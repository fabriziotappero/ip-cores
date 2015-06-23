--------------------------------------------------------------------------------
-- Company: University of Vigo
-- Engineer: L. Jacobo Alvarez Ruiz de Ojeda
--
-- Create Date:    18:26:28 10/17/06
-- Design Name:    
-- Module Name:    rs232_transmitter - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
-- The parity can be selected through the signal even_odd (0: odd/impar; 1: even/par)
-- The busy signal keeps activated during the whole transmitting process of a data (start bit, 8 data bits, parity bit and stop bit)
-- The send clock must have a frequency equal to the desired baud rate
-- The activation of "send_data" during one "clk" clock cycle orders this circuit to capture the character present
-- at the "data_in" inputs and to send it through the RS232 TXD line
-- The activation of the "send_done" signal during one "clk" clock cycle indicates that the character has been sent
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

entity rs232_transmitter is
    Port ( clk : in std_logic; -- global clock
           reset : in std_logic; -- global reset
           send_clk : in std_logic; -- this clock gives the duration of each bit in the transmission, that is, the baud rate
           send_data : in std_logic; -- this signal orders to send the data present at the data_in inputs
           data_in : in std_logic_vector(7 downto 0); -- data to be sent
		 even_odd: in std_logic; -- it selects the desired parity (0: odd/impar; 1: even/par)
           txd : out std_logic; -- The RS232 TXD line
           busy : out std_logic; -- it indicates that the transmitter is busy sending one character
           send_done : out std_logic); -- it indicates that the sending process has ended
end rs232_transmitter;

architecture Behavioral of rs232_transmitter is

-- Component declaration

-- 9 bits shift register declaration
	COMPONENT shift9_lr
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		load_8_lsb_bits : IN std_logic;
		load_msb_bit : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);
		msb_in : IN std_logic;
		shift_enable : IN std_logic;
		q_shift : OUT std_logic_vector(8 downto 0);          
		lsb_out : OUT std_logic
		);
	END COMPONENT;

-- BCD counter declaration
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

-- Transmitter control state machine declaration
	COMPONENT tx_ctrl
	PORT(
		CLK : IN std_logic;
		ctr_eq_9 : IN std_logic;
		fa_send_clk : IN std_logic;
		RESET : IN std_logic;
		send_data : IN std_logic;          
		incr_ctr : OUT std_logic;
		load_parity_bit : OUT std_logic;
		load_txd : OUT std_logic;
		reset_busy : OUT std_logic;
		reset_ctr : OUT std_logic;
		reset_txd : OUT std_logic;
		send_done : OUT std_logic;
		set_busy : OUT std_logic;
		set_txd : OUT std_logic;
		shift_enable : OUT std_logic
		);
	END COMPONENT;

-- Signals declaration
-- Edge detector for send_clk
signal send_clk_t_1 , send_clk_s, fa_send_clk: std_logic;

-- Shift register
signal parity_bit, load_parity_bit, shift_enable, lsb_out: std_logic;
signal q_shift : std_logic_vector(8 downto 0);

-- BCD counter
signal incr_ctr, ctr_eq_9, reset_ctr: std_logic;
signal q_ctr: std_logic_vector (3 downto 0);

-- Busy register
signal set_busy, reset_busy: std_logic;

-- TXD register
signal set_txd, reset_txd, load_txd: std_logic;

begin

-- Edge detector for send_clk
process (reset,clk,send_clk_s,send_clk_t_1)
begin
	if reset = '1' then 	send_clk_s <= '0';
								send_clk_t_1 <= '0';
	elsif clk = '1' and clk'event then send_clk_t_1 <= send_clk_s;
												send_clk_s <= send_clk;
	end if;

	fa_send_clk <= send_clk_s and not send_clk_t_1;
--	fd_send_clk <= not send_clk_s and send_clk_t_1;
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

-- TXD register
TXD_register: process (clk, reset, reset_txd, set_txd)
begin
if reset = '1' then
	txd <= '1';
elsif clk'event and clk ='1' then
	if set_txd = '1' then txd <= '1';
	elsif reset_txd ='1' then txd <= '0';
	elsif load_txd = '1' then txd <= lsb_out;
	end if; 
end if;
end process;

-- Parity calculator
parity_calculator: process(even_odd, q_shift)
begin
if even_odd = '0' then -- odd parity (the 9 bits has an odd number of ones)
	-- 8 bits XNOR 
	parity_bit <= not (q_shift(7) xor q_shift(6) xor q_shift(5) xor q_shift(4) xor q_shift(3) xor q_shift(2) xor q_shift(1) xor q_shift(0));

elsif even_odd = '1' then -- even parity (the 9 bits has an even number of ones)
	-- 8 bits XOR 
	parity_bit <= q_shift(7) xor q_shift(6) xor q_shift(5) xor q_shift(4) xor q_shift(3) xor q_shift(2) xor q_shift(1) xor q_shift(0);
end if;
end process;

-- Component instantiation

-- 9 bits shift register instantiation
	Inst_shift9_lr: shift9_lr PORT MAP(
		clk => clk,
		reset => reset,
		load_8_lsb_bits => send_data,
		load_msb_bit => load_parity_bit,
		data_in => data_in,
		msb_in => parity_bit,
		shift_enable => shift_enable,
		q_shift => q_shift,
		lsb_out => lsb_out
		);

-- BCD counter instantiation
	Inst_ctr_bcd: ctr_bcd PORT MAP(
		clk => clk,
		reset => reset,
		sync_reset => reset_ctr,
		gctr => incr_ctr,
		qctr => q_ctr,
		ctr_eq_9 => ctr_eq_9
	);

-- Transmitter control state machine instantiation
	Inst_tx_ctrl: tx_ctrl PORT MAP(
		CLK => clk,
		ctr_eq_9 => ctr_eq_9,
		fa_send_clk => fa_send_clk,
		RESET => reset,
		send_data => send_data,
		incr_ctr => incr_ctr,
		load_parity_bit => load_parity_bit,
		load_txd => load_txd,
		reset_busy => reset_busy,
		reset_ctr => reset_ctr,
		reset_txd => reset_txd,
		send_done => send_done,
		set_busy => set_busy,
		set_txd => set_txd,
		shift_enable => shift_enable
	);

end Behavioral;
