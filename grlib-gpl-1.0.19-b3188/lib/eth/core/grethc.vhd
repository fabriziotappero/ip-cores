------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
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
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	greth
-- File:	greth.vhd
-- Author:	Marko Isomaki 
-- Description:	Ethernet Media Access Controller with Ethernet Debug
--              Communication Link
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library eth;
use eth.grethpkg.all;

entity grethc is
  generic(
    ifg_gap        : integer := 24; 
    attempt_limit  : integer := 16;
    backoff_limit  : integer := 10;
    mdcscaler      : integer range 0 to 255 := 25; 
    enable_mdio    : integer range 0 to 1 := 0;
    fifosize       : integer range 4 to 512 := 8;
    nsync          : integer range 1 to 2 := 2;
    edcl           : integer range 0 to 2 := 0;
    edclbufsz      : integer range 1 to 64 := 1;
    macaddrh       : integer := 16#00005E#;
    macaddrl       : integer := 16#000000#;
    ipaddrh        : integer := 16#c0a8#;
    ipaddrl        : integer := 16#0035#;
    phyrstadr      : integer range 0 to 32 := 0;
    rmii           : integer range 0 to 1  := 0;
    oepol	   : integer range 0 to 1  := 0; 
    scanen	   : integer range 0 to 1  := 0); 
  port(
    rst            : in  std_ulogic;
    clk            : in  std_ulogic;
    --ahb mst in
    hgrant         : in  std_ulogic;
    hready         : in  std_ulogic;   
    hresp          : in  std_logic_vector(1 downto 0);
    hrdata         : in  std_logic_vector(31 downto 0); 
    --ahb mst out
    hbusreq        : out  std_ulogic;        
    hlock          : out  std_ulogic;
    htrans         : out  std_logic_vector(1 downto 0);
    haddr          : out  std_logic_vector(31 downto 0);
    hwrite         : out  std_ulogic;
    hsize          : out  std_logic_vector(2 downto 0);
    hburst         : out  std_logic_vector(2 downto 0);
    hprot          : out  std_logic_vector(3 downto 0);
    hwdata         : out  std_logic_vector(31 downto 0);
    --apb slv in 
    psel	   : in   std_ulogic;
    penable	   : in   std_ulogic;
    paddr	   : in   std_logic_vector(31 downto 0);
    pwrite	   : in   std_ulogic;
    pwdata	   : in   std_logic_vector(31 downto 0);
    --apb slv out
    prdata	   : out  std_logic_vector(31 downto 0);
    --irq
    irq            : out  std_logic;
    --rx ahb fifo
    rxrenable      : out  std_ulogic;
    rxraddress     : out  std_logic_vector(10 downto 0);
    rxwrite        : out  std_ulogic;
    rxwdata        : out  std_logic_vector(31 downto 0);
    rxwaddress     : out  std_logic_vector(10 downto 0);
    rxrdata        : in   std_logic_vector(31 downto 0);    
    --tx ahb fifo  
    txrenable      : out  std_ulogic;
    txraddress     : out  std_logic_vector(10 downto 0);
    txwrite        : out  std_ulogic;
    txwdata        : out  std_logic_vector(31 downto 0);
    txwaddress     : out  std_logic_vector(10 downto 0);
    txrdata        : in   std_logic_vector(31 downto 0);    
    --edcl buf     
    erenable       : out  std_ulogic;
    eraddress      : out  std_logic_vector(15 downto 0);
    ewritem        : out  std_ulogic;
    ewritel        : out  std_ulogic;
    ewaddressm     : out  std_logic_vector(15 downto 0);
    ewaddressl     : out  std_logic_vector(15 downto 0);
    ewdata         : out  std_logic_vector(31 downto 0);
    erdata         : in   std_logic_vector(31 downto 0);
    --ethernet input signals
    rmii_clk       : in   std_ulogic;
    tx_clk         : in   std_ulogic;
    rx_clk         : in   std_ulogic;
    rxd            : in   std_logic_vector(3 downto 0);   
    rx_dv          : in   std_ulogic; 
    rx_er          : in   std_ulogic; 
    rx_col         : in   std_ulogic;
    rx_crs         : in   std_ulogic;
    mdio_i         : in   std_ulogic;
    phyrstaddr     : in   std_logic_vector(4 downto 0);
    --ethernet output signals
    reset          : out  std_ulogic;
    txd            : out  std_logic_vector(3 downto 0);   
    tx_en          : out  std_ulogic; 
    tx_er          : out  std_ulogic; 
    mdc            : out  std_ulogic;    
    mdio_o         : out  std_ulogic; 
    mdio_oe        : out  std_ulogic;
    --scantest
    testrst        : in   std_ulogic;
    testen         : in   std_ulogic;
    edcladdr       : in  std_logic_vector(3 downto 0) := "0000"
  );
end entity;
  
