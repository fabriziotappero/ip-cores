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
--  modified by Thomas Ameseder, Gleichmann Electronics 2004, 2005 to
--  support the use of an external AHB slave and different HPE board versions
------------------------------------------------------------------------------
--  further adapted from Hpe_compact to Hpe_mini (Feb. 2005)
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
library gaisler;
use gaisler.libdcom.all;
use gaisler.sim.all;
library techmap;
use techmap.gencomp.all;
library micron;
use micron.components.all;
library gleichmann;
use gleichmann.hpi.all;

use work.config.all;                    -- configuration
use work.debug.all;
use std.textio.all;
library grlib;
use grlib.stdlib.all;
use grlib.stdio.all;
use grlib.devices.all;


entity testbench is
  generic (
    fabtech : integer := CFG_FABTECH;
    memtech : integer := CFG_MEMTECH;
    padtech : integer := CFG_PADTECH;
    clktech : integer := CFG_CLKTECH;
    disas   : integer := CFG_DISAS;     -- Enable disassembly to console
    dbguart : integer := CFG_DUART;     -- Print UART on console
    pclow   : integer := CFG_PCLOW;

    clkperiod : integer := 40;          -- system clock period
    romwidth  : integer := 32;          -- rom data width (8/32)
    romdepth  : integer := 16;          -- rom address depth
    sramwidth : integer := 32;          -- ram data width (8/16/32)
    sramdepth : integer := 18;          -- ram address depth
    srambanks : integer := 2            -- number of ram banks
    );
end;

architecture behav of testbench is

  constant promfile  : string := "prom.srec";   -- rom contents
  constant sramfile  : string := "sram.srec";   -- ram contents
  constant sdramfile : string := "sdram.srec";  -- sdram contents


  signal   clk : std_logic := '0';
  signal   Rst : std_logic := '0';      -- Reset
  constant ct  : integer   := clkperiod/2;

  signal address : std_logic_vector(27 downto 0);
  signal data    : std_logic_vector(31 downto 0);

  signal ramsn  : std_logic_vector(4 downto 0);
  signal ramoen : std_logic_vector(4 downto 0);
  signal rwen   : std_logic_vector(3 downto 0);
  signal rwenx  : std_logic_vector(3 downto 0);
  signal romsn  : std_logic_vector(1 downto 0);
  signal iosn   : std_ulogic;
  signal oen    : std_ulogic;
  signal read   : std_ulogic;
  signal writen : std_ulogic;
  signal rben   : std_logic_vector(3 downto 0);
  signal tmp    : std_logic_vector(3 downto 0);

  -- ddr memory  
  signal ddr_clk    : std_logic;
  signal ddr_clkb   : std_logic;
  signal ddr_clk_fb : std_logic;
  signal ddr_cke    : std_logic;
  signal ddr_csb    : std_logic;
  signal ddr_web    : std_ulogic;                      -- ddr write enable
  signal ddr_rasb   : std_ulogic;                      -- ddr ras
  signal ddr_casb   : std_ulogic;                      -- ddr cas
  signal ddr_dm     : std_logic_vector (3 downto 0);   -- ddr dm
  signal ddr_dqs    : std_logic_vector (3 downto 0);   -- ddr dqs
  signal ddr_ad     : std_logic_vector (12 downto 0);  -- ddr address
  signal ddr_ba     : std_logic_vector (1 downto 0);   -- ddr bank address
  signal ddr_dq     : std_logic_vector (31 downto 0);  -- ddr data

  signal ddr_clk_del  : std_logic;      -- delayed DDR memory clocks
  signal ddr_clkb_del : std_logic;

  signal brdyn                               : std_ulogic;
  signal bexcn                               : std_ulogic;
  signal wdog                                : std_ulogic;
  signal dsuen, dsutx, dsurx, dsubre, dsuact : std_ulogic;
  signal dsurst                              : std_ulogic;
  signal test                                : std_ulogic;

  signal error : std_logic;

  signal pio  : std_logic_vector(15 downto 0);
  signal GND  : std_ulogic := '0';
  signal VCC  : std_ulogic := '1';
  signal NC   : std_ulogic := 'Z';
  signal clk2 : std_ulogic := '1';

  signal sdcke  : std_logic_vector (1 downto 0);  -- clk en
  signal sdcsn  : std_logic_vector (1 downto 0);  -- chip sel
  signal sdwen  : std_ulogic;                     -- write en
  signal sdrasn : std_ulogic;                     -- row addr stb
  signal sdcasn : std_ulogic;                     -- col addr stb
  signal sddqm  : std_logic_vector (3 downto 0);  -- data i/o mask
  signal sd_clk : std_logic_vector(1 downto 0);

  signal sdclk   : std_ulogic;
