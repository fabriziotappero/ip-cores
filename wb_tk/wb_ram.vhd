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
		data_width: positive := 8;
		addr_width: positive := 10
	);
	port (
    	clk_i: in std_logic;
--		rst_i: in std_logic := '0';
		adr_i: in std_logic_vector (addr_width-1 downto 0);
--		sel_i: in std_logic_vector ((bus_width/8)-1 downto 0) := (others => '1');
		dat_i: in std_logic_vector (data_width-1 downto 0);
		dat_oi: in std_logic_vector (data_width-1 downto 0) := (others => '-');
		dat_o: out std_logic_vector (data_width-1 downto 0);
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
	component ram 
		generic (
			data_width : positive;
			addr_width : positive
		);
		port (
			clk : in std_logic;
			we : in std_logic;
			addr : in std_logic_vector(addr_width-1 downto 0);
			d_in : in std_logic_vector(data_width-1 downto 0);
			d_out : out std_logic_vector(data_width-1 downto 0)
		);
	end component;
	
	signal mem_we: std_logic;
	signal mem_dat_o: std_logic_vector(data_width-1 downto 0);
begin
    mem_we <= we_i and stb_i and cyc_i;
    tech_ram: ram
        generic map (
            data_width => data_width,
            addr_width => addr_width
        )
        port map (
            clk => clk_i,
            we => mem_we,
            addr => adr_i,
            d_in => dat_i,
            d_out => mem_dat_o
        );
        
    dat_o_gen: for i in dat_o'RANGE generate
        dat_o(i) <= (mem_dat_o(i) and stb_i and cyc_i and not we_i) or (dat_oi(i) and not (stb_i and cyc_i and not we_i));
    end generate;
    ack_o <= ('1' and stb_i and cyc_i) or (ack_oi and not (stb_i and cyc_i));
end wb_ram;

