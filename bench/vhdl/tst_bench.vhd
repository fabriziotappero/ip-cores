--
-- Testbench for memory controller
--
-- Uses VGA controller as master device
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity testbench is
end entity;

architecture test of testbench is
	--
	-- component declarations
	--

	-- VHDL declaration of module mc_top
	component mc_top is
		port(
			clk, rst : in std_logic;

			----------------------------------------
			-- WISHBONE SLAVE INTERFACE 
			wb_data_i : in std_logic_vector(31 downto 0);
			wb_data_o : out std_logic_vector(31 downto 0);
			wb_addr_i : in std_logic_vector(31 downto 0);
			wb_sel_i : in std_logic_vector(3 downto 0);
			wb_we_i : in std_logic;
			wb_cyc_i : in std_logic;
			wb_stb_i : in std_logic;
			wb_ack_o : out std_logic;
			wb_err_o : out std_logic;

			----------------------------------------
			-- Suspend Resume Interface
			susp_req : in std_logic;
			resume_req : in std_logic;
			suspended : out std_logic;

			-- POC
			poc : out std_logic_vector(31 downto 0);

			----------------------------------------
			-- Memory Bus Signals
			mc_clk : in std_logic;
			mc_br : in std_logic;
			mc_bg : out std_logic;
			mc_ack : in std_logic;
			mc_addr : out std_logic_vector(23 downto 0);
			mc_data_i : in std_logic_vector(31 downto 0);
			mc_data_o : out std_logic_vector(31 downto 0);
			mc_dp_i : in std_logic_vector(3 downto 0);
			mc_dp_o : out std_logic_vector(3 downto 0);
			mc_data_oe : out std_logic;
			mc_dqm : out std_logic_vector(3 downto 0);
			\mc_oe_\ : out std_logic;
			\mc_we_\ : out std_logic;
			\mc_cas_\ : out std_logic;
			\mc_ras_\ : out std_logic;
			\mc_cke_\ : out std_logic;
			\mc_cs_\ : out std_logic_vector(7 downto 0);
			mc_sts : in std_logic;
			\mc_rp_\ : out std_logic;
			mc_vpen : out std_logic;
			\mc_adsc_\ : out std_logic;
			\mc_adv_\ : out std_logic;
			mc_zz : out std_logic;
			mc_c_oe : out std_logic
		);
	end component mc_top;

	-- sdram (Micron)
	component mt48lc2m32b2 is
		generic(
			addr_bits : natural := 11;
			data_bits : natural := 32;
			col_bits  : natural :=  8;
			mem_sizes : natural := 524287
		);
		port(
			dq : inout std_logic_vector(data_bits -1 downto 0);

			addr : in std_logic_vector(addr_bits -1 downto 0);
			ba : in std_logic_vector(1 downto 0);

			clk : in std_logic;
			cke : in std_logic;
			cs_n : in std_logic;
			
			ras_n : in std_logic;
			cas_n : in std_logic;
			we_n : in std_logic;
			dqm : in std_logic_vector(3 downto 0)
		);
	end component mt48lc2m32b2;

	-- sram (cypress Cy7C185-20)
	component A8Kx8 is
	generic (
		Trc  :   TIME    :=   20 ns;
		Taa  :   TIME    :=   20 ns;
		Toha :   TIME    :=   05 ns;
		Tace :   TIME    :=   20 ns;
		Tdoe :   TIME    :=   09 ns;
		Thzoe:   TIME    :=   08 ns;
		Thzce:   TIME    :=   08 ns;
		Twc  :   TIME    :=   20 ns;
		Tsce :   TIME    :=   15 ns;
		Taw  :   TIME    :=   15 ns;
		Tha  :   TIME    :=   0 ns;
		Tsa  :   TIME    :=   0 ns;
		Tpwe :   TIME    :=   15 ns;
		Tsd  :   TIME    :=   10 ns;
		Thd  :   TIME    :=   0 ns
	);
	port (
		CE_b, WE_b, OE_n : IN Std_Logic;
		A : IN Std_Logic_Vector(12 downto 0);
		IO : INOUT Std_Logic_Vector(7 downto 0):=(others=>'Z')
	);
	end component A8Kx8;

	-- vga controller 
	component VGA is
	port (
		CLK_I : in std_logic;
		RST_I : in std_logic := '0';
		NRESET : in std_logic := '1';
		INTA_O : out std_logic;

		-- slave signals
		ADR_I : in unsigned(4 downto 2);                          -- only 32bit databus accesses supported
		SDAT_I : in std_logic_vector(31 downto 0);
		SDAT_O : out std_logic_vector(31 downto 0);
		SEL_I : in std_logic_vector(3 downto 0);
		WE_I : in std_logic;
		STB_I : in std_logic;
		CYC_I : in std_logic;
		ACK_O : out std_logic;
		ERR_O : out std_logic;
		
		-- master signals
		ADR_O : out unsigned(31 downto 2);
		MDAT_I : in std_logic_vector(31 downto 0);
		SEL_O : out std_logic_vector(3 downto 0);
		WE_O : out std_logic;
		STB_O : out std_logic;
		CYC_O : out std_logic;
		CAB_O : out std_logic;
		ACK_I : in std_logic;
		ERR_I : in std_logic;

		-- VGA signals
		PCLK : in std_logic;                     -- pixel clock
		HSYNC : out std_logic;                   -- horizontal sync
		VSYNC : out std_logic;                   -- vertical sync
		CSYNC : out std_logic;                   -- composite sync
		BLANK : out std_logic;                   -- blanking signal
		R,G,B : out std_logic_vector(7 downto 0) -- RGB color signals
	);
	end component vga;
	
	-- wishbone host. Testvector generator
	component wb_host is
	port(
		clk_i : in std_logic;
		rst_i : in std_logic;

		cyc_o : out std_logic;
		stb_o : out std_logic;
		we_o  : out std_logic;
		adr_o : out std_logic_vector(31 downto 0);
		dat_o : out std_logic_vector(31 downto 0);
		dat_i : in std_logic_vector(31 downto 0);
		sel_o : out std_logic_vector(3 downto 0);
		ack_i : in std_logic;
		err_i : in std_logic
	);
	end component wb_host;

	--
	-- signal declarations
	--
	signal clk, clk2, vga_clk : std_logic := '0';                 -- initially clear clocks
	signal rst, init          : std_logic := '0';                 -- reset signal
	
	-- memory controller signals
	signal mc_data_i, mc_data_o : std_logic_vector(31 downto 0);  -- memory controller data-in/data-out signals
	signal mc_data_oe : std_logic;                                -- memory controller data-lines tri-state control
	signal mc_data : std_logic_vector(31 downto 0);               -- memory controller data-lines (tri-state signals)

	signal \mc_cs_\ : std_logic_vector(7 downto 0);               -- memory controller chip-select outputs

	signal \mc_oe_\ : std_logic;																										-- memory controller output_enable signal

	signal \mc_ras_\, \mc_cas_\, \mc_cke_\, \mc_we_\ : std_logic; -- memory controller SDRAM control signals
	signal mc_dqm : std_logic_vector(3 downto 0);

	signal mc_addr : std_logic_vector(23 downto 0);               -- memory controller address output

	-- memory controller wishbone signals
	signal mc_cyc_i, mc_stb_i, mc_we_i : std_logic;
	signal mc_adr_i                    : std_logic_vector(31 downto 0);
	signal mc_dat_o                    : std_logic_vector(31 downto 0);
	signal mc_sel_i                    : std_logic_vector(3 downto 0);
	signal mc_ack_o, mc_err_o          : std_logic;
	signal mc_ack_o_temp : std_logic;

	-- memory controller additional signals
	signal mc_susp_req, mc_resume_req  : std_logic := '0';
	signal mc_br, mc_ack, mc_sts       : std_logic := '0';
	signal mc_dp_i                     : std_logic_vector(3 downto 0);

	-- vga wishbone signals
	signal vga_cyc_o, vga_stb_o, vga_we_o, vga_ack_i  : std_logic;
	signal vga_adr_o                                  : std_logic_vector(31 downto 2);
	signal vga_dat_o                                  : std_logic_vector(31 downto 0);
	signal vga_sel_o                                  : std_logic_vector(3 downto 0);
	signal vga_stb_i, vga_ack_o, vga_err_o, vga_err_i : std_logic;

	-- host wishbone signals
	signal h_cyc_o, h_stb_o, h_we_o  : std_logic;
	signal h_adr_o                   : std_logic_vector(31 downto 0);
	signal h_dat_o, h_dat_i          : std_logic_vector(31 downto 0);
	signal h_sel_o                   : std_logic_vector(3 downto 0);
	signal h_ack_i, h_err_i          : std_logic;

