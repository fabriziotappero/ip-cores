library ieee,wb_tk,wb_vga;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
use wb_tk.technology.all;
use wb_tk.wb_test.all;
use wb_tk.all;
use wb_vga.all;

entity wb_pal_ram_tb is
	generic(
		cpu_dat_width: positive := 32;
		cpu_adr_width: positive := 8;
		v_dat_width: positive := 16;
		v_adr_width: positive := 8
    );
end wb_pal_ram_tb;

architecture TB of wb_pal_ram_tb is
	component wb_pal_ram
    	generic (
    		cpu_dat_width: positive := cpu_dat_width;
    		cpu_adr_width: positive := cpu_adr_width;
    		v_dat_width: positive := v_dat_width;
    		v_adr_width: positive := v_adr_width
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
	end component;

-- Wishbone interface to CPU (write-only support)
	signal clk_i: std_logic;
	signal rst_i: std_logic := '0';
	signal adr_i: std_logic_vector (cpu_adr_width-1 downto 0);
	signal dat_i: std_logic_vector (cpu_dat_width-1 downto 0);
	signal dat_oi: std_logic_vector (cpu_dat_width-1 downto 0) := (others => '-');
	signal dat_o: std_logic_vector (cpu_dat_width-1 downto 0);
	signal cyc_i: std_logic;
	signal ack_o: std_logic;
	signal ack_oi: std_logic := '-';
	signal err_o: std_logic;
	signal err_oi: std_logic := '-';
	signal we_i: std_logic;
	signal stb_i: std_logic;
-- Interface to the video output
    signal blank: std_logic;
    signal v_dat_i: std_logic_vector(v_adr_width-1 downto 0);
    signal v_dat_o: std_logic_vector(v_dat_width-1 downto 0);
begin

	-- Unit Under Test port map
	UUT : wb_pal_ram
		port map (
        	clk_i => clk_i,
    		rst_i => rst_i,
    		adr_i => adr_i,
    		dat_i => dat_i,
    		dat_oi => dat_oi,
    		dat_o => dat_o,
    		cyc_i => cyc_i,
    		ack_o => ack_o,
    		ack_oi => ack_oi,
    		err_o => err_o,
    		err_oi => err_oi,
    		we_i => we_i,
    		stb_i => stb_i,

            blank => blank,
            v_dat_i => v_dat_i,
            v_dat_o => v_dat_o
        );

	clk: process is
	begin
		clk_i <= '0';
		wait for 25ns;
		clk_i <= '1';
		wait for 25ns;
	end process;
	
	reset: process is
	begin
		rst_i <= '1';
		wait for 150ns;
		rst_i <= '0';
		wait;
	end process;
	
	gen_v_output: process is
	    variable addr: std_logic_vector(v_adr_width-1 downto 0) := (others => '0');
	begin
	    blank <= '0';
	    wait until clk_i'EVENT and clk_i = '1';
	    v_dat_i <= addr;
--	    if (addr = "1111") then
--	        blank <= '1';
--		    wait until clk_i'EVENT and clk_i = '1';
--    	    addr := (v_adr_width'RANGE => '0');
--	    else
	        addr := add_one(addr);
--	    end if;
    end process;
	
	dat_oi <= (others => 'U');
	ack_oi <= 'U';
	err_oi <= 'U';
	
	master: process is
		variable i: integer := 0;
	    variable addr: std_logic_vector(cpu_adr_width-1 downto 0) := (others => '0');
	    variable data: std_logic_vector(cpu_dat_width-1 downto 0) := (others => '0');
	begin
		we_i <= '0';
		cyc_i <= '0';
		stb_i <= '0';
		adr_i <= (others => '0');
		dat_i <= (others => '0');
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';

        for i in 0 to 511 loop
		    wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,addr,data);
		    addr := add_one(addr);
		    data := add_one(data);
		end loop;
		wait;
	end process;
	
end TB;

configuration TB_wb_pal_ram of wb_pal_ram_tb is
	for TB
		for UUT : wb_pal_ram
			use entity wb_vga.wb_pal_ram(wb_pal_ram);
		end for;
	end for;
end TB_wb_pal_ram;	   