architecture rtl of grethc is
  procedure sel_op_mode(
    capbil : in std_logic_vector(4 downto 0);
    speed  : out std_ulogic;
    duplex : out std_ulogic) is
    variable vspeed  : std_ulogic;
    variable vduplex : std_ulogic;
  begin
    vspeed := '0'; vduplex := '0';
    vspeed := orv(capbil(4 downto 2));

    vduplex := (vspeed and capbil(3)) or ((not vspeed) and capbil(1));
    speed := vspeed;
    duplex := vduplex;
  end procedure;
  
  --host constants
  constant fabits          : integer := log2(fifosize);
  constant burstlength     : integer := setburstlength(fifosize);
  constant burstbits       : integer := log2(burstlength);
  constant ctrlopcode      : std_logic_vector(15 downto 0) := X"8808"; 
  constant broadcast       : std_logic_vector(47 downto 0) := X"FFFFFFFFFFFF";
  constant maxsizetx       : integer := 1514;
  constant index           : integer := log2(edclbufsz);
  constant receiveOK       : std_logic_vector(3 downto 0) := "0000";
  constant frameCheckError : std_logic_vector(3 downto 0) := "0100";
  constant alignmentError  : std_logic_vector(3 downto 0) := "0001";
  constant frameTooLong    : std_logic_vector(3 downto 0) := "0010";
  constant overrun         : std_logic_vector(3 downto 0) := "1000";
  constant minpload        : std_logic_vector(10 downto 0) :=
                             conv_std_logic_vector(60, 11);
 
  --mdio constants
  constant divisor : std_logic_vector(7 downto 0) :=
    conv_std_logic_vector(mdcscaler, 8);

  --receiver constants
  constant maxsizerx : std_logic_vector(15 downto 0) :=
    conv_std_logic_vector(1514, 16);

  --edcl constants
  type szvct is array (0 to 6) of integer;
  constant ebuf : szvct := (64, 128, 128, 256, 256, 256, 256);
  constant blbits : szvct := (6, 7, 7, 8, 8, 8, 8);
  constant winsz : szvct := (4, 4, 8, 8, 16, 32, 64);
  constant macaddrt : std_logic_vector(47 downto 0) :=
    conv_std_logic_vector(macaddrh, 24) & conv_std_logic_vector(macaddrl, 24);
  constant bpbits : integer := blbits(log2(edclbufsz));
  constant wsz : integer := winsz(log2(edclbufsz));
  constant bselbits : integer := log2(wsz);
  constant eabits: integer := log2(edclbufsz) + 8;
  constant ebufmax : std_logic_vector(bpbits-1 downto 0) := (others => '1');
  constant bufsize : std_logic_vector(2 downto 0) :=
                       conv_std_logic_vector(log2(edclbufsz), 3);
  constant ebufsize : integer := ebuf(log2(edclbufsz));
  constant txfifosize : integer := getfifosize(edcl, fifosize, ebufsize);
  constant txfabits : integer := log2(txfifosize);
  constant txfifosizev : std_logic_vector(txfabits downto 0) :=
    conv_std_logic_vector(txfifosize, txfabits+1);
 
  constant rxburstlen      : std_logic_vector(fabits downto 0) :=
    conv_std_logic_vector(burstlength, fabits+1);
  constant txburstlen      : std_logic_vector(txfabits downto 0) :=
    conv_std_logic_vector(burstlength, txfabits+1);
  
  type edclrstate_type is (idle, wrda, wrdsa, wrsa, wrtype, ip, ipdata,
                           oplength, arp, iplength, ipcrc, arpop, udp, spill);

  type duplexstate_type is (start, waitop, nextop, selmode, done);
      
  --host types
  type txd_state_type is (idle, read_desc, check_desc, req, fill_fifo,
                          check_result, write_result, readhdr, start, wrbus,
                          etdone, getlen, ahberror);
  type rxd_state_type is (idle, read_desc, check_desc, read_req, read_fifo,
                          discard, write_status, write_status2);

  --mdio types
  type mdio_state_type is (idle, preamble, startst, op, op2, phyadr, regadr,
                           ta, ta2, ta3, data, dataend);

  type ctrl_reg_type is record
    txen	: std_ulogic;
    rxen        : std_ulogic;
    tx_irqen    : std_ulogic;
    rx_irqen    : std_ulogic; 
    full_duplex : std_ulogic; 
    prom        : std_ulogic;
    reset       : std_ulogic;
    speed       : std_ulogic;
  end record;

  type status_reg_type is record
    tx_int      : std_ulogic;
    rx_int      : std_ulogic;
    rx_err      : std_ulogic;
    tx_err      : std_ulogic;
    txahberr    : std_ulogic;
    rxahberr    : std_ulogic;
    toosmall    : std_ulogic;
    invaddr     : std_ulogic;
  end record;

  type mdio_ctrl_reg_type is record
    phyadr   : std_logic_vector(4 downto 0);
    regadr   : std_logic_vector(4 downto 0);
    write    : std_ulogic;
    read     : std_ulogic;
    data     : std_logic_vector(15 downto 0);
    busy     : std_ulogic;
    linkfail : std_ulogic;
  end record;

  subtype mac_addr_reg_type is std_logic_vector(47 downto 0); 

  type fifo_access_in_type is record
    renable   : std_ulogic;    
    raddress  : std_logic_vector(fabits-1 downto 0);
    write     : std_ulogic;
    waddress  : std_logic_vector(fabits-1 downto 0);
    datain    : std_logic_vector(31 downto 0);
  end record;

  type fifo_access_out_type is record
    data      : std_logic_vector(31 downto 0);
  end record;

  type tx_fifo_access_in_type is record
    renable   : std_ulogic;    
    raddress  : std_logic_vector(txfabits-1 downto 0);
    write     : std_ulogic;
    waddress  : std_logic_vector(txfabits-1 downto 0);
    datain    : std_logic_vector(31 downto 0);
  end record;

  type tx_fifo_access_out_type is record
    data      : std_logic_vector(31 downto 0);
  end record;

  type edcl_ram_in_type is record
    renable   : std_ulogic;    
    raddress  : std_logic_vector(eabits-1 downto 0);
    writem    : std_ulogic;
    writel    : std_ulogic;
    waddressm : std_logic_vector(eabits-1 downto 0);
    waddressl : std_logic_vector(eabits-1 downto 0);
    datain    : std_logic_vector(31 downto 0);
  end record;

  type edcl_ram_out_type is record
    data      : std_logic_vector(31 downto 0);
  end record;

  type reg_type is record
    --user registers
    ctrl        : ctrl_reg_type;
    status      : status_reg_type;
    mdio_ctrl   : mdio_ctrl_reg_type;
    mac_addr    : mac_addr_reg_type;
    txdesc      : std_logic_vector(31 downto 10);
    rxdesc      : std_logic_vector(31 downto 10);
    edclip      : std_logic_vector(31 downto 0);
    
    --master tx interface
    txdsel          : std_logic_vector(9 downto 3);
    tmsto           : eth_tx_ahb_in_type;
    txdstate        : txd_state_type;
    txwrap          : std_ulogic;
    txden           : std_ulogic;
    txirq           : std_ulogic;
    txaddr          : std_logic_vector(31 downto 2);
    txlength        : std_logic_vector(10 downto 0);
    txburstcnt      : std_logic_vector(burstbits downto 0);
    tfwpnt          : std_logic_vector(txfabits-1 downto 0);
    tfrpnt          : std_logic_vector(txfabits-1 downto 0);
    tfcnt           : std_logic_vector(txfabits downto 0); 
    txcnt           : std_logic_vector(10 downto 0);
    txstart         : std_ulogic;
    txirqgen        : std_ulogic;
    txstatus        : std_logic_vector(1 downto 0);
    txvalid         : std_ulogic; 
    txdata          : std_logic_vector(31 downto 0);
    writeok         : std_ulogic;
    txread          : std_logic_vector(nsync-1 downto 0);
    txrestart       : std_logic_vector(nsync downto 0);
    txdone          : std_logic_vector(nsync downto 0);
    txstart_sync    : std_ulogic;
    txreadack       : std_ulogic;
    txdataav        : std_ulogic;
    txburstav       : std_ulogic;
          
    --master rx interface 
    rxdsel          : std_logic_vector(9 downto 3);
    rmsto           : eth_rx_ahb_in_type;
    rxdstate        : rxd_state_type;
    rxstatus        : std_logic_vector(4 downto 0);
    rxaddr          : std_logic_vector(31 downto 2);
    rxlength        : std_logic_vector(10 downto 0);
    rxbytecount     : std_logic_vector(10 downto 0);
    rxwrap          : std_ulogic;
    rxirq           : std_ulogic;
    rfwpnt          : std_logic_vector(fabits-1 downto 0);
    rfrpnt          : std_logic_vector(fabits-1 downto 0);
    rfcnt           : std_logic_vector(fabits downto 0);
    rxcnt           : std_logic_vector(10 downto 0);
    rxdoneold       : std_ulogic;
    rxdoneack       : std_ulogic; 
    rxdone          : std_logic_vector(nsync-1 downto 0);
    rxstart         : std_logic_vector(nsync downto 0);
    rxwrite         : std_logic_vector(nsync-1 downto 0);
    rxwriteack      : std_ulogic; 
    rxburstcnt      : std_logic_vector(burstbits downto 0);
    addrnok         : std_ulogic;
    ctrlpkt         : std_ulogic;
    check           : std_ulogic;
    checkdata       : std_logic_vector(31 downto 0);
    usesizefield    : std_ulogic;
    rxden           : std_ulogic;
    gotframe        : std_ulogic;
    bcast           : std_ulogic;
    rxburstav       : std_ulogic;
    
    --mdio
    mdccnt          : std_logic_vector(7 downto 0);
    mdioclk         : std_ulogic;
    mdioclkold      : std_ulogic;
    mdio_state      : mdio_state_type;
    mdioo           : std_ulogic;
    mdioi           : std_ulogic;
    mdioen          : std_ulogic;
    cnt             : std_logic_vector(4 downto 0);
    duplexstate     : duplexstate_type;
    ext             : std_ulogic;
    extcap          : std_ulogic;
    regaddr         : std_logic_vector(4 downto 0);
    phywr           : std_ulogic;
    rstphy          : std_ulogic;
    capbil          : std_logic_vector(4 downto 0);
    rstaneg         : std_ulogic;

    --edcl
    edclrstate      : edclrstate_type;
    edclactive      : std_ulogic;
    nak             : std_ulogic;
    ewr             : std_ulogic;
    write           : std_logic_vector(wsz-1 downto 0);
    seq             : std_logic_vector(13 downto 0);
    abufs           : std_logic_vector(bselbits downto 0);
    tpnt            : std_logic_vector(bselbits-1 downto 0);
    rpnt            : std_logic_vector(bselbits-1 downto 0);
    tcnt            : std_logic_vector(bpbits-1 downto 0);
    rcntm           : std_logic_vector(bpbits-1 downto 0);
    rcntl           : std_logic_vector(bpbits-1 downto 0);
    ipcrc           : std_logic_vector(17 downto 0);
    applength       : std_logic_vector(15 downto 0);
    oplen           : std_logic_vector(9 downto 0);
    udpsrc          : std_logic_vector(15 downto 0);
    ecnt            : std_logic_vector(3 downto 0);
    tarp            : std_ulogic;
    tnak            : std_ulogic;
    tedcl           : std_ulogic;
    edclbcast       : std_ulogic;
  end record;

  --host signals
  signal arst             : std_ulogic;
  signal irst             : std_ulogic;
  signal vcc              : std_ulogic;

  signal tmsto            : eth_tx_ahb_in_type;
  signal tmsti            : eth_tx_ahb_out_type;

  signal rmsto            : eth_rx_ahb_in_type;
  signal rmsti            : eth_rx_ahb_out_type;

  signal macaddr         : std_logic_vector(47 downto 0);

  signal ahbmi            : ahbc_mst_in_type;
  signal ahbmo            : ahbc_mst_out_type;

  signal txi              : host_tx_type;
  signal txo              : tx_host_type;

  signal rxi              : host_rx_type;
  signal rxo              : rx_host_type;

  signal r, rin           : reg_type;

  attribute sync_set_reset : string;
  attribute sync_set_reset of irst : signal is "true";

