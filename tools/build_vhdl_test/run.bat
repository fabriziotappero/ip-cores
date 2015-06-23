echo off

set crtdir=%cd%
set pavrdir=..\..\
set testdir=%pavrdir%test\
set buildvhdltestdir=%pavrdir%tools\build_vhdl_test\
set srcdir=%pavrdir%src\

rem rem General test ------------------
rem echo Building general test...
rem cd %testdir%gentest\
rem del test.bin
rem call compile.bat
rem echo Copying binary file...
rem copy test.bin %buildvhdltestdir%
rem rem -------------------------------

rem rem Sieve of Eratoshthenes ------------
rem echo Building Sieve of Eratosthenes test...
rem cd %testdir%sieve\
rem  del test.bin
rem  call gcccompile.bat
rem echo Copying binary file...
rem copy test.bin %buildvhdltestdir%
rem rem -----------------------------------

rem Waves -----------------------------
echo Building Waves test...
cd %testdir%waves\
 del test.bin
 call gcccompile.bat
echo Copying binary file...
copy test.bin %buildvhdltestdir%
rem -----------------------------------

cd %buildvhdltestdir%
echo Copying VHDL source file...
copy %srcdir%test_pavr.vhd %buildvhdltestdir%

echo Building VHDL source test file...
build_vhdl_test.exe test_pavr.vhd test.bin

echo Overwriting the original VHDL source test file...
copy test_pavr.vhd %srcdir%

echo Changing to initial directory...
cd %crtdir%
