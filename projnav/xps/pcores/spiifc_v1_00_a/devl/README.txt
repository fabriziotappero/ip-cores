TABLE OF CONTENTS
  1) Peripheral Summary
  2) Description of Generated Files
  3) Description of Used IPIC Signals
  4) Description of Top Level Generics


================================================================================
*                             1) Peripheral Summary                            *
================================================================================
Peripheral Summary:

  XPS project / EDK repository               : C:\Users\mjlyons\workspace\vSPI\projnav\xps
  logical library name                       : spiifc_v1_00_a
  top name                                   : spiifc
  version                                    : 1.00.a
  type                                       : PLB (v4.6) slave
  features                                   : slave attachment
                                               interrupt control
                                               user s/w registers
                                               user memory spaces

Address Block for User Logic and IPIF Predefined Services

  user logic slave space                     : C_BASEADDR + 0x00000000
                                             : C_BASEADDR + 0x000000FF
  interrupt control space                    : C_BASEADDR + 0x00000100
                                             : C_BASEADDR + 0x000001FF
  User logic memory space 0                  : C_MEM0_BASEADDR
                                             : C_MEM0_HIGHADDR
  User logic memory space 1                  : C_MEM1_BASEADDR
                                             : C_MEM1_HIGHADDR


================================================================================
*                          2) Description of Generated Files                   *
================================================================================
- HDL source file(s)

  hdl/vhdl/spiifc.vhd

    This is the template file for your peripheral's top design entity. It
    configures and instantiates the corresponding design units in the way you
    indicated in the wizard GUI and hooks it up to the stub user logic where
    the actual functionalites should get implemented. You are not expected to
    modify this template file except certain marked places for adding user
    specific generics and ports.

  verilog/user_logic.v

    This is the template file for the stub user logic design entity, either in
    VHDL or Verilog, where the actual functionalities should get implemented.
    Some sample code snippet may be provided for demonstration purpose.

- XPS interface file(s)

  data/spiifc_v2_1_0.mpd

    This Microprocessor Peripheral Description file contains information of the
    interface of your peripheral, so that other EDK tools can recognize your
    peripheral.

  data/spiifc_v2_1_0.pao

    This Peripheral Analysis Order file defines the analysis order of all the HDL
    source files that are used to compile your peripheral.

- ISE project file(s)

  devl/projnav/spiifc.ise

    This is the ProjNavigator project file. It sets up the needed logical
    libraries and dependent library files for you to help you develop your
    peripheral using ProjNavigator.

  devl/projnav/spiifc.cli

    This is the TCL command line file used to generate the .ise file.

- XST synthesis file(s)

  devl/synthesis/spiifc_xst.scr

    This is the XST synthesis script file to compile your peripheral.
    Note: you may want to modify the device part option for your target.

  devl/synthesis/spiifc_xst.prj

    This is the XST synthesis project file used by the above script file to
    compile your peripheral.

- Driver source file(s)

  src/spiifc.h

    This is the software driver header template file, which contains address offset of
    software addressable registers in your peripheral, as well as some common masks and
    simple register access macros or function declaration.

  src/spiifc.c

    This is the software driver source template file, to define all applicable driver
    functions.

  src/spiifc_selftest.c

    This is the software driver self test example file, which contain self test example
    code to test various hardware features of your peripheral.

  src/Makefile

    This is the software driver makefile to compile drivers.

- Driver interface file(s)
-user needs to add these to repositories path in SDK (Xilinx Tools-->Repositories)

  data/spiifc_v2_1_0.mdd

    This is the Microprocessor Driver Definition file.

  data/spiifc_v2_1_0.tcl

    This is the Microprocessor Driver Command file.

- Other misc file(s)

  devl/ipwiz.opt

    This is the option setting file for the wizard batch mode, which should
    generate the same result as the wizard GUI mode.

  devl/README.txt

    This README file for your peripheral.

  devl/ipwiz.log

    This is the log file by operating on this wizard.


================================================================================
*                         3) Description of Used IPIC Signals                  *
================================================================================
For more information (usage, timing diagrams, etc.) regarding the IPIC signals
used in the templates, please refer to the following specifications:
proc_common_v3_00_a
	No documentation for this library

plbv46_slave_burst_v1_01_a
	C:\Users\mjlyons\workspace\vSPI\projnav\xps\C:\Xilinx\13.2\ISE_DS\EDK\hw\XilinxProcessorIPLib\pcores\plbv46_slave_burst_v1_01_a\doc\plbv46_slave_burst.pdf

interrupt_control_v2_01_a
	C:\Users\mjlyons\workspace\vSPI\projnav\xps\C:\Xilinx\13.2\ISE_DS\EDK\hw\XilinxProcessorIPLib\pcores\interrupt_control_v2_01_a\doc\interrupt_control.pdf

