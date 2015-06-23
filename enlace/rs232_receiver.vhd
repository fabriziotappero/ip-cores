--------------------------------------------------------------------------------
-- Company: University of Vigo
-- Engineer: L. Jacobo Alvarez Ruiz de Ojeda
--
-- Create Date:    10:26:09 10/18/06
-- Design Name:    
-- Module Name:    rs232_receiver - Behavioral.
-- The parity can be selected through the signal even_odd (0: odd/impar; 1: even/par)
-- The error flags (start_error, discrepancy_error and stop_error) keep activated only one clock cycle except the parity error flag, that holds its state
-- until a new data is received.
-- The busy signal keeps activated during the whole receiving process of a data (start bit, 8 data bits, parity bit and stop bit)
-- The receive clock must have a frequency of each times faster than the baud rate
-- The activation of "new_data" during one clock cycle indicates the arriving of a new character.
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rs232_receiver is
    Port ( clk : in std_logic; -- global clock
           reset : in std_logic; -- global reset
           receive_clk : in std_logic; -- this clock must have a frequency of eight times faster than the baud rate
           even_odd: in std_logic; -- it selects the desired parity (0: odd/impar; 1: even/par)
			  rxd : in std_logic; -- The RS232 RXD line
           data_out : out std_logic_vector(7 downto 0); -- The data received, in parallel
           parity_error : out std_logic; -- it indicates a parity error in the received data
           start_error : out std_logic; -- it indicates an error in the start bit (false start). The receiver will wait for a new complete start bit
           stop_error : out std_logic; -- it indicates an error in the stop bit (though the data could have been received correctly and it is presented at the outputs).
			  discrepancy_error: out std_logic;  -- it indicates an error because the three samples of the same bit have different values.
           busy : out std_logic; -- it indicates that the receiver is busy receiving one character
           new_data : out std_logic); -- it indicates that the receiving process has ended and a new character is available
end rs232_receiver;

architecture Behavioral of rs232_receiver is

-- Component declaration

-- 9 bits shift register declaration
	COMPONENT shift9_r
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		msb_in : IN std_logic;
		shift_enable : IN std_logic;          
		q_shift : OUT std_logic_vector(8 downto 0)
		);
	END COMPONENT;

-- BCD counter declaration. This is the bit counter
	COMPONENT ctr_bcd
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		sync_reset : IN std_logic;
		gctr : IN std_logic;          
		qctr : OUT std_logic_vector(3 downto 0);
		ctr_eq_9 : OUT std_logic
		);
	END COMPONENT;

-- Receiver clock counter declaration. This is the counter for the "receive_clock" cycles
	COMPONENT ctr_receiver_clock
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		sync_reset : IN std_logic;
		gctr : IN std_logic;          
		ctr_eq_2 : OUT std_logic;
		ctr_eq_4 : OUT std_logic;
		ctr_eq_6 : OUT std_logic;
		ctr_eq_8 : OUT std_logic;
		qctr : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;

-- Voting circuit declaration
	COMPONENT voting_circuit_2_of_3
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		load_sample_1 : IN std_logic;
		load_sample_2 : IN std_logic;
		load_sample_3 : IN std_logic;
		bit_input : IN std_logic;          
		sampled_bit : OUT std_logic;
		discrepancy : OUT std_logic
		);
	END COMPONENT;

-- Receiver control state machine declaration
	COMPONENT rx_ctrl
	PORT(
		CLK : IN std_logic;
		ctr_bits_eq_9 : IN std_logic;
		last_sample : IN std_logic;
		RESET : IN std_logic;
		fd_rxd : IN std_logic;
		sampled_bit : IN std_logic;          
		incr_ctr_bits : OUT std_logic;
		ld_parity_error : OUT std_logic;
		load_data : OUT std_logic;
		load_discrepancy : OUT std_logic;
		new_data : OUT std_logic;
		reset_busy : OUT std_logic;
		reset_capture : OUT std_logic;
		reset_ctr_bits : OUT std_logic;
		reset_ctr_clock : OUT std_logic;
		rst_ce_ctr_clock : OUT std_logic;
		rst_discrepancy : OUT std_logic;
		set_busy : OUT std_logic;
		set_capture : OUT std_logic;
		set_ce_ctr_clock : OUT std_logic;
		shift_enable : OUT std_logic;
		start_error : OUT std_logic;
		stop_error : OUT std_logic
		);
	END COMPONENT;

