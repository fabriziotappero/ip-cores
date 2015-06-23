--------------------------------------------------------------------
--  Entity:         MultiIO_APB
--  File:           MultiIO_APB.vhd
--  Author:         Thomas Ameseder, Gleichmann Electronics
--  Based on an orginal version by Manfred.Helzle@embedd.it
--  
--  Description:    APB Multiple digital I/O for minimal User Interface
--------------------------------------------------------------------
--  Functionality:
--  8 LEDs,         active low or high, r/w
--  dual 7Segment,  active low or high, w only
--  8 DIL Switches, active low or high, r only
--  8 Buttons,      active low or high, r only, with IRQ enables
--------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;

library gleichmann;
use gleichmann.spi.all;
use gleichmann.i2c.all;
use gleichmann.miscellaneous.all;
use gleichmann.ge_clkgen.all;
use gleichmann.multiio.all;

--  pragma translate_off
use std.textio.all;
--  pragma translate_on


entity MultiIO_APB is
  generic (
    hpe_version: integer := 0;          -- adapt multiplexing for different boards
    pindex : integer := 0;              -- Leon-Index
    paddr  : integer := 0;              -- Leon-Address
    pmask  : integer := 16#FFF#;        -- Leon-Mask
    pirq   : integer := 0;              -- Leon-IRQ

    clk_freq_in : integer := 25_000_000;  -- Leons clock to calculate timings

    led7act   : std_logic := '0';       -- active level for 7Segment
    ledact    : std_logic := '0';       -- active level for LEDs
    switchact : std_logic := '1';       -- active level for LED's
    buttonact : std_logic := '1';       -- active level for LED's

    n_switches  : integer := 8;   -- number of switches that are driven
    n_leds      : integer := 8    -- number of LEDs that are driven

    );

  port (
    rst_n       : in  std_ulogic;        -- global Reset, active low
    clk         : in  std_ulogic;        -- global Clock
    apbi        : in  apb_slv_in_type;   -- APB-Input
    apbo        : out apb_slv_out_type;  -- APB-Output
    MultiIO_in  : in  MultiIO_in_type;   -- MultIO-Inputs
    MultiIO_out : out MultiIO_out_type   -- MultiIO-Outputs
    );
end entity;


architecture Implementation of MultiIO_APB is  ----------------------

  constant VERSION  : std_logic_vector(31 downto 0) := x"EA_07_12_06";
  constant REVISION : integer                       := 1;
  constant MUXMAX   : integer                       := 7;

  constant VCC : std_logic_vector(31 downto 0) := (others => '1');
  constant GND : std_logic_vector(31 downto 0) := (others => '0');

  signal Enable1ms  : boolean;
  signal MUXCounter : integer range 0 to MUXMAX-1;

  signal clkgen_mclk   : std_ulogic;
  signal clkgen_bclk   : std_ulogic;
  signal clkgen_sclk   : std_ulogic;
  signal clkgen_lrclk : std_ulogic;

  type state_t is (WAIT_FOR_SYNC,READY,WAIT_FOR_ACK);
  signal state,next_state : state_t;
  signal Strobe,next_Strobe                        : std_ulogic;

  -- status signals of the i2s core for upper-level state machine
  signal SampleAck, WaitForSample : std_ulogic;
  signal samplereg : std_ulogic_vector(N_CODECI2SBITS-1 downto 0);

  constant pconfig : apb_config_type := (
    0 => ahb_device_reg (VENDOR_GLEICHMANN, GLEICHMANN_HIFC, 0, REVISION, pirq),
    1 => apb_iobar(paddr, pmask)
    );

  type MultiIOregisters is
    record
      ledreg  : std_logic_vector(31 downto 0);    -- LEDs
      led7reg : std_logic_vector(31 downto 0);    -- Dual 7Segment LEDs
      codecreg : std_logic_vector(31 downto 0);
      codecreg2 : std_logic_vector(31 downto 0);

      -- Switches in
      sw_inreg  : std_logic_vector(31 downto 0);
      -- ASCII value of input button
      btn_inreg : std_logic_vector(31 downto 0);

      irqenareg : std_logic_vector(31 downto 0);  -- IRQ enables for Buttons
      btn_irqs  : std_logic_vector(31 downto 0);  -- IRQs from each Button

      new_data : std_ulogic;
