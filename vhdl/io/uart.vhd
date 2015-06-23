--
--  Copyright 2000-2011 Martin Schoeberl <masca@imm.dtu.dk>,
--  All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
--    1. Redistributions of source code must retain the above copyright notice,
--       this list of conditions and the following disclaimer.
-- 
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
-- OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
-- NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
-- THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-- 
-- The views and conclusions contained in the software and documentation are
-- those of the authors and should not be interpreted as representing official
-- policies, either expressed or implied, of the copyright holder.
-- 


--
--	This file is an adapted version of the SimpCon UART (from JOP).
--	Simplify to have a one cycle read.
--
--	uart.vhd
--
--	8-N/E/O-1 serial interface
--	
--	wr, rd should be one cycle long => trde, rdrf goes 0 one cycle later
--
--	Author: Martin Schoeberl	martin@jopdesign.com
--

--	2000-12-02	first working version
--  history deleted
--	2011-06-02	simplify for Leros


--
--	The FIFO for read and write buffers
--
library ieee;
use ieee.std_logic_1164.all;

entity fifo_elem is

generic (width : integer);
port (
	clk		: in std_logic;
	reset	: in std_logic;

	din		: in std_logic_vector(width-1 downto 0);
	dout	: out std_logic_vector(width-1 downto 0);

	rd		: in std_logic;
	wr		: in std_logic;

	rd_prev	: out std_logic;
	full	: out std_logic
);
end fifo_elem;

architecture rtl of fifo_elem is

	signal buf		: std_logic_vector(width-1 downto 0);
	signal f		: std_logic;

begin

	dout <= buf;

process(clk, reset, f)

begin

	full <= f;

	if (reset='1') then

		buf <= (others => '0');
		f <= '0';
		rd_prev <= '0';

	elsif rising_edge(clk) then

		rd_prev <= '0';
		if f='0' then
			if wr='1' then
				rd_prev <= '1';
				buf <= din;
				f <= '1';
			end if;
		else
			if rd='1' then
				f <= '0';
			end if;
		end if;

	end if;

end process;

end rtl;

library ieee;
use ieee.std_logic_1164.all;

entity fifo is

generic (width : integer := 8; depth : integer := 4);
port (
	clk		: in std_logic;
	reset	: in std_logic;

	din		: in std_logic_vector(width-1 downto 0);
	dout	: out std_logic_vector(width-1 downto 0);

	rd		: in std_logic;
	wr		: in std_logic;

	empty	: out std_logic;
	full	: out std_logic
);
end fifo ;

architecture rtl of fifo is

component fifo_elem is

generic (width : integer);
port (
	clk		: in std_logic;
	reset	: in std_logic;

	din		: in std_logic_vector(width-1 downto 0);
	dout	: out std_logic_vector(width-1 downto 0);

	rd		: in std_logic;
	wr		: in std_logic;

	rd_prev	: out std_logic;
	full	: out std_logic
);
end component;

	signal r, w, rp, f	: std_logic_vector(depth-1 downto 0);
	type d_array is array (0 to depth-1) of std_logic_vector(width-1 downto 0);
	signal di, do		: d_array;
	
begin


	g1: for i in 0 to depth-1 generate

		f1: fifo_elem generic map (width)
			port map (clk, reset, di(i), do(i), r(i), w(i), rp(i), f(i));

		x: if i<depth-1 generate
			r(i) <= rp(i+1);
			w(i+1) <= f(i);
			di(i+1) <= do(i);
		end generate;

	end generate;

	di(0) <= din;
	dout <= do(depth-1);
	w(0) <= wr;
	r(depth-1) <= rd;

	full <= f(0);
	empty <= not f(depth-1);
	
end rtl;

--
--	The UART
-- this UART consumes 104 LCs!!! The original version
-- was way smaller - let's get it down again.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is

	generic (clk_freq : integer;
			 baud_rate : integer;
			 txf_depth : integer;
			 rxf_depth : integer);
	port (
		clk		: in std_logic;
		reset	: in std_logic;

-- SimpCon interface

		address		: in std_logic;
		wr_data		: in std_logic_vector(15 downto 0);
		rd, wr		: in std_logic;
		rd_data		: out std_logic_vector(15 downto 0);

		txd		: out std_logic;
		rxd		: in std_logic
		);
end uart;

architecture rtl of uart is

	component fifo is

		generic (width : integer; depth : integer);
		port (
			clk		: in std_logic;
			reset	: in std_logic;

			din		: in std_logic_vector(width-1 downto 0);
			dout	: out std_logic_vector(width-1 downto 0);

			rd		: in std_logic;
			wr		: in std_logic;

			empty	: out std_logic;
			full	: out std_logic
			);
	end component;

--
--	signals for uart connection
--
	signal ua_dout			: std_logic_vector(7 downto 0);
	signal ua_wr, tdre		: std_logic;
	signal ua_rd, rdrf		: std_logic;

	type uart_tx_state_type		is (s0, s1);
	signal uart_tx_state 		: uart_tx_state_type;

	signal tf_dout		: std_logic_vector(7 downto 0); -- fifo out
	signal tf_rd		: std_logic;
	signal tf_empty		: std_logic;
	signal tf_full		: std_logic;

	signal tsr			: std_logic_vector(9 downto 0); -- tx shift register

	signal tx_clk		: std_logic;


	type uart_rx_state_type		is (s0, s1, s2);
	signal uart_rx_state 		: uart_rx_state_type;

	signal rf_wr		: std_logic;
	signal rf_empty		: std_logic;
	signal rf_full		: std_logic;

	signal rxd_reg		: std_logic_vector(2 downto 0);
	signal rx_buf		: std_logic_vector(2 downto 0);	-- sync in, filter
	signal rx_d			: std_logic;					-- rx serial data
	
	signal rsr			: std_logic_vector(9 downto 0); -- rx shift register

	signal rx_clk		: std_logic;
	signal rx_clk_ena	: std_logic;
	
	constant clk16_cnt	: integer := (clk_freq/baud_rate+8)/16-1;
	

