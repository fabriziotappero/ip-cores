@echo off
arm-elf-as.exe -EB -mapcs-32 main.asm
extract.exe