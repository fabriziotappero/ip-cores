library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;

package dac is

  type adcdac_in_type is
    record
      adc_in : std_ulogic;
    end record;

  type adcdac_out_type is
    record
      adc_fb  : std_ulogic;
      dac_out : std_ulogic;
    end record;

  component adcdac
    generic (
      pindex : integer;
      paddr  : integer;
      pmask  : integer;
      nbits  : integer);
    port (
      rst     : in  std_ulogic;
      clk     : in  std_ulogic;
      apbi    : in  apb_slv_in_type;
      apbo    : out apb_slv_out_type;
      adcdaci : in  adcdac_in_type;
      adcdaco : out adcdac_out_type);
  end component;

  component dac_ahb
    generic (
      length : integer;
      hindex : integer;
      haddr  : integer;
      hmask  : integer;
      tech   : integer;
      kbytes : integer);
    port (
      rst     : in  std_ulogic;
      clk     : in  std_ulogic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      dac_out : out std_ulogic);
  end component;

  component sigdelt
    generic (
      c_dacin_length : positive);
    port (
      reset   : in  std_logic;
      clock   : in  std_logic;
      dac_in  : in  std_logic_vector(c_dacin_length-1 downto 0);
      dac_out : out std_logic);
  end component;

  component adc_sigdelt
    generic (
      c_adcin_length : positive);
    port (
      rstn    : in  std_ulogic;
      clk     : in  std_ulogic;
      valid   : out std_ulogic;
      adc_fb  : out std_ulogic;
      adc_out : out std_logic_vector(c_adcin_length-1 downto 0);
      adc_in  : in  std_ulogic);
  end component;

end dac;
