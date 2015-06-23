library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


package dongle_arch is


--VCI bus types
type vci_slave_in is record
    lpc_addr   : std_logic_vector(15 downto 0); --shared address
    lpc_wr     : std_logic;         --shared write not read
    lpc_data_o : std_logic_vector(7 downto 0);  
    lpc_val    : std_logic;
end record;

type vci_slave_out is record
    lpc_data_i : std_logic_vector(7 downto 0);
    lpc_ack    : std_logic;
    lpc_irq    : std_logic;
end record;

	procedure vci_slave_reset(signal vci : out vci_slave_out);

	
end package dongle_arch;




package body dongle_arch is	

	procedure vci_slave_reset(
		signal vci : out vci_slave_out) is
		variable v : vci_slave_out;
	begin
		v.lpc_ack:='0';
		v.lpc_irq:='0';
		v.lpc_data_i:=x"00";
		vci<=v;
	end procedure vci_slave_reset;
	
	
end package body dongle_arch;
