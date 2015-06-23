#!/bin/bash
# Xanthopoulos Constantinos
# Some useful function for my scripts

function cecho
{
	 echo -e "\033[1m\033[33m$1\033[0m"
	 echo -e "\033[1m\033[33m$1\033[0m" >> ${SCRIPT_DIR}/progress.log
}

function cnecho
{
	 echo -e -n "\033[0m\033[33m$1\033[0m"
	 echo -e -n "\033[0m\033[33m$1\033[0m" >> ${SCRIPT_DIR}/progress.log
}

function errormsg
{	
	echo -e "\033[1m\033[31mError: $1\033[0m\n";
	echo -e "\033[1m\033[31mError: $1\033[0m\n" >> ${SCRIPT_DIR}/error.log
	exit 1;
}

function _execcmd
{
    # Print Message
    echo -e "\033[35m$1...\033[0m\n" >> ${SCRIPT_DIR}/progress.log
    if [ -n "$1" ]
    then
	echo -e -n "\033[35m$1...\033[0m"
    fi
    # Execute command
    if [ $DEBUG -ne 1 ];
    then
        eval $2 1>>${SCRIPT_DIR}/progress.log 2>>${SCRIPT_DIR}/error.log;
    fi;
    # Check Execution
    if [ $? -eq 0 ]
    then
        if [ -n "$1" ]
        then
            echo -e "\033[32mcomplete\033[0m";
	    echo -e "\033[32mcomplete\033[0m" >> ${SCRIPT_DIR}/progress.log
        fi
    else
        errormsg "Command: $2 Description: $1"; 
        exit 1;
    fi
}

function execcmd
{
    if [ -z "$2" ]
    then
        _execcmd "" "$1"
    else
        _execcmd "$1" "$2"
    fi
}

if [ $DEBUG -eq 1 ]
then
    cecho "Debug mode on! Nothing will actually run";
fi
