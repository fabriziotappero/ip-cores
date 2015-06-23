--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Title			: FT245R interface
-- File			: ft245rl_interface.vhd
-- Author		: Alexey Lyashko <pradd@opencores.org>
-- License		: LGPL
--------------------------------------------------------------------------
-- Description	:
-- The controller simplifies the communication with FT245R chip. While 
-- provided interface is very similar to that of the chip itself, 
-- this controller takes care of all the delays and other aspects of 
-- FT245R's protocol as well as provifes separate ports for input and 
-- output.
--------------------------------------------------------------------------
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ft245rl_interface is
	-- This value is for 400MHz clock. Change it to suit your configuration.
	generic (min_delay : real := 2.5);														
	port
	(
		-- physical FT245RL interface 
		data_io					: inout 	std_logic_vector(7 downto 0);					
		nrst						: out		std_logic := '1';									
		ntxe						: in		std_logic;
		nrxf						: in		std_logic;
		nwr						: out		std_logic := '0';
		nrd						: out		std_logic := '1';
		
		-- logical interface
		clk						: in		std_logic;								-- System clock
		data_in					: in		std_logic_vector(7 downto 0);		-- Input from client entity
		data_out					: out		std_logic_vector(7 downto 0);		-- Output to client entity
		nce						: in		std_logic := '1';						-- "Chip" enable
		fetch_next_byte		: in		std_logic := '0';						-- Strobing this to '1' instructs the module to poll FT245RL for next available byte
		do_write					: in		std_logic := '0';						-- Strobing this to '1' instructs the module to write byte to FT245RL
		busy						: out		std_logic := '0';						-- Is '1' when the module is processing data
		data_available			: buffer	std_logic := '0';						-- Notifies the client of data availability
		reset						: in		std_logic := '1'						-- Resets the module
	);
end ft245rl_interface;


architecture action of ft245rl_interface is
	type state_t is (
								INIT,
								IDLE,
								READ_BYTE,
								READ_BYTE1,
								READ_BYTE2,
								READ_BYTE3,
								WRITE_BYTE,
								WRITE_BYTE1,
								WRITE_BYTE2,
								WRITE_BYTE3,
								DO_DELAY
							);
	signal c_state	: state_t := INIT;	-- current state
	signal n_state	: state_t := INIT;	-- next state
	
	signal delay_cnt:integer := 0;								-- Delay counter register
	signal current_delay : integer := 0;						-- This register holds number of clock cycles 
																			-- needed by the specified delay
	signal in_buff	: std_logic_vector(7 downto 0);			-- holds data received from FT245RL
	signal out_buff: std_logic_vector(7 downto 0);			-- holds data to be sent to FT245RL
	signal we		: std_logic := '0';							-- enables data output to FT245RL
	
	-- All delay specs may be found in FT245RL datasheet at
	-- http://www.ftdichip.com/Support/Documents/DataSheets/ICs/DS_FT245R.pdf
	constant t1_delay		:	integer := integer(50.0 / min_delay) - 1;
	constant t2_delay		:	integer := integer((50.0 + 80.0) / min_delay) - 1;
	constant t3_delay		:	integer := integer(35.0 / min_delay) - 1;
	constant t4_delay		:	integer := 0;
	constant t5_delay		:	integer := integer(25.0 / min_delay) - 1;
	constant t6_delay		:	integer := integer(80.0 / min_delay) - 1;
	constant t7_delay		:	integer := integer(50.0 / min_delay) - 1;
	constant t8_delay		:	integer := integer(50.0 / min_delay) - 1;
	constant t9_delay		:	integer := integer(20.0 / min_delay) - 1;
	constant t10_delay	:	integer := 0;
	constant t11_delay	:	integer := integer(25.0 / min_delay) - 1;
	constant t12_delay	:	integer := integer(80.0 / min_delay) - 1;