Bus2IP_Clk
    Synchronization clock provided to the user logic. All IPIC signals are 
    synchronous to this clock. It is identical to the input <bus>_Clk signal of 
    the peripheral. No additional buffering is provided on the clock; it is 
    passed through as is. 

Bus2IP_Reset
    Active high reset used by the user logic. It is asserted whenever the 
    <bus>_Rst signal asserts or whenever there is a software-programmed reset 
    (if the soft reset block is included). 

Bus2IP_Addr
    Address bus to the user logic. It indicates the address of the requested 
    read or write operation. It can be used for additional address decoding or 
    as input to addressable memory devices. 

Bus2IP_CS
    Active high chip select bus. Assertion of a chip select indicates an active 
    transaction request to the chip select's target address space. This is 
    typically used for user logic memory space selection. 

Bus2IP_RNW
    Input signal to the user logic. It indicates the sense of a requested 
    operation with the user logic. High is a read and low is a write. It is 
    valid whenever at least one of the Bus2IP_CS bits is active. 

Bus2IP_Data
    Write data bus to the user logic. Write data is accepted by the user logic 
    during a write operation by assertion of the write acknowledgement signal 
    and the rising edge of the Bus2IP_Clk. 

Bus2IP_BE
    Byte Enable qualifiers for the requested read or write operation to the user 
    logic. A bit in the Bus2IP_BE set to '1' indicates that the associated byte 
    lane contains valid data. For example, if Bus2IP_BE = 0011, this indicates 
    that byte lanes 2 and 3 contain valid data. 

Bus2IP_RdCE
    Active high chip enable bus to the user logic. These chip enables are only 
    asserted during active read transaction requests with the target address 
    space and in conjunction with the corresponding sub-address within the 
    space. These are typically used for user logic readable registers selection. 

Bus2IP_WrCE
    Active high chip enable bus to the user logic. These chip enables are 
    asserted only during active write transaction requests with the target 
    address space and in conjunction with the corresponding sub-address within 
    the space. Typically used for user logic writable registers selection. 

Bus2IP_Burst
    Active high signal indicating that the active read or write operation with 
    the user logic is utilizing bursting protocol. This signal is asserted at 
    the initiation of a burst transaction with the user logic and de-asserted at 
    the completion of the second to last data beat of the burst data transfer. 

Bus2IP_BurstLength
    This value is an indication of the number of bytes being requested for 
    transfer and is valid when the cycle is of burst type Bus2IP_CS is active. 

Bus2IP_RdReq
    Active high signal indicating the initiation of a read operation with the 
    user logic. It is asserted for one Bus2IP_Clk during single data beat 
    transactions and remains high to completion on burst read operations. 

Bus2IP_WrReq
    Active high signal indicating the initiation of a write operation with the 
    user logic. It is asserted for one Bus2IP_Clk during single data beat 
    transactions and remains high to completion on burst write operations. 

IP2Bus_AddrAck
    Active high signal that advances the address counter and request state 
    during multiple data beat transfers, i.e. bursting. 

IP2Bus_Data
    Output read data bus from the user logic; data is qualified with the 
    assertion of IP2Bus_RdAck signal and the rising edge of the Bus2IP_Clk. 

IP2Bus_RdAck
    Active high read data qualifier providing the read acknowledgement from the 
    user logic. Read data on the IP2Bus_Data bus is deemed valid at the rising 
    edge of the Bus2IP_Clk and IP2Bus_RdAck asserted high by the user logic. For 
    immediate acknowledgement (such as for a register read), this signal can be 
    tied to '1'. Wait states can be inserted in the transaction by delaying the 
    assertion of the acknowledgement. 

IP2Bus_WrAck
    Active high write data qualifier providing the write acknowledgement from 
    the user logic. Write data on the Bus2IP_Data bus is deemed accepted by the 
    user logic at the rising edge of the Bus2IP_Clk and IP2Bus_WrAck asserted 
    high by the user logic. For immediate acknowledgement (such as for a 
    register write), this signal can be tied to '1'. Wait states can be inserted 
    in the transaction by delaying the assertion of the acknowledgement. 

IP2Bus_Error
    Active high signal indicating the user logic has encountered an error with 
    the requested operation. It is asserted in conjunction with the read/write 
    acknowledgement signal(s). 

IP2Bus_IntrEvent
    An output from the user logic to the IPIF that consists of interrupt event 
    signals to be detected and latched inside the IPIF. 