--  alias sdclk   : std_logic is sd_clk(0);
  signal plllock : std_ulogic;

-- pulled up high, therefore std_logic
  signal txd1, rxd1 : std_logic;

  signal etx_clk, erx_clk, erx_dv, erx_er, erx_col, erx_crs, etx_en, etx_er : std_logic                    := '0';
  signal erxd, etxd                                                         : std_logic_vector(3 downto 0) := (others => '0');
  signal erxdt, etxdt                                                       : std_logic_vector(7 downto 0) := (others => '0');
  signal emdc, emdio                                                        : std_logic;
  signal gtx_clk                                                            : std_ulogic                   := '0';

  signal emddis  : std_logic;
  signal epwrdwn : std_logic;
  signal ereset  : std_logic;
  signal esleep  : std_logic;
  signal epause  : std_logic;
  signal tp_out  : std_logic_vector(7 downto 0);
  signal led_cfg : std_logic_vector(2 downto 0);

  constant lresp : boolean := false;

  signal sa : std_logic_vector(14 downto 0);
  signal sd : std_logic_vector(63 downto 0);


-- Added for Hpe

  signal resoutn : std_logic;
  signal disrams : std_logic;
  signal sdclk0  : std_ulogic;
  signal sdclk1  : std_ulogic;
  signal sdba0   : std_logic;           -- bank address zero
  signal sdba1   : std_logic;           -- bank address one
  signal dsubren : std_ulogic;
  signal dsuactn : std_ulogic;
  signal bufdir  : std_logic;
  signal bufoen  : std_logic;
  signal s_sddqm : std_logic_vector (3 downto 0);

  signal HRESETn   : std_ulogic;
  signal HSEL      : std_ulogic;
  signal HREADY_ba : std_ulogic;        -- hready input signal
  signal HADDR     : std_logic_vector(31 downto 0);
  signal HWRITE    : std_ulogic;
  signal HTRANS    : std_logic_vector(1 downto 0);
  signal HSIZE     : std_logic_vector(2 downto 0);
  signal HBURST    : std_logic_vector(2 downto 0);
  signal HWDATA    : std_logic_vector(31 downto 0);
  signal HMASTER   : std_logic_vector(3 downto 0);
  signal HMASTLOCK : std_ulogic;
  signal HREADY    : std_ulogic;
  signal HRESP     : std_logic_vector(1 downto 0);
  signal HRDATA    : std_logic_vector(31 downto 0);
  signal HSPLIT    : std_logic_vector(15 downto 0);

  signal clk_ctrl        : std_logic_vector(1 downto 0);  -- cpld      
  signal CAN_RXD         : std_logic;
  signal CAN_TXD         : std_logic;
  signal CAN_STB         : std_logic;
  signal CAN_TXD_delayed : std_logic := '1';
  signal gpio            : std_logic_vector(7 downto 0);

  signal dac : std_ulogic;              -- ouput of sigma delta DAC

  subtype sd_address_range is natural range 14 downto 2;
  subtype sd_ba_range is natural range 16 downto 15;

  signal vga_vsync : std_ulogic;
  signal vga_hsync : std_ulogic;
  signal vga_rd    : std_logic_vector(1 downto 0);
  signal vga_gr    : std_logic_vector(1 downto 0);
  signal vga_bl    : std_logic_vector(1 downto 0);

  signal ata_data  : std_logic_vector(15 downto 0);
  signal ata_da    : std_logic_vector(2 downto 0);
  signal ata_cs0   : std_logic;
  signal ata_cs1   : std_logic;
  signal ata_dior  : std_logic;
  signal ata_diow  : std_logic;
  signal ata_iordy : std_logic;
  signal ata_intrq : std_logic;


  ---------------------------------------------------------------------------------------
  -- HPI SIGNALS
  ---------------------------------------------------------------------------------------
  signal hpiaddr           : std_logic_vector(1 downto 0);
  signal hpidata, hpirdata : std_logic_vector(15 downto 0);
  signal hpicsn            : std_ulogic;
  signal hpiwrn            : std_ulogic;
  signal hpirdn            : std_ulogic;
  signal hpiint            : std_ulogic;
  signal dbg_equal         : std_ulogic;
  signal drive_bus         : std_ulogic;
  ---------------------------------------------------------------------------------------
