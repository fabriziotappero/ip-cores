-- *****************************************************************************
-- *                                                                           *
-- *                            VGA TIMING DRIVER                              *
-- *                                                                           *
-- * Creates timing for the VGA port on an XESS board. This is the XESS VGA    *
-- * generator with the pixel buffer fifo ripped out, and the signals it fed   *
-- * are brought out to ports. The buffer is not bad, it is just not required  *
-- * for applications like a dot character generator, that can respond to      *
-- * pixel row timing without delay.                                           *
-- *                                                                           *
-- * Simulation plugs exist in this code. Look for "????? SIMULATION PLUG"     *
-- *                                                                           *
-- *****************************************************************************

library IEEE, unisim;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use unisim.vcomponents.all;
use work.common.all;

package vga_pckg is
  component vga
    generic (
      FREQ            :     natural := 50_000;  -- master clock frequency (in KHz)
      CLK_DIV         :     natural := 2;  -- FREQ / CLK_DIV = pixel clock
      PIXEL_WIDTH     :     natural := 1;  -- pixel width: 1, 2, 4, 8, or 16 bits
      PIXELS_PER_LINE :     natural := 640;  -- pixels per video scan line
      LINES_PER_FRAME :     natural := 480;  -- scan lines per video frame
      NUM_RGB_BITS    :     natural := 3;  -- width of R, G and B color output buses (2 or 3 are only valid values)
      FIT_TO_SCREEN   :     boolean := true  -- fit width x length to monitor screen
      );
    port (
      rst             : in  std_logic;  -- reset
      clk             : in  std_logic;  -- master clock
      pixel_data_in   : in  std_logic_vector(15 downto 0);  -- input databus to pixel buffer
      rd              : out std_logic;  -- read next pixel
      eof             : out std_logic;  -- end of vga frame
      r, g, b         : out std_logic_vector(NUM_RGB_BITS-1 downto 0);  -- R,G,B color output buses
      hsync_n         : out std_logic;  -- horizontal sync pulse
      vsync_n         : out std_logic;  -- vertical sync pulse
      blank           : out std_logic   -- blanking signal
      );
  end component vga;
end package vga_pckg;

library IEEE, unisim;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use unisim.vcomponents.all;
use work.common.all;

entity vga is
  generic (
    FREQ            :     natural := 50_000;  -- master clock frequency (in KHz)
    CLK_DIV         :     natural := 2;  -- FREQ / CLK_DIV = pixel clock
    PIXEL_WIDTH     :     natural := 1;  -- pixel width: 1, 2, 4, 8, or 16 bits
    PIXELS_PER_LINE :     natural := 640;  -- pixels per video scan line
    LINES_PER_FRAME :     natural := 480;  -- scan lines per video frame
    NUM_RGB_BITS    :     natural := 3;  -- width of R, G and B color output buses
    FIT_TO_SCREEN   :     boolean := true  -- fit width x length to monitor screen
    );
  port (
    rst             : in  std_logic;  -- reset
    clk             : in  std_logic;  -- master clock
    pixel_data_in   : in  std_logic_vector(15 downto 0);  -- input databus to pixel buffer
    rd              : out std_logic;  -- read next pixel
    eof             : out std_logic;  -- end of vga frame
    r, g, b         : out std_logic_vector(NUM_RGB_BITS-1 downto 0);  -- R,G,B color output buses
    hsync_n         : out std_logic;  -- horizontal sync pulse
    vsync_n         : out std_logic;  -- vertical sync pulse
    blank           : out std_logic   -- blanking signal
    );
end entity vga;