begin
 
  macaddr(47 downto 4) <= macaddrt(47 downto 4);
  macaddr(3 downto 0) <= macaddrt(3 downto 0) when edcl /= 2 else edcladdr;

  --reset generators for transmitter and receiver
  vcc <= '1';
  arst <= testrst when (scanen = 1) and (testen = '1') 
          else rst and not r.ctrl.reset;
  irst <= rst and not r.ctrl.reset;
     
  comb : process(rst, irst, r, rmsti, tmsti, txo, rxo, psel, paddr, penable,
                 erdata, pwrite, pwdata, rxrdata, txrdata, mdio_i, phyrstaddr,
                 testen, testrst, macaddr, edcladdr) is
    variable v             : reg_type;
    variable vpirq         : std_ulogic;
    variable vprdata       : std_logic_vector(31 downto 0);
    variable txvalid       : std_ulogic;
    variable vtxfi         : tx_fifo_access_in_type; 
    variable vrxfi         : fifo_access_in_type;
    variable lengthav      : std_ulogic;
    variable txdone        : std_ulogic;
    variable txread        : std_ulogic;
    variable txrestart     : std_ulogic;
    variable rxstart       : std_ulogic;
    variable rxdone        : std_ulogic;
    variable vrxwrite      : std_ulogic;
    variable ovrunstop     : std_ulogic;
    --mdio
    variable mdioindex     : integer range 0 to 31;
    variable mclk          : std_ulogic;
    --edcl
    variable veri          : edcl_ram_in_type;
    variable swap          : std_ulogic;
    variable setmz         : std_ulogic;
    variable ipcrctmp      : std_logic_vector(15 downto 0);
    variable ipcrctmp2     : std_logic_vector(17 downto 0);
    variable vrxenable     : std_ulogic;
    variable crctmp        : std_ulogic;
    variable vecnt         : integer;
  begin 
    v := r; vprdata := (others => '0'); vpirq := '0';
    v.check := '0'; lengthav := r.rxdoneold;-- or r.usesizefield;
    ovrunstop := '0';
    
    vtxfi.datain := tmsti.data; 
    vtxfi.raddress := r.tfrpnt; vtxfi.write := '0';
    vtxfi.waddress := r.tfwpnt; vtxfi.renable := '1';

    vrxfi.datain := rxo.dataout; 
    vrxfi.write := '0'; vrxfi.waddress := r.rfwpnt;
    vrxfi.renable := '1'; vrxenable := r.ctrl.rxen;

    --synchronization
    v.txdone(0)     := txo.done;
    v.txread(0)     := txo.read;
    v.txrestart(0)  := txo.restart;
    v.rxstart(0)    := rxo.start;
    v.rxdone(0)     := rxo.done;
    v.rxwrite(0)    := rxo.write;
        
    if nsync = 2 then
      v.txdone(1)     := r.txdone(0);
      v.txread(1)     := r.txread(0);
      v.txrestart(1)  := r.txrestart(0);
      v.rxstart(1)    := r.rxstart(0);
      v.rxdone(1)     := r.rxdone(0);
      v.rxwrite(1)    := r.rxwrite(0);
    end if;

    txdone     := r.txdone(nsync)     xor r.txdone(nsync-1);
    txread     := r.txreadack         xor r.txread(nsync-1);
    txrestart  := r.txrestart(nsync)  xor r.txrestart(nsync-1);
    rxstart    := r.rxstart(nsync)    xor r.rxstart(nsync-1);
    rxdone     := r.rxdoneack         xor r.rxdone(nsync-1);
    vrxwrite   := r.rxwriteack        xor r.rxwrite(nsync-1);
   
    if txdone = '1' then
      v.txstatus := txo.status;
    end if;
    
