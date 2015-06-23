--
--  Horizontal and vertical sync generator.
--
--  (c) Copyright Andras Tantos <tantos@opencores.org> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

library IEEE;
use IEEE.std_logic_1164.all;

entity hv_sync is
	port (
		clk: in std_logic;
		pix_clk_en: in std_logic := '1';
		reset: in std_logic := '0';

		hbs: in std_logic_vector(7 downto 0);
		hss: in std_logic_vector(7 downto 0);
		hse: in std_logic_vector(7 downto 0);
		htotal: in std_logic_vector(7 downto 0);
		vbs: in std_logic_vector(7 downto 0);
		vss: in std_logic_vector(7 downto 0);
		vse: in std_logic_vector(7 downto 0);
		vtotal: in std_logic_vector(7 downto 0);

		h_sync: out std_logic;
		h_blank: out std_logic;
		v_sync: out std_logic;
		v_blank: out std_logic;
		h_tc: out std_logic;
		v_tc: out std_logic;
		blank: out std_logic
	);
end hv_sync;

architecture hv_sync of hv_sync is
	component sync_gen
		port (
			clk: in std_logic;
			clk_en: in std_logic;
			reset: in std_logic := '0';
	
			bs: in std_logic_vector(7 downto 0);
			ss: in std_logic_vector(7 downto 0);
			se: in std_logic_vector(7 downto 0);
			total: in std_logic_vector(7 downto 0);
	
			sync: out std_logic;
			blank: out std_logic;
			tc: out std_logic;
			
			count: out std_logic_vector (7 downto 0)
		);
	end component;
	signal h_blank_i: std_logic;
	signal v_blank_i: std_logic;
	signal h_tc_i: std_logic;
	signal hcen: std_logic;
	signal vcen: std_logic;

	constant h_pre_div_factor: integer := 3;
	constant v_pre_div_factor: integer := 3;
	subtype h_div_var is integer range 0 to h_pre_div_factor;
	subtype v_div_var is integer range 0 to v_pre_div_factor;

begin
	
	h_pre_div : process is
		variable cntr: h_div_var;
	begin
		wait until clk'EVENT and clk='1';
		if (reset = '1') then
			cntr := 0;
			hcen <= '0';
		else
			if (pix_clk_en='1') then
				if (cntr = h_pre_div_factor) then
					cntr := 0;
					hcen <= '1';
				else
					cntr := cntr+1;
					hcen <= '0';
				end if;
			else
				hcen <= '0';
			end if;
		end if;
	end process;

	h_sync_gen : sync_gen
		port map (
			clk => clk,
			clk_en => hcen,
			reset => reset,
	
			bs => hbs,
			ss => hss,
			se => hse,
			total => htotal,
	
			sync => h_sync,
			blank => h_blank_i,
			tc => h_tc_i
		);

	h_tc <= h_tc_i;

	v_pre_div : process is
		variable cntr: v_div_var;
	begin
		wait until clk'EVENT and clk='1';
		if (reset = '1') then
			cntr := 0;
			vcen <= '0';
		else
			if (h_tc_i='1') then
				if (cntr = v_pre_div_factor) then
					cntr := 0;
					vcen <= '1';
				else
					cntr := cntr+1;
					vcen <= '0';
				end if;
			else
				vcen <= '0';
			end if;
		end if;
	end process;

	v_sync_gen : sync_gen
		port map (
			clk => clk,
			clk_en => vcen,
			reset => reset,
	
			bs => vbs,
			ss => vss,
			se => vse,
			total => vtotal,
	
			sync => v_sync,
			blank => v_blank_i,
			tc => v_tc
		);

	blank <= h_blank_i or v_blank_i;
	h_blank <= h_blank_i;
	v_blank <= v_blank_i;
end hv_sync;