-- Signals declaration
-- Edge detector for receive_clk
signal receive_clk_t_1 , receive_clk_s, fa_receive_clk, fd_receive_clk: std_logic;

-- Shift register
signal shift_enable: std_logic;
signal q_shift : std_logic_vector(8 downto 0);

-- BCD counter
signal reset_ctr_bits, incr_ctr_bits, ctr_bits_eq_9: std_logic;
signal q_ctr_bits: std_logic_vector (3 downto 0);

-- Receiver clock cycles counter
signal reset_ctr_clock, incr_ctr_clock, ctr_clock_eq_2, ctr_clock_eq_4, ctr_clock_eq_6, ctr_clock_eq_8: std_logic;
signal q_ctr_clock: std_logic_vector (3 downto 0);

-- Busy register
signal set_busy, reset_busy: std_logic;

-- Parity error register
signal load_parity_error, parity_error_aux: std_logic;

-- Synchonization register and edge detector for RXD line
signal rxd_s, rxd_t_1, fd_rxd: std_logic;

-- Capture samples register
signal reset_capture, set_capture, capture_samples: std_logic;

-- Enable receive clock counter register
signal reset_ce_ctr_clock, set_ce_ctr_clock, ce_ctr_clock: std_logic;

-- Voting circuit for rxd samples
signal load_sample_1, load_sample_2, load_sample_3, sampled_bit, discrepancy: std_logic;

-- Discrepancy error register
signal load_discrepancy_error, reset_discrepancy_error: std_logic;

-- Data received register
signal load_data: std_logic;

-- Receiver control state machine
signal last_sample: std_logic;

begin

-- Edge detector for receive_clk
process (reset,clk,receive_clk_s,receive_clk_t_1)
begin
	if reset = '1' then 	receive_clk_s <= '0';
								receive_clk_t_1 <= '0';
	elsif clk = '1' and clk'event then receive_clk_t_1 <= receive_clk_s;
												receive_clk_s <= receive_clk;
	end if;

	fa_receive_clk <= receive_clk_s and not receive_clk_t_1;
	fd_receive_clk <= not receive_clk_s and receive_clk_t_1;
end process;

-- Synchonization register and edge detector for RXD line
process (reset,clk,rxd_s,rxd_t_1)
begin
	if reset = '1' then 	rxd_s <= '1';
								rxd_t_1 <= '1';
	elsif clk = '1' and clk'event then  rxd_t_1 <= rxd_s;
													rxd_s <= rxd;
	end if;

--	fa_rxd <= rxd_s and not rxd_t_1;
	fd_rxd <= not rxd_s and rxd_t_1;
end process;

-- Busy register
Busy_register: process (clk, reset, reset_busy, set_busy)
begin
if reset = '1' then
	busy <= '0';
elsif clk'event and clk ='1' then
	if reset_busy = '1' then busy <= '0';
	elsif set_busy ='1' then busy <= '1';
	end if; 
end if;
end process;

-- Capture samples register
Capture_register: process (clk, reset, reset_capture, set_capture)
begin
if reset = '1' then
	capture_samples <= '0';
elsif clk'event and clk ='1' then
	if reset_capture = '1' then capture_samples <= '0';
	elsif set_capture ='1' then capture_samples <= '1';
	end if; 
end if;
end process;

-- Enable receive clock counter register
Enable_receive_clock_counter_register: process (clk, reset, reset_ce_ctr_clock, set_ce_ctr_clock)
begin
if reset = '1' then
	ce_ctr_clock <= '0';
elsif clk'event and clk ='1' then
	if reset_ce_ctr_clock = '1' then ce_ctr_clock <= '0';
	elsif set_ce_ctr_clock ='1' then ce_ctr_clock <= '1';
	end if; 
end if;
end process;

-- Parity error register
Parity_error_register: process (clk, reset, load_parity_error)
begin
if reset = '1' then
	parity_error <= '0';
elsif clk'event and clk ='1' then
	if load_parity_error = '1' then parity_error <= parity_error_aux;
	end if; 
end if;
end process;

-- Parity calculator
parity_calculator: process(even_odd, q_shift)
begin
if even_odd = '0' then -- odd parity (the 9 bits has an odd number of ones)
	-- 9 bits XNOR. If it is 1, there is an error because there is an even number of ones
	parity_error_aux <= not (q_shift(8) xor q_shift(7) xor q_shift(6) xor q_shift(5) xor q_shift(4) xor q_shift(3) xor q_shift(2) xor q_shift(1) xor q_shift(0));

