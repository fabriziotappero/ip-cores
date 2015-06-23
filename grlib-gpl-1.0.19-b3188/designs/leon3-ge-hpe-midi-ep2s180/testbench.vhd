-----------------------------------------------------------------------------
--  LEON3 Demonstration design test bench
--  Copyright (C) 2004 Jiri Gaisler, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library gaisler;
use gaisler.libdcom.all;
use gaisler.sim.all;
--use gaisler.jtagtst.all;

library techmap;
use techmap.gencomp.all;

library micron;
use micron.components.all;

library gleichmann;
use gleichmann.hpi.all;
-- modified version of the JTAG test package
--  use gleichmann.jtagtst.all;

library work;
use work.debug.all;
use work.config.all;                    -- configuration


entity testbench is
  generic (
    fabtech : integer := CFG_FABTECH;
    memtech : integer := CFG_MEMTECH;
    padtech : integer := CFG_PADTECH;
    clktech : integer := CFG_CLKTECH;
    disas   : integer := CFG_DISAS;     -- Enable disassembly to console
    dbguart : integer := CFG_DUART;     -- Print UART on console
    pclow   : integer := CFG_PCLOW;

    clkperiod : integer := 25;          -- system clock period
    romwidth  : integer := 32;          -- rom data width (8/32)
    romdepth  : integer := 16;          -- rom address depth
    sramwidth : integer := 32;          -- ram data width (8/16/32)
    sramdepth : integer := 16;          -- ram address depth
    srambanks : integer := 2);          -- number of ram banks
  port (
    pci_rst    : in    std_logic;      -- PCI bus
    pci_clk    : in    std_logic;
    pci_gnt    : in    std_logic;
    pci_idsel  : in    std_logic;
    pci_lock   : inout std_logic;
    pci_ad     : inout std_logic_vector(31 downto 0);
    pci_cbe    : inout std_logic_vector(3 downto 0);
    pci_frame  : inout std_logic;
    pci_irdy   : inout std_logic;
    pci_trdy   : inout std_logic;
    pci_devsel : inout std_logic;
    pci_stop   : inout std_logic;
    pci_perr   : inout std_logic;
    pci_par    : inout std_logic;
    pci_req    : inout std_logic;
    pci_serr   : inout std_logic;
    pci_host   : in    std_logic;
    pci_66     : in    std_logic);
end testbench;


architecture behav of testbench is

  constant promfile  : string := "prom.srec";   -- rom contents
  constant sramfile  : string := "sram.srec";   -- ram contents
  constant sdramfile : string := "sdram.srec";  -- sdram contents


  signal   clk : std_logic := '0';
  signal   Rst : std_logic := '0';      -- Reset
  constant ct  : integer   := clkperiod/2;

  signal address : std_logic_vector(27 downto 0);
  signal data    : std_logic_vector(31 downto 0);

  signal ramsn                               : std_logic_vector(4 downto 0);
  signal ramoen                              : std_logic_vector(4 downto 0);
  signal rwen                                : std_logic_vector(3 downto 0);
  signal rwenx                               : std_logic_vector(3 downto 0);
  signal romsn                               : std_logic_vector(1 downto 0);
  signal iosn                                : std_logic;
  signal oen                                 : std_logic;
  signal read                                : std_logic;
  signal writen                              : std_logic;
  signal brdyn                               : std_logic;
  signal bexcn                               : std_logic;
  signal wdog                                : std_logic;
  signal dsuen, dsutx, dsurx, dsubre, dsuact : std_logic;
  signal dsurst                              : std_logic;
  signal test                                : std_logic;

  signal error : std_logic;
  alias errorn : std_logic is error;

  signal pio  : std_logic_vector(15 downto 0);
  signal GND  : std_logic := '0';
  signal VCC  : std_logic := '1';
  signal NC   : std_logic := 'Z';
  signal clk2 : std_logic := '1';

-- sdram
  signal sdclk  : std_logic_vector(1 downto 0);
