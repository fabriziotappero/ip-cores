TABLE OF CONTENTS
  1) Peripheral Summary
  2) Description of Generated Files
  3) Description of Used IPIC Signals
  4) Description of Top Level Generics


================================================================================
*                             1) Peripheral Summary                            *
================================================================================
Peripheral Summary:

  XPS project / EDK repository               : D:\custom_pulse_generator\standalone_pulse_generator
  logical library name                       : s3e_vga_char_dev_v1_00_a
  top name                                   : s3e_vga_char_dev
  version                                    : 1.00.a
  type                                       : OPB slave
  features                                   : slave attachement
                                               mir/rst register
                                               user s/w registers

Address Block for User Logic and IPIF Predefined Services

  User logic slave space service             : C_BASEADDR + 0x00000000
                                             : C_BASEADDR + 0x000000FF
  IPIF Reset/MIR service                     : C_BASEADDR + 0x00000100
                                             : C_BASEADDR + 0x000001FF


================================================================================
*                          2) Description of Generated Files                   *
================================================================================
- HDL source file(s)
  D:\custom_pulse_generator\standalone_pulse_generator/pcores/s3e_vga_char_dev_v1_00_a/hdl

  vhdl/s3e_vga_char_dev.vhd

    This is the template file for your peripheral's top design entity. It
    configures and instantiates the corresponding IPIF unit in the way you
    indicated in the wizard GUI and hooks it up to the stub user logic where
    the actual functionalites should get implemented. You are not expected to
    modify this template file except certain marked places for adding user
    specific generics and ports.

  verilog/user_logic.v

    This is the template file for the stub user logic design entity, either in
    VHDL or Verilog, where the actual functionalities should get implemented.
    Some sample code snippet may be provided for demonstration purpose.


- XPS interface file(s)
  D:\custom_pulse_generator\standalone_pulse_generator/pcores/s3e_vga_char_dev_v1_00_a/data

  s3e_vga_char_dev_v2_1_0.mpd

    This Microprocessor Peripheral Description file contains information of the
    interface of your peripheral, so that other EDK tools can recognize your
    peripheral.

  s3e_vga_char_dev_v2_1_0.pao

    This Peripheral Analysis Order file defines the analysis order of all the HDL
    source files that are used to compile your peripheral.


- ISE project file(s)
  D:\custom_pulse_generator\standalone_pulse_generator/pcores/s3e_vga_char_dev_v1_00_a/devl/projnav

  s3e_vga_char_dev.npl

    This is the ProjNavigator project file. It sets up the needed logical
    libraries and dependent library files for you to help you develop your
    peripheral using ProjNavigator.

  s3e_vga_char_dev.cli

    This is the TCL command line file used to generate the .npl file.


- XST synthesis file(s)
  D:\custom_pulse_generator\standalone_pulse_generator/pcores/s3e_vga_char_dev_v1_00_a/devl/synthesis

  s3e_vga_char_dev_xst.scr

    This is the XST synthesis script file to compile your peripheral.
    Note: you may want to modify the device part option for your target.

  s3e_vga_char_dev_xst.prj

    This is the XST synthesis project file used by the above script file to
    compile your peripheral.


- Driver source file(s)
  D:\custom_pulse_generator\standalone_pulse_generator/drivers/s3e_vga_char_dev_v1_00_a/src

  s3e_vga_char_dev.h

    This is the software driver header template file, which contains address offset of
    software addressable registers in your peripheral, as well as some common masks and
    simple register access macros or function declaration.

  s3e_vga_char_dev.c

    This is the software driver source template file, to define all applicable driver
    functions.

  s3e_vga_char_dev_selftest.c

    This is the software driver self test example file, which contain self test example
    code to test various hardware features of your peripheral.

  Makefile

    This is the software driver makefile to compile drivers.


- Driver interface file(s)
  D:\custom_pulse_generator\standalone_pulse_generator/drivers/s3e_vga_char_dev_v1_00_a/data

  s3e_vga_char_dev_v2_1_0.mdd

    This is the Microprocessor Driver Definition file.

  s3e_vga_char_dev_v2_1_0.tcl

    This is the Microprocessor Driver Command file.


- Other misc file(s)
  D:\custom_pulse_generator\standalone_pulse_generator/pcores/s3e_vga_char_dev_v1_00_a/devl

  ipwiz.opt

    This is the option setting file for the wizard batch mode, which should
    generate the same result as the wizard GUI mode.

  README.txt

    This README file for your peripheral.

  ipwiz.log

    This is the log file by operating on this wizard.


