--
--  File: vga_core_v2.vhd
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/04/26
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--  vga_core_v2: A WB compatible monitor controller core with version2 features.

library IEEE;
use IEEE.std_logic_1164.all;

library wb_vga;
use wb_vga.all;

library wb_tk;
use wb_tk.all;
use wb_tk.technology.all;

entity vga_core_v2 is
	generic (
		v_dat_width: positive := 16;
		v_adr_width : positive := 20;
		cpu_dat_width: positive := 16;
		cpu_adr_width: positive := 11;
		fifo_size: positive := 256;
		accel_size: positive := 9;
		v_pal_size: positive := 8;
		v_pal_width: positive := 16
	);
	port (
		clk_i: in std_logic;
		clk_en: in std_logic := '1';
		rst_i: in std_logic := '0';

		-- CPU bus interface
		dat_i: in std_logic_vector (cpu_dat_width-1 downto 0);
		dat_oi: in std_logic_vector (cpu_dat_width-1 downto 0);
		dat_o: out std_logic_vector (cpu_dat_width-1 downto 0);
		cyc_i: in std_logic;
		ack_o: out std_logic;
		ack_oi: in std_logic;
		err_o: out std_logic;
		err_oi: in std_logic;
		we_i: in std_logic;
		accel_stb_i: in std_logic;
		pal_stb_i: in std_logic;
		reg_stb_i: in std_logic;
		adr_i: in std_logic_vector (cpu_adr_width-1 downto 0);
        sel_i: in std_logic_vector ((cpu_dat_width/8)-1 downto 0) := (others => '1');

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
		video_out: out std_logic_vector (v_pal_size-1 downto 0);   -- video output binary signal (unused bits are forced to 0)
		true_color_out: out std_logic_vector (v_pal_width-1 downto 0) -- true-color video output
	);
end vga_core_v2;

