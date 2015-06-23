-- GAISLER_LICENSE
-----------------------------------------------------------------------------   
-- Entity:      dma
-- File:        dma.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: Simple DMA (needs the AHB master interface)
------------------------------------------------------------------------------  

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;

entity ahbdma is
   generic (
     hindex : integer := 0;
     pindex : integer := 0;
     paddr  : integer := 0;
     pmask  : integer := 16#fff#;
     pirq   : integer := 0;
     dbuf   : integer := 4);
   port (
      rst  : in  std_logic;
      clk  : in  std_ulogic;
      apbi : in  apb_slv_in_type;
      apbo : out apb_slv_out_type;
      ahbi : in  ahb_mst_in_type;
      ahbo : out ahb_mst_out_type 
      );
end;      

architecture struct of ahbdma is

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBDMA, 0, 0, pirq),
  1 => apb_iobar(paddr, pmask));

type dma_state_type is (readc, writec);
subtype word32 is std_logic_vector(31 downto 0);
type datavec is array (0 to dbuf-1) of word32;
type reg_type is record
  srcaddr : std_logic_vector(31 downto 0);
  srcinc  : std_logic_vector(1 downto 0);
  dstaddr : std_logic_vector(31 downto 0);
  dstinc  : std_logic_vector(1 downto 0);
  len     : std_logic_vector(15 downto 0);
  enable  : std_logic;
  write   : std_logic;
  inhibit : std_logic;
  status  : std_logic_vector(1 downto 0);
  dstate  : dma_state_type;
  data    : datavec;
  cnt     : integer range 0 to dbuf-1;
end record;

signal r, rin : reg_type;
signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;

begin

  comb : process(apbi, dmao, rst, r)
  variable v       : reg_type;
  variable regd    : std_logic_vector(31 downto 0);   -- data from registers
  variable start   : std_logic;
  variable burst   : std_logic;
  variable write   : std_logic;
  variable ready   : std_logic;
  variable retry   : std_logic;
  variable mexc    : std_logic;
  variable irq     : std_logic;
  variable address : std_logic_vector(31 downto 0);   -- DMA address
  variable size    : std_logic_vector( 1 downto 0);   -- DMA transfer size
  variable newlen  : std_logic_vector(15 downto 0);
  variable oldaddr : std_logic_vector(9 downto 0);
  variable newaddr : std_logic_vector(9 downto 0);
  variable oldsize : std_logic_vector( 1 downto 0);
  variable ainc    : std_logic_vector( 3 downto 0);

  begin

    v := r; regd := (others => '0'); burst := '0'; start := '0';
    write := '0'; ready := '0'; mexc := '0';
    size := r.srcinc; irq := '0'; v.inhibit := '0';
    if r.write = '0' then address := r.srcaddr;
    else address := r.dstaddr; end if;
    newlen := r.len - 1;

    if (r.cnt < dbuf-1) or (r.len(9 downto 2) = "11111111") then burst := '1'; 
    else burst := '0'; end if;
    start := r.enable;
    if dmao.active = '1' then
      if r.write = '0' then
	if dmao.ready = '1' then
	  v.data(r.cnt) := dmao.rdata;
	  if r.cnt = dbuf-1 then 
	    v.write := '1'; v.cnt := 0; v.inhibit := '1';
	    address := r.dstaddr; size := r.dstinc;
	  else v.cnt := r.cnt + 1; end if;
	end if;
      else
	if r.cnt = dbuf-1 then start := '0'; end if;
	if dmao.ready = '1' then
	  if r.cnt = dbuf-1 then v.cnt := 0;
	    v.write := '0'; v.len := newlen; v.enable := start; irq := start;
	  else v.cnt := r.cnt + 1; end if;
	end if;
      end if;
    end if;

    if r.write = '0' then oldaddr := r.srcaddr(9 downto 0); oldsize := r.srcinc;
    else oldaddr := r.dstaddr(9 downto 0); oldsize := r.dstinc; end if;

    ainc := decode(oldsize);

    newaddr := oldaddr + ainc(3 downto 0);

    if (dmao.active and dmao.ready) = '1' then
      if r.write = '0' then v.srcaddr(9 downto 0) := newaddr;
      else v.dstaddr(9 downto 0) := newaddr; end if;
    end if;

-- read DMA registers

    case apbi.paddr(3 downto 2) is
    when "00" => regd := r.srcaddr;
    when "01" => regd := r.dstaddr;
    when "10" => regd(20 downto 0) := r.enable & r.srcinc & r.dstinc & r.len;
    when others => null;
    end case;

-- write DMA registers

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(3 downto 2) is
      when "00" => 
        v.srcaddr := apbi.pwdata;
      when "01" => 
        v.dstaddr := apbi.pwdata;
      when "10" => 
        v.len := apbi.pwdata(15 downto 0);
        v.srcinc := apbi.pwdata(17 downto 16);
        v.dstinc := apbi.pwdata(19 downto 18);
        v.enable := apbi.pwdata(20);
      when others => null;
      end case;
    end if;

    if rst = '0' then
      v.dstate := readc; v.enable := '0'; v.write := '0';
      v.cnt  := 0;
    end if;

    rin <= v;
    apbo.prdata  <= regd;
    dmai.address <= address;
    dmai.wdata   <= r.data(r.cnt);
    dmai.start   <= start and not v.inhibit;
    dmai.burst   <= burst;
    dmai.write   <= v.write;
    dmai.size    <= size;
    apbo.pirq    <= (others =>'0');
    apbo.pindex  <= pindex;
    apbo.pconfig <= pconfig;

  end process;


  ahbif : ahbmst generic map (hindex => hindex, devid => 16#26#, incaddr => 1) 
	port map (rst, clk, dmai, dmao, ahbi, ahbo);


  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;

-- pragma translate_off
    bootmsg : report_version 
    generic map ("ahbdma" & tost(pindex) & 
	": AHB DMA Unit rev " & tost(0) & ", irq " & tost(pirq));
-- pragma translate_on

end;
