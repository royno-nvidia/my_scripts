#!/bin/bash

echo "Checking if unifdef installed"
if ! command -v unifdef &> /dev/null
then
	echo "unifdef tool is missing.. installing"
	sudo yum -y install unifdef
else
	echo "Already installed"
fi
