----------------------------------------------------------------------------------
-- Company:  ISI/Nallatech
-- Engineer: Luis Munoz
-- Email:    lfmunoz4@gmail.com
-- 
-- Create Date:        09:09:53 07/07/2011 
--
-- Module Name:        patternGen - Behavioral 
--
-- Project Name:       Video Pattern Generator
--
-- Target Devices:     Xilinx Spartan-LX150T-2 using Xilinx ISE 13.1 and ISIM 13.1
--
-- Description:        This module is meant to generate a video output
--                     pattern 1-pixel at time to test any
--                     form of video output stream. It uses simple counters
--                     to generate the output.
--
--
-- Revision:           1.0 Initial Release
--
-- To do list:  Automatically calculate the bar widths and counter register size
--              depending on the frame width and frame height. Right now this is
--              is a manual process and depeding on your frame size the strips
--              of the pattern might be too thin or too wide.
--      
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
use IEEE.numeric_std.all;


entity patternGen is
generic(
    FrameWidth      : integer := 640; -- # of pixels per line
    FrameHeight     : integer := 512; -- # of lines in a frame
    PIXEL_SIZE      : integer := 8;   -- # of bits each pixel has
    REG_SIZE        : integer := 16   -- # size of register to store width count and heigh count
);
port(
    CLK_i        : in std_logic;                               -- input clk
    RST_i        : in std_logic;                               -- reset module
    SEL_i        : in std_logic_vector(2 downto 0);            -- select pattern to generate
    CLKen_i      : in std_logic;                               -- enables output or used to stall output
    VALID_o      : out std_logic;                              -- high on a valid pixel 
    ENDline_o    : out std_logic;                              -- high on last pixel of a line
    ENDframe_o   : out std_logic;                              -- high on last pixel of a frame
    PIXEL_o      : out std_logic_vector(PIXEL_SIZE-1 downto 0) -- the actual pixel 
);

end patternGen;

