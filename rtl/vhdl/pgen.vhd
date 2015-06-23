--
-- File pgen.vhd, Video Pixel Generator
-- Project: VGA
-- Author : Richard Herveille
-- rev.: 0.1 April 19th, 2001. Initial release
-- rev.: 1.0 July  15th, 2001. Removed synchronized registers; static settings don't require synchronization.
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Pgen is
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
end entity Pgen;

architecture dataflow of Pgen is
	--
	-- Component declarations
	--
	component tgen is
	port(
		clk : in std_logic;
		rst : in std_logic;

		-- horizontal timing settings
		HSyncL : in std_logic;              -- horizontal sync pulse polarization level (pos/neg)
		Thsync : in unsigned(7 downto 0);   -- horizontal sync pulse width (in pixels)
		Thgdel : in unsigned(7 downto 0);   -- horizontal gate delay (in pixels)
		Thgate : in unsigned(15 downto 0);  -- horizontal gate (number of visible pixels per line)
		Thlen  : in unsigned(15 downto 0);  -- horizontal length (number of pixels per line)

		-- vertical timing settings
		VSyncL : in std_logic;              -- vertical sync pulse polarization level (pos/neg)
		Tvsync : in unsigned(7 downto 0);   -- vertical sync width (in lines)
		Tvgdel : in unsigned(7 downto 0);   -- vertical gate delay (in lines)
		Tvgate : in unsigned(15 downto 0);  -- vertical gate (visible number of lines in frame)
		Tvlen  : in unsigned(15 downto 0);  -- vertical length (number of lines in frame)

		CSyncL : in std_logic;              -- composite sync pulse polarization level (pos/neg)
		BlankL : in std_logic;              -- blank signal polarization level
		
		eol,                                -- end of line
		eof,                                -- end of frame
		gate,                               -- vertical AND horizontal gate (logical and function)

		Hsync,                              -- horizontal sync pulse
		Vsync,                              -- vertical sync pulse
		Csync,                              -- composite sync pulse
		Blank : out std_logic               -- blank signal
	);
	end component tgen;

	--
	-- signals
	--
	signal eol, eof : std_logic;
begin
	--
	-- timing block
	--
	tblk: block
		signal nVen : std_logic;                 -- video enable signal (active low)
	begin
		-- synchronize timing/control settings (from master-clock-domain to pixel-clock-domain)
		sync_settings: process(pclk)
		begin
			if (pclk'event and pclk = '1') then
				nVen    <= not ctrl_Ven;
			end if;
		end process sync_settings;

		-- hookup video timing generator
		vtgen: tgen port map (clk => pclk, rst => nVen, HSyncL => ctrl_HSyncL, Thsync => Thsync, Thgdel => Thgdel, Thgate => Thgate, Thlen => Thlen,
										VsyncL => ctrl_VsyncL, Tvsync => Tvsync, Tvgdel => Tvgdel, Tvgate => Tvgate, Tvlen => Tvlen, CSyncL => ctrl_CSyncL,
										BlankL => ctrl_BlankL, eol => eol, eof => eof, gate => gate, Hsync => Hsync, Vsync => Vsync, Csync => Csync, Blank => Blank);
	end block tblk;
	
	--
	-- pixel clock
	--
	pblk: block
		signal seol, seof : std_logic;           -- synchronized end-of-line, end-of-frame
		signal dseol, dseof : std_logic;         -- delayed synchronized eol, eof
	begin
		-- synchronize eol, eof (from pixel-clock-domain to master-clock-domain)
		sync_eol_eof: process(mclk)
		begin
			if (mclk'event and mclk = '1') then
				seol  <= eol;
				dseol <= seol;
				seof  <= eof;
				dseof <= seof;
				eoh <= seol and not dseol;
				eov <= seof and not dseof;
			end if;
		end process sync_eol_eof;
	end block pblk;

end architecture dataflow;
