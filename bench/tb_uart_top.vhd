library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.wb_pack.all;

entity tb_uart_top is
end tb_uart_top;

architecture behaviour of tb_uart_top is	
	component uart_top is
	generic(address_width : integer := 3);
	port(	clk, master_rst		: in std_logic;
		
			RST_I				: in std_logic;
			
			ADR_I 				: in std_logic_vector(7 downto 0);
			DAT_I				: in std_logic_vector(7 downto 0);
			WE_I				: in std_logic;
			STB_I				: in std_logic;
			CYC_I				: in std_logic;
			DAT_O				: out std_logic_vector(7 downto 0);
			ACK_O				: out std_logic;
			
			rx					: in std_logic;
			tx					: out std_logic;
			
			rx_fifo_empty		: out std_logic;
			rx_fifo_full		: out std_logic;
			tx_fifo_empty		: out std_logic;
			tx_fifo_full		: out std_logic;
			parity_error		: out std_logic;
			stop_bit_error		: out std_logic;
			transmitting		: out std_logic);
	end component;

	constant clk_period : time := 2 ns;	-- 50MHz
	signal clk, RST_I : std_logic;
	signal txrx : std_logic;
	signal rx_fifo_empty, rx_fifo_full, tx_fifo_empty, tx_fifo_full : std_logic;

	signal ADR_I, DAT_I, DAT_O : std_logic_vector(7 downto 0);
	signal WE_I, STB_I, CYC_I, ACK_O : std_logic;
	
	type expected_output_buf_type is array (0 to 500) of std_logic_vector(7 downto 0);
	signal expected_output : expected_output_buf_type;
	signal index_in, index_in1, index_out : integer := 0;
	signal expected : std_logic_vector(7 downto 0);
	
	signal sim_word_width		: std_logic_vector(3 downto 0);
	signal sim_stop_bits		: std_logic_vector(1 downto 0);
	signal sim_idle_line_lvl, sim_use_parity_bit, sim_parity_type : std_logic;
	signal sim_baud_period 		: std_logic_vector(15 downto 0);
	signal master_rst : std_logic;
	
	signal wb_master_in		: wb_master_in_type;
	signal wb_master_out 	: wb_master_out_type;


begin

	uut : uart_top generic map (3) port map (clk, master_rst, RST_I, ADR_I, DAT_I, WE_I, STB_I, CYC_I, DAT_O, ACK_O, txrx, txrx, rx_fifo_empty, rx_fifo_full, tx_fifo_empty, tx_fifo_full);

	wb_naive_connect(CYC_I, STB_I, ACK_O, WE_I, ADR_I, DAT_I, DAT_O, wb_master_in, wb_master_out);

	read_write : process
		variable wb_read_data		: natural;
	begin	
		wait until master_rst = '1';
		wb_reset(clk, wb_master_out);
		wait until master_rst = '0';
		
		--RX_Enable
		wb_read(clk, 1, wb_read_data, wb_master_in, wb_master_out);
		assert wb_read_data = 0
			report "wrong reset value"
				severity error;
		wb_confirme_write(clk, 1, 1, wb_master_in, wb_master_out);
		
		--send 01100110
		wb_read(clk,3,wb_read_data, wb_master_in, wb_master_out);
		while wb_read_data /= 0 loop
			wb_write(clk, 0, 110, wb_master_in, wb_master_out);
			wb_read(clk,3,wb_read_data, wb_master_in, wb_master_out);
		end loop;
		
		wait until falling_edge(rx_fifo_empty);
		wb_read(clk, 0, wb_read_data, wb_master_in, wb_master_out);
		assert wb_read_data = 110
			report "wrong data recieved"
				severity error;
		
		wait;
	end process;
	
	
	RST_I				<= '0';
	sim_use_parity_bit	<= '0';
	sim_parity_type		<= '0';
	sim_stop_bits		<= "01";
	sim_word_width		<= "1000";
	sim_idle_line_lvl	<= '1';
	sim_baud_period <= "0000000000010000";

	clk_process : process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2; 
	end process;

	rst_process : process
	begin
		master_rst <= '0';
		wait for 1 ns;
		master_rst <= '1';
		wait for 5 ns;
		master_rst <= '0';
		wait;
	end process;
	
	expected_output_buffer : process
	begin
		wait until master_rst = '1';
		wait until master_rst = '0';
		
		while true loop
			wait until CYC_I = '1' and WE_I = '1' and ADR_I = "00000000";
			wait for 0.1 ns;
			while CYC_I = '1' and WE_I = '1' and ADR_I = "00000000" loop
				expected_output(index_in) <= DAT_I;
				index_in <= index_in + 1;
				wait for 2 ns;
			end loop;
		end loop; 
	end process;
	
	signal_intregrity_process : process
	begin
		wait until master_rst = '1';
		wait until master_rst = '0';
		
		--check each signal send
		while true loop
		
			--wait for start bit
			wait until txrx = not sim_idle_line_lvl;
			expected <= expected_output(index_out);
			index_out <= index_out + 1;
			
			wait for 3 ns;
			
			--bit 0
			wait for clk_period * conv_integer(sim_baud_period);	--wait a bit for next bits
			assert txrx = expected(0) report "wrong data bit0" severity error;
			
			--bit 1
			wait for clk_period * conv_integer(sim_baud_period);	--wait a bit for next bits
			assert txrx = expected(1) report "wrong data bit1" severity error;
			
			--bit 2
			wait for clk_period * conv_integer(sim_baud_period);	--wait a bit for next bits
			assert txrx = expected(2) report "wrong data bit2" severity error;
	
			--bit 3
			wait for clk_period * conv_integer(sim_baud_period);	--wait a bit for next bits
			assert txrx = expected(3) report "wrong data bit3" severity error;

			--bit 4
			wait for clk_period * conv_integer(sim_baud_period);	--wait a bit for next bits
			assert txrx = expected(4) report "wrong data bit4" severity error;
			
			if sim_word_width > "0101" then
				--bit 5
				wait for clk_period * conv_integer(sim_baud_period);	--wait a bit for next bits
				assert txrx = expected(5) report "wrong data bit5" severity error;
				
				if sim_word_width > "0110" then
					--bit 6
					wait for clk_period * conv_integer(sim_baud_period);	--wait a bit for next bits
					assert txrx = expected(6) report "wrong data bit6" severity error;
				
					if sim_word_width > "0111" then	
						--bit 7
						wait for clk_period * conv_integer(sim_baud_period);	--wait a bit for next bits
						assert txrx = expected(7) report "wrong data bit7" severity error;
					end if;
				end if;
			end if;
			
			if sim_use_parity_bit = '1' then
				--bit party_bit
				wait for clk_period * conv_integer(sim_baud_period);	--wait a bit for next bits
				assert txrx = expected(1) report "wrong parity bit" severity error;
			end if;
			
			--stop bit 1
			wait for clk_period * conv_integer(sim_baud_period);	--wait a bit for next bits
			assert txrx = sim_idle_line_lvl report "wrong stop bit1" severity error;

			if sim_stop_bits = "10" then
				--stop bit 2
				wait for clk_period * conv_integer(sim_baud_period);	--wait a bit for next bits
				assert txrx = sim_idle_line_lvl report "wrong stop bit2" severity error;
			end if;
		end loop;
	end process;
	
end behaviour;