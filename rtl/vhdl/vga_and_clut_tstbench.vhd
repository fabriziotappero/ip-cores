--
-- file: vga_and_clut_tstbench.vhd
-- project: VGA/LCD controller + Color Lookup Table
-- author: Richard Herveille
--
-- Testbench for VGA controller + CLUT combination
--
-- rev 1.0 July 4th, 2001.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity tst_bench is
end entity tst_bench;

architecture test of tst_bench is
	--
	-- component declarations
	--

	component vga_and_clut is
	port(
		CLK_I   : in std_logic;                         -- wishbone clock input
		RST_I   : in std_logic;                         -- synchronous active high reset
		NRESET  : in std_logic := '1';                  -- asynchronous active low reset
		INTA_O  : out std_logic;                        -- interrupt request output

		-- slave signals
		ADR_I      : in unsigned(10 downto 2);          -- addressbus input (only 32bit databus accesses supported)
		SDAT_I     : in std_logic_vector(31 downto 0);  -- Slave databus output
		SDAT_O     : out std_logic_vector(31 downto 0); -- Slave databus input
		SEL_I      : in std_logic_vector(3 downto 0);   -- byte select inputs
		WE_I       : in std_logic;                      -- write enabel input
		VGA_STB_I  : in std_logic;                      -- vga strobe/select input
		CLUT_STB_I : in std_logic;                      -- color-lookup-table strobe/select input
		CYC_I      : in std_logic;                      -- valid bus cycle input
		ACK_O      : out std_logic;                     -- bus cycle acknowledge output
		ERR_O      : out std_logic;                     -- bus cycle error output
		
		-- master signals
		ADR_O : out unsigned(31 downto 2);              -- addressbus output
		MDAT_I : in std_logic_vector(31 downto 0);      -- Master databus input
		SEL_O : out std_logic_vector(3 downto 0);       -- byte select outputs
		WE_O : out std_logic;                           -- write enable output
		STB_O : out std_logic;                          -- strobe output
		CYC_O : out std_logic;                          -- valid bus cycle output
		CAB_O : out std_logic;                          -- continuos address burst output
		ACK_I : in std_logic;                           -- bus cycle acknowledge input
		ERR_I : in std_logic;                           -- bus cycle error input

		-- VGA signals
		PCLK : in std_logic;                            -- pixel clock
		HSYNC : out std_logic;                          -- horizontal sync
		VSYNC : out std_logic;                          -- vertical sync
		CSYNC : out std_logic;                          -- composite sync
		BLANK : out std_logic;                          -- blanking signal
		R,G,B : out std_logic_vector(7 downto 0)        -- RGB color signals
	);
	end component vga_and_clut;

	component wb_host is
	generic(
		RST_LVL : std_logic := '0'                -- reset level
	);
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

	component vid_mem is
	generic(
		ACK_DELAY : natural := 2
	);
	port(
		clk_i : in std_logic;
		adr_i : in unsigned (15 downto 0);
		cyc_i : in std_logic;
		stb_i : in std_logic;
		dat_o : out std_logic_vector(31 downto 0);
		ack_o : out std_logic
	);
	end component vid_mem;

	--
	-- signal declarations
	--

	-- clock & reset
	signal clk, vga_clk : std_logic := '0';
	signal rst : std_logic := '1';
	signal init : std_logic := '0';

	-- wishbone host
	signal h_cyc_o, h_stb_o, h_we_o : std_logic;
	signal h_adr_o                  : unsigned(31 downto 0);
	signal h_dat_o, h_dat_i         : std_logic_vector(31 downto 0);
	signal h_sel_o                  : std_logic_vector(3 downto 0);
	signal h_ack_i, h_err_i         : std_logic;

	-- vga master
	signal vga_adr_o                       : unsigned(31 downto 2);
	signal vga_dat_i                       : std_logic_vector(31 downto 0);
	signal vga_stb_o, vga_cyc_o, vga_ack_i : std_logic;
	signal vga_sel_o                       : std_logic_vector(3 downto 0);
	signal vga_we_o, vga_err_i             : std_logic;

	-- vga
	signal r, g, b : std_logic_vector(7 downto 0);
	signal hsync, vsync, csync, blank : std_logic;