architecture vga_arch of vga is
  constant NORM : natural := 1000;      -- normalization factor for us * KHz

  -- video timing parameters for FIT_TO_SCREEN mode
  constant HSYNC_START_F  : natural := (NORM * PIXELS_PER_LINE * CLK_DIV)/FREQ + 1;  -- start of horiz. sync pulse with a scanline (us)
  constant HSYNC_PERIOD_F : natural := HSYNC_START_F + 6;  -- horizontal scanline period (us)
  constant HSYNC_WIDTH_F  : natural := 4;  -- width of horiz. sync pulse (us)
  constant HSYNC_FREQ_F   : natural := NORM / HSYNC_PERIOD_F;  -- scanline frequency (KHz) 
  constant VSYNC_START_F  : natural := HSYNC_PERIOD_F * LINES_PER_FRAME + 340;  -- start of vert. sync pulse within a frame (us)
  constant VSYNC_PERIOD_F : natural := VSYNC_START_F + 1084;  -- video frame period (us)
  constant VSYNC_WIDTH_F  : natural := 64;  -- width of vert. sync pulse (us)

  -- video timing for 31 KHz horizontal, 60 Hz vertical screen refresh
  constant HSYNC_START  : natural := 26;  -- start of horiz. sync pulse with a scanline (us)
  constant HSYNC_PERIOD : natural := 32;  -- horizontal scanline period (us)
  constant HSYNC_WIDTH  : natural := 4;  -- width of horiz. sync pulse (us)
  constant HSYNC_FREQ   : natural := NORM / HSYNC_PERIOD;  -- scanline frequency (KHz) 
  constant VSYNC_START  : natural := 15_700;  -- start of vert. sync pulse within a frame (us)
  constant VSYNC_PERIOD : natural := 16_784;  -- video frame period (us)
  constant VSYNC_WIDTH  : natural := 64;  -- width of vert. sync pulse (us)

  signal   clk_div_cnt                :     unsigned(7 downto 0);
  signal   cke                        :     std_logic;
  signal   line_cnt, pixel_cnt        :     unsigned(15 downto 0);  -- current video line and pixel within line
  signal   eof_i, eof_x, eof_r        :     std_logic;
  signal   v_gate, cke_v_gate         :     std_logic;
  signal   h_blank, v_blank, visible  :     std_logic;
  constant PIX_PROC_DELAY             :     natural := 3;  -- time delay to read a pixel from the FIFO and colormap it
  signal   hsync_x, hsync_r           :     std_logic_vector(PIX_PROC_DELAY downto 1);
  signal   blank_x, blank_r           :     std_logic_vector(PIX_PROC_DELAY downto 1);
  signal   rd_x, rd_r                 :     std_logic;
  signal   pixel                      :     std_logic_vector(PIXEL_WIDTH-1 downto 0);
  signal   pixel_data_x, pixel_data_r :     std_logic_vector(15 downto 0);
  signal   rgb_x, rgb_r               :     std_logic_vector(3*NUM_RGB_BITS-1 downto 0);

  component sync
    generic (
      FREQ                            :     natural := 50_000;  -- master clock frequency (in KHz)
      PERIOD                          :     natural := 32;  -- period of sync pulse (in us)
      START                           :     natural := 26;  -- time sync pulse starts within the period (in us)
      WIDTH                           :     natural := 4;  -- width of sync pulse (in us)
      VISIBLE                         :     natural := 1024  -- number of visible pixels/line or lines/frame
      );
    port (
      rst                             : in  std_logic;  -- reset
      clk                             : in  std_logic;  -- master clock
      cke                             : in  std_logic;  -- clock-enable
      sync_n                          : out std_logic;  -- sync pulse
      gate                            : out std_logic;  -- single-clock pulse at start of sync pulse
      blank                           : out std_logic;  -- blanking signal
      cnt                             : out unsigned(15 downto 0)  -- output the timing counter value
      );
  end component sync;