begin
  
  dsubren <= not dsubre;
  disrams <= '0';

-- clock and reset

  clk     <= not clk after ct * 1 ns;
  rst     <= '1'     after 10 ns;
  dsuen   <= '0'; dsubre <= '0'; rxd1 <= 'H';
  led_cfg <= "000";                     --put the phy in base10h mode

  d3 : entity work.leon3mini
    port map (
      resetn  => rst,
      resoutn => resoutn,
      clk     => clk,
      errorn  => error,
      address => address,
      data    => data,

      ddr_clk0   => ddr_clk,
      ddr_clk0b  => ddr_clkb,
      ddr_clk_fb => ddr_clk_fb,
      ddr_cke0   => ddr_cke,
      ddr_cs0b   => ddr_csb,
      ddr_web    => ddr_web,
      ddr_rasb   => ddr_rasb,
      ddr_casb   => ddr_casb,
      ddr_dm     => ddr_dm,
      ddr_dqs    => ddr_dqs,
      ddr_ad     => ddr_ad,
      ddr_ba     => ddr_ba,
      ddr_dq     => ddr_dq,
      ddr_clk1   => open,
      ddr_clk1b  => open,
      ddr_cke1   => open,
      ddr_cs1b   => open,
      sertx      => dsutx,
      serrx      => dsurx,

      dsuen   => dsuen,
      dsubre  => dsubre,
      dsuactn => dsuactn,

      ramsn  => ramsn(0),
      oen    => oen,
      rben   => rben,
      writen => writen,
      read   => read,
      iosn   => iosn,
      romsn  => romsn(0),

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

      ata_data  => ata_data,
      ata_da    => ata_da,
      ata_cs0   => ata_cs0,
      ata_cs1   => ata_cs1,
      ata_dior  => ata_dior,
      ata_diow  => ata_diow,
      ata_iordy => ata_iordy,
      ata_intrq => ata_intrq,

      dac       => dac,
      vga_vsync => vga_vsync,
      vga_hsync => vga_hsync,
      vga_rd    => vga_rd,
      vga_gr    => vga_gr,
      vga_bl    => vga_bl
      );

  hpidata <= hpirdata when hpirdn = '0' else (others => 'Z');

  hpiint <= '0';

  hpi_ram_1 : hpi_ram
    generic map (
      abits => 10,
      dbits => 16)
    port map (
      clk     => clk,
      address => hpiaddr,
      datain  => hpidata,
      dataout => hpirdata,
      writen  => hpiwrn,
      readn   => hpirdn,
      csn     => hpicsn
      );