architecture Behavioral of patternGen is
    -- constant declaration section
    constant WIDTH          : std_logic_vector(REG_SIZE-1 downto 0) :=
                              std_logic_vector(to_unsigned(FrameWidth, REG_SIZE)) - 1;
    constant HEIGHT         : std_logic_vector(REG_SIZE-1 downto 0) := 
                              std_logic_vector(to_unsigned(FrameHeight, REG_SIZE)) - 1;
    constant BLACK          : std_logic_vector(PIXEL_SIZE-1 downto 0) := (others=>'1');
    constant WHITE          : std_logic_vector(PIXEL_SIZE-1 downto 0) := (others=>'0');
    -- signal declaration section
    signal line_cnt         : std_logic_vector(HEIGHT'length-1 downto 0);
    signal frame_end        : std_logic;
    signal frame_end_temp   : std_logic;
    signal pixel_cnt        : std_logic_vector(WIDTH'length-1 downto 0);
    signal line_end         : std_logic;
    signal line_end_temp    : std_logic;
    signal left_cnt         : std_logic_vector(WIDTH'length-1 downto 0);
    signal down_cnt         : std_logic_vector(HEIGHT'length-1 downto 0);    
    signal diag_cnt         : std_logic_vector(WIDTH'length-1 downto 0);
    signal pixel_cnt_off    : std_logic_vector(WIDTH'length-1 downto 0);
    signal line_cnt_off     : std_logic_vector(HEIGHT'length-1 downto 0);
    signal pixel            : std_logic_vector(PIXEL_SIZE-1 downto 0);
    signal valid            : std_logic;
    -- registered outputs signals 
    signal pixel_r          : std_logic_vector(PIXEL_SIZE-1 downto 0);
    signal line_end_r       : std_logic;
    signal frame_end_r      : std_logic;
    signal valid_r          : std_logic;
    signal color_sel        : std_logic;


begin
------------------------------------------------------
    --------------------------------------------------
    -- register all output signals
    --------------------------------------------------
    process(CLK_i, RST_i)
    begin
        if rising_edge(CLK_i) then
            if(RST_i = '1') then            
                pixel_r       <= "10101010"; -- unmistakble reset value
                line_end_r    <= '0';
                frame_end_r   <= '0';
                valid_r       <= '0';
            else
                pixel_r       <= pixel;
                line_end_r    <= line_end and CLKen_i;
                frame_end_r   <= frame_end and CLKen_i;
                valid_r       <= valid;
            end if;        
        end if;    
    end process;
         
    PIXEL_o      <= pixel_r;
    ENDline_o    <= line_end_r;
    ENDframe_o   <= frame_end_r;
    VALID_o      <= valid_r;
    --------------------------------------------------
    -- pixel count within a line
    --------------------------------------------------
    pixel_counter: entity work.xcounter 
    generic map(
        XVAL      => WIDTH
    )
    port map(
        CLK_i     => CLK_i,
        RST_i     => RST_i,
        CLKen_i   => CLKen_i,        
        COUNT_o   => pixel_cnt,
        DONE_o    => line_end_temp --signals last pixel of a line
    );
    -- only let line_end go high when enable is high,
    -- this is needed because when you stalling the output
    -- the pixel valid should go low.
    line_end <= line_end_temp and CLKen_i;
    --------------------------------------------------
    -- line count within a frame
    --------------------------------------------------
    line_counter: entity work.xcounter 
    generic map(
        XVAL      => HEIGHT
    )
    port map(
        CLK_i     => CLK_i, 
        RST_i     => RST_i,
        CLKen_i   => line_end, -- increment only when each line ends
        COUNT_o   => line_cnt,
        DONE_o    => frame_end_temp
    );
    -- this makes it so the frame_end signal goes
    -- high only on the last pixel and not stay
    -- high for the entire last line
    frame_end  <= frame_end_temp and line_end;

    --------------------------------------------------
    -- pattern select
    --------------------------------------------------
 
    with SEL_i select
    color_sel    <= '1'                             when  "000", -- always black
                    pixel_cnt(4)                    when  "001", -- vertical lines
                    line_cnt(5)                     when  "010", -- horizontal lines
                    pixel_cnt_off(3)                when  "011", -- moving vertical lines
                    line_cnt_off(5)                 when  "100", -- moving horizontal lines                            
                    pixel_cnt(3) and line_cnt(5)    when  "101", -- checker pattern (Not Completed)
                    diag_cnt(3)                     when  "110", -- diagonal lines (Not Completed)
                    pixel_cnt(0)                    when  OTHERS; -- rotate white / black

	 pixel  <= WHITE when color_sel = '1' else BLACK;
    valid  <= '1'   when RST_i = '0' else '0';
    ----------------------------------------------------
    -- experimental diagonal pattern (place holder)
    ----------------------------------------------------
    diag_cnt <= pixel_cnt +  line_cnt;    
    --------------------------------------------------
    -- counter to shift frame horizontally
    --------------------------------------------------
    left_shift_counter: entity work.xcounter 
    generic map(
        XVAL      => WIDTH
    )
    port map(
        CLK_i     => CLK_i,
        RST_i     => RST_i,
        CLKen_i   => frame_end, -- count at end of each frame
        COUNT_o   => left_cnt,
        DONE_o    => open
    );    
    -- here we offset the pixel counter by 1 every frame
    -- this causes a horizontal moving effect
    pixel_cnt_off  <=  pixel_cnt + left_cnt;
    --------------------------------------------------
    -- counter to shift frame vertically
    --------------------------------------------------
    down_shift_counter: entity work.xcounter 
    generic map(
        XVAL      => HEIGHT
    )
    port map(
        CLK_i     => CLK_i,
        RST_i     => RST_i,
        CLKen_i   => frame_end, -- count at end of each frame
        COUNT_o   => down_cnt,
        DONE_o    => open
    );
    -- here we offset the line counter by 1 every frame
    -- this causes vertical moving effect
    line_cnt_off  <=  line_cnt + down_cnt;

-----------------
end Behavioral;
-----------------
