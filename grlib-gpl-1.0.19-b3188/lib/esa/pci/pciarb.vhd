------------------------------------------------------------------------------
-- Entity: 	esa_pciarb 
-- File:	esa_pciarb.vhd
-- Author:     	Marko Isomaki
-- Description:	GRLIB wrapper for the ESA PCI arbiter
------------------------------------------------------------------------------

library ieee;
library grlib;
library gaisler;
library esa;
library techmap;

use ieee.std_logic_1164.all;
use grlib.stdlib.all;
use grlib.amba.all;
use grlib.devices.all;
use techmap.gencomp.all;
use esa.pci_arb_pkg.all;
--pragma translate_off
use std.textio.all;
--pragma translate_on


entity pciarb is
  generic(
    pindex     : integer := 0;
    paddr      : integer := 0;
    pmask      : integer := 16#FFF#;
    nb_agents  : integer := 4;
    apb_en     : integer := 1;
    netlist    : integer := 0);
  port(
    clk     : in std_ulogic;
    rst_n   : in std_ulogic;
    req_n   : in std_logic_vector(0 to nb_agents-1);
    frame_n : in std_logic;
    gnt_n   : out std_logic_vector(0 to nb_agents-1);
    pclk    : in std_ulogic;
    prst_n  : in std_ulogic;
    apbi    : in apb_slv_in_type;
    apbo    : out apb_slv_out_type
  );
end entity;

architecture rtl of pciarb is

component pci_arb is
  generic(
    NB_AGENTS : integer := 4;
    ARB_SIZE  : integer := 2;
    APB_EN    : integer := 1
  );
  port(
    clk     : in  clk_type;                            -- clock
    rst_n   : in  std_logic;                           -- async reset active low
    req_n   : in  std_logic_vector(0 to NB_AGENTS-1);  -- bus request
    frame_n : in  std_logic;
    gnt_n   : out std_logic_vector(0 to NB_AGENTS-1);  -- bus grant
    pclk    : in  clk_type;                            -- APB clock
    prst_n  : in  std_logic;                           -- APB reset
    pbi     : in  EAPB_Slv_In_Type;                     -- APB inputs
    pbo     : out EAPB_Slv_Out_Type                     -- APB outputs
  );
end component;

component pci_arb_net is
  generic (
    nb_agents : integer := 4;
    arb_size  : integer := 2;
    apb_en    : integer := 1
  );
  port (
    clk     : in  std_logic;                            -- clock
    rst_n   : in  std_logic;                           -- async reset active low
    req_n   : in  std_logic_vector(0 to NB_AGENTS-1);  -- bus request
    frame_n : in  std_logic;
    gnt_n   : out std_logic_vector(0 to NB_AGENTS-1);  -- bus grant
    pclk    : in  std_logic;                            -- APB clock
    prst_n  : in  std_logic;                           -- APB reset
    pbi_psel   : in  std_ulogic;                         -- slave select
    pbi_penable: in  std_ulogic;                         -- strobe
    pbi_paddr  : in  std_logic_vector(31 downto 0); -- address bus (byte)
    pbi_pwrite : in  std_ulogic;                         -- write
    pbi_pwdata : in  std_logic_vector(31 downto 0); -- write data bus
    pbo_prdata : out std_logic_vector(31 downto 0) -- read data bus
  );
end component;

signal pbi : eapb_slv_in_type;
signal pbo : eapb_slv_out_type;

constant REVISION : integer := 0;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_ESA, ESA_PCIARB, 0, REVISION, 0),
  1 => apb_iobar(paddr, pmask));

begin
  rtl0 : if netlist = 0 generate
    arb : pci_arb
    generic map(
      NB_AGENTS => nb_agents, ARB_SIZE => log2(nb_agents), APB_EN => apb_en)
    port map(
      clk => clk, rst_n => rst_n, req_n => req_n, frame_n => frame_n,
      gnt_n => gnt_n, pclk => pclk, prst_n => prst_n, pbi => pbi, pbo => pbo);
  end generate;
  net0 : if netlist /= 0 generate
    arb : pci_arb_net
    generic map(
      NB_AGENTS => nb_agents, ARB_SIZE => log2(nb_agents), APB_EN => apb_en)
    port map(
      clk => clk, rst_n => rst_n, req_n => req_n, frame_n => frame_n,
      gnt_n => gnt_n, pclk => pclk, prst_n => prst_n, 
      pbi_psel    => pbi.psel, 
      pbi_penable => pbi.penable, 
      pbi_paddr   => pbi.paddr, 
      pbi_pwrite  => pbi.pwrite, 
      pbi_pwdata  => pbi.pwdata, 
      pbo_prdata  => pbo.prdata);
  end generate;

  apbo.prdata <= pbo.prdata;
  apbo.pindex <= pindex;
  apbo.pconfig <= pconfig;
  apbo.pirq <= (others => '0');

  pbi.psel <= apbi.psel(pindex);
  pbi.penable <= apbi.penable;
  pbi.paddr <= apbi.paddr;
  pbi.pwrite <= apbi.pwrite;
  pbi.pwdata <= apbi.pwdata;
  
-- boot message

-- pragma translate_off
    bootmsg : report_version 
    generic map ("pciarb" & tost(pindex) & 
	": PCI arbiter, " & tost(nb_agents) & " masters"); 
-- pragma translate_on


end architecture;
