--------------------------------------------------------------------
--  Package:        MultiIO
--  File:           MultiIO.vhd
--  Author:         Thomas Ameseder, Gleichmann Electronics
--  Based on an orginal version by Manfred.Helzle@embedd.it
--  
--  Description:    APB Multiple digital I/O Types and Components
--------------------------------------------------------------------
--  Functionality:
--  8 LEDs,         active low or high, r/w
--  dual 7Segment,  active low or high, w only
--  8 DIL Switches, active low or high, r only
--  8 Buttons,      active low or high, r only, with IRQ enables
--------------------------------------------------------------------

library ieee;
use IEEE.STD_LOGIC_1164.all;

library grlib;
use grlib.amba.all;

package MultiIO is

  -- maximum number of switches and LEDs
  -- specific number that is used can be defined via a generic
  constant N_SWITCHMAX : integer := 8;
  constant N_LEDMAX : integer := 8;

  constant N_BUTTONS   : integer := 12;  -- number of push-buttons

  -- data width of the words for the codec configuration interface
  constant N_CODECBITS : integer := 16;

  -- data width of the words for the i2s digital samples
  constant N_CODECI2SBITS : integer := 16;

  -- the number of register bits that are assigned to the LCD
  -- the enable control bit is set automatically
  -- this constant should comprise the number of data bits as well
  -- as the RW and RS control bits
  constant N_LCDBITS : integer := 10;

  -- number of bits to hold information for the (single/dual)
  -- seven segment display;
  constant N_SEVSEGBITS : integer := 16;

  -- number of expansion connector i/o bits
  constant N_EXPBITS : integer := 40;

  -- number of high-speed connector bits per connector
  constant N_HSCBITS : integer := 4;

  -- number of childboard3 connector i/o bits
  constant N_CB3 : integer := 32;
  
  type asciichar_vect is array (16#30# to 16#46#) of character;

  -- excerpt of the ASCII chart
  constant ascii2char : asciichar_vect :=
--  -------------------------------------------
--  | 30   31   32   33   34   35   36   37   |
--  -------------------------------------------
    ('0', '1', '2', '3', '4', '5', '6', '7',
--  -------------------------------------------
--  | 38   39   3A   3B   3C   3D   3E   3F   |
--  -------------------------------------------
      '8', '9', ':', ';', '<', '=', '>', '?',
--  -------------------------------------------
--  | 40   41   42   43   44   45   46        |
--  -------------------------------------------
      '@', 'A', 'B', 'C', 'D', 'E', 'F');


  ---------------------------------------------------------------------------------------
  -- AUDIO CODEC
  ---------------------------------------------------------------------------------------

  subtype tReg is std_ulogic_vector(N_CODECBITS-1 downto 0);

  type    tRegMap is array(10 downto 0) of tReg;
  subtype tRegData is std_ulogic_vector(8 downto 0);
  subtype tRegAddr is std_ulogic_vector(6 downto 0);

  -- ADDRESS
  constant cAddrLLI   : tRegAddr := "0000000";  -- Left line input channel volume control
  constant cAddrRLI   : tRegAddr := "0000001";  -- Right line input channel volume control
  constant cAddrLCH   : tRegAddr := "0000010";  -- Left channel headphone volume control
  constant cAddrRCH   : tRegAddr := "0000011";  -- Right channel headphone volume control
  constant cAddrAAP   : tRegAddr := "0000100";  -- Analog audio path control
  constant cAddrDAP   : tRegAddr := "0000101";  -- Digital audio path control
  constant cAddrPDC   : tRegAddr := "0000110";  -- Power down control
  constant cAddrDAI   : tRegAddr := "0000111";  -- Digital audio interface format
  constant cAddrSRC   : tRegAddr := "0001000";  -- Sample rate control
  constant cAddrDIA   : tRegAddr := "0001001";  -- Digital interface activation
  constant cAddrReset : tRegAddr := "0001111";  -- Reset register

  -- Data
  constant cDataLLI  : tRegData := "100011111";
  constant cDataRLI  : tRegData := "100011111";
  constant cDataLCH  : tRegData := "011111111";
  constant cDataRCH  : tRegData := "011111111";
  constant cDataAAP  : tRegData := "000011010";
  constant cDataDAP  : tRegData := "000000000";
  constant cDataPDC  : tRegData := "000001010";
  constant cDataDAI  : tRegData := "000000010";
  constant cDataSRC  : tRegData := "010000000";
  constant cDataDIA  : tRegData := "000000001";
  constant cdataInit : tRegData := "000000000";


  -- Register
  constant cRegLLI   : tReg := cAddrLLI & cDataLLI;
  constant cRegRLI   : tReg := cAddrRLI & cDataRLI;
  constant cRegLCH   : tReg := cAddrLCH & cDataLCH;
  constant cRegRCH   : tReg := cAddrRCH & cDataRCH;
  constant cRegAAP   : tReg := cAddrAAP & cDataAAP;
  constant cRegDAP   : tReg := cAddrDAP & cDataDAP;
  constant cRegPDC   : tReg := cAddrPDC & cDataPDC;
  constant cRegDAI   : tReg := cAddrDAI & cDataDAI;
  constant cRegSRC   : tReg := cAddrSRC & cDataSRC;
  constant cRegDIA   : tReg := cAddrDIA & cDataDIA;
  constant cRegReset : tReg := CAddrReset & cdataInit;


  -- Register Map
  constant cregmap : tRegMap := (
    0  => cRegLLI,
    1  => cRegRLI,
    2  => cRegLCH,
    3  => cRegRCH,
    4  => cRegAAP,
    5  => cRegDAP,
    6  => cRegPDC,
    7  => cRegDAI,
    8  => cRegSRC,
    9  => cRegDIA,
    10 => cRegReset
    );

  ---------------------------------------------------------------------------------------

  type MultiIO_in_type is
    record
      switch_in : std_logic_vector(N_SWITCHMAX-1 downto 0);  -- 8 DIL Switches
      -- row input from the key matrix
      row_in    : std_logic_vector(3 downto 0);

      -- expansion connector input bits
      exp_in    : std_logic_vector(N_EXPBITS/2-1 downto 0);
      hsc_in    : std_logic_vector(N_HSCBITS-1 downto 0);

      -- childboard3 connector input bits
      cb3_in : std_logic_vector(N_CB3-1 downto 0);
    end record;
  
  type MultiIO_out_type is
    record
      -- signals for the 7 segment display
      -- data bits 0 to 7 of the LCD
      -- LED signals for the Hpe_midi
      led_a_out  : std_logic;
      led_b_out  : std_logic;
      led_c_out  : std_logic;
      led_d_out  : std_logic;
      led_e_out  : std_logic;
      led_f_out  : std_logic;
      led_g_out  : std_logic;
      led_dp_out : std_logic;
      -- common anode for enabling left and/or right digit
      -- data bit 7 for the LCD
      led_ca_out : std_logic_vector(1 downto 0);

      -- enable output to LED's for the Hpe_midi
      led_enable : std_logic;

      -- LCD-only control signals
      lcd_regsel : std_logic;
      lcd_rw : std_logic;
      lcd_enable : std_logic;

      -- LED register for all boards except the Hpe_midi
      led_out : std_logic_vector(N_LEDMAX-1 downto 0);  -- 8 LEDs

      -- column output to the key matrix
      column_out : std_logic_vector(2 downto 0);

      -- signals for the SPI audio codec
      codec_mode : std_ulogic;
      codec_mclk : std_ulogic;
      codec_sclk : std_ulogic;
      codec_sdin : std_ulogic;
      codec_cs   : std_ulogic;

      codec_din    :  std_ulogic;         -- I2S format serial data input to the sigma-delta stereo DAC
      codec_bclk   :  std_ulogic;         -- I2S serial-bit clock
--  codec_dout   : in  std_ulogic;         -- I2S format serial data output from the sigma-delta stereo ADC
      codec_lrcin  :  std_ulogic;         -- I2S DAC-word clock signal
      codec_lrcout :  std_ulogic;          -- I2S ADC-word clock signal

      -- expansion connector output bits
      exp_out    : std_logic_vector(N_EXPBITS/2-1 downto 0);
      hsc_out    : std_logic_vector(N_HSCBITS-1 downto 0);

      -- childboard3 connector output bits
      -- cb3_out : std_logic_vector(N_CB3-1 downto 0);
    end record;
  
  component MultiIO_APB
    generic
      (
        hpe_version : integer := 0;     -- adapt multiplexing for different boards
        pindex : integer := 0;          -- Leon-Index
        paddr  : integer := 0;          -- Leon-Address
        pmask  : integer := 16#FFF#;    -- Leon-Mask
        pirq   : integer := 0;          -- Leon-IRQ

        clk_freq_in : integer;          -- Leons clock to calculate timings

        led7act   : std_logic := '0';   -- active level for 7Segment
        ledact    : std_logic := '0';   -- active level for LED's
        switchact : std_logic := '1';   -- active level for LED's
        buttonact : std_logic := '1';   -- active level for LED's

        n_switches  : integer := 8;   -- number of switches
        n_leds      : integer := 8    -- number of LEDs

        );

    port (
      rst_n       : in  std_ulogic;        -- global Reset, active low
      clk         : in  std_ulogic;        -- global Clock
      apbi        : in  apb_slv_in_type;   -- APB-Input
      apbo        : out apb_slv_out_type;  -- APB-Output
      MultiIO_in  : in  MultiIO_in_type;   -- MultIO-Inputs
      MultiIO_out : out MultiIO_out_type   -- MultiIO-Outputs
      );
  end component;

end package;
