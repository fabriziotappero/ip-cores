library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rx_func is
	port(	clk, reset, rx_enable : in std_logic;
			rx : in std_logic;
			
			word_width : in std_logic_vector(3 downto 0);
			baud_period : in std_logic_vector(15 downto 0);
			use_parity_bit, parity_type : in std_logic;
			stop_bits : in std_logic_vector(1 downto 0);
			idle_line_lvl : in std_logic;
			
			start_samples : in std_logic_vector(3 downto 0);	--How many correct samples should give a start bit
			line_samples : in std_logic_vector(3 downto 0);		--How many samples should tip the internal rx value
			
			data 		: out std_logic_vector(7 downto 0);
			data_ready 	: out std_logic;
			parity_error :	out std_logic;
			stop_bit_error : out std_logic);
end entity rx_func;

architecture behaviour of rx_func is
	type state_type is (idle, data_bit0, data_bit1, data_bit2, data_bit3, data_bit4, data_bit5, data_bit6, data_bit7, parity_bit, stop_bit1, stop_bit2, data_check, data_rdy);
	signal current_state : state_type := idle;
	signal next_state, next_state_rst : state_type;
	signal next_state_from_data_bit4 : state_type;
	signal next_state_from_data_bit5 : state_type;
	signal next_state_from_data_bit6 : state_type;
	signal next_state_from_data_bit7 : state_type;
	signal next_state_from_stop_bit1 : state_type;
	
	signal sampled_data : std_logic_vector(9 downto 0);-- := "0000000000";

	signal period_count_enable : std_logic;
	signal period_count_q : std_logic_vector(15 downto 0);-- := "0000000000000000";
	signal period_count_d : std_logic_vector(15 downto 0);
	signal baud_tick : std_logic;
	signal period16_count_q : std_logic_vector(11 downto 0);-- := "000000000000";
	signal period16_count_d : std_logic_vector(11 downto 0);
	signal sample_tick : std_logic;
	signal sample_reg_q, sample_reg_start_bit_q : std_logic_vector(3 downto 0);-- := "0000";
	signal sample_reg_start_bit_d, sample_reg_d : std_logic_vector(3 downto 0);
	signal rx_sampled_q : std_logic;-- := '0';
	signal rx_sampled_d : std_logic;
	signal xored_sampled_data_bit_q : std_logic;-- := '0';
	signal xored_sampled_data_bit_d : std_logic;
	
begin
-------------------------
-- Combinational logic --
-------------------------

--State Logic
	next_state 					<= 	idle when reset = '1' else
									next_state_rst;
	with current_state select
		next_state_rst 			<=	data_bit0 					when idle,		--Identifying start bit
									data_bit1 					when data_bit0,
									data_bit2 					when data_bit1,
									data_bit3 					when data_bit2,
									data_bit4 					when data_bit3,
									next_state_from_data_bit4	when data_bit4,
									next_state_from_data_bit5 	when data_bit5,
									next_state_from_data_bit6 	when data_bit6,
									next_state_from_data_bit7 	when data_bit7,
									stop_bit1 					when parity_bit,
									next_state_from_stop_bit1	when stop_bit1,
									data_check					when stop_bit2,
									data_rdy					when data_check,
									idle						when data_rdy,
									idle 						when others;

	next_state_from_data_bit4 <= 	parity_bit 	when word_width = "0101" and use_parity_bit = '1' else
									stop_bit1	when word_width = "0101" and use_parity_bit = '0' else
									data_bit5;

	next_state_from_data_bit5 <= 	parity_bit 	when word_width = "0110" and use_parity_bit = '1' else
									stop_bit1	when word_width = "0110" and use_parity_bit = '0' else
									data_bit6;
	
	next_state_from_data_bit6 <= 	parity_bit 	when word_width = "0111" and use_parity_bit = '1' else
									stop_bit1	when word_width = "0111" and use_parity_bit = '0' else
									data_bit7;
	
	next_state_from_data_bit7 <= 	parity_bit 	when use_parity_bit = '1' else
									stop_bit1;
	
	next_state_from_stop_bit1 <= 	stop_bit2 	when stop_bits = "10" else
									data_check;


--Sample logic
	period16_count_d 		<= 	period16_count_q + 1 when reset = '0' and period16_count_q /= baud_period(15 downto 4) else
								"000000000001";
	sample_tick 			<= 	'1' when period16_count_q = baud_period(15 downto 4) else
								'0';

