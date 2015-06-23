----------
--! @file
--! @brief The top-level test-bench.
----------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all; 	-- conv_integer, conv_signed
library work;
use work.tb_pack.all;
use work.fir_pkg.all;
library std;
use std.textio.all;		-- write, writeline

entity fir_filter_stage_tb is
end fir_filter_stage_tb;

architecture tb of fir_filter_stage_tb is

constant clockperiod : time := 10 ns; --! Clock period

component fir_filter_stage_TF
  port (fir_clk, fir_clr : in  std_logic;
        fir_in           : in  std_logic_vector(0 downto 0);
        fir_out          : out std_logic_vector(14 downto 0));
end component;
			
signal fir_clk, fir_clr			: std_logic;
signal fir_in 				: std_logic_vector(0 downto 0);
signal fir_out				: std_logic_vector(14 downto 0);
signal read_flag			: std_ulogic;
signal write_finished, read_finished	: std_ulogic := '0';
-- Internal deibugging signals
signal multi_add   : std_logic_vector((order-1)*width_out-1 downto 0);
signal add_delay   : std_logic_vector((order-2)*width_out-1 downto 0);
signal delay_add   : std_logic_vector((order-1)*width_out-1 downto 0);
signal multi_delay : std_logic_vector(width_out-1 downto 0);

begin

process 
  begin
    fir_in <= (others => '0');
 wait until read_flag = '1';	     
    	ReadData ( "./testbench/data.txt", fir_in, fir_clk, read_finished);	--! Input file for stimuli bit-stream    	      
end process;

multi_add 	<= g_multi_add;
add_delay	<= g_add_delay;	
delay_add 	<= g_delay_add;
multi_delay 	<= g_multi_delay;

ExportOutput: process
		file wr_file : text open write_mode is "./fir_filter_ouput.txt"; --! Output file 
		variable export_vector : integer; 
		variable export_line : line;
	begin
	wait until rising_edge(fir_clk);
		export_vector := conv_integer(conv_signed(unsigned(fir_out),fir_out'length));
		write(export_line, export_vector);
		writeline(wr_file, export_line);
	end process;
			
DUT : fir_filter_stage_TF
  port map(
  		fir_clk => fir_clk, 
  		fir_clr => fir_clr,
        	fir_in  => fir_in,
        	fir_out => fir_out 
        );
			
process
  begin
  	fir_clr <= '1';	read_flag <= '0';
		wait for 43 ns;
				
	fir_clr	<= '0'; read_flag <= '1';
		wait for 43 ns;
		
	fir_clr	<= '0'; read_flag <= '1';
		wait for 500 ns;
  end process;
			
process 
  begin
   wait for (clockperiod/2);
	fir_clk <= '1';
   wait for (clockperiod/2);
	fir_clk <= '0';
  end process;

end tb;
