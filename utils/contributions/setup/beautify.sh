#!/bin/bash
# Xanthopoulos Constantinos
# Some useful function for my scripts

function cecho
{
	 echo -e "\033[1m\033[33m$1\033[0m"
}

function cnecho
{
	 echo -e -n "\033[0m\033[33m$1\033[0m"
}

function errormsg
{	
	echo -e "\033[1m\033[31mError: $1\033[0m\n";
	exit 1;
}

function execcmd
{
        # Print Message
        echo -e "\033[35m$1\033[0m"
        # Execute command
        echo $2
        if [ $DEBUG -ne 1 ];
	then
		eval $2;
	fi;
        # Check Execution
        if [ $? -eq 0 ]
        then
                echo -e "\033[32mSuccessfully \"$1\"\033[0m\n";
        else
               	errormsg "$1"; 
                exit 1;

        fi
}

if [ $DEBUG -eq 1 ]
then
	cecho "Debug mode on! Nothing will actually run";
fi