begin

	rd_data(15 downto 8) <= (others => '0');

-- This is a single cycle read, different from SimpCon	
process(address, rd, rdrf, tdre, ua_dout)
begin
	ua_rd <= '0';
	if address='0' then
		rd_data(7 downto 0) <= "000000" & rdrf & tdre;
	else
		rd_data(7 downto 0) <= ua_dout;
		if rd='1' then
			ua_rd <= rd;
		end if;
	end if;
end process;

	-- write is on address offset 1	
	ua_wr <= wr and address;

--
--	serial clock
--
	process(clk, reset)

		variable clk16		: integer range 0 to clk16_cnt;
		variable clktx		: unsigned(3 downto 0);
		variable clkrx		: unsigned(3 downto 0);

	begin
		if (reset='1') then
			clk16 := 0;
			clktx := "0000";
			clkrx := "0000";
			tx_clk <= '0';
			rx_clk <= '0';
			rx_buf <= "111";

		elsif rising_edge(clk) then

			rxd_reg(0) <= rxd;			-- to avoid setup timing error in Quartus
			rxd_reg(1) <= rxd_reg(0);
			rxd_reg(2) <= rxd_reg(1);

			if (clk16=clk16_cnt) then		-- 16 x serial clock
				clk16 := 0;
--
--	tx clock
--
				clktx := clktx + 1;
				if (clktx="0000") then
					tx_clk <= '1';
				else
					tx_clk <= '0';
				end if;
--
--	rx clock
--
				if (rx_clk_ena='1') then
					clkrx := clkrx + 1;
					if (clkrx="1000") then
						rx_clk <= '1';
					else
						rx_clk <= '0';
					end if;
				else
					clkrx := "0000";
				end if;
--
--	sync in filter buffer
--
				rx_buf(0) <= rxd_reg(2);
				rx_buf(2 downto 1) <= rx_buf(1 downto 0);
			else
				clk16 := clk16 + 1;
				tx_clk <= '0';
				rx_clk <= '0';
			end if;


		end if;

	end process;


--
--	transmit fifo
--
	tf: fifo generic map (8, txf_depth)
		port map (clk, reset, wr_data(7 downto 0), tf_dout, tf_rd, ua_wr, tf_empty, tf_full);

--
--	state machine for actual shift out
--
	process(clk, reset)

		variable i : integer range 0 to 11;

	begin
		

		if (reset='1') then
			uart_tx_state <= s0;
			tsr <= "1111111111";
			tf_rd <= '0';

		elsif rising_edge(clk) then

			case uart_tx_state is

				when s0 =>
					
					i := 0;
					if tf_empty='0' then
						uart_tx_state <= s1;
						-- is there a reason to start with a stop bit?
						tsr <= tf_dout & '0' & '1';
						tf_rd <= '1';
					end if; 

				when s1 =>
					tf_rd <= '0';
					if (tx_clk='1') then
						tsr(9) <= '1';
						tsr(8 downto 0) <= tsr(9 downto 1);
						i := i+1;
						if i=11 then
							uart_tx_state <= s0;
						end if;
						
					end if;
					
			end case;
			
		end if;

	end process;

	txd <= tsr(0);
	tdre <= not tf_full;

--
--	receive fifo
--
	rf: fifo generic map (8, rxf_depth)
		port map (clk, reset, rsr(8 downto 1), ua_dout, ua_rd, rf_wr, rf_empty, rf_full);

	rdrf <= not rf_empty;

--
--	filter rxd
--
-- TODO: this is not really needed and should go away
-- just do a dual FF synchronizer
--
	with rx_buf select
		rx_d <=	'0' when "000",
		'0' when "001",
		'0' when "010",
		'1' when "011",
		'0' when "100",
		'1' when "101",
		'1' when "110",
		'1' when "111",
		'X' when others;

--
--	state machine for actual shift in
--
	process(clk, reset)

		variable i : integer range 0 to 10;

	begin

		if (reset='1') then
			uart_rx_state <= s0;
			rsr <= "0000000000";
			rf_wr <= '0';
			rx_clk_ena <= '0';

		elsif rising_edge(clk) then

			case uart_rx_state is


				when s0 =>
					i := 0;
					rf_wr <= '0';
					if (rx_d='0') then
						rx_clk_ena <= '1';
						uart_rx_state <= s1;
					else
						rx_clk_ena <= '0';
					end if;

				when s1 =>
					if (rx_clk='1') then
						rsr(9) <= rx_d;
						rsr(8 downto 0) <= rsr(9 downto 1);
						i := i+1;

						if i=10 then
							uart_rx_state <= s2;
						end if;
					end if;
					
				when s2 =>
					rx_clk_ena <= '0';
					
					if rsr(0)='0' and rsr(9)='1' then						
						if rf_full='0' then				-- if full just drop it
							rf_wr <= '1';
						end if;
					end if;
					
					uart_rx_state <= s0;

			end case;
		end if;

	end process;

end rtl;
