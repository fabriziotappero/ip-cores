#!/bin/sh
fuse -incremental -o tb.exe -prj ../src/tb_aes.prj tb_aes
./tb.exe
