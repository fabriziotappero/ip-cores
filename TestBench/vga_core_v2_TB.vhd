library ieee,exemplar;
use ieee.std_logic_1164.all;
use exemplar.exemplar_1164.all;
use ieee.std_logic_unsigned.all;
library synopsys;
use synopsys.std_logic_arith.all;

library wb_tk;
use wb_tk.wb_test.all;

library	wb_vga;
use wb_vga.all;
use wb_vga.constants.all;

entity vga_core_v2_tb is
	generic (
		v_dat_width: positive := 16;
		v_adr_width : positive := 12;
		cpu_dat_width: positive := 8;
		cpu_adr_width: positive := 12;
--		cpu_dat_width: positive := 16;
--		cpu_adr_width: positive := 11;
		fifo_size: positive := 256;
		accel_size: positive := 9;
		v_pal_size: positive := 8;
		v_pal_width: positive := 16
	);
end vga_core_v2_tb;

architecture TB of vga_core_v2_tb is
	-- Component declaration of the tested unit
    component vga_core_v2
    	generic (
    		v_dat_width: positive    :=  v_dat_width;
    		v_adr_width : positive   :=  v_adr_width;
    		cpu_dat_width: positive  :=  cpu_dat_width;
    		cpu_adr_width: positive  :=  cpu_adr_width;
    		fifo_size: positive      :=  fifo_size;
    		accel_size: positive     :=  accel_size;
    		v_pal_size: positive     :=  v_pal_size;
    		v_pal_width: positive    :=  v_pal_width
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
    end component;

    signal clk_i: std_logic;
    signal clk_en: std_logic := '1';
    signal rst_i: std_logic := '0';

    -- CPU bus interface
    signal dat_i: std_logic_vector (cpu_dat_width-1 downto 0);
    signal dat_oi: std_logic_vector (cpu_dat_width-1 downto 0);
    signal dat_o: std_logic_vector (cpu_dat_width-1 downto 0);
    signal cyc_i: std_logic;
    signal ack_o: std_logic;
    signal ack_oi: std_logic;
    signal err_o: std_logic;
    signal err_oi: std_logic;
    signal we_i: std_logic;
    signal accel_stb_i: std_logic;
    signal pal_stb_i: std_logic;
    signal reg_stb_i: std_logic;
    signal adr_i: std_logic_vector (cpu_adr_width-1 downto 0);
    signal sel_i: std_logic_vector ((cpu_dat_width/8)-1 downto 0) := (others => '1');

    -- video memory interface
    signal v_adr_o: std_logic_vector (v_adr_width-1 downto 0);
    signal v_sel_o: std_logic_vector ((v_dat_width/8)-1 downto 0);
    signal v_dat_i: std_logic_vector (v_dat_width-1 downto 0);
    signal v_dat_o: std_logic_vector (v_dat_width-1 downto 0);
    signal v_cyc_o: std_logic;
    signal v_ack_i: std_logic;
    signal v_we_o: std_logic;
    signal v_stb_o: std_logic;

    -- sync blank and video signal outputs
    signal h_sync: std_logic;
    signal h_blank: std_logic;
    signal v_sync: std_logic;
    signal v_blank: std_logic;
    signal h_tc: std_logic;
    signal v_tc: std_logic;
    signal blank: std_logic;
    signal video_out: std_logic_vector (v_pal_size-1 downto 0);   -- video output binary signal (unused bits are forced to 0)
    signal true_color_out: std_logic_vector (v_pal_width-1 downto 0); -- true-color video output

	constant reg_total0        : integer :=  0;
	constant reg_total1        : integer :=  1;
	constant reg_total2        : integer :=  2;
	constant reg_total3        : integer :=  3;
	constant reg_ofs0          : integer :=  4;
	constant reg_ofs1          : integer :=  5;
	constant reg_ofs2          : integer :=  6;
	constant reg_ofs3          : integer :=  7;

	constant reg_fifo_treshold : integer :=  16;
	constant reg_bpp           : integer :=  17;
	constant reg_hbs           : integer :=  18;
	constant reg_hss           : integer :=  19;
	constant reg_hse           : integer :=  20;
	constant reg_htotal        : integer :=  21;
	constant reg_vbs           : integer :=  22;
	constant reg_vss           : integer :=  23;
	constant reg_vse           : integer :=  24;
	constant reg_vtotal        : integer :=  25;
	constant reg_pps           : integer :=  26;
	constant reg_sync_pol      : integer :=  27;

	constant reg_ws            : integer :=  32;
	constant reg_cur           : integer :=  40;
	constant reg_ext           : integer :=  44;

	constant val_total0        : std_logic_vector(7 downto 0) :=  "11111111";
	constant val_total1        : std_logic_vector(7 downto 0) :=  "00000000";
	constant val_total2        : std_logic_vector(7 downto 0) :=  "00000000";
	constant val_total3        : std_logic_vector(7 downto 0) :=  "00000000";
	constant val_ofs0          : std_logic_vector(7 downto 0) :=  "00000000";
	constant val_ofs1          : std_logic_vector(7 downto 0) :=  "00000000";
	constant val_ofs2          : std_logic_vector(7 downto 0) :=  "00000000";
	constant val_ofs3          : std_logic_vector(7 downto 0) :=  "00000000";
	constant val_fifo_treshold : std_logic_vector(7 downto 0) :=  "00000011";
	constant val_bpp           : std_logic_vector(7 downto 0) :=  "00000011";
	constant val_hbs           : std_logic_vector(7 downto 0) :=  "00000111";
	constant val_hss           : std_logic_vector(7 downto 0) :=  "00001000";
	constant val_hse           : std_logic_vector(7 downto 0) :=  "00001001";
	constant val_htotal        : std_logic_vector(7 downto 0) :=  "00001010";
	constant val_vbs           : std_logic_vector(7 downto 0) :=  "00000001";
	constant val_vss           : std_logic_vector(7 downto 0) :=  "00000010";
	constant val_vse           : std_logic_vector(7 downto 0) :=  "00000011";
	constant val_vtotal        : std_logic_vector(7 downto 0) :=  "00000100";
	constant val_pps           : std_logic_vector(7 downto 0) :=  "00000001";
	constant val_sync_pol      : std_logic_vector(7 downto 0) :=  "10000000";
	constant val_ws            : std_logic_vector(7 downto 0) :=  "00000010";

    type data_array is array (integer range <>) of std_logic_vector(v_dat_width-1 downto 0);-- Memory Type
	signal mem_data : data_array(0 to (2** v_adr_width-1) );  -- Local data
begin

	UUT : vga_core_v2
		port map (
            clk_i         =>clk_i,
            clk_en        =>clk_en,
            rst_i         =>rst_i,

            -- CPU bus interface
            dat_i         =>dat_i,
            dat_oi        =>dat_oi,
            dat_o         =>dat_o,
            cyc_i         =>cyc_i,
            ack_o         =>ack_o,
            ack_oi        =>ack_oi,
            err_o         =>err_o,
            err_oi        =>err_oi,
            we_i          =>we_i,
            accel_stb_i   =>accel_stb_i,
            pal_stb_i     =>pal_stb_i,
            reg_stb_i     =>reg_stb_i,
            adr_i         =>adr_i,
            sel_i         =>sel_i,

            -- video memory interface
            v_adr_o       =>v_adr_o,
            v_sel_o       =>v_sel_o,
            v_dat_i       =>v_dat_i,
            v_dat_o       =>v_dat_o,
            v_cyc_o       =>v_cyc_o,
            v_ack_i       =>v_ack_i,
            v_we_o        =>v_we_o,
            v_stb_o       =>v_stb_o,

            -- sync blank and video outputs
            h_sync        =>h_sync,
            h_blank       =>h_blank,
            v_sync        =>v_sync,
            v_blank       =>v_blank,
            h_tc          =>h_tc,
            v_tc          =>v_tc,
            blank         =>blank,
            video_out     =>video_out,
            true_color_out=>true_color_out
		);

	-- Add your stimulus here ...

	clk_en <= '1';
	-- Add your stimulus here ...
	clock: process is
	begin
		wait for 25 ns;
		clk_i <= '1';
		wait for 25 ns;
		clk_i <= '0';
	end process;

	ack_oi <= '1';
	err_oi <= '1';
	dat_oi <= (others => '0');

	setup: process is
	begin
	    sel_i <= (others => '1');
		we_i <= '0';
		reg_stb_i <= '0';
		accel_stb_i <= '0';
		pal_stb_i <= '0';
		cyc_i <= '0';
		rst_i <= '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		rst_i <= '0';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';

		if (cpu_dat_width = 8) then
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_total0            ,val_total0);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_total1            ,val_total1);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_total2            ,val_total2);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_total3            ,val_total3);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_ofs0              ,val_ofs0);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_ofs1              ,val_ofs1);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_ofs2              ,val_ofs2);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_ofs3              ,val_ofs3);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_ws                ,val_ws);

			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';

			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_fifo_treshold     ,val_fifo_treshold);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_bpp               ,val_bpp);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_hbs               ,val_hbs);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_hss               ,val_hss);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_hse               ,val_hse);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_htotal            ,val_htotal);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_vbs               ,val_vbs);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_vss               ,val_vss);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_vse               ,val_vse);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_vtotal            ,val_vtotal);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_pps               ,val_pps);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_sync_pol          ,val_sync_pol);

			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,0   ,"00000001");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,1   ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,2   ,"00000010");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,3   ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,4   ,"00000100");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,5   ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,6   ,"00001000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,7   ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,8   ,"00010000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,9   ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,10  ,"00100000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,11  ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,12  ,"01000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,13  ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,14  ,"10000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,15  ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,16  ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,17  ,"00000001");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,18  ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,19  ,"00000010");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,20  ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,21  ,"00000100");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,22  ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,23  ,"00001000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,24  ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,25  ,"00010000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,26  ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,27  ,"00100000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,28  ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,29  ,"01000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,30  ,"00000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,31  ,"10000000");
		end if;
		if (cpu_dat_width = 16) then
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_total0/2 ,val_total1 & val_total0);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_total2/2 ,val_total3 & val_total2);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_ofs0/2   ,val_ofs1 & val_ofs0);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_ofs2/2   ,val_ofs3 & val_ofs2);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_ws/2     ,"00000000" & val_ws );

			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';

			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_fifo_treshold/2 ,val_bpp & val_fifo_treshold);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_hbs/2           ,val_hss & val_hbs);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_hse/2           ,val_htotal & val_hse);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_vbs/2           ,val_vss & val_vbs);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_vse/2           ,val_vtotal & val_vse);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_pps/2           ,val_sync_pol & val_pps);


			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,0   ,"0000000000000001");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,1   ,"0000000000000010");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,2   ,"0000000000000100");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,3   ,"0000000000001000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,4   ,"0000000000010000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,5   ,"0000000000100000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,6   ,"0000000001000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,7   ,"0000000010000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,8   ,"0000000100000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,9   ,"0000001000000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,10  ,"0000010000000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,11  ,"0000100000000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,12  ,"0001000000000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,13  ,"0010000000000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,14  ,"0100000000000000");
			wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,pal_stb_i,ack_o,15  ,"1000000000000000");

            wait for 90us;
    		wait until clk_i'EVENT and clk_i = '1';
    
    		-- Set Cursor to 0
    		wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_cur/2 ,"0000000000000000");
    		-- Accel index 0 is 0
    		wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,0,"0000000000000000");
    		-- Accel index 1 is 1
    		wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,1,"0000000000000001");
    		-- Accel index 2 is 3
    		wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2,"0000000000000011");
    		-- Accel index 3 is -1
    		wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,3,"1111111111111111");
    
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+0,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+1,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+1,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+3,"1111000011110000");
    
    		chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_cur/2,"0000000000000001");
    		
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+3,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+2,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+2,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+2,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+3,"1111000011110000");
    
    		chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_cur/2,"0000000000001000");
    		
    		-- Set Cursor to 16
    		wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_cur/2,"0000000000010000");
    
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+0,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+1,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+1,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+3,"1111000011110000");
    
    		chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_cur/2,"0000000000010001");
    		
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+3,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+2,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+2,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+2,"1111000011110000");
    		wr_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,accel_stb_i,ack_o,2**accel_size+3,"1111000011110000");
    
    		chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_cur/2,"0000000000011000");
    		
    		-- Set Cursor to 0
    		wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_cur/2,"0000000000000000");
    

		end if;
		if (cpu_dat_width = 32) then
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_total0/4 ,val_total3 & val_total2 & val_total1 & val_total0);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_ofs0/4   ,val_ofs3 & val_ofs2 & val_ofs1 & val_ofs0);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_ws/4     ,"000000000000000000000000" & val_ws );

			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';
			wait until clk_i'EVENT and clk_i = '1';

			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_fifo_treshold/4 ,val_hss & val_hbs & val_bpp & val_fifo_treshold);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_hse/4           ,val_vss & val_vbs & val_htotal & val_hse);
			wr_chk_val(clk_i, adr_i,dat_o,dat_i,we_i,cyc_i,reg_stb_i,ack_o,reg_vse/4           ,val_sync_pol & val_pps & val_vtotal & val_vse);
		end if;

		wait;
	end process;


	ram: process is
