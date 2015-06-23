--
--  File: vga_chip.vhd
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

library IEEE;
use IEEE.std_logic_1164.all;

package constants is
    constant v_dat_width: positive := 16;
    constant v_adr_width : positive := 20;
    constant cpu_dat_width: positive := 32;
    constant cpu_adr_width: positive := 19;
    constant reg_adr_width: positive := 5;
    constant fifo_size: positive := 256;
--	constant addr_diff: integer := log2(cpu_dat_width/v_dat_width);
end constants;

library IEEE;
use IEEE.std_logic_1164.all;

library wb_vga;
use wb_vga.all;
use wb_vga.constants.all;

library wb_tk;
use wb_tk.all;
use wb_tk.technology.all;


-- same as VGA_CORE but without generics. Suited for post-layout simulation.
entity vga_chip is
	port (
		clk_i: in std_logic;
		clk_en: in std_logic := '1';
		rstn: in std_logic := '1';

		-- CPU bus interface
		data: inout std_logic_vector (cpu_dat_width-1 downto 0) := (others => 'Z');
		addr: in std_logic_vector (cpu_adr_width-1 downto 0) := (others => 'U');
		rdn: in std_logic := '1';
		wrn: in std_logic := '1';
		vmem_cen: in std_logic := '1';
		reg_cen: in std_logic := '1';
		byen: in std_logic_vector ((cpu_dat_width/8)-1 downto 0);
		waitn: out std_logic;

		-- video memory SRAM interface
		s_data : inout std_logic_vector(v_dat_width-1 downto 0);
		s_addr : out std_logic_vector(v_adr_width-1 downto 0);
		s_oen : out std_logic;
		s_wrhn : out std_logic;
		s_wrln : out std_logic;
		s_cen : out std_logic;

		-- sync blank and video signal outputs
		h_sync: out std_logic;
		h_blank: out std_logic;
		v_sync: out std_logic;
		v_blank: out std_logic;
		h_tc: out std_logic;
		v_tc: out std_logic;
		blank: out std_logic;
		video_out: out std_logic_vector (7 downto 0)   -- video output binary signal (unused bits are forced to 0)
	);
end vga_chip;

