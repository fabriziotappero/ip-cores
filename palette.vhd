--
--  Palette RAM.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

-------------------------------------------------------------------------------
--
--  wb_pal_ram
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library wb_tk;
use wb_tk.technology.all;
use wb_tk.all;

entity wb_pal_ram is
	generic (
		cpu_dat_width: positive := 8;
		cpu_adr_width: positive := 9;
		v_dat_width: positive := 16;
		v_adr_width: positive := 8
	);
	port (
-- Wishbone interface to CPU (write-only support)
    	clk_i: in std_logic;
		rst_i: in std_logic := '0';
		adr_i: in std_logic_vector (cpu_adr_width-1 downto 0);
--		sel_i: in std_logic_vector ((cpu_dat_width/8)-1 downto 0) := (others => '1');
		dat_i: in std_logic_vector (cpu_dat_width-1 downto 0);
		dat_oi: in std_logic_vector (cpu_dat_width-1 downto 0) := (others => '-');
		dat_o: out std_logic_vector (cpu_dat_width-1 downto 0);
		cyc_i: in std_logic;
		ack_o: out std_logic;
		ack_oi: in std_logic := '-';
		err_o: out std_logic;
		err_oi: in std_logic := '-';
--		rty_o: out std_logic;
--		rty_oi: in std_logic := '-';
		we_i: in std_logic;
		stb_i: in std_logic;
-- Interface to the video output
        blank: in std_logic;
        v_dat_i: in std_logic_vector(v_adr_width-1 downto 0);
        v_dat_o: out std_logic_vector(v_dat_width-1 downto 0)
	);
end wb_pal_ram;

architecture wb_pal_ram of wb_pal_ram is
    component dpram
    	generic (
    		data_width : positive;
    		addr_width : positive
    	);
    	port (
    		clk : in std_logic;
    
    		r_d_out : out std_logic_vector(data_width-1 downto 0);
    		r_rd : in std_logic;
    		r_clk_en : in std_logic;
    		r_addr : in std_logic_vector(addr_width-1 downto 0);
    
    		w_d_in : in std_logic_vector(data_width-1 downto 0);
    		w_wr : in std_logic;
    		w_clk_en : in std_logic;
    		w_addr : in std_logic_vector(addr_width-1 downto 0)
    	);
    end component;

	component wb_out_reg
	generic (
		width : positive := 8;
		bus_width: positive := 8;
		offset: integer := 0
	);
	port (
		clk_i: in std_logic;
		rst_i: in std_logic;
		rst_val: std_logic_vector(width-1 downto 0) := (others => '0');

        cyc_i: in std_logic := '1';
		stb_i: in std_logic;
        sel_i: in std_logic_vector ((bus_width/8)-1 downto 0) := (others => '1');
		we_i: in std_logic;
		ack_o: out std_logic;
		ack_oi: in std_logic := '-';
		adr_i: in std_logic_vector (size2bits((width+offset+bus_width-1)/bus_width)-1 downto 0) := (others => '0');
		dat_i: in std_logic_vector (bus_width-1 downto 0);
		dat_oi: in std_logic_vector (bus_width-1 downto 0) := (others => '-');
		dat_o: out std_logic_vector (bus_width-1 downto 0);
		q: out std_logic_vector (width-1 downto 0)
	);
	end component;
	
	signal mem_we: std_logic;
	signal mem_rd: std_logic;
	signal mem_d_in: std_logic_vector(v_dat_width-1 downto 0);
	signal ext_reg_stb: std_logic;
	signal mem_stb: std_logic;
    signal mem_d_out: std_logic_vector(v_dat_width-1 downto 0);
begin
    mem_stb_gen1: if (cpu_dat_width < v_dat_width) generate
        mem_stb <= '1' WHEN adr_i(cpu_adr_width-v_adr_width-1 downto 0)=(cpu_adr_width-v_adr_width-1 downto 0 =>'1') ELSE '0';
    end generate;
    mem_stb_gen2: if (cpu_dat_width >= v_dat_width) generate
        mem_stb <= '1';
    end generate;
    mem_we <= we_i and stb_i and cyc_i and mem_stb;
    mem_rd <= not blank;
    mem_d_in_gen1: if (cpu_dat_width < v_dat_width) generate
        mem_d_in(v_dat_width-1 downto v_dat_width-cpu_dat_width) <= dat_i;
    end generate;
    mem_d_in_gen2: if (cpu_dat_width >= v_dat_width) generate
        mem_d_in(v_dat_width-1 downto 0) <= dat_i(mem_d_in'RANGE);
    end generate;
    tech_ram: dpram
    	generic map(
    		data_width => v_dat_width,
    		addr_width => v_adr_width
    	)
    	port map (
    		clk => clk_i,
    
    		r_d_out => mem_d_out,
    		r_rd => mem_rd,
    		r_clk_en => '1',
    		r_addr => v_dat_i,
    
    		w_d_in => mem_d_in,
    		w_wr => mem_we,
    		w_clk_en => '1',
    		w_addr => adr_i(cpu_adr_width-1 downto cpu_adr_width-v_adr_width)
    	);
    v_dat_o_gen: for i in v_dat_o'RANGE generate
        v_dat_o(i) <= mem_d_out(i) and not blank;
    end generate;

    ext_reg_stb <= we_i and stb_i and cyc_i and not mem_stb;
    ext_reg_gen: if (cpu_dat_width < v_dat_width) generate
        ext_reg: wb_out_reg
            generic map (
    			width => v_dat_width-cpu_dat_width,
    			bus_width => cpu_dat_width,
    			offset => 0
    		)
    		port map (
    			clk_i => clk_i,
    			rst_i => rst_i,
    	
    	        cyc_i => cyc_i,
    			stb_i => ext_reg_stb,
    			we_i => we_i,
--    			ack_o
    			adr_i => adr_i(cpu_adr_width-v_adr_width-1 downto 0),
    			dat_i => dat_i,
    			q => mem_d_in(v_dat_width-cpu_dat_width-1 downto 0)
    		);
    end generate;
        
    dat_o <= dat_oi;
    ack_o <= (     we_i  and (stb_i and cyc_i)) or (ack_oi and not (stb_i and cyc_i));
    err_o <= ((not we_i) and (stb_i and cyc_i)) or (err_oi and not (stb_i and cyc_i));
end wb_pal_ram;