-------------------------------------------------------------------------------
-- HOST INTERFACE -------------------------------------------------------------
-------------------------------------------------------------------------------
   --SLAVE INTERFACE

   --write
   if (psel and penable and pwrite) = '1' then
     case paddr(5 downto 2) is
     when "0000" => --ctrl reg
       if rmii = 1 then
       v.ctrl.speed       := pwdata(7);  
       end if;
       v.ctrl.reset       := pwdata(6);
       v.ctrl.prom        := pwdata(5); 
       v.ctrl.full_duplex := pwdata(4);
       v.ctrl.rx_irqen    := pwdata(3);
       v.ctrl.tx_irqen    := pwdata(2);
       v.ctrl.rxen        := pwdata(1);
       v.ctrl.txen        := pwdata(0);
     when "0001" => --status/int source reg
       if pwdata(7) = '1' then v.status.invaddr  := '0'; end if;
       if pwdata(6) = '1' then v.status.toosmall := '0'; end if;
       if pwdata(5) = '1' then v.status.txahberr := '0'; end if;
       if pwdata(4) = '1' then v.status.rxahberr := '0';  end if;
       if pwdata(3) = '1' then v.status.tx_int := '0'; end if;
       if pwdata(2) = '1' then v.status.rx_int := '0'; end if;
       if pwdata(1) = '1' then v.status.tx_err := '0'; end if;
       if pwdata(0) = '1' then v.status.rx_err := '0'; end if;
     when "0010" => --mac addr msb
       v.mac_addr(47 downto 32) := pwdata(15 downto 0);
     when "0011" => --mac addr lsb
       v.mac_addr(31 downto 0)  := pwdata(31 downto 0);
     when "0100" => --mdio ctrl/status
       if enable_mdio = 1 then 
         v.mdio_ctrl.data   := pwdata(31 downto 16);
         v.mdio_ctrl.phyadr := pwdata(15 downto 11);
         v.mdio_ctrl.regadr := pwdata(10 downto 6);
         if r.mdio_ctrl.busy = '0' then
           v.mdio_ctrl.read   := pwdata(1);
           v.mdio_ctrl.write  := pwdata(0);
           v.mdio_ctrl.busy   := pwdata(1) or pwdata(0);
         end if;
       end if;
     when "0101" => --tx descriptor 
       v.txdesc := pwdata(31 downto 10);
       v.txdsel := pwdata(9 downto 3);
     when "0110" => --rx descriptor
       v.rxdesc := pwdata(31 downto 10);
       v.rxdsel := pwdata(9 downto 3);
     when "0111" => --edcl ip
       if (edcl /= 0) then
       v.edclip := pwdata;
       end if;
     when others => null; 
     end case; 
   end if;

   --read
   case paddr(5 downto 2) is
   when "0000" => --ctrl reg
     if (edcl /= 0) then
       vprdata(31) := '1';
       vprdata(30 downto 28) := bufsize;
     end if;
     if rmii = 1 then
     vprdata(7) := r.ctrl.speed;
     end if;
     vprdata(6) := r.ctrl.reset;
     vprdata(5) := r.ctrl.prom;
     vprdata(4) := r.ctrl.full_duplex;
     vprdata(3) := r.ctrl.rx_irqen;
     vprdata(2) := r.ctrl.tx_irqen;
     vprdata(1) := r.ctrl.rxen;
     vprdata(0) := r.ctrl.txen; 
   when "0001" => --status/int source reg
     vprdata(5) := r.status.invaddr;
     vprdata(4) := r.status.toosmall;
     vprdata(5) := r.status.txahberr;
     vprdata(4) := r.status.rxahberr;
     vprdata(3) := r.status.tx_int;
     vprdata(2) := r.status.rx_int;
     vprdata(1) := r.status.tx_err;
     vprdata(0) := r.status.rx_err; 
   when "0010" => --mac addr msb/mdio address
     vprdata(15 downto 0) := r.mac_addr(47 downto 32);
   when "0011" => --mac addr lsb
     vprdata := r.mac_addr(31 downto 0); 
   when "0100" => --mdio ctrl/status
     vprdata(31 downto 16) := r.mdio_ctrl.data;
     vprdata(15 downto 11) := r.mdio_ctrl.phyadr;
     vprdata(10 downto 6) :=  r.mdio_ctrl.regadr;  
     vprdata(3) := r.mdio_ctrl.busy;
     vprdata(2) := r.mdio_ctrl.linkfail;
     vprdata(1) := r.mdio_ctrl.read;
     vprdata(0) := r.mdio_ctrl.write; 
   when "0101" => --tx descriptor 
     vprdata(31 downto 10) := r.txdesc;
     vprdata(9 downto 3)   := r.txdsel;
   when "0110" => --rx descriptor
     vprdata(31 downto 10) := r.rxdesc;
     vprdata(9 downto 3)   := r.rxdsel;
   when "0111" => --edcl ip
     if (edcl /= 0) then
     vprdata := r.edclip;
     end if;
   when others => null; 
   end case;   
      
   --MASTER INTERFACE

   v.txburstav := '0';
   if (txfifosizev - r.tfcnt) >= txburstlen then
     v.txburstav := '1'; 
   end if; 

   --tx dma fsm
   case r.txdstate is
   when idle =>
     v.txcnt := (others => '0');
     if (edcl /= 0) then
       v.tedcl := '0';
     end if;
     if (edcl /= 0) and (conv_integer(r.abufs) /= 0)  then
       v.txdstate := getlen;
       v.tcnt := conv_std_logic_vector(10, bpbits);
     elsif r.ctrl.txen = '1' then
       v.txdstate := read_desc; v.tmsto.write := '0';  
       v.tmsto.addr := r.txdesc & r.txdsel & "000"; v.tmsto.req := '1';
     end if;
     if r.txirqgen = '1' then
       vpirq := '1'; v.txirqgen := '0';
     end if;
     if txrestart = '1' then
       v.txrestart(nsync) := r.txrestart(nsync-1);
       v.tfcnt := (others => '0'); v.tfrpnt := (others => '0');
       v.tfwpnt := (others => '0');
     end if;
   when read_desc =>
     v.tmsto.write := '0'; v.txstatus := (others => '0'); 
     v.tfwpnt := (others => '0'); v.tfrpnt := (others => '0');
     v.tfcnt := (others => '0');
     if tmsti.grant = '1' then
       v.tmsto.addr := r.tmsto.addr + 4;
     end if;
     if tmsti.ready = '1' then
       v.txcnt := r.txcnt + 1; v.tmsto.req := '0';
       case r.txcnt(1 downto 0) is
         when "00" =>
           v.txlength  := tmsti.data(10 downto 0);
           v.txden     := tmsti.data(11);
           v.txwrap    := tmsti.data(12);
           v.txirq     := tmsti.data(13);
           v.ctrl.txen := tmsti.data(11);
         when "01" =>
           v.txaddr    := tmsti.data(31 downto 2);
           v.txdstate  := check_desc;
         when others => null;
       end case; 
     end if;
   when check_desc =>
     v.txstart := '0'; 
     v.txburstcnt := (others => '0'); 
     if r.txden = '1' then
       if (conv_integer(r.txlength) > maxsizetx) or
                  (conv_integer(r.txlength) = 0) then
         v.txdstate := write_result; v.tmsto.req := '1';
         v.tmsto.write := '1'; v.tmsto.addr := r.txdesc & r.txdsel & "000";
         v.tmsto.data := (others => '0');
       else
         v.txdstate := req;
         v.tmsto.addr := r.txaddr & "00"; v.txcnt(10 downto 0) := r.txlength;
       end if;
     else
       v.txdstate := idle;
     end if;
   when req =>
     if txrestart = '1' then
       v.txdstate := idle; v.txstart := '0'; 
       if (edcl /= 0) and (r.tedcl = '1') then
         v.txdstate := idle; 
       end if;
     elsif txdone = '1' then
       v.txdstate := check_result;
       v.tfcnt := (others => '0'); v.tfrpnt := (others => '0');
       v.tfwpnt := (others => '0');
       if (edcl /= 0) and (r.tedcl = '1') then
         v.txdstate := etdone;
       end if;
     elsif conv_integer(r.txcnt) = 0 then
       v.txdstate := check_result;
       if (edcl /= 0) and (r.tedcl = '1') then
         v.txdstate := etdone; v.txstart_sync := not r.txstart_sync;
       end if;
     elsif (r.txburstav = '1') or (r.tedcl = '1') then
       v.tmsto.req := '1'; v.txdstate := fill_fifo;
     end if;
     v.txburstcnt := (others => '0');
   when fill_fifo =>
     v.txburstav := '0';
     if tmsti.grant = '1' then
       v.tmsto.addr := r.tmsto.addr + 4;
       if ((conv_integer(r.txcnt) <= 8) and (tmsti.ready = '1')) or
          ((conv_integer(r.txcnt) <= 4) and (tmsti.ready = '0')) then
         v.tmsto.req := '0'; 
       end if;
       v.txburstcnt := r.txburstcnt + 1;
       if (conv_integer(r.txburstcnt) = burstlength-1) then
         v.tmsto.req := '0';
       end if;
     end if;
     if (tmsti.ready = '1') or ((edcl /= 0) and (r.tedcl and tmsti.error) = '1') then
       v.tfwpnt := r.tfwpnt + 1; v.tfcnt := r.tfcnt + 1; vtxfi.write := '1';
       if r.tmsto.req = '0' then
         v.txdstate := req;
         if (r.txstart = '0') and not ((edcl /= 0) and (r.tedcl = '1')) then
           v.txstart := '1'; v.txstart_sync := not r.txstart_sync; 
         end if;
       end if;
       if conv_integer(r.txcnt) > 3 then
         v.txcnt := r.txcnt - 4;
       else
         v.txcnt := (others => '0');
       end if;
     end if;
   when check_result =>
     if txdone = '1' then
       v.txdstate := write_result; v.tmsto.req := '1'; v.txstart := '0';
       v.tmsto.write := '1'; v.tmsto.addr := r.txdesc & r.txdsel & "000";
       v.tmsto.data(31 downto 16) := (others => '0');
       v.tmsto.data(15 downto 14) := v.txstatus;
       v.tmsto.data(13 downto 0)  := (others => '0');
       v.txdone(nsync) := r.txdone(nsync-1);
     elsif txrestart = '1' then
       v.txdstate := idle; v.txstart := '0'; 
     end if;
   when write_result =>
     if tmsti.grant = '1' then
       v.tmsto.req := '0'; v.tmsto.addr := r.tmsto.addr + 4;
     end if;
     if tmsti.ready = '1' then
       v.txdstate := idle; 
       v.txirqgen := r.ctrl.tx_irqen and r.txirq; 
       if r.txwrap = '0' then v.txdsel := r.txdsel + 1;
       else v.txdsel := (others => '0'); end if;
       if conv_integer(r.txstatus) = 0 then v.status.tx_int := '1';
       else v.status.tx_err := '1'; end if;
     end if;
   when ahberror =>
     v.tfcnt := (others => '0'); v.tfwpnt := (others => '0');
     v.tfrpnt := (others => '0');
     v.status.txahberr := '1'; v.ctrl.txen := '0';
     if not ((edcl /= 0) and (r.tedcl = '1')) then
       if r.txstart = '1' then
         if txdone = '1' then
           v.txdstate := idle; v.txdone(nsync) := r.txdone(nsync-1);
         end if;
       else
         v.txdstate := idle;
       end if;
     else
       v.txdstate := idle; 
       v.abufs := r.abufs - 1; v.tpnt := r.tpnt + 1;
     end if;
   when others =>
     null;
   end case;

   --tx fifo read
   v.txdataav := '0';
   if conv_integer(r.tfcnt) /= 0 then
     v.txdataav := '1';
   end if;
   if txread = '1' then
     v.txreadack := not r.txreadack;
     if r.txdataav = '1' then
       if conv_integer(r.tfcnt) < 2 then
         v.txdataav := '0';
       end if;
       v.txvalid := '1';
       v.tfcnt := v.tfcnt - 1; v.tfrpnt := r.tfrpnt + 1;
     else
       v.txvalid := '0';
     end if;
     v.txdata := txrdata;
   end if;

   v.rxburstav := '0';
   if r.rfcnt >= rxburstlen then
     v.rxburstav := '1'; 
   end if;

   --rx dma fsm
   case r.rxdstate is
   when idle =>
     v.rmsto.req := '0'; v.rmsto.write := '0'; v.addrnok := '0'; 
     v.rxcnt := (others => '0'); v.rxdoneold := '0';
     v.ctrlpkt := '0'; v.bcast := '0'; v.edclactive := '0';
     if r.ctrl.rxen = '1' then
       v.rxdstate := read_desc; v.rmsto.req := '1';
       v.rmsto.addr := r.rxdesc & r.rxdsel & "000"; 
     elsif rxstart = '1' then
       v.rxstart(nsync) := r.rxstart(nsync-1);
       v.rxdstate := discard;
     end if;
   when read_desc =>
     v.rxstatus := (others => '0');
     if rmsti.grant = '1' then
       v.rmsto.addr := r.rmsto.addr + 4;
     end if;
     if rmsti.ready = '1' then
       v.rxcnt := r.rxcnt + 1; v.rmsto.req := '0';
       case r.rxcnt(1 downto 0) is
         when "00" =>
           v.ctrl.rxen := rmsti.data(11);
           v.rxden     := rmsti.data(11);
           v.rxwrap    := rmsti.data(12);
           v.rxirq     := rmsti.data(13);
         when "01" =>
           v.rxaddr    := rmsti.data(31 downto 2);
           v.rxdstate  := check_desc;
         when others =>
           null;
       end case; 
     end if;
     if rmsti.error = '1' then
       v.rmsto.req := '0'; v.rxdstate := idle;
       v.status.rxahberr := '1'; v.ctrl.rxen := '0';
     end if;
   when check_desc =>
     v.rxcnt := (others => '0'); v.usesizefield := '0'; v.rmsto.write := '1'; 
     if r.rxden = '1' then
       if rxstart = '1' then
         v.rxdstate := read_req; v.rxstart(nsync) := r.rxstart(nsync-1);
       end if; 
     else
       v.rxdstate := idle;
     end if;
     v.rmsto.addr := r.rxaddr & "00";
   when read_req =>
     if r.edclactive = '1' then
       v.rxdstate := discard;
     elsif (r.rxdoneold and r.rxstatus(3)) = '1' then
       v.rxdstate := write_status; 
       v.rfcnt := (others => '0'); v.rfwpnt := (others => '0');
       v.rfrpnt := (others => '0'); v.writeok := '1';
       v.rxbytecount := (others => '0'); v.rxlength := (others => '0');
     elsif (r.addrnok or r.ctrlpkt) = '1' then
       v.rxdstate := discard; v.status.invaddr := '1';
     elsif ((r.rxdoneold = '1') and r.rxcnt >= r.rxlength) then
       if r.gotframe = '1' then
         v.rxdstate := write_status;
       else
         v.rxdstate := discard; v.status.toosmall := '1';
       end if;
     elsif (r.rxburstav or r.rxdoneold) = '1' then
       v.rmsto.req := '1'; v.rxdstate := read_fifo;
       v.rfrpnt := r.rfrpnt + 1; v.rfcnt := r.rfcnt - 1;
     end if;
     v.rxburstcnt := (others => '0'); v.rmsto.data := rxrdata; 
   when read_fifo =>
     v.rxburstav := '0';
     if rmsti.grant = '1' then
       v.rmsto.addr := r.rmsto.addr + 4;
       if (lengthav = '1') then
         if ((conv_integer(r.rxcnt) >=
              (conv_integer(r.rxlength) - 8)) and (rmsti.ready = '1')) or
         ((conv_integer(r.rxcnt) >=
           (conv_integer(r.rxlength) - 4)) and (rmsti.ready = '0')) then
           v.rmsto.req := '0'; 
         end if;
       end if;
       v.rxburstcnt := r.rxburstcnt + 1;
       if (conv_integer(r.rxburstcnt) = burstlength-1) then
         v.rmsto.req := '0';
       end if;
     end if;
     if rmsti.ready = '1' then
       v.rmsto.data := rxrdata; 
       v.rxcnt := r.rxcnt + 4;  
       if r.rmsto.req = '0' then
         v.rxdstate := read_req; 
       else
         v.rfcnt := r.rfcnt - 1; v.rfrpnt := r.rfrpnt + 1;
       end if;
       v.check := '1'; v.checkdata := r.rmsto.data; 
     end if;
     if rmsti.error = '1' then
       v.rmsto.req := '0'; v.rxdstate := discard;
       v.rxcnt := r.rxcnt + 4;
       v.status.rxahberr := '1'; v.ctrl.rxen := '0';
     end if;
   when write_status =>
     v.rmsto.req := '1'; v.rmsto.addr := r.rxdesc & r.rxdsel & "000";
     v.rxdstate := write_status2;
     v.rmsto.data := X"000" & '0' & r.rxstatus & "000" & r.rxlength;  
   when write_status2 =>
     if rmsti.grant = '1' then
       v.rmsto.req := '0'; v.rmsto.addr := r.rmsto.addr + 4;
     end if;
     if rmsti.ready = '1' then
       if (r.rxstatus(4) or not r.rxstatus(3)) = '1' then
         v.rxdstate := discard;
       else
         v.rxdstate := idle;
       end if;
       if (r.ctrl.rx_irqen and r.rxirq) = '1' then
         vpirq := '1';
       end if;
       if conv_integer(r.rxstatus) = 0 then v.status.rx_int := '1';
       else v.status.rx_err := '1'; end if;
       if r.rxwrap = '1' then
         v.rxdsel := (others => '0');
       else
         v.rxdsel := r.rxdsel + 1;
       end if;
     end if;
     if rmsti.error = '1' then
       v.rmsto.req := '0'; v.rxdstate := idle;
       v.status.rxahberr := '1'; v.ctrl.rxen := '0';
     end if;
   when discard =>
     if (r.rxdoneold = '0') or ((r.rxdoneold = '1') and
        (conv_integer(r.rxcnt) < conv_integer(r.rxbytecount))) then
       if conv_integer(r.rfcnt) /= 0 then
         v.rfrpnt := r.rfrpnt + 1; v.rfcnt := r.rfcnt - 1;
         v.rxcnt := r.rxcnt + 4;
       end if;
     elsif (r.rxdoneold = '1') then
       v.rxdstate := idle; v.ctrlpkt := '0';
     end if;
   when others =>
     null;
   end case;
   
   --rx address/type check
   if r.check = '1' and r.rxcnt(10 downto 5) = "000000" then 
     case r.rxcnt(4 downto 2) is
     when "001" =>
       if r.checkdata /= broadcast(47 downto 16) and
          r.checkdata /= r.mac_addr(47 downto 16) and
          (not r.ctrl.prom) = '1'then
         v.addrnok := '1';
       elsif r.checkdata = broadcast(47 downto 16) then
         v.bcast := '1';
       end if;
     when "010" =>
       if r.checkdata(31 downto 16) /= broadcast(15 downto 0) and
          r.checkdata(31 downto 16) /= r.mac_addr(15 downto 0) and
          (not r.ctrl.prom) = '1' then
         v.addrnok := '1';
       elsif (r.bcast = '0') and
             (r.checkdata(31 downto 16) = broadcast(15 downto 0)) then
         v.addrnok := '1';
       end if;
     when "011" =>
       null;
     when "100" =>
       if r.checkdata(31 downto 16) = ctrlopcode then v.ctrlpkt := '1'; end if;
     when others =>
       null;
     end case; 
   end if;
    
   --rx packet done
   if (rxdone and not rxstart) = '1' then
     v.gotframe := rxo.gotframe; v.rxbytecount := rxo.byte_count;
     v.rxstatus(3 downto 0) := rxo.status;
     if (rxo.lentype > maxsizerx) or (rxo.status /= "0000") then
       v.rxlength := rxo.byte_count;
     else
       v.rxlength := rxo.lentype(10 downto 0);
       if (rxo.lentype(10 downto 0) > minpload) and
          (rxo.lentype(10 downto 0) /= rxo.byte_count) then
         if rxo.status(2 downto 0) = "000" then
           v.rxstatus(4) := '1'; v.rxlength := rxo.byte_count;
           v.usesizefield := '0';
         end if;
       elsif (rxo.lentype(10 downto 0) <= minpload) and
             (rxo.byte_count /= minpload) then
         if rxo.status(2 downto 0) = "000" then
           v.rxstatus(4) := '1'; v.rxlength := rxo.byte_count;
           v.usesizefield := '0';
         end if;
       end if;
     end if;
     v.rxdoneold := '1';
     --if ((not rxo.status(3)) or (rxo.status(3) and ovrunstop)) = '1' then
       v.rxdoneack := not r.rxdoneack; 
     --end if;
     --if ovrunstop = '1' then
     --  v.rxbytecount := (others => '0');
     --end if;
   end if; 
     
   --rx fifo write
   if vrxwrite = '1' then
     v.rxwriteack := not r.rxwriteack;
     if (not r.rfcnt(fabits)) = '1' then 
       v.rfwpnt := r.rfwpnt + 1; v.rfcnt := v.rfcnt + 1; v.writeok := '1'; 
       vrxfi.write := '1'; 
     else
       v.writeok := '0'; 
     end if;
   end if;  

   --must be placed here because it uses variable  
   vrxfi.raddress := v.rfrpnt;