-- signal sdclk    : std_logic;       
--  alias sdclk   : std_logic is sd_clk(0);
  signal sdcke  : std_logic_vector (1 downto 0);  -- clk en
  signal sa     : std_logic_vector(14 downto 0);
  signal sd     : std_logic_vector(63 downto 0);
  signal sddqm  : std_logic_vector (7 downto 0);  -- data i/o mask
  signal sdwen  : std_logic;                     -- write en
  signal sdcasn : std_logic;                     -- col addr stb
  signal sdrasn : std_logic;                     -- row addr stb
  signal sdcsn  : std_logic_vector (1 downto 0);  -- chip sel

  signal plllock : std_logic;

-- pulled up high, therefore std_logic
  signal txd1, rxd1 : std_logic;

  signal etx_clk, erx_clk, erx_dv, erx_er, erx_col, erx_crs, etx_en, etx_er : std_logic                    := '0';
  signal erxd, etxd                                                         : std_logic_vector(3 downto 0) := (others => '0');
  signal emdc, emdio                                                        : std_logic;  --dummy signal for the mdc,mdio in the phy which is not used

  signal emddis  : std_logic;
  signal epwrdwn : std_logic;
  signal ereset  : std_logic;
  signal esleep  : std_logic;
  signal epause  : std_logic;
  signal tp_out  : std_logic_vector(7 downto 0);
  signal led_cfg : std_logic_vector(2 downto 0);

  constant lresp : boolean := false;



-- Added for Hpe

  signal resoutn : std_logic;
  signal disrams : std_logic;
  signal rben    : std_logic_vector(3 downto 0);
  signal sdclk0  : std_logic;
  signal sdclk1  : std_logic;
  signal sdba0   : std_logic;           -- bank address zero
  signal sdba1   : std_logic;           -- bank address one
  signal dsubren : std_logic;
  signal dsuactn : std_logic;
  signal bufdir  : std_logic;
  signal bufoen  : std_logic;
  signal s_sddqm : std_logic_vector (3 downto 0);

  signal HRESETn   : std_logic;
  signal HSEL      : std_logic;
  signal HREADY_ba : std_logic;        -- hready input signal
  signal HADDR     : std_logic_vector(31 downto 0);
  signal HWRITE    : std_logic;
  signal HTRANS    : std_logic_vector(1 downto 0);
  signal HSIZE     : std_logic_vector(2 downto 0);
  signal HBURST    : std_logic_vector(2 downto 0);
  signal HWDATA    : std_logic_vector(31 downto 0);
  signal HMASTER   : std_logic_vector(3 downto 0);
  signal HMASTLOCK : std_logic;
  signal HREADY    : std_logic;
  signal HRESP     : std_logic_vector(1 downto 0);
  signal HRDATA    : std_logic_vector(31 downto 0);
  signal HSPLIT    : std_logic_vector(15 downto 0);

  signal clk_ctrl        : std_logic_vector(1 downto 0);  -- cpld      
  signal CAN_RXD         : std_logic;
  signal CAN_TXD         : std_logic;
  signal CAN_STB         : std_logic;
  signal CAN_TXD_delayed : std_logic := '1';
  signal gpio            : std_logic_vector(7 downto 0);

  subtype sd_address_range is natural range 24 downto 12;
  subtype sd_ba_range is natural range 26 downto 25;

  ---------------------------------------------------------------------------------------
  -- HPI SIGNALS
  ---------------------------------------------------------------------------------------
  signal hpiaddr : std_logic_vector(1 downto 0);
  signal hpidata : std_logic_vector(15 downto 0);
  signal hpicsn  : std_logic;
  signal hpiwrn  : std_logic;
  signal hpiint  : std_logic;
  signal hpirdn  : std_logic;
--  signal hpirdata : std_logic_vector(15 downto 0);
--  signal hpiwdata : std_logic_vector(15 downto 0);

--  signal dbg_rdata : std_logic_vector(15 downto 0);
--  signal dbg_wdata : std_logic_vector(15 downto 0);
---------------------------------------------------------------------------------------

component hpi_ram
  generic (
    abits : integer;
    dbits : integer);
  port (
    clk     : in  std_logic;
    address : in  std_logic_vector(1 downto 0);
    datain  : in  std_logic_vector(dbits-1 downto 0);
    dataout : out std_logic_vector(dbits-1 downto 0);
    writen  : in  std_logic;
    readn   : in  std_logic;
    csn     : in  std_logic);
