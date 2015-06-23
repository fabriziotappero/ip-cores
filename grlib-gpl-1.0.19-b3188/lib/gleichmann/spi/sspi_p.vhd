library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;

package sspi is

  type sspi_in_type is
    record
      miso : std_ulogic;
    end record;

  type sspi_out_type is
    record
      mosi : std_ulogic;
      sck  : std_ulogic;
      ssn  : std_logic_vector(7 downto 0);
    end record;

  component spi_oc is
    generic (
      pindex : integer := 0;            -- Leon-Index
      paddr  : integer := 0;            -- Leon-Address
      pmask  : integer := 16#FFF#;      -- Leon-Mask
      pirq   : integer := 0             -- Leon-IRQ
      );
    port (
      rstn    : in  std_ulogic;         -- global Reset, active low
      clk     : in  std_ulogic;         -- global Clock
      apbi    : in  apb_slv_in_type;    -- APB-Input
      apbo    : out apb_slv_out_type;   -- APB-Output
      spi_in  : in  sspi_in_type;        -- MultIO-Inputs
      spi_out : out sspi_out_type        -- Spi-Outputs
      );
  end component spi_oc;

end package sspi;