================================================================================
*                     4) Description of Top Level Generics                     *
================================================================================
C_BASEADDR/C_HIGHADDR
    These two generics are used to define the memory mapped address space for
    the peripheral registers, including Soft Reset register, Interrupt Source
    Controller registers, Read/Write FIFO control/data registers, user logic
    software accessible registers and etc., but excluding those user logic
    memory spaces if ever existed. When instantiation, the address space
    size determined by these two generics must be a power of 2 (e.g. 2^k =
    C_HIGHADDR - C_BASEADDR + 1), a factor of C_BASEADDR and larger than the
    minimum size as indicated in the template.

C_SPLB_AWIDTH
    This is the slave interface address bus width for Processor Local Bus
    version 4.6 (PLBv46). Value can be assigned automatically by EDK
    tooling during system creation.

C_SPLB_DWIDTH
    This is the slave interface data bus width for Processor Local Bus
    version 4.6 (PLBv46). Value can be assigned automatically by EDK
    tooling during system creation.

C_SPLB_NUM_MASTERS
    This indicates to the slave interface the number of PLBv46 masters
    present. Value can be assigned automatically by EDK tooling during
    system creation.

C_SPLB_MID_WIDTH
    This indicates to the slave interface the number of bits required
    for the PLB_masterID input bus. It is an integer value equal to
    log2(C_SPLB_NUM_MASTERS). Value will be assigned automatically by
    EDK tooling during system creation.

C_SPLB_NATIVE_DWIDTH
    This indicates to the slave interface the native bit width of the
    internal data bus of the peripheral. Some peripheral will require
    the value of this parameter to be fixed, while others might have
    selectable native data widths.

C_SPLB_P2P
    This indicates to the slave interface when it is exclusively attached
    to a PLBv46 bus via a Point to Point interconnect scheme. In this
    scenario, the slave interface may be able to reduce resource utilization
    by eliminating address decode function and modifying interface behavior
    to allow for a reduction in latency.

C_SPLB_SUPPORT_BURSTS
    This indicates to the associated PLBv46 bus that this slave interface
    support burst transfers to improve performance.

C_SPLB_SMALLEST_MASTER
    This indicates the smallest native data width of any master on the
    corresponding PLBv46 bus that may access the slave interface. It allows
    optimizations within the slave interface logic if narrower masters don't
    have to be supported for that application.

C_SPLB_CLK_PERIOD_PS
    This is the period of the PLBv46 bus clock (in picoseconds) for the
    corresponding PLBv46 slave interface attachment. It has been defined
    for use by peripheral that needs to know the bus clock rate to improve
    certain functions such as internal timers.

C_INCLUDE_DPHASE_TIMER
    This indicates if the data phase timer is used or not. The value of
    0 will exclude the timer.  The value of 1 includes the timer.
    If C_INCLUDE_DPHASE_TIMER = 1 and after 128 SPLB_Clk cycles, as
    measured from the assertion of Sl_AddrAck, the User IP does not
    respond with either an IP2Bus_RdAck or IP2Bus_WrAck the 
    plbv46_slave_single will de-assert the User IP cycle request
    signals, Bus2IP_CS and Bus2IP_RdCE or Bus2IP_WrCE, and will assert
    Sl_rdDAck with Sl_rdDBus=zero for a read cycle or Sl_wrDAck for
    a write cycle. This will gracefully terminate the cycle. Note 
    that the requesting master will have no knowledge that the data
    phase of the PLB request was terminated in this manner.

C_FAMILY
    This is to set the target FPGA architecture, s.t. virtex6, etc.

C_MEMn_BASEADDR/C_MEMn_HIGHADDR (n = 0, 1, 2, etc.)
    These two generics are used to define the memory mapped address space for
    user logic memory space n, which are typically used in peripherals like
    memory controllers, bridges, that need to access memory blocks other
    than local register space. When instantiation, the address space size
    determined by these two generics should be a power of 2 (e.g. 2^k =
    C_MEMn_HIGHADDR - C_MEMn_BASEADDR + 1) and a factor of C_MEMn_BASEADDR.

================================================================================
*          5) Location to documentation of dependent libraries                 *
*                                                                              *
*   In general, the documentation is located under:                            *
*   $XILINX_EDK/hw/XilinxProcessorIPLib/pcores/$libName/doc                    *
*                                                                              *
================================================================================
proc_common_v3_00_a
	No documentation for this library

plbv46_slave_burst_v1_01_a
	C:\Users\mjlyons\workspace\vSPI\projnav\xps\C:\Xilinx\13.2\ISE_DS\EDK\hw\XilinxProcessorIPLib\pcores\plbv46_slave_burst_v1_01_a\doc\plbv46_slave_burst.pdf

interrupt_control_v2_01_a
	C:\Users\mjlyons\workspace\vSPI\projnav\xps\C:\Xilinx\13.2\ISE_DS\EDK\hw\XilinxProcessorIPLib\pcores\interrupt_control_v2_01_a\doc\interrupt_control.pdf

