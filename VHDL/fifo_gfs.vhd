
-----------------------------------------------------------------------------
-- NoCem -- Network on Chip Emulation Tool for System on Chip Research 
-- and Implementations
-- 
-- Copyright (C) 2006  Graham Schelle, Dirk Grunwald
-- 
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
-- 02110-1301, USA.
-- 
-- The authors can be contacted by email: <schelleg,grunwald>@cs.colorado.edu 
-- 
-- or by mail: Campus Box 430, Department of Computer Science,
-- University of Colorado at Boulder, Boulder, Colorado 80309
-------------------------------------------------------------------------------- 


-- 
-- Filename: fifo_gfs.vhd
-- 
-- Description: an all vhdl version of a FIFO
-- 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fifo_gfs is
	generic (
		WIDTH : integer := 16;  	-- FIFO word width
		ADD_WIDTH : integer := 3	-- Address Width
		); 

	PORT(
		Data_in : IN std_logic_vector(WIDTH-1 downto 0);
		clk : IN std_logic;
		Reset : IN std_logic;
		RE : IN std_logic;
		WE : IN std_logic;          
		Data_out : OUT std_logic_vector(WIDTH-1 downto 0);
		Full : OUT std_logic;
		Half_full : OUT std_logic;
		empty : OUT std_logic
		);	
end fifo_gfs;



architecture Behavioral of fifo_gfs is

	signal MAX_ADDR:  std_logic_vector(ADD_WIDTH   downto 0);
	signal MIN_ADDR:  std_logic_vector(ADD_WIDTH   downto 0);


    signal R_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);  -- Read Address
    signal W_ADD   : std_logic_vector(ADD_WIDTH - 1 downto 0);
	 signal D_ADD   : std_logic_vector(ADD_WIDTH     downto 0);	 -- notice size of ADD_WIDTH+1


	 signal rst_n : std_logic;

	 signal empty_datain,empty_dataout,empty_memcore : std_logic;
	 signal full_datain,full_dataout,full_memcore    : std_logic;

	 signal dout_dataout,dout_datain,dout_memcore : std_logic_vector(WIDTH-1 downto 0);
	 signal din_dataout,din_datain,din_memcore : std_logic_vector(WIDTH-1 downto 0);
	 signal we_dataout,we_datain,we_memcore : std_logic;
	 signal re_dataout,re_datain,re_memcore : std_logic;

	component dpmem
	    generic (ADD_WIDTH : integer;
	   			 WIDTH : integer);

    	port (clk : in std_logic;
	    reset : in std_logic;
	  	w_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    r_add : in std_logic_vector(ADD_WIDTH -1 downto 0 );
	    data_in : in std_logic_vector(WIDTH - 1 downto 0);
	    data_out : out std_logic_vector(WIDTH - 1 downto 0 );
	    WR  : in std_logic;
	    RE  : in std_logic);
	end component;

	COMPONENT fifo_reg
	generic (
		WIDTH : integer
	);
	PORT(
		clk : IN std_logic;
		din : IN std_logic_vector(WIDTH-1 downto 0);
		rd_en : IN std_logic;
		rst : IN std_logic;
		wr_en : IN std_logic;          
		dout : OUT std_logic_vector(WIDTH-1 downto 0);
		empty : OUT std_logic;
		full : OUT std_logic
		);
	END COMPONENT;


