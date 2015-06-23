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
-- Entity:      tap_altera
-- File:        tap_altera_gen.vhd
-- Author:      Edvin Catovic - Gaisler Research
-- Description: Altera TAP controllers wrappers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library altera_mf;
use altera_mf.altera_mf_components.all;
use altera_mf.sld_virtual_jtag;
-- pragma translate_on

entity altera_tap is
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;  
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_inst   : out std_logic_vector(7 downto 0);     
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic     
    );
end;

architecture rtl of altera_tap is

  signal ir0 : std_logic_vector(7 downto 0);
  
 component sld_virtual_jtag
 	generic (
 		--lpm_hint	:	string := "UNUSED";
 		--lpm_type	:	string := "sld_virtual_jtag";
 		sld_auto_instance_index	:	string := "NO";
 		sld_instance_index	:	natural := 0;
 		sld_ir_width	:	natural := 1;
 		sld_sim_action	:	string := "UNUSED"
 		--sld_sim_n_scan	:	natural := 0;
 		--sld_sim_total_length	:	natural := 0
                );
 	port(
 		ir_in	:	out std_logic_vector(sld_ir_width-1 downto 0);
 		ir_out	:	in std_logic_vector(sld_ir_width-1 downto 0);
 		jtag_state_cdr	:	out std_logic;
 		jtag_state_cir	:	out std_logic;
 		jtag_state_e1dr	:	out std_logic;
 		jtag_state_e1ir	:	out std_logic;
 		jtag_state_e2dr	:	out std_logic;
 		jtag_state_e2ir	:	out std_logic;
 		jtag_state_pdr	:	out std_logic;
 		jtag_state_pir	:	out std_logic;
 		jtag_state_rti	:	out std_logic;
 		jtag_state_sdr	:	out std_logic;
 		jtag_state_sdrs	:	out std_logic;
 		jtag_state_sir	:	out std_logic;
 		jtag_state_sirs	:	out std_logic;
 		jtag_state_tlr	:	out std_logic;
 		jtag_state_udr	:	out std_logic;
 		jtag_state_uir	:	out std_logic;
 		tck	:	out std_logic;
 		tdi	:	out std_logic;
 		tdo	:	in std_logic;
 		tms	:	out std_logic;
 		virtual_state_cdr	:	out std_logic;
 		virtual_state_cir	:	out std_logic;
 		virtual_state_e1dr	:	out std_logic;
 		virtual_state_e2dr	:	out std_logic;
 		virtual_state_pdr	:	out std_logic;
 		virtual_state_sdr	:	out std_logic;
 		virtual_state_udr	:	out std_logic;
 		virtual_state_uir	:	out std_logic
 	);
 end component;

begin
  
  tapo_capt <= '0'; tapo_upd <= '0'; tapo_rst <= '0';
  tapo_xsel1 <= '0'; tapo_xsel2 <= '0';

  
  u0 : sld_virtual_jtag
    generic map (sld_ir_width => 8,
                 sld_auto_instance_index => "NO",
                 sld_instance_index => 0)
    port map (ir_in   => tapo_inst,
              ir_out  => ir0,
              jtag_state_cdr  => open,	
              jtag_state_cir  => open,
              jtag_state_e1dr => open,	
              jtag_state_e1ir => open,	
              jtag_state_e2dr => open,	
              jtag_state_e2ir => open,	
              jtag_state_pdr  => open,	
              jtag_state_pir  => open,	
              jtag_state_rti  => open,	
              jtag_state_sdr  => open, 
              jtag_state_sdrs => open, 	
              jtag_state_sir  => open,	
              jtag_state_sirs => open,	
              jtag_state_tlr  => open,	
              jtag_state_udr  => open,	
              jtag_state_uir  => open,	
              tck	      => tapo_tck,
              tdi             => tapo_tdi,
              tdo             => tapi_tdo1,
              tms             => open,  
              virtual_state_cdr	 => open,
              virtual_state_cir	 => open,
              virtual_state_e1dr => open,
              virtual_state_e2dr => open,
              virtual_state_pdr  => open,	
              virtual_state_sdr  => tapo_shft,
              virtual_state_udr  => open,	
              virtual_state_uir  => open);
  
end;
