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
-- Entity:        ssrctrl_net
-- file:          ssrctrl_net.vhd
-- Description:   Wrapper for SSRAM controller
------------------------------------------------------------------------------
library  ieee;
use      ieee.std_logic_1164.all;

library  techmap;
use      techmap.gencomp.all;

entity ssrctrl_net is
   generic (
      tech:                   Integer := 0;
      bus16:                  Integer := 1);
   port (
      rst:              in    Std_Logic;
      clk:              in    Std_Logic;

      n_ahbsi_hsel:     in    Std_Logic_Vector(0 to 15);
      n_ahbsi_haddr:    in    Std_Logic_Vector(31 downto 0);
      n_ahbsi_hwrite:   in    Std_Logic;
      n_ahbsi_htrans:   in    Std_Logic_Vector(1 downto 0);
      n_ahbsi_hsize:    in    Std_Logic_Vector(2 downto 0);
      n_ahbsi_hburst:   in    Std_Logic_Vector(2 downto 0);
      n_ahbsi_hwdata:   in    Std_Logic_Vector(31 downto 0);
      n_ahbsi_hprot:    in    Std_Logic_Vector(3 downto 0);
      n_ahbsi_hready:   in    Std_Logic;
      n_ahbsi_hmaster:  in    Std_Logic_Vector(3 downto 0);
      n_ahbsi_hmastlock:in    Std_Logic;
      n_ahbsi_hmbsel:   in    Std_Logic_Vector(0 to 3);
      n_ahbsi_hcache:   in    Std_Logic;
      n_ahbsi_hirq:     in    Std_Logic_Vector(31 downto 0);

      n_ahbso_hready:   out   Std_Logic;
      n_ahbso_hresp:    out   Std_Logic_Vector(1 downto 0);
      n_ahbso_hrdata:   out   Std_Logic_Vector(31 downto 0);
      n_ahbso_hsplit:   out   Std_Logic_Vector(15 downto 0);
      n_ahbso_hcache:   out   Std_Logic;
      n_ahbso_hirq:     out   Std_Logic_Vector(31 downto 0);

      n_apbi_psel:      in    Std_Logic_Vector(0 to 15);
      n_apbi_penable:   in    Std_Logic;
      n_apbi_paddr:     in    Std_Logic_Vector(31 downto 0);
      n_apbi_pwrite:    in    Std_Logic;
      n_apbi_pwdata:    in    Std_Logic_Vector(31 downto 0);
      n_apbi_pirq:      in    Std_Logic_Vector(31 downto 0);

      n_apbo_prdata:    out   Std_Logic_Vector(31 downto 0);
      n_apbo_pirq:      out   Std_Logic_Vector(31 downto 0);

      n_sri_data:       in    Std_Logic_Vector(31 downto 0);
      n_sri_brdyn:      in    Std_Logic;
      n_sri_bexcn:      in    Std_Logic;
      n_sri_writen:     in    Std_Logic;
      n_sri_wrn:        in    Std_Logic_Vector(3 downto 0);
      n_sri_bwidth:     in    Std_Logic_Vector(1 downto 0);
      n_sri_sd:         in    Std_Logic_Vector(63 downto 0);
      n_sri_cb:         in    Std_Logic_Vector(7 downto 0);
      n_sri_scb:        in    Std_Logic_Vector(7 downto 0);
      n_sri_edac:       in    Std_Logic;

      n_sro_address:    out   Std_Logic_Vector(31 downto 0);
      n_sro_data:       out   Std_Logic_Vector(31 downto 0);
      n_sro_sddata:     out   Std_Logic_Vector(63 downto 0);
      n_sro_ramsn:      out   Std_Logic_Vector(7 downto 0);
      n_sro_ramoen:     out   Std_Logic_Vector(7 downto 0);
      n_sro_ramn:       out   Std_Logic;
      n_sro_romn:       out   Std_Logic;
      n_sro_mben:       out   Std_Logic_Vector(3 downto 0);
      n_sro_iosn:       out   Std_Logic;
      n_sro_romsn:      out   Std_Logic_Vector(7 downto 0);
      n_sro_oen:        out   Std_Logic;
      n_sro_writen:     out   Std_Logic;
      n_sro_wrn:        out   Std_Logic_Vector(3 downto 0);
      n_sro_bdrive:     out   Std_Logic_Vector(3 downto 0);
      n_sro_vbdrive:    out   Std_Logic_Vector(31 downto 0);
      n_sro_svbdrive:   out   Std_Logic_Vector(63 downto 0);
      n_sro_read:       out   Std_Logic;
      n_sro_sa:         out   Std_Logic_Vector(14 downto 0);
      n_sro_cb:         out   Std_Logic_Vector(7 downto 0);
      n_sro_scb:        out   Std_Logic_Vector(7 downto 0);
      n_sro_vcdrive:    out   Std_Logic_Vector(7 downto 0);
      n_sro_svcdrive:   out   Std_Logic_Vector(7 downto 0);
      n_sro_ce:         out   Std_Logic);
