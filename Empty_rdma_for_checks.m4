dnl Examine kernel functionality

# DO NOT insert new defines in this section!!!
# Add your defines ONLY in LINUX_CONFIG_COMPAT section
AC_DEFUN([BP_CHECK_RHTABLE],
[
	AC_MSG_CHECKING([if file include/linux/rhashtable-types.h exists])
	MLNX_BG_LB_LINUX_TRY_COMPILE([
		#include <linux/rhashtable-types.h>
	],[
		struct rhltable x;
		x = x;

		return 0;
	],[
		AC_MSG_RESULT(yes)
		MLNX_AC_DEFINE(HAVE_RHASHTABLE_TYPES, 1,
			[file rhashtable-types exists])
	],[
		AC_MSG_RESULT(no)
		AC_MSG_CHECKING([if rhltable defined])
		MLNX_BG_LB_LINUX_TRY_COMPILE([
			#include <linux/rhashtable.h>
		],[
			struct rhltable x;
			x = x;

			return 0;
		],[
			AC_MSG_RESULT(yes)
			MLNX_AC_DEFINE(HAVE_RHLTABLE, 1,
				[struct rhltable is defined])
			AC_MSG_CHECKING([if struct rhashtable_params contains insecure_elasticity])
			MLNX_BG_LB_LINUX_TRY_COMPILE([
				#include <linux/rhashtable.h>
			],[
				struct rhashtable_params x;
				unsigned int y;
				y = (unsigned int)x.insecure_elasticity;

				return 0;
			],[
				AC_MSG_RESULT(yes)
				MLNX_AC_DEFINE(HAVE_RHASHTABLE_INSECURE_ELASTICITY, 1,
					[struct rhashtable_params has insecure_elasticity])
			],[
				AC_MSG_RESULT(no)
			])
			AC_MSG_CHECKING([if struct rhashtable_params contains insecure_max_entries])
			MLNX_BG_LB_LINUX_TRY_COMPILE([
				#include <linux/rhashtable.h>
			],[
				struct rhashtable_params x;
				unsigned int y;
				y = (unsigned int)x.insecure_max_entries;

				return 0;
			],[
				AC_MSG_RESULT(yes)
				MLNX_AC_DEFINE(HAVE_RHASHTABLE_INSECURE_MAX_ENTRIES, 1,
					[struct rhashtable_params has insecure_max_entries])
			],[
				AC_MSG_RESULT(no)
			])
			AC_MSG_CHECKING([if struct rhashtable contains max_elems])
			MLNX_BG_LB_LINUX_TRY_COMPILE([
				#include <linux/rhashtable.h>
			],[
				struct rhashtable x;
				unsigned int y;
				y = (unsigned int)x.max_elems;

				return 0;
			],[
				AC_MSG_RESULT(yes)
				MLNX_AC_DEFINE(HAVE_RHASHTABLE_MAX_ELEMS, 1,
					[struct rhashtable has max_elems])
			],[
				AC_MSG_RESULT(no)
			])
		],[
			AC_MSG_RESULT(no)
			AC_MSG_CHECKING([if struct netns_frags contains rhashtable])
			MLNX_BG_LB_LINUX_TRY_COMPILE([
				#include <linux/in6.h>
				#include <net/inet_frag.h>
			],[
				struct netns_frags x;
				struct rhashtable rh;
				rh = x.rhashtable;

				return 0;
			],[
				AC_MSG_RESULT(yes)
				MLNX_AC_DEFINE(HAVE_NETNS_FRAGS_RHASHTABLE, 1,
					[struct netns_frags has rhashtable])
			],[
				AC_MSG_RESULT(no)
			])
		])
	])
])


AC_DEFUN([LINUX_CONFIG_COMPAT],
[

#############################
# Copy here config to check #
#############################

])
#
# COMPAT_CONFIG_HEADERS
#
# add -include config.h
#
AC_DEFUN([COMPAT_CONFIG_HEADERS],[
#
#	Wait for remaining build tests running in background
#
	wait
#
#	Append confdefs.h files from CONFDEFS_H_DIR to the main confdefs.h file
#
	/bin/cat CONFDEFS_H_DIR/confdefs.h.* >> confdefs.h
	/bin/rm -rf CONFDEFS_H_DIR
#
#	Generate the config.h header file
#
	AC_CONFIG_HEADERS([config.h])
	EXTRA_KCFLAGS="-include $PWD/config.h $EXTRA_KCFLAGS"
	AC_SUBST(EXTRA_KCFLAGS)
])

AC_DEFUN([MLNX_PROG_LINUX],
[

LB_LINUX_PATH
LB_LINUX_SYMVERFILE
LB_LINUX_CONFIG([MODULES],[],[
    AC_MSG_ERROR([module support is required to build mlnx kernel modules.])
])
LB_LINUX_CONFIG([MODVERSIONS])
LB_LINUX_CONFIG([KALLSYMS],[],[
    AC_MSG_ERROR([compat_mlnx requires that CONFIG_KALLSYMS is enabled in your kernel.])
])

LINUX_CONFIG_COMPAT
COMPAT_CONFIG_HEADERS

])
