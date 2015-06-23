library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tx_fifo is
	generic(address_width : integer := 3);
	port(	clk, reset		: in std_logic;

			write_tx_data	: in std_logic;
			tx_data 		: in std_logic_vector(7 downto 0);
			tx_fifo_full 	: out std_logic;
			tx_fifo_empty 	: out std_logic;
			tx_fifo_entries_free : out std_logic_vector(7 downto 0);

			tx_func_data		: out std_logic_vector(7 downto 0);
			tx_func_apply_data 	: out std_logic;
			tx_func_sending		: in std_logic);
end entity tx_fifo;

architecture behaviour of tx_fifo is
	type ram_type is array (0 to 2**address_width-1) of std_logic_vector(7 downto 0);
	signal ram : ram_type;

	constant max_fifo_entries : std_logic_vector(address_width downto 0) := conv_std_logic_vector(2**address_width, address_width+1);
	signal tx_entries_back_d : std_logic_vector(address_width downto 0);
	signal tx_entries_back_q : std_logic_vector(address_width downto 0);
	signal tx_in_addr_d, tx_out_addr_d : std_logic_vector(address_width-1 downto 0);
	signal tx_in_addr_q, tx_out_addr_q : std_logic_vector(address_width-1 downto 0);
	signal tx_in_addr_en, tx_out_addr_en, tx_entries_back_en : std_logic;
	
	signal ram_we : std_logic;
	signal ram_address : std_logic_vector(address_width-1 downto 0);
	signal tx_fifo_empty_i : std_logic := '1';
	signal tx_fifo_full_i : std_logic := '0';
	
	signal tx_func_apply_data_i : std_logic;
	
begin
--------------------
-- Component used --
--------------------


-------------------------
-- Combinational Logic --
-------------------------
	ram_we					<= 	write_tx_data and not tx_fifo_full_i;
--	ram_we					<=	'1' when write_tx_data = '1' and tx_fifo_full_i = '0' else
--								'0';
	
	with ram_we select
	ram_address 			<= 	tx_in_addr_q 		when '1',
								tx_out_addr_q 		when '0',
								tx_out_addr_q		when others;
	
	tx_in_addr_en			<=	reset or ram_we;
	tx_in_addr_d			<= 	(others => '0')		when reset = '1' else
								tx_in_addr_q + 1;-- 	when ram_we = '1' else	--taken care of by the register enable
								--tx_in_addr_q;
	tx_out_addr_en			<=	reset or tx_func_apply_data_i;
	tx_out_addr_d			<= 	(others => '0') 	when reset = '1' else
								tx_out_addr_q + 1;--	when tx_func_apply_data_i = '1' else
								--tx_out_addr_q;
	
	tx_func_apply_data 		<=	tx_func_apply_data_i;	
	tx_func_apply_data_i	<= 	not(ram_we or tx_func_sending or tx_fifo_empty_i);
--	tx_func_apply_data_i	<= 	'1' when ram_we = '0' and tx_func_sending = '0' and tx_fifo_empty_i = '0' else
--								'0';

	tx_fifo_empty			<= 	tx_fifo_empty_i;
	tx_fifo_empty_i 		<= 	'0' when tx_entries_back_q /= max_fifo_entries else 
								'1';
	tx_fifo_full			<=	tx_fifo_full_i;
	tx_fifo_full_i			<=	'0' when tx_entries_back_q /= conv_std_logic_vector(0, address_width+1) else
								'1';

	tx_fifo_entries_free	<=	conv_std_logic_vector(0,7-address_width) & tx_entries_back_q;
	tx_entries_back_en		<=	reset or ram_we or tx_func_apply_data_i;
	tx_entries_back_d 		<= 	max_fifo_entries 		when reset = '1' else
								tx_entries_back_q - 1	when ram_we = '1' else 
								tx_entries_back_q + 1;-- 	when tx_func_apply_data_i = '1' else
								--tx_entries_back_q;

--------------------
-- Register Logic --
--------------------
	reg_control : process(clk, tx_entries_back_en, tx_out_addr_en, tx_in_addr_en, tx_entries_back_d, tx_out_addr_d, tx_in_addr_d)
	begin
		if rising_edge(clk) then			
			if tx_entries_back_en = '1' then
				tx_entries_back_q 	<= tx_entries_back_d;
			end if;
			
			if tx_out_addr_en = '1' then
				tx_out_addr_q 		<= tx_out_addr_d;
			end if;
			
			if tx_in_addr_en = '1' then
				tx_in_addr_q		<= tx_in_addr_d;
			end if;
		end if;
	end process reg_control;

-----------------------------------
-- RAM synchronous - single port --
-----------------------------------
	ram_control : process(clk, ram_we, ram_address, tx_data)
	begin
		if rising_edge(clk) then
			if ram_we = '1' then
				ram(conv_integer(ram_address)) <= tx_data;
			end if;
		end if;
	end process ram_control;
	tx_func_data <= ram(conv_integer(ram_address));
	
end architecture behaviour;	