--      new_data_valid : std_ulogic;
      lcdreg : std_logic_vector(31 downto 0);  -- LCD instruction

      --cb1_in_reg : std_logic_vector(31 downto 0);
      --cb1_out_reg : std_logic_vector(31 downto 0);

      -- cb3_in_reg : std_logic_vector(31 downto 0);
      --cb4_in2_reg : std_logic_vector(31 downto 0);
      -- cb3_out_reg : std_logic_vector(31 downto 0);
      --cb4_out2_reg : std_logic_vector(31 downto 0);
      
      exp_in_reg : std_logic_vector(31 downto 0);
      exp_out_reg : std_logic_vector(31 downto 0);

      hsc_out_reg : std_logic_vector(31 downto 0);
      hsc_in_reg  : std_logic_vector(31 downto 0);
    end record;

  signal r, rin : MultiIOregisters;     -- register sets

  signal Key           : std_logic_vector(7 downto 0);  -- ASCII value of button
  -- character representation of the key (for simulation purposes)
  signal KeyVal        : character;

  signal OldColumnRow1 : std_logic_vector(6 downto 0);  -- for key debounce
  signal OldColumnRow2 : std_logic_vector(6 downto 0);  -- for key debounce

begin

  reg_rw : process(MUXCounter, MultiIO_in, apbi, key, r, rst_n)
    variable readdata : std_logic_vector(31 downto 0);  -- system bus width
    variable irqs     : std_logic_vector(31 downto 0);  -- system IRQs width
    variable v        : MultiIOregisters;               -- register set
  begin
    v := r;

    --  reset registers
    if rst_n = '0' then
      -- lower half of LEDs on
      v.ledreg := (others => '0');
      v.ledreg(3 downto 0) := "1111";

      v.led7reg := (others => '0');
      v.led7reg(15 downto 0) := X"38_4F";            -- show "L3" Leon3 on 7Segments

      v.codecreg := (others => '0');
      v.codecreg2 := (others => '0');
      v.irqenareg := (others => '0');   -- IRQs disable
      v.btn_inreg := (others => '0');
      v.sw_inreg  := (others => '0');

      -- new data flag off
      v.new_data := '0';