-------------------------------------------------------------------------------
-- MDIO INTERFACE -------------------------------------------------------------
-------------------------------------------------------------------------------
   --mdio commands
   if enable_mdio = 1 then
     mclk := r.mdioclk and not r.mdioclkold;
     v.mdioclkold := r.mdioclk;
     if r.mdccnt = "00000000" then
       v.mdccnt := divisor;
       v.mdioclk := not r.mdioclk;
     else
       v.mdccnt := r.mdccnt - 1;
     end if;
     mdioindex := conv_integer(r.cnt); v.mdioi := mdio_i;
     if mclk = '1' then
       case r.mdio_state is
         when idle =>
           v.cnt := (others => '0');
           if r.mdio_ctrl.busy = '1' then
             v.mdio_ctrl.linkfail := '0'; 
             if r.mdio_ctrl.read = '1' then
               v.mdio_ctrl.write := '0'; 
             end if;
             v.mdio_state := preamble; v.mdioo := '1';
             if OEPOL = 0 then v.mdioen := '0'; else v.mdioen := '1'; end if;
           end if; 
         when preamble =>
           v.cnt := r.cnt + 1; 
           if r.cnt = "11111" then
             v.mdioo := '0'; v.mdio_state := startst; 
           end if; 
         when startst =>
           v.mdioo := '1'; v.mdio_state := op; v.cnt := (others => '0');
         when op =>
           v.mdio_state := op2;    
           if r.mdio_ctrl.read = '1' then v.mdioo := '1';
           else v.mdioo := '0'; end if;
         when op2 =>
           v.mdioo := not r.mdioo; v.mdio_state := phyadr;
           v.cnt := (others => '0');
         when phyadr =>
           v.cnt := r.cnt + 1;
           case mdioindex is
           when 0 => v.mdioo := r.mdio_ctrl.phyadr(4);
           when 1 => v.mdioo := r.mdio_ctrl.phyadr(3);
           when 2 => v.mdioo := r.mdio_ctrl.phyadr(2);
           when 3 => v.mdioo := r.mdio_ctrl.phyadr(1);
           when 4 => v.mdioo := r.mdio_ctrl.phyadr(0);
                     v.mdio_state := regadr; v.cnt := (others => '0');
           when others => null;
           end case;
         when regadr =>
           v.cnt := r.cnt + 1;
           case mdioindex is
           when 0 => v.mdioo := r.mdio_ctrl.regadr(4);
           when 1 => v.mdioo := r.mdio_ctrl.regadr(3);
           when 2 => v.mdioo := r.mdio_ctrl.regadr(2);
           when 3 => v.mdioo := r.mdio_ctrl.regadr(1);
           when 4 => v.mdioo := r.mdio_ctrl.regadr(0);
                     v.mdio_state := ta; v.cnt := (others => '0');
           when others => null;
           end case;
         when ta =>
           v.mdio_state := ta2;
           if r.mdio_ctrl.read = '1' then 
             if OEPOL = 0 then v.mdioen := '1'; else v.mdioen := '0'; end if;
           else v.mdioo := '1'; end if;
         when ta2 =>
           v.cnt := "01111"; v.mdio_state := ta3; 
           if r.mdio_ctrl.write = '1' then v.mdioo := '0'; v.mdio_state := data; end if;
         when ta3 =>
           v.mdio_state := data;
           if r.mdioi /= '0' then
             v.mdio_ctrl.linkfail := '1';
           end if;
         when data =>
           v.cnt := r.cnt - 1;
           if r.mdio_ctrl.read = '1' then
             v.mdio_ctrl.data(mdioindex) := r.mdioi; 
           else
             v.mdioo := r.mdio_ctrl.data(mdioindex);
           end if;
           if r.cnt = "00000" then
             v.mdio_state := dataend;
           end if;
         when dataend =>
           v.mdio_ctrl.busy := '0'; v.mdio_ctrl.read := '0';
           v.mdio_ctrl.write := '0'; v.mdio_state := idle;
           if OEPOL = 0 then v.mdioen := '1'; else v.mdioen := '0'; end if;
         when others =>
           null;
       end case;
     end if;
   end if;