begin

	-- generate clocks
	clk_block: block
	begin
		process(clk)
		begin
			clk <= not clk after 2.5 ns; -- 200MHz wishbone clock
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
			rst <= '0' after 100 ns;
			init <= '1';
		end if;
	end process gen_rst;

	--
	-- hookup vga + clut core
	--
	u1: vga_and_clut port map (CLK_I => clk, RST_I => RST, ADR_I => h_adr_o(10 downto 2),
		SDAT_I => h_dat_o, SDAT_O => h_dat_i, SEL_I => h_sel_o, WE_I => h_we_o, VGA_STB_I => h_adr_o(31),
		CLUT_STB_I => h_adr_o(30), CYC_I => h_cyc_o, ACK_O => h_ack_i, ERR_O => h_err_i,
		ADR_O => vga_adr_o, MDAT_I => vga_dat_i, SEL_O => vga_sel_o, WE_O => vga_we_o, STB_O => vga_stb_o,
		CYC_O => vga_cyc_o, ACK_I => vga_ack_i, ERR_I => vga_err_i,
		PCLK => vga_clk, HSYNC => hsync, VSYNC => vsync, CSYNC => csync, BLANK => blank, R => r, G => g, B => b);

	--
	-- hookup wishbone host
	--
	u2: wb_host
		generic map (RST_LVL => '1')
		port map (clk_i => clk, rst_i => rst, cyc_o => h_cyc_o, stb_o => h_stb_o, we_o => h_we_o, unsigned(adr_o) => h_adr_o,
			dat_o => h_dat_o, dat_i => h_dat_i, sel_o => h_sel_o, ack_i => h_ack_i, err_i => h_err_i);

	u3: vid_mem 
			generic map (ACK_DELAY => 0)
			port map (clk_i => clk, adr_i => vga_adr_o(17 downto 2), cyc_i => vga_cyc_o, 
				stb_i => vga_stb_o, dat_o => vga_dat_i, ack_o => vga_ack_i);
end architecture test;

--
------------------------------------
-- Wishbone host behavioral model --
------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
library std;
use std.standard.all;

entity wb_host is
	generic(
		RST_LVL : std_logic := '1'                -- reset level
	);
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
	-- type declarations
	type vector_type is 
		record
			adr   : std_logic_vector(31 downto 0); -- wishbone address output
			we    : std_logic;                     -- wishbone write enable output
			dat   : std_logic_vector(31 downto 0); -- wishbone data output (write) or input compare value (read)
			sel   : std_logic_vector(3 downto 0);  -- wishbone byte select output
			stop  : std_logic;                     -- last field, stop wishbone activities
		end record;

	type vector_list is array(0 to 38) of vector_type;

	type states is (chk_stop, gen_cycle);

	-- signal declarations
	signal state : states;
	signal cnt : natural := 0;
	signal cyc, stb : std_logic;

	shared variable vectors : vector_list :=
		(
			-- fill clut (adr(30) = '1')
			(x"40000000",'1',x"00123456","1111",'0'), --0
			(x"40000004",'1',x"00789abc","1111",'0'),
			(x"40000008",'1',x"00def010","1111",'0'),
			(x"4000000C",'1',x"00010203","1111",'0'),
			(x"40000010",'1',x"00040506","1111",'0'),
			(x"40000014",'1',x"00070809","1111",'0'),
			(x"40000018",'1',x"000a0b0c","1111",'0'),
			(x"4000001C",'1',x"00102030","1111",'0'),
			(x"40000020",'1',x"00405060","1111",'0'),
			(x"40000024",'1',x"00708090","1111",'0'),
			(x"40000028",'1',x"00a0b0c0","1111",'0'),
			(x"4000002C",'1',x"00112233","1111",'0'),
			(x"40000030",'1',x"00445566","1111",'0'),
			(x"40000034",'1',x"00778899","1111",'0'),
			(x"40000038",'1',x"00aabbcc","1111",'0'),
			(x"4000003C",'1',x"00ddeeff","1111",'0'),

			-- verify data written
			(x"40000000",'0',x"00123456","1111",'0'), --16
			(x"40000004",'0',x"00789abc","1111",'0'),
			(x"40000008",'0',x"00def010","1111",'0'),
			(x"4000000C",'0',x"00010203","1111",'0'),
			(x"40000010",'0',x"00040506","1111",'0'),
			(x"40000014",'0',x"00070809","1111",'0'),
			(x"40000018",'0',x"000a0b0c","1111",'0'),
			(x"4000001C",'0',x"00102030","1111",'0'),
			(x"40000020",'0',x"00405060","1111",'0'),
			(x"40000024",'0',x"00708090","1111",'0'),
			(x"40000028",'0',x"00a0b0c0","1111",'0'),
			(x"4000002C",'0',x"00112233","1111",'0'),
			(x"40000030",'0',x"00445566","1111",'0'),
			(x"40000034",'0',x"00778899","1111",'0'),
			(x"40000038",'0',x"00aabbcc","1111",'0'),
			(x"4000003C",'0',x"00ddeeff","1111",'0'),

			-- program vga controller
			(x"80000008",'1',x"04090018","1111",'0'), --32 program horizontal timing register (25 visible pixels per line)
			(x"8000000c",'1',x"05010003","1111",'0'), --   program vertical timing register (4 visible lines per frame)
			(x"80000010",'1',x"00320016","1111",'0'), --   program horizontal/vertical length register (50x50 pixels)
			(x"80000014",'1',x"10000000","1111",'0'), --   program video base address 0 register (sdram)
			(x"8000001c",'1',x"10200000","1111",'0'), --   program color lookup table (sram)
			(x"80000000",'1',x"00000901","1111",'0'), --   program control register (enable video system)

			-- end list
			(x"00000000",'0',x"00000000","1111",'1')  --38 stop testbench
		);

