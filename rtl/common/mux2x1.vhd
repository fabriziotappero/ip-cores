----------------------------------------------------------------------------------
-- Engineer: Joao Carlos Nunes Bittencourt
----------------------------------------------------------------------------------
-- Create Date:    13:18:18 03/06/2012 
----------------------------------------------------------------------------------
-- Design Name:    2x1 Multiplexer
-- Module Name:    mux2x1 - behavioral 
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

entity mux2x1 is
	generic ( WIDTH : integer := 16 );
    port ( sink_a   : in std_logic_vector (WIDTH-1 downto 0);
           sink_b   : in std_logic_vector (WIDTH-1 downto 0);
           sink_sel : in std_logic_vector (0 downto 0); -- FIXME
           src_data : out std_logic_vector (WIDTH-1 downto 0)
    );
end mux2x1;

architecture Primitive of mux2x1 is
begin
	process(sink_sel, sink_a, sink_b)
	begin
		case sink_sel is
			when "0" => src_data <= sink_a;
			when "1" => src_data <= sink_b;
			when others => src_data <= (others => '0');
		end case;
			
	end process;
end Primitive;