-- optional sdram

  sd0 : if (CFG_MCTRL_SDEN = 1) generate
    u0 : mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
      port map(
        Dq   => data(31 downto 16), Addr => address(sd_address_range),
        Ba   => address(sd_ba_range), Clk => sdclk, Cke => sdcke(0),
        Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(3 downto 2));
    u1 : mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
      port map(
        Dq   => data(15 downto 0), Addr => address(sd_address_range),
        Ba   => address(sd_ba_range), Clk => sdclk, Cke => sdcke(0),
        Cs_n => sdcsn(0), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(1 downto 0));
    u2 : mt48lc16m16a2 generic map (index => 0, fname => sdramfile)
      port map(
        Dq   => data(31 downto 16), Addr => address(sd_address_range),
        Ba   => address(sd_ba_range), Clk => sdclk, Cke => sdcke(0),
        Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(3 downto 2));
    u3 : mt48lc16m16a2 generic map (index => 16, fname => sdramfile)
      port map(
        Dq   => data(15 downto 0), Addr => address(sd_address_range),
        Ba   => address(sd_ba_range), Clk => sdclk, Cke => sdcke(0),
        Cs_n => sdcsn(1), Ras_n => sdrasn, Cas_n => sdcasn, We_n => sdwen,
        Dqm  => sddqm(1 downto 0));
  end generate;

  ddr_clk_del  <= transport ddr_clk  after 5 ns;
  ddr_clkb_del <= transport ddr_clkb after 5 ns;

  u1 : mt46v16m16
    port map(
      Dq   => ddr_dq(15 downto 0), Dqs => ddr_dqs(1 downto 0), Addr => ddr_ad,
      Ba   => ddr_ba, Clk => ddr_clk_del, Clk_n => ddr_clkb_del, Cke => ddr_cke,
      Cs_n => ddr_csb, Ras_n => ddr_rasb, Cas_n => ddr_casb, We_n => ddr_web,
      Dm   => ddr_dm(1 downto 0));

  u2 : mt46v16m16
    port map(
      Dq   => ddr_dq(31 downto 16), Dqs => ddr_dqs(3 downto 2), Addr => ddr_ad,
      Ba   => ddr_ba, Clk => ddr_clk_del, Clk_n => ddr_clkb_del, Cke => ddr_cke,
      Cs_n => ddr_csb, Ras_n => ddr_rasb, Cas_n => ddr_casb, We_n => ddr_web,
      Dm   => ddr_dm(3 downto 2));

  tmp <= not rben;
  extbprom : if CFG_BOOTOPT = 0 generate
    prom0 : for i in 0 to (romwidth/8)-1 generate
      sr0 : sram generic map (index => i, abits => romdepth, fname => promfile)
        port map (address(romdepth+1 downto 2), data(31-i*8 downto 24-i*8), romsn(0),
                  tmp(i), oen);         -- **** tame: changed rwen to rben
    end generate;
  end generate extbprom;


  sram0 : for i in 0 to (sramwidth/8)-1 generate
    sr0 : sram generic map (index => i, abits => sramdepth, fname => sramfile)
      port map (address(sramdepth+1 downto 2), data(31-i*8 downto 24-i*8), ramsn(0),
                writen, oen);           -- **** tame: changed rwen to rben
    --  rben(0), ramoen(0));    -- **** tame: changed rwen to rben
  end generate;

  phy0 : if CFG_GRETH > 0 generate
    emdio <= 'H';
    erxd  <= erxdt(3 downto 0);
    etxdt <= "0000" & etxd;

    p0 : phy
      generic map(base1000_t_fd => 0, base1000_t_hd => 0)
      port map(rst, emdio, etx_clk, erx_clk, erxdt, erx_dv,
               erx_er, erx_col, erx_crs, etxdt, etx_en, etx_er, emdc, gtx_clk);
  end generate;
  error <= 'H';                         -- ERROR pull-up

  iuerr : process
  begin
    wait for 5 us;
    assert (to_X01(error) /= '0')
      report "*** IU in error mode, simulation halted ***"
      severity failure;
  end process;

  data <= buskeep(data), (others => 'H') after 250 ns;
  sd   <= buskeep(sd), (others   => 'H') after 250 ns;

  test0 : grtestmod
    port map (rst, clk, error, address(21 downto 2), data,
              iosn, oen, writen, brdyn);

  dcomstart : if CFG_BOOTOPT = 0 generate

    dsucom : process
      procedure dsucfg(signal dsurx : in std_ulogic; signal dsutx : out std_ulogic) is
        variable w32 : std_logic_vector(31 downto 0);
        variable c8  : std_logic_vector(7 downto 0);
        constant txp : time := 160 * 1 ns;
      begin
        dsutx  <= '1';
        dsurst <= '1';
