----------------------------------------------------------------------------------
-- Engineer: Joao Carlos Nunes Bittencourt
----------------------------------------------------------------------------------
-- Create Date:    13:18:18 03/06/2012 
----------------------------------------------------------------------------------
-- Design Name:    4x1 Multiplexer
-- Module Name:    mux4x1 - behavioral 
----------------------------------------------------------------------------------
-- Project Name:   16-bit uRISC Processor
----------------------------------------------------------------------------------
-- Revision: 
-- 	1.0 - File Created
-- 	2.0 - Project refactoring
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity mux4x1 is
	generic ( 
		WIDTH : integer := 16 );
    port ( 
    	sink_a   : in std_logic_vector (WIDTH-1 downto 0);
        sink_b   : in std_logic_vector (WIDTH-1 downto 0);
        sink_c   : in std_logic_vector (WIDTH-1 downto 0);
        sink_d   : in std_logic_vector (WIDTH-1 downto 0);
        sink_sel : in std_logic_vector (1 downto 0);
        src_data : out std_logic_vector (WIDTH-1 downto 0) );
end mux4x1;

architecture Multiplex of mux4x1 is
begin
	process(sink_sel, sink_a, sink_b, sink_c)
	begin
		case sink_sel is
			when "00" => src_data <= sink_a;
			when "01" => src_data <= sink_b;
			when "10" => src_data <= sink_c;
			when "11" => src_data <= sink_d;
			when others => src_data <= (others => '0');
		end case;			
	end process;

end Multiplex;

