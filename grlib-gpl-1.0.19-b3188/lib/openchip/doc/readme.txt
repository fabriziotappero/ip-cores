OpenChip IP-Cores for GRLIB


implemented in this release:

APBGPIO
APBSUI

both tested on Memec S3-1500MB board.


Generic note about the IP Cores:
All REV 0 IPcores implement only minimal "software assisted"
functionality, so they are basically just like specialized
IO ports that connect to the extenal peripherals.

Next REVision will include dedicated hardware, but will be
backwards compatible and continue supporting the "software"
mode where the software has direct access to the peripherals.



APBGPIO
=======
Simple 32bit General Purpose Input Output port

address map (REV 0)

base+0 write : data output
base+4 write : tristate register

base+0 read  : data input (external pins readback)


tristate buffer should be instantiated in toplevel, 
if no tristate signals are used the GPIO can be used
as two 32 bit output and one 32 bit input port

example use in C:

int *gpio = (int *) 0x80000400; // Set base address!
int temp;

  gpio[0] = 0x12345678; // Write to DATA
  gpio[1] = 0xFFFFFFFF; // Write to Direction
  temp = gpio[0];       // Read input data



APBSUI
======
Simple User Interface

combines in one peripheral
* Switches, use for DIP switches)
* Buttons, use for Push Buttons
* LED's, use for single LED's
* 7 Segment LED', connect to Segment LED's
* Buzzer, connect to Piezo or Speaker
* Character LCD, connect to typical Character mode LCD


address map (REV 0)
base+0 write : single LED's
base+1 write : 7 Segment LED's (4 digits, non multiplexed)
base+2 write : LCD
base+3 write : d0 - buzzer


base+4 read  : Switches
base+5 read  : Buttons


example use in vhdl top:
------------------------------------------------------------
  sui0 : apbsui
  generic map (
	pindex => 4, 
	paddr => 4, 
	pirq => 5,
	ledact => 0,
	led7act => 0
	)
  port map (
	rstn, 
	clkm, 
	apbi, 
	apbo(4), 
	suii, 
	suio
  );

  suii.switch_in(7 downto 0) <= switch(7 downto 0); 
  suii.button_in(0) <= push1; 

  led(3 downto 0) <= suio.led_out(3 downto 0);

  led1_a  <= suio.led_a_out(0);
  led1_b  <= suio.led_b_out(0);
  led1_c  <= suio.led_c_out(0);
  led1_d  <= suio.led_d_out(0);
  led1_e  <= suio.led_e_out(0);
  led1_f  <= suio.led_f_out(0);
  led1_g  <= suio.led_g_out(0);
  led1_dp <= suio.led_dp_out(0);

  led2_a  <= suio.led_a_out(1);
  led2_b  <= suio.led_b_out(1);
  led2_c  <= suio.led_c_out(1);
  led2_d  <= suio.led_d_out(1);
  led2_e  <= suio.led_e_out(1);
  led2_f  <= suio.led_f_out(1);
  led2_g  <= suio.led_g_out(1);
  led2_dp <= suio.led_dp_out(1);

  lcd_data <= suio.lcd_out;
  lcd_en   <= suio.lcd_en(0);
  lcd_rs   <= suio.lcd_rs;
  piezo    <= suio.buzzer;

------------------------------------------------------------

