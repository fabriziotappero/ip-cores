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
-- Entity:      tap_proasic3
-- File:        tap_proasic3.vhd
-- Author:      Edvin Catovic - Gaisler Research
-- Description: Actel Proasic3 TAP controller wrapper
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library proasic3;
-- pragma translate_on

entity proasic3_tap is
port (
     tck         : in std_ulogic;
     tms         : in std_ulogic;
     tdi         : in std_ulogic;
     trst        : in std_ulogic;
     tdo         : out std_ulogic;                    
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapi_en1    : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_inst   : out std_logic_vector(7 downto 0)
    );
end;

architecture rtl of proasic3_tap is

 component UJTAG
   port(
      UTDO           :  in    STD_ULOGIC;
      TMS            :  in    STD_ULOGIC;
      TDI            :  in    STD_ULOGIC;
      TCK            :  in    STD_ULOGIC;
      TRSTB          :  in    STD_ULOGIC;
      UIREG0         :  out   STD_ULOGIC;
      UIREG1         :  out   STD_ULOGIC;
      UIREG2         :  out   STD_ULOGIC;
      UIREG3         :  out   STD_ULOGIC;
      UIREG4         :  out   STD_ULOGIC;
      UIREG5         :  out   STD_ULOGIC;
      UIREG6         :  out   STD_ULOGIC;
      UIREG7         :  out   STD_ULOGIC;
      UTDI           :  out   STD_ULOGIC;
      URSTB          :  out   STD_ULOGIC;
      UDRCK          :  out   STD_ULOGIC;
      UDRCAP         :  out   STD_ULOGIC;
      UDRSH          :  out   STD_ULOGIC;
      UDRUPD         :  out   STD_ULOGIC;
      TDO            :  out   STD_ULOGIC);
 end component;  

 signal gnd, tdoi, rsti : std_ulogic;
 
begin

  gnd <= '0';

  tdoi <= tapi_tdo1 when tapi_en1 = '1' else tapi_tdo2;
  tapo_rst <= not rsti; 
  
  u0 : UJTAG port map (
    UTDO    => tdoi,
    TMS     => tms,       
    TDI     => tdi,       
    TCK     => tck,       
    TRSTB   => trst,       
    UIREG0  => tapo_inst(0),       
    UIREG1  => tapo_inst(1),              
    UIREG2  => tapo_inst(2),
    UIREG3  => tapo_inst(3),       
    UIREG4  => tapo_inst(4),       
    UIREG5  => tapo_inst(5),       
    UIREG6  => tapo_inst(6),       
    UIREG7  => tapo_inst(7),       
    UTDI    => tapo_tdi,       
    URSTB   => rsti,        
    UDRCK   => tapo_tck,        
    UDRCAP  => tapo_capt,      
    UDRSH   => tapo_shft,        
    UDRUPD  => tapo_upd,       
    TDO     => tdo);       

  
end;
