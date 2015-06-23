::######################################################
::#                                                    #
::# Xilinx Synthesis, Place & Route script for WINDOWS #
::#                                                    #
::######################################################

:: Cleanup
RMDIR /S /Q .\WORK
MKDIR WORK
cd ./WORK

:: Copy the RAM & ROM ngc files
XCOPY ..\..\..\rtl\verilog\coregen\ram_16x512.ngc .
XCOPY ..\..\..\rtl\verilog\coregen\ram_16x2k.ngc .

:: Copy the Xilinx constraints file
XCOPY ..\openMSP430_fpga.ucf                        .


:: XFLOW
::---------------

xflow -p 3S200FT256-4 -implement high_effort.opt    ^
                      -config    bitgen.opt         ^
                      -synth     ..\xst_verilog.opt ^
                      ..\openMSP430_fpga.prj

:: MANUAL FLOW
::---------------

::xst      -intstyle xflow    -ifn ..\openMSP430_fpga.xst

::ngdbuild -p xc3s200-4-ft256 -uc  ..\openMSP430_fpga.ucf openMSP430_fpga

::map -k 6 -detail -pr b openMSP430_fpga

::par -ol med -w openMSP430_fpga.ncd openMSP430_fpga

::trce -e -o openMSP430_fpga_err.twr openMSP430_fpga
::trce -v -o openMSP430_fpga_ver.twr openMSP430_fpga

::bitgen -w -g UserID:5555000 -g DonePipe:yes -g UnusedPin:Pullup openMSP430_fpga


cd ..
PAUSE