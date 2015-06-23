library ieee,wb_tk,wb_vga;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;
use wb_tk.technology.all;
use wb_tk.wb_test.all;
use wb_tk.all;
use wb_vga.all;

entity accel_tb is
	generic(
		accel_size : POSITIVE := 9;
		video_addr_width : POSITIVE := 20;
		video_data_width : POSITIVE := 16;
		data_width : POSITIVE := 16 );
end accel_tb;

architecture TB of accel_tb is
	component accel
		generic(
			accel_size : POSITIVE := accel_size;
			video_addr_width : POSITIVE := video_addr_width;
			video_data_width : POSITIVE := video_data_width;
			data_width : POSITIVE := data_width
		);
		port (
			clk_i: in std_logic;
			rst_i: in std_logic := '0';
	
			-- Slave interface to the CPU side
			we_i: in std_logic;
			cyc_i: in std_logic;
	        sel_i: in std_logic_vector ((data_width/8)-1 downto 0) := (others => '1');
			cur_stb_i: in std_logic;
			ext_stb_i: in std_logic;
			acc_stb_i: in std_logic;
			mem_stb_i: in std_logic;
			
			adr_i: in std_logic_vector(accel_size-1 downto 0);
			dat_i: in std_logic_vector(data_width-1 downto 0);
			dat_o: out std_logic_vector(data_width-1 downto 0);
			dat_oi: in std_logic_vector(data_width-1 downto 0);
	
			ack_o: out std_logic;
			ack_oi: in std_logic;
	
			-- Master interface to the video memory side.		
			v_we_o: out std_logic;
			v_cyc_o: out std_logic;
			v_sel_o: out std_logic;
	
			v_adr_o: out std_logic_vector (video_addr_width-1 downto 0);
			v_dat_o: out std_logic_vector (video_data_width-1 downto 0);
			v_dat_i: in std_logic_vector (video_data_width-1 downto 0);
			
			v_ack_i: in std_logic
		);
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk_i : std_logic;
	signal rst_i : std_logic;
	signal we_i : std_logic;
	signal cyc_i : std_logic;
    signal sel_i: std_logic_vector ((data_width/8)-1 downto 0) := (others => '1');
	signal cur_stb_i : std_logic;
	signal ext_stb_i : std_logic;
	signal acc_stb_i : std_logic;
	signal mem_stb_i : std_logic;
	signal adr_i : std_logic_vector((accel_size-1) downto 0);
	signal dat_i : std_logic_vector((data_width-1) downto 0);
	signal dat_oi : std_logic_vector((data_width-1) downto 0);
	signal ack_oi : std_logic;
	signal v_dat_i : std_logic_vector((video_data_width-1) downto 0);
	signal v_ack_i : std_logic;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal dat_o : std_logic_vector((data_width-1) downto 0);
	signal ack_o : std_logic;
	signal v_we_o : std_logic;
	signal v_sel_o : std_logic;
	signal v_cyc_o : std_logic;
	signal v_adr_o : std_logic_vector((video_addr_width-1) downto 0);
	signal v_dat_o : std_logic_vector((video_data_width-1) downto 0);
begin

	-- Unit Under Test port map
	UUT : accel
		port map
			(clk_i => clk_i,
			rst_i => rst_i,
			we_i => we_i,
			cyc_i => cyc_i,
			sel_i => sel_i,
			cur_stb_i => cur_stb_i,
			ext_stb_i => ext_stb_i,
			acc_stb_i => acc_stb_i,
			mem_stb_i => mem_stb_i,
			adr_i => adr_i,
			dat_i => dat_i,
			dat_o => dat_o,
			dat_oi => dat_oi,
			ack_o => ack_o,
			ack_oi => ack_oi,
			v_we_o => v_we_o,
			v_cyc_o => v_cyc_o,
			v_sel_o => v_sel_o,
			v_adr_o => v_adr_o,
			v_dat_o => v_dat_o,
			v_dat_i => v_dat_i,
			v_ack_i => v_ack_i );

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
	
	memory: process is
	begin
		v_ack_i <= '0';
		v_dat_i <= (others => 'U');
		if (v_sel_o /= '1') then wait until v_sel_o = '1'; end if;
		wait until clk_i'EVENT and clk_i = '1';
		v_ack_i <= '1';
		if (v_we_o = '1') then
			v_dat_i <= v_adr_o(v_dat_i'RANGE);
		else
			v_dat_i <= (others => 'U');
		end if;
		wait until clk_i'EVENT and clk_i = '1';
		wait for 15ns;
	end process;

	dat_oi <= (others => 'U');
	ack_oi <= 'U';
	
	master: process is
		variable init: boolean := true;
	begin
		if (init) then
			we_i <= '0';
			cyc_i <= '0';
			cur_stb_i <= '0';
			ext_stb_i <= '0';
			acc_stb_i <= '0';
			mem_stb_i <= '0';
			adr_i <= (others => '0');
			dat_i <= (others => '0');
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';

			-- Set Cursor to 0
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,cur_stb_i,ack_o,"000000000","0000000000000000");
			-- Accel index 0 is 0
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,acc_stb_i,ack_o,"000000000","0000000000000000");
			-- Accel index 1 is 1
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,acc_stb_i,ack_o,"000000001","0000000000000001");
			-- Accel index 2 is 3
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,acc_stb_i,ack_o,"000000010","0000000000000011");
			-- Accel index 3 is -1
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,acc_stb_i,ack_o,"000000011","1111111111111111");
		end if;
		init := false;
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000000","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000001","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000001","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000011","1111000011110000");

		chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,cur_stb_i,ack_o,"000000000","0000000000000001");
		
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000011","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000010","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000010","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000010","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000011","1111000011110000");

		chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,cur_stb_i,ack_o,"000000000","0000000000001000");
		
		-- Set Cursor to 16
		wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,cur_stb_i,ack_o,"000000000","0000000000010000");

		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000000","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000001","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000001","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000011","1111000011110000");

		chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,cur_stb_i,ack_o,"000000000","0000000000010001");
		
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000011","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000010","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000010","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000010","1111000011110000");
		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,mem_stb_i,ack_o,"000000011","1111000011110000");

		chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,cur_stb_i,ack_o,"000000000","0000000000011000");
		
		-- Set Cursor to 0
		wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,cur_stb_i,ack_o,"000000000","0000000000000000");
	
		wait;
	end process;
	
end TB;

configuration TB_accel of accel_tb is
	for TB
		for UUT : accel
			use entity wb_vga.accel(accel);
		end for;
	end for;
end TB_accel;

