
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:17:15 10/10/2008
-- Design Name:   receiver
-- Module Name:   C:/Xilinx92i/projects/citac/tb_rx.vhd
-- Project Name:  citac
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: receiver
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
USE ieee.std_logic_arith.all;
USE ieee.numeric_std.ALL;
use ieee.math_real.all; -- for UNIFORM, TRUNC

ENTITY tb_rx_vhd IS
END tb_rx_vhd;

ARCHITECTURE behavior OF tb_rx_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT aes3rx
	generic (
		reg_width : integer := 5
	);
   port (
      clk   : in  std_logic; -- master clock
      aes3  : in  std_logic; -- input 
      reset : in  std_logic; -- synchronous reset
      
      sdata : out std_logic; -- output serial data
      sclk  : out std_logic; -- output serial data clock
      bsync : out std_logic; -- block start (high when Z subframe is being transmitted)
      lrck  : out std_logic; -- frame sync (high for channel A, low for B)
      active: out std_logic  -- receiver has valid data on its outputs
   );
	end component;
	
	--Inputs
	SIGNAL CLK_50MHZ :  std_logic := '0';
	SIGNAL RX :  std_logic := '0';
   signal TX : std_logic := '0';

	--Outputs
--	SIGNAL active : std_logic;
--	SIGNAL sdata :  std_logic;
--	SIGNAL sclk :  std_logic;
--	SIGNAL fsync :  std_logic;
--	signal bsync : std_logic;
	
   constant PERIOD : time := 20ns;
   constant DUTY_CYCLE : real := 0.5;
   constant OFFSET : time := 100 ns;
	type INT_ARRAY is array (integer range <>) of integer;
	shared variable vals : INT_ARRAY(0 to 191);
	
	shared variable S : time :=150 ns;
	shared variable M : time :=310 ns;
	shared variable L : time :=485 ns;
	
	procedure vector2aes(vector : in std_logic_vector (23 downto 0); signal aes : inout  std_logic) is
	begin
		for i in 0 to 23 loop
			if vector(i) = '0' then
				aes <= not aes;
				wait for M;
			elsif vector(i) = '1' then
				aes <= not aes;
				wait for S;
				aes <= not aes;
				wait for S;
			end if;
		end loop;
	end procedure;
	
	procedure generate_block(pcm_data : in INT_ARRAY(0 to 191); signal aes : inout  std_logic; signal curr_val : out std_logic_vector(23 downto 0)) is
	begin
		-- Z preamble
		aes <= not aes;	
		wait for L;					
		aes <= not aes;	
		wait for S;
		aes <= not aes;	
		wait for S;
		aes <= not aes;	
		wait for L;

		vector2aes(conv_std_logic_vector(pcm_data(0), 24), aes);	
		curr_val <= conv_std_logic_vector(pcm_data(0), 24);

		aes <= not aes; -- 1.5
		wait for M;
		aes <= not aes; -- 1.5
		wait for M;
		aes <= not aes; -- 1.5
		wait for M;
		aes <= not aes; -- 1.5
		wait for M;				
				
		
		for i in 1 to 191 loop
			if i mod 2 /= 0 then --B subframe
				--Y preamble
				aes <= not aes; -- 1.5				
				wait for L;
				aes <= not aes; -- 1.5
				wait for M;
				aes <= not aes; -- 3
				wait for S;
				aes <= not aes; -- 3.5
				wait for M;		
				
			else --A subframe
				--X preamble
				aes <= not aes; -- 1.5				
				wait for L;
				aes <= not aes; 
				wait for L;
				aes <= not aes; 				
				wait for S;
				aes <= not aes; 
				wait for S;
				
			end if;
			curr_val <= conv_std_logic_vector(pcm_data(i), 24);

			vector2aes(conv_std_logic_vector(pcm_data(i), 24), aes);

			aes <= not aes; -- 1.5
			wait for M;
			aes <= not aes; -- 1.5
			wait for M;
			aes <= not aes; -- 1.5
			wait for M;
			aes <= not aes; -- 1.5
			wait for M;				
						
		end loop;
		
	end procedure;
	
	shared variable seed1 : positive;
	shared variable seed2 : positive;
	shared variable rand : real;
	signal curr_val : std_logic_vector(23 downto 0);

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: aes3rx PORT MAP(
		clk  => CLK_50MHZ,
		aes3 => RX,
		reset => '0'
		--bsync => bsync
		--bsync => bsync
	);	
	
	PROCESS    -- clock process for CLK_50MHZ
	BEGIN
		WAIT for OFFSET;
		CLOCK_LOOP : LOOP
			 CLK_50MHZ <= '0';
			 WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
			 CLK_50MHZ <= '1';
			 WAIT FOR (PERIOD * DUTY_CYCLE);
		END LOOP CLOCK_LOOP;
	END PROCESS;

	tb : PROCESS
	BEGIN
		
		wait for 100 ns;
	
		for i in 0 to 191 loop
			if i = 0 then
				vals(i) := 8388609;
			else 
				vals(i) := 8388609;
			end if;
		end loop;
		
		generate_block(vals, RX, curr_val);
		
		for i in 0 to 191 loop
			if i = 0 then
				vals(i) := 0;
			else 
				vals(i) := vals(i-1) + 10000;
			end if;
		end loop;
		
		generate_block(vals, RX, curr_val);
		
		
		-- Wait 100 ns for global reset to finish
		wait for 100 us;
      
      S := 81.2 ns;
      M := 162.6 ns;
      L := 244 ns;
      
      wait for 100 ns;
	
		for i in 0 to 191 loop
			if i = 0 then
				vals(i) := 0;
			else 
				vals(i) := 1;
			end if;
		end loop;
		
		generate_block(vals, RX, curr_val);
		
		for i in 0 to 191 loop
			if i = 0 then
				vals(i) := 0;
			else 
				vals(i) := vals(i-1) + 10000;
			end if;
		end loop;
		
		wait; -- will wait forever
	END PROCESS;

END;