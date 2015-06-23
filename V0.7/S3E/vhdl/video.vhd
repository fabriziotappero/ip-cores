-- Z80SoC for Spartan 3E
-- Ronivon Candido Costa
--
-- 2010 - 02 - 17 Update
-- Changed the entity to include signals for the char memory
-- The char memory is a dual port ram memory, and now
--     the char paterns can be modified by software.
-- 
--
library IEEE; 
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;
 
ENTITY video is
	PORT(	CLOCK_25		: IN STD_LOGIC;
			VRAM_DATA		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			VRAM_ADDR		: OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
			VRAM_CLOCK		: OUT STD_LOGIC;
			VRAM_WREN		: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			CRAM_DATA		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			CRAM_ADDR		: OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
			CRAM_WEB			: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			VGA_R,
			VGA_G,
			VGA_B				: OUT STD_LOGIC;
			VGA_HS,
			VGA_VS			: OUT STD_LOGIC);
END video;

ARCHITECTURE A OF video IS

      use work.z80soc_pack.all;

	-- Added for VDU support
	constant vid_width			: std_logic_vector := "001010000"; -- 80 columns
	signal Clock_video			: std_logic;
	signal VGA_R_sig				: std_logic;
	signal VGA_G_sig				: std_logic;
	signal VGA_B_sig				: std_logic;
	signal pixel_row_sig			: std_logic_vector(9 downto 0);
	signal pixel_column_sig		: std_logic_vector(9 downto 0);
	signal pixel_row_sigFF		: std_logic_vector(9 downto 0);
	signal pixel_column_sigFF	: std_logic_vector(9 downto 0);
	signal pixel_clock_sig		: std_logic;
	signal char_addr_sig			: std_logic_vector(7 downto 0);
	signal font_row_sig			: std_logic_vector(2 downto 0);
	signal font_col_sig			: std_logic_vector(2 downto 0);
	signal pixel_sig				: std_logic;
	signal video_on_sig			: std_logic;

	constant sv1				: integer := 3 + pixelsxchar - 1;
	constant sv2				: integer := 8 + pixelsxchar - 1;
	constant cv1				: integer := 0 + pixelsxchar - 1;
	constant cv2				: integer := 2 + pixelsxchar - 1;
	signal fix					: integer;

COMPONENT VGA_SYNC
	PORT(	clock_25Mhz							: IN 	STD_LOGIC;
			red, green, blue					: IN	STD_LOGIC;
			red_out, green_out, blue_out	: OUT	STD_LOGIC;
			horiz_sync_out, vert_sync_out, 
			video_on, pixel_clock			: OUT	STD_LOGIC;
			pixel_row, pixel_column			: OUT 	STD_LOGIC_VECTOR(9 DOWNTO 0));
END COMPONENT;
	
BEGIN
	
	VGA_R_sig <= '0';
	VGA_G_sig <= '0';
	VGA_B_sig <= pixel_sig;
	
	-- Fonts ROM read
	-- Picks next letter for a 80 Columns x 30 Lines display
	VRAM_WREN(0) <= '1';
	VRAM_CLOCK <= pixel_clock_sig;
	VRAM_ADDR <= pixel_row_sig(sv2 downto sv1) * conv_std_logic_vector(vid_cols,7) + pixel_column_sig(sv2 downto sv1);

	-- Fonts RAM read
	-- Takes the letter, calculates the position in the char memory to get the pixel pattern
	-- Plot the pixel in the video
	-- Using pixel_row(3 downto 1) has the effect of "shifting" (multiplying by 2)
	-- This will plot 2 pixels on video for every pixel defined on char memory
	CRAM_WEB(0) <= '1';
	CRAM_ADDR <= VRAM_DATA & pixel_row_sig(cv2 downto cv1);
	fix <= 1 when pixelsxchar = 2 else 2;
	pixel_sig <= CRAM_DATA (CONV_INTEGER(NOT (pixel_column_sig(cv2 downto cv1) - fix)))  when 
	            ( (pixel_row_sig < (pixelsxchar * 8 * vid_lines)) and (pixel_column_sig < (pixelsxchar * 8 * vid_cols)) ) else 
                '0';

	vga_sync_inst : vga_sync 
		port map (
			clock_25Mhz			=> CLOCK_25,
			red					=> VGA_R_sig,
			green					=> VGA_G_sig,
			blue					=> VGA_B_sig,
			red_out				=> VGA_R,
			green_out			=> VGA_G,
			blue_out				=> VGA_B,
			horiz_sync_out		=> VGA_HS,
			vert_sync_out		=> VGA_VS,
			video_on				=> video_on_sig,
			pixel_clock			=> pixel_clock_sig,
			pixel_row			=> pixel_row_sig,
			pixel_column		=> pixel_column_sig
	);
		
END A;
