--
--  File: vga_core.vhd
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

library IEEE;
use IEEE.std_logic_1164.all;

library wb_tk;
use wb_tk.all;
use wb_tk.technology.all;

library wb_vga;
use wb_vga.all;

entity vga_core is
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
end vga_core;

architecture vga_core of vga_core is
	component video_engine
		generic (
			v_mem_width: positive := 16;
			v_addr_width: positive:= 20;
			fifo_size: positive := 256;
			dual_scan_fifo_size: positive := 256
		);
		port (
			clk: in std_logic;
			clk_en: in std_logic := '1';
			reset: in std_logic := '0';

    		v_mem_end: in std_logic_vector(v_addr_width-1 downto 0);   -- video memory end address in words
	    	v_mem_start: in std_logic_vector(v_addr_width-1 downto 0) := (others => '0'); -- video memory start adderss in words
			fifo_treshold: in std_logic_vector(7 downto 0);        -- priority change threshold
			bpp: in std_logic_vector(1 downto 0);                  -- number of bits makes up a pixel valid values: 1,2,4,8
			multi_scan: in std_logic_vector(1 downto 0);           -- number of repeated scans

			hbs: in std_logic_vector(7 downto 0);
			hss: in std_logic_vector(7 downto 0);
			hse: in std_logic_vector(7 downto 0);
			htotal: in std_logic_vector(7 downto 0);
			vbs: in std_logic_vector(7 downto 0);
			vss: in std_logic_vector(7 downto 0);
			vse: in std_logic_vector(7 downto 0);
			vtotal: in std_logic_vector(7 downto 0);

			pps: in std_logic_vector(7 downto 0);

			high_prior: out std_logic;                      -- signals to the memory arbitrer to give high
			                                                -- priority to the video engine
			v_mem_rd: out std_logic;                        -- video memory read request
			v_mem_rdy: in std_logic;                        -- video memory data ready
			v_mem_addr: out std_logic_vector (v_addr_width-1 downto 0); -- video memory address
			v_mem_data: in std_logic_vector (v_mem_width-1 downto 0);   -- video memory data

			h_sync: out std_logic;
			h_blank: out std_logic;
			v_sync: out std_logic;
			v_blank: out std_logic;
			h_tc: out std_logic;
			v_tc: out std_logic;
			blank: out std_logic;
			video_out: out std_logic_vector (7 downto 0)    -- video output binary signal (unused bits are forced to 0)
		);
	end component video_engine;

	component wb_arbiter
	port (
--		clk: in std_logic;
		rst_i: in std_logic := '0';
		
		-- interface to master device a
		a_we_i: in std_logic;
		a_stb_i: in std_logic;
		a_cyc_i: in std_logic;
		a_ack_o: out std_logic;
		a_ack_oi: in std_logic := '-';
		a_err_o: out std_logic;
		a_err_oi: in std_logic := '-';
		a_rty_o: out std_logic;
		a_rty_oi: in std_logic := '-';
	
		-- interface to master device b
		b_we_i: in std_logic;
		b_stb_i: in std_logic;
		b_cyc_i: in std_logic;
		b_ack_o: out std_logic;
		b_ack_oi: in std_logic := '-';
		b_err_o: out std_logic;
		b_err_oi: in std_logic := '-';
		b_rty_o: out std_logic;
		b_rty_oi: in std_logic := '-';

		-- interface to shared devices
		s_we_o: out std_logic;
		s_stb_o: out std_logic;
		s_cyc_o: out std_logic;
		s_ack_i: in std_logic;
		s_err_i: in std_logic := '-';
		s_rty_i: in std_logic := '-';
		
		mux_signal: out std_logic; -- 0: select A signals, 1: select B signals

		-- misc control lines
		priority: in std_logic -- 0: A have priority over B, 1: B have priority over A
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

	component wb_bus_resize
	generic (
		m_bus_width: positive;
		m_addr_width: positive;
		s_bus_width: positive;
		s_addr_width: positive;
		little_endien: boolean := true -- if set to false, big endien
	);
	port (
--		clk_i: in std_logic;
--		rst_i: in std_logic := '0';

		-- Master bus interface
		m_adr_i: in std_logic_vector (m_addr_width-1 downto 0);
		m_sel_i: in std_logic_vector ((m_bus_width/8)-1 downto 0) := (others => '1');
		m_dat_i: in std_logic_vector (m_bus_width-1 downto 0);
		m_dat_oi: in std_logic_vector (m_bus_width-1 downto 0) := (others => '-');
		m_dat_o: out std_logic_vector (m_bus_width-1 downto 0);
		m_cyc_i: in std_logic;
		m_ack_o: out std_logic;
		m_ack_oi: in std_logic := '-';
		m_err_o: out std_logic;
		m_err_oi: in std_logic := '-';
		m_rty_o: out std_logic;
		m_rty_oi: in std_logic := '-';
		m_we_i: in std_logic;
		m_stb_i: in std_logic;

		-- Slave bus interface
		s_adr_o: out std_logic_vector (s_addr_width-1 downto 0);
		s_sel_o: out std_logic_vector ((s_bus_width/8)-1 downto 0);
		s_dat_i: in std_logic_vector (s_bus_width-1 downto 0);
		s_dat_o: out std_logic_vector (s_bus_width-1 downto 0);
		s_cyc_o: out std_logic;
		s_ack_i: in std_logic;
		s_err_i: in std_logic := '-';
		s_rty_i: in std_logic := '-';
		s_we_o: out std_logic;
		s_stb_o: out std_logic
	);
	end component;

	signal v_mem_start: std_logic_vector(v_adr_width-1 downto 0);
	signal v_mem_end: std_logic_vector(v_adr_width-1 downto 0);
	
	signal reg_bank: std_logic_vector((8*12)-1 downto 0);

	alias fifo_treshold: std_logic_vector(7 downto 0) is reg_bank( 7 downto  0);
	alias bpp: std_logic_vector(1 downto 0)           is reg_bank( 9 downto  8);
	alias multi_scan: std_logic_vector(1 downto 0)    is reg_bank(13 downto 12);
	alias hbs: std_logic_vector(7 downto 0)           is reg_bank(23 downto 16);
	alias hss: std_logic_vector(7 downto 0)           is reg_bank(31 downto 24);
	alias hse: std_logic_vector(7 downto 0)           is reg_bank(39 downto 32);
	alias htotal: std_logic_vector(7 downto 0)        is reg_bank(47 downto 40);
	alias vbs: std_logic_vector(7 downto 0)           is reg_bank(55 downto 48);
	alias vss: std_logic_vector(7 downto 0)           is reg_bank(63 downto 56);
	alias vse: std_logic_vector(7 downto 0)           is reg_bank(71 downto 64);
	alias vtotal: std_logic_vector(7 downto 0)        is reg_bank(79 downto 72);
	alias pps: std_logic_vector(7 downto 0)           is reg_bank(87 downto 80);
	alias sync_pol: std_logic_vector (3 downto 0)     is reg_bank(91 downto 88);
	alias reset_core: std_logic_vector(0 downto 0)    is reg_bank(95 downto 95);

    signal v_mem_start_stb: std_logic;    -- selects total register
    signal v_mem_end_stb: std_logic;      -- selects offset register
    signal reg_bank_stb: std_logic; -- selects all other registers (in a single bank)

	signal reg_bank_do: std_logic_vector(cpu_dat_width-1 downto 0);
	signal v_mem_start_do: std_logic_vector(cpu_dat_width-1 downto 0);

	signal reg_bank_ack: std_logic;
	signal v_mem_start_ack: std_logic;

	signal a_adr_o : std_logic_vector((v_adr_width-1) downto 0);
	signal a_sel_o : std_logic_vector((v_dat_width/8)-1 downto 0);
	signal a_dat_o : std_logic_vector((v_dat_width-1) downto 0);
	signal a_dat_i : std_logic_vector((v_dat_width-1) downto 0);
	signal a_we_o : std_logic;
	signal a_stb_o : std_logic;
	signal a_cyc_o : std_logic;
	signal a_ack_i : std_logic;

	signal b_adr_o : std_logic_vector((v_adr_width-1) downto 0);
	signal b_sel_o : std_logic_vector((v_dat_width/8)-1 downto 0);
--	signal b_dat_o : std_logic_vector((v_dat_width-1) downto 0);
	signal b_dat_i : std_logic_vector((v_dat_width-1) downto 0);
	signal b_stb_o : std_logic;
--	signal b_we_o : std_logic;
--	signal b_cyc_o : std_logic;
	signal b_ack_i : std_logic;

	signal mux_signal: std_logic;

	signal high_prior: std_logic;

	signal reset_engine: std_logic;

	signal i_h_sync: std_logic;
	signal i_h_blank: std_logic;
	signal i_v_sync: std_logic;
	signal i_v_blank: std_logic;

	signal s_wrn : std_logic;
	
	constant v_adr_zero : std_logic_vector(v_adr_width-1 downto 0) := (others => '0');
	constant reg_bank_rst_val: std_logic_vector(reg_bank'Range) := (others => '0');
	constant reg_bank_size: integer := size2bits((reg_bank'HIGH+cpu_dat_width)/cpu_dat_width);
	constant tot_ofs_size: integer := size2bits((v_adr_width+cpu_dat_width-1)/cpu_dat_width);
begin
	-- map all registers:
--		adr_i: in std_logic_vector (max(log2((width+offset+bus_width-1)/bus_width)-1,0) downto 0) := (others => '0');

	reg_bank_reg: wb_out_reg
		generic map( width => reg_bank'HIGH+1, bus_width => cpu_dat_width , offset => 0 )
		port map(
    		stb_i => reg_bank_stb,
    		q => reg_bank,
    		rst_val => reg_bank_rst_val,
    		dat_oi => reg_dat_oi,
    		dat_o => reg_bank_do,
    		ack_oi => reg_ack_oi,
    		ack_o => reg_bank_ack,
    		adr_i => reg_adr_i(reg_bank_size-1 downto 0),
    		sel_i => reg_sel_i, cyc_i => reg_cyc_i, we_i => reg_we_i, clk_i => clk_i, rst_i => rst_i, dat_i => reg_dat_i );
	v_mem_start_reg: wb_out_reg
		generic map( width => v_adr_width, bus_width => cpu_dat_width , offset => 0 )
		port map(
            stb_i => v_mem_start_stb,
            q => v_mem_start,
            rst_val => v_adr_zero,
            dat_oi => reg_bank_do,
            dat_o => v_mem_start_do,
            ack_oi => reg_bank_ack,
            ack_o => v_mem_start_ack,
    		adr_i => reg_adr_i(tot_ofs_size-1 downto 0),
    		sel_i => reg_sel_i, cyc_i => reg_cyc_i, we_i => reg_we_i, clk_i => clk_i, rst_i => rst_i, dat_i => reg_dat_i );
	v_mem_end_reg: wb_out_reg
		generic map( width => v_adr_width, bus_width => cpu_dat_width , offset => 0 )
		port map(
            stb_i => v_mem_end_stb,
            q => v_mem_end,
            rst_val => v_adr_zero,
            dat_oi => v_mem_start_do,
            dat_o => reg_dat_o, -- END OF THE CHAIN
            ack_oi => v_mem_start_ack,
            ack_o => reg_ack_o, -- END OF THE CHAIN
    		adr_i => reg_adr_i(tot_ofs_size-1 downto 0),
    		sel_i => reg_sel_i, cyc_i => reg_cyc_i, we_i => reg_we_i, clk_i => clk_i, rst_i => rst_i, dat_i => reg_dat_i );

    reset_engine <= rst_i or not reset_core(0);

	v_e: video_engine
		generic map ( v_mem_width => v_dat_width, v_addr_width => v_adr_width, fifo_size => fifo_size, dual_scan_fifo_size => fifo_size )
		port map (
			clk => clk_i,
			clk_en => clk_en,
			reset => reset_engine,
			v_mem_start => v_mem_start,
			v_mem_end => v_mem_end,
			fifo_treshold => fifo_treshold,
			bpp => bpp,
			multi_scan => multi_scan,
			hbs => hbs,
			hss => hss,
			hse => hse,
			htotal => htotal,
			vbs => vbs,
			vss => vss,
			vse => vse,
			vtotal => vtotal,
			pps => pps,

			high_prior => high_prior,

			v_mem_rd => b_stb_o,
			v_mem_rdy => b_ack_i,
			v_mem_addr => b_adr_o,
			v_mem_data => b_dat_i,

			h_sync => i_h_sync,
			h_blank => i_h_blank,
			v_sync => i_v_sync,
			v_blank => i_v_blank,
			h_tc => h_tc,
			v_tc => v_tc,
			blank => blank,
			video_out => video_out
		);

	h_sync <= i_h_sync xor sync_pol(0);
	v_sync <= i_v_sync xor sync_pol(1);
	h_blank <= i_h_blank;-- xor sync_pol(2);
	v_blank <= i_v_blank;-- xor sync_pol(3);

	resize: wb_bus_resize
		generic map (
			m_bus_width => cpu_dat_width, s_bus_width => v_dat_width, m_addr_width => cpu_adr_width, s_addr_width => v_adr_width, little_endien => true
		)
		port map (
			m_adr_i => vmem_adr_i,
			m_cyc_i => vmem_cyc_i,
			m_sel_i => vmem_sel_i,
			m_dat_i => vmem_dat_i,
			m_dat_oi => vmem_dat_oi,
			m_dat_o => vmem_dat_o,
			m_ack_o => vmem_ack_o,
			m_ack_oi => vmem_ack_oi, -- Beginning of the chain
			m_we_i => vmem_we_i,
			m_stb_i => vmem_stb_i,
	
			s_adr_o => a_adr_o,
			s_sel_o => a_sel_o,
			s_dat_i => a_dat_i,
			s_dat_o => a_dat_o,
    		s_cyc_o => a_cyc_o,
			s_ack_i => a_ack_i,
			s_we_o => a_we_o,
			s_stb_o => a_stb_o
		);


	arbiter: wb_arbiter
    	port map (
    		rst_i => reset_engine,

    		a_we_i => a_we_o,
    		a_cyc_i => a_cyc_o,
    		a_stb_i => a_stb_o,
    		a_ack_o => a_ack_i,
    		a_ack_oi => '-',

    		b_we_i => '0',
    		b_cyc_i => b_stb_o,
    		b_stb_i => b_stb_o,
    		b_ack_o => b_ack_i,
    		b_ack_oi => '0',

    		s_we_o => v_we_o,
    		s_stb_o => v_stb_o,
    		s_ack_i => v_ack_i,
    		s_cyc_o => v_cyc_o,

	    	mux_signal => mux_signal,
    
    		priority => high_prior
    	);

    b_sel_o <= (others => '1');
    
	bus_mux: process is
	begin
		wait on mux_signal, v_dat_i, a_adr_o, a_dat_o, b_adr_o, a_sel_o, b_sel_o;
		if (mux_signal = '0') then
			v_adr_o <= a_adr_o;
			v_sel_o <= a_sel_o;
			v_dat_o <= a_dat_o;
			a_dat_i <= v_dat_i;
			b_dat_i <= (others => '-');
		else
			v_adr_o <= b_adr_o;
			v_sel_o <= b_sel_o;
			v_dat_o <= (others => '-');
			b_dat_i <= v_dat_i;
			a_dat_i <= (others => '-');
		end if;
	end process;

	addr_decoder: process is
	begin
		wait on reg_stb_i, reg_adr_i;

        v_mem_start_stb <= '0';
        v_mem_end_stb <= '0';
        reg_bank_stb <= '0';

		if (reg_stb_i = '1') then
			case (reg_adr_i(reg_bank_size)) is
				when '0' => 
        			case (reg_adr_i(reg_bank_size-2)) is
        				when '0' => v_mem_end_stb <= '1';
        				when '1' => v_mem_start_stb <= '1';
        				when others => 
        			end case;
				when '1' => reg_bank_stb <= '1';
				when others => 
			end case;
		end if;
	end process;
end vga_core;