architecture vga_core_v2 of vga_core_v2 is
	component vga_core
    	generic (
    		v_dat_width: positive := v_dat_width;
    		v_adr_width : positive := v_adr_width;
    		cpu_dat_width: positive := cpu_dat_width;
    		cpu_adr_width: positive := v_adr_width-bus_resize2adr_bits(cpu_dat_width,v_dat_width);
    		reg_adr_width: positive := cpu_adr_width;
    		fifo_size: positive := fifo_size
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

    component accel is
    	generic (
    		accel_size: positive := accel_size;
    		video_addr_width: positive := v_adr_width-bus_resize2adr_bits(cpu_dat_width,v_dat_width);
    		data_width: positive := cpu_dat_width
    	);
    	port (
    		clk_i: in std_logic;
    		rst_i: in std_logic := '0';
    
    		-- Slave interface to the CPU side
    		we_i: in std_logic;
    		cyc_i: in std_logic;
    		cur_stb_i: in std_logic;
    		ext_stb_i: in std_logic;
    		acc_stb_i: in std_logic;
    		mem_stb_i: in std_logic;
    		
            sel_i: in std_logic_vector ((data_width/8)-1 downto 0) := (others => '1');
    		adr_i: in std_logic_vector(accel_size-1 downto 0);
    		dat_i: in std_logic_vector(data_width-1 downto 0);
    		dat_o: out std_logic_vector(data_width-1 downto 0);
    		dat_oi: in std_logic_vector(data_width-1 downto 0);
    
    		ack_o: out std_logic;
    		ack_oi: in std_logic;
    
    		-- Master interface to the video memory side.		
    		v_we_o: out std_logic;
    		v_cyc_o: out std_logic;
    		v_stb_o: out std_logic;
    
    		v_adr_o: out std_logic_vector (video_addr_width-1 downto 0);
            v_sel_o: out std_logic_vector ((data_width/8)-1 downto 0);
    		v_dat_o: out std_logic_vector (data_width-1 downto 0);
    		v_dat_i: in std_logic_vector (data_width-1 downto 0);
    		
    		v_ack_i: in std_logic
    	);
    end component;
    
    component wb_pal_ram is
    	generic (
    		cpu_dat_width: positive := cpu_dat_width;
    		cpu_adr_width: positive := v_pal_size-bus_resize2adr_bits(cpu_dat_width,v_dat_width);
    		v_dat_width: positive := v_pal_width;
    		v_adr_width: positive := v_pal_size
    	);
    	port (
    -- Wishbone interface to CPU (write-only support)
        	clk_i: in std_logic;
    		rst_i: in std_logic := '0';
    		adr_i: in std_logic_vector (cpu_adr_width-1 downto 0);
    		dat_i: in std_logic_vector (cpu_dat_width-1 downto 0);
    		dat_oi: in std_logic_vector (cpu_dat_width-1 downto 0) := (others => '-');
    		dat_o: out std_logic_vector (cpu_dat_width-1 downto 0);
    		cyc_i: in std_logic;
    		ack_o: out std_logic;
    		ack_oi: in std_logic := '-';
    		err_o: out std_logic;
    		err_oi: in std_logic := '-';
    		we_i: in std_logic;
    		stb_i: in std_logic;
    -- Interface to the video output
            blank: in std_logic;
            v_dat_i: in std_logic_vector(v_adr_width-1 downto 0);
            v_dat_o: out std_logic_vector(v_dat_width-1 downto 0)
    	);
    end component;

    -- register select signals
    signal vga_reg_stb: std_logic;
    signal cur_stb: std_logic;
    signal ext_stb: std_logic;
    -- accelerator select signals
    signal acc_stb: std_logic;
    signal mem_stb: std_logic;

	signal vga_dat_o: std_logic_vector(cpu_dat_width-1 downto 0);
	signal vga_ack_o: std_logic;

	signal vreg_dat_o: std_logic_vector(cpu_dat_width-1 downto 0);
	signal vreg_ack_o: std_logic;
	signal accel_dat_o: std_logic_vector(cpu_dat_width-1 downto 0);
	signal accel_ack_o: std_logic;
	signal pal_dat_o: std_logic_vector(cpu_dat_width-1 downto 0);
	signal pal_ack_o: std_logic;

    signal i_video_out: std_logic_vector (v_pal_size-1 downto 0);
    signal i_blank: std_logic;
    signal vmem_stb: std_logic;

    signal vm_cyc: std_logic;
    signal vm_we: std_logic;
    signal vm_stb: std_logic;
    signal vm_ack: std_logic;
    signal vm_adr: std_logic_vector(v_adr_width-bus_resize2adr_bits(cpu_dat_width,v_dat_width)-1 downto 0);
    signal vm_sel: std_logic_vector(cpu_dat_width/8-1 downto 0);
    signal vm_dat_i: std_logic_vector(cpu_dat_width-1 downto 0);
    signal vm_dat_o: std_logic_vector(cpu_dat_width-1 downto 0);

	constant vga_reg_size: integer := size2bits((32*8)/cpu_dat_width)-1;
begin
	core : vga_core
		port map (
    		clk_i => clk_i,
		    clk_en => clk_en,
		    rst_i => rst_i,
    		-- CPU bus interface
    		vmem_cyc_i => vm_cyc,
    		vmem_we_i => vm_we,
    		vmem_stb_i => vm_stb,
    		vmem_ack_o => vm_ack,
    		vmem_ack_oi => '1',
    		vmem_adr_i => vm_adr,
            vmem_sel_i => vm_sel,
    		vmem_dat_i => vm_dat_i,
    		vmem_dat_oi => (cpu_dat_width-1 downto 0 => '-'),
    		vmem_dat_o => vm_dat_o,
    
    		-- CPU register bus interface
    		reg_cyc_i => cyc_i,
    		reg_we_i => we_i,
        	reg_stb_i => vga_reg_stb,
    		reg_ack_o => vreg_ack_o,
    		reg_ack_oi => ack_oi,
    		reg_adr_i => adr_i,
            reg_sel_i => sel_i,
    		reg_dat_i => dat_i,
    		reg_dat_oi => dat_oi,
    		reg_dat_o => vreg_dat_o,
    

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
		    blank => i_blank,
    		video_out => i_video_out
		);

    acc: accel 
    	port map (
    		clk_i => clk_i,
    		rst_i => rst_i,
    
    		-- Slave interface to the CPU side
    		we_i => we_i,
    		cyc_i => cyc_i,
    		cur_stb_i => cur_stb,
    		ext_stb_i => ext_stb,
    		acc_stb_i => acc_stb,
    		mem_stb_i => mem_stb,
    		
            sel_i => sel_i,
    		adr_i => adr_i(accel_size-1 downto 0),
    		dat_i => dat_i,
    		dat_o => accel_dat_o,
    		dat_oi => vreg_dat_o,
    
    		ack_o => accel_ack_o,
    		ack_oi => vreg_ack_o,
    
    		-- Master interface to the video memory side.		
    		v_we_o => vm_we,
    		v_cyc_o => vm_cyc,
    		v_stb_o => vm_stb,
    
    		v_adr_o => vm_adr,
    		v_sel_o => vm_sel,
    		v_dat_o => vm_dat_i,
    		v_dat_i => vm_dat_o,
    		
    		v_ack_i => vm_ack
    	);

    palette: wb_pal_ram
    	port map (
        	clk_i => clk_i,
    		rst_i => rst_i,
    		adr_i => adr_i(v_pal_size-bus_resize2adr_bits(cpu_dat_width,v_dat_width)-1 downto 0),
    		dat_i => dat_i,
    		dat_oi => accel_dat_o,
    		dat_o => dat_o,
    		cyc_i => cyc_i,
    		ack_o => ack_o,
    		ack_oi => accel_ack_o,
    		err_o => err_o,
    		err_oi => err_oi,
    		we_i => we_i,
    		stb_i => pal_stb_i,
    -- Interface to the video output
            blank => i_blank,
            v_dat_i => i_video_out,
            v_dat_o => true_color_out
    	);
    video_out <= i_video_out;
    blank <= i_blank;
    
	reg_addr_decoder: process is
	begin
		wait on reg_stb_i, adr_i;

        vga_reg_stb <= '0';
        cur_stb <= '0';
        ext_stb <= '0';

		if (reg_stb_i = '1') then
			case (adr_i(vga_reg_size)) is
				when '0' => vga_reg_stb <= '1';
				when '1' => 
				    if (adr_i(vga_reg_size-2) = '1') then
        				case (adr_i(vga_reg_size-3)) is
        				    when '0' => cur_stb <= '1';
        				    when '1' => ext_stb <= '1';
            				when others => 
            			end case;
            		end if;
				when others => 
			end case;
		end if;
	end process;

	accel_addr_decoder: process is
	begin
		wait on accel_stb_i, adr_i;

        acc_stb <= '0';
        mem_stb <= '0';

		if (accel_stb_i = '1') then
			case (adr_i(accel_size)) is
				when '0' => acc_stb <= '1';
				when '1' => mem_stb <= '1';
				when others => 
			end case;
		end if;
	end process;

end vga_core_v2;
