--
-- file: vga.vhd
-- project: VGA/LCD controller
-- author: Richard Herveille
--
-- rev 1.0 May  10th, 2001
-- rev 1.1 June  3th, 2001. Changed WISHBONE addresses. Addresses are byte oriented, instead of databus-independent
-- rev 1.2 June 29th, 2001. Many hanges in design to reflect changes in fifo's. Design now correctly maps to Xilinx-BlockRAMs.
-- rev 1.3 July 15th, 2001. Added CLUT bank switching

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity VGA is
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
end entity vga;

architecture dataflow of vga is
	--
	-- components
	--

	-- dual clock-fifo. Change the dual-port memory section, depending on the target technology
	component FIFO_DC is
	generic(
		DEPTH : natural := 128;
		DWIDTH : natural := 32
	);
	port(
		rclk : in std_logic;                          -- read clock input
		wclk : in std_logic;                          -- write clock input
		aclr : in std_logic := '1';                   -- active low asynchronous clear

		D : in std_logic_vector(DWIDTH -1 downto 0);  -- Data input
		wreq : in std_logic;                          -- write request

		Q : out std_logic_vector(DWIDTH -1 downto 0); -- Data output
		rreq : in std_logic;                          -- read request
		
		rd_empty,                                     -- FIFO is empty, synchronous to read clock
		rd_full,                                      -- FIFO is full, synchronous to read clock
		wr_empty,                                     -- FIFO is empty, synchronous to write clock
		wr_full : out std_logic                       -- FIFO is full, synchronous to write clock
	);
	end component FIFO_DC;

	-- WISHBONE slave block
	component wb_slave is
	port (
		CLK_I : in std_logic;
		RST_I : in std_logic;
		NRESET : in std_logic;
		ADR_I : in unsigned(4 downto 2);
		DAT_I : in std_logic_vector(31 downto 0);
		DAT_O : out std_logic_vector(31 downto 0);
		SEL_I : in std_logic_vector(3 downto 0);
		WE_I : in std_logic;
		STB_I : in std_logic;
		CYC_I : in std_logic;
		ACK_O : out std_logic;
		ERR_O : out std_logic;
		INTA_O : out std_logic;

		-- control register settings
		BL   : out std_logic;		                  -- blanking level
		CSL  : out std_logic;                    -- composite sync level
		VSL  : out std_logic;                    -- vsync level
		HSL  : out std_logic;                    -- hsync level
		PC   : out std_logic;                    -- pseudo color
 		CD   : out std_logic_vector(1 downto 0); -- color depth
		VBL  : out std_logic_vector(1 downto 0); -- burst length
		CBSW : out std_logic;                    -- clut bank switching enable
		VBSW : out std_logic;                    -- video page bank switching enable
		Ven  : out std_logic;                    -- video system enable

		-- status register inputs
		AVMP,                -- active video memory page
		ACMP : in std_logic; -- active clut page
		bsint_in,
		hint_in,
		vint_in,
		luint_in,
		sint_in : in std_logic; -- interrupt request signals

		-- Horizontal Timing Register
		Thsync : out unsigned(7 downto 0);
		Thgdel : out unsigned(7 downto 0);
		Thgate : out unsigned(15 downto 0);
		Thlen : out unsigned(15 downto 0);

		-- Vertical Timing Register
		Tvsync : out unsigned(7 downto 0);
		Tvgdel : out unsigned(7 downto 0);
		Tvgate : out unsigned(15 downto 0);
		Tvlen : out unsigned(15 downto 0);

		VBARa,
		VBARb : buffer unsigned(31 downto  2);
		CBAR  : buffer unsigned(31 downto 11)
	);
	end component wb_slave;

	-- WISHBONE master block
	component wb_master is
	port(
		-- WISHBONE signals
		CLK_I : in std_logic;                        -- master clock input
		RST_I : in std_logic;                        -- synchronous active high reset
		nRESET : in std_logic;                       -- asynchronous active low reset
		CYC_O : out std_logic;                       -- cycle output
		STB_O : out std_logic;                       -- strobe output
		CAB_O : out std_logic;                       -- Consecutive Address Burst output
		WE_O  : out std_logic;                       -- write enable output
		ADR_O : out unsigned(31 downto 2);           -- address output
		SEL_O : out std_logic_vector(3 downto 0);    -- Byte Select outputs (only 32bit accesses are supported)
		ACK_I : in std_logic;                        -- WISHBONE cycle acknowledge signal
		ERR_I : in std_logic;                        -- oops, bus-error
		DAT_I : in std_logic_vector(31 downto 0);    -- WISHBONE data in

		SINT : out std_logic;                        -- Non recoverable error, interrupt host

		-- control register settings
		ctrl_Ven : in std_logic;                     -- video enable bit
		ctrl_cd : in std_logic_vector(1 downto 0);   -- color depth
		ctrl_pc : in std_logic;                      -- 8bpp pseudo color/bw
		ctrl_vbl : in std_logic_vector(1 downto 0);  -- burst length
		ctrl_vbsw : in std_logic;                    -- enable video bank switching
		ctrl_cbsw : in std_logic;                    -- enable clut bank switching

		-- video memory addresses
		VBAa,                                        -- Video Memory Base Address-A
		VBAb : in unsigned(31 downto 2);             -- Video Memory Base Address-B
		CBA : in unsigned(31 downto 11);             -- CLUT Base Address Register

		Thgate : unsigned(15 downto 0);              -- horizontal visible area (in pixels)
		Tvgate : unsigned(15 downto 0);              -- vertical visible area (in horizontal lines)

		stat_AVMP : out std_logic;                   -- active video memory page
		stat_ACMP : out std_logic;                   -- active color lookup table
		bs_req : out std_logic;                      -- bank-switch request: memory page switched (when enabled). bs_req is always generated

		-- to/from line fifo
		line_fifo_wreq : out std_logic;
		line_fifo_d : out std_logic_vector(23 downto 0);
		line_fifo_full : in std_logic
	);
	end component wb_master;

	-- pixel generator. Generates video and pixel timing.
	component Pgen is
	port(
		mclk : in std_logic;                        -- master clock
		pclk : in std_logic;                        -- pixel clock

		ctrl_Ven : in std_logic;                    -- VideoEnable signal

		-- horizontal timing settings
		ctrl_HSyncL : in std_logic;                 -- horizontal sync pulse polarization level (pos/neg)
		Thsync : in unsigned(7 downto 0);           -- horizontal sync pulse width (in pixels)
		Thgdel : in unsigned(7 downto 0);           -- horizontal gate delay (in pixels)
		Thgate : in unsigned(15 downto 0);          -- horizontal gate (number of visible pixels per line)
		Thlen  : in unsigned(15 downto 0);          -- horizontal length (number of pixels per line)

		-- vertical timing settings
		ctrl_VSyncL : in std_logic;                 -- vertical sync pulse polarization level (pos/neg)
		Tvsync : in unsigned(7 downto 0);           -- vertical sync width (in lines)
		Tvgdel : in unsigned(7 downto 0);           -- vertical gate delay (in lines)
		Tvgate : in unsigned(15 downto 0);          -- vertical gate (visible number of lines in frame)
		Tvlen  : in unsigned(15 downto 0);          -- vertical length (number of lines in frame)
		
		ctrl_CSyncL : in std_logic;                 -- composite sync pulse polarization level
		ctrl_BlankL : in std_logic;                 -- blank signal polarization level

		-- status outputs
		eoh,                                        -- end of horizontal
		eov,                                        -- end of vertical
		Gate : out std_logic;                       -- vertical AND horizontal gate (logical AND function)

		-- pixel control outputs
		Hsync,                                      -- horizontal sync pulse
		Vsync,                                      -- vertical sync pulse
		Csync,                                      -- composite sync: Hsync OR Vsync (logical OR function)
		Blank : out std_logic                       -- blank signals
	);
	end component Pgen;

	--
	-- signals
	--

	-- from wb_slave
	signal ctrl_bl, ctrl_csl, ctrl_vsl, ctrl_hsl, ctrl_pc, ctrl_cbsw, ctrl_vbsw, ctrl_ven : std_logic;
	signal ctrl_cd, ctrl_vbl : std_logic_vector(1 downto 0);
	signal Thsync, Thgdel, Tvsync, Tvgdel : unsigned(7 downto 0);
	signal Thgate, Thlen, Tvgate, Tvlen : unsigned(15 downto 0);
	signal VBARa, VBARb : unsigned(31 downto 2);
	signal CBAR : unsigned(31 downto 11);

	-- to wb_slave
	signal stat_avmp, stat_acmp, bsint, hint, vint, luint, sint : std_logic;

	-- from wb_master
	signal line_fifo_wreq : std_logic;
	signal line_fifo_d : std_logic_vector(23 downto 0);

	-- from pixel generator
	signal cgate : std_logic; -- composite gate signal
	signal ihsync, ivsync, icsync, iblank : std_logic; -- intermediate horizontal/vertical/composite sync, intermediate blank
