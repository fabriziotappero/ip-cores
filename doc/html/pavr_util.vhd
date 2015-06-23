-- <File header>
-- Project
--    pAVR (pipelined AVR) is an 8 bit RISC controller, compatible with Atmel's
--    AVR core, but about 3x faster in terms of both clock frequency and MIPS.
--    The increase in speed comes from a relatively deep pipeline. The original
--    AVR core has only two pipeline stages (fetch and execute), while pAVR has
--    6 pipeline stages:
--       1. PM    (read Program Memory)
--       2. INSTR (load Instruction)
--       3. RFRD  (decode Instruction and read Register File)
--       4. OPS   (load Operands)
--       5. ALU   (execute ALU opcode or access Unified Memory)
--       6. RFWR  (write Register File)
-- Version
--    0.32
-- Date
--    2002 August 07
-- Author
--    Doru Cuturela, doruu@yahoo.com
-- License
--    This program is free software; you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation; either version 2 of the License, or
--    (at your option) any later version.
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--    You should have received a copy of the GNU General Public License
--    along with this program; if not, write to the Free Software
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-- </File header>



-- <File info>
-- This file defines utilities used throughout pAVR sources:
--    - Bypass Unit access function
--       The input address is compared to all bypass entries flagged as active
--          (actually holding data). If match, read data from that entry, and
--          output it rather than the input data.
--       Multiple match can occur on an address.
--       If multiple match, the newest entry wins.
--       If 2 simultaneous entries match, the one in bypass chain having lower
--       index wins (that is, chain 0 beats chain 1 that beats chain 2). However,
--          this shouldn't happen (the controller should never fill the Bypass
--          registers with such data). That would indicate a design bug.
--    - Interrupt arbitrer function
--       This function prioritizes the interrupts.
--       Interfaces signals:
--          - input vector
--             This holds all interrupt flags. Interrupts trying to `come out'
--             are in 1 logic.
--          - output vector
--             All losing interrupts from input are disabled (0 logic). The winer
--             takes it all (1 logic).
--             The winner is the rightmost line that is in 1 logic.
-- </File info>



-- <File body>
library work;
use work.std_util.all;
library ieee;
use ieee.std_logic_1164.all;



package pavr_util is

   -- Reading through Bypass Unit
   function read_through_bpu(vin: std_logic_vector; vin_addr: std_logic_vector;
                             -- Bypass chain 0
                             bpr00: std_logic_vector; bpr00_addr: std_logic_vector; bpr00_active: std_logic;
                             bpr01: std_logic_vector; bpr01_addr: std_logic_vector; bpr01_active: std_logic;
                             bpr02: std_logic_vector; bpr02_addr: std_logic_vector; bpr02_active: std_logic;
                             bpr03: std_logic_vector; bpr03_addr: std_logic_vector; bpr03_active: std_logic;
                             -- Bypass chain 1
                             bpr10: std_logic_vector; bpr10_addr: std_logic_vector; bpr10_active: std_logic;
                             bpr11: std_logic_vector; bpr11_addr: std_logic_vector; bpr11_active: std_logic;
                             bpr12: std_logic_vector; bpr12_addr: std_logic_vector; bpr12_active: std_logic;
                             bpr13: std_logic_vector; bpr13_addr: std_logic_vector; bpr13_active: std_logic;
                             -- Bypass chain 2
                             bpr20: std_logic_vector; bpr20_addr: std_logic_vector; bpr20_active: std_logic;
                             bpr21: std_logic_vector; bpr21_addr: std_logic_vector; bpr21_active: std_logic;
                             bpr22: std_logic_vector; bpr22_addr: std_logic_vector; bpr22_active: std_logic;
                             bpr23: std_logic_vector; bpr23_addr: std_logic_vector; bpr23_active: std_logic
                            )
      return std_logic_vector;

   -- Prioritize interrupts
   function prioritize_int(vin: std_logic_vector) return std_logic_vector;

end;



package body pavr_util is

   -- Here, all data is expected to be 8 bits wide, and all addresses 5 bits wide.
   --    Even though this could have been done length independent, pAVR will never
   --    need that.
   function read_through_bpu(vin: std_logic_vector; vin_addr: std_logic_vector;
                             bpr00: std_logic_vector; bpr00_addr: std_logic_vector; bpr00_active: std_logic;
                             bpr01: std_logic_vector; bpr01_addr: std_logic_vector; bpr01_active: std_logic;
                             bpr02: std_logic_vector; bpr02_addr: std_logic_vector; bpr02_active: std_logic;
                             bpr03: std_logic_vector; bpr03_addr: std_logic_vector; bpr03_active: std_logic;
                             bpr10: std_logic_vector; bpr10_addr: std_logic_vector; bpr10_active: std_logic;
                             bpr11: std_logic_vector; bpr11_addr: std_logic_vector; bpr11_active: std_logic;
                             bpr12: std_logic_vector; bpr12_addr: std_logic_vector; bpr12_active: std_logic;
                             bpr13: std_logic_vector; bpr13_addr: std_logic_vector; bpr13_active: std_logic;
                             bpr20: std_logic_vector; bpr20_addr: std_logic_vector; bpr20_active: std_logic;
                             bpr21: std_logic_vector; bpr21_addr: std_logic_vector; bpr21_active: std_logic;
                             bpr22: std_logic_vector; bpr22_addr: std_logic_vector; bpr22_active: std_logic;
                             bpr23: std_logic_vector; bpr23_addr: std_logic_vector; bpr23_active: std_logic
                            )
   return std_logic_vector is
      variable bpr00_match, bpr01_match, bpr02_match, bpr03_match,
               bpr10_match, bpr11_match, bpr12_match, bpr13_match,
               bpr20_match, bpr21_match, bpr22_match, bpr23_match : std_logic;
      variable tmpv1, tmpv2, tmpv3, tmpv4: std_logic_vector(2 downto 0);
      variable r: std_logic_vector(7 downto 0);
   begin
      r := vin;

      bpr00_match := cmp_std_logic_vector(bpr00_addr, vin_addr);
      bpr01_match := cmp_std_logic_vector(bpr01_addr, vin_addr);
      bpr02_match := cmp_std_logic_vector(bpr02_addr, vin_addr);
      bpr03_match := cmp_std_logic_vector(bpr03_addr, vin_addr);
      bpr10_match := cmp_std_logic_vector(bpr10_addr, vin_addr);
      bpr11_match := cmp_std_logic_vector(bpr11_addr, vin_addr);
      bpr12_match := cmp_std_logic_vector(bpr12_addr, vin_addr);
      bpr13_match := cmp_std_logic_vector(bpr13_addr, vin_addr);
      bpr20_match := cmp_std_logic_vector(bpr20_addr, vin_addr);
      bpr21_match := cmp_std_logic_vector(bpr21_addr, vin_addr);
      bpr22_match := cmp_std_logic_vector(bpr22_addr, vin_addr);
      bpr23_match := cmp_std_logic_vector(bpr23_addr, vin_addr);

      tmpv1 := (bpr00_match and bpr00_active) & (bpr10_match and bpr10_active) & (bpr20_match and bpr20_active);
      tmpv2 := (bpr01_match and bpr01_active) & (bpr11_match and bpr11_active) & (bpr21_match and bpr21_active);
      tmpv3 := (bpr02_match and bpr02_active) & (bpr12_match and bpr12_active) & (bpr22_match and bpr22_active);
      tmpv4 := (bpr03_match and bpr03_active) & (bpr13_match and bpr13_active) & (bpr23_match and bpr23_active);

      case tmpv1 is
         when "000" =>
            case tmpv2 is
               when "000" =>
                  case tmpv3 is
                     when "000" =>
                        case tmpv4 is
                           when "000" =>
                              null;
                           when "001" =>
                              r := bpr23;
                           when "010" =>
                              r := bpr13;
                           when others =>
                              r := bpr03;
                        end case;
                     when "001" =>
                        r := bpr22;
                     when "010" =>
                        r := bpr12;
                     when others =>
                        r := bpr02;
                  end case;
               when "001" =>
                  r := bpr21;
               when "010" =>
                  r := bpr11;
               when others =>
                  r := bpr01;
            end case;
         when "001" =>
            r := bpr20;
         when "010" =>
            r := bpr10;
         when others =>
            r := bpr00;
      end case;

      return r;
   end;



   -- Input: a vector that is built by interrupt flags.
   -- Output: a vector derived from input, that has all elements zero, except for
   --    the rightmost position where a 1 occurs in the input.
   -- Both input and output have the width 32. That is, maximum 32 interrupt
   --    sources are supported.
   -- This should synthesize into an asynchronous device with about 5-6 elemetary
   --    gates delay.
   function prioritize_int(vin: std_logic_vector) return std_logic_vector is
      variable vout: std_logic_vector(31 downto 0);
      variable or16: std_logic;
      variable or8: std_logic_vector(1 downto 0);
      variable or4: std_logic_vector(3 downto 0);
      variable or2: std_logic_vector(7 downto 0);
   begin

      or16   := vin( 0) or
                vin( 1) or
                vin( 2) or
                vin( 3) or
                vin( 4) or
                vin( 5) or
                vin( 6) or
                vin( 7) or
                vin( 8) or
                vin( 9) or
                vin(10) or
                vin(11) or
                vin(12) or
                vin(13) or
                vin(14) or
                vin(15);

      or8(0) := vin( 0) or
                vin( 1) or
                vin( 2) or
                vin( 3) or
                vin( 4) or
                vin( 5) or
                vin( 6) or
                vin( 7);

      or8(1) := vin(16) or
                vin(17) or
                vin(18) or
                vin(19) or
                vin(20) or
                vin(21) or
                vin(22) or
                vin(23);

      or4(0) := vin( 0) or
                vin( 1) or
                vin( 2) or
                vin( 3);

      or4(1) := vin( 8) or
                vin( 9) or
                vin(10) or
                vin(11);

      or4(2) := vin(16) or
                vin(17) or
                vin(18) or
                vin(19);

      or4(3) := vin(24) or
                vin(25) or
                vin(26) or
                vin(27);

      or2(0) := vin( 0) or
                vin( 1);

      or2(1) := vin( 4) or
                vin( 5);

      or2(2) := vin( 8) or
                vin( 9);

      or2(3) := vin(12) or
                vin(13);

      or2(4) := vin(16) or
                vin(17);

      or2(5) := vin(20) or
                vin(21);

      or2(6) := vin(24) or
                vin(25);

      or2(7) := vin(28) or
                vin(29);

      for i in 0 to 15 loop
         vout(2*i)   := vin(2*i);
         vout(2*i+1) := vin(2*i+1) and (not vin(2*i));
      end loop;

      for i in 0 to 7 loop
         vout(4*i)   := vout(4*i)   and (    or2(i));
         vout(4*i+1) := vout(4*i+1) and (    or2(i));
         vout(4*i+2) := vout(4*i+2) and (not or2(i));
         vout(4*i+3) := vout(4*i+3) and (not or2(i));
      end loop;

      for i in 0 to 3 loop
         vout(8*i)   := vout(8*i)   and (    or4(i));
         vout(8*i+1) := vout(8*i+1) and (    or4(i));
         vout(8*i+2) := vout(8*i+2) and (    or4(i));
         vout(8*i+3) := vout(8*i+3) and (    or4(i));
         vout(8*i+4) := vout(8*i+4) and (not or4(i));
         vout(8*i+5) := vout(8*i+5) and (not or4(i));
         vout(8*i+6) := vout(8*i+6) and (not or4(i));
         vout(8*i+7) := vout(8*i+7) and (not or4(i));
      end loop;

      for i in 0 to 1 loop
         vout(16*i   ) := vout(16*i   ) and (    or8(i));
         vout(16*i+ 1) := vout(16*i+ 1) and (    or8(i));
         vout(16*i+ 2) := vout(16*i+ 2) and (    or8(i));
         vout(16*i+ 3) := vout(16*i+ 3) and (    or8(i));
         vout(16*i+ 4) := vout(16*i+ 4) and (    or8(i));
         vout(16*i+ 5) := vout(16*i+ 5) and (    or8(i));
         vout(16*i+ 6) := vout(16*i+ 6) and (    or8(i));
         vout(16*i+ 7) := vout(16*i+ 7) and (    or8(i));
         vout(16*i+ 8) := vout(16*i+ 8) and (not or8(i));
         vout(16*i+ 9) := vout(16*i+ 9) and (not or8(i));
         vout(16*i+10) := vout(16*i+10) and (not or8(i));
         vout(16*i+11) := vout(16*i+11) and (not or8(i));
         vout(16*i+12) := vout(16*i+12) and (not or8(i));
         vout(16*i+13) := vout(16*i+13) and (not or8(i));
         vout(16*i+14) := vout(16*i+14) and (not or8(i));
         vout(16*i+15) := vout(16*i+15) and (not or8(i));
      end loop;

      vout( 0) := vout( 0) and (    or16) ;
      vout( 1) := vout( 1) and (    or16) ;
      vout( 2) := vout( 2) and (    or16) ;
      vout( 3) := vout( 3) and (    or16) ;
      vout( 4) := vout( 4) and (    or16) ;
      vout( 5) := vout( 5) and (    or16) ;
      vout( 6) := vout( 6) and (    or16) ;
      vout( 7) := vout( 7) and (    or16) ;
      vout( 8) := vout( 8) and (    or16) ;
      vout( 9) := vout( 9) and (    or16) ;
      vout(10) := vout(10) and (    or16) ;
      vout(11) := vout(11) and (    or16) ;
      vout(12) := vout(12) and (    or16) ;
      vout(13) := vout(13) and (    or16) ;
      vout(14) := vout(14) and (    or16) ;
      vout(15) := vout(15) and (    or16) ;
      vout(16) := vout(16) and (not or16) ;
      vout(17) := vout(17) and (not or16) ;
      vout(18) := vout(18) and (not or16) ;
      vout(19) := vout(19) and (not or16) ;
      vout(20) := vout(20) and (not or16) ;
      vout(21) := vout(21) and (not or16) ;
      vout(22) := vout(22) and (not or16) ;
      vout(23) := vout(23) and (not or16) ;
      vout(24) := vout(24) and (not or16) ;
      vout(25) := vout(25) and (not or16) ;
      vout(26) := vout(26) and (not or16) ;
      vout(27) := vout(27) and (not or16) ;
      vout(28) := vout(28) and (not or16) ;
      vout(29) := vout(29) and (not or16) ;
      vout(30) := vout(30) and (not or16) ;
      vout(31) := vout(31) and (not or16) ;

      return vout;

   end;


end;
-- </File body>
