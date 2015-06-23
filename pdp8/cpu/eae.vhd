------------------------------------------------------------------
--!
--! PDP-8 Processor
--!
--! \brief
--!      CPU Extended Arithmetic Element (EAE)
--!
--! \file
--!      eae.vhd
--!
--! \author
--!      Rob Doyle - doyle (at) cox (dot) net
--!
--------------------------------------------------------------------
--
--  Copyright (C) 2009, 2010, 2011, 2012 Rob Doyle
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- version 2.1 of the License.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE. See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl.txt
--
--------------------------------------------------------------------
--
-- Comments are formatted for doxygen
--

library ieee;                                   --! IEEE Library
use ieee.std_logic_1164.all;                    --! IEEE 1164
use ieee.numeric_std.all;                       --! IEEE Numeric Standard
use work.cpu_types.all;                         --! Types

--
--! CPU Extended Arithmetic Element (EAE) Entity
--

entity eEAE is
    port (
        sys   : in  sys_t;                      --! Clock/Reset
        eaeOP : in  eaeOP_t;                    --! EAE Operation
        MD    : in  data_t;                     --! MD Register
        MQ    : in  data_t;                     --! MQ Register
        AC    : in  data_t;                     --! AC register
        EAE   : out eae_t                       --! EAE Output
    );
end eEAE;

--
--! CPU Extended Arithmetic Element (EAE) RTL
--

