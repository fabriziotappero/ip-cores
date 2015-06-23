library IEEE;
use IEEE.std_logic_1164.all;
use work.amba.all;

package peri_serial_comp is

type uart_in_type is record
  rxd   	: std_logic;
  ctsn   	: std_logic;
  scaler	: std_logic_vector(7 downto 0);
end record;

type uart_out_type is record
  rxen    	: std_logic;
  txen    	: std_logic;
  flow   	: std_logic;
  irq   	: std_logic;
  rtsn   	: std_logic;
  txd   	: std_logic;
end record;

component uart
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    uarti  : in  uart_in_type;
    uarto  : out uart_out_type
  );
end component; 

end peri_serial_comp;
