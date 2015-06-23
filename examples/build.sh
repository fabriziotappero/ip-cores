#!/bin/bash


../asm/asm $1.asm > $1.bin
cat $1.bin | ../sim/sendb
