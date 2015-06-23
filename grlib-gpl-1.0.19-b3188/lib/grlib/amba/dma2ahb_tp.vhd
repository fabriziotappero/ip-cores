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
--============================================================================--
-- Design unit  : DMA2AHB_TestPackage (package declaration)
--
-- File name    : dma2ahb_tp.vhd
--
-- Purpose      : Interface package for AMBA AHB master interface with DMA input
--
-- Reference    : AMBA(TM) Specification (Rev 2.0), ARM IHI 0011A,
--                13th May 1999, issue A, first release, ARM Limited
--                The document can be retrieved from http://www.arm.com
--                AMBA is a trademark of ARM Limited.
--                ARM is a registered trademark of ARM Limited.
--
-- Note         : Naming convention according to AMBA(TM) Specification:
--                Signal names are in upper case, except for the following:
--                   A lower case 'n' in the name indicates that the signal
--                   is active low.
--                   Constant names are in upper case.
--                The least significant bit of an array is located to the right,
--                carrying the index number zero.
--
-- Limitations  : See DMA2AHB VHDL core
--
-- Library      : {independent}
--
-- Authors      : Mr Sandi Habinc
--                Gaisler Research AB
--                Forsta Langgantan 19
--                SE-413 27 Göteborg
--                Sweden
--
-- Contact      : mailto:sandi@gaisler.com
--                http://www.gaisler.com
--
-- Disclaimer   : All information is provided "as is", there is no warranty that
--                the information is correct or suitable for any purpose,
--                neither implicit nor explicit.
--
--------------------------------------------------------------------------------
-- Version  Author   Date           Changes
--
-- 1.4      SH        1 Jul 2005    New package
-- 1.5      SH        1 Sep 2005    New library TOPNET
-- 1.6      SH       20 Sep 2005    Added transparent HSIZE support
-- 1.8      SH       10 Nov 2005    Updated DMA2AHB interface usage
-- 1.9      SH        4 Jan 2006    Burst routines added
--                                  Fault reporting priority and timing improved
-- 1.9.1    SH       12 Jan 2006    Correct DmaComp8
-- 1.9.2    SH       ## ### ####    Corrected compare to allow pull-up
--                                  Adjusted printouts
-- 1.9.3    JA       14 Dec 2007    Support for halfword and byte bursts
-- 1.9.4    MI        4 Aug 2008    Support for Lock
--------------------------------------------------------------------------------
library  IEEE;
use      IEEE.Std_Logic_1164.all;
use      IEEE.Numeric_Std.all;

library  Std;
use      Std.Standard.all;
use      Std.TextIO.all;

library  GRLIB;
use      GRLIB.AMBA.all;
use      GRLIB.STDIO.all;
use      GRLIB.DMA2AHB_Package.all;
use      GRLIB.STDLIB.all;