begin


	constant_sigs : process (empty_datain,empty_memcore, empty_dataout, full_datain, full_memcore, full_dataout, Reset)
	begin
		empty <=  empty_datain and empty_memcore and empty_dataout;
		full  <=  full_datain  and full_memcore  and full_dataout;
		Half_full <= '0';

		rst_n <= not reset;


		MAX_ADDR <= (others => '0');
		MAX_ADDR(ADD_WIDTH) <= '1';
		MIN_ADDR <= (others => '0');

	end process;


	-----------------------------------------------------------
	------------------- SIGNAL GENERATION ---------------------
	-----------------------------------------------------------

	-- dataout_fifo
	Data_out   <= dout_dataout;
	

	dataflow_gen : process (dout_memcore, dout_datain,full_dataout,WE, Data_in, full_memcore, full_datain, RE, empty_memcore, empty_datain)
	begin

		
		din_dataout <= (others => '0');
		we_dataout	<= '0';
		re_dataout	<= '0';

		din_memcore <= (others => '0');
		we_memcore	<= '0';
		re_memcore	<= '0';

		din_datain  <= (others => '0');
		we_datain	<= '0';
		re_datain	<= '0';



		-- where to do writing of new data
		if full_dataout='0' and WE='1' and RE='0' then
			din_dataout	<= Data_in;
			we_dataout  <= WE;
		elsif	full_memcore='0' and WE='1' and RE='0' then
			din_memcore	<= Data_in;
			we_memcore  <= WE;
		elsif full_datain='0' and WE='1' and RE='0' then
			din_datain	<= Data_in;
			we_datain  <= WE;			
		end if;

		-- handling RE's
		if RE='1' and WE='0' then
			re_dataout <= RE;
			
			if empty_memcore='0' then
				re_memcore <= '1';
				we_dataout <= '1';
				din_dataout <= dout_memcore;
			end if;
			
			if empty_datain='0' then
				re_datain  <= '1';
				we_memcore <= '1';
				din_memcore <= dout_datain;						
			end if;		
		end if;


		if RE='1' and WE='1' then
		
			if full_dataout='1' and empty_memcore='1' then
				re_dataout <= '1';	
				we_dataout <= '1';
				din_dataout <= data_in;
			elsif full_dataout='1' and empty_memcore='0' and empty_datain='1' then
				re_dataout <= '1';
				re_memcore <= '1';	
				we_dataout <= '1';
				we_memcore <= '1';				 
				din_dataout <= dout_memcore;
			   din_memcore <= data_in;
			elsif full_dataout='1' and full_memcore='1' and full_datain='1' then
				re_dataout <= '1';
				re_memcore <= '1';	
				we_dataout <= '1';
				we_memcore <= '1';
				re_datain  <= '1';
				we_datain  <= '1';
				din_dataout  <= dout_memcore;
			   din_memcore <= dout_datain;
				din_datain   <= data_in;								 
			end if;
		end if;
		


	end process;




	-- handling memcore signalling
	memcore_sig_gen_clkd : process (clk,reset)
	begin
		
		if reset='1' then
			W_ADD <= (others =>'0');
			R_ADD <= (others =>'0');
			D_ADD <= (others =>'0');
		elsif clk='1' and clk'event then

			if we_memcore = '1' then
				W_ADD <= W_ADD + 1;
			end if;

			if re_memcore = '1' then 
			   R_ADD <= R_ADD + 1;
		   end if;

			if we_memcore='1' and re_memcore='1' then
				null;
			elsif we_memcore='1' then 
				D_ADD <= D_ADD + 1;
			elsif re_memcore='1' then 
				D_ADD <= D_ADD - 1;
			else
				null;			
			end if;

		end if;

	end process;


	-- handling memcore signalling
	memcore_sig_gen_uclkd : process (D_ADD, MIN_ADDR, MAX_ADDR)
	begin
		
			if D_ADD = MIN_ADDR then 										
				empty_memcore <= '1';
			else
				empty_memcore <= '0';	
			end if;
			
			if D_ADD = MAX_ADDR then 										
				full_memcore <= '1';
			else
				full_memcore <= '0';	
			end if;				

	end process;


	-----------------------------------------------------------
	------------------- THE ACTUAL FIFOS ----------------------
	-----------------------------------------------------------

	datain_reg : fifo_reg 
	Generic map(
		WIDTH => WIDTH
	)	
	PORT MAP(
		clk => clk,
		din => din_datain,
		rd_en => re_datain,
		rst => Reset,
		wr_en => we_datain,
		dout => dout_datain,
		empty => empty_datain,
		full => full_datain
	);


	memcore: dpmem 
	generic map (
				ADD_WIDTH =>ADD_WIDTH,
				WIDTH => WIDTH
				)
	port map (clk => clk,
			 reset => rst_n,
			 w_add => W_ADD,
			 r_add => R_ADD,
			 Data_in => din_memcore,
			 data_out => dout_memcore,
			 wr => we_memcore,
			 re => re_memcore);


	dataout_reg : fifo_reg 
	Generic map(
		WIDTH => WIDTH
	)	
	PORT MAP(
		clk => clk,
		din => din_dataout,
		rd_en => re_dataout,
		rst => reset,
		wr_en => we_dataout,
		dout => dout_dataout,
		empty => empty_dataout,
		full => full_dataout 
	);




end Behavioral;