begin

	-- Bidirectional bus implementation.
	data_io	<=	out_buff when we = '1' else
					"ZZZZZZZZ" when we = '0' else
					"XXXXXXXX";
	in_buff	<= data_io;
	
	busy		<= '0' when c_state = IDLE else
					'1';
	
	-- Reset the FT245R chip on powerup.
	nrst		<= '0' when c_state = INIT else
					'1';

	nrd		<= '0' when c_state = READ_BYTE or c_state = READ_BYTE1 or
								(c_state = DO_DELAY and (n_state = READ_BYTE1 or n_state = READ_BYTE2)) else
					'1';
					
	nwr 		<= '1' when (c_state = WRITE_BYTE and ntxe = '0') or (c_state = DO_DELAY and n_state = WRITE_BYTE1) else
					'0';

	we			<= '1' when (c_state = WRITE_BYTE and ntxe = '0') or c_state = WRITE_BYTE1 or (c_state = DO_DELAY and (n_state = WRITE_BYTE1 or n_state = WRITE_BYTE2)) else
					'0';
				
	process(clk, reset, nrxf, ntxe, nce, data_available, fetch_next_byte, do_write)
	begin
		if(reset = '0')then
			c_state		<= INIT;
		elsif(rising_edge(clk) and nce = '0')then
			
			case c_state is
				-- The module enters this state on powerup or when 'reset' is low.
				when INIT =>
									delay_cnt		<= 0;
									current_delay	<= 0;
									c_state			<= IDLE;
									data_available	<= '0';
									
				-- This is the "main loop"
				when IDLE =>
									-- If this condition is true, we may safely read another byte from FT245RL's FIFO
									if(nrxf = '0' and data_available = '0')then
										c_state		<= READ_BYTE;
										
									-- We have to clear 'data_available' when the client module is requesting a new byte
									elsif(fetch_next_byte = '1')then
										data_available	<= '0';
										if(nrxf = '0')then
											c_state		<= READ_BYTE;
										else
											c_state		<= IDLE;
										end if;
										
									-- Well, here we simply write a byte to FT245RL's data bus
									elsif(do_write = '1')then
										c_state		<= WRITE_BYTE;
									end if;
				
				
				-- Read one byte from the device
				when READ_BYTE =>
									current_delay	<= t3_delay;
									c_state			<= DO_DELAY;
									n_state			<= READ_BYTE1;
									
				when READ_BYTE1 =>
									current_delay	<= t1_delay - t3_delay;
									c_state			<= DO_DELAY;
									n_state			<= READ_BYTE2;
									
				when READ_BYTE2 =>
									data_out			<= in_buff;
									current_delay	<= t5_delay;
									c_state			<= DO_DELAY;
									n_state			<= READ_BYTE3;
									
				when READ_BYTE3 =>
									current_delay	<= t2_delay;
									c_state			<= DO_DELAY;
									n_state			<= IDLE;
									data_available	<= '1';
									
				-- Write one byte to the device
				when WRITE_BYTE =>
									if(ntxe = '0')then
										current_delay<= t7_delay;
										c_state		<= DO_DELAY;
										n_state		<= WRITE_BYTE1;
										out_buff		<= data_in;
									else
										c_state		<= WRITE_BYTE;
									end if;
				
				when WRITE_BYTE1 =>
									current_delay	<= t11_delay;
									c_state			<= DO_DELAY;
									n_state			<= WRITE_BYTE2;
				
				when WRITE_BYTE2 =>
									current_delay	<= t12_delay;
									c_state			<=DO_DELAY;
									n_state			<= WRITE_BYTE3;
				
				when WRITE_BYTE3 =>
									c_state			<= IDLE;
				
				when DO_DELAY =>
									if(delay_cnt < current_delay)then	
										delay_cnt 	<= delay_cnt + 1;
									else
										c_state		<= n_state;
										delay_cnt	<= 0;
									end if;
									
				when others =>
									c_state		<= INIT;
			end case;	-- c_state
		end if;
	end process;
	
end action;