----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Aart Mulder
-- 
-- Create Date:    12:22:01 05/22/2013 
-- Design Name:    Tiff compression 
-- Module Name:    capture_manager_top_nexys - Behavioral 
-- Target Devices: Digilent Nexys2-1200(spartan 3E-1200)
-- Description:    
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity capture_manager_top_nexys is
	Generic (
		COLUMNS_G            : integer := 752;
		ROWS_G               : integer := 480;
		COL_INDEX_WIDTH_G    : integer := 10;
		ROW_INDEX_WIDTH_G    : integer := 9;

		MAX_CODE_LEN_G       : integer := 28;
		MAX_CODE_LEN_WIDTH_G : integer := 5;
		SEG_OUTPUT_WIDTH_G   : integer := 8;

		TX_MEMORY_SIZE_G            : integer := 2;
		TX_MEMORY_ADDRESS_WIDTH_G   : integer := 12;
		
		--@26.6MHz
		BAUD_DIVIDE_G        : integer := 15; 	--115200 baud
		BAUD_RATE_G          : integer := 231
	);
	Port 
	(
		reset_i   : in  STD_LOGIC;

		fsync_i   : in  STD_LOGIC;
		rsync_i   : in  STD_LOGIC;
		pclk_i    : in  STD_LOGIC;
		pix_data_i: in  STD_LOGIC_VECTOR(7 downto 0);
		
		vga_fsync_o : out STD_LOGIC;
		vga_rsync_o : out STD_LOGIC;
		vgaRed      : out STD_LOGIC_VECTOR(7 downto 5);
		vgaGreen    : out STD_LOGIC_VECTOR(7 downto 5);
		vgaBlue     : out STD_LOGIC_VECTOR(7 downto 6);

		TX_o    : out STD_LOGIC;
		RX_i    : in STD_LOGIC;

		led0_o  : out STD_LOGIC;
		led1_o  : out STD_LOGIC;
		led2_o  : out STD_LOGIC;
		led3_o  : out STD_LOGIC;
		
		sw_i : in STD_LOGIC_VECTOR(6 downto 0)
	);
end capture_manager_top_nexys;

architecture Behavioral of capture_manager_top_nexys is

begin
	capture_manager_ins : entity work.capture_manager
	generic map(
		COLUMNS_G                 => COLUMNS_G,
		ROWS_G                    => ROWS_G,
		COL_INDEX_WIDTH_G         => COL_INDEX_WIDTH_G,
		ROW_INDEX_WIDTH_G         => ROW_INDEX_WIDTH_G,
		MAX_CODE_LEN_G            => MAX_CODE_LEN_G,
		MAX_CODE_LEN_WIDTH_G      => MAX_CODE_LEN_WIDTH_G,
		SEG_OUTPUT_WIDTH_G        => SEG_OUTPUT_WIDTH_G,
		TX_MEMORY_SIZE_G          => TX_MEMORY_SIZE_G,
		TX_MEMORY_ADDRESS_WIDTH_G => TX_MEMORY_ADDRESS_WIDTH_G,
		BAUD_DIVIDE_G             => BAUD_DIVIDE_G,
		BAUD_RATE_G               => BAUD_RATE_G
	)
	port map(
		reset_i                     => reset_i,
		fsync_i                     => fsync_i,
		rsync_i                     => rsync_i,
		pclk_i                      => pclk_i,
		pix_data_i                  => pix_data_i,
		vga_fsync_o                 => vga_fsync_o,
		vga_rsync_o                 => vga_rsync_o,
		vgaRed                      => vgaRed,
		vgaGreen                    => vgaGreen,
		vgaBlue                     => vgaBlue,
		TX_o                        => TX_o,
		RX_i                        => RX_i,
		led0_o                      => led0_o,
		led1_o                      => led1_o,
		led2_o                      => led2_o,
		led3_o                      => led3_o,
		sw_i                        => sw_i,
		--Used for testbench purposes
		CCITT4_run_len_code_o       => open,
		CCITT4_run_len_code_width_o => open,
		CCITT4_run_len_code_valid_o => open,
		CCITT4_frame_finished_o     => open
	);
	
end Behavioral;

