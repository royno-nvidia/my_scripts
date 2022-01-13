import argparse
import os
import re
import subprocess
from pygit2 import Repository
from pygit2 import GIT_SORT_TOPOLOGICAL

def create_mail(problens=[], workspace='/tmp'):
    if problens:
        html_string = """
        <!DOCTYPE html>
        <html>
        <head>
        <style>
        </style>
        </head>
        <body>
        """
        html_string += '\n'.join(problens)
        html_string += """
                        </body>
                        </html>
                        """
        with open(f"{workspace}/history_verifier.html", "w") as F:
            F.write(f"{html_string}")


def run_shell_command(cmd):
    print(f'CMD: {cmd}')
    return subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout.decode('utf-8')


def get_change_id_from_cmsg(commit):
    s = re.search('Change-Id: *(I[a-f0-9]+)', commit.message)
    if s:
        return s.group(1).strip()
    else:
        print(f'failed to find change-id for {commit.hex}')
        return None


def add_new_problem(actual_diff, base_sha, back_sha):
    print(f'DIFF FOUND\n{actual_diff}')
    return f"Base commit {base_sha} and History commit {back_sha} are not aligned\n" + '\n'.join(actual_diff)


def extract_acttual_diff(full_diff: str):
    ignore_pattern = ['Only in', 'backports', '.git', 'quiltrc', 'tags']
    relevant_diff = []
    for line in full_diff.split('\n'):
        if not any(sub in line for sub in ignore_pattern) and line:
            relevant_diff.append(line)
    return relevant_diff


def get_subject_from_cmsg(commit):
    split = commit.message.split('\n')
    return split[0]


def operate_on_base_side(base_path, data):
    os.chdir(base_path)
    run_shell_command(f"git checkout {data['base']}")
    run_shell_command(f'git branch -D backport-HEAD')  # remove unused head
    run_shell_command(f'./ofed_scripts/ofed_patch.sh')


def operate_on_backport_side(back_path, data, base_path, back_path1):
    os.chdir(back_path)
    run_shell_command(f"git checkout {data['back']}")


def reset_directories(base_path, back_path, origin_branch):
    os.chdir(base_path)
    run_shell_command(f"git checkout {origin_branch['base']}")
    run_shell_command(f'git branch -D backport-HEAD')  # remove unused head
    os.chdir(back_path)
    run_shell_command(f"git checkout {origin_branch['back']}")


def parse_args():
    parser = argparse.ArgumentParser(description="The scripts is meant to run as a bot ")
    parser.add_argument("-base", type=str, default="", required=True, help="OFED git path")
    parser.add_argument("-back", type=str, default="", required=True, help="OFED git path ends with _history")
    parser.add_argument("-workspace", type=str, default="", required=True, help="Workspace path")
    options = parser.parse_args()
    return options
##########################MAIN##########################


def main():
    args = parse_args()
    problems = []
    base_path = args.base
    back_path = args.back
    base = Repository(f'{base_path}/.git')
    back = Repository(f'{back_path}/.git')
    info = {}
    origin_branch = {
        'base': base.lookup_reference('HEAD').resolve().shorthand,
        'back': back.lookup_reference('HEAD').resolve().shorthand
    }

    for commit in back.walk(back.head.target, GIT_SORT_TOPOLOGICAL):
        sub = get_subject_from_cmsg(commit)
        cid = get_change_id_from_cmsg(commit)
        info[cid] = {
            'sub': sub,
            'back': commit.hex,
            'base': ''
        }

    for commit in base.walk(base.head.target, GIT_SORT_TOPOLOGICAL):
        cid = get_change_id_from_cmsg(commit)
        if cid in info.keys():
            if info[cid]['back'] == commit.hex:  # exact same commit - no need to check
                del info[cid]
            else:  # aligned commit from base found
                info[cid]['base'] = commit.hex

    for cid, data in info.items():
        if not data['base']:  # missing commit in base branch
            problems.append(f"Change-id '{cid}' is missing in '{origin_branch['base']}' branch")
            continue

        operate_on_base_side(base_path, data)
        operate_on_backport_side(back_path, data, base_path, back_path)

        diff = run_shell_command(f"diff -qr {base_path} {back_path}")
        actual_diff = extract_acttual_diff(diff)
        if actual_diff:
            problems.append(add_new_problem(actual_diff, data['base'], data['back']))

    reset_directories(base_path, back_path, origin_branch)

    if problems:
        rc = len(problems)
        print(f'Found {rc} un-aligned commits')
        print('\n'.join(problems))
        create_mail(problems, args.workspace)
        exit(rc)
    else:
        print(f'No Problems found!')
        exit(0)


if __name__ == '__main__':
    main()