-------------------------------------------------------------------------------
-- EDCL -----------------------------------------------------------------------
-------------------------------------------------------------------------------
   if (edcl /= 0) then
     veri.renable := '1'; veri.writem := '0'; veri.writel := '0';
     veri.waddressm := r.rpnt & r.rcntm; veri.waddressl := r.rpnt & r.rcntl;
     swap := '0'; vrxenable := '1'; vecnt := conv_integer(r.ecnt); setmz := '0';
     veri.datain := rxo.dataout;

     if vrxwrite = '1' then
       v.rxwriteack := not r.rxwriteack;
     end if;

     --edcl receiver 
     case r.edclrstate is
       when idle =>
         v.edclbcast := '0';
         if rxstart = '1' then
           v.edclrstate := wrda; v.edclactive := '0';
           v.rcntm := conv_std_logic_vector(2, bpbits);
           v.rcntl := conv_std_logic_vector(1, bpbits);
         end if;
       when wrda =>
         if vrxwrite = '1' then
           v.edclrstate := wrdsa;
           veri.writem := '1'; veri.writel := '1';
           swap := '1';
           v.rcntm := r.rcntm - 2; v.rcntl := r.rcntl + 1;
           if (macaddr(47 downto 16) /= rxo.dataout) and
                        (X"FFFFFFFF" /= rxo.dataout) then
             v.edclrstate := spill;
           elsif (X"FFFFFFFF" = rxo.dataout) then
              v.edclbcast := '1'; 
           end if;
           if conv_integer(r.abufs) = wsz then
             v.edclrstate := spill;
           end if;
         end if;
         if (rxdone and not rxstart) = '1' then
           v.edclrstate := idle;
         end if;
       when wrdsa =>
         if vrxwrite = '1' then
           v.edclrstate := wrsa; swap := '1';
           veri.writem := '1'; veri.writel := '1';
           v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl - 2;
           if (macaddr(15 downto 0) /= rxo.dataout(31 downto 16)) and
                           (X"FFFF" /= rxo.dataout(31 downto 16)) then
             v.edclrstate := spill; 
           elsif (X"FFFF" = rxo.dataout(31 downto 16)) then
             v.edclbcast := r.edclbcast; 
           end if;
         end if;
         if (rxdone and not rxstart) = '1' then
           v.edclrstate := idle;
         end if;
       when wrsa =>
         if vrxwrite = '1' then
           veri.writem := '1'; veri.writel := '1';
           v.edclrstate := wrtype; swap := '1';
           v.rcntm := r.rcntm + 2; v.rcntl := r.rcntl + 3;
         end if;
         if (rxdone and not rxstart) = '1' then
           v.edclrstate := idle;
         end if;
       when wrtype =>
         if vrxwrite = '1' then
           veri.writem := '1'; veri.writel := '1';
           v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl + 1;
           if X"0800" = rxo.dataout(31 downto 16) and (r.edclbcast = '0') then
             v.edclrstate := ip;
           elsif X"0806" = rxo.dataout(31 downto 16) and (r.edclbcast = '1') then
             v.edclrstate := arp;
           else
             v.edclrstate := spill;
           end if;
         end if;
         v.ecnt := (others => '0'); v.ipcrc := (others => '0');
         if (rxdone and not rxstart) = '1' then
           v.edclrstate := idle;
         end if;
       when ip =>
         if vrxwrite = '1' then
           v.ecnt := r.ecnt + 1;
           veri.writem := '1'; veri.writel := '1';
           case vecnt is
             when 0 =>
               v.ipcrc :=
               crcadder(not rxo.dataout(31 downto 16), r.ipcrc);
               v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl + 1;
             when 1 =>
               v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl + 2;
             when 2 =>
               v.ipcrc :=
               crcadder(not rxo.dataout(31 downto 16), r.ipcrc);
               v.rcntm := r.rcntm + 2; v.rcntl := r.rcntl - 1;
             when 3 =>
               v.rcntm := r.rcntm - 1; v.rcntl := r.rcntl + 2;
             when 4 =>
               v.udpsrc := rxo.dataout(15 downto 0);
               v.rcntm := r.rcntm + 2; v.rcntl := r.rcntl + 1; 
             when 5 =>
               setmz := '1';
               v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl + 1; 
             when 6 =>
               v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl + 1; 
             when 7 =>
               v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl + 1;
               if (rxo.dataout(31 downto 18) = r.seq) then
                 v.seq := r.seq + 1; v.nak := '0'; 
               else
                 v.nak := '1'; 
                 veri.datain(31 downto 18) := r.seq;
               end if;
               veri.datain(17) := v.nak; v.ewr := rxo.dataout(17);
               if (rxo.dataout(17) or v.nak) = '1' then
                 veri.datain(16 downto 7) := (others => '0');
               end if;
               v.oplen := rxo.dataout(16 downto 7);
               v.applength := "000000" & veri.datain(16 downto 7);
               v.ipcrc :=
               crcadder(v.applength + 38, r.ipcrc);
               v.write(conv_integer(r.rpnt)) := rxo.dataout(17);
             when 8 =>
               ipcrctmp := (others => '0');
               ipcrctmp(1 downto 0) := r.ipcrc(17 downto 16);
               ipcrctmp2 := "00" & r.ipcrc(15 downto 0);
               v.ipcrc :=
               crcadder(ipcrctmp, ipcrctmp2);
               v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl + 1;
               v.edclrstate := ipdata;
             when others =>
               null;
           end case;
         end if;
         if (rxdone and not rxstart) = '1' then
           v.edclrstate := idle;
         end if;
       when ipdata =>
         if (vrxwrite and r.ewr and not r.nak) = '1' and
                               (r.rcntm /= ebufmax) then
           veri.writem := '1'; veri.writel := '1';
           v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl + 1;
         end if;
         if rxdone = '1' then
           v.edclrstate := ipcrc; v.rcntm := conv_std_logic_vector(6, bpbits);
           ipcrctmp := (others => '0');
           ipcrctmp(1 downto 0) := r.ipcrc(17 downto 16);
           ipcrctmp2 := "00" & r.ipcrc(15 downto 0);
           v.ipcrc := crcadder(ipcrctmp, ipcrctmp2);
           if conv_integer(v.rxstatus(3 downto 0)) /= 0 then
             v.edclrstate := idle;
           end if;
         end if;
       when ipcrc =>
         veri.writem := '1'; veri.datain(31 downto 16) := not r.ipcrc(15 downto 0);
         v.edclrstate := udp; v.rcntm := conv_std_logic_vector(9, bpbits);
         v.rcntl := conv_std_logic_vector(9, bpbits);
       when udp =>
         veri.writem := '1'; veri.writel := '1';
         v.edclrstate := iplength;
         veri.datain(31 downto 16) := r.udpsrc;
         veri.datain(15 downto 0) := r.applength + 18;
         v.rcntm := conv_std_logic_vector(4, bpbits);
       when iplength =>
         veri.writem := '1';
         veri.datain(31 downto 16) := r.applength + 38;
         v.edclrstate := oplength;
         v.rcntm := conv_std_logic_vector(10, bpbits);
         v.rcntl := conv_std_logic_vector(10, bpbits);
       when oplength =>
         if rxstart = '0' then
           v.abufs := r.abufs + 1; v.rpnt := r.rpnt + 1;
           veri.writel := '1'; veri.writem := '1';
         end if;
         v.edclrstate := idle;
         veri.datain(31 downto 0) := (others => '0');
         veri.datain(15 downto 0) := "00000" & r.nak & r.oplen;
       when arp =>
         if vrxwrite = '1' then
           v.ecnt := r.ecnt + 1;
           veri.writem := '1'; veri.writel := '1';
           case vecnt is
             when 0 =>
               v.rcntm := r.rcntm + 4; 
             when 1 =>
               swap := '1'; veri.writel := '0'; 
               v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl + 4;
             when 2 =>
               swap := '1';
               v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl + 1;
             when 3 =>
               swap := '1';
               v.rcntm := r.rcntm - 4; v.rcntl := r.rcntl - 4;
             when 4 =>
               veri.datain := macaddr(31 downto 16) & macaddr(47 downto 32);
               v.rcntm := r.rcntm + 1; v.rcntl := r.rcntl + 1; 
             when 5 =>
               v.rcntl := r.rcntl + 1;
               veri.datain(31 downto 16) := rxo.dataout(15 downto 0);
               veri.datain(15 downto 0) := macaddr(15 downto 0);
               if rxo.dataout(15 downto 0) /= r.edclip(31 downto 16) then
                 v.edclrstate := spill;
               end if;
             when 6 =>
               swap := '1'; veri.writem := '0'; 
               v.rcntm := conv_std_logic_vector(5, bpbits);
               v.rcntl := conv_std_logic_vector(1, bpbits);
               if rxo.dataout(31 downto 16) /= r.edclip(15 downto 0) then
                 v.edclrstate := spill;
               else
                 v.edclactive := '1'; 
               end if;
             when 7 =>
               veri.writem := '0';
               veri.datain(15 downto 0) := macaddr(47 downto 32);
               v.rcntl := r.rcntl + 1;
               v.rcntm := conv_std_logic_vector(2, bpbits);
             when 8 =>
               v.edclrstate := arpop;
               veri.datain := macaddr(31 downto 0);
               v.rcntm := conv_std_logic_vector(5, bpbits);
             when others =>
               null;
           end case;
         end if;
         if (rxdone and not rxstart) = '1' then
           v.edclrstate := idle;
         end if;
       when arpop =>
         veri.writem := '1'; veri.datain(31 downto 16) := X"0002";
         if (rxdone and not rxstart) = '1' then
           v.edclrstate := idle;
           if conv_integer(v.rxstatus) = 0 and (rxo.gotframe = '1') then
             v.abufs := r.abufs + 1; v.rpnt := r.rpnt + 1;
           end if;
         end if;
       when spill =>
         if (rxdone and not rxstart) = '1' then
           v.edclrstate := idle;
         end if;
     end case;
          
     --edcl transmitter
     case r.txdstate is
       when getlen =>
         v.tcnt := r.tcnt + 1;
         if conv_integer(r.tcnt) = 10 then
           v.txlength := '0' & erdata(9 downto 0);
           v.tnak := erdata(10);
           v.txcnt := v.txlength;
           if (r.write(conv_integer(r.tpnt)) or v.tnak) = '1' then
             v.txlength := (others => '0');
           end if;
         end if;
         if conv_integer(r.tcnt) = 11 then
           v.txdstate := readhdr;
           v.tcnt := (others => '0');
         end if;
       when readhdr =>
         v.tcnt := r.tcnt + 1; vtxfi.write := '1';
         v.tfwpnt := r.tfwpnt + 1; v.tfcnt := v.tfcnt + 1; 
         vtxfi.datain := erdata;
         if conv_integer(r.tcnt) = 12 then
           v.txaddr := erdata(31 downto 2);
         end if;
         if conv_integer(r.tcnt) = 3 then
           if erdata(31 downto 16) = X"0806" then
             v.tarp := '1'; v.txlength := conv_std_logic_vector(42, 11);
           else
             v.tarp := '0'; v.txlength := r.txlength + 52;
           end if;
         end if;
         if r.tarp = '0' then
           if conv_integer(r.tcnt) = 12 then
             v.txdstate := start;
           end if;
         else
           if conv_integer(r.tcnt) = 10 then
             v.txdstate := start;
           end if;
         end if;
         if (txrestart or txdone) = '1' then
           v.txdstate := etdone;
         end if;
       when start =>
         v.tmsto.addr := r.txaddr & "00"; 
         v.tmsto.write := r.write(conv_integer(r.tpnt));
         if (conv_integer(r.txcnt) = 0) or (r.tarp or r.tnak) = '1' then
           v.tmsto.req := '0'; v.txdstate := etdone;
           v.txstart_sync := not r.txstart_sync;
         elsif r.write(conv_integer(r.tpnt)) = '0' then
           v.txdstate := req; v.tedcl := '1';
         else
           v.txstart_sync := not r.txstart_sync;
           v.txdstate := wrbus; v.tmsto.req := '1'; v.tedcl := '1';
           v.tmsto.data := erdata; v.tcnt := r.tcnt + 1;
         end if;
         if (txrestart or txdone) = '1' then
           v.txdstate := etdone;
         end if;
       when wrbus =>
         if tmsti.grant = '1' then
           v.tmsto.addr := r.tmsto.addr + 4;
           if ((conv_integer(r.txcnt) <= 4) and (tmsti.ready = '0')) or
              ((conv_integer(r.txcnt) <= 8) and (tmsti.ready = '1')) then
             v.tmsto.req := '0';
           end if;
         end if;
         if (tmsti.ready or tmsti.error) = '1' then
           v.tmsto.data := erdata; v.tcnt := r.tcnt + 1;
           v.txcnt := r.txcnt - 4;
           if r.tmsto.req = '0' then
             v.txdstate := etdone;
           end if;
         end if;
         if tmsti.retry = '1' then
           v.tmsto.addr := r.tmsto.addr - 4; v.tmsto.req := '1';
         end if;
         --if (txrestart or txdone) = '1' then
          -- v.txdstate := etdone; v.tmsto.req := '0';
         --end if;
       when etdone =>
         if txdone = '1' then
           v.txdstate := idle; v.txdone(nsync) := r.txdone(nsync-1);
           v.abufs := v.abufs - 1; v.tpnt := r.tpnt + 1;
           v.tfcnt := (others => '0'); v.tfrpnt := (others => '0');
           v.tfwpnt := (others => '0');
         elsif txrestart = '1' then
           v.txdstate := idle;
         end if;
       when others =>
         null;
     end case;

     if swap = '1' then
       veri.datain(31 downto 16) := rxo.dataout(15 downto 0); 
       veri.datain(15 downto 0)  := rxo.dataout(31 downto 16);
     end if;
     if setmz = '1' then
       veri.datain(31 downto 16) := (others => '0');
     end if;
     veri.raddress := r.tpnt & v.tcnt;
   end if;

   --edcl duplex mode read
   if (rmii = 1) or (edcl /= 0) then
     --edcl, gbit link mode check
     case r.duplexstate is
       when start =>
         v.mdio_ctrl.regadr := r.regaddr;
         v.mdio_ctrl.busy := '1'; v.duplexstate := waitop;
         if (r.phywr or r.rstphy) = '1' then
           v.mdio_ctrl.write := '1'; 
         else
           v.mdio_ctrl.read := '1';
         end if;
         if r.rstphy = '1' then
           v.mdio_ctrl.data := X"9000";
         end if;
       when waitop =>
         if r.mdio_ctrl.busy = '0' then
           if r.mdio_ctrl.linkfail = '1' then
             v.duplexstate := start; 
           elsif r.rstphy = '1' then
             v.duplexstate := start; v.rstphy := '0';
           else
             v.duplexstate := nextop;
           end if;
         end if;
       when nextop =>
         case r.regaddr is
           when "00000" =>
             if r.mdio_ctrl.data(15) = '1' then --rst not finished
               v.duplexstate := start; 
             elsif (r.phywr and not r.rstaneg) = '1' then --forced to 10 Mbit HD
               v.duplexstate := selmode;
             elsif r.mdio_ctrl.data(12) = '0' then --no auto neg
               v.duplexstate := start; v.phywr := '1';
               v.mdio_ctrl.data := (others => '0');
             else
               v.duplexstate := start; v.regaddr := "00001";
             end if;
             if r.rstaneg = '1' then
               v.phywr := '0';
             end if;
           when "00001" =>
             v.ext := r.mdio_ctrl.data(8); --extended status register
             v.extcap := r.mdio_ctrl.data(1); --extended register capabilities
             v.duplexstate := start;
             if r.mdio_ctrl.data(0) = '0' then
               --no extended register capabilites, unable to read aneg config
               --forcing 10 Mbit
               v.duplexstate := start; v.phywr := '1';
               v.mdio_ctrl.data := (others => '0');
               v.regaddr := (others => '0');
             elsif (r.mdio_ctrl.data(8) and not r.rstaneg) = '1' then
               --phy gbit capable, disable gbit
               v.regaddr := "01001"; 
             elsif r.mdio_ctrl.data(5) = '1' then --auto neg completed
               v.regaddr := "00100"; 
             end if;
           when "00100" =>
             v.duplexstate := start; v.regaddr := "00101";
             v.capbil(4 downto 0) := r.mdio_ctrl.data(9 downto 5);
           when "00101" =>
             v.duplexstate := selmode;
             v.capbil(4 downto 0) :=
             r.capbil(4 downto 0) and r.mdio_ctrl.data(9 downto 5);
           when "01001" =>
             if r.phywr = '0' then
               v.duplexstate := start; v.phywr := '1';
               v.mdio_ctrl.data(9 downto 8) := (others => '0');
             else
               v.regaddr := "00000";
               v.duplexstate := start; v.phywr := '1';
               v.mdio_ctrl.data := X"3300"; v.rstaneg := '1';
             end if;
           when others =>
             null;
         end case;
       when selmode =>
         v.duplexstate := done;
         if r.phywr = '1' then
           v.ctrl.full_duplex := '0'; v.ctrl.speed := '0';
         else
           sel_op_mode(r.capbil, v.ctrl.speed, v.ctrl.full_duplex);
         end if;
       when done =>
         null;
     end case;
   end if;

   --transmitter retry
   if tmsti.retry = '1' then
     v.tmsto.req := '1'; v.tmsto.addr := r.tmsto.addr - 4;
     v.txburstcnt := r.txburstcnt - 1;
   end if;

   --transmitter AHB error
   if tmsti.error = '1' and (not ((edcl /= 0) and (r.tedcl = '1'))) then
     v.tmsto.req := '0'; v.txdstate := ahberror;
   end if;
    
   --receiver retry
   if rmsti.retry = '1' then
     v.rmsto.req := '1'; v.rmsto.addr := r.rmsto.addr - 4;
     v.rxburstcnt := r.rxburstcnt - 1;
   end if;