package DMA2AHB_TestPackage is

   -----------------------------------------------------------------------------
   -- Vector of words
   -----------------------------------------------------------------------------
   type Data_Vector  is array (Natural range <> ) of
                                          Std_Logic_Vector(32-1 downto 0);

   -----------------------------------------------------------------------------
   -- Constants for comparison
   -----------------------------------------------------------------------------
   constant DontCare32:    Std_Logic_Vector(31 downto 0) := (others => '-');
   constant DontCare24:    Std_Logic_Vector(23 downto 0) := (others => '-');
   constant DontCare16:    Std_Logic_Vector(15 downto 0) := (others => '-');
   constant DontCare8:     Std_Logic_Vector( 7 downto 0) := (others => '-');

   ----------------------------------------------------------------------------
   -- Constant for calculating burst lengths
   ----------------------------------------------------------------------------
   constant WordSize: integer := 32;
   
   -----------------------------------------------------------------------------
   -- Initialize AHB interface
   -----------------------------------------------------------------------------
   procedure DMAInit(
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      constant InstancePath:  in    String  := "DMAInit";
      constant ScreenOutput:  in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWrite(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAQuiet(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAQuiet";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMARead(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMARead";
      constant ScreenOutput:  in    Boolean := True;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAComp(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant CxData:        in    Std_Logic_Vector(31 downto 0);
      variable RxData:        out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAComp";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWrite16(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(15 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite16";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAQuiet16(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(15 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAQuiet16";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMARead16(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(15 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMARead16";
      constant ScreenOutput:  in    Boolean := True;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAComp16(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant CxData:        in    Std_Logic_Vector(15 downto 0);
      variable RxData:        out   Std_Logic_Vector(15 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAComp16";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWrite8(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector( 7 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite8";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAQuiet8(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector( 7 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAQuiet8";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMARead8(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector( 7 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMARead8";
      constant ScreenOutput:  in    Boolean := True;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAComp8(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant CxData:        in    Std_Logic_Vector( 7 downto 0);
      variable RxData:        out   Std_Logic_Vector( 7 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAComp8";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWriteQuietBurst(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Data_Vector;
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Beat:          in    Integer := 1;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWriteBurst(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Data_Vector;
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Beat:          in    Integer := 1;
      constant Lock:          in    Boolean := False);

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAQuietBurst(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Data_Vector;
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAQuiet";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Beat:          in    Integer := 1;
      constant Lock:          in    Boolean := False);


   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAReadBurst(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Data_Vector;
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMARead";
      constant ScreenOutput:  in    Boolean := True;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Beat:          in    Integer := 1;
      constant Lock:          in    Boolean := False);


   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMACompBurst(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable CxData:        in    Data_Vector;
      variable RxData:        out   Data_Vector;
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAComp";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Beat:          in    Integer := 1;
      constant Lock:          in    Boolean := False);

end package DMA2AHB_TestPackage;

package body DMA2AHB_TestPackage is
   -----------------------------------------------------------------------------
   -- Compare function handling '-'
   -----------------------------------------------------------------------------
   function Compare(O, C: in Std_Logic_Vector) return Boolean is
      variable T:       Std_Logic_Vector(O'Range) := C;
      variable Result:  Boolean;
   begin
      Result := True;
      for i in O'Range loop
          if not (To_X01(O(i))=T(i) or T(i)='-' or T(i)='U') then
            Result   := False;
          end if;
      end loop;
      return Result;
   end function Compare;

   -----------------------------------------------------------------------------
   -- Function declarations
   -----------------------------------------------------------------------------
   function Conv_Std_Logic_Vector(
      constant i:          Integer;
               w:          Integer)
      return               Std_Logic_Vector is
      variable tmp:        Std_Logic_Vector(w-1 downto 0);
   begin
      tmp := Std_Logic_Vector(To_UnSigned(i, w));
      return(tmp);
   end;

   -----------------------------------------------------------------------------
   -- Function declarations
   -----------------------------------------------------------------------------
   function Conv_Integer(
      constant i:          Std_Logic_Vector)
      return               Integer is
      variable tmp:        Integer;
   begin
      tmp := To_Integer(UnSigned(i));
      return(tmp);
   end;

   -----------------------------------------------------------------------------
   -- Synchronisation with respect to clock and with output offset
   -----------------------------------------------------------------------------
   procedure Synchronise(
      signal   Clock:      in    Std_ULogic;
      constant Offset:     in    Time    := 5 ns;
      constant Enable:     in    Boolean := True) is
   begin
      if Enable then
         wait until Clock = '1';                         -- synchronise
         if Offset > 0 ns then
            wait for Offset;                             -- output offset delay
         end if;
      end if;
   end procedure Synchronise;

   -----------------------------------------------------------------------------
   -- Initialize AHB interface
   -----------------------------------------------------------------------------
   procedure DMAInit(
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      constant InstancePath:  in    String  := "DMAInit";
      constant ScreenOutput:  in    Boolean := False) is
      variable L:                   Line;
   begin
      Synchronise(HCLK);
      dmai.Reset     <= '0';
      dmai.Address   <= (others => '0');
      dmai.Request   <= '0';
      dmai.Burst     <= '0';
      dmai.Beat      <= (others => '0');
      dmai.Store     <= '0';
      dmai.Data      <= (others => '0');
      dmai.Size      <= "10";
      dmai.Lock      <= '0';

      if ScreenOutput then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB initalised"));
         WriteLine(Output, L);
      end if;
   end procedure DMAInit;

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWriteQuiet(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Lock:          in    Boolean := False) is
      variable L:                   Line;
   begin
      -- do not synchronise when a back-to-back access is requested
      if not cBack2Back then
         Synchronise(HCLK);
      end if;
      dmai.Reset     <= '0';
      dmai.Address   <= Address;
      dmai.Request   <= '1';
      dmai.Burst     <= '0';
      dmai.Beat      <= (others => '0');
      dmai.Store     <= '1';
      dmai.Data      <= Data;
      if    Size=32 then
         dmai.Size      <= HSIZE32;
      elsif Size=16 then
         dmai.Size      <= HSIZE16;
      elsif Size=8 then
         dmai.Size      <= HSIZE8;
      else
         report "Unsupported data width"
            severity Failure;
      end if;

      if Lock then
        dmai.Lock    <= '1';
      else
        dmai.Lock    <= '0';
      end if;

      wait for 1 ns;
      if dmao.Grant='0' then
         while dmao.Grant='0' loop
            Synchronise(HCLK, 0 ns);
         end loop;
      else
         Synchronise(HCLK);
      end if;

      dmai.Reset     <= '0';
      dmai.Request   <= '0';
      dmai.Store     <= '0';
      dmai.Burst     <= '0';

      dmai.Data      <= Data;

      loop
         Synchronise(HCLK);
         while dmao.Ready='0' and dmao.Retry='0' and dmao.Fault='0' loop
            Synchronise(HCLK);
         end loop;

         if dmao.Fault='1' then
            if ScreenOutput then
               Write (L, Now, Right, 15);
               Write (L, " : " & InstancePath);
               Write (L, String'(" : AHB write access, address: "));
               HWrite(L, Address);
               Write (L, String'("  ERROR reponse "));
               WriteLine(Output, L);
            end if;
            TP             := False;
            dmai.Reset     <= '0';
            dmai.Address   <= (others => '0');
            dmai.Data      <= (others => '0');
            dmai.Request   <= '0';
            dmai.Store     <= '0';
            dmai.Burst     <= '0';
            dmai.Beat      <= (others => '0');
            dmai.Size      <= (others => '0');
            dmai.Lock      <= '0'; 
            Synchronise(HCLK);
            Synchronise(HCLK);
            exit;
         elsif dmao.Ready='1' then
            dmai.Reset     <= '0';
            dmai.Address   <= (others => '0');
            dmai.Data      <= (others => '0');
            dmai.Request   <= '0';
            dmai.Store     <= '0';
            dmai.Burst     <= '0';
            dmai.Beat      <= (others => '0');
            dmai.Size      <= (others => '0');
            dmai.Lock      <= '0';
            exit;
         end if;

         if dmao.Retry='1' then
           if ScreenOutput then
               Write (L, Now, Right, 15);
               Write (L, " : " & InstancePath);
               Write (L, String'(" : AHB write access, address: "));
               HWrite(L, Address);
               Write (L, String'("  RETRY/SPLIT reponse "));
               WriteLine(Output, L);
            end if;
         end if;
      end loop;
   end procedure DMAWriteQuiet;

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWrite(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Lock:          in    Boolean := False) is
      variable OK:                  Boolean := True;
      variable L:                   Line;
   begin
      DMAWriteQuiet(Address, Data, HCLK, dmai, dmao, OK,
                    InstancePath, True, cBack2Back, Size, Lock);
      if ScreenOutput and OK then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB write access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : data: "));
         HWrite(L, Data);
         WriteLine(Output, L);
      elsif not OK then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB write access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : ## Failed ##"));
         WriteLine(Output, L);
         TP    := False;
      end if;
   end procedure DMAWrite;


   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAQuiet(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAQuiet";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Lock:          in    Boolean := False) is
      variable L:                   Line;
   begin
      -- do not Synchronise when a back-to-back access is requested
      if not cBack2Back then
         Synchronise(HCLK);
      end if;
      dmai.Reset     <= '0';
      dmai.Address   <= Address;
      dmai.Request   <= '1';
      dmai.Burst     <= '0';
      dmai.Beat      <= (others => '0');
      dmai.Store     <= '0';
      dmai.Data      <= (others => '0');
      if    Size=32 then
         dmai.Size      <= HSIZE32;
      elsif Size=16 then
         dmai.Size      <= HSIZE16;
      elsif Size=8 then
         dmai.Size      <= HSIZE8;
      else
         report "Unsupported data width"
            severity Failure;
      end if;

      if Lock then
        dmai.Lock       <= '1';
      else
        dmai.Lock       <= '0';
      end if;
      

      wait for 1 ns;
      if dmao.Grant='0' then
         while dmao.Grant='0' loop
            Synchronise(HCLK, 0 ns);
         end loop;
      else
         Synchronise(HCLK);
      end if;

      dmai.Reset     <= '0';
      dmai.Data      <= (others => '0');
      dmai.Request   <= '0';
      dmai.Store     <= '0';
      dmai.Burst     <= '0';
      dmai.Beat      <= (others => '0');

      loop
         Synchronise(HCLK);
         while dmao.Ready='0' and dmao.Retry='0' and dmao.Fault='0' loop
            Synchronise(HCLK);
         end loop;

         if    dmao.Fault='1' then
            if ScreenOutput then
               Write (L, Now, Right, 15);
               Write (L, " : " & InstancePath);
               Write (L, String'(" : AHB read  access, address: "));
               HWrite(L, Address);
               Write (L, String'("  ERROR reponse "));
               WriteLine(Output, L);
            end if;
            TP             := False;
            dmai.Reset     <= '0';
            dmai.Address   <= (others => '0');
            dmai.Data      <= (others => '0');
            dmai.Request   <= '0';
            dmai.Store     <= '0';
            dmai.Burst     <= '0';
            dmai.Beat      <= (others => '0');
            dmai.Size      <= (others => '0');
            Data           := (others => 'X');
            Synchronise(HCLK);
            Synchronise(HCLK);
            exit;
         elsif dmao.Ready='1' then
            Data           := dmao.Data;
            dmai.Address   <= (others => '0');
            dmai.Beat      <= (others => '0');
            dmai.Size      <= (others => '0');
            exit;
         end if;

         if dmao.Retry='1' then
           if ScreenOutput then
               Write (L, Now, Right, 15);
               Write (L, " : " & InstancePath);
               Write (L, String'(" : AHB read  access, address: "));
               HWrite(L, Address);
               Write (L, String'("  RETRY/SPLIT reponse "));
               WriteLine(Output, L);
            end if;
         end if;
      end loop;
   end procedure DMAQuiet;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMARead(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMARead";
      constant ScreenOutput:  in    Boolean := True;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Lock:          in    Boolean := False) is
      variable OK:                  Boolean := True;
      variable L:                   Line;
      variable Temp:                Std_Logic_Vector(31 downto 0);
   begin
      DMAQuiet(Address, Temp, HCLK, dmai, dmao, OK,
               InstancePath, True, cBack2Back, Size, Lock);
      if ScreenOutput and OK then
         Data := Temp;
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : data: "));
         HWrite(L, Temp);
         WriteLine(Output, L);
      elsif OK then
         Data  := Temp;
      else
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : ## Failed ##"));
         WriteLine(Output, L);
         Data  := (others => '-');
         TP    := False;
      end if;
   end procedure DMARead;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAComp(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant CxData:        in    Std_Logic_Vector(31 downto 0);
      variable RxData:        out   Std_Logic_Vector(31 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAComp";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Lock:          in    Boolean := False) is
      variable OK:                  Boolean := True;
      variable L:                   Line;
      variable Data:                Std_Logic_Vector(31 downto 0);
   begin
      DMAQuiet(Address, Data, HCLK, dmai, dmao, OK,
               InstancePath, True, cBack2Back, Size, Lock);
      if    not OK then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : ## Failed ##"));
         WriteLine(Output, L);
         TP       := False;
         RxData   := (others => '-');
      elsif not Compare(Data, CxData) then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : data: "));
         HWrite(L, Data);
         Write (L, String'(" : expected: "));
         HWrite(L, CxData);
         Write (L, String'(" # Error #"));
         WriteLine(Output, L);
         TP       := False;
         RxData   := Data;
      elsif ScreenOutput then
         Write(L, Now, Right, 15);
         Write(L, " : " & InstancePath);
         Write(L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write(L, String'(" : data: "));
         HWrite(L, Data);
         WriteLine(Output, L);
         RxData   := Data;
      else
         RxData   := Data;
      end if;
   end procedure DMAComp;

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWriteQuiet16(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(15 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite16";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False) is
   begin
      DMAWriteQuiet(Address, Data & Data, HCLK, dmai, dmao, TP,
                    InstancePath, ScreenOutput, cBack2Back, 16, Lock);
   end procedure DMAWriteQuiet16;

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWrite16(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector(15 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite16";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False) is
   begin
      DMAWrite(Address, Data & Data, HCLK, dmai, dmao, TP,
               InstancePath, ScreenOutput, cBack2Back, 16, Lock);
   end procedure DMAWrite16;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAQuiet16(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(15 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAQuiet16";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False) is
      variable Tmp:                 Std_Logic_Vector(31 downto 0);
   begin
      DMAQuiet(Address, Tmp, HCLK, dmai, dmao, TP,
               InstancePath, ScreenOutput, cBack2Back, 16, Lock);
      if Address(1)='0' then
         Data  := Tmp(31 downto 16);
      else
         Data  := Tmp(15 downto  0);
      end if;
   end procedure DMAQuiet16;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMARead16(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector(15 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMARead16";
      constant ScreenOutput:  in    Boolean := True;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False) is
      variable Tmp:                 Std_Logic_Vector(31 downto 0);
   begin
      DMARead(Address, Tmp, HCLK, dmai, dmao, TP,
              InstancePath, ScreenOutput, cBack2Back, 16, Lock);
      if Address(1)='0' then
         Data  := Tmp(31 downto 16);
      else
         Data  := Tmp(15 downto  0);
      end if;
   end procedure DMARead16;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAComp16(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant CxData:        in    Std_Logic_Vector(15 downto 0);
      variable RxData:        out   Std_Logic_Vector(15 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAComp16";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False) is
      variable TmpRx:               Std_Logic_Vector(31 downto 0);
      variable TmpCx:               Std_Logic_Vector(31 downto 0);
   begin
      if Address(1)='0' then
         TmpCx := CxData & "----------------";
      else
         TmpCx := "----------------" & CxData;
      end if;
      DMAComp(Address, TmpCx, TmpRx, HCLK, dmai, dmao, TP,
              InstancePath, ScreenOutput, cBack2Back, 16, Lock);
      if Address(1)='0' then
         RxData := TmpRx(31 downto 16);
      else
         RxData := TmpRx(15 downto  0);
      end if;
   end procedure DMAComp16;


   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWriteQuiet8(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector( 7 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite8";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False) is
   begin
      DMAWriteQuiet(Address, Data & Data & Data & Data, HCLK, dmai, dmao, TP,
                    InstancePath, ScreenOutput, cBack2Back, 8, Lock);
   end procedure DMAWriteQuiet8;

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWrite8(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Std_Logic_Vector( 7 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite8";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False) is
   begin
      DMAWrite(Address, Data & Data & Data & Data, HCLK, dmai, dmao, TP,
               InstancePath, ScreenOutput, cBack2Back, 8, Lock);
   end procedure DMAWrite8;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAQuiet8(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector( 7 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAQuiet8";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False) is
      variable Tmp:                 Std_Logic_Vector(31 downto 0);
   begin
      DMAQuiet(Address, Tmp, HCLK, dmai, dmao, TP,
               InstancePath, ScreenOutput, cBack2Back, 8, Lock);
      if    Address(1 downto 0)="00" then
         Data  := Tmp(31 downto 24);
      elsif Address(1 downto 0)="01" then
         Data  := Tmp(23 downto 16);
      elsif Address(1 downto 0)="10" then
         Data  := Tmp(15 downto  8);
      else
         Data  := Tmp( 7 downto  0);
      end if;
   end procedure DMAQuiet8;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMARead8(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Std_Logic_Vector( 7 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMARead8";
      constant ScreenOutput:  in    Boolean := True;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False) is
      variable Tmp:                 Std_Logic_Vector(31 downto 0);
   begin
      DMARead(Address, Tmp, HCLK, dmai, dmao, TP,
              InstancePath, ScreenOutput, cBack2Back, 8, Lock);
      if    Address(1 downto 0)="00" then
         Data  := Tmp(31 downto 24);
      elsif Address(1 downto 0)="01" then
         Data  := Tmp(23 downto 16);
      elsif Address(1 downto 0)="10" then
         Data  := Tmp(15 downto  8);
      else
         Data  := Tmp( 7 downto  0);
      end if;
   end procedure DMARead8;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAComp8(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant CxData:        in    Std_Logic_Vector( 7 downto 0);
      variable RxData:        out   Std_Logic_Vector( 7 downto 0);
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAComp8";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Lock:          in    Boolean := False) is
      variable TmpRx:               Std_Logic_Vector(31 downto 0);
      variable TmpCx:               Std_Logic_Vector(31 downto 0);
   begin
      if    Address(1 downto 0)="00" then
         TmpCx := CxData & "--------" & "--------" & "--------";
      elsif Address(1 downto 0)="01" then
         TmpCx := "--------" & CxData & "--------" & "--------";
      elsif Address(1 downto 0)="10" then
         TmpCx := "--------" & "--------" & CxData & "--------";
      else
         TmpCx := "--------" & "--------" & "--------" & CxData;
      end if;
      DMAComp(Address, TmpCx, TmpRx, HCLK, dmai, dmao, TP,
              InstancePath, ScreenOutput, cBack2Back, 8, Lock);
      if    Address(1 downto 0)="00" then
         RxData := TmpRx(31 downto 24);
      elsif Address(1 downto 0)="01" then
         RxData := TmpRx(23 downto 16);
      elsif Address(1 downto 0)="10" then
         RxData := TmpRx(15 downto  8);
      else
         RxData := TmpRx( 7 downto  0);
      end if;
   end procedure DMAComp8;

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWriteQuietBurst(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Data_Vector;
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Beat:          in    Integer := 1;
      constant Lock:          in    Boolean := False) is
      variable L:                   Line;
      constant Count:               Integer := Data'Length*WordSize/Size;
      variable GCount:              Integer := Data'Length*WordSize/Size;
      variable DCount:              Integer := 1;
   begin
      -- do not synchronise when a back-to-back access is requested
      if not cBack2Back then
         Synchronise(HCLK);
      end if;

      dmai.Reset     <= '0';
      dmai.Address   <= Address;
      dmai.Data      <= (others => '0');
      dmai.Request   <= '1';
      dmai.Store     <= '1';
      if Count > 1 then
         dmai.Burst  <= '1';
      else
         dmai.Burst  <= '0';
      end if;
      if    Beat=1 then
         dmai.Beat   <= HINCR;
      elsif Beat=4 then
         dmai.Beat   <= HINCR4;
      elsif Beat=8 then
         dmai.Beat   <= HINCR8;
      elsif Beat=16 then
         dmai.Beat   <= HINCR16;
      else
         report "Unsupported beat"
         severity Failure;
      end if;
      if Size=32 then
         dmai.Size      <= HSIZE32;
      elsif Size=16 then
         dmai.Size      <= HSIZE16;
      elsif Size=8 then
         dmai.Size      <= HSIZE8;
      else
         report "Unsupported data width"
         severity Failure;
      end if;

      if Lock then
        dmai.Lock       <= '1';
      else
        dmai.Lock       <= '0';
      end if;

      -- wait for first grant, indicating start of accesses
      wait for 1 ns;
      if dmao.Grant='0' then
         while dmao.Grant='0' loop
            Synchronise(HCLK);
         end loop;
         Synchronise(HCLK);
      else
         Synchronise(HCLK);
      end if;
      GCount := GCount-1;
      
      -- first data
      if Size=32 then
         dmai.Data   <= Data(0);
      elsif Size=16 then
         dmai.Data   <= Data(0)(31 downto 16) & Data(0)(31 downto 16);
      elsif Size=8 then
         dmai.Data   <= Data(0)(31 downto 24) & Data(0)(31 downto 24) &
                        Data(0)(31 downto 24) & Data(0)(31 downto 24);
      end if;
      
      loop
         -- remove request when all grants received
         if dmao.Grant='1' then
            if GCount=0 then
               dmai.Reset     <= '0';
               dmai.Request   <= '0';
               dmai.Store     <= '0';
               dmai.Burst     <= '0';
            else
               GCount         := GCount-1;
            end if;
         end if;

         Synchronise(HCLK, 0 ns);
         while dmao.Grant='0' and dmao.Ready='0' and dmao.OKAY='0' and dmao.Retry='0' and dmao.Fault='0' loop
            Synchronise(HCLK, 0 ns);
         end loop;

         if    dmao.Fault='1' then
            if ScreenOutput then
               Write (L, Now, Right, 15);
               Write (L, " : " & InstancePath);
               Write (L, String'(" : AHB write access, address: "));
               HWrite(L, Conv_Std_Logic_Vector(Conv_Integer(Address)+(DCount-1)*Beat*Size/8, 32));
               Write (L, String'("  ERROR response "));
               WriteLine(Output, L);
            end if;
            TP             := False;
            dmai.Reset     <= '0';
            dmai.Address   <= (others => '0');
            dmai.Data      <= (others => '0');
            dmai.Request   <= '0';
            dmai.Store     <= '0';
            dmai.Burst     <= '0';
            dmai.Beat      <= (others => '0');
            dmai.Size      <= (others => '0');
            Synchronise(HCLK, 0 ns);
            Synchronise(HCLK, 0 ns);
            exit;
         elsif dmao.OKAY='1' then
            -- for each OKAY, provide new data
            if DCount=Count then
               dmai.Address   <= (others => '0');
               dmai.Beat      <= (others => '0');
               dmai.Size      <= (others => '0');
               Synchronise(HCLK, 0 ns);
               while dmao.Ready='0' loop
                  Synchronise(HCLK, 0 ns);
               end loop;
               exit;
            else
               if Size=32 then
                  dmai.Data   <= Data(DCount);
               elsif Size=16 then
                  dmai.Data   <= Data(DCount/2)((31-16*(DCount mod 2)) downto (16-(16*(DCount mod 2)))) &
                                 Data(DCount/2)((31-16*(DCount mod 2)) downto (16-(16*(DCount mod 2))));
               elsif Size=8 then
                  dmai.Data   <= Data(DCount/4)((31-8*(DCount mod 4)) downto (24-(8*(DCount mod 4)))) &
                                 Data(DCount/4)((31-8*(DCount mod 4)) downto (24-(8*(DCount mod 4)))) &
                                 Data(DCount/4)((31-8*(DCount mod 4)) downto (24-(8*(DCount mod 4)))) &
                                 Data(DCount/4)((31-8*(DCount mod 4)) downto (24-(8*(DCount mod 4))));
               end if;
               DCount      := DCount+1;
            end if;
         end if;
          
        
         if dmao.Retry='1' then
           if ScreenOutput then
               Write (L, Now, Right, 15);
               Write (L, " : " & InstancePath);
               Write (L, String'(" : AHB write access, address: "));
               HWrite(L, Conv_Std_Logic_Vector(Conv_Integer(Address)+(DCount-1)*Beat*Size/8, 32));
               Write (L, String'("  RETRY/SPLIT response "));
               WriteLine(Output, L);
            end if;
         end if;
      end loop;
   end procedure DMAWriteQuietBurst;

   -----------------------------------------------------------------------------
   -- AMBA AHB write access
   -----------------------------------------------------------------------------
   procedure DMAWriteBurst(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      constant Data:          in    Data_Vector;
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAWrite";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Beat:          in    Integer := 1;
      constant Lock:          in    Boolean := False) is
      variable OK:                  Boolean := True;
      variable L:                   Line;
   begin
      DMAWriteQuietBurst(Address, Data, HCLK, dmai, dmao, OK,
                    InstancePath, ScreenOutput, cBack2Back, Size, Beat, Lock);
      if ScreenOutput and OK then
         for i in 0 to Data'Length-1 loop
            Write (L, Now, Right, 15);
            Write (L, " : " & InstancePath);
            Write (L, String'(" : AHB write access, address: "));
            HWrite(L, Conv_Std_Logic_Vector(Conv_Integer(Address)+i*Beat*Size/8, 32));
            Write (L, String'(" : data: "));
            HWrite(L, Data(i));
            WriteLine(Output, L);
         end loop;
      elsif not OK then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB write access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : ## Failed ##"));
         WriteLine(Output, L);
         TP    := False;
      end if;
   end procedure DMAWriteBurst;

   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAQuietBurst(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Data_Vector;
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAQuiet";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Beat:          in    Integer := 1;
      constant Lock:          in    Boolean := False) is
      variable L:                   Line;
      constant Count:               Integer := Data'Length*WordSize/Size;
      variable GCount:              Integer := Data'Length*WordSize/Size;
      variable DCount:              Integer := 1;
      variable DataPart:            Integer := 0;
   begin
      -- do not Synchronise when a back-to-back access is requested
      if not cBack2Back then
         Synchronise(HCLK);
      end if;
      
      dmai.Reset     <= '0';
      dmai.Address   <= Address;
      dmai.Data      <= (others => '0');
      dmai.Request   <= '1';
      dmai.Store     <= '0';
      if Count > 1 then
         dmai.Burst  <= '1';
      else
         dmai.Burst  <= '0';
      end if;
      if    Beat=1 then
         dmai.Beat   <= HINCR;
      elsif Beat=4 then
         dmai.Beat   <= HINCR4;
      elsif Beat=8 then
         dmai.Beat   <= HINCR8;
      elsif Beat=16 then
         dmai.Beat   <= HINCR16;
      else
         report "Unsupported beat"
         severity Failure;
      end if;
      if Size=32 then
         dmai.Size      <= HSIZE32;
      elsif Size=16 then
         dmai.Size      <= HSIZE16;
         if Address(1 downto 0) = "00" then
            DataPart := 0;
         else
            DataPart := 1;
         end if;
      elsif Size=8 then
         dmai.Size      <= HSIZE8;
         if Address(1 downto 0) = "00" then
            DataPart := 0;
         elsif Address(1 downto 0) = "01" then
            DataPart := 1;
         elsif Address(1 downto 0) = "10" then
            DataPart := 2;
         else
            DataPart := 3;
         end if;
      else
        report "Unsupported data width"
        severity Failure;
      end if;

      if Lock then
        dmai.Lock    <= '1';
      else
        dmai.Lock    <= '0';
      end if;
      
      
      -- wait for first grant, indicating start of accesses
      wait for 1 ns;
      if dmao.Grant='0' then
         while dmao.Grant='0' loop
            Synchronise(HCLK);
         end loop;
         Synchronise(HCLK);
      else
         Synchronise(HCLK);
      end if;
      GCount := GCount-1;

      loop
         -- remove request when all grants received
         if dmao.Grant='1' then
            if GCount=0 then
               dmai.Reset     <= '0';
               dmai.Data      <= (others => '0');
               dmai.Request   <= '0';
               dmai.Store     <= '0';
               dmai.Burst     <= '0';
            else
               GCount         := GCount-1;
            end if;
         end if;

         Synchronise(HCLK);
         while dmao.Grant='0' and dmao.Ready='0' and dmao.Retry='0' and dmao.Fault='0' loop
            Synchronise(HCLK);
         end loop;

         if    dmao.Fault='1' then
            if ScreenOutput then
               Write (L, Now, Right, 15);
               Write (L, " : " & InstancePath);
               Write (L, String'(" : AHB read  access, address: "));
               HWrite(L, Conv_Std_Logic_Vector(Conv_Integer(Address)+(DCount-1)*Beat*Size/8, 32));
               Write (L, String'("  ERROR response"));
               WriteLine(Output, L);
            end if;
            TP             := False;
            dmai.Reset     <= '0';
            dmai.Address   <= (others => '0');
            dmai.Data      <= (others => '0');
            dmai.Request   <= '0';
            dmai.Store     <= '0';
            dmai.Burst     <= '0';
            dmai.Beat      <= (others => '0');
            dmai.Size      <= (others => '0');
            Synchronise(HCLK);
            Synchronise(HCLK);
            exit;
         elsif dmao.Ready='1' then
            -- for each READY, store data
            if Size=32 then
               Data(DCount-1)    := dmao.Data;
            elsif Size=16 then
               Data((DCount-1)/2)((31-16*((DCount-1) mod 2)) downto (16-(16*((DCount-1) mod 2)))) :=
                 dmao.Data((31-16*DataPart) downto (16-16*DataPart));
               DataPart := (DataPart + 1) mod 2;
            elsif Size=8 then
               Data((DCount-1)/4)((31-8*((DCount-1) mod 4)) downto (24-(8*((DCount-1) mod 4)))) :=
                 dmao.Data((31-8*DataPart) downto (24-8*DataPart));
               DataPart := (DataPart + 1) mod 4;
            end if;
            
            if DCount=Count then
               dmai.Address   <= (others => '0');
               dmai.Beat      <= (others => '0');
               dmai.Size      <= (others => '0');
               exit;
            else
               DCount         := DCount+1;
            end if;
         end if;

         if dmao.Retry='1' then
           if ScreenOutput then
               Write (L, Now, Right, 15);
               Write (L, " : " & InstancePath);
               Write (L, String'(" : AHB read  access, address: "));
               HWrite(L, Conv_Std_Logic_Vector(Conv_Integer(Address)+(DCount-1)*Beat*Size/8, 32));
               Write (L, String'("  RETRY/SPLIT response "));
               WriteLine(Output, L);
            end if;
         end if;
      end loop;
   end procedure DMAQuietBurst;


   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMAReadBurst(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable Data:          out   Data_Vector;
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMARead";
      constant ScreenOutput:  in    Boolean := True;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Beat:          in    Integer := 1;
      constant Lock:          in    Boolean := False) is
      variable OK:                  Boolean := True;
      variable L:                   Line;
      variable Temp:                Data_Vector(0 to Data'Length-1);
   begin
      DMAQuietBurst(Address, Temp, HCLK, dmai, dmao, OK,
               InstancePath, ScreenOutput, cBack2Back, Size, Beat, Lock);
      if ScreenOutput and OK then
         Data  := Temp;
         for i in 0 to Data'Length-1 loop
            Write (L, Now, Right, 15);
            Write (L, " : " & InstancePath);
            Write (L, String'(" : AHB read  access, address: "));
            HWrite(L, Conv_Std_Logic_Vector(Conv_Integer(Address)+i*Beat*Size/8, 32));
            Write (L, String'(" : data: "));
            HWrite(L, Temp(i));
            WriteLine(Output, L);
         end loop;
      elsif OK then
         Data  := Temp;
      else
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : ## Failed ##"));
         WriteLine(Output, L);
         Temp  := (others => (others => '-'));
         Data  := Temp;
         TP    := False;
      end if;
   end procedure DMAReadBurst;


   -----------------------------------------------------------------------------
   -- AMBA AHB read access
   -----------------------------------------------------------------------------
   procedure DMACompBurst(
      constant Address:       in    Std_Logic_Vector(31 downto 0);
      variable CxData:        in    Data_Vector;
      variable RxData:        out   Data_Vector;
      signal   HCLK:          in    Std_ULogic;
      signal   dmai:          out   dma_in_type;
      signal   dmao:          in    dma_out_type;
      variable TP:            inout Boolean;
      constant InstancePath:  in    String  := "DMAComp";
      constant ScreenOutput:  in    Boolean := False;
      constant cBack2Back:    in    Boolean := False;
      constant Size:          in    Integer := 32;
      constant Beat:          in    Integer := 1;
      constant Lock:          in    Boolean := False) is
      variable OK:                  Boolean := True;
      variable L:                   Line;
      variable Data:                Data_Vector(0 to CxData'Length-1);
   begin
      DMAQuietBurst(Address, Data, HCLK, dmai, dmao, OK,
               InstancePath, ScreenOutput, cBack2Back, Size, Beat, Lock);
      if not OK then
         Write (L, Now, Right, 15);
         Write (L, " : " & InstancePath);
         Write (L, String'(" : AHB read  access, address: "));
         HWrite(L, Address);
         Write (L, String'(" : ## Failed ##"));
         WriteLine(Output, L);
         TP       := False;
         Data     := (others => (others => '-'));
         RxData   := Data;
      else
         for i in 0 to Data'Length-1 loop
            if not Compare(Data(i), CxData(i)) then
               Write(L, Now, Right, 15);
               Write(L, " : " & InstancePath);
               Write(L, String'(" : AHB read  access, address: "));
               HWrite(L, Conv_Std_Logic_Vector(Conv_Integer(Address)+i*Beat*Size/8, 32));
               Write(L, String'(" : data: "));
               HWrite(L, Data(i));
               Write(L, String'(" : expected: "));
               HWrite(L, CxData(i));
               Write(L, String'(" # Error #"));
               WriteLine(Output, L);
               TP       := False;
            elsif ScreenOutput then
               Write(L, Now, Right, 15);
               Write(L, " : " & InstancePath);
               Write(L, String'(" : AHB read  access, address: "));
               HWrite(L, Conv_Std_Logic_Vector(Conv_Integer(Address)+i*Beat*Size/8, 32));
               Write(L, String'(" : data: "));
               HWrite(L, Data(i));
               WriteLine(Output, L);
            end if;
         end loop;
         RxData   := Data;
      end if;
   end procedure DMACompBurst;

end package body DMA2AHB_TestPackage; --======================================--