begin

	-- generate clocks
	clk_block: block
	begin
		process(clk)
		begin
			clk <= not clk after 2.5 ns; -- 200MHz wishbone clock
			if (clk = '1') then
				clk2 <= not clk2; -- after 0.5 ns; -- some delay
			end if;
		end process;

		process(vga_clk)
		begin
			vga_clk <= not vga_clk after 12.5 ns; -- 40MHz vga clock
		end process;
	end block clk_block;

	-- generate reset signal
	gen_rst: process(init, rst)
	begin
		if (init = '0') then
			rst <= '1' after 100 ns;
			init <= '1';
		end if;
	end process gen_rst;

	-- generate mini-TCOP
	mini_tcop: block
		signal sel_vga, dh_cyc_o : std_logic;
	begin
		process(clk)
		begin
			if (clk'event and clk = '1') then
				sel_vga <= vga_cyc_o and not (h_cyc_o and dh_cyc_o and not sel_vga);
				dh_cyc_o <= h_cyc_o;
			end if;
		end process;

		mc_cyc_i <= vga_cyc_o or h_cyc_o;
		mc_stb_i <= vga_stb_o when (sel_vga = '1') else h_stb_o;
		mc_we_i  <= vga_we_o  when (sel_vga = '1') else h_we_o;
		mc_adr_i <= (vga_adr_o & "00") when (sel_vga = '1') else h_adr_o;
		mc_sel_i <= vga_sel_o when (sel_vga = '1') else h_sel_o;

		vga_ack_i <= sel_vga and mc_ack_o;
		vga_err_i <= sel_vga and mc_err_o;

		h_ack_i <= vga_ack_o or (not sel_vga and mc_ack_o);
		h_err_i <= vga_err_o or (not sel_vga and mc_err_o);
	end block mini_tcop;

	-- hookup device under test
	dut: mc_top port map (clk => clk, rst => rst, mc_clk => clk2, mc_data_i => mc_data, mc_data_o => mc_data_o, mc_data_oe => mc_data_oe,
		mc_addr => mc_addr, \mc_ras_\ => \mc_ras_\, \mc_cas_\ => \mc_cas_\, \mc_we_\ => \mc_we_\, \mc_cs_\ => \mc_cs_\, \mc_cke_\ => \mc_cke_\,
		mc_dqm => mc_dqm, \mc_oe_\ => \mc_oe_\,
		wb_data_i => h_dat_o, wb_data_o => mc_dat_o, wb_addr_i => mc_adr_i, wb_sel_i => mc_sel_i, wb_we_i => mc_we_i, wb_cyc_i => mc_cyc_i, 
		wb_stb_i => mc_stb_i, wb_ack_o => mc_ack_o, wb_err_o => mc_err_o,
		susp_req => mc_susp_req, resume_req => mc_resume_req, mc_br => mc_br, mc_ack => mc_ack, mc_dp_i => mc_dp_i, mc_sts => mc_sts);

	-- generate tri-state outputs for DUT
	mc_data <= mc_data_o when (mc_data_oe = '1') else (others => 'L');

	-- hookup sdram
	sdram: mt48lc2m32b2 port map(clk => clk2, cke => \mc_cke_\, cs_n => \mc_cs_\(1), ras_n => \mc_ras_\, cas_n => \mc_cas_\, we_n => \mc_we_\,
		dq => mc_data, dqm => mc_dqm, addr => mc_addr(10 downto 0), ba(0) => mc_addr(14), ba(1) => mc_addr(13) );

	-- hookup srams
	sram0: a8kx8 port map(ce_b => \mc_cs_\(2), we_b => \mc_we_\, oe_n => \mc_oe_\, A => mc_addr(12 downto 0), io => mc_data( 7 downto  0) );
	sram1: a8kx8 port map(ce_b => \mc_cs_\(2), we_b => \mc_we_\, oe_n => \mc_oe_\, A => mc_addr(12 downto 0), io => mc_data(15 downto  8) );
	sram2: a8kx8 port map(ce_b => \mc_cs_\(2), we_b => \mc_we_\, oe_n => \mc_oe_\, A => mc_addr(12 downto 0), io => mc_data(23 downto 16) );
	sram3: a8kx8 port map(ce_b => \mc_cs_\(2), we_b => \mc_we_\, oe_n => \mc_oe_\, A => mc_addr(12 downto 0), io => mc_data(31 downto 24) );

	-- hookup vga controller
	vga_stb_i <= h_stb_o and h_adr_o(31) and not h_adr_o(30);
	vga_core: vga port map(clk_i => clk, pclk => vga_clk, nreset => rst,
		cyc_o => vga_cyc_o, stb_o => vga_stb_o, we_o => vga_we_o, std_logic_vector(adr_o) => vga_adr_o, sel_o => vga_sel_o, ack_i => mc_ack_o, 
		err_i => vga_err_i, mdat_i => mc_dat_o, cyc_i => h_cyc_o, stb_i => vga_stb_i, we_i => h_we_o, adr_i => unsigned(h_adr_o(4 downto 2)), 
		sel_i => h_sel_o, ack_o => vga_ack_o, err_o => vga_err_o, sdat_i => h_dat_o, sdat_o => vga_dat_o);

	-- hookup wishbone host (testvector generator)
	h_dat_i <= vga_dat_o when (h_adr_o(31 downto 30) = "10") else mc_dat_o;
	host: wb_host port map (clk_i => clk, rst_i => rst, cyc_o => h_cyc_o, stb_o => h_stb_o, we_o => h_we_o, adr_o => h_adr_o, dat_o => h_dat_o,
		dat_i => h_dat_i, sel_o => h_sel_o, ack_i => h_ack_i, err_i => h_err_i);
end architecture;




library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
library std;
use std.standard.all;

entity wb_host is
	port(
		clk_i : in std_logic;
		rst_i : in std_logic;

		cyc_o : out std_logic;
		stb_o : out std_logic;
		we_o  : out std_logic;
		adr_o : out std_logic_vector(31 downto 0);
		dat_o : out std_logic_vector(31 downto 0);
		dat_i : in std_logic_vector(31 downto 0);
		sel_o : out std_logic_vector(3 downto 0);
		ack_i : in std_logic;
		err_i : in std_logic
	);
end entity wb_host;

architecture behavioral of wb_host is
	-------------------------------------------
	-- convert a std_logic value to a character
	-------------------------------------------
	type stdlogic_to_char_t is array(std_logic) of character;
	constant to_char : stdlogic_to_char_t := (
		'U' => 'U',
		'X' => 'X',
		'0' => '0',
		'1' => '1',
		'Z' => 'Z',
		'W' => 'W',
		'L' => 'L',
		'H' => 'H',
		'-' => '-');

	-----------------------------------------
	-- convert a std_logic_vector to a string
	-----------------------------------------
	function slv_to_string(inp : std_logic_vector) return string is
		alias vec : std_logic_vector(1 to inp'length) is inp;
		variable result : string(vec'range);
	begin
		for i in vec'range loop
			result(i) := to_char(vec(i));
		end loop;
		return result;
	end;

	-- type declarations
	type vector_type is 
		record
			adr   : std_logic_vector(31 downto 0); -- wishbone address output
			we    : std_logic;                     -- wishbone write enable output
			dat   : std_logic_vector(31 downto 0); -- wishbone data output (write) or input compare value (read)
			sel   : std_logic_vector(3 downto 0);  -- wishbone byte select output
			burst : std_logic;                     -- perform next cycle as part of a burst
			stop  : std_logic;                     -- last field, stop wishbone activities
		end record;

	type vector_list is array(0 to 102) of vector_type;

	type states is (chk_stop, assert_cyc, gen_cycle);

	-- signal declarations
	signal state : states;
	signal cnt : natural := 0;
	signal cyc, stb : std_logic;
	signal cyc_delay : natural := 0;

	shared variable vectors : vector_list :=
		(
			-- program memory controller
			(x"E0000008",'1',x"000000FF","1111",'0','0'), --0 program base address register
			(x"E0000008",'0',x"000000FF","1111",'0','0'),    -- verify written data
			(x"E0000000",'1',x"61000400","1111",'0','0'), --2 memory controller CSR register
			(x"E0000000",'0',x"61000400","1111",'0','0'),    -- verify written data
			(x"E0000008",'0',x"000000FF","1111",'0','0'),    -- re-read BA_MASK (bug ???) => fixed
					-- program SDRAM chip select
			(x"E0000018",'1',x"00800421","1111",'0','0'), --5 program chip-select 1 config register (sdram, 32bit, 0x10000000)
			(x"E0000018",'0',x"00800421","1111",'0','0'),    -- verify written data
			(x"E000001c",'1',x"07260232","1111",'0','0'), --7 program TMS1 register (bl=4, bt=seq, cl=3, wbl=1)
			(x"E000001c",'0',x"07260232","1111",'0','0'),    -- verify written data

					-- write some data in sdrams
			(x"10000000",'1',x"01234567","1111",'0','0'), --9 write data in sdram
	(x"E0000018",'1',x"00800421","1111",'0','0'), --5 program chip-select 1 config register (sdram, 32bit, 0x10000000)
	(x"E0000018",'0',x"00800421","1111",'0','0'),    -- verify written data
	(x"E000001c",'1',x"07260232","1111",'0','0'), --7 program TMS1 register (bl=4, bt=seq, cl=3, wbl=1)
	(x"E000001c",'0',x"07260232","1111",'0','0'),    -- verify written data

			(x"10000004",'1',x"89abcdef","1111",'0','0'),
			(x"10000008",'1',x"00112233","1111",'0','0'),
			(x"1000000C",'1',x"44556677","1111",'0','0'),
			(x"10000010",'1',x"8899aabb","1111",'0','0'),
			(x"10000014",'1',x"ccddeeff","1111",'0','0'),

			(x"10000000",'0',x"01234567","1111",'0','0'), --15 verify data in sdram
			(x"10000004",'0',x"89abcdef","1111",'1','0'),
			(x"10000008",'0',x"00112233","1111",'1','0'),
			(x"1000000C",'0',x"44556677","1111",'1','0'),
			(x"10000010",'0',x"8899aabb","1111",'1','0'),
			(x"10000014",'0',x"ccddeeff","1111",'1','0'),

					-- write more data in sdrams (different column)
			(x"10000200",'1',x"01234567","1111",'0','0'), --21 write data in sdram
			(x"10000204",'1',x"89abcdef","1111",'0','0'),
			(x"10000208",'1',x"00112233","1111",'0','0'),
			(x"1000020C",'1',x"44556677","1111",'0','0'),
			(x"10000210",'1',x"8899aabb","1111",'0','0'),
			(x"10000214",'1',x"ccddeeff","1111",'0','0'),

			(x"10000200",'0',x"01234567","1111",'0','0'), --27 verify data in sdram
			(x"10000204",'0',x"89abcdef","1111",'1','0'),
			(x"10000208",'0',x"00112233","1111",'1','0'),
			(x"1000020C",'0',x"44556677","1111",'1','0'),
			(x"10000210",'0',x"8899aabb","1111",'1','0'),
			(x"10000214",'0',x"ccddeeff","1111",'1','0'),

				-- write to another bank in sdram memory (BAS = 0)
			(x"10000400",'1',x"01234567","1111",'0','0'), --33 write data in sdram
			(x"10000404",'1',x"89abcdef","1111",'0','0'),
			(x"10000408",'1',x"00112233","1111",'0','0'),
			(x"1000040C",'1',x"44556677","1111",'0','0'),
			(x"10000410",'1',x"8899aabb","1111",'0','0'),
			(x"10000414",'1',x"ccddeeff","1111",'0','0'),

			(x"10000400",'0',x"01234567","1111",'0','0'), --39 verify data in sdram
			(x"10000404",'0',x"89abcdef","1111",'1','0'),
			(x"10000408",'0',x"00112233","1111",'1','0'),
			(x"1000040C",'0',x"44556677","1111",'1','0'),
			(x"10000410",'0',x"8899aabb","1111",'1','0'),
			(x"10000414",'0',x"ccddeeff","1111",'1','0'),

					-- program SRAM timing register
			(x"E0000024",'1',x"00001201","1111",'0','0'), --45 program TMS2 register (Twwd=5(10)ns, Twd=0(0)ns, Twpw=15(20)ns, Trdz=8(10)ns, Trdv=20(20)ns read after 30ns)
			(x"E0000024",'0',x"00001201","1111",'0','0'), 			-- verify written data

					-- program SRAM chip select for 32bit wide databus
			(x"E0000020",'1',x"00810025","1111",'0','0'), --47 program chip-selec2 2 config register (sram, 32bit, 0x10200000)
			(x"E0000020",'0',x"00810025","1111",'0','0'), 			-- verify written data

					-- write some data in sram 
			(x"10200000",'1',x"a5a5a5a5","1111",'0','0'), --49 write data in srams
			(x"10200004",'1',x"5a5a5a5a","1111",'0','0'),
			(x"10200008",'1',x"00112233","1111",'0','0'),

					-- verify data written
			(x"10200000",'0',x"a5a5a5a5","1111",'0','0'), --52 write data in srams
			(x"10200004",'0',x"5a5a5a5a","1111",'0','0'),
			(x"10200008",'0',x"00112233","1111",'0','0'),

					-- program SRAM chip select for 16bit wide databus
			(x"E0000020",'1',x"00810015","1111",'0','0'), --55 program chip-selec2 2 config register (sram, 16bit, 0x10200000)
			(x"E0000020",'0',x"00810015","1111",'0','0'), 			-- verify written data

					-- write some data in sram 
			(x"10200000",'1',x"00005a5a","1111",'0','0'), --57 write data in srams
			(x"10200002",'1',x"00005a5a","1111",'0','0'),
			(x"10200004",'1',x"0000a5a5","1111",'0','0'),
			(x"10200006",'1',x"0000a5a5","1111",'0','0'),
			(x"10200008",'1',x"00005566","1111",'0','0'),
			(x"1020000A",'1',x"00003344","1111",'0','0'),

					-- verify data written
			(x"10200000",'0',x"5a5a5a5a","1111",'0','0'), --63 write data in srams
			(x"10200004",'0',x"a5a5a5a5","1111",'0','0'),
			(x"10200008",'0',x"33445566","1111",'0','0'),

					-- program SRAM chip select for 8bit wide databus
			(x"E0000020",'1',x"00810005","1111",'0','0'), --66 program chip-selec2 2 config register (sram, 8bit, 0x10200000)
			(x"E0000020",'0',x"00810005","1111",'0','0'), 			-- verify written data


					--write some data in srams
			(x"10200000",'1',x"00000003","1111",'0','0'), --68 write data in srams (8bit srams; for write only single access is supported)
			(x"10200001",'1',x"00000002","1111",'0','0'),
			(x"10200002",'1',x"00000001","1111",'0','0'),
			(x"10200003",'1',x"00000000","1111",'0','0'),
			(x"10200004",'1',x"00000006","1111",'0','0'), --72
			(x"10200005",'1',x"00000005","1111",'0','0'),
			(x"10200006",'1',x"00000004","1111",'0','0'),
			(x"10200007",'1',x"00000000","1111",'0','0'),
			(x"1020008C",'1',x"00000009","1111",'0','0'), --76
			(x"1020008D",'1',x"00000008","1111",'0','0'),
			(x"1020008E",'1',x"00000007","1111",'0','0'),
			(x"1020008F",'1',x"00000000","1111",'0','0'),
			(x"10200114",'1',x"0000000c","1111",'0','0'), --80
			(x"10200115",'1',x"0000000b","1111",'0','0'),
			(x"10200116",'1',x"0000000a","1111",'0','0'),
			(x"10200117",'1',x"00000000","1111",'0','0'),
			(x"1020019C",'1',x"0000000f","1111",'0','0'), --84
			(x"1020019D",'1',x"0000000e","1111",'0','0'),
			(x"1020019E",'1',x"0000000d","1111",'0','0'),
			(x"1020019F",'1',x"00000000","1111",'0','0'),

			(x"10200000",'0',x"00010203","1111",'0','0'), --88 verify written data (read as 32bit data)
			(x"10200004",'0',x"00040506","1111",'0','0'),
			(x"1020008C",'0',x"00070809","1111",'0','0'),
			(x"10200114",'0',x"000a0b0c","1111",'0','0'),
			(x"1020019C",'0',x"000d0e0f","1111",'0','0'),

			-- program vga controller
			(x"80000008",'1',x"04090018","1111",'0','0'), --93 program horizontal timing register
			(x"8000000c",'1',x"05010002","1111",'0','0'), --   program vertical timing register
			(x"80000010",'1',x"00640064","1111",'0','0'), --   program horizontal/vertical length register (100x100 pixels)
			(x"80000014",'1',x"10000000","1111",'0','0'), --   program video base address 0 register (sdram)
			(x"8000001c",'1',x"10200000","1111",'0','0'), --   program color lookup table (sram)
			(x"80000000",'1',x"00000901","1111",'0','0')  --98 program control register (enable video system)

			-- end list
		);

begin
	process(clk_i, cnt, cyc_delay, ack_i, err_i)
		variable nxt_state : states;
		variable icnt : natural;
		variable icyc_delay : natural;
	begin

		nxt_state := state;
		icnt := cnt;
		icyc_delay := cyc_delay;

		case state is
			when chk_stop =>
				cyc <= '0';                          -- no valid bus-cycle
				stb <= '0';                          -- disable strobe output
--				if (vectors(cnt).stop = '0') then
				if (cnt /= vectors'high) then
					cyc <= '1';

					if (cyc_delay > 0) then
						nxt_state := assert_cyc;
						stb <= '0';
					else
						nxt_state := gen_cycle;
						stb <= '1';
					end if;
				else
					if (cyc_delay = 0) then
						icyc_delay := 1;
						icnt := 0;                       -- start testbench again, this time with a delay between STB and CYC assertion
					end if;
				end if;

			when assert_cyc =>
				cyc <= '1';
				stb <= '1';
				nxt_state := gen_cycle;

			when gen_cycle =>
				cyc <= '1';
				stb <= '1';

				if (ack_i = '1') or (err_i = '1') then

					icnt := cnt +1;
					if (cnt /= vectors'high) and (vectors(icnt).burst = '1') then
						nxt_state := gen_cycle;
						cyc <= '1';
						stb <= '1';
					else
						nxt_state := chk_stop;
						cyc <= '0';
						stb <= '0';
					end if;

					if (err_i = '1') then
						if (clk_i'event and clk_i = '1') then -- display warning only at rising edge of clock
--							report ("ERR_I asserted at vectorno. ")& cnt 
--									severity err0r;
							report ("ERR_I asserted at vectorno. ") severity error;
						end if;
					end if;

					if (vectors(cnt).we = '0') then
						if (vectors(cnt).dat /= dat_i) then
							if (clk_i'event and clk_i = '1') then -- display warning only at rising edge of clock
								report "DAT_I not equal to compare value. Expected " & slv_to_string(vectors(cnt).dat) & " received " & slv_to_string(dat_i)
									 severity error;
							end if;
						end if;
					end if;
				end if;
		end case;


		if (clk_i'event and clk_i = '1') then
			if (rst_i = '0') then
				state <= chk_stop;
				cyc_o <= '0';
				stb_o <= '0';
				adr_o <= (others => 'X');
				dat_o <= (others => 'X');
				we_o  <= 'X';
				sel_o <= (others => 'X');
			else
				state <= nxt_state;
				cyc_o <= cyc;
				stb_o <= stb;

				if (cyc = '1') then
					adr_o <= vectors(icnt).adr;
					dat_o <= vectors(icnt).dat;
					we_o  <= vectors(icnt).we;
					sel_o <= vectors(icnt).sel;
				else
					adr_o <= (others => 'X');
					dat_o <= (others => 'X');
					we_o  <= 'X';
					sel_o <= (others => 'X');
				end if;
			end if;

			cnt <= icnt;
			cyc_delay <= icyc_delay;
		end if;
	end process;

	-- fetch vector field
	-- check stop-bit
	-- if not(stop) generate wishbone bus-cycle
	-- wait for ack/err
	-- if (err) generate message
	-- if (read) compare dat_i and vector field dat_i
	-- if not equal generate message
end architecture behavioral;



