library ieee,exemplar;
use ieee.std_logic_1164.all;
use exemplar.exemplar_1164.all;

library wb_tk;
use wb_tk.wb_test.all;

library	wb_vga;
use wb_vga.all;
use wb_vga.constants.all;

entity vga_chip_tb is
end vga_chip_tb;

architecture TB of vga_chip_tb is
	-- Component declaration of the tested unit
    component vga_chip is
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
    		we_i: in std_logic;
    		vmem_stb_i: in std_logic;
    		reg_stb_i: in std_logic;
    		adr_i: in std_logic_vector (cpu_adr_width-1 downto 0);
            sel_i: in std_logic_vector ((cpu_dat_width/8)-1 downto 0) := (others => '1');
    
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
    end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk_i : std_logic;
	signal clk_en : std_logic;
	signal rst_i : std_logic;
	signal dat_i : std_logic_vector(cpu_dat_width-1 downto 0);
	signal dat_oi : std_logic_vector(cpu_dat_width-1 downto 0);
	signal cyc_i : std_logic;
	signal ack_oi : std_logic;
	signal we_i : std_logic;
	signal vmem_stb_i : std_logic;
	signal reg_stb_i : std_logic;
	signal adr_i : std_logic_vector(cpu_adr_width-1 downto 0);
    signal sel_i: std_logic_vector ((cpu_dat_width/8)-1 downto 0) := (others => '1');
	signal s_data : std_logic_vector(v_dat_width-1 downto 0);
	-- Observed signals - signals mapped to the output ports of tested entity
	signal dat_o : std_logic_vector(cpu_dat_width-1 downto 0);
	signal ack_o : std_logic;
	signal s_addr : std_logic_vector(v_adr_width-1 downto 0);
	signal s_oen : std_logic;
	signal s_wrhn : std_logic;
	signal s_wrln : std_logic;
	signal s_cen : std_logic;
	signal h_sync : std_logic;
	signal h_blank : std_logic;
	signal v_sync : std_logic;
	signal v_blank : std_logic;
	signal h_tc : std_logic;
	signal v_tc : std_logic;
	signal blank : std_logic;
	signal video_out : std_logic_vector(7 downto 0);

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
	
	constant val_total0        : std_logic_vector(7 downto 0) :=  "00001111";
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
	
begin

	-- Unit Under Test port map
	UUT : vga_chip
		port map (
			clk_i => clk_i,
			clk_en => clk_en,
			rst_i => rst_i,
			dat_i => dat_i,
			dat_oi => dat_oi,
			dat_o => dat_o,
			cyc_i => cyc_i,
			ack_o => ack_o,
			ack_oi => ack_oi,
			we_i => we_i,
			vmem_stb_i => vmem_stb_i,
			reg_stb_i => reg_stb_i,
			adr_i => adr_i,
			s_data => s_data,
			s_addr => s_addr,
			s_oen => s_oen,
			s_wrhn => s_wrhn,
			s_wrln => s_wrln,
			s_cen => s_cen,
			h_sync => h_sync,
			h_blank => h_blank,
			v_sync => v_sync,
			v_blank => v_blank,
			h_tc => h_tc,
			v_tc => v_tc,
			blank => blank,
			video_out => video_out
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
	
	ack_oi <= '0';
	dat_oi <= (others => '0');
	
	setup: process is
	begin
	    sel_i <= (others => '1');
		we_i <= '0';
		reg_stb_i <= '0';
		vmem_stb_i <= '0';
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

	s_ram: process is
	begin
		wait on s_data,s_addr,s_oen,s_wrhn,s_wrln,s_cen;
		if (s_cen = '0') then
			if (s_oen = '0') then
				s_data <= s_addr(v_dat_width-1 downto 0);
			elsif (s_wrhn = '0' or s_wrln = '0') then
				if (s_wrhn = '0') then
				else
				end if;
			else
				s_data <= (others => 'Z');
			end if;
		end if;
	end process;
	
end TB;

configuration TB_vga_chip of vga_chip_tb is
	for TB
		for UUT : vga_chip
			use entity wb_vga.vga_chip(vga_chip);
		end for;
	end for;
end TB_vga_chip;


--configuration SYNTH_vga_chip of vga_chip_tb is
--	for TB
--		for UUT : vga_chip
--			use entity work.vga_chip(ep1k30fc256_a1);
--		end for;
--	end for;
--end SYNTH_vga_chip;
--
--