architecture vga_chip of vga_chip is
	component wb_async_slave
	generic (
		width: positive := 16;
		addr_width: positive := 20
	);
	port (
		clk_i: in std_logic;
		rst_i: in std_logic := '0';

		-- interface for wait-state generator state-machine
		wait_state: in std_logic_vector (3 downto 0);

		-- interface to wishbone master device
		adr_i: in std_logic_vector (addr_width-1 downto 0);
		sel_i: in std_logic_vector ((addr_width/8)-1 downto 0);
		dat_i: in std_logic_vector (width-1 downto 0);
		dat_o: out std_logic_vector (width-1 downto 0);
		dat_oi: in std_logic_vector (width-1 downto 0) := (others => '-');
		we_i: in std_logic;
		stb_i: in std_logic;
		ack_o: out std_logic := '0';
		ack_oi: in std_logic := '-';

		-- interface to async slave
		a_data: inout std_logic_vector (width-1 downto 0) := (others => 'Z');
		a_addr: out std_logic_vector (addr_width-1 downto 0) := (others => 'U');
		a_rdn: out std_logic := '1';
		a_wrn: out std_logic := '1';
		a_cen: out std_logic := '1';
		-- byte-enable signals
		a_byen: out std_logic_vector ((width/8)-1 downto 0)
	);
	end component;

    component wb_async_master
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
    end component;

	component vga_core
    	generic (
    		v_dat_width: positive := 16;
    		v_adr_width : positive := 20;
    		cpu_dat_width: positive := 16;
    		cpu_adr_width: positive := 20;
    		reg_adr_width: positive := 20;
    		fifo_size: positive := 256
    	);
    	port (
    		clk_i: in std_logic;
    		clk_en: in std_logic := '1';
    		rst_i: in std_logic := '0';
    
    		-- CPU memory bus interface
    		vmem_cyc_i: in std_logic;
    		vmem_we_i: in std_logic;
    		vmem_stb_i: in std_logic;   -- selects video memory
    		vmem_ack_o: out std_logic;
    		vmem_ack_oi: in std_logic;
    		vmem_adr_i: in std_logic_vector (cpu_adr_width-1 downto 0);
            vmem_sel_i: in std_logic_vector ((cpu_dat_width/8)-1 downto 0) := (others => '1');
    		vmem_dat_i: in std_logic_vector (cpu_dat_width-1 downto 0);
    		vmem_dat_oi: in std_logic_vector (cpu_dat_width-1 downto 0);
    		vmem_dat_o: out std_logic_vector (cpu_dat_width-1 downto 0);
    
    		-- CPU register bus interface
    		reg_cyc_i: in std_logic;
    		reg_we_i: in std_logic;
        	reg_stb_i: in std_logic;    -- selects configuration registers
    		reg_ack_o: out std_logic;
    		reg_ack_oi: in std_logic;
    		reg_adr_i: in std_logic_vector (reg_adr_width-1 downto 0);
            reg_sel_i: in std_logic_vector ((cpu_dat_width/8)-1 downto 0) := (others => '1');
    		reg_dat_i: in std_logic_vector (cpu_dat_width-1 downto 0);
    		reg_dat_oi: in std_logic_vector (cpu_dat_width-1 downto 0);
    		reg_dat_o: out std_logic_vector (cpu_dat_width-1 downto 0);
    
    		-- video memory interface
    		v_adr_o: out std_logic_vector (v_adr_width-1 downto 0);
    		v_sel_o: out std_logic_vector ((v_dat_width/8)-1 downto 0);
    		v_dat_i: in std_logic_vector (v_dat_width-1 downto 0);
    		v_dat_o: out std_logic_vector (v_dat_width-1 downto 0);
    		v_cyc_o: out std_logic;
    		v_ack_i: in std_logic;
    		v_we_o: out std_logic;
    		v_stb_o: out std_logic;
    
    		-- sync blank and video signal outputs
    		h_sync: out std_logic;
    		h_blank: out std_logic;
    		v_sync: out std_logic;
    		v_blank: out std_logic;
    		h_tc: out std_logic;
    		v_tc: out std_logic;
    		blank: out std_logic;
    		video_out: out std_logic_vector (7 downto 0)  -- video output binary signal (unused bits are forced to 0)
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

    signal reg_ack_o: std_logic;
    signal reg_dat_o: std_logic_vector(cpu_dat_width-1 downto 0);

    signal reg_stb: std_logic;
    signal ws_stb: std_logic;
    signal wait_state: std_logic_vector(3 downto 0);

	signal v_adr_o: std_logic_vector (v_adr_width-1 downto 0);
	signal v_sel_o: std_logic_vector ((v_dat_width/8)-1 downto 0);
	signal v_dat_i: std_logic_vector (v_dat_width-1 downto 0);
	signal v_dat_o: std_logic_vector (v_dat_width-1 downto 0);
	signal v_cyc_o: std_logic;
	signal v_ack_i: std_logic;
	signal v_we_o: std_logic;
	signal v_stb_o: std_logic;

	signal s_byen : std_logic_vector((v_dat_width/8)-1 downto 0);
	
	signal ws_dat_o: std_logic_vector(cpu_dat_width-1 downto 0);
	signal ws_ack_o: std_logic;
	
	signal s_wrn: std_logic;


	signal dat_i: std_logic_vector (cpu_dat_width-1 downto 0);
	signal dat_oi: std_logic_vector (cpu_dat_width-1 downto 0);
	signal dat_o: std_logic_vector (cpu_dat_width-1 downto 0);
	signal cyc_i: std_logic;
	signal ack_o: std_logic;
	signal ack_oi: std_logic;
	signal we_i: std_logic;
	signal vmem_stb_i: std_logic;
	signal reg_stb_i: std_logic;
	signal adr_i: std_logic_vector (cpu_adr_width-1 downto 0);
	signal sel_i: std_logic_vector ((cpu_dat_width/8)-1 downto 0) := (others => '1');
	
	signal cen: std_logic;
	signal stb: std_logic;

    signal rst_i: std_logic := '0';

	constant vga_reg_size: integer := size2bits((32*8+cpu_dat_width-1)/cpu_dat_width);
begin
    rst_i <= not rstn;
    
	ws_reg: wb_out_reg
		generic map( width => 4, bus_width => cpu_dat_width , offset => 0 )
		port map(
    		stb_i => ws_stb,
    		q => wait_state,
    		rst_val => "1111",
    		dat_oi => dat_oi,
    		dat_o => ws_dat_o,
    		ack_oi => ack_oi,
    		ack_o => ws_ack_o,
    		adr_i => adr_i(0 downto 0), -- range should be calculated !!!
    		sel_i => sel_i, cyc_i => cyc_i, we_i => we_i, clk_i => clk_i, rst_i => rst_i, dat_i => dat_i );

	core : vga_core
    	generic map (
    		v_dat_width => v_dat_width,
    		v_adr_width => v_adr_width,
    		cpu_dat_width => cpu_dat_width,
    		cpu_adr_width => cpu_adr_width,
    		reg_adr_width => reg_adr_width,
    		fifo_size => fifo_size
    	)
		port map (
    		clk_i => clk_i,
		    clk_en => clk_en,
		    rst_i => rst_i,

    		-- CPU bus interface
    		vmem_cyc_i => cyc_i,
    		vmem_we_i => we_i,
    		vmem_stb_i => vmem_stb_i,
    		vmem_ack_o => ack_o,
    		vmem_ack_oi => reg_ack_o,
    		vmem_adr_i => adr_i,
            vmem_sel_i => sel_i,
    		vmem_dat_i => dat_i,
    		vmem_dat_oi => reg_dat_o,
    		vmem_dat_o => dat_o,
    
    		-- CPU register bus interface
    		reg_cyc_i => cyc_i,
    		reg_we_i => we_i,
        	reg_stb_i => reg_stb_i,
    		reg_ack_o => reg_ack_o,
    		reg_ack_oi => ack_oi,
    		reg_adr_i => adr_i(reg_adr_width-1 downto 0),
            reg_sel_i => sel_i,
    		reg_dat_i => dat_i,
    		reg_dat_oi => dat_oi,
    		reg_dat_o => reg_dat_o,
    

    		-- video memory interface
    		v_adr_o => v_adr_o,
    		v_sel_o => v_sel_o,
    		v_dat_i => v_dat_i,
    		v_dat_o => v_dat_o,
    		v_cyc_o => v_cyc_o,
    		v_ack_i => v_ack_i,
    		v_we_o => v_we_o,
    		v_stb_o => v_stb_o,

    		h_sync => h_sync,
		    h_blank => h_blank,
		    v_sync => v_sync,
		    v_blank => v_blank,
		    h_tc => h_tc,
		    v_tc => v_tc,
		    blank => blank,
    		video_out => video_out
		);

	mem_driver: wb_async_slave
	    generic map (width => v_dat_width, addr_width => v_adr_width)
	    port map (
    		clk_i => clk_i,
		    rst_i => rst_i,

    		wait_state => wait_state,

    		adr_i => v_adr_o,
			sel_i => v_sel_o,
    		dat_o => v_dat_i,
    		dat_i => v_dat_o,
--    		dat_oi => (others => '0'),
    		we_i => v_we_o,
    		stb_i => v_stb_o,
    		ack_o => v_ack_i,
    		ack_oi => '0',

    		a_data => s_data,
    		a_addr => s_addr,
    		a_rdn => s_oen,
    		a_wrn => s_wrn,
    		a_cen => s_cen,
    		a_byen => s_byen
	    );

	s_wrln <= s_wrn or s_byen(0);
	s_wrhn <= s_wrn or s_byen(1);

    master: wb_async_master
    	generic map (
    		width => cpu_dat_width,
    		addr_width => cpu_adr_width
    	)
    	port map (
    		clk_i => clk_i,
    		rst_i => rst_i,
    		
    		-- interface to wb slave devices
    		s_adr_o => adr_i,
    		s_sel_o => sel_i,
    		s_dat_i => dat_o,
    		s_dat_o => dat_i,
    		s_cyc_o => cyc_i,
    		s_ack_i => ack_o,
    		s_err_i => '0',
    		s_rty_i => '0',
    		s_we_o => we_i,
    		s_stb_o => stb,
    
    		-- interface to asyncron master device
    		a_data => data,
    		a_addr => addr,
    		a_rdn => rdn,
    		a_wrn => wrn,
    		a_cen => cen,
    		a_byen => byen,
    		a_waitn => waitn
    	);

    cen <= vmem_cen and reg_cen;
    vmem_stb_i <= stb and not vmem_cen;
    reg_stb_i <= stb and not reg_cen;
    
	addr_decoder: process is
	begin
		wait on reg_stb_i, adr_i;

        reg_stb <= '0';
        ws_stb <= '0';

		if (reg_stb_i = '1') then
			case (adr_i(vga_reg_size)) is
				when '0' => reg_stb <= '1';
				when '1' => ws_stb <= '1';
				when others => 
			end case;
		end if;
	end process;

end vga_chip;
