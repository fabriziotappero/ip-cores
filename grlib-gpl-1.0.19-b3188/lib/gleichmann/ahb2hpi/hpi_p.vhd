library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;

package hpi is

  component ahb2hpi2
    generic (
      counter_width : integer;
      data_width    : integer;
      address_width : integer;
      hindex        : integer;
      haddr         : integer;
      hmask         : integer);
    port (
      HCLK      : in  std_ulogic;
      HRESETn   : in  std_ulogic;
      ahbso     : out ahb_slv_out_type;
      ahbsi     : in  ahb_slv_in_type;
      ADDR      : out std_logic_vector(address_width-1 downto 0);
      WDATA     : out std_logic_vector(data_width-1 downto 0);
      RDATA     : in  std_logic_vector(data_width-1 downto 0);
      nCS       : out std_ulogic;
      nWR       : out std_ulogic;
      nRD       : out std_ulogic;
      INT       : in  std_ulogic;
      drive_bus : out std_ulogic;
      dbg_equal : out std_ulogic);
  end component;


  component hpi_ram
    generic (
      abits : integer;
      dbits : integer);
    port (
      clk     : in  std_ulogic;
      address : in  std_logic_vector(1 downto 0);
      datain  : in  std_logic_vector(dbits-1 downto 0);
      dataout : out std_logic_vector(dbits-1 downto 0);
      writen  : in  std_ulogic;
      readn   : in  std_ulogic;
      csn     : in  std_ulogic);
  end component;


end package hpi;
