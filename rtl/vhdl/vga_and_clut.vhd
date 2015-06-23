--
-- file: vga_and_clut.vhd
-- project: VGA/LCD controller + Color Lookup Table
-- author: Richard Herveille
--
-- rev. 1.0 July  4th, 2001.
-- rev. 1.1 July 15th, 2001. Changed cycle_shared_memory to csm_pb. The core does not require a CLKx2 clock anymore.
--                           Added CLUT bank switching

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity vga_and_clut is
	port(
		CLK_I   : in std_logic;                         -- wishbone clock input
		RST_I   : in std_logic;                         -- synchronous active high reset
		NRESET  : in std_logic;                         -- asynchronous active low reset
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
end entity vga_and_clut;

architecture structural of vga_and_clut is
	--
	-- component declarations
	--
	component VGA is
	port (
		CLK_I : in std_logic;
		RST_I : in std_logic;
		NRESET : in std_logic;
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

	component csm_pb is
	generic(
		DWIDTH : natural := 32; -- databus width
		AWIDTH : natural := 8   -- addressbus width
	);
	port(
		-- SYSCON signals
		CLK_I   : in std_logic; -- wishbone clock input
		RST_I   : in std_logic; -- synchronous active high reset
		nRESET  : in std_logic; -- asynchronous active low reset

		-- wishbone slave0 connections
		ADR0_I : in unsigned(AWIDTH -1 downto 0);              -- address input
		DAT0_I : in std_logic_vector(DWIDTH -1 downto 0);      -- data input
		DAT0_O : out std_logic_vector(DWIDTH -1 downto 0);     -- data output
		SEL0_I : in std_logic_vector( (DWIDTH/8) -1 downto 0); -- byte select input
		WE0_I : in std_logic;                                  -- write enable input
		STB0_I : in std_logic;                                 -- strobe input
		CYC0_I : in std_logic;                                 -- valid bus cycle input
		ACK0_O : out std_logic;                                -- acknowledge output
		ERR0_O : out std_logic;                                -- error output

		-- wishbone slave1 connections
		ADR1_I : in unsigned(AWIDTH -1 downto 0);              -- address input
		DAT1_I : in std_logic_vector(DWIDTH -1 downto 0);      -- data input
		DAT1_O : out std_logic_vector(DWIDTH -1 downto 0);     -- data output
		SEL1_I : in std_logic_vector( (DWIDTH/8) -1 downto 0); -- byte select input
		WE1_I : in std_logic;                                  -- write enable input
		STB1_I : in std_logic;                                 -- strobe input
		CYC1_I : in std_logic;                                 -- valid bus cycle input
		ACK1_O : out std_logic;                                -- acknowledge output
		ERR1_O : out std_logic                                 -- error output
	);
	end component csm_pb;

	--
	-- Signal declarations
	--
	signal CBA : unsigned(31 downto 11); -- color lookup table base address

	signal vga_clut_acc : std_logic; -- vga access to color lookup table
	
	signal empty_data : std_logic_vector(23 downto 0); -- all zeros
	
	signal vga_ack_o, vga_ack_i, vga_err_o, vga_err_i : std_logic;
	signal vga_adr_o                                  : unsigned(31 downto 2);
	signal vga_dat_i, vga_dat_o                       : std_logic_vector(31 downto 0); -- vga master data input, vga slave data output
	signal vga_sel_o                                  : std_logic_vector(3 downto 0);
	signal vga_we_o, vga_stb_o, vga_cyc_o             : std_logic;

	signal vga_clut_stb : std_logic;

	signal mem0_dat_o, mem1_dat_o : std_logic_vector(23 downto 0);
	signal mem0_ack_o, mem0_err_o : std_logic;
	signal mem1_ack_o, mem1_err_o : std_logic;
begin
	--
	-- capture VGA CBAR access
	--
	process(CLK_I, nReset)
	begin
		if (nReset = '0') then
			CBA <= (others => '0');
		elsif (CLK_I'event and CLK_I = '1') then
			if (RST_I = '1') then
				CBA <= (others  => '0');
			elsif ( (SEL_I = "1111") and (CYC_I = '1') and (VGA_STB_I = '1') and (WE_I = '1') and (std_logic_vector(ADR_I(4 downto 2)) = "111") ) then
				CBA <= unsigned(SDAT_I(31 downto 11));
			end if;
		end if;
	end process;

	-- generate vga_clut_acc. Because CYC_O and STB_O are generated one clock cycle after ADR_O,
	-- vga_clut_acc may be synchronous.
	process(CLK_I)
	begin
		if (CLK_I'event and CLK_I = '1') then
			if (vga_adr_o(31 downto 11) = CBA) then
				vga_clut_acc <= '1';
			else
				vga_clut_acc <= '0';
			end if;
		end if;
	end process;

	--
	-- hookup vga controller
	--
	u1: VGA port map (CLK_I => CLK_I, RST_I => RST_I, NRESET => nReset, INTA_O => INTA_O,
					ADR_I => ADR_I(4 downto 2), SDAT_I => SDAT_I, SDAT_O => vga_dat_o, SEL_I => SEL_I, WE_I => WE_I, 
					STB_I => VGA_STB_I, CYC_I => CYC_I, ACK_O => vga_ack_o, ERR_O => vga_err_o,
					ADR_O => vga_adr_o, MDAT_I => vga_dat_i, SEL_O => vga_sel_o, WE_O => vga_we_o, STB_O => vga_stb_o,
					CYC_O => vga_cyc_o, CAB_O => CAB_O, ACK_I => vga_ack_i, ERR_I => vga_err_i,
					PCLK => PCLK, HSYNC => HSYNC, VSYNC => VSYNC, CSYNC => CSYNC, BLANK => BLANK, R => R, G => G, B => B);

	--
	-- hookup cycle shared memory
	--
	vga_clut_stb <= vga_stb_o when (vga_clut_acc = '1') else '0';

	empty_data <= (others => '0');
	u2: csm_pb 
			generic map (DWIDTH => 24, AWIDTH => 9)
			port map (CLK_I => CLK_I, RST_I => RST_I, nRESET => nReset,
				ADR0_I => vga_adr_o(10 downto 2), DAT0_I => empty_data, DAT0_O => mem0_dat_o, SEL0_I => vga_sel_o(2 downto 0), 
				WE0_I => vga_we_o, STB0_I => vga_clut_stb, CYC0_I => vga_cyc_o, ACK0_O => mem0_ack_o, ERR0_O => mem0_err_o,
				ADR1_I => ADR_I(10 downto 2), DAT1_I => SDAT_I(23 downto 0), DAT1_O => mem1_dat_o, SEL1_I => SEL_I(2 downto 0),
				WE1_I => WE_I, STB1_I => CLUT_STB_I, CYC1_I => CYC_I, ACK1_O => mem1_ack_o, ERR1_O => mem1_err_o);
	
	--
	-- assign outputs
	--

	-- wishbone master
	CYC_O <= '0' when (vga_clut_acc = '1') else vga_cyc_o;
	STB_O <= '0' when (vga_clut_acc = '1') else vga_stb_o;
	ADR_O <= vga_adr_o;
	SEL_O <= vga_sel_o;
	WE_O  <= vga_we_o;
	vga_dat_i(31 downto 24) <= MDAT_I(31 downto 24);
	vga_dat_I(23 downto  0) <= mem0_dat_o when (vga_clut_acc = '1') else MDAT_I(23 downto 0);
	vga_ack_i <= mem0_ack_o when (vga_clut_acc = '1') else ACK_I;
	vga_err_i <= mem0_err_o when (vga_clut_acc = '1') else ERR_I;

	-- wishbone slave
	SDAT_O <= (x"00" & mem1_dat_o) when (CLUT_STB_I = '1') else vga_dat_o;
	ACK_O  <= mem1_ack_o when (CLUT_STB_I = '1') else vga_ack_o;
	ERR_O  <= mem1_err_o when (CLUT_STB_I = '1') else vga_err_o;
end architecture structural;


