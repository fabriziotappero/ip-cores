--
--  Wishbone bus toolkit.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--
-- ELEMENTS:
--   wb_async_master: async bus master to Wishbone bus bridge.

-------------------------------------------------------------------------------
--
--  wb_async_master
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library wb_tk;
use wb_tk.technology.all;

entity wb_async_master is
	generic (
		width: positive := 16;
		addr_width: positive := 20
	);
	port (
		clk_i: in std_logic;
		rst_i: in std_logic := '0';
		
		-- interface to wb slave devices
		s_adr_o: out std_logic_vector (addr_width-1 downto 0);
		s_sel_o: out std_logic_vector ((width/8)-1 downto 0);
		s_dat_i: in std_logic_vector (width-1 downto 0);
		s_dat_o: out std_logic_vector (width-1 downto 0);
		s_cyc_o: out std_logic;
		s_ack_i: in std_logic;
		s_err_i: in std_logic := '-';
		s_rty_i: in std_logic := '-';
		s_we_o: out std_logic;
		s_stb_o: out std_logic;

		-- interface to asyncron master device
		a_data: inout std_logic_vector (width-1 downto 0) := (others => 'Z');
		a_addr: in std_logic_vector (addr_width-1 downto 0) := (others => 'U');
		a_rdn: in std_logic := '1';
		a_wrn: in std_logic := '1';
		a_cen: in std_logic := '1';
		a_byen: in std_logic_vector ((width/8)-1 downto 0);
		a_waitn: out std_logic
	);
end wb_async_master;

architecture wb_async_master of wb_async_master is
	component d_ff
		port (  d  :  in STD_LOGIC;
				clk:  in STD_LOGIC;
		        ena:  in STD_LOGIC := '1';
		        clr:  in STD_LOGIC := '0';
		        pre:  in STD_LOGIC := '0';
				q  :  out STD_LOGIC
		);
	end component;
	signal wg_clk, wg_pre, wg_q: std_logic;
	signal i_cyc_o, i_stb_o, i_we_o: std_logic;
	signal i_waitn: std_logic;
begin
	ctrl: process is
	begin
		wait until clk_i'EVENT and clk_i = '1';
		if (rst_i = '1') then
			i_cyc_o <= '0';
			i_stb_o <= '0';
			i_we_o <= '0';
		else
			if (a_cen = '0') then
			 	i_stb_o <= not (a_rdn and a_wrn);
				i_we_o <= not a_wrn;
				i_cyc_o <= '1';
			else
				i_cyc_o <= '0';
				i_stb_o <= '0';
				i_we_o <= '0';
			end if;
		end if;
	end process;
	s_cyc_o <= i_cyc_o and not i_waitn;
	s_stb_o <= i_stb_o and not i_waitn;
	s_we_o <= i_we_o and not i_waitn;

	w_ff1: d_ff port map (
		d => s_ack_i,
		clk => clk_i,
		ena => '1',
		clr => rst_i,
		pre => '0',
		q => wg_q
	);
	
	wg_clk <= not a_cen;
	wg_pre <= wg_q or rst_i;
	w_ff2: d_ff port map (
		d => '0',
		clk => wg_clk,
		ena => '1',
		clr => '0',
		pre => wg_pre,
		q => i_waitn
	);
	a_waitn <= i_waitn;

	s_adr_o <= a_addr;
	negate: for i in s_sel_o'RANGE generate s_sel_o(i) <= not a_byen(i); end generate;
	s_dat_o <= a_data;

	a_data_out: process is
	begin
		wait on s_dat_i, a_rdn, a_cen;
		if (a_rdn = '0' and a_cen = '0') then
			a_data <= s_dat_i;
		else
			a_data <= (others => 'Z');
		end if;
	end process;
end wb_async_master;

