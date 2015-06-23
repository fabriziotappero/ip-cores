--add wave -position end  sim:/nand_ctrl/clk
--add wave -position end  sim:/nand_ctrl/c_state
--add wave -position end  sim:/nand_ctrl/r_state
--add wave -position end  sim:/nand_ctrl/t_state
--add wave -position end  sim:/nand_ctrl/nand_id(0)
--add wave -position end  sim:/nand_ctrl/nand_id(1)
--add wave -position end  sim:/nand_ctrl/nand_id(2)
--add wave -position end  sim:/nand_ctrl/nand_id(3)
--add wave -position end  sim:/nand_ctrl/nand_id(4)
--add wave -position end  sim:/nand_ctrl/exec
--add wave -position end  sim:/nand_ctrl/action_address
--add wave -position end  sim:/nand_ctrl/action_cmd
--add wave -position end  sim:/nand_ctrl/action_read
--add wave -position end  sim:/nand_ctrl/action_write
--add wave -position end  sim:/nand_ctrl/nand_ready
--add wave -position end  sim:/nand_ctrl/nandi_rx
--add wave -position end  sim:/nand_ctrl/nandi_tx
--add wave -position end  sim:/nand_ctrl/data_rx
--add wave -position end  sim:/nand_ctrl/data_tx
--force -freeze sim:/nand_ctrl/clk 1 0, 0 {1250 ps} -r 2.5ns

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.nand_stuff.all;


entity nand_ctrl is
	port
	(
		-- System interface
		clk						: in	std_logic;
		
		-- nand_interface interface
		action_cmd				: out	std_logic := '0';
		action_address			: out	std_logic := '0';
		action_read				: out	std_logic := '0';
		action_write			: out	std_logic := '0';
		n_nand_enable			: out	std_logic := '1';
		nandi_rx					: in	std_logic_vector(15 downto 0);
		nandi_tx					: out	std_logic_vector(15 downto 0);
		nand_ready				: in	std_logic := '0';
		is_x16					: out	std_logic := '0';
		die_select				: out	std_logic := '0';
		
		-- client interface
		data_rx					: in	std_logic_vector(7 downto 0);
		data_tx					: out	std_logic_vector(7 downto 0);
		-- Strobing 'exec' to '1' notifies the controller of a command pending on 'data_rx'.
		-- May also be used during command execution (for example, during data transfers), 
		-- notifying of either new data having been written to data_rx or of a need to output
		-- next byte to data_tx.
		exec						: in	std_logic := '0';
		n_reset					: in	std_logic := '1';
		ready						: out	std_logic := '1'
	);
end nand_ctrl;

architecture action of nand_ctrl is
	-- State machine stuff
	type c_state_t is (C_RESET, C_IDLE, C_DELAY, C_WAIT, C_CMD_NAND_RESET, C_CMD_NAND_READ_ID);
	signal c_state 			: c_state_t := C_RESET;
	signal r_state				: c_state_t;
	
	type t_state_t is (T_BEGIN, T_1, T_2, T_3, T_END);
	signal t_state				: t_state_t := T_BEGIN;
	
	type nand_cmd_t is array (0 to 64) of c_state_t;
	signal nand_cmd_list		: nand_cmd_t := (C_CMD_NAND_RESET, C_CMD_NAND_READ_ID,
															others => C_IDLE);

	-- Local storage for NAND chip ID
	type nand_id_t is array (0 to 4) of std_logic_vector(7 downto 0);
	signal nand_id 			: nand_id_t;

	-- Counters
	signal delay_cnt			: integer := 0;
	signal byte_cnt			: integer := 0;
	
	signal nandi_tx_buffer	: std_logic_vector(15 downto 0);
