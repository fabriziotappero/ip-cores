--
--  Wishbone bus toolkit.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--
-- ELEMENTS:
--   wb_ram: ram element.

-------------------------------------------------------------------------------
--
--  wb_ram
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library wb_tk;
use wb_tk.technology.all;

entity wb_ram is
	generic (
		dat_width: positive := 8;
		adr_width: positive := 10
	);
	port (
		clk_i: in std_logic;
--		rst_i: in std_logic := '0';
		adr_i: in std_logic_vector (adr_width-1 downto 0);
--		sel_i: in std_logic_vector ((dat_width/8)-1 downto 0) := (others => '1');
		dat_i: in std_logic_vector (dat_width-1 downto 0);
		dat_oi: in std_logic_vector (dat_width-1 downto 0) := (others => '-');
		dat_o: out std_logic_vector (dat_width-1 downto 0);
		cyc_i: in std_logic;
		ack_o: out std_logic;
		ack_oi: in std_logic := '-';
--		err_o: out std_logic;
--		err_oi: in std_logic := '-';
--		rty_o: out std_logic;
--		rty_oi: in std_logic := '-';
		we_i: in std_logic;
		stb_i: in std_logic
	);
end wb_ram;

architecture wb_ram of wb_ram is
	signal mem_stb: std_logic;
	signal mem_dat_o: std_logic_vector(dat_width-1 downto 0);
	signal mem_ack: std_logic;
begin
	mem_stb <= stb_i and cyc_i;
	tech_ram: spmem
		generic map (
			default_out => 'X',
			default_content => '0',
			adr_width   => adr_width,
			dat_width   => dat_width,
			async_read  => true
		)
		port map (
			stb_i    => mem_stb,
			clk_i    => clk_i,
--			reset    => '0',
			adr_i    => adr_i,
			dat_i    => dat_i,
			dat_o    => mem_dat_o,
			we_i     => we_i
		);

	dat_o_gen: for i in dat_o'RANGE generate
		dat_o(i) <= (mem_dat_o(i) and stb_i and cyc_i and not we_i) or (dat_oi(i) and not (stb_i and cyc_i and not we_i));
	end generate;
	ack_o <= (mem_ack and stb_i and cyc_i) or (ack_oi and not (stb_i and cyc_i));
end wb_ram;

