del *.obj
del *.lst
del *.map
del *.hex
del *.bin
del *.err
del *.ini
del *.equ
del *.nlb
del *.tds
del *.exe
del *.dat

make clean
del coff\*.* /S /Q
rmdir coff