begin
	ready						<= '1' when c_state = C_IDLE else '0';

	action_cmd				<= '1' when (c_state = C_CMD_NAND_RESET and t_state = T_BEGIN) or
										 (c_state = C_CMD_NAND_READ_ID and t_state = T_BEGIN)
										 else '0';
										 
	action_address			<= '1' when (c_state = C_CMD_NAND_READ_ID and t_state = T_1)
										 else '0';
										 
	action_read				<= '1' when c_state = C_CMD_NAND_READ_ID and t_state = T_2
										 else '0';

--	action_write

	nandi_tx					<= x"00ff" when c_state = C_CMD_NAND_RESET and (t_state = T_BEGIN or t_state = T_1 or t_state = T_2) else
									x"0090" when (c_state = C_CMD_NAND_READ_ID and t_state = T_BEGIN) or (c_state = C_WAIT and r_state = C_CMD_NAND_READ_ID and t_state = T_1) else
									x"0000" when (c_state = C_CMD_NAND_READ_ID and t_state = T_1) or (c_state = C_WAIT and r_state = C_CMD_NAND_READ_ID and t_state = T_2) else
									nandi_tx_buffer;
										 
	process(clk, exec, data_rx, nandi_rx, nand_ready)
	begin
		if(n_reset = '0')then	
				c_state									<= C_RESET;
			elsif(rising_edge(clk))then
				case c_state is
					when C_RESET =>
						c_state							<= C_IDLE;
									
				----------------------------------------------------
				-- Idle state - controller awaits orders
				----------------------------------------------------
				when C_IDLE =>
					t_state								<= T_BEGIN;
					if(exec = '1')then
						if(data_rx(7 downto 6) = "00")then
							c_state						<= nand_cmd_list(to_integer(unsigned(data_rx(5 downto 0))));
						
						end if;
					else 
						c_state							<= C_IDLE;
					end if;
									
				----------------------------------------------------
				-- NAND READ ID function
				----------------------------------------------------
				when C_CMD_NAND_READ_ID =>
					if(t_state = T_BEGIN)then
						r_state							<= C_CMD_NAND_READ_ID;
						c_state							<= C_WAIT;
						t_state							<= T_1;
						
					elsif(t_state = T_1)then
						r_state							<= C_CMD_NAND_READ_ID;
						c_state							<= C_WAIT;
						t_state							<= T_2;
						byte_cnt							<= 0;
						
					elsif(t_state = T_2)then
						r_state							<= C_CMD_NAND_READ_ID;
						c_state							<= C_WAIT;
						t_state							<= T_END;
						
					elsif(t_state = T_END)then
						nand_id(byte_cnt)				<= nandi_rx(7 downto 0);
						if(byte_cnt < 4)then
							byte_cnt						<= byte_cnt + 1;
							c_state						<= C_CMD_NAND_READ_ID;
							t_state						<= T_2;
						else
							byte_cnt						<= 0;
							c_state						<= C_IDLE;
						end if;
					end if;
						
						
				
				----------------------------------------------------
				-- NAND reset function
				----------------------------------------------------
				when C_CMD_NAND_RESET =>
					if(t_state = T_BEGIN)then
						t_state							<= T_1;
						
					elsif(t_state = T_1)then
						r_state							<= C_CMD_NAND_RESET;
						c_state							<= C_DELAY;
						delay_cnt						<= t_rst;
						t_state							<= T_2;
						
					elsif(t_state = T_2)then
						if(nand_ready = '1')then
							c_state						<= C_IDLE;
							t_state						<= T_BEGIN;
						else
							c_state						<= C_CMD_NAND_RESET;
							t_state						<= T_2;
						end if;
					end if;
										
				----------------------------------------------------
				-- Simple delay 
				----------------------------------------------------
				when C_DELAY =>
					if(delay_cnt > 0)then
						delay_cnt						<= delay_cnt - 1;
					else
						c_state							<= r_state;
					end if;
					
				when C_WAIT =>
					if(nand_ready = '1')then
						c_state							<= r_state;
					else
						c_state							<= C_WAIT;
					end if;
						
				when others =>
					c_state								<= C_RESET;
			end case;
		end if;
	end process;
end action;