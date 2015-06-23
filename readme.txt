Information to the Project HD44780 Driver
-----------------------------------------
This project contains VHDL descriptions for driving a standard HD44780
LCD Driver with a minimum of inputs. Please read on.

Information
-----------
Author:    J.E.J. op den Brouw <J.E.J.opdenBrouw@hhs.nl>
Company:   De Haagse Hogeschool <www.hhs.nl>
Rationale: This driver is written to facilitate my students
Software:  Quartus II v11.1 / ModelSim v10.0.c / Windows 7
Hardware:  Terasic DE0 board with optional display (Cyclone III)
Status:    Alpha, tested by my students.

Files
-----
lcd_driver_hd44780_module.vhd       - The Driver
tb_lcd_driver_hd44780_module.vhd    - Simple testbench
tb_lcd_driver_hd44780_module.do     - ModelSim command file
example_driver.vhd                  - Example on how to use the driver
tb_example_driver.vhd               - Simple testbench
tb_example_driver.do                - ModelSim command file
lcd_driver_hd44780.sdc              - Synopsys Constraints File (clock info only)
readme.txt                          - This file

Overall Description
----------------------------------------------------------------------------------------
Currently, this driver uses the 8-bit databus mode. This is not a big problem
for most FPGA's because of the numerous pins.
Please note that there are a lot of almost-the-same displays available, so
it's not guaranteed to work with all displays available. Also, timing may differ.

This code is tested on a Terasic DE0-board with an optional LCD display.
See the weblinks:
http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=56&No=364
http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=78&No=396
for more info. The display used has only two lines.

The VHDL descriptions can both be simulated and synthesized.

This driver has a User Side and a LCD Side. The user is to interface at the User Side
and has a number of "routines" at her disposal. The User Side implements the following
inputs/routines in order of priority:

Command inputs:
    init:   a logic 1 initializes the display
    cls:    a logic 1 clears the display (and goes to home)
    home:   a logic 1 sets the cursor to row 0, column 0
    goto10: a logic 1 sets the cursor to row 1, column 0
    goto20: a logic 1 sets the cursor to row 2, column 0
    goto30: a logic 1 sets the cursor to row 3, column 0
    wr:     a logic 1 writes a character to the display

Data inputs:

    data:   an 8-bit data to be written to the display

The user has one observable output:

    busy:   a logic 1 indicates that the driver is currently
            busy driving the display, a logic 0 indicates that
            the driver waits for the next command.

The user can supply the next generics, which are processed at
instantiation of the module:

	 freq:   the clock frequency at which the hardware has to run.
            this frequency is mandatory because of internal delays
            calculated, defaults to 50 MHz.
    areset_pol:
            the polarity of the reset signal, defaults to High (1)
    time_init1:
            the time to wait after Vcc > 4.5 V 
    time_init2:
            the time to wait after first "contact"
    time_init3:
            the time to wait after the second contact
    time_tas:
            the RW and RS signal setup time with respect to the positive
            edge of the E pulse
    time_cycle_e:
            the complete cycle time
    time_pweh:
            the E pulse width high time
    time_no_bf:
            time to wait before command completion if no Busy Flag reading is done,
            some designs connect RW to logic 0, so reading from the LCD is not
            possible, saves a pin.
    cursor_on:
            true to set the cursor on at the display, false for no cursor
    blink_on:
            true to let the cursor blink, false for no blink (just a underscore)
    use_bf: true if Busy Flag reading is to be used, false for no BF reading

Note: it's not possible to write command codes to the display.

A note about timing:
    Some of the timing parameters are very small, e.g. the RW and RS setup time with
    respect to rising edge of E. If the clock frequency is too low, the delay calculated
    will be zero, which result in at least a delay with the period time of the clock.

A note about implementing:
    If the driver doesn't work or you get clobbered strings, please use non-BF
    reading at first. Next, increase the Cycle E time and PWeh time.
