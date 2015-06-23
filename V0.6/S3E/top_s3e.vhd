-------------------------------------------------------------------------------------------------
-- Z80_Soc (Z80 System on Chip)
-- 
-- Version history:
-------------------
-- version 0.6 for Spartan 3E
-- Release Date: 2008 / 05 / 21
--
-- Version 0.5 Beta for Spartan 3E
-- Developer: Ronivon Candido Costa
-- Release Date: 2008 / 05 / 01
--
-- Based on the T80 core: http://www.opencores.org/projects.cgi/web/t80
-- This version developed and tested on: Diligent Spartan 3E
--
-- Architecture of z80soc:
-- Processor: Z80 Processor (T80 core) Runnig at 3.58 Mhz (can be changed)
--
-- External devices/resources:
-- 
--	16 KB Internal ROM	Read			(0x0000h - 0x3FFFh)
--	08 KB INTERNAL VRAM	Write			(0x4000h - 0x5FFFh)
--	01 LCD display			Out			(0x7FE0h - 0x7FFFh)
-- 16 KB INTERNAL RAM	Read/Write	(0x8000h - 0xBFFFh)
--	08 Green Leds			Out			(Port 0x01h)
--	04 Switches				In				(Port 0x20h)
--	04 Push buttons		In				(Port 0x30h)
-- 01	Rotary Knob			In				(Port 0x70h)
--	PS/2 keyboard 			In				(Port 0x80h)
--	Video write				Out			(Port 0x90h)
--
--  Revision history:
--
-- 2008/05/20 - Modified RAM layout to support new and future improvements
--            - Added port 0x90 to write a character to video.
--            - Cursor x,y automatically updated after writing to port 0x90
--            - Added port 0x91 for video cursor X
--            - Added port 0x92 for video cursor Y
--	           - Updated ROM to demonstrate how to use these new resources
--            - Changed ROM to support 14 bit addresses (16 Kb)
--
-- 2008/05/12 - Added support for the Rotary Knob
--            - ROT_CENTER push button (Knob) reserved for RESET
--            - The four push buttons are now available for the user (Port 0x30)
--
-- 2008/05/11 - Fixed access to RAM and VRAM,
--              Released same ROM version for DE1 and S3E
--
-- 2008/05/01 - Added LCD support for Spartan 3E
--
-- 2008/04(21 - Release of Version 0.5-S3E-Beta for Diligent Spartan 3E
--
--	2008/04/17 - Added Video support for 40x30 mode
--
-- 2008/04/16 - Release of Version 0.5-DE1-Beta for Altera DE1
--
-- TO-DO:
-- - Implement hardware control for the A/D and IO pins
-- - Monitor program to introduce Z80 Assmebly codes and run
--	- Serial communication, to download assembly code from PC
--	- Add hardware support for 80x40 Video out
--	- SD/MMC card interface to read/store data and programs
-------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity Z80SOC_TOP is
	port(
    -- Clocks
    CLOCK_50 : in std_logic;                                    -- 50 MHz

    -- Buttons and switches
    KEY : in std_logic_vector(3 downto 0);         -- Push buttons
    SW : in std_logic_vector(3 downto 0);          -- Switches

    -- LED displays
    LEDG : out std_logic_vector(7 downto 0);       -- Green LEDs

    -- RS-232 interface
    -- UART_TXD : out std_logic;                      -- UART transmitter   
    -- UART_RXD : in std_logic;                       -- UART receiver

    -- PS/2 port
    PS2_DAT,                    -- Data
    PS2_CLK : inout std_logic;     -- Clock

    -- VGA output
    VGA_HS,                                             -- H_SYNC
    VGA_VS : out std_logic;                             -- SYNC
    VGA_R,                                              -- Red[3:0]
    VGA_G,                                              -- Green[3:0]
    VGA_B : out std_logic;									   -- Blue[3:0]
	 SF_D  : out std_logic_vector(3 downto 0);
	 LCD_E, LCD_RS, LCD_RW, SF_CE0 : out std_logic;
	 ROT_A, ROT_B, ROT_CENTER : in std_logic	
);
end Z80SOC_TOP;

architecture rtl of Z80SOC_TOP is

	component T80se
	generic(
		Mode : integer := 0;	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
		T2Write : integer := 1;	-- 0 => WR_n active in T3, /=0 => WR_n active in T2
		IOWait : integer := 1	-- 0 => Single cycle I/O, 1 => Std I/O cycle
	);
	port(
		RESET_n	: in std_logic;
		CLK_n		: in std_logic;
		CLKEN		: in std_logic;
		WAIT_n	: in std_logic;
		INT_n		: in std_logic;
		NMI_n		: in std_logic;
		BUSRQ_n	: in std_logic;
		M1_n		: out std_logic;
		MREQ_n	: out std_logic;
		IORQ_n	: out std_logic;
		RD_n		: out std_logic;
		WR_n		: out std_logic;
		RFSH_n	: out std_logic;
		HALT_n	: out std_logic;
		BUSAK_n	: out std_logic;
		A			: out std_logic_vector(15 downto 0);
		DI			: in std_logic_vector(7 downto 0);
		DO			: out std_logic_vector(7 downto 0)
	);
	end component;

	component sram16k
		port (
		addr	: IN std_logic_VECTOR(13 downto 0);
		clk	: IN std_logic;
		din	: IN std_logic_VECTOR(7 downto 0);
		dout	: OUT std_logic_VECTOR(7 downto 0);
		we		: IN std_logic);
	end component;

	component rom
	port (
		Clk	: in std_logic;
		A		: in std_logic_vector(13 downto 0);
		D		: out std_logic_vector(7 downto 0));
	end component;
	
	component Clock_357Mhz
	PORT (
		clock_50Mhz				: IN	STD_LOGIC;
		clock_357Mhz			: OUT	STD_LOGIC);
	end component;
	
	component clk_div
	PORT
	(
		clock_25Mhz				: IN	STD_LOGIC;
		clock_1MHz				: OUT	STD_LOGIC;
		clock_100KHz			: OUT	STD_LOGIC;
		clock_10KHz				: OUT	STD_LOGIC;
		clock_1KHz				: OUT	STD_LOGIC;
		clock_100Hz				: OUT	STD_LOGIC;
		clock_10Hz				: OUT	STD_LOGIC;
		clock_1Hz				: OUT	STD_LOGIC);
	end component;
	
	component lcd
	port(
		clk, reset 							: in std_logic;
		SF_D 									: out std_logic_vector(3 downto 0);
		LCD_E, LCD_RS, LCD_RW, SF_CE0 : out std_logic;
		lcd_addr								: out std_logic_vector(4 downto 0);
		lcd_char								: in std_logic_vector(7 downto 0));
	end component;

	component lcdvram
	port (
		addra	: IN std_logic_VECTOR(4 downto 0);
		addrb	: IN std_logic_VECTOR(4 downto 0);
		clka	: IN std_logic;
		clkb	: IN std_logic;
		dina	: IN std_logic_VECTOR(7 downto 0);
		doutb	: OUT std_logic_VECTOR(7 downto 0);
		wea	: IN std_logic);
	end component;

	component ps2kbd
	PORT (	
			keyboard_clk	: inout std_logic;
			keyboard_data	: inout std_logic;
			clock				: in std_logic;
			clkdelay			: in std_logic;
			reset				: in std_logic;
			read				: in std_logic;
			scan_ready		: out std_logic;
			ps2_ascii_code	: out std_logic_vector(7 downto 0));
	end component;
	 
	component vram8k
	port (
		addra: IN std_logic_VECTOR(12 downto 0);
		addrb: IN std_logic_VECTOR(12 downto 0);
		clka: IN std_logic;
		clkb: IN std_logic;
		dina: IN std_logic_VECTOR(7 downto 0);
		dinb: IN std_logic_VECTOR(7 downto 0);
		douta: OUT std_logic_VECTOR(7 downto 0);
		doutb: OUT std_logic_VECTOR(7 downto 0);
		wea: IN std_logic;
		web: IN std_logic);
	end component;

	COMPONENT video
	PORT (	
			CLOCK_25		: IN STD_LOGIC;
			VRAM_DATA	: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			VRAM_ADDR	: OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
			VRAM_CLOCK	: OUT STD_LOGIC;
			VRAM_WREN	: OUT STD_LOGIC;
			VGA_R,
			VGA_G,
			VGA_B			: OUT STD_LOGIC;
			VGA_HS,
			VGA_VS		: OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT ROT_CTRL
	PORT (
		CLOCK				: IN STD_LOGIC;
		ROT_A				: IN	STD_LOGIC;
		ROT_B				: IN	STD_LOGIC;
		DIRECTION		: OUT	STD_LOGIC_VECTOR(1 DOWNTO 0));
	END COMPONENT;
	
	signal MREQ_n	: std_logic;
	signal IORQ_n	: std_logic;
	signal RD_n		: std_logic;
	signal WR_n		: std_logic;
	signal MWr_n	: std_logic;
	signal Rst_n_s	: std_logic;
	signal Clk_Z80	: std_logic;
	signal DI_CPU	: std_logic_vector(7 downto 0);
	signal DO_CPU	: std_logic_vector(7 downto 0);
	signal A			: std_logic_vector(15 downto 0);
	signal One		: std_logic;
	
	signal D_ROM	: std_logic_vector(7 downto 0);

	signal clk25mhz		: std_logic;
	signal clk100hz		: std_logic;
	signal clk10hz			: std_logic;
	signal clk1hz			: std_logic;

	signal vram_addra		: std_logic_vector(15 downto 0);
	signal vram_addrb		: std_logic_vector(15 downto 0);
	signal vram_dina			: std_logic_vector(7 downto 0);
	signal vram_dinb			: std_logic_vector(7 downto 0);
	signal vram_douta		: std_logic_vector(7 downto 0);
	signal vram_doutb		: std_logic_vector(7 downto 0);
	signal vram_wea			: std_logic;
	signal vram_web			: std_logic;
	signal vram_clka			: std_logic;
	signal vram_clkb			: std_logic;
	
	signal vram_douta_reg	: std_logic_vector(7 downto 0);	
	signal VID_CURSOR		: std_logic_vector(15 downto 0);
	signal CURSOR_X		    : std_logic_vector(5 downto 0);
	signal CURSOR_Y		    : std_logic_vector(4 downto 0);

	-- sram signals
	signal sram_addr		: std_logic_vector(15 downto 0);
	signal sram_din		: std_logic_vector(7 downto 0);
	signal sram_dout		: std_logic_vector(7 downto 0);
	signal sram_we			: std_logic;
	
	-- LCD signals
	signal lcd_wea			: std_logic;
	signal lcd_addra		: std_logic_vector(4 downto 0);
	signal lcd_addrb		: std_logic_vector(4 downto 0);
	signal lcd_dina		: std_logic_vector(7 downto 0);
	signal lcd_doutb		: std_logic_vector(7 downto 0);
	
	-- VGA conversion from 4 bits to 8 bit
	signal VGA_Rs, VGA_Gs, VGA_Bs	: std_logic_vector(3 downto 0);
	signal VGA_HSs, VGA_VSs 		: std_logic;
	
	-- PS/2 Keyboard
	signal ps2_read					: std_logic;
	signal ps2_scan_ready			: std_logic;
	signal ps2_ascii_sig				: std_logic_vector(7 downto 0);
	signal ps2_ascii_reg1			: std_logic_vector(7 downto 0);
	signal ps2_ascii_reg				: std_logic_vector(7 downto 0);
	
	-- Rotary Control
	signal rot_dir     : std_logic_vector(1 downto 0);
	signal rot_dir_sig : std_logic_vector(1 downto 0);
	
	signal Z80SOC_VERSION		: std_logic_vector(2 downto 0);   -- "000" = DE1, "001" = S3E
	signal Z80SOC_STACK			: std_logic_vector(15 downto 0);  -- Should be set to top of (RAM Memory - 1)
	
begin

	Z80SOC_VERSION <= "001";		-- "000" = DE1, "001" = S3E
	Z80SOC_STACK <= x"BFFE"; 		-- Should be set to top of (RAM Memory - 1)	
	Rst_n_s <= not ROT_CENTER;
	
--	Write into VRAM
	vram_addra <= VID_CURSOR when (IORQ_n = '0' and MREQ_n = '1' and A(7 downto 0) = x"90")  else
	              A - x"4000" when (A >= x"4000" and A <= x"5FFF");
	vram_wea <= '0' when ((A >= x"4000" and A <= x"5FFF" and Wr_n = '0' and MReq_n = '0') or (Wr_n = '0' and IORQ_n = '0' and A(7 downto 0) = x"90")) else 
             	'1';
	vram_dina <= DO_CPU; -- when (A >= x"4000" and A <= x"5FFF" and Wr_n = '0' and MReq_n = '0');
	
-- Write into LCD video ram
	lcd_addra <= A - x"7FE0" when (A >= x"7FE0" and A <= x"7FFF");
	lcd_wea <= '0' when (A >= x"7FE0" and A <= x"7FFF" and Wr_n = '0' and MReq_n = '0') else '1';
	lcd_dina <= DO_CPU when (A >= x"7FE0" and A <= x"7FFF" and Wr_n = '0' and MReq_n = '0');
	
-- Write into SRAM
	sram_addr <= A - x"8000" when (A >= x"8000" and A <= x"BFFF");
	sram_we <= '0' when (A >= x"8000" and A <= x"BFFF" and Wr_n = '0' and MReq_n = '0') else '1';
	sram_din <= DO_CPU when (A >= x"8000" and A <= x"BFFF" and Wr_n = '0' and MReq_n = '0');
			
	DI_CPU <= ("00000" & Z80SOC_VERSION) when (Rd_n = '0' and MREQ_n = '0' and IORQ_n = '1' and A = x"7FDD") else
			Z80SOC_STACK(7 downto 0) when (Rd_n = '0' and MREQ_n = '0' and IORQ_n = '1' and A = x"7FDE") else
			Z80SOC_STACK(15 downto 8) when (Rd_n = '0' and MREQ_n = '0' and IORQ_n = '1' and A = x"7FDF") else
			vram_douta when (MREQ_n = '0' and IORQ_n = '1' and Rd_n = '0' and A >= x"4000" and A <= x"5FFF") else
		   sram_dout when (Rd_n = '0' and MREQ_n = '0' and IORQ_n = '1' and A >= x"8000" and A <= x"BFFF") else
			D_ROM when (Rd_n = '0' and MREQ_n = '0' and IORQ_n = '1' and A < x"4000") else
			("0000" & SW) when (IORQ_n = '0' and MREQ_n = '1' and Rd_n = '0' and A(7 downto 0) = x"20") else
			("0000" & KEY) when (IORQ_n = '0' and MREQ_n = '1' and Rd_n = '0' and A(7 downto 0) = x"30") else
			("000000" & rot_dir) when (IORQ_n = '0' and Rd_n = '0' and A(7 downto 0) = x"70") else
			ps2_ascii_reg when (IORQ_n = '0' and MREQ_n = '1' and Rd_n = '0' and A(7 downto 0) = x"80") else
			("00" & CURSOR_X) when (IORQ_n = '0' and MREQ_n = '1' and Rd_n = '0' and A(7 downto 0) = x"91") else
			("000" & CURSOR_Y) when (IORQ_n = '0' and MREQ_n = '1' and Rd_n = '0' and A(7 downto 0) = x"92") else
			"ZZZZZZZZ";
	
	-- Process to latch leds and hex displays
	pinout_process: process(Clk_Z80)
	variable LEDG_sig		: std_logic_vector(7 downto 0);
	begin	
		if Clk_Z80'event and Clk_Z80 = '1' then
		  if IORQ_n = '0' and Wr_n = '0' then
			-- LEDG
			if A(7 downto 0) = x"01" then
				LEDG_sig := DO_CPU;
			end if;
		  end if;
		end if;	
		-- Latches the signals
		LEDG <= LEDG_sig;
	end process;
	
	cursorxy: process (Clk_Z80)
	variable VID_X	: std_logic_vector(5 downto 0);
	variable VID_Y	: std_logic_vector(4 downto 0);
	begin
		if Clk_Z80'event and Clk_Z80 = '1' then
			if (IORQ_n = '0' and MREQ_n = '1' and Wr_n = '0' and A(7 downto 0) = x"91") then
				VID_X := DO_CPU(5 downto 0);
			elsif (IORQ_n = '0' and MREQ_n = '1' and Wr_n = '0' and A(7 downto 0) = x"92") then
				VID_Y := DO_CPU(4 downto 0);
			elsif (IORQ_n = '0' and MREQ_n = '1' and Wr_n = '0' and A(7 downto 0) = x"90") then
				if VID_X = "100111" then
					VID_X := "000000";
					if VID_Y = "11101" then
						VID_Y := "00000";
					else
						VID_Y := VID_Y + 1;
					end if;
				else
					VID_X := VID_X + 1;
				end if;
			end if;
		end if;
		VID_CURSOR <= x"4000" + ( VID_X + ( VID_Y * "0101000"));
		CURSOR_X <= VID_X;
		CURSOR_Y <= VID_Y;
	end process;

	-- the following three processes deals with different clock domain signals
	ps2_process1: process(CLOCK_50)
	begin
		if CLOCK_50'event and CLOCK_50 = '1' then
			if ps2_read = '1' then
				if ps2_ascii_sig /= x"FF" then
					ps2_read <= '0';
					ps2_ascii_reg1 <= "00000000";
				end if;
			elsif ps2_scan_ready = '1' then
				if ps2_ascii_sig = x"FF" then
					ps2_read <= '1';
				else
					ps2_ascii_reg1 <= ps2_ascii_sig;
				end if;
			end if;
		end if;
	end process;
	
	ps2_process2: process(Clk_Z80)
	variable stack	: std_logic_vector(15 downto 0):=x"7FDE";
	begin
		if Clk_Z80'event and Clk_Z80 = '1' then
			ps2_ascii_reg <= ps2_ascii_reg1;
		end if;
	end process;
	
	rot_process: process(clk100hz)
	begin
		if clk100hz'event and clk100hz = '1' then
			rot_dir <= rot_dir_sig;
		end if;
	end process;
	
	One <= '1';
	z80_inst: T80se
		port map (
			M1_n => open,
			MREQ_n => MReq_n,
			IORQ_n => IORq_n,
			RD_n => Rd_n,
			WR_n => Wr_n,
			RFSH_n => open,
			HALT_n => open,
			WAIT_n => One,
			INT_n => One,
			NMI_n => One,
			RESET_n => Rst_n_s,
			BUSRQ_n => One,
			BUSAK_n => open,
			CLK_n => Clk_Z80,
			CLKEN => One,
			A => A,
			DI => DI_CPU,
			DO => DO_CPU
		);
			
	ps2_kbd_inst : ps2kbd PORT MAP (
		keyboard_clk	=> PS2_CLK,
		keyboard_data	=> PS2_DAT,
		clock			=> CLOCK_50,
		clkdelay		=> clk100hz,
		reset			=> Rst_n_s,
		read			=> ps2_read,
		scan_ready		=> ps2_scan_ready,
		ps2_ascii_code	=> ps2_ascii_sig
	);
	
	clk25mhz_proc: process (CLOCK_50)
   begin
		if CLOCK_50'event and CLOCK_50 = '1' then
        clk25mhz <= not clk25mhz;
		end if;
   end process;
	
   clkdiv_inst: clk_div
		port map (
		clock_25Mhz		=> clk25mhz,		
		clock_1MHz		=> open,
		clock_100KHz	=> open,
		clock_10KHz		=> open,
		clock_1KHz		=> open,
		clock_100Hz		=> clk100hz,	
		clock_10Hz		=> clk10hz,
		clock_1Hz		=> clk1hz
	);
	
	clock_z80_inst : Clock_357Mhz
	port map (
		clock_50Mhz		=> CLOCK_50,
		clock_357Mhz	=> Clk_Z80
	);
	
	lcd_inst: lcd
	port map (
		clk			=> CLOCK_50,
		reset			=> not Rst_n_s,
		SF_D 			=> SF_D,
		LCD_E			=> LCD_E,
		LCD_RS		=> LCD_RS,
		LCD_RW		=> LCD_RW,
		SF_CE0 		=> SF_CE0,
		lcd_addr		=> lcd_addrb,
		lcd_char		=> lcd_doutb
	);
			
	rom_inst: rom
		port map (
			Clk => Clk_Z80,
			A	=> A(13 downto 0),
			D 	=> D_ROM
		);

		
	video_inst: video port map (
			CLOCK_25			=> clk25mhz,
			VRAM_DATA		=> vram_doutb,
			VRAM_ADDR		=> vram_addrb(12 downto 0),
			VRAM_CLOCK		=> vram_clkb,
			VRAM_WREN		=> vram_web,
			VGA_R				=> VGA_R,
			VGA_G				=> VGA_G,
			VGA_B				=> VGA_B,
			VGA_HS			=> VGA_HS,
			VGA_VS			=> VGA_VS
	);
	
	vram8k_inst: vram8k port map (
		clka 		=> Clk_Z80,
		clkb		=> vram_clkb,
      wea    	=> vram_wea,
		web    	=> vram_web,
      addra		=> vram_addra(12 downto 0),
      addrb		=> vram_addrb(12 downto 0),
      dina   	=> vram_dina,
      dinb   	=> vram_dinb,
		douta		=> vram_douta,
		doutb		=> vram_doutb
	);

	lcdvram_inst : lcdvram
		port map (
			addra => lcd_addra,
			addrb => lcd_addrb,
			clka => Clk_Z80,
			clkb => CLOCK_50,
			dina => lcd_dina,
			doutb => lcd_doutb,
			wea => lcd_wea
		);

	ram16k_inst : sram16k
		port map (
			addr => sram_addr(13 downto 0),
			clk => Clk_Z80,
			din => sram_din,
			dout => sram_dout,
			we => sram_we
	);

	rotary_inst: ROT_CTRL
		port map (
			CLOCK			=> CLOCK_50,
			ROT_A			=> ROT_A,
			ROT_B			=> ROT_B,
			DIRECTION	=> rot_dir_sig
	);
			
end;