elsif even_odd = '1' then -- even parity (the 9 bits has an even number of ones)
	-- 9 bits XOR. If it is 1, there is an error because there is an odd number of ones
	parity_error_aux <= q_shift(8) xor q_shift(7) xor q_shift(6) xor q_shift(5) xor q_shift(4) xor q_shift(3) xor q_shift(2) xor q_shift(1) xor q_shift(0);
end if;
end process;

-- Discrepancy error register
Discrepancy_error_register: process (clk, reset, load_discrepancy_error)
begin
if reset = '1' then
	discrepancy_error <= '0';
elsif clk'event and clk ='1' then
	if reset_discrepancy_error = '1' then discrepancy_error <= '0';
	elsif load_discrepancy_error = '1' then discrepancy_error <= discrepancy;
	end if; 
end if;
end process;


-- Data received register
Data_received_register: process (clk, reset, load_data)
begin
if reset = '1' then
	data_out <= "00000000";
elsif clk'event and clk ='1' then
	if load_data = '1' then data_out <= q_shift (7 downto 0);
	end if; 
end if;
end process;


-- Component instantiation

-- 9 bits shift register instantiation
	Inst_shift9_r: shift9_r PORT MAP(
		clk => clk,
		reset => reset,
		msb_in => sampled_bit,
		shift_enable => shift_enable,
		q_shift => q_shift
	);

-- BCD counter instantiation. This is the bit counter
	Inst_ctr_bcd: ctr_bcd PORT MAP(
		clk => clk,
		reset => reset,
		sync_reset => reset_ctr_bits,
		gctr => incr_ctr_bits,
		qctr => q_ctr_bits,
		ctr_eq_9 => ctr_bits_eq_9
	);

-- Receiver clock counter instantiation. This is the counter for the "receive_clock" cycles
	Inst_ctr_receiver_clock: ctr_receiver_clock PORT MAP(
		clk => clk,
		reset => reset,
		sync_reset => reset_ctr_clock,
		ctr_eq_2 => ctr_clock_eq_2,
		ctr_eq_4 => ctr_clock_eq_4,
		ctr_eq_6 => ctr_clock_eq_6,
		ctr_eq_8 => ctr_clock_eq_8,
		gctr => incr_ctr_clock,
		qctr => q_ctr_clock
	);

-- Increment order for receiver clock counter
incr_ctr_clock <= ce_ctr_clock and fa_receive_clk;

-- Voting circuit instantiation
	Inst_voting_circuit_2_of_3: voting_circuit_2_of_3 PORT MAP(
		clk => clk,
		reset => reset,
		load_sample_1 => load_sample_1,
		load_sample_2 => load_sample_2,
		load_sample_3 => load_sample_3,
		bit_input => rxd_s,
		sampled_bit => sampled_bit,
		discrepancy => discrepancy
	);

-- Capture sample orders for voting circuit
load_sample_1 <= fd_receive_clk and ctr_clock_eq_2 and capture_samples;
load_sample_2 <= fd_receive_clk and ctr_clock_eq_4 and capture_samples;
load_sample_3 <= fd_receive_clk and ctr_clock_eq_6 and capture_samples;
last_sample <= fd_receive_clk and ctr_clock_eq_6;

-- Receiver control state machine instantiation
	Inst_rx_ctrl: rx_ctrl PORT MAP(
		CLK => clk,
		ctr_bits_eq_9 => ctr_bits_eq_9,
		last_sample => last_sample,
		RESET => reset,
		fd_rxd => fd_rxd,
		sampled_bit => sampled_bit,
		incr_ctr_bits => incr_ctr_bits,
		ld_parity_error => load_parity_error,
		load_data => load_data,
		load_discrepancy => load_discrepancy_error,
		new_data => new_data,
		reset_busy => reset_busy,
		reset_capture => reset_capture,
		reset_ctr_bits => reset_ctr_bits,
		reset_ctr_clock => reset_ctr_clock,
		rst_ce_ctr_clock => reset_ce_ctr_clock,
		rst_discrepancy => reset_discrepancy_error,
		set_busy => set_busy,
		set_capture => set_capture,
		set_ce_ctr_clock => set_ce_ctr_clock,
		shift_enable => shift_enable,
		start_error => start_error,
		stop_error => stop_error
	);

end Behavioral;