end component;

-----------------------------------------------------------------------------------------
-- IO SECTION
-----------------------------------------------------------------------------------------
  signal dsw          : std_logic_vector(7 downto 0) := "00000001";
  signal led          : std_logic_vector(7 downto 0);
  signal sevensegment : std_logic_vector(9 downto 0);
  signal tst_col      : std_logic_vector(2 downto 0);
  signal tst_row      : std_logic_vector(3 downto 0);
  signal lcd_enable   : std_logic;
  signal lcd_regsel   : std_logic;
  signal lcd_rw       : std_logic;

  signal ac97_bit_clk   : std_logic := '0';
  signal ac97_sync      : std_logic;
  signal ac97_sdata_out : std_logic;
  signal ac97_sdata_in  : std_logic;
  signal ac97_resetn    : std_logic;
  signal ac97_ext_clk   : std_logic;

  signal vga_clk    : std_logic;
  signal vga_syncn  : std_logic;
  signal vga_blankn : std_logic;
  signal vga_vsync  : std_logic;
  signal vga_hsync  : std_logic;
  signal vga_rd     : std_logic_vector(7 downto 0);
  signal vga_gr     : std_logic_vector(7 downto 0);
  signal vga_bl     : std_logic_vector(7 downto 0);

  signal ps2_clk  : std_logic_vector(1 downto 0);
  signal ps2_data : std_logic_vector(1 downto 0);

  signal exp_datao : std_logic_vector(19 downto 0);
  signal exp_datai : std_logic_vector(19 downto 0);

  signal cb4_datao : std_logic_vector(35 downto 0);
  signal cb4_datai : std_logic_vector(35 downto 0);

  signal sdcard_cs   : std_logic;
  signal sdcard_di   : std_logic;
  signal sdcard_sclk : std_logic;
  signal sdcard_do   : std_logic;

  component spi_slave_model
    port(
      csn : in  std_logic;
      sck : in  std_logic;
      di  : in  std_logic;
      do  : out std_logic
      );
  end component;

-----------------------------------------------------------------------------------------
-- USB DEBUG LINK
-----------------------------------------------------------------------------------------
  signal usb_clkout    : std_logic;
  signal usb_d         : std_logic_vector(15 downto 0);
  signal usb_linestate : std_logic_vector(1 downto 0);
  signal usb_opmode    : std_logic_vector(1 downto 0);
  signal usb_reset     : std_logic;
  signal usb_rxactive  : std_logic;
  signal usb_rxerror   : std_logic;
  signal usb_rxvalid   : std_logic;
  signal usb_suspend   : std_logic;
  signal usb_termsel   : std_logic;
  signal usb_txready   : std_logic;
  signal usb_txvalid   : std_logic;
  signal usb_validh    : std_logic;
  signal usb_xcvrsel   : std_logic;
  signal usb_vbus      : std_logic;
  signal usb_dbus16    : std_logic;
  signal usb_unidir    : std_logic;

-----------------------------------------------------------------------------------------
-- ADC/DAC
-----------------------------------------------------------------------------------------
  signal adc_dout : std_logic;
  signal adc_ain  : std_logic;
  signal dac_out  : std_logic;

--------------------------------------------------------------------------------
-- MISC TEST BENCH SIGNALS
--------------------------------------------------------------------------------
  signal clock_cycle_counter : integer;
-- UART test bench module
  signal rts_internal        : std_logic;
  signal cts_internal        : std_logic;

begin
  
  dsubren <= not dsubre;
  disrams <= '0';

-- clock and reset

  clk <= not clk  after ct * 1 ns;
  rst <= '1', '0' after 10 ns, '1' after 100 ns;

  dsuen   <= '1'; dsubre <= '0'; rxd1 <= 'H';
  led_cfg <= "011";                     -- put the phy in base100f mode

  clk_count_seq : process (rst, clk) is
  begin
    if rst = '0' then
      clock_cycle_counter <= 0;
    elsif rising_edge(clk) then
      clock_cycle_counter <= clock_cycle_counter + 1;
    end if;
  end process;

  d3 : entity work.leon3hpe