================================================================================
*                         3) Description of Used IPIC Signals                  *
================================================================================
For more information (usage, timing diagrams, etc.) regarding the IPIC signals
used in the templates, please refer to the following specifications (under
%XILINX_EDK%\doc for windows or $XILINX_EDK/doc for solaris and linux):
proc_ip_ref_guide.pdf - Processor IP Reference Guide (chapter 4 IPIF)
user_core_templates_ref_guide.pdf - User Core Templates Reference Guide

Bus2IP_Clk
    This is the clock input to the user logic. All IPIC signals are synchronous 
    to this clock. It is identical to the <bus>_Clk signal that is an input to 
    the user core. In an OPB core, Bus2IP_Clk is the same as OPB_Clk, and in a 
    PLB core, it is the same as PLB_Clk. No additional buffering is provided on 
    the clock; it is passed through as is. 

Bus2IP_Reset
    Signal to reset the User Logic; asserts whenever the <bus>_Rst signal does 
    and, if the Reset block is included, whenever there is a software-programmed 
    reset. 

Bus2IP_Data
    This is the data bus from the IPIF to the user logic; it is used for both 
    master and slave transactions. It is used to access user logic registers. 

Bus2IP_BE
    The Bus2IP_BE is a bus of Byte Enable qualifiers from the IPIF to the user 
    logic. A bit in the Bus2IP_BE set to '1' indicates that the associated byte 
    lane contains valid data. For example, if Bus2IP_BE = 0011, this indicates 
    that byte lanes 2 and 3 contains valid data. 

Bus2IP_RdCE
    The Bus2IP_RdCE bus is an input to the user logic. It is Bus2IP_CE qualified 
    by a read transaction. 

Bus2IP_WrCE
    The Bus2IP_WrCE bus is an input to the user logic. It is Bus2IP_CE qualified 
    by a write transaction. 

IP2Bus_Data
    This is the data bus from the user logic to the IPIF; it is used for both 
    master and slave transactions. It is used to access user logic registers. 

IP2Bus_Ack
    The IP2Bus_Ack signal provide the read/write acknowledgement from the user 
    logic to the IPIF. For writes, it indicates the data has been taken by the 
    user logic. For reads, it indicates that valid data is available. For 
    immediate acknowledgement (such as for a register read/write), this signal 
    can be tied to '1'. Wait states can be inserted in the transaction by 
    delaying the assertion of the acknowledgement. If the IP2Bus_Ack for OPB 
    cores will be delayed more than 8 clocks, then the IP2Bus_ToutSup (timeout 
    suppress) signal must also be asserted to prevent a timeout on the host bus. 

IP2Bus_Retry
    IP2Bus_Retry is a response from the user logic to the IPIF that indicates 
    the currently requested transaction cannot be completed at this time and 
    that the requesting master should retry the operation. If the IP2Bus_Retry 
    signal will be delayed more than 8 clocks, then the IP2Bus_ToutSup (timeout 
    suppress) signal must also be asserted to prevent a timeout on the host bus. 
    Note: this signal is unused by PLB IPIF. 

IP2Bus_Error
    This signal from the user logic to the IPIF indicates an error has occurred 
    during the current transaction. It is valid when IP2Bus_Ack is asserted. 

IP2Bus_ToutSup
    The IP2Bus_ToutSup must be asserted by the user logic whenever its 
    acknowledgement or retry response will take longer than 8 clock cycles. 

================================================================================
*                     4) Description of Top Level Generics                     *
================================================================================
C_BASEADDR/C_HIGHADDR
    These two generics are used to define the memory mapped address space for
    the peripheral registers, including Reset/MIR register, Interrupt Source
    Controller registers, Read/Write FIFO control/data registers, user logic
    software accessible registers and etc., but excluding those user logic
    address ranges if ever used. When instantiation, the address space size
    determined by these two generics must be a power of 2 (e.g. 2^k =
    C_HIGHADDR - C_BASEADDR + 1), a factor of C_BASEADDR and larger than the
    minimum size as indicated in the template.

C_OPB_DWIDTH
    This is the data bus width for On-chip Peripheral Bus (OPB). It should
    always be set to 32 as of today.

C_OPB_AWIDTH
    This is the address bus width for On-chip Peripheral Bus (OPB). It should
    always be set to 32 as of today.

C_USER_ID_CODE
    This is the ID that will be put into the MIR register, it's mainly used
    for debug purpose to identify the peripheral under test if multiple
    instances exist in the system.

C_FAMILY
    This is to set the target FPGA architecture, s.t. virtex2, virtex2p, etc.