begin
	process(clk_i, cnt, ack_i, err_i)
		variable nxt_state : states;
		variable icnt : natural;
	begin

		nxt_state := state;
		icnt := cnt;

		case state is
			when chk_stop =>
				cyc <= '0';                          -- no valid bus-cycle
				stb <= '0';                          -- disable strobe output
				if (vectors(cnt).stop = '0') then
					nxt_state := gen_cycle;
					cyc <= '1';
					stb <= '1';
				end if;

			when gen_cycle =>
				cyc <= '1';
				stb <= '1';
				if (ack_i = '1') or (err_i = '1') then
					nxt_state := chk_stop;
					cyc <= '0';
					stb <= '0';

					icnt := cnt +1;

					--
					-- check assertion of ERR_I
					--
					if (err_i = '1') then
						if (clk_i'event and clk_i = '1') then -- display warning only at rising edge of clock
--							report ("ERR_I asserted at vectorno. ")& cnt 
--									severity warning;
							report ("ERR_I asserted at vectorno. ") severity error;
						end if;
					end if;

					--
					-- compare DAT_I with expected data during ACK_I assertion
					--
					if (vectors(cnt).we = '0') then
						if (vectors(cnt).dat /= dat_i) then
							if (clk_i'event and clk_i = '1') then -- display warning only at rising edge of clock
--								report ("DAT_I not equal to compare value. Expected ")& vectors(cnt).dat_i & (" received ") & dat_i;
--									 severity warning;
								report ("DAT_I not equal to compare value") severity error;
							end if;
						end if;
					end if;

				end if;
		end case;


		if (clk_i'event and clk_i = '1') then
			if (rst_i = RST_LVL) then
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
					adr_o <= vectors(cnt).adr;
					dat_o <= vectors(cnt).dat;
					we_o  <= vectors(cnt).we;
					sel_o <= vectors(cnt).sel;
				else
					adr_o <= (others => 'X');
					dat_o <= (others => 'X');
					we_o  <= 'X';
					sel_o <= (others => 'X');
				end if;
			end if;

			cnt <= icnt;
		end if;
	end process;
end architecture behavioral;

--
------------------------
-- video memory (ROM) --
------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity vid_mem is
	generic(
		ACK_DELAY : natural := 2
	);
	port(
		clk_i : in std_logic;
		adr_i : in unsigned (15 downto 0);
		cyc_i : in std_logic;
		stb_i : in std_logic;
		dat_o : out std_logic_vector(31 downto 0);
		ack_o : out std_logic
	);
end entity vid_mem;

architecture behavioral of vid_mem is
	signal cnt : unsigned(2 downto 0) := conv_unsigned(ACK_DELAY, 3);
	signal my_ack : std_logic;
begin
	with adr_i(15 downto 0) select
		dat_o <= x"01020304" when x"0000",
		         x"05060708" when x"0001",
		         x"090a0b0c" when x"0002",
		         x"0d0e0f00" when x"0003",
              x"a5a5a5a5" when others;

		gen_ack: process(clk_i)
		begin
			if (clk_i'event and clk_i = '1') then
				if (my_ack = '1') then
					cnt <= conv_unsigned(ACK_DELAY, 3);
				elsif ((cyc_i = '1') and (stb_i = '1')) then
					cnt <= cnt -1;
				end if;
			end if;
		end process gen_ack;

		my_ack <= '1' when ((cyc_i = '1') and (stb_i = '1') and (cnt = 0)) else '0';
		ack_o <= my_ack;
end architecture behavioral;






