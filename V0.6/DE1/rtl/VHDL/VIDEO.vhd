library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
-- use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
--use IEEE.std_logic_signed.all;
--use IEEE.math_real.all;
--use IEEE.math_complex.all;


ENTITY video is
	PORT(	CLOCK_25		: IN STD_LOGIC;
			VRAM_DATA		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			VRAM_ADDR		: OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
			VRAM_CLOCK		: OUT STD_LOGIC;
			VRAM_WREN		: OUT STD_LOGIC;
			VGA_R,
			VGA_G,
			VGA_B			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			VGA_HS,
			VGA_VS			: OUT STD_LOGIC);
END video;

ARCHITECTURE A OF video IS

	-- Added for VDU support
	signal Clock_video		: std_logic;
	signal VGA_R_sig		: std_logic_vector(3 downto 0);
	signal VGA_G_sig		: std_logic_vector(3 downto 0);
	signal VGA_B_sig		: std_logic_vector(3 downto 0);
	signal pixel_row_sig	: std_logic_vector(9 downto 0);
	signal pixel_column_sig	: std_logic_vector(9 downto 0);
	signal pixel_clock_sig	: std_logic;
	signal char_addr_sig	: std_logic_vector(7 downto 0);
	signal font_row_sig		: std_logic_vector(2 downto 0);
	signal font_col_sig		: std_logic_vector(2 downto 0);
	signal pixel_sig		: std_logic;
	signal video_on_sig		: std_logic;
		
BEGIN
	
	VGA_R_sig <= "0000";
	VGA_G_sig <= "0000";
	VGA_B_sig <= pixel_sig & pixel_sig & pixel_sig & pixel_sig;
	
	VRAM_WREN <= '1';
	VRAM_CLOCK <= pixel_clock_sig;
	VRAM_ADDR <= (pixel_row_sig(9 downto 4) * "0101000" + pixel_column_sig(9 downto 4));
	
	-- Fonts ROM read
	char_addr_sig <= VRAM_DATA;
	font_row_sig(2 downto 0) <= pixel_row_sig(3 downto 1);
	font_col_sig(2 downto 0) <= pixel_column_sig(3 downto 1);
	
	vga_sync_inst : work.vga_sync 
		port map (
			clock_25Mhz			=> CLOCK_25,
			red					=> VGA_R_sig,
			green				=> VGA_G_sig,
			blue				=> VGA_B_sig,
			red_out				=> VGA_R,
			green_out			=> VGA_G,
			blue_out			=> VGA_B,
			horiz_sync_out		=> VGA_HS,
			vert_sync_out		=> VGA_VS,
			video_on			=> video_on_sig,
			pixel_clock			=> pixel_clock_sig,
			pixel_row			=> pixel_row_sig,
			pixel_column		=> pixel_column_sig
	);

	char_rom_inst : work.char_rom
		port map (
			clock				=> pixel_clock_sig,			
			character_address	=> char_addr_sig,
			font_row			=> font_row_sig,
			font_col			=> font_col_sig,
			rom_mux_output		=> pixel_sig
	);	
		
END A;