--      v.new_data_valid := '0';
      v.lcdreg := (others => '0');

      -- v.cb3_in_reg := (others => '0');
      --v.cb4_in2_reg := (others => '0');
      -- v.cb3_out_reg := (others => '0');
      --v.cb4_out2_reg := (others => '0');
      
      v.exp_in_reg := (others => '0');
      v.exp_out_reg := (others => '0');

      v.hsc_in_reg := (others => '0');
      v.hsc_out_reg := (others => '0');
    end if;

    --  get switches and buttons
    if switchact = '1' then
      v.sw_inreg(N_SWITCHES-1 downto 0) := MultiIO_in.switch_in;
    else
      v.sw_inreg(N_SWITCHES-1 downto 0) := not MultiIO_in.switch_in;
    end if;

    v.btn_inreg(7 downto 0) := key;

    v.btn_irqs := (others => '0');

    ---------------------------------------------------------------------------
    -- TO BE ALTERED
    ---------------------------------------------------------------------------
    --  set local button-IRQs
    for i in 0 to v.btn_irqs'left loop
      -- detect low-to-high transition
      if (v.btn_inreg(i) = '1') and (r.btn_inreg(i) = '0') then
        -- set local IRQs if IRQ enabled
        v.btn_irqs(i) := v.btn_inreg(i) and r.irqenareg(i);
      else
        -- clear local IRQs
        v.btn_irqs(i) := '0';
      end if;
    end loop;
    ---------------------------------------------------------------------------

    --  read registers
    readdata := (others => 'X');

    case conv_integer(apbi.paddr(6 downto 2)) is
      when 0 => readdata := r.ledreg;   -- LEDs
      when 1 => readdata := r.led7reg;  -- seven segment
      when 2 => readdata := r.codecreg;  -- codec command register
      when 3 => readdata := r.codecreg2;  -- codec i2s register
      when 4 => readdata := r.sw_inreg;   -- switches
      when 5 => readdata := r.btn_inreg;  -- buttons
      when 6 => readdata := r.irqenareg;  -- IRQ enables
      when 7 => readdata := conv_std_logic_vector(pirq, 32);  -- IRQ#
      when 8 => readdata := version;      -- version
      when 9 => readdata := r.lcdreg;   -- LCD data
      when 10 => readdata := r.exp_out_reg;  -- expansion connector out
      when 11 => readdata := r.exp_in_reg;  -- expansion connector in
      when 12 => readdata := r.hsc_out_reg;
      when 13 => readdata := r.hsc_in_reg;
      --when 14 => readdata := r.cb4_out1_reg;  -- childboard4 connector out
      --when 15 => readdata := r.cb4_out2_reg;  -- childboard4 connector out
      -- when 14 => readdata := r.cb3_in_reg;  -- childboard3 connector in
      -- when 15 => readdata := r.cb3_out_reg;  -- childboard3 connector out
      --when 14 => readdata := r.cb1_out_reg;  -- childboard1 connector out
      --when 15 => readdata := r.cb1_in_reg;  -- childboard1 connector in
      when others => null;
    end case;

    --  write registers
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case conv_integer(apbi.paddr(6 downto 2)) is
        when 0 => v.ledreg :=
                    GND(31 downto N_LEDS) &
                    apbi.pwdata(N_LEDS-1 downto 0);        -- write LEDs
        when 1 => v.led7reg :=
                    GND(31 downto N_SEVSEGBITS) &
                    apbi.pwdata(N_SEVSEGBITS-1 downto 0);  -- write 7Segment
        when 2 => v.codecreg :=
                    GND(31 downto N_CODECBITS) &
                    apbi.pwdata(N_CODECBITS-1 downto 0);
        when 3 => v.codecreg2 :=
                    GND(31 downto N_CODECI2SBITS) &
                    apbi.pwdata(N_CODECI2SBITS-1 downto 0);
        when 6 => v.irqenareg :=
                    GND(31 downto N_BUTTONS) &
                    apbi.pwdata(N_BUTTONS-1 downto 0);
        when 9 => v.lcdreg :=
                    GND(31 downto N_LCDBITS) &
                    apbi.pwdata(N_LCDBITS-1 downto 0);
                  -- signal that new data has arrived
--                  v.new_data_valid := '0';
                  v.new_data := '1';
        when 10 => v.exp_out_reg :=
                    GND(31 downto N_EXPBITS/2) &
                    -- bit(N_EXPBITS) holds enable signal
                    apbi.pwdata(N_EXPBITS/2-1 downto 0);
        when 12 => v.hsc_out_reg :=
                     GND(31 downto N_HSCBITS) &
                     apbi.pwdata(N_HSCBITS-1 downto 0);
        --when 14 => v.cb4_out1_reg :=
        --             apbi.pwdata(31 downto 0);
        -- when 15 => v.cb3_out_reg :=
        --              apbi.pwdata(31 downto 0);
        --when 14 => v.exp_out_reg :=
        --            GND(31 downto 13) &
        --            -- bit(N_EXPBITS) holds enable signal
        --            apbi.pwdata(12 downto 0);
        when others => null;
      end case;
    end if;

    --  set PIRQ
    irqs := (others => '0');
    for i in 0 to v.btn_irqs'left loop
      -- set IRQ if button-i pressed and IRQ enabled
      irqs(pirq) := irqs(pirq) or r.btn_irqs(i);
    end loop;

    if ledact = '1' then
      MultiIO_out.led_out <= r.ledreg(N_LEDS-1 downto 0);      -- not inverted
    else
      MultiIO_out.led_out <= not r.ledreg(N_LEDS-1 downto 0);  -- inverted
    end if;

    -- disable seven segment and LC display by default
