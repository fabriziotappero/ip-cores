#!/bin/bash

#system workings
MINSOC_DIR=`pwd`/..

PROJECT=$1
OUTPUT=$2

ENV=`uname -o`

function adaptpath
{
    if [ "$ENV" == "Cygwin" ]
    then
        local cygpath=`cygpath -w $1`
        local result=`echo $cygpath | sed 's/\\\\/\\//g'`
        echo "$result"
    else
        echo "$1"
    fi
}

if [ ! -f $PROJECT ]
then
    echo "Unexistent project file."
    exit 1
fi

if [ -z "$OUTPUT" ]
then
    echo "Second argument should be the destintion file for the file and directory inclusions."
    exit 1
fi
echo -n "" > $OUTPUT

source $PROJECT

for file in "${PROJECT_SRC[@]}"
do
    FOUND=0

    for dir in "${PROJECT_DIR[@]}"
    do
        if [ -f $MINSOC_DIR/$dir/$file ]
        then
            adapted_file=`adaptpath $MINSOC_DIR/$dir/$file`
            echo "$adapted_file" >> $OUTPUT
            FOUND=1
            break
        fi
    done

    if [ $FOUND != 1 ]
    then
        echo "FILE NOT FOUND: $file"
        exit 1
    fi
done
