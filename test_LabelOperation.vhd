--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:39:28 05/13/2008
-- Design Name:   mean3x3Operation
-- Module Name:   C:/Documents and Settings/bentho/Mina dokument/VHDL/Pegasus/studentVideo/test_mean3x3Operation.vhd
-- Project Name:  studentVideo
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mean3x3Operation
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY test_labelOperation IS
END test_labelOperation;

ARCHITECTURE behavior OF test_labelOperation IS 


	SIGNAL clk :  std_logic := '0';
	SIGNAL fsync_in :  std_logic := '0';
	SIGNAL rsync_in :  std_logic := '0';
	SIGNAL pdata_in :  std_logic_vector(7 downto 0) := (others=>'0');
	SIGNAL outputCodes : std_logic_vector(9 downto 0);
	SIGNAL componentCnt : std_logic_vector(9 downto 0);
	SIGNAL fsync_out :  std_logic;
	SIGNAL rsync_out :  std_logic;
	SIGNAL pdata_out :  std_logic_vector(7 downto 0);
	SIGNAL pdata_inter :  std_logic_vector(7 downto 0);
	SIGNAL reset : std_logic;
	SIGNAL fsync_inter, rsync_inter, bindata : std_logic;
	
	SIGNAL features : std_logic_vector(34 downto 0);
	SIGNAL featureDataStrobe, commReady : std_logic;
	SIGNAL x_cog, y_cog : std_logic_vector(16 downto 0);
	
	SIGNAL RX_DATA, RTS_IN, DSR_OUT, TX_DATA, CTS_OUT : std_logic := '0';

BEGIN
		
	-- Instantiate the Unit Under Test (UUT)
	uut: entity work.label8Operation
	port map(
				pclk => clk,
				reset => reset,
				fsync_in => fsync_inter, 
				rsync_in	=> rsync_inter,
				data_in => pdata_inter,
				pbin_in => bindata,
				fsync_out => fsync_out,
				rsync_out => rsync_out,
				pdata_out => outputCodes,
				featureDataStrobe => featureDataStrobe,
				acknowledge => commReady,
				cntObjects => componentCnt,
				x_cog_out => x_cog,
				y_cog_out => y_cog
	);
	
	features <= '0' & x_cog & y_cog; -- x and y coordinates are merged into one single vector
												-- for transmission over the serial link
	
	transmit: entity work.SendFeatures 
	PORT MAP (
          features => features,
			 fsync => fsync_out,
          wstrobe => featureDataStrobe,
			 ready => commReady,
          clk => clk,
          reset => reset,
          RX_DATA => RX_DATA,
          RTS_IN => RTS_IN,
          DSR_OUT => DSR_OUT,
          TX_DATA => TX_DATA,
          CTS_OUT => CTS_OUT
        );
		  
		  RX_DATA <= TX_DATA;


 
	fsync_inter <= fsync_in;
	rsync_inter <= rsync_in;
	pdata_inter <= "11111111" - pdata_in;
	bindata <= '1' when pdata_in < 110 else '0';
	
-----------------------------------------------------------------
		
	img_read : entity work.img_testbench
	port map (
      pclk_i    => clk,
	 	reset_i	 => reset,
      fsync_i   => fsync_out,
      rsync_i   => rsync_out,		
      pdata_i   => pdata_out,	  
		cols_o	 => open,
		rows_o	 => open,
		col_o		 => open,
		row_o		 => open,
      fsync_o   => fsync_in,
      rsync_o   => rsync_in,
		pdata_o   => pdata_in);

	clock_generate: process (clk)
		constant T_pw : time := 37 ns;      -- Clock frequency is 27/2 MHz
	begin  -- process img
		if clk = '0' then
			clk <= '1' after T_pw, '0' after 2*T_pw;
		end if;
	end process clock_generate;
	
	pdata_out <= outputCodes(7 downto 0);
--	pdata_out <= bindata&bindata&bindata&bindata&bindata&bindata&bindata&bindata;
	reset <= '1', '0' after 60 ns;

END;