end entity ssrctrl_net;

architecture rtl of ssrctrl_net is
   component ssrctrl_unisim
   port (
      rst:              in    Std_Logic;
      clk:              in    Std_Logic;

      n_ahbsi_hsel:     in    Std_Logic_Vector(0 to 15);
      n_ahbsi_haddr:    in    Std_Logic_Vector(31 downto 0);
      n_ahbsi_hwrite:   in    Std_Logic;
      n_ahbsi_htrans:   in    Std_Logic_Vector(1 downto 0);
      n_ahbsi_hsize:    in    Std_Logic_Vector(2 downto 0);
      n_ahbsi_hburst:   in    Std_Logic_Vector(2 downto 0);
      n_ahbsi_hwdata:   in    Std_Logic_Vector(31 downto 0);
      n_ahbsi_hprot:    in    Std_Logic_Vector(3 downto 0);
      n_ahbsi_hready:   in    Std_Logic;
      n_ahbsi_hmaster:  in    Std_Logic_Vector(3 downto 0);
      n_ahbsi_hmastlock:in    Std_Logic;
      n_ahbsi_hmbsel:   in    Std_Logic_Vector(0 to 3);
      n_ahbsi_hcache:   in    Std_Logic;
      n_ahbsi_hirq:     in    Std_Logic_Vector(31 downto 0);

      n_ahbso_hready:   out   Std_Logic;
      n_ahbso_hresp:    out   Std_Logic_Vector(1 downto 0);
      n_ahbso_hrdata:   out   Std_Logic_Vector(31 downto 0);
      n_ahbso_hsplit:   out   Std_Logic_Vector(15 downto 0);
      n_ahbso_hcache:   out   Std_Logic;
      n_ahbso_hirq:     out   Std_Logic_Vector(31 downto 0);

      n_apbi_psel:      in    Std_Logic_Vector(0 to 15);
      n_apbi_penable:   in    Std_Logic;
      n_apbi_paddr:     in    Std_Logic_Vector(31 downto 0);
      n_apbi_pwrite:    in    Std_Logic;
      n_apbi_pwdata:    in    Std_Logic_Vector(31 downto 0);
      n_apbi_pirq:      in    Std_Logic_Vector(31 downto 0);

      n_apbo_prdata:    out   Std_Logic_Vector(31 downto 0);
      n_apbo_pirq:      out   Std_Logic_Vector(31 downto 0);

      n_sri_data:       in    Std_Logic_Vector(31 downto 0);
      n_sri_brdyn:      in    Std_Logic;
      n_sri_bexcn:      in    Std_Logic;
      n_sri_writen:     in    Std_Logic;
      n_sri_wrn:        in    Std_Logic_Vector(3 downto 0);
      n_sri_bwidth:     in    Std_Logic_Vector(1 downto 0);
      n_sri_sd:         in    Std_Logic_Vector(63 downto 0);
      n_sri_cb:         in    Std_Logic_Vector(7 downto 0);
      n_sri_scb:        in    Std_Logic_Vector(7 downto 0);
      n_sri_edac:       in    Std_Logic;

      n_sro_address:    out   Std_Logic_Vector(31 downto 0);
      n_sro_data:       out   Std_Logic_Vector(31 downto 0);
      n_sro_sddata:     out   Std_Logic_Vector(63 downto 0);
      n_sro_ramsn:      out   Std_Logic_Vector(7 downto 0);
      n_sro_ramoen:     out   Std_Logic_Vector(7 downto 0);
      n_sro_ramn:       out   Std_Logic;
      n_sro_romn:       out   Std_Logic;
      n_sro_mben:       out   Std_Logic_Vector(3 downto 0);
      n_sro_iosn:       out   Std_Logic;
      n_sro_romsn:      out   Std_Logic_Vector(7 downto 0);
      n_sro_oen:        out   Std_Logic;
      n_sro_writen:     out   Std_Logic;
      n_sro_wrn:        out   Std_Logic_Vector(3 downto 0);
      n_sro_bdrive:     out   Std_Logic_Vector(3 downto 0);
      n_sro_vbdrive:    out   Std_Logic_Vector(31 downto 0);
      n_sro_svbdrive:   out   Std_Logic_Vector(63 downto 0);
      n_sro_read:       out   Std_Logic;
      n_sro_sa:         out   Std_Logic_Vector(14 downto 0);
      n_sro_cb:         out   Std_Logic_Vector(7 downto 0);
      n_sro_scb:        out   Std_Logic_Vector(7 downto 0);
      n_sro_vcdrive:    out   Std_Logic_Vector(7 downto 0);
      n_sro_svcdrive:   out   Std_Logic_Vector(7 downto 0);
      n_sro_ce:         out   Std_Logic);
   end component;