--    generic map (
--      fabtech => fabtech,
--      memtech => memtech,
--      padtech => padtech,
--      clktech => clktech,
--      disas   => disas,
--      dbguart => dbguart,
--      pclow   => pclow)
    port map (
      resetn  => rst,
      resoutn => resoutn,
      clk     => clk,
--      pllref  => clk,
      errorn  => errorn,
      address => address,
      data    => data,

      sdclk  => sdclk,
      sdcke  => sdcke,
      sdaddr => sa(12 downto 0),
      sddq   => sd,
      sddqm  => sddqm,                  -- topmost bits are undriven
      sdwen  => sdwen,
      sdcasn => sdcasn,
      sdrasn => sdrasn,
      sdcsn  => sdcsn,
      sdba   => sa(14 downto 13),

      dsutx   => dsutx,
      dsurx   => dsurx,
--      dsuen   => dsuen,
      dsubre  => dsubre,
      dsuactn => dsuactn,

      txd1 => txd1,
      rxd1 => rxd1,

--      gpio => gpio,

      ramsn  => ramsn,
      ramoen => ramoen,
      oen    => oen,
      rben   => rben,
      rwen   => rwen,
      writen => writen,
      read   => read,
      iosn   => iosn,
      romsn  => romsn,

      emdio   => emdio,
      etx_clk => etx_clk,
      erx_clk => erx_clk,
      erxd    => erxd,
      erx_dv  => erx_dv,
      erx_er  => erx_er,
      erx_col => erx_col,
      erx_crs => erx_crs,
      etxd    => etxd,
      etx_en  => etx_en,
      etx_er  => etx_er,
      emdc    => emdc,

      can_txd => can_txd,
      can_rxd => can_rxd,
      can_stb => can_stb,

      dsw          => dsw,
--      led          => led,
      sevensegment => sevensegment,
      tst_col      => tst_col,
      tst_row      => tst_row,
      lcd_enable   => lcd_enable,
      lcd_regsel   => lcd_regsel,
      lcd_rw       => lcd_rw,

      ps2_clk   => ps2_clk,
      ps2_data  => ps2_data,
      exp_datao => exp_datao,
      exp_datai => exp_datai,

      -----------------------------------------------------------------------------------
      -- FOR TEST PURPOSES WITH THE AHB2HPI CORE
      -----------------------------------------------------------------------------------

      hpiint => gnd,

      hpiaddr => hpiaddr,
      hpidata => hpidata,
      hpicsn  => hpicsn,
      hpiwrn  => hpiwrn,
      hpirdn  => hpirdn,

      vga_clk    => vga_clk,
      vga_syncn  => vga_syncn,
      vga_blankn => vga_blankn,
      vga_vsync  => vga_vsync,
      vga_hsync  => vga_hsync,
      vga_rd     => vga_rd,
      vga_gr     => vga_gr,
      vga_bl     => vga_bl,

      ac97_bit_clk   => ac97_bit_clk,
      ac97_sync      => ac97_sync,
      ac97_sdata_out => ac97_sdata_out,
      ac97_sdata_in  => ac97_sdata_in,
      ac97_resetn    => ac97_resetn,
--    ac97_ext_clk   => ac97_ext_clk

      usb_clkout    => usb_clkout,
      usb_d         => usb_d,
      usb_linestate => usb_linestate,
      usb_opmode    => usb_opmode,
--      usb_reset     => usb_reset,
      usb_rxactive  => usb_rxactive,
      usb_rxerror   => usb_rxerror,
      usb_rxvalid   => usb_rxvalid,
      usb_suspend   => usb_suspend,
      usb_termsel   => usb_termsel,
      usb_txready   => usb_txready,
      usb_txvalid   => usb_txvalid,
      usb_validh    => usb_validh,
      usb_xcvrsel   => usb_xcvrsel,
      usb_vbus      => usb_vbus,
      usb_dbus16    => usb_dbus16,
      usb_unidir    => usb_unidir,

      adc_dout => adc_dout,
      adc_ain  => adc_ain,
      dac_out  => dac_out,

      sdcard_cs   => sdcard_cs,
      sdcard_di   => sdcard_di,
      sdcard_sclk => sdcard_sclk,
      sdcard_do   => sdcard_do

      );


  spi_slave_model_1 : spi_slave_model
    port map (
      csn => sdcard_cs,
      sck => sdcard_sclk,
      di  => sdcard_di,
      do  => sdcard_do);


  hpi_ram_1 : hpi_ram
    generic map (
      abits => 10,
      dbits => 16)
    port map (
      clk     => clk,
      address => hpiaddr,
      datain  => hpidata,
      dataout => hpidata,
      writen  => hpiwrn,
      readn   => hpirdn,
      csn     => hpicsn);


  sd0 : if (CFG_MCTRL_SDEN = 1) and (CFG_MCTRL_SEPBUS = 0) generate
    u0 : mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
      port map(
        Dq   => data(31 downto 16), Addr => address(14 downto 2),
        Ba   => address(16 downto 15), Clk => sdclk(0), Cke => sdcke(0),
        Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(3 downto 2));
    u1 : mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
      port map(
        Dq   => data(15 downto 0), Addr => address(14 downto 2),
        Ba   => address(16 downto 15), Clk => sdclk(0), Cke => sdcke(0),
        Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(1 downto 0));
    u2 : mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
      port map(
        Dq   => data(31 downto 16), Addr => address(14 downto 2),
        Ba   => address(16 downto 15), Clk => sdclk(0), Cke => sdcke(0),
        Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(3 downto 2));
    u3 : mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
      port map(
        Dq   => data(15 downto 0), Addr => address(14 downto 2),
        Ba   => address(16 downto 15), Clk => sdclk(0), Cke => sdcke(0),
        Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(1 downto 0));
  end generate;

  sd1 : if (CFG_MCTRL_SDEN = 1) and (CFG_MCTRL_SEPBUS = 1) generate
    u0 : mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
      port map(
        Dq   => sd(31 downto 16), Addr => sa(12 downto 0),
        Ba   => sa(14 downto 13), Clk => sdclk(0), Cke => sdcke(0),
        Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(3 downto 2));
    u1 : mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
      port map(
        Dq   => sd(15 downto 0), Addr => sa(12 downto 0),
        Ba   => sa(14 downto 13), Clk => sdclk(0), Cke => sdcke(0),
        Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(1 downto 0));
    u2 : mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
      port map(
        Dq   => sd(31 downto 16), Addr => sa(12 downto 0),
        Ba   => sa(14 downto 13), Clk => sdclk(0), Cke => sdcke(0),
        Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(3 downto 2));
    u3 : mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
      port map(
        Dq   => sd(15 downto 0), Addr => sa(12 downto 0),
        Ba   => sa(14 downto 13), Clk => sdclk(0), Cke => sdcke(0),
        Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(1 downto 0));
    sd64 : if (CFG_MCTRL_SD64 = 1) generate
      u4 : mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
        port map(
          Dq   => sd(63 downto 48), Addr => sa(12 downto 0),
          Ba   => sa(14 downto 13), Clk => sdclk(0), Cke => sdcke(0),
          Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
          Dqm  => sddqm(7 downto 6));
      u5 : mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
        port map(
          Dq   => sd(47 downto 32), Addr => sa(12 downto 0),
          Ba   => sa(14 downto 13), Clk => sdclk(0), Cke => sdcke(0),
          Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
          Dqm  => sddqm(5 downto 4));
      u6 : mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
        port map(
          Dq   => sd(63 downto 48), Addr => sa(12 downto 0),
          Ba   => sa(14 downto 13), Clk => sdclk(0), Cke => sdcke(0),
          Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
          Dqm  => sddqm(7 downto 6));
      u7 : mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
        port map(
          Dq   => sd(47 downto 32), Addr => sa(12 downto 0),
          Ba   => sa(14 downto 13), Clk => sdclk(0), Cke => sdcke(0),
          Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
          Dqm  => sddqm(5 downto 4));
    end generate;
  end generate;


  extbprom : if CFG_AHBROMEN = 0 generate
    prom0 : for i in 0 to (romwidth/8)-1 generate
      sr0 : sram generic map (index => i, abits => romdepth, fname => promfile)
        port map (address(romdepth+1 downto 2), data(31-i*8 downto 24-i*8), romsn(0),
                  rwen(i), oen);
    end generate;
  end generate extbprom;


  sram0 : for i in 0 to (sramwidth/8)-1 generate
    sr0 : sram generic map (index => i, abits => sramdepth, fname => sramfile)
      port map (address(sramdepth+1 downto 2), data(31-i*8 downto 24-i*8), ramsn(0),
                rwen(0), ramoen(0));
  end generate;

  error <= 'H';                         -- ERROR pull-up

  iuerr : process
  begin
    wait for 2500 ns;
    if to_x01(error) = '1' then wait on error; end if;
    assert (to_x01(error) = '1')
      report "*** IU in error mode, simulation halted ***"
      severity failure;
  end process;

  data <= buskeep(data) after 5 ns;
  sd   <= buskeep(sd)   after 5 ns;

  can01 : if CFG_CAN /= 0 generate
    -- CAN_TXD_delayed <= CAN_TXD after 160 ns;
    CAN_TXD_delayed <= CAN_TXD;
    CAN_RXD         <= '1' and CAN_TXD_delayed;
  end generate;
  can00 : if CFG_CAN = 0 generate
    CAN_RXD <= '1';
  end generate;

  test0 : grtestmod
    port map (rst, clk, error, address(21 downto 2), data,
               iosn, oen, writen, brdyn);


  dcomstart : if CFG_AHBROMEN = 0 generate
    dsucom : process
      procedure dsucfg(signal dsurx : in std_logic; signal dsutx : out std_logic) is
        variable w32 : std_logic_vector(31 downto 0);
        variable c8  : std_logic_vector(7 downto 0);
        constant txp : time := 160 * 1 ns;
      begin
        dsutx  <= '1';
        dsurst <= '1';
        wait;
        wait for 5000 ns;
        txc(dsutx, 16#55#, txp);        -- sync uart

        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#00#, 16#ef#, txp);

        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#ff#, 16#ff#, txp);

        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#90#, 16#40#, 16#00#, 16#48#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#00#, 16#12#, txp);

        txc(dsutx, 16#c0#, txp);
        txa(dsutx, 16#90#, 16#40#, 16#00#, 16#60#, txp);
        txa(dsutx, 16#00#, 16#00#, 16#12#, 16#10#, txp);

        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
        rxi(dsurx, w32, txp, lresp);

        txc(dsutx, 16#a0#, txp);
        txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
        rxi(dsurx, w32, txp, lresp);

      end;

    begin
      dsucfg(dsutx, dsurx);
      wait;
    end process;
  end generate dcomstart;


  altstimuli : if CFG_AHBROMEN = 1 generate
    stimuli : process
    begin
      dsurx <= '1';
      -- rxd1 <= 'H'; --already defined above
      txd1  <= 'H';


      wait;
    end process STIMULI;
  end generate altstimuli;

  -----------------------------------------------------------------------------
  -- ARC testbench modules
  -----------------------------------------------------------------------------

  phy0 : if CFG_GRETH > 0 generate
    p0 : entity gleichmann.phy_ext
      generic map (
        infile_name  => "indata",
        outfile_name => "outdata",
        logfile_name => "logfile_phy",
        win_size     => 3)
      port map (
        resetn    => rst,
        led_cfg   => led_cfg,
        log_en    => VCC,
        cycle_num => clock_cycle_counter,
        mdio      => emdio,
        tx_clk    => etx_clk,
        rx_clk    => erx_clk,
        rxd       => erxd,
        rx_dv     => erx_dv,
        rx_er     => erx_er,
        rx_col    => erx_col,
        rx_crs    => erx_crs,
        txd       => etxd,
        tx_en     => etx_en,
        tx_er     => etx_er,
        mdc       => emdc);
  end generate;

  uart0 : if CFG_UART1_ENABLE > 0 generate
    rts_internal <= '0',
                    '1' after 1000 ns,
                    '0' after 1150 ns,
                    'Z' after 1500 ns;

    uart_ext_1 : entity gleichmann.uart_ext
      generic map (
        logfile_name => "logfile_uart",
        t_delay      => 5 ns)
      port map (
        resetn    => rst,
        log_en    => VCC,
        cycle_num => clock_cycle_counter,
        cts       => cts_internal,
        rxd       => rxd1,
        txd       => txd1,
        rts       => rts_internal);
  end generate uart0;
end architecture behav;