architecture rtl of eEAE is

    signal eaeREG : eae_t;                      --! EAE Register
    signal eaeMUX : eae_t;                      --! EAE Multiplexer
    signal temp1  : unsigned(0 to 24);

    --
    -- Function to implement 24bit ASR
    --
    
    function asr24(i : std_logic_vector; sc : std_logic_vector) return std_logic_vector is
        constant count : integer  := to_integer(unsigned(sc));
    begin
        case count is
            when 0 =>
                return i(1) & i(1 to 24);
            when 1 =>
                return i(1) & i(1) & i(1 to 23);
            when 2 =>
                return i(1) & i(1) & i(1) & i(1 to 22);
            when 3 =>
                return i(1) & i(1) & i(1) & i(1) & i(1 to 21);
            when 4 =>
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1 to 20);
            when 5 =>
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1 to 19);
            when 6 =>
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1 to 18);
            when 7 =>
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1 to 17);
            when 8 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1 to 16);
            when 9 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & 
                       i(1) & i(1 to 15);
            when 10 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & 
                       i(1) & i(1) & i(1 to 14);
            when 11 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & 
                       i(1) & i(1) &  i(1) & i(1 to 13);
            when 12 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & 
                       i(1) & i(1) & i(1) & i(1) & i(1 to 12);
            when 13 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & 
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1 to 11);
            when 14 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & 
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1 to 10);
            when 15 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & 
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1 to 9);
            when 16 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1 to 8);
            when 17 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1 to 7);
            when 18 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1 to 6);
            when 19 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1 to 5);
            when 20 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1 to 4);
            when 21 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1) & i(1 to 3);
            when 22 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1 to 2);
            when 23 => 
                return i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1) &
                       i(1) & i(1) & i(1) & i(1) & i(1) & i(1) & i(1);
            when others =>
                return i;
                
        end case;
    end asr24;

    --
    -- Function to implement 24bit LSR
    --
    
    function lsr24(i : std_logic_vector; sc : std_logic_vector) return std_logic_vector is
        constant count : integer  := to_integer(unsigned(sc));
    begin
        case count is
            when 0 =>
                return '0' & i(1 to 24);
            when 1 =>
                return '0' & '0' & i(1 to 23);
            when 2 =>
                return '0' & '0' & '0' & i(1 to 22);
            when 3 =>
                return '0' & '0' & '0' & '0' & i(1 to 21);
            when 4 =>
                return '0' & '0' & '0' & '0' & '0' & i(1 to 20);
            when 5 =>
                return '0' & '0' & '0' & '0' & '0' & '0' & i(1 to 19);
            when 6 =>
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & i(1 to 18);
            when 7 =>
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & i(1 to 17);
            when 8 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       i(1 to 16);
            when 9 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & 
                       '0' & i(1 to 15);
            when 10 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & 
                       '0' & '0' & i(1 to 14);
            when 11 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & 
                       '0' & '0' &  '0' & i(1 to 13);
            when 12 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & 
                       '0' & '0' & '0' & '0' & i(1 to 12);
            when 13 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & 
                       '0' & '0' & '0' & '0' & '0' & i(1 to 11);
            when 14 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & 
                       '0' & '0' & '0' & '0' & '0' & '0' & i(1 to 10);
            when 15 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & '0' & '0' & '0' & i(1 to 9);
            when 16 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & i(1 to 8);
            when 17 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       i(1 to 7);
            when 18 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & i(1 to 6);
            when 19 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & i(1 to 5);
            when 20 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & i(1 to 4);
            when 21 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & i(1 to 3);
            when 22 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & '0' & i(1 to 2);
            when 23 => 
                return '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' &
                       '0' & '0' & '0' & '0' & '0' & '0' & '0';
            when others =>
                return i;
        end case;
    end lsr24;

    --
    -- Function to implement 24bit SHL
    --
    
    function shl24(i : std_logic_vector; sc : std_logic_vector) return std_logic_vector is
        constant count : integer  := to_integer(unsigned(sc));
    begin
        case count is
            when 0 =>
                return i( 0 to 24);
            when 1 =>
                return i( 1 to 24) & "0";
            when 2 =>
                return i( 2 to 24) & "00";
            when 3 =>
                return i( 3 to 24) & "000";
            when 4 =>
                return i( 4 to 24) & "0000";
            when 5 =>
                return i( 5 to 24) & "00000";
            when 6 =>
                return i( 6 to 24) & "000000";
            when 7 =>
                return i( 7 to 24) & "0000000";
            when 8 => 
                return i( 8 to 24) & "00000000";
            when 9 => 
                return i( 9 to 24) & "000000000";
            when 10 => 
                return i(10 to 24) & "0000000000";
            when 11 => 
                return i(11 to 24) & "00000000000";
            when 12 => 
                return i(12 to 24) & "000000000000";
            when 13 => 
                return i(13 to 24) & "0000000000000";
            when 14 => 
                return i(14 to 24) & "00000000000000";
            when 15 => 
                return i(15 to 24) & "000000000000000";
            when 16 => 
                return i(16 to 24) & "0000000000000000";
            when 17 => 
                return i(17 to 24) & "00000000000000000";
            when 18 => 
                return i(18 to 24) & "000000000000000000";
            when 19 => 
                return i(19 to 24) & "0000000000000000000";
            when 20 => 
                return i(20 to 24) & "00000000000000000000";
            when 21 => 
                return i(21 to 24) & "000000000000000000000";
            when 22 => 
                return i(22 to 24) & "0000000000000000000000";
            when 23 => 
                return i(23 to 24) & "00000000000000000000000";
            when 24 => 
                return i(24 to 24) & "000000000000000000000000";
            when others =>
                return "0000000000000000000000000";
        end case;
    end shl24;
    
begin

    temp1 <= ('0' & unsigned(MD) * unsigned(MQ)) + unsigned(AC);
  
    --
    -- EAE Multiplexer
    --

    with eaeOP select
        eaeMUX <= eaeREG                   when eaeopNOP,	-- EAE <- EAE
                  std_logic_vector(temp1)  when eaeopMUY;       -- EAE <- (MQ * MD) + AC;
                --asr24(eaeREG, MD)        when eaeopASRMD,     -- EAE <- EAE ASR MD
                --lsr24(eaeREG, MD)        when eaeopLSRMD,     -- EAE <- EAE LSR MD
                --shl24(eaeREG, MD)        when eaeopSHLMD;     -- EAE <- EAE SHL MD
    --
    --! EAE Register
    --
  
    REG_EAE : process(sys)
    begin
        if sys.rst = '1' then
            eaeREG <= (others => '0');
        elsif rising_edge(sys.clk) then
            eaeREG <= eaeMUX;
        end if;
    end process REG_EAE;

    EAE <= eaeREG;
    
end rtl;
