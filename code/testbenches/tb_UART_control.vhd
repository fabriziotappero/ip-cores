--------------------------------------------------------------------------------
-- Company: 
-- Engineer:			Predonzani Mauro (predmauro@libero.it)
--
-- Create Date:   21:44:39 31/08/2011
-- Design Name:   
-- Module Name:   tb_UART_control.vhd
-- Project Name:  UART
-- Target Device:  
-- Tool versions:  
-- Description:   create a stimulus to test ab_top.vhd
-- 
-- VHDL Test Bench: ab_top
-- 
-- Dependencies:	ad_top.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY tb_ab_top IS
END tb_ab_top;
 
ARCHITECTURE behavior OF tb_ab_top IS 
 
	-- Component Declaration for the Unit Under Test (UUT)
 
	COMPONENT ab_top
	PORT(
		clk_uart_29MHz_i   : in     std_logic;
		clk_uart_monitor_o : out    std_logic;
		uart_rst_i         : in     std_logic;
		uart_leds_o        : out    std_logic_vector(7 downto 0);
    uart_dout_o        : out    std_logic;
    uart_din_i         : in     std_logic);
	END COMPONENT;

	--Inputs
	signal sys_clk_i : std_logic := '0';
	signal uart_din_emu : std_logic := '0';
	signal uart_rst_emu : std_logic := '0';

 	--Outputs
	signal uart_dout_emu : std_logic;
	signal s_br_clk_uart_o : std_logic;
	signal uart_leds_emu : std_logic_vector (7 downto 0);
	 
	constant uart_clock_period : time := 34 ns;
	constant bit_period : time := uart_clock_period*32;

	type sample_array is array (natural range<>) of std_logic_vector (7 downto 0);

	constant test_data : sample_array :=
		(
		-- 1st data
			X"00", -- BYTE1
			X"20", -- BYTE2
			X"08", -- BYTE3
			X"40", -- BYTE4
			X"80", -- BYTE5
			X"20", -- BYTE6
		-- 2nd data	
			X"00", -- BYTE1
			X"30", -- BYTE2
			X"09", -- BYTE3
			X"41", -- BYTE4
			X"81", -- BYTE5
			X"21", -- BYTE6
		-- 3rd data
			X"00", -- BYTE1
			X"31", -- BYTE2
			X"8A", -- BYTE3
			X"44", -- BYTE4
			X"88", -- BYTE5
			X"6a", -- BYTE6
		-- 4th data	
			X"00", -- BYTE1
			X"32", -- BYTE2
			X"08", -- BYTE3
			X"40", -- BYTE4
			X"80", -- BYTE5
			X"20", -- BYTE6
		-- 5th data
			X"00", -- BYTE1
			X"40", -- BYTE2
			X"08", -- BYTE3
			X"40", -- BYTE4
			X"80", -- BYTE5
			X"20", -- BYTE6
		-- 6th data	
			X"00", -- BYTE1
			X"50", -- BYTE2
			X"08", -- BYTE3
			X"40", -- BYTE4
			X"80", -- BYTE5
			X"20", -- BYTE6
                        -- ##############
                        -- add other data
                        -- ##############
		-- 7th data	
			X"80", -- BYTE1
			X"00", -- BYTE2
			X"00", -- BYTE3
			X"00", -- BYTE4
			X"00", -- BYTE5
			X"00"  -- BYTE6
		);
	 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)

 	uut: ab_top PORT MAP(
		clk_uart_29MHz_i => sys_clk_i,
		clk_uart_monitor_o =>  s_br_clk_uart_o,
		uart_rst_i => uart_rst_emu,
		uart_leds_o => uart_leds_emu,
		uart_dout_o => uart_dout_emu,
		uart_din_i => uart_din_emu
	);

   uart_clock_process :process
   begin
		sys_clk_i <= '0';
		wait for uart_clock_period/2;
		sys_clk_i <= '1';
		wait for uart_clock_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
		-- hold reset
		wait for 50 ns;	
		uart_rst_emu <= '0';
		wait for uart_clock_period*10;
		uart_rst_emu <= '1';
		-- insert stimulus here 
		uart_din_emu  <= '1';
		
		wait for 10 us;
		
		-- look through test_data
		for j in test_data'range loop
			-- tx_start_bit 
			uart_din_emu <=  '0';
			wait for bit_period;
			
			-- Byte serializer
			for i in  0 to 7 loop
				uart_din_emu <= test_data(j)(i);
				wait for bit_period;
			end loop;
			
			-- tx_stop_bit 
			uart_din_emu <=  '1';
			wait for bit_period;
			wait for 5 us;
		end loop;
		
    wait;
   end process;

END;
