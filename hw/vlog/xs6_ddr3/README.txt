*** Steps to create the Spartan-6 DDR3 memory interface for the SP605 development board.
These instructions are based on using Xilinx ISE 14.5

Run coregen
Open the project hw/vlog/xs6_ddr3/coregen_sp605.cgp
Under Project IP, select the Core Name "MIG Virtex-6 and Spartan-6",
right mouse on it and select Regenerate 9Under Original Project Settings)
Answer Yes to 'Do you wish to continue?' twice. The core generation process then runs in a few seconds.
Exit coregen.


This is the controller configuration, for reference.
- Component Name: ddr3
- Bank 3 Memory Type DDR3 SDRAM
- Frequency: 400MHz
- Memory Part: MT41J64M16XX-187E
- Configuration Selection: One 128-bit bi-directional port
- Memory Address Mapping Selection: Row, Bank, Column


Once the controller is generated copy all the Verilog files from the 
hw/vlog/xs6_ddr3/user_design/rtl and hw/vlog/xs6_ddr3/user_design/rtl/mcb_controller 
directories to $AMBER_BASE/hw/vlog/xs6_ddr3. Then make the following modifications

1. ddr3
line 167 change
   localparam C3_CLKFBOUT_MULT        = 2;
to
   localparam C3_CLKFBOUT_MULT        = 4;
   
    
2. infrastructure.v
Comment out line 126, (* KEEP = "TRUE" *) wire sys_clk_ibufg;
Comment out the IBUFG instance u_ibufg_sys_clk on lines 156 to 160. 
Change the CLKIN1 signal on line 202 from sys_clk_ibufg to sys_clk.

There is already an IBUFGDS on that signal in clocks_resets.v so the 
one in infrastructure.v is not needed.


In order to use Impact on CentOS 6, you need to install a USB driver.
sudo yum install libusb-devel
Then download and make the usb driver from http://rmdir.de/~michael/xilinx/
Once its successfully compiled run setup_pcusb to add the device IDs to the Xilinx installation.

You also need to install the fxload package
sudo rpm -i fxload-2008_10_13-3.el6.i686.rpm
And reboot after installing it.

Then power on the SP605 board and connect its USB-JTAG port to your PC.
Then run impact as follows
export LD_PRELOAD=/your-path/libusb-driver.so
impact
Impact should now be able to auto-detect the FPFA card. Right click on the FPGA and select the bitfile to load into it.