--        wait;
        wait for 5000 ns;
        txc(dsutx, 16#55#, txp);        -- sync uart

--        txc(dsutx, 16#c0#, txp);
--        txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
--        txa(dsutx, 16#00#, 16#00#, 16#00#, 16#ef#, txp);
--
--        txc(dsutx, 16#c0#, txp);
--        txa(dsutx, 16#90#, 16#00#, 16#00#, 16#20#, txp);
--        txa(dsutx, 16#00#, 16#00#, 16#ff#, 16#ff#, txp);
--
--        txc(dsutx, 16#c0#, txp);
--        txa(dsutx, 16#90#, 16#40#, 16#00#, 16#48#, txp);
--        txa(dsutx, 16#00#, 16#00#, 16#00#, 16#12#, txp);
--
--        txc(dsutx, 16#c0#, txp);
--        txa(dsutx, 16#90#, 16#40#, 16#00#, 16#60#, txp);
--        txa(dsutx, 16#00#, 16#00#, 16#12#, 16#10#, txp);
--
--        txc(dsutx, 16#80#, txp);
--        txa(dsutx, 16#90#, 16#00#, 16#00#, 16#00#, txp);
--        rxi(dsurx, w32, txp, lresp);
--**********
--        print("Start write");
        txc(dsutx, 16#c2#, txp);
        txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
        txa(dsutx, 16#aa#, 16#aa#, 16#aa#, 16#a0#, txp);
        txa(dsutx, 16#aa#, 16#aa#, 16#aa#, 16#a4#, txp);
        txa(dsutx, 16#aa#, 16#aa#, 16#aa#, 16#a8#, txp);
--        txa(dsutx, 16#aa#, 16#aa#, 16#aa#, 16#ac#, txp);
--        txa(dsutx, 16#aa#, 16#aa#, 16#aa#, 16#10#, txp);
--        txa(dsutx, 16#aa#, 16#aa#, 16#aa#, 16#14#, txp);
--        txa(dsutx, 16#aa#, 16#aa#, 16#aa#, 16#18#, txp);
--        txa(dsutx, 16#aa#, 16#aa#, 16#aa#, 16#1c#, txp);

--        print("Start read");
        txc(dsutx, 16#80#, txp);
        txa(dsutx, 16#40#, 16#00#, 16#00#, 16#04#, txp);
        rxi(dsurx, w32, txp, lresp);

--        print("Res: " & tost(w32));
--**********        

        txc(dsutx, 16#a0#, txp);
        txa(dsutx, 16#40#, 16#00#, 16#00#, 16#00#, txp);
        rxi(dsurx, w32, txp, lresp);

      end;

    begin

      dsucfg(dsutx, dsurx);

      wait;
    end process;

  end generate dcomstart;


  altstimuli : if CFG_BOOTOPT = 1 generate
    stimuli : process
    begin
      dsurx <= '1';
      -- rxd1 <= 'H'; --already defined above
      txd1  <= 'H';


      wait;
    end process STIMULI;
  end generate altstimuli;

end;