------------------------------------------------------------------------------
-- RESET ----------------------------------------------------------------------
-------------------------------------------------------------------------------
    if irst = '0' then
      v.txdstate := idle; v.rxdstate := idle; v.rfrpnt := (others => '0');
      v.tmsto.req := '0'; v.tmsto.req := '0'; v.rfwpnt := (others => '0'); 
      v.rfcnt := (others => '0');  v.mdio_ctrl.read := '0';
      v.mdio_ctrl.write := '0'; v.ctrl.txen := '0';
      v.mdio_ctrl.busy := '0'; v.txirqgen := '0'; v.ctrl.rxen := '0';
      v.mdio_ctrl.data := (others => '0');
      v.mdio_ctrl.regadr := (others => '0');
      v.txdsel := (others => '0'); v.txstart_sync := '0';
      v.txread := (others => '0'); v.txrestart := (others => '0');
      v.txdone := (others => '0'); v.txreadack := '0'; 
      v.rxdsel := (others => '0'); v.rxdone := (others => '0');
      v.rxdoneold := '0'; v.rxdoneack := '0'; v.rxwriteack := '0';
      v.rxstart := (others => '0'); v.rxwrite := (others => '0');
      v.mdio_ctrl.linkfail := '1'; v.ctrl.reset := '0';
      v.status.invaddr := '0'; v.status.toosmall := '0';
      v.ctrl.full_duplex := '0'; v.writeok := '0';
      if (enable_mdio = 1) then
        v.mdccnt := (others => '0'); v.mdioclk := '0';
        v.mdio_state := idle;
        if OEPOL = 0 then v.mdioen := '1'; else v.mdioen := '0'; end if;
      end if;
      if (edcl /= 0) then
        v.tpnt := (others => '0'); v.rpnt := (others => '0');
        v.tcnt := (others => '0'); v.edclactive := '0';
        v.tarp := '0'; v.abufs := (others => '0');
        v.edclrstate := idle;
      end if;
      if (rmii = 1) then
        v.ctrl.speed := '1';
      end if;
      v.ctrl.tx_irqen := '0';
      v.ctrl.rx_irqen := '0';
      v.ctrl.prom := '0';
    end if;

    if edcl = 0 then
      v.edclrstate := idle; v.edclactive := '0'; v.nak := '0'; v.ewr := '0';
      v.write := (others => '0'); v.seq := (others => '0'); v.abufs := (others => '0');
      v.tpnt := (others => '0'); v.rpnt := (others => '0'); v.tcnt := (others => '0');
      v.rcntm := (others => '0'); v.rcntl := (others => '0'); v.ipcrc := (others => '0');
      v.applength := (others => '0'); v.oplen := (others => '0');
      v.udpsrc := (others => '0'); v.ecnt := (others => '0'); v.tarp := '0';
      v.tnak := '0'; v.tedcl := '0'; v.edclbcast := '0';
    end if;

    --some parts of edcl are only affected by hw reset
    if rst = '0' then
      v.edclip := conv_std_logic_vector(ipaddrh, 16) &
                  conv_std_logic_vector(ipaddrl, 16);
      if edcl = 2 then v.edclip(3 downto 0) := edcladdr; end if;
      v.duplexstate := start; v.regaddr := (others => '0');
      v.phywr := '0'; v.rstphy := '1'; v.rstaneg := '0';
      if phyrstadr /= 32 then 
        v.mdio_ctrl.phyadr := conv_std_logic_vector(phyrstadr, 5);
      else
        v.mdio_ctrl.phyadr := phyrstaddr;
      end if;
      v.seq := (others => '0');
    end if;