--	signal dhsync, dvsync, dcsync, dblank : std_logic; -- delayed intermedates (needed for fifo synchronization)

	-- from line fifo
	signal line_fifo_full_wr, line_fifo_empty_rd : std_logic;
	signal RGB : std_logic_vector(23 downto 0);
begin

	-- hookup wishbone slave
	u1: wb_slave port map (CLK_I => CLK_I, RST_I => RST_I, nRESET => nRESET, ADR_I => ADR_I, DAT_I => SDAT_I, DAT_O => SDAT_O,
			SEL_I => SEL_I, WE_I => WE_I, STB_I => STB_I, CYC_I => CYC_I, ACK_O => ACK_O, ERR_O => ERR_O, INTA_O => INTA_O,
			BL => ctrl_bl, csl => ctrl_csl, vsl => ctrl_vsl, hsl => ctrl_hsl, pc => ctrl_pc, cd => ctrl_cd, vbl => ctrl_vbl, 
			cbsw => ctrl_cbsw, vbsw => ctrl_vbsw, ven => ctrl_ven, acmp => stat_acmp, avmp => stat_avmp, bsint_in => bsint, 
			hint_in => hint, vint_in => vint, luint_in => luint, sint_in => sint, Thsync => Thsync, Thgdel => Thgdel, 
			Thgate => Thgate, Thlen => Thlen,	Tvsync => Tvsync, Tvgdel => Tvgdel, Tvgate => Tvgate, Tvlen => Tvlen,
			VBARa => VBARa, VBARb => VBARb, CBAR => CBAR);

	-- hookup wishbone master
	u2: wb_master port map (CLK_I => CLK_I, RST_I => RST_I, nReset => nReset, CYC_O => CYC_O, STB_O => STB_O, CAB_O => CAB_O, WE_O => WE_O,
			ADR_O => ADR_O, SEL_O => SEL_O, ACK_I => ACK_I, ERR_I => ERR_I, DAT_I => MDAT_I, SINT => sint,
			ctrl_Ven => ctrl_ven, ctrl_cd => ctrl_cd, ctrl_pc => ctrl_pc, ctrl_vbl => ctrl_vbl, ctrl_cbsw => ctrl_cbsw, ctrl_vbsw => ctrl_vbsw,
			VBAa => VBARa, VBAb => VBARb, CBA => CBAR, Thgate => Thgate, Tvgate => Tvgate, stat_acmp => stat_acmp, stat_AVMP => stat_avmp, 
			bs_req => bsint,	line_fifo_wreq => line_fifo_wreq, line_fifo_d => line_fifo_d, line_fifo_full => line_fifo_full_wr);

	-- hookup pixel and video timing generator
	u3: pgen port map (mclk => CLK_I, pclk => pclk, ctrl_Ven => ctrl_ven, 
			ctrl_HSyncL => ctrl_hsl, Thsync => Thsync, Thgdel => Thgdel, Thgate => Thgate, Thlen => Thlen, ctrl_VSyncL => ctrl_vsl, 
			Tvsync => Tvsync, Tvgdel => Tvgdel, Tvgate => Tvgate, Tvlen => Tvlen, ctrl_CSyncL => ctrl_csl, ctrl_BlankL => ctrl_bl,
			eoh => hint, eov => vint, gate => cgate, Hsync => ihsync, Vsync => ivsync, Csync => icsync, Blank => iblank);

	-- delay video control signals 1 clock cycle (dual clock fifo synchronizes output)
	del_video_sigs: process(pclk)
	begin
		if (pclk'event and pclk = '1') then
			HSYNC  <= ihsync;
			VSYNC  <= ivsync;
			CSYNC  <= icsync;
			BLANK  <= iblank;
		end if;
	end process del_video_sigs;

	-- hookup line-fifo
	u4: FIFO_DC generic map (DEPTH => 256, DWIDTH => 24)
					port map (rclk => pclk, wclk => CLK_I, aclr => ctrl_Ven, D => line_fifo_d, wreq => line_fifo_wreq,
									q => RGB, rreq => cgate, rd_empty => line_fifo_empty_rd, wr_full => line_fifo_full_wr);
	R <= RGB(23 downto 16);
	G <= RGB(15 downto 8);
	B <= RGB(7 downto 0);

	-- generate interrupt signal when reading line-fifo while it is empty (line-fifo under-run interrupt)
	luint_blk: block
		signal luint_pclk, sluint : std_logic;
	begin
		gen_luint_pclk: process(pclk)
		begin
			if (pclk'event and pclk = '1') then
				luint_pclk <= cgate and line_fifo_empty_rd;
			end if;
		end process gen_luint_pclk;

		process(CLK_I)
		begin
			if(CLK_I'event and CLK_I = '1') then
				sluint <= luint_pclk;	-- resample at CLK_I clock
				luint <= sluint;      -- sample again, reduce metastability risk
			end if;
		end process;
	end block luint_blk;

end architecture dataflow;






