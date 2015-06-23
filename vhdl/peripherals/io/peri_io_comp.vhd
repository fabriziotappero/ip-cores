library IEEE;
use IEEE.std_logic_1164.all;
use work.amba.all;
use work.peri_serial_comp.all;

package peri_io_comp is

-- todo: fix this (core part)
type io_in_type is record
  piol             : std_logic_vector(15 downto 0); -- I/O port inputs
  pci_arb_req_n    : std_logic_vector(0 to 3);
end record;

type pio_out_type is record
  irq              : std_logic_vector(3 downto 0);
  piol             : std_logic_vector(31 downto 0);
  piodir           : std_logic_vector(17 downto 0);
  io8lsb           : std_logic_vector(7 downto 0);
  rxd              : std_logic_vector(1 downto 0);
  ctsn   	   : std_logic_vector(1 downto 0);
  wrio   	   : std_logic;
end record;

component ioport
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    uart1o : in  uart_out_type;
    uart2o : in  uart_out_type;
    mctrlo_pioh : in  std_logic_vector(15 downto 0);
    ioi    : in  io_in_type;
    pioo   : out pio_out_type
  );
end component;
  
end peri_io_comp;
