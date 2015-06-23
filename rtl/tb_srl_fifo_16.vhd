----------------------------------------------------------------------------
----												                    ----
----												                    ----
---- This file is part of the srl_fifo project						    ----
---- http://www.opencores.org/cores/srl_fifo					        ----
----												                    ----
---- Description										                ----
---- Implementation of srl_fifo IP core according to                    ----
---- srl_fifo IP core specification document.			                ----
----												                    ----
---- To Do:											                    ----
----	NA											                    ----
----												                    ----
---- Author(s):										                    ----
----   Andrew Mulcock, amulcock@opencores.org			                ----
----												                    ----
----------------------------------------------------------------------------
----												                    ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG				        ----
----												                    ----
---- This source file may be used and distributed without				----
---- restriction provided that this copyright statement is not			----
---- removed from the file and that any derivative work contains		----
---- the original copyright notice and the associated disclaimer.		----
----												                    ----
---- This source file is free software; you can redistribute it			----
---- and/or modify it under the terms of the GNU Lesser General		    ----
---- Public License as published by the Free Software Foundation;		----
---- either version 2.1 of the License, or (at your option) any			----
---- later version.										                ----
----												                    ----
---- This source is distributed in the hope that it will be				----
---- useful, but WITHOUT ANY WARRANTY; without even the implied	        ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR	        ----
---- PURPOSE. See the GNU Lesser General Public License for more		----
---- details.											                ----
----												                    ----
---- You should have received a copy of the GNU Lesser General		    ----
---- Public License along with this source; if not, download it			----
---- from http://www.opencores.org/lgpl.shtml					        ----
----												                    ----
----------------------------------------------------------------------------
--												                        ----
-- CVS Revision History									                ----
--												                        ----
-- $Log: not supported by cvs2svn $											                    ----
--												                        ----
--
-- quick description
--
--  Based upon the using a shift register as a fifo which has been 
--   around for years ( decades ), but really came of use to VHDL 
--   when the Xilinx FPGA's started having SRL's. 
--
--  In my view, the definitive article on shift register logic fifo's 
--   comes from Mr Chapman at Xilinx, in the form of his BBFIFO
--    tecXeclusive article, which as at early 2008, Xilinx have
--     removed.
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY tb_srl_fifo_16_vhd IS
END tb_srl_fifo_16_vhd;

ARCHITECTURE behavior OF tb_srl_fifo_16_vhd IS 

constant width_tb : integer := 8;

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT srl_fifo_16
    GENERIC ( width : integer := width_tb ); -- set to how wide fifo is to be
	PORT(
		data_in : IN std_logic_vector(width_tb - 1 downto 0);
		reset : IN std_logic;
		write : IN std_logic;
		read : IN std_logic;
		clk : IN std_logic;          
		data_out : OUT std_logic_vector(width_tb - 1  downto 0);
		full : OUT std_logic;
		half_full : OUT std_logic;
		data_present : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL reset :  std_logic := '0';
	SIGNAL write :  std_logic := '0';
	SIGNAL read :  std_logic := '0';
	SIGNAL clk :  std_logic := '0';
	SIGNAL data_in :  std_logic_vector(width_tb - 1 downto 0) := (others=>'0');

	--Outputs
	SIGNAL data_out :  std_logic_vector(width_tb -1  downto 0);
	SIGNAL full :  std_logic;
	SIGNAL half_full :  std_logic;
	SIGNAL data_present :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: srl_fifo_16
        GENERIC MAP (
        width => width_tb
        )
        PORT MAP(
		data_in => data_in,
		data_out => data_out,
		reset => reset,
		write => write,
		read => read,
		full => full,
		half_full => half_full,
		data_present => data_present,
		clk => clk
	);

	tb : PROCESS
	BEGIN


        reset <= '1';
		-- Wait 100 ns for global reset to finish
		wait for 100 ns;

        wait until clk = '0';
        reset <= '0';
    
		-- Place stimulus here

    wait until clk = '0';  -- 0
    data_in <= X"AA";
    write <= '1';
    
    wait until clk = '0';   -- 1
    data_in <= X"55";

    wait until clk = '0';   -- 2
    data_in <= X"02";
    wait until clk = '0';   -- 3
    data_in <= X"03";
    wait until clk = '0';   -- 4
    data_in <= X"04";
    wait until clk = '0';   -- 5
    data_in <= X"05";
    wait until clk = '0';   -- 6
    data_in <= X"06";
    wait until clk = '0';   -- 7
    data_in <= X"07";
    wait until clk = '0';   -- 8
    data_in <= X"08";
    wait until clk = '0';   -- 9
    data_in <= X"09";
    wait until clk = '0';   -- A
    data_in <= X"A0";
    wait until clk = '0';   -- B
    data_in <= X"B0";
    wait until clk = '0';   -- C
    data_in <= X"C0";
    wait until clk = '0';   -- D
    data_in <= X"D0";
    wait until clk = '0';   -- E
    data_in <= X"E0";
    wait until clk = '0';   -- F
    data_in <= X"F0";
    wait until clk = '0';   -- no write
    data_in <= X"FF";
    
    wait until clk = '0';   -- write and read on full, reads first out
    data_in <= X"EE";
    read <= '1';

    wait until clk = '0';   -- no read or write
    data_in <= X"AB";
    read <= '0';
    write <= '0';
    

-- read untill empty

    wait until clk = '0';

    read <= '1';
    for i in 0 to 13 loop   -- read out 13 more
        wait until clk = '0';
    end loop;
    
    read <= '0';
    wait until clk = '0';   --  dont read, 

    read <= '1';
    wait until clk = '0';   -- read last - 1 out


    read <= '0';
    wait until clk = '0';   --  dont read, 

    read <= '1';
    wait until clk = '0';   -- read last out


    read <= '0';    -- stop reading

		wait; -- will wait forever
	END PROCESS;

-- clock gen process
process
begin
    wait for 1 ns;
    clk <= '0';
    wait for 1 ns;
    clk <= '1';
end process;


END;
