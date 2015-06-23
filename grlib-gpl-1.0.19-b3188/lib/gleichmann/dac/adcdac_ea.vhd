
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gleichmann;
use gleichmann.dac.all;
--pragma translate_off
use std.textio.all;
--pragma translate_on

entity adcdac is
  generic (
    pindex : integer := 0;
    paddr  : integer := 0;
    pmask  : integer := 16#fff#;
    nbits  : integer := 10              -- GPIO bits
    );
  port (
    rst     : in  std_ulogic;
    clk     : in  std_ulogic;
    apbi    : in  apb_slv_in_type;
    apbo    : out apb_slv_out_type;
    adcdaci : in  adcdac_in_type;
    adcdaco : out adcdac_out_type
    );
end;

architecture rtl of adcdac is

  constant REVISION : integer := 0;

  constant pconfig : apb_config_type := (
    0 => ahb_device_reg (VENDOR_GLEICHMANN, GLEICHMANN_ADCDAC, 0, REVISION, 0),
    1 => apb_iobar(paddr, pmask));

  type registers is
    record
      dac_reg : std_logic_vector(nbits-1 downto 0);
      adc_reg : std_logic_vector(nbits-1 downto 0);
    end record;

  signal r, rin : registers;

  -- ADC signals
  signal valid       : std_ulogic;
  signal adc_out_par : std_logic_vector(nbits-1 downto 0);

  signal rst_inv : std_ulogic;

begin

  comb : process(adc_out_par, apbi, r, rst, valid)
    variable readdata : std_logic_vector(31 downto 0);
    variable v        : registers;
  begin

-- read registers
    readdata := (others => '0');
    case apbi.paddr(4 downto 2) is
      when "000"  => readdata(nbits-1 downto 0) := r.dac_reg;
      when "001"  => readdata(nbits-1 downto 0) := r.adc_reg;
      when others => null;
    end case;

-- write registers
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(4 downto 2) is
        when "000"  => v.dac_reg := apbi.pwdata(nbits-1 downto 0);
        when "001"  => null;
        when others => null;
      end case;
    end if;

-- update ADC value
    if valid = '1' then
      v.adc_reg := adc_out_par;
    end if;

-- reset operation
    if rst = '0' then
      v.dac_reg := (others => '0');
      v.adc_reg := (others => '0');
    end if;

    rin <= v;

    apbo.prdata <= readdata;            -- drive apb read bus
    apbo.pirq   <= (others => '0');
  end process comb;

  apbo.pindex  <= pindex;
  apbo.pconfig <= pconfig;

-- registers

  regs : process(clk)
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process;

  rst_inv <= not rst;

  dac : sigdelt
    generic map (
      c_dacin_length => nbits)
    port map (
      reset   => rst_inv,
      clock   => clk,
      dac_in  => r.dac_reg(nbits-1 downto 0),
      dac_out => adcdaco.dac_out);

  adc : adc_sigdelt
    generic map (
      c_adcin_length => nbits)
    port map (
      rstn    => rst,
      clk     => clk,
      valid   => valid,
      adc_fb  => adcdaco.adc_fb,
      adc_out => adc_out_par,
      adc_in  => adcdaci.adc_in);

-- boot message

-- pragma translate_off
  bootmsg : report_version
    generic map ("adcdac" & tost(pindex) &
                 ": " & tost(nbits) & "-bit ADC/DAC core rev " & tost(REVISION));
-- pragma translate_on

end architecture rtl;