--    MultiIO_out.lcd_enable <= '0';
    MultiIO_out.lcd_rw     <= r.lcdreg(8);
    MultiIO_out.lcd_regsel <= r.lcdreg(9);

    -- reset new lcd data flag
    -- will be enabled when new data are written to the LCD register
    if MUXCounter = 4 then
      v.new_data := '0';
--      v.serviced := '1';
    end if;

    -- register inputs from expansion connector
    v.exp_in_reg(N_EXPBITS/2-1 downto 0) := MultiIO_in.exp_in;

    MultiIO_out.exp_out <= r.exp_out_reg(N_EXPBITS/2-1 downto 0);

    -- high-speed connector
    v.hsc_in_reg(N_HSCBITS-1 downto 0) := MultiIO_in.hsc_in;
    MultiIO_out.hsc_out <= r.hsc_out_reg(N_HSCBITS-1 downto 0);

    -- configure control port of audio codec for SPI mode
    MultiIO_out.codec_mode <= '1';

    apbo.prdata <= readdata;            -- output data to Leon
    apbo.pirq   <= irqs;                -- output IRQs to Leon
    apbo.pindex <= pindex;              -- output index to Leon

    rin <= v;                           -- update registers

  end process;


  apbo.pconfig <= pconfig;              -- output config to Leon


  regs : process(clk)                   -- update registers
  begin
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process;


  KeyBoard : process(clk, rst_n)
    variable ColumnStrobe : std_logic_vector(2 downto 0);
    variable FirstTime    : boolean;
    variable NewColumnRow : std_logic_vector(6 downto 0);
  begin
    if rst_n = '0' then
      MultiIO_out.column_out <= (others => '0');  -- all column off
      Key                    <= X"40";  -- default '@' after Reset and no key pressed
      OldColumnRow1          <= "1111111";
      OldColumnRow2          <= "1110011";
      ColumnStrobe           := "001";
      FirstTime              := true;
    elsif rising_edge(clk) then
      if Enable1ms then
        if MultiIO_in.row_in = "0000" then        -- no key pressed
          ColumnStrobe           := ColumnStrobe(1) & ColumnStrobe(0) & ColumnStrobe(2);  -- rotate column
          MultiIO_out.column_out <= ColumnStrobe;

          if not FirstTime then
            Key <= X"3F";               -- no key pressed '?'
          end if;
          
        else                            -- key pressed
          OldColumnRow2 <= OldColumnRow1;

          -- check whether button inputs produce a high or a
          -- low level, then assign these inputs in order that
          -- they can be decoded into ASCII format
          if buttonact = '1' then
            NewColumnRow := ColumnStrobe & MultiIO_in.row_in;
          else
            NewColumnRow := ColumnStrobe & not MultiIO_in.row_in;
          end if;

          OldColumnRow1 <= NewColumnRow;

          if (ColumnStrobe & MultiIO_in.row_in = OldColumnRow1) and
            (OldColumnRow1 = OldColumnRow2)
          then                          -- debounced
            FirstTime := false;         -- 1st valid key pressed

            case OldColumnRow2 is       -- decode keys into ascii characters
              when "0010001" => Key <= x"31";  -- 1
              when "0010010" => Key <= x"34";  -- 4
              when "0010100" => Key <= x"37";  -- 7
              when "0011000" => Key <= x"43";  -- C
              when "0100001" => Key <= x"32";  -- 2
              when "0100010" => Key <= x"35";  -- 5
              when "0100100" => Key <= x"38";  -- 8
              when "0101000" => Key <= x"30";  -- 0
              when "1000001" => Key <= x"33";  -- 3
              when "1000010" => Key <= x"36";  -- 6
              when "1000100" => Key <= x"39";  -- 9
              when "1001000" => Key <= x"45";  -- E
              when others => Key    <= x"39";  -- ?    -- more than one key pressed
            end case;
          else
            Key <= x"3D";  -- '='    -- bouncing
          end if;  -- debounce
        end if;  -- MultiIO_in.row_in
      end if;  -- Enable1ms
    end if;  -- rst_n
  end process KeyBoard;

  Multiplex3Sources : if hpe_version = midi generate
    Multiplex : process(MUXCounter, r)
    begin
      -- disable LED output by default
      MultiIO_out.led_enable <= '0' xnor ledact;
      -- disable 7-segment display by default
      MultiIO_out.led_ca_out <= "00" xnor (led7act & led7act);

      -- set enable signal in the middle of LCD timeslots
      if MUXCounter = 3 then
        MultiIO_out.lcd_enable <= '1';
      else
        MultiIO_out.lcd_enable <= '0';
      end if;

      case MUXCounter is
        when 0 | 1 =>
          -- output logical value according to active level of the 7segment display
          MultiIO_out.led_a_out  <= r.led7reg(MUXCounter*8 + 0) xnor led7act;
          MultiIO_out.led_b_out  <= r.led7reg(MUXCounter*8 + 1) xnor led7act;
          MultiIO_out.led_c_out  <= r.led7reg(MUXCounter*8 + 2) xnor led7act;
          MultiIO_out.led_d_out  <= r.led7reg(MUXCounter*8 + 3) xnor led7act;
          MultiIO_out.led_e_out  <= r.led7reg(MUXCounter*8 + 4) xnor led7act;
          MultiIO_out.led_f_out  <= r.led7reg(MUXCounter*8 + 5) xnor led7act;
          MultiIO_out.led_g_out  <= r.led7reg(MUXCounter*8 + 6) xnor led7act;
          MultiIO_out.led_dp_out <= r.led7reg(MUXCounter*8 + 7) xnor led7act;
          -- selectively enable the current digit
          for i in 0 to 1 loop
            if i = MUXCounter then
              MultiIO_out.led_ca_out(i) <= '1' xnor led7act;
            else
              MultiIO_out.led_ca_out(i) <= '0' xnor led7act;
            end if;
          end loop;  -- i
        when 2 | 3 | 4 =>
          MultiIO_out.led_a_out  <= r.lcdreg(0);
          MultiIO_out.led_b_out  <= r.lcdreg(1);
          MultiIO_out.led_c_out  <= r.lcdreg(2);
          MultiIO_out.led_d_out  <= r.lcdreg(3);
          MultiIO_out.led_e_out  <= r.lcdreg(4);
          MultiIO_out.led_f_out  <= r.lcdreg(5);
          MultiIO_out.led_g_out  <= r.lcdreg(6);
          MultiIO_out.led_dp_out <= r.lcdreg(7);
        when 5 | 6 =>
          MultiIO_out.led_enable <= '1' xnor ledact;
          MultiIO_out.led_a_out  <= r.ledreg(0) xnor ledact;
          MultiIO_out.led_b_out  <= r.ledreg(1) xnor ledact;
          MultiIO_out.led_c_out  <= r.ledreg(2) xnor ledact;
          MultiIO_out.led_d_out  <= r.ledreg(3) xnor ledact;
          MultiIO_out.led_e_out  <= r.ledreg(4) xnor ledact;
          MultiIO_out.led_f_out  <= r.ledreg(5) xnor ledact;
          MultiIO_out.led_g_out  <= r.ledreg(6) xnor ledact;
          MultiIO_out.led_dp_out <= r.ledreg(7) xnor ledact;
        when others =>
          null;
      end case;
    end process Multiplex;
  end generate Multiplex3Sources;

  Multiplex2Sources : if hpe_version /= midi generate
    Multiplex : process(MUXCounter, r)
    begin
      -- disable LED output by default
      MultiIO_out.led_enable <= '0' xnor ledact;
      -- disable 7-segment display by default
      MultiIO_out.led_ca_out <= "00" xnor (led7act & led7act);

      -- set enable signal in the middle of LCD timeslots
      if MUXCounter = 3 then
        MultiIO_out.lcd_enable <= '1';
      else
        MultiIO_out.lcd_enable <= '0';
      end if;

      case MUXCounter is
        when 0 | 1 =>
          -- output logical value according to active level of the 7segment display
          MultiIO_out.led_a_out  <= r.led7reg(MUXCounter*8 + 0) xnor led7act;
          MultiIO_out.led_b_out  <= r.led7reg(MUXCounter*8 + 1) xnor led7act;
          MultiIO_out.led_c_out  <= r.led7reg(MUXCounter*8 + 2) xnor led7act;
          MultiIO_out.led_d_out  <= r.led7reg(MUXCounter*8 + 3) xnor led7act;
          MultiIO_out.led_e_out  <= r.led7reg(MUXCounter*8 + 4) xnor led7act;
          MultiIO_out.led_f_out  <= r.led7reg(MUXCounter*8 + 5) xnor led7act;
          MultiIO_out.led_g_out  <= r.led7reg(MUXCounter*8 + 6) xnor led7act;
          MultiIO_out.led_dp_out <= r.led7reg(MUXCounter*8 + 7) xnor led7act;
          -- selectively enable the current digit
          for i in 0 to 1 loop
            if i = MUXCounter then
              MultiIO_out.led_ca_out(i) <= '1' xnor led7act;
            else
              MultiIO_out.led_ca_out(i) <= '0' xnor led7act;
            end if;
          end loop;  -- i

        when others =>
          MultiIO_out.led_a_out  <= r.lcdreg(0);
          MultiIO_out.led_b_out  <= r.lcdreg(1);
          MultiIO_out.led_c_out  <= r.lcdreg(2);
          MultiIO_out.led_d_out  <= r.lcdreg(3);
          MultiIO_out.led_e_out  <= r.lcdreg(4);
          MultiIO_out.led_f_out  <= r.lcdreg(5);
          MultiIO_out.led_g_out  <= r.lcdreg(6);
          MultiIO_out.led_dp_out <= r.lcdreg(7);
      end case;
    end process Multiplex;
  end generate Multiplex2Sources;


  -- generate prescaler signal every 100 ms
  -- control MUXCounter according to input and board type
  Count1ms : process(clk, rst_n)
    constant divider100ms        : integer := clk_freq_in / 10_000;
    variable frequency_counter : integer range 0 to Divider100ms;
  begin
    if rst_n = '0' then
      frequency_counter := Divider100ms;
      Enable1ms         <= false;
      MUXCounter        <= 0;
    elsif rising_edge(clk) then
      if frequency_counter = 0 then  -- 1-ms counter has expired
        frequency_counter := Divider100ms;
        Enable1ms         <= true;

        if (hpe_version = midi) then
          -- skip LCD control sequence and go to
          -- LED control
          if (MUXCounter = 1 and r.new_data = '0') then
            MUXCounter <= 5;
          -- overflow at maximum counter value for Hpe_midi
          elsif MUXCounter = MUXMAX-1 then
            MUXCounter <= 0;
          else
            MUXCounter <= MUXCounter + 1;
          end if;
        elsif (hpe_version /= midi) then
          -- skip LCD control sequence and go back to
          -- 7-segment control
          if (MUXCounter = 1 and r.new_data = '0') then
            MUXCounter <= 0;
          -- overflow at maximum counter value for Hpe_mini
          elsif MUXCounter = MUXMAX-3 then
            MUXCounter <= 0;
          else
            MUXCounter <= MUXCounter + 1;
          end if;
        end if;

      else
        frequency_counter := frequency_counter - 1;
        Enable1ms         <= false;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------------------
  -- AUDIO CODEC SECTION
  ---------------------------------------------------------------------------------------

  tlv320aic23b_audio : if hpe_version = mini_altera generate

    -- audio clock generation
    clk_gen : ClockGenerator
      port map (
        Clk     => clk,
        Reset   => rst_n,
        omclk   => clkgen_mclk,
        obclk   => clkgen_bclk,
        osclk   => clkgen_sclk,
        olrcout => clkgen_lrclk);

    -- drive clock signals by clock generator
    MultiIO_out.CODEC_SCLK   <= clkgen_sclk;
    MultiIO_out.CODEC_MCLK   <= clkgen_mclk;
    MultiIO_out.CODEC_BCLK   <= clkgen_bclk;
    MultiIO_out.CODEC_LRCIN  <= clkgen_lrclk;
    MultiIO_out.CODEC_LRCOUT <= clkgen_lrclk;

    -- SPI control interface
    spi_xmit_1 : spi_xmit
      generic map (
        data_width => N_CODECBITS)
      port map (
        clk_i      => clkgen_SCLK,
        rst_i      => rst_n,
        data_i     => r.codecreg(N_CODECBITS-1 downto 0),
        CODEC_SDIN => MultiIO_out.CODEC_SDIN,
        CODEC_CS   => MultiIO_out.CODEC_CS);

    -- I2C data interface
    ParToI2s_1 : ParToI2s
      generic map (
        SampleSize_g => N_CODECI2SBITS)
      port map (
        Clk_i           => clk,
        Reset_i         => rst_n,
        SampleLeft_i    => SampleReg,
        SampleRight_i   => SampleReg,
        StrobeLeft_i    => Strobe,
        StrobeRight_i   => Strobe,
        SampleAck_o     => SampleAck,
        WaitForSample_o => WaitForSample,
        SClk_i          => clkgen_sclk,
        LRClk_i         => clkgen_lrclk,
        SdnyData_o      => MultiIO_out.CODEC_DIN);

    audio_ctrl_sm : process(SampleAck, WaitForSample, state)
    begin
      next_state  <= state;
      next_Strobe <= '0';
      case state is
        when WAIT_FOR_SYNC =>
          if WaitForSample = '1' then
            next_state <= READY;
          end if;
        when READY =>
          next_state  <= WAIT_FOR_ACK;
          next_Strobe <= '1';
        when WAIT_FOR_ACK =>
          if SampleAck = '1' then
            next_state <= READY;
          end if;
        when others =>
          next_state <= WAIT_FOR_SYNC;
      end case;
    end process;

    audio_ctrl_reg : process(clk, rst_n)
    begin
      if rst_n = '0' then               -- asynchronous reset
        state     <= WAIT_FOR_SYNC;
        Strobe    <= '0';
        SampleReg <= (others => '0');
      elsif clk'event and clk = '1' then
        state  <= next_state;
        Strobe <= next_Strobe;
        if (next_Strobe) = '1' then
--        if Mode = '0' then
--          SampleReg <= std_ulogic_vector(unsigned(AudioSample)- X"80");
--        else
--          SampleReg <= AudioSample;
--        end if;
          SampleReg <= std_ulogic_vector(r.codecreg2(N_CODECI2SBITS-1 downto 0));
        end if;
      end if;
    end process;

  end generate tlv320aic23b_audio;


  ---------------------------------------------------------------------------------------
  -- DEBUG SECTION
  ---------------------------------------------------------------------------------------

--  pragma translate_off
  KeyVal <=
    ascii2char(conv_integer(Key)) when
    (conv_integer(Key) >= 16#30#) and (conv_integer(Key) <= 16#46#)
    else 'U';

  bootmsg : report_version
    generic map ("MultiIO_APB6:" & tost(pindex) &
                 ", Human Interface Controller rev " & tost(REVISION) &
                 ", IRQ " & tost(pirq));
--  pragma translate_on

end architecture;