--Baud logic
	with current_state select
		period_count_enable		<= 	'0' when idle,
									'0' when data_check,
									'0' when data_rdy,
									'1' when others;
	period_count_d 			<= 	period_count_q + 1 when reset = '0' and period_count_q /= baud_period else
								"0000000000000001";
	baud_tick				<=	'1' when period_count_q = baud_period else
								'0';

--RX sampled, by saturation counter
	sample_reg_d			<=	sample_reg_q + 1 	when reset = '0' and rx = '1' and sample_reg_q /= line_samples else
								sample_reg_q - 1 	when reset = '0' and rx = '0' and sample_reg_q /= "0000" else
								sample_reg_q		when reset = '0' else
								"0000";

	rx_sampled_d			<=  '1' when reset = '0' and sample_reg_q = line_samples else
								'0' when reset = '0' and sample_reg_q = "0000" else
								rx_sampled_q;
	
	sample_reg_start_bit_d	<=	sample_reg_start_bit_q + 1	when reset = '0' and rx /= idle_line_lvl and sample_reg_start_bit_q /= start_samples else
								sample_reg_start_bit_q - 1	when reset = '0' and rx  = idle_line_lvl and sample_reg_start_bit_q /= "0000" else
								sample_reg_start_bit_q		when reset = '0' else
								"0000";

--Parity bit
	with current_state select
		xored_sampled_data_bit_d	<= 	'0' when idle,
										xored_sampled_data_bit_q when stop_bit1,
										xored_sampled_data_bit_q when stop_bit2,
										xored_sampled_data_bit_q when data_check,
										xored_sampled_data_bit_q xor rx_sampled_q when others;

--Reciving status signals
	data_ready <= 		'1' when current_state = data_rdy else
						'0';
	parity_error 	<= 	'1' when xored_sampled_data_bit_q /= parity_type and current_state = data_check else
						'0';
	stop_bit_error 	<= 	'1' when current_state = data_check and (sampled_data(8) /= idle_line_lvl or (sampled_data(9) /= idle_line_lvl and stop_bits = "10")) else
						'0';


--------------------
-- Register logic --
--------------------
	register_logic : process(clk, reset, rx_enable, period_count_enable, sample_tick, baud_tick, current_state, use_parity_bit)
	begin
		if rising_edge(clk) then
			--sample counter
			if rx_enable = '1' or reset = '1' then
				period16_count_q	<= period16_count_d;
			end if;
			
			--baud counter
			if period_count_enable = '1' or reset = '1' then
				period_count_q 		<= period_count_d;
			end if;
			
			if sample_tick = '1' then
				sample_reg_q			<= sample_reg_d;
				rx_sampled_q 			<= rx_sampled_d;
				sample_reg_start_bit_q	<= sample_reg_start_bit_d;
			end if;
			
			if baud_tick = '1' or (current_state = idle and sample_reg_start_bit_q = start_samples) or current_state = data_check or current_state = data_rdy then
				current_state <= next_state;
			end if;
			
			if baud_tick = '1' and current_state = data_bit0 then
				sampled_data(0) <= rx_sampled_q;
			end if;
			if baud_tick = '1' and current_state = data_bit1 then
				sampled_data(1) <= rx_sampled_q;
			end if;
			if baud_tick = '1' and current_state = data_bit2 then
				sampled_data(2) <= rx_sampled_q;
			end if;
			if baud_tick = '1' and current_state = data_bit3 then
				sampled_data(3) <= rx_sampled_q;
			end if;
			if baud_tick = '1' and current_state = data_bit4 then
				sampled_data(4) <= rx_sampled_q;
			end if;
			if baud_tick = '1' and current_state = data_bit5 then
				sampled_data(5) <= rx_sampled_q;
			end if;
			if baud_tick = '1' and current_state = data_bit6 then
				sampled_data(6) <= rx_sampled_q;
			end if;
			if baud_tick = '1' and current_state = data_bit7 then
				sampled_data(7) <= rx_sampled_q;
			end if;
			if baud_tick = '1' and current_state = stop_bit1 then
				sampled_data(8) <= rx_sampled_q;
			end if;
			if baud_tick = '1' and current_state = stop_bit2 then
				sampled_data(9) <= rx_sampled_q;
			end if;	

			if current_state = data_check then
				data <= sampled_data(7 downto 0);
			end if;
			
			if baud_tick = '1' and use_parity_bit = '1' then
				xored_sampled_data_bit_q <= xored_sampled_data_bit_d;
			end if;
		end if;
	end process register_logic;
	
end architecture behaviour;