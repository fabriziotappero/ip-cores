del test.bin

echo Cleaning...
make clean

echo Compiling sources...
make  > err.txt
hexbin waves.hex test.bin I

echo Copying binary file to VHDL test directory...
del ..\..\tools\build_vhdl_test\test.bin
copy test.bin ..\..\tools\build_vhdl_test