--        type data_array is array (integer range <>) of std_logic_vector(v_dat_width-1 downto 0);-- Memory Type
--        variable data : data_array(0 to (2** v_adr_width-1) );  -- Local data
        variable init: boolean := true;
	begin
	    if (init) then
            for i in mem_data'RANGE loop
				mem_data(i) <= CONV_STD_LOGIC_VECTOR(i,v_dat_width);
--                data(i) := (others => '0');
            end loop;
	        init := false;
	    end if;
	    
	    wait on clk_i, v_cyc_o, v_stb_o, v_we_o, v_dat_o;
	    if (v_cyc_o = '1' and v_stb_o = '1') then
	        v_ack_i <= '1';
	    else
	        v_ack_i <= '0';
	    end if;
	    
	    if (clk_i'EVENT and clk_i = '1' and v_cyc_o = '1' and v_stb_o = '1' and v_we_o = '1') then
	        mem_data(CONV_INTEGER(v_adr_o)) <= v_dat_o;
	        v_dat_i <= (others => 'U');
	    elsif (v_cyc_o = '1' and v_stb_o = '1' and v_we_o = '0') then
	        v_dat_i <= mem_data(CONV_INTEGER(v_adr_o));
--			v_dat_i <= v_adr_o(v_dat_i'RANGE);
	    else
	        v_dat_i <= (others => 'U');
	    end if;
	end process;

end TB;