begin
   xil : if ((tech = virtex2)  or (tech = virtex4) or (tech = virtex5) or
             (tech = spartan3) or (tech = spartan3e)) and bus16=1 generate
      ssrctrlxil: ssrctrl_unisim
         port map(
            rst               => rst,
            clk               => clk,
            n_ahbsi_hsel      => n_ahbsi_hsel,
            n_ahbsi_haddr     => n_ahbsi_haddr,
            n_ahbsi_hwrite    => n_ahbsi_hwrite,
            n_ahbsi_htrans    => n_ahbsi_htrans,
            n_ahbsi_hsize     => n_ahbsi_hsize,
            n_ahbsi_hburst    => n_ahbsi_hburst,
            n_ahbsi_hwdata    => n_ahbsi_hwdata,
            n_ahbsi_hprot     => n_ahbsi_hprot,
            n_ahbsi_hready    => n_ahbsi_hready,
            n_ahbsi_hmaster   => n_ahbsi_hmaster,
            n_ahbsi_hmastlock => n_ahbsi_hmastlock,
            n_ahbsi_hmbsel    => n_ahbsi_hmbsel,
            n_ahbsi_hcache    => n_ahbsi_hcache,
            n_ahbsi_hirq      => n_ahbsi_hirq,
            n_ahbso_hready    => n_ahbso_hready,
            n_ahbso_hresp     => n_ahbso_hresp,
            n_ahbso_hrdata    => n_ahbso_hrdata,
            n_ahbso_hsplit    => n_ahbso_hsplit,
            n_ahbso_hcache    => n_ahbso_hcache,
            n_ahbso_hirq      => n_ahbso_hirq,
            n_apbi_psel       => n_apbi_psel,
            n_apbi_penable    => n_apbi_penable,
            n_apbi_paddr      => n_apbi_paddr,
            n_apbi_pwrite     => n_apbi_pwrite,
            n_apbi_pwdata     => n_apbi_pwdata,
            n_apbi_pirq       => n_apbi_pirq,
            n_apbo_prdata     => n_apbo_prdata,
            n_apbo_pirq       => n_apbo_pirq,
            n_sri_data        => n_sri_data,
            n_sri_brdyn       => n_sri_brdyn,
            n_sri_bexcn       => n_sri_bexcn,
            n_sri_writen      => n_sri_writen,
            n_sri_wrn         => n_sri_wrn,
            n_sri_bwidth      => n_sri_bwidth,
            n_sri_sd          => n_sri_sd,
            n_sri_cb          => n_sri_cb,
            n_sri_scb         => n_sri_scb,
            n_sri_edac        => n_sri_edac,
            n_sro_address     => n_sro_address,
            n_sro_data        => n_sro_data,
            n_sro_sddata      => n_sro_sddata,
            n_sro_ramsn       => n_sro_ramsn,
            n_sro_ramoen      => n_sro_ramoen,
            n_sro_ramn        => n_sro_ramn,
            n_sro_romn        => n_sro_romn,
            n_sro_mben        => n_sro_mben,
            n_sro_iosn        => n_sro_iosn,
            n_sro_romsn       => n_sro_romsn,
            n_sro_oen         => n_sro_oen,
            n_sro_writen      => n_sro_writen,
            n_sro_wrn         => n_sro_wrn,
            n_sro_bdrive      => n_sro_bdrive,
            n_sro_vbdrive     => n_sro_vbdrive,
            n_sro_svbdrive    => n_sro_svbdrive,
            n_sro_read        => n_sro_read,
            n_sro_sa          => n_sro_sa,
            n_sro_cb          => n_sro_cb,
            n_sro_scb         => n_sro_scb,
            n_sro_vcdrive     => n_sro_vcdrive,
            n_sro_svcdrive    => n_sro_svcdrive,
            n_sro_ce          => n_sro_ce);
   end generate;

-- pragma translate_off
   nonet : if not (((tech = virtex2)  or (tech = virtex4) or (tech = virtex5) or
                    (tech = spartan3) or (tech = spartan3e)))
      generate
         err : process
         begin
            assert False report "ERROR : No ssrctrl netlist available for this technology!"
            severity Failure;
            wait;
         end process;
      end generate;
   nobus16 : if not ( bus16=1 )
      generate
         err : process
         begin
            assert False report "ERROR : 16-bit PROM bus option not selected for ssrctrl netlist!"
            severity Failure;
            wait;
         end process;
      end generate;
-- pragma translate_on

end architecture;