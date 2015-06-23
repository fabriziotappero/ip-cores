md html
md chm


doxygen doxygen.cfg
copy ..\src\*.vhd html\
copy ..\src\*.do html\
copy ..\src\gpl.txt html\

echo Building compressed HTML file...
cd html
hhc index.hhp

cd ..
copy html\index.chm chm\pavr.chm

del html\index.hhc
del html\index.hhk
del html\index.hhp
del html\index.chm
