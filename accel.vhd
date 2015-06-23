--
--  Address generator and accelerator.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--


-- Standard library.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library wb_tk;
use wb_tk.technology.all;
use wb_tk.all;

library wb_vga;
use wb_vga.all;

entity accel is
	generic (
		accel_size: positive := 9;
		video_addr_width: positive := 20;
		data_width: positive := 16
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
end accel;

architecture accel of accel is
	component wb_io_reg
		generic (
			width : positive := video_addr_width;
			bus_width: positive := data_width;
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
			q: out std_logic_vector (width-1 downto 0);
			ext_d: in std_logic_vector (width-1 downto 0) := (others => '-');
			ext_we: in std_logic := '0'
		);
	end component;
	
	component wb_ram 
		generic (
			data_width: positive := 8;
			addr_width: positive := 10
		);
		port (
	    	clk_i: in std_logic;
			adr_i: in std_logic_vector (addr_width-1 downto 0);
			dat_i: in std_logic_vector (data_width-1 downto 0);
			dat_oi: in std_logic_vector (data_width-1 downto 0) := (others => '-');
			dat_o: out std_logic_vector (data_width-1 downto 0);
			cyc_i: in std_logic;
			ack_o: out std_logic;
			ack_oi: in std_logic := '-';
			we_i: in std_logic;
			stb_i: in std_logic
		);
	end component;

	signal cursor: std_logic_vector(video_addr_width-1 downto 0);
	signal accel_ram_d_out: std_logic_vector(video_addr_width-1 downto 0);
	signal accel_ram_dat_i: std_logic_vector(video_addr_width-1 downto 0);
	signal accel_ram_stb: std_logic;
	signal accel_ram_ack: std_logic;
	signal accel_ram_we: std_logic;
	signal accel_ram_clk: std_logic;
	signal next_cur: std_logic_vector(video_addr_width-1 downto 0);
	signal cur_update: std_logic := '0';
	signal mem_ack_o: std_logic := '1';
	signal mem_dat_o: std_logic_vector(data_width-1 downto 0);
	signal cur_ack_o: std_logic := '1';
	signal cur_dat_o: std_logic_vector(data_width-1 downto 0);
	signal ext_value: std_logic_vector(max(video_addr_width - data_width,1)-1 downto 0);
	signal ext_ext_we: std_logic;
begin
	accel_ram_stb <= acc_stb_i or mem_stb_i;
	accel_ram_we <= we_i and acc_stb_i;
	accel_ram_clk <= clk_i;
	accel_ram_dat_i(min2(video_addr_width-1
	,data_width-1) downto 0) <= 
	    dat_i(min2(video_addr_width,data_width) - 1 downto 0);
	high_accel_dat_gen: if (video_addr_width > data_width) generate
		accel_ram_dat_i(video_addr_width-1 downto data_width) <= ext_value;
	end generate;
	accel_ram: wb_ram 
		generic map (
			data_width => video_addr_width,
			addr_width => accel_size
		)
		port map (
			clk_i => clk_i,
			cyc_i => cyc_i,
			stb_i => accel_ram_stb,
			we_i => accel_ram_we,
			adr_i => adr_i,
			dat_i => accel_ram_dat_i,
			dat_o => accel_ram_d_out,
			ack_o => accel_ram_ack
		);

	v_stb_o <= mem_stb_i;
	v_cyc_o <= mem_stb_i and cyc_i;
	v_adr_o <= cursor;
	v_we_o <= we_i;
	v_dat_o <= dat_i;
	
	next_cur <= cursor + accel_ram_d_out;
	
	ext_ext_we <= acc_stb_i and not we_i;
	ext_reg_gen: if (video_addr_width > data_width) generate
		ext_reg: wb_io_reg
			generic map (
				width => video_addr_width - data_width,
				bus_width => data_width,
				offset => 0
			)
			port map (
				clk_i => clk_i,
				rst_i => rst_i,
				rst_val => (video_addr_width - data_width-1 downto 0 => '0'),
		
		        cyc_i => cyc_i,
				stb_i => ext_stb_i,
		        sel_i => sel_i,
				we_i => we_i,
				ack_o => ack_o,
				ack_oi => cur_ack_o,
				adr_i => adr_i(size2bits((video_addr_width-1)/data_width)-1 downto 0),
				dat_i => dat_i,
				dat_oi => cur_dat_o,
				dat_o => dat_o,
				q => ext_value,
				ext_d => accel_ram_d_out(video_addr_width-1 downto data_width),
				ext_we => ext_ext_we
			);
	end generate;
	ext_gen: if (video_addr_width <= data_width) generate
		dat_o <= cur_dat_o;
		ack_o <= cur_ack_o;
		ext_value(0) <= '0';
	end generate;

	cur_reg: wb_io_reg
		generic map (
			width => video_addr_width,
			bus_width => data_width,
			offset => 0
		)
		port map (
			clk_i => clk_i,
			rst_i => rst_i,
			rst_val => (video_addr_width-1 downto 0 => '0'),
	
	        cyc_i => cyc_i,
			stb_i => cur_stb_i,
	        sel_i => sel_i,
			we_i => we_i,
			ack_o => cur_ack_o,
			ack_oi => mem_ack_o,
			adr_i => adr_i(size2bits((video_addr_width+data_width-1)/data_width)-1 downto 0),
			dat_i => dat_i,
			dat_oi => mem_dat_o,
			dat_o => cur_dat_o,
			q => cursor,
			ext_d => next_cur,
			ext_we => cur_update
		);

	cur_update <= mem_stb_i and cyc_i and v_ack_i;

    v_sel_o <= sel_i;
	gen_dat_o: for i in dat_o'RANGE generate
        gen_dat_o1: if (i < video_addr_width) generate
    		mem_dat_o(i) <= (
    			(cyc_i and ((accel_ram_d_out(i) and acc_stb_i) or (v_dat_i(i) and mem_stb_i))) or 
    			(dat_oi(i) and ((not (acc_stb_i or mem_stb_i or cur_stb_i)) or (not cyc_i)))
    		);
    	end generate;
        gen_dat_o2: if (i >= video_addr_width) generate
    		mem_dat_o(i) <= (
    			(cyc_i and (('0' and acc_stb_i) or (v_dat_i(i) and mem_stb_i))) or 
    			(dat_oi(i) and ((not (acc_stb_i or mem_stb_i or cur_stb_i)) or (not cyc_i)))
    		);
    	end generate;
	end generate;
	mem_ack_o <= (
		(cyc_i and ((accel_ram_ack and acc_stb_i) or (v_ack_i and mem_stb_i))) or 
		(ack_oi and ((not (acc_stb_i or mem_stb_i or cur_stb_i)) or (not cyc_i)))
	);

end accel;
