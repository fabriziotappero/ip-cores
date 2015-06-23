library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tx_func is
	port(	clk, reset : in std_logic;
			data : in std_logic_vector(7 downto 0);
			transmit_data : in std_logic;
			
			word_width : in std_logic_vector(3 downto 0);
			baud_period : in std_logic_vector(15 downto 0);
			use_parity_bit, parity_type : in std_logic;
			stop_bits : in std_logic_vector(1 downto 0);
			idle_line_lvl : in std_logic;

			tx : out std_logic;
			sending : out std_logic);
end entity tx_func;


architecture behaviour of tx_func is
	type state_type is (idle, start_bit, data_bit0, data_bit1, data_bit2, data_bit3, data_bit4, data_bit5, data_bit6, data_bit7, parity_bit, stop_bit1, stop_bit2);
	signal current_state : state_type;-- := idle;
	signal next_state : state_type;

	signal register_enable : std_logic;

	signal next_state_from_data_bit4	: state_type;
	signal next_state_from_data_bit5	: state_type;
	signal next_state_from_data_bit6	: state_type;
	signal next_state_from_data_bit7	: state_type;
	signal next_state_from_stop_bit1	: state_type;

	signal baud_tick : std_logic;-- := '0';
	signal baud_counter_d : std_logic_vector(15 downto 0);
	signal baud_counter_q : std_logic_vector(15 downto 0);-- := (others => '0');

	signal cal_parity_bit : std_logic;
	
	signal data_q : std_logic_vector(7 downto 0);-- := (others => '0');

begin
-----------------------
--Combinational logic
-----------------------
	--Tilstands encoding
	with current_state select	
		next_state <= 	start_bit 					when idle,
						data_bit0 					when start_bit,
						data_bit1 					when data_bit0,
						data_bit2 					when data_bit1,
						data_bit3 					when data_bit2,
						data_bit4 					when data_bit3,
						next_state_from_data_bit4 	when data_bit4,
						next_state_from_data_bit5 	when data_bit5,
						next_state_from_data_bit6 	when data_bit6,
						next_state_from_data_bit7 	when data_bit7,
						stop_bit1					when parity_bit,
						next_state_from_stop_bit1	when stop_bit1,
						idle						when stop_bit2,
						idle						when others;

	next_state_from_data_bit4 <= parity_bit when word_width = "0101" and use_parity_bit = '1' else
								 stop_bit1	when word_width = "0101" and use_parity_bit = '0' else
								 data_bit5;

	next_state_from_data_bit5 <= parity_bit when word_width = "0110" and use_parity_bit = '1' else
								 stop_bit1	when word_width = "0110" and use_parity_bit = '0' else
								 data_bit6;

	next_state_from_data_bit6 <= parity_bit when word_width = "0111" and use_parity_bit = '1' else
								 stop_bit1	when word_width = "0111" and use_parity_bit = '0' else
								 data_bit7;
	
	next_state_from_data_bit7 <= parity_bit when use_parity_bit = '1' else
								 stop_bit1;

	next_state_from_stop_bit1 <= stop_bit2	when stop_bits = "10" else 
								 idle;

	--Baud logic
	baud_tick <= '1' when baud_counter_q = baud_period else '0';
	baud_counter_d <= 	baud_counter_q + 1 when baud_tick = '0' and current_state /= idle else
						"0000000000000001";

	--Parity_bit logic
	cal_parity_bit <= data_q(0) xor data_q(1) xor data_q(2) xor data_q(3) xor data_q(4) xor data_q(5) xor data_q(6) xor data_q(7) xor parity_type;

	--TX Line logic
	with current_state select
		tx <= 			idle_line_lvl 		when idle,
						not idle_line_lvl 	when start_bit,
						data_q(0) 			when data_bit0,
						data_q(1) 			when data_bit1,
						data_q(2) 			when data_bit2,
						data_q(3) 			when data_bit3,
						data_q(4) 			when data_bit4,
						data_q(5) 			when data_bit5,
						data_q(6) 			when data_bit6,
						data_q(7) 			when data_bit7,
						cal_parity_bit		when parity_bit,
						idle_line_lvl		when stop_bit1,
						idle_line_lvl		when stop_bit2,
						idle_line_lvl		when others;
	
	--Signal logic
	sending <= '0' when current_state = idle else '1';

------------------
--Register logic
------------------
	register_enable <= 	'1' when (transmit_data = '1' and current_state = idle) or baud_tick = '1' else
						'0';

	register_logic : process(clk, reset)
	begin
		if rising_edge(clk) then
			--State Control
			if reset = '1' then
				current_state <= idle;
			elsif register_enable = '1' then
				current_state <= next_state;
			end if;
			
			--BAUD Counter Control
			if current_state /= idle or (current_state = idle and transmit_data = '1')then
				baud_counter_q <= baud_counter_d;
			end if;
			
			--DATA control
			if current_state = idle and transmit_data = '1' then
				data_q <= data;
			end if;
			
		end if;
	end process;

end architecture behaviour;	