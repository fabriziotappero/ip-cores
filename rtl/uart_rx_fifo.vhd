-----------------------------
-- rx_fifo
------------------------------
--  WB interface has the highest priority.
--	
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rx_fifo is
	generic(address_width : integer := 3);
	port(	clk, reset		: in std_logic;

			read_rx_data	: in  std_logic;
			rx_data 		: out std_logic_vector(7 downto 0);
			rx_fifo_full 	: out std_logic;
			rx_fifo_empty 	: out std_logic;
			rx_fifo_entries_free : out std_logic_vector(7 downto 0);

			rx_func_data		: in std_logic_vector(7 downto 0);
			rx_func_data_ready 	: in std_logic);
end entity rx_fifo;

architecture behaviour of rx_fifo is
	type ram_type is array (0 to 2**address_width-1) of std_logic_vector(7 downto 0);
	signal ram : ram_type;
	signal ram_we : std_logic;
	signal ram_address : std_logic_vector(address_width-1 downto 0);
	signal rx_in_addr_d, rx_out_addr_d : std_logic_vector(address_width-1 downto 0);
	signal rx_in_addr_q, rx_out_addr_q : std_logic_vector(address_width-1 downto 0) := (others => '0');
	
	signal rx_fifo_full_i, rx_fifo_empty_i : std_logic;
	
	constant max_fifo_entries : std_logic_vector(address_width downto 0) := conv_std_logic_vector(2**address_width, address_width+1);
	signal fifo_entries_back_q, fifo_entries_back_d : std_logic_vector(address_width downto 0);
	signal data_ready_q, data_ready_d : std_logic;
	
begin
-------------------------
-- Combinational Logic --
-------------------------
	ram_we					<=	'1' when read_rx_data = '0' and rx_fifo_full_i = '0' and data_ready_q = '1' else
								'0';
	data_ready_d			<=  not (reset or ram_we);
								--'0' when reset = '1' or ram_we = '1' else
								--'1';-- when rx_func_data_ready = '1' else	--taken care of by register enable
								--'0' when ram_we = '1' else
								--data_ready_q;
	ram_address				<=	rx_in_addr_q	when ram_we = '1' else
								rx_out_addr_q;
	rx_in_addr_d			<=	(others => '0') when reset = '1' else
								rx_in_addr_q + 1;-- when ram_we = '1' else	--taken care of by register enable
								--rx_in_addr_q;
	rx_out_addr_d			<=	(others => '0') when reset = '1' else		--taken care of by register enable
								rx_out_addr_q + 1;-- when rx_read = '1' else
								--rx_out_addr_q;
						


	rx_fifo_entries_free 	<=	conv_std_logic_vector(0, 7 - address_width) & fifo_entries_back_q;
	fifo_entries_back_d 	<=	max_fifo_entries 		when reset = '1' else
								fifo_entries_back_q + 1 when read_rx_data = '1' else
								fifo_entries_back_q - 1 when ram_we = '1' else		--taken care of by register enable
								fifo_entries_back_q;
	
	rx_fifo_full			<=	rx_fifo_full_i;
	rx_fifo_full_i 			<=	'1' when fifo_entries_back_q = conv_std_logic_vector(0, address_width+1) else
								'0';
	
	rx_fifo_empty			<=	rx_fifo_empty_i;
	rx_fifo_empty_i			<=	'1' when fifo_entries_back_q = max_fifo_entries else
								'0';
	

--------------------
-- Register Logic --
--------------------
	reg_control : process(clk)
	begin
		if rising_edge(clk) then
			--if reset = '1' or read_rx_data = '1' or ram_we = '1' then 
				fifo_entries_back_q <= fifo_entries_back_d;
			--end if;
			if reset = '1' or ram_we = '1' or rx_func_data_ready = '1' then
				data_ready_q <= data_ready_d;
			end if;
			if reset = '1' or ram_we = '1' then
				rx_in_addr_q <= rx_in_addr_d;
			end if;
			if reset = '1' or read_rx_data = '1' then
				rx_out_addr_q <= rx_out_addr_d;
			end if;
		end if;
	end process;


-----------------------------------
-- RAM synchronous - single port --
-----------------------------------
	ram_control : process(clk, ram_we, ram_address, rx_func_data)
	begin
		if rising_edge(clk) then
			if ram_we = '1' then
				ram(conv_integer(ram_address)) <= rx_func_data;
			end if;
		end if;
	end process ram_control;
	rx_data <= ram(conv_integer(ram_address));

end architecture behaviour;