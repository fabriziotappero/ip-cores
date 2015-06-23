library ieee;

use ieee.std_logic_1164.all;

package pci_arb_pkg is
   subtype clk_type is std_logic;
   
   -----------------------------------------------------------------------------
   -- Constant definitions for AMBA(TM) APB
   -----------------------------------------------------------------------------
   constant PDMAX:   Positive range 8 to 32 := 32;       -- data width
   constant PAMAX:   Positive range 8 to 32 := 32;       -- address width

   -----------------------------------------------------------------------------
   -- Definitions for AMBA(TM) APB Slaves
   -----------------------------------------------------------------------------
   -- APB slave inputs (PCLK and PRESETn routed separately)
   type EAPB_Slv_In_Type is
      record
         PSEL:       Std_ULogic;                         -- slave select
         PENABLE:    Std_ULogic;                         -- strobe
         PADDR:      Std_Logic_Vector(PAMAX-1 downto 0); -- address bus (byte)
         PWRITE:     Std_ULogic;                         -- write
         PWDATA:     Std_Logic_Vector(PDMAX-1 downto 0); -- write data bus
      end record;

   -- APB slave outputs
   type EAPB_Slv_Out_Type is
      record
         PRDATA:     Std_Logic_Vector(PDMAX-1 downto 0); -- read data bus
      end record;
end pci_arb_pkg;