-------------------------------------------------------------------------------
-- SIGNAL ASSIGNMENTS ---------------------------------------------------------
-------------------------------------------------------------------------------
    rin           <= v;
    prdata        <= vprdata;                          	
    irq           <= vpirq;

    --rx ahb fifo
    rxrenable                         <= vrxfi.renable;
    rxraddress(10 downto fabits)      <= (others => '0');
    rxraddress(fabits-1 downto 0)     <= vrxfi.raddress;
    rxwrite                           <= vrxfi.write;  
    rxwdata                           <= vrxfi.datain;
    rxwaddress(10 downto fabits)      <= (others => '0');
    rxwaddress(fabits-1 downto 0)     <= vrxfi.waddress;

    --tx ahb fifo  
    txrenable                         <= vtxfi.renable;
    txraddress(10 downto txfabits)    <= (others => '0');
    txraddress(txfabits-1 downto 0)   <= vtxfi.raddress;
    txwrite                           <= vtxfi.write;
    txwdata                           <= vtxfi.datain;
    txwaddress(10 downto txfabits)    <= (others => '0');
    txwaddress(txfabits-1 downto 0)   <= vtxfi.waddress;

    --edcl buf     
    erenable                          <= veri.renable;
    eraddress(15 downto eabits)       <= (others => '0');
    eraddress(eabits-1 downto 0)      <= veri.raddress;
    ewritem                           <= veri.writem;
    ewritel                           <= veri.writel;
    ewaddressm(15 downto eabits)      <= (others => '0');
    ewaddressm(eabits-1 downto 0)     <= veri.waddressm(eabits-1 downto 0);
    ewaddressl(15 downto eabits)      <= (others => '0');
    ewaddressl(eabits-1 downto 0)     <= veri.waddressl(eabits-1 downto 0);
    ewdata                            <= veri.datain;

    rxi.enable    <= vrxenable;
  end process;

  rxi.writeack    <= r.rxwriteack;
  rxi.doneack     <= r.rxdoneack;
  rxi.speed       <= r.ctrl.speed;
  rxi.writeok     <= r.writeok;
  rxi.rxd         <= rxd;
  rxi.rx_dv       <= rx_dv;
  rxi.rx_crs      <= rx_crs;
  rxi.rx_er       <= rx_er;
  
  txi.rx_col      <= rx_col;
  txi.rx_crs      <= rx_crs;
  txi.full_duplex <= r.ctrl.full_duplex;
  txi.start       <= r.txstart_sync;
  txi.readack     <= r.txreadack;
  txi.speed       <= r.ctrl.speed;
  txi.data        <= r.txdata;
  txi.valid       <= r.txvalid;
  txi.len         <= r.txlength;
  
  mdc             <= r.mdioclk;
  mdio_o          <= r.mdioo; 
  mdio_oe         <= r.mdioen;
  tmsto           <= r.tmsto;
  rmsto           <= r.rmsto;

  txd             <= txo.txd;
  tx_en           <= txo.tx_en;
  tx_er           <= txo.tx_er;

  ahbmi.hgrant    <= hgrant;
  ahbmi.hready    <= hready;
  ahbmi.hresp     <= hresp;
  ahbmi.hrdata    <= hrdata;

  hbusreq         <= ahbmo.hbusreq;
  hlock           <= ahbmo.hlock;
  htrans          <= ahbmo.htrans;
  haddr           <= ahbmo.haddr;
  hwrite          <= ahbmo.hwrite;
  hsize           <= ahbmo.hsize;
  hburst          <= ahbmo.hburst;
  hprot           <= ahbmo.hprot;
  hwdata          <= ahbmo.hwdata;

  reset 	  <= irst;

  regs : process(clk) is
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process;
-------------------------------------------------------------------------------
-- TRANSMITTER-----------------------------------------------------------------
-------------------------------------------------------------------------------
  tx_rmii0 : if rmii = 0 generate
    tx0: greth_tx
      generic map(
        ifg_gap        => ifg_gap,
        attempt_limit  => attempt_limit,
        backoff_limit  => backoff_limit,
        nsync          => nsync,
        rmii           => rmii)
      port map(
        rst            => arst,
        clk            => tx_clk,
        txi            => txi,
        txo            => txo);
  end generate;

  tx_rmii1 : if rmii = 1 generate
    tx0: greth_tx
      generic map(
        ifg_gap        => ifg_gap,
        attempt_limit  => attempt_limit,
        backoff_limit  => backoff_limit,
        nsync          => nsync,
        rmii           => rmii)
      port map(
        rst            => arst,
        clk            => rmii_clk,
        txi            => txi,
        txo            => txo);
  end generate;
  
-------------------------------------------------------------------------------
-- RECEIVER -------------------------------------------------------------------
-------------------------------------------------------------------------------
  rx_rmii0 : if rmii = 0 generate
    rx0 : greth_rx
      generic map(
        nsync => nsync,
        rmii  => rmii)
      port map(
        rst   => arst,
        clk   => rx_clk,
        rxi   => rxi,  
        rxo   => rxo);
  end generate;

  rx_rmii1 : if rmii = 1 generate
    rx0 : greth_rx
      generic map(
        nsync => nsync,
        rmii  => rmii)
      port map(
        rst   => arst,
        clk   => rmii_clk,
        rxi   => rxi,  
        rxo   => rxo);
  end generate;

-------------------------------------------------------------------------------
-- AHB MST INTERFACE ----------------------------------------------------------
-------------------------------------------------------------------------------
  ahb0 : eth_ahb_mst 
    port map(rst, clk, ahbmi, ahbmo, tmsto, tmsti, rmsto, rmsti);

end architecture;