begin

  -- clock divider for reducing the pixel clock rate
  process(clk, rst)
  begin
    if rst = YES then
      clk_div_cnt   <= (others => '0');
      cke           <= YES;
    elsif rising_edge(clk) then
      if clk_div_cnt = CLK_DIV-1 then
        clk_div_cnt <= (others => '0');
        cke         <= YES;
      else
        clk_div_cnt <= clk_div_cnt + 1;
        cke         <= NO;
      end if;
    end if;
  end process;

  -- form read pixel signal
  rd <= rd_x and cke;

  -- the clock enable for the vertical sync module is also combined with a gate signal
  -- that is generated at the end of every scanline by the horizontal sync module
  cke_v_gate <= cke and v_gate;

  -- generate the horizontal and vertical sync pulses for FIT_TO_SCREEN mode
  gen_syncs_fit : if FIT_TO_SCREEN = true generate
    hsync       : sync
      generic map (
        FREQ    => FREQ / CLK_DIV,      -- master pixel-clock frequency
        PERIOD  => HSYNC_PERIOD_F,      -- scanline period (32 us)
        START   => HSYNC_START_F,       -- start of horizontal sync pulse in scan line
        WIDTH   => HSYNC_WIDTH_F,       -- width of horizontal sync pulse
        VISIBLE => PIXELS_PER_LINE
        )
      port map (
        rst     => rst,
        clk     => clk,                 -- master clock
        cke     => cke,                 -- a new pixel is output whenever the clock is enabled
        sync_n  => hsync_x(1),          -- send pulse through delay line
        gate    => v_gate,              -- send gate signal to increment vertical sync pulse generator once per scan line
        blank   => h_blank,             -- blanking signal within a scan line
        cnt     => pixel_cnt            -- current pixel within the scan line
        );

    vsync : sync
      generic map (
        FREQ    => HSYNC_FREQ_F,        -- scanline frequency
        PERIOD  => VSYNC_PERIOD_F,      -- image frame period
        START   => VSYNC_START_F,       -- start of vertical sync pulse in frame
        WIDTH   => VSYNC_WIDTH_F,       -- width of vertical sync pulse
        VISIBLE => LINES_PER_FRAME
        )
      port map (
        rst     => rst,
        clk     => clk,                 -- master clock
        cke     => cke_v_gate,          -- enable clock once per horizontal scan line
        sync_n  => vsync_n,             -- send pulse through delay line
        gate    => eof_x,               -- indicate the end of a complete frame
        blank   => v_blank,             -- blanking signal within a frame
        cnt     => line_cnt             -- current scan line within a frame
        );
  end generate;

  -- generate the horizontal and vertical sync pulses for 31 KHz horizontal, 60 Hz vertical screen refresh
  gen_syncs_nofit : if FIT_TO_SCREEN = false generate
    hsync         : sync
      generic map (
        FREQ    => FREQ / CLK_DIV,      -- master pixel-clock frequency
        PERIOD  => HSYNC_PERIOD,        -- scanline period (32 us)
        START   => HSYNC_START,         -- start of horizontal sync pulse in scan line
        WIDTH   => HSYNC_WIDTH,         -- width of horizontal sync pulse
        VISIBLE => PIXELS_PER_LINE
        )
      port map (
        rst     => rst,
        clk     => clk,                 -- master clock
        cke     => cke,                 -- clock always enabled so there is a new pixel output on every clock pulse
        sync_n  => hsync_x(1),          -- send pulse through delay line
        gate    => v_gate,              -- send gate signal to increment vertical sync pulse generator once per scan line
        blank   => h_blank,             -- blanking signal within a scan line
        cnt     => pixel_cnt            -- current pixel within the scan line
        );

    vsync : sync
      generic map (
        FREQ    => HSYNC_FREQ,          -- scanline frequency (KHz)
        PERIOD  => VSYNC_PERIOD,        -- image frame period
        START   => VSYNC_START,         -- start of vertical sync pulse in frame
        WIDTH   => VSYNC_WIDTH,         -- width of vertical sync pulse
        VISIBLE => LINES_PER_FRAME
        )
      port map (
        rst     => rst,
        clk     => clk,                 -- master clock
        cke     => cke_v_gate,          -- enable clock once per horizontal scan line
        sync_n  => vsync_n,             -- send pulse through delay line
        gate    => eof_x,               -- indicate the end of a complete frame
        blank   => v_blank,             -- blanking signal within a frame
        cnt     => line_cnt             -- current scan line within a frame
        );
  end generate;

  eof_i    <= eof_x and not eof_r;      -- shorten end-of-frame signal to a single clock cycle
  eof      <= eof_i;

  visible    <= h_blank nor v_blank;    -- pixels are visible when horiz. & vertical blank are inactive 
  blank_x(1) <= not visible;            -- send blanking signal through delay line

  -- pass the horiz. and vert. syncs and blanking signal through delay lines to compensate for the
  -- processing delays incurred by the pixel data
  hsync_x(hsync_x'high downto 2) <= hsync_r(hsync_r'high-1 downto 1);
  hsync_n                        <= hsync_r(hsync_r'high);
  blank_x(blank_x'high downto 2) <= blank_r(blank_r'high-1 downto 1);
  blank                          <= blank_r(blank_r'high);

  -- get the current pixel from the word of pixel data or read more pixel data from the buffer
  get_pixel : process(visible, pixel_data_in, pixel_data_r, rd_r, pixel_cnt)
  begin
    rd_x <= NO;                         -- by default, don't read next word of pixel data from the buffer

    -- shift pixel data depending on its width so the next pixel is in the LSBs of the pixel data shift register
    case PIXEL_WIDTH is
      when 1      =>                    -- 1-bit pixels, 16 per pixel data word
        if (visible = YES) and (pixel_cnt(3 downto 0) = 0) then
          rd_x       <= YES;            -- read new pixel data from buffer every 16 clocks during visible portion of scan line
        end if;
        pixel_data_x <= "0" & pixel_data_r(15 downto 1);  -- left-shift pixel data to move next pixel to LSB
      when 2      =>                    -- 2-bit pixels, 8 per pixel data word
        if (visible = YES) and (pixel_cnt(2 downto 0) = 0) then
          rd_x       <= YES;            -- read new pixel data from buffer every 8 clocks during visible portion of scan line
        end if;
        pixel_data_x <= "00" & pixel_data_r(15 downto 2);  -- left-shift pixel data to move next pixel to LSB 
      when 4      =>                    -- 4-bit pixels, 4 per pixel data word
        if (visible = YES) and (pixel_cnt(1 downto 0) = 0) then
          rd_x       <= YES;            -- read new pixel data from buffer every 4 clocks during visible portion of scan line
        end if;
        pixel_data_x <= "0000" & pixel_data_r(15 downto 4);  -- left-shift pixel data to move next pixel to LSB 
      when 8      =>                    -- 8-bit pixels, 2 per pixel data word
        if (visible = YES) and (pixel_cnt(0 downto 0) = 0) then
          rd_x       <= YES;            -- read new pixel data from buffer every 2 clocks during visible portion of scan line
        end if;
        pixel_data_x <= "00000000" & pixel_data_r(15 downto 8);  -- left-shift pixel data to move next pixel to LSB 
      when others =>                    -- any other width, then 1 per pixel data word
        if (visible = YES) then
          rd_x       <= YES;            -- read new pixel data from buffer every clock during visible portion of scan line
        end if;
        pixel_data_x <= pixel_data_r;
    end case;

    -- store the pixel data from the buffer instead of shifting the pixel data
    -- if a read operation was initiated in the previous cycle.
    if rd_r = YES then
      pixel_data_x <= pixel_data_in;
    end if;

    -- the current pixel is in the lower bits of the pixel data shift register
    pixel <= pixel_data_r(pixel'range);
  end process get_pixel;

  -- map the current pixel to RGB values
  map_pixel : process(pixel, rgb_r, blank_r)
  begin
    if NUM_RGB_BITS=2 then
    case PIXEL_WIDTH is
      when 1          =>                -- 1-bit pixels map to black or white
			  rgb_x <= (others => pixel(0));
      when 2          =>                -- 2-bit pixels map to black, 2/3 gray, 1/3 gray, and white
			  rgb_x <= pixel(1 downto 0) & pixel(1 downto 0) & pixel(1 downto 0);
      when 4          =>                -- 4-bit pixels map to 8 colors (ignore MSB)
			  rgb_x <= pixel(2) & pixel(2) & pixel(1) & pixel(1) & pixel(0) & pixel(0);
      when 8          =>                -- 8-bit pixels map directly to RGB values
        rgb_x <= pixel(7 downto 6) & pixel(4 downto 1);
      when others     =>                -- 16-bit pixels maps directly to RGB values
        rgb_x <= pixel(8) & pixel(7) & pixel(5) & pixel(4) & pixel(2) & pixel(1);
    end case;
    else -- NUM_RGB_BITS=3
    case PIXEL_WIDTH is
      when 1          =>                -- 1-bit pixels map to black or white
			  rgb_x <= (others => pixel(0));
      when 2          =>                -- 2-bit pixels map to black, 5/7 gray, 3/7 gray, and  1/7 gray
			  rgb_x <= pixel(1 downto 0) & '0' & pixel(1 downto 0) & '0' & pixel(1 downto 0) & '0';
      when 4          =>                -- 4-bit pixels map to 8 colors (ignore MSB)
			  rgb_x <= pixel(2) & pixel(2) & pixel(2) & pixel(1) & pixel(1) & pixel(1) & pixel(0) & pixel(0) & pixel(0);
      when 8          =>                -- 8-bit pixels map to RGB with reduced resolution in green component
        rgb_x <= pixel(7 downto 5) & pixel(4 downto 3) & '0' & pixel(2 downto 0);
      when others     =>                -- 16-bit pixels map directly to RGB values
        rgb_x <= pixel(8 downto 0);
    end case;
    end if;

    -- just blank the pixel if not in the visible region of the screen
    if blank_r(blank_r'high-1) = YES then
      rgb_x <= (others => '0');
    end if;

    -- break the pixel into its red, green and blue components
    r <= rgb_r(3*NUM_RGB_BITS-1 downto 2*NUM_RGB_BITS);
    g <= rgb_r(2*NUM_RGB_BITS-1 downto NUM_RGB_BITS);
    b <= rgb_r(NUM_RGB_BITS-1 downto 0);
  end process map_pixel;

-- update registers
  update : process(rst, clk)
  begin
    if rst = YES then
      eof_r          <= '0';
      rd_r           <= NO;
      hsync_r        <= (others => '1');
      blank_r        <= (others => '0');
      pixel_data_r   <= (others => '0');
      rgb_r          <= (others => '0');
    elsif rising_edge(clk) then
      eof_r          <= eof_x;          -- end-of-frame signal goes at full clock rate to external system
      if cke = YES then
        rd_r         <= rd_x;
        hsync_r      <= hsync_x;
        blank_r      <= blank_x;
        pixel_data_r <= pixel_data_x;
        rgb_r        <= rgb_x;
      end if;
    end if;
  end process update;

end architecture vga_arch;

library IEEE, unisim;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use unisim.vcomponents.all;
use work.common.all;

-- Generate a sync pulse within a waveform PERIOD.
-- Also output the value of the counter used for timing so that
-- it can be used in generating an address for a video RAM.

entity sync is
  generic (
    FREQ    :     natural := 100_000;    -- master clock frequency (in KHz)
    PERIOD  :     natural := 32;        -- period of sync pulse (in us)
    START   :     natural := 26;        -- time sync pulse starts within the period (in us)
    WIDTH   :     natural := 4;         -- width of sync pulse (in us)
    VISIBLE :     natural := 1024       -- number of visible pixels/line or lines/frame
    );
  port (
    rst     : in  std_logic;            -- reset
    clk     : in  std_logic;            -- master clock
    cke     : in  std_logic;            -- clock-enable
    sync_n  : out std_logic;            -- sync pulse
    gate    : out std_logic;            -- single-clock pulse at start of sync pulse
    blank   : out std_logic;            -- blanking signal
    cnt     : out unsigned(15 downto 0)  -- output the timing counter value
    );
end entity sync;

architecture sync_arch of sync is
  constant NORM             : natural := 1000;  -- normalization factor for us * KHz
  constant CYC_PERIOD       : natural := (PERIOD * FREQ)/NORM;  -- sync wave PERIOD in clock cycles
  constant CYC_START        : natural := (START * FREQ)/NORM;  -- sync pulse START in cycles
  constant CYC_WIDTH        : natural := (WIDTH * FREQ)/NORM;  -- sync pulse WIDTH in cycles
  constant CYC_END          : natural := CYC_START + CYC_WIDTH;  -- sync pulse end in cycles
  signal   cnt_r, cnt_x     : unsigned(cnt'range);  -- counter for timing sync pulse waveform
  signal   sync_r, sync_x   : std_logic;  -- sync register
  signal   gate_r, gate_x   : std_logic;  -- gate register
  signal   blank_r, blank_x : std_logic;  -- blank register
begin

-- increment counter and wrap around to zero at end of period
  cnt_x <= (others => '0') when cnt_r = CYC_PERIOD-1 else cnt_r+1;

-- generate sync pulse within waveform period
  sync_x <= LO when cnt_r = CYC_START-1 else
            HI when cnt_r = CYC_END-1   else
            sync_r;
  sync_n <= sync_r;

-- generate gate signal at start of sync pulse
  gate_x <= YES when cnt_r = CYC_START-1 else NO;
  gate   <= gate_r;

-- generate blank signal after initial visible period
  blank_x <= YES when cnt_r = VISIBLE-1    else
             NO  when cnt_r = CYC_PERIOD-1 else
             blank_r;
  blank   <= blank_r;

-- output counter value
  cnt <= cnt_r;

-- update counter and registers
  update : process(rst, clk)
  begin
    if rst = YES then
-- ????? SIMULATION PLUG
-- swap this next to place in non-blank cycle
-- this allows data to appear in simulation, and only produces a momentary
-- glitch in real hardware
--      cnt_r     <= (others => '0');
      cnt_r     <= "0000000011111111";
      sync_r    <= HI;
      gate_r    <= NO;
-- ????? SIMULATION PLUG
-- swap this next to place in non-blank cycle
-- this allows data to appear in simulation, and only produces a momentary
-- glitch in real hardware
--      blank_r   <= YES;
      blank_r   <= NO;
    elsif rising_edge(clk) then
      if cke = YES then
        cnt_r   <= cnt_x;
        sync_r  <= sync_x;
        gate_r  <= gate_x;
        blank_r <= blank_x;
      end if;
    end if;
  end process update;

end architecture sync_arch;
