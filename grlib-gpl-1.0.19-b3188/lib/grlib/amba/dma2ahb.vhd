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
-- Design unit  : DMA2AHB (Entity & architecture declarations)
--
-- File name    : dma2ahb.vhd
--
-- Purpose      : AMBA AHB master interface with DMA input
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
-- Limitations  : The AMBA AHB interface has been reduced in function to support
--                only what is required. The following features are constrained:
--                Optionally generates HSIZE=BYTE, HWORD and WORD
--                Only generates HPROT="0000"
--                Allways generates HBURST=HBURST_SINGLE, HBURST_INCR
--                Optionally generates HBURST_INCR4, HBURST_INCR8, HBURST_INCR16
--
--                Generates the following on reponses on DMA interface:
--                   HRESP=HRESP_OKAY  => DMAOut.Ready
--                   HRESP=HRESP_ERROR => DMAOut.Fault
--                   HRESP=HRESP_RETRY => DMAOut.Retry (normally not used)
--                   HRESP=HRESP_SPLIT => DMAOut.Retry (normally not used)
--
--                Assumes pipelined data input (after OKAY asserted).
--
--                Only big-endianness is supported.
--
--                Supports Early Bus Termination with automatic restart.
--                Supports Retry/Split with automatic restart.
--
-- Library      : gaisler
--
-- Authors      : Mr Sandi Habinc
--                Gaisler Research AB
--                Forsta Langgatan 19
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
-- 0.1      SH        1 Jul 2003    New version
-- 0.2      SH       21 Jul 2003    Combinatorial response introduced
-- 0.3      SH       25 Jan 2004    Support for interrupted bursts introduced
--                                  (early burst termination)
--                                  Optimised coding
--                                  Idle transfer initiated in 1st error phase
-- 1.3      SH        1 Oct 2004    Ported to GRLIB
-- 1.4      SH        1 Jul 2005    Support for fixed length incrementing bursts
--                                  Support for record types
-- 1.5      SH        1 Sep 2005    New library gaisler
-- 1.6      SH       20 Sep 2005    Added transparent HSIZE support
-- 1.6      SH        1 Nov 2005    DMAOut.Grant asserted only while HREADY high
-- 1.8      SH       10 Nov 2005    Re-ported to GRLIB
-- 1.8.1    SH       12 Dec 2005    Ensured no HTRANS=seq occurs after idle
-- 1.9      SH        1 Jan 2006    Resolve retry/early burst termination
-- 1.9.2    SH        3 Jan 2006    DelDataPhase dealyed with HREADY signal
-- 1.9.3    SH       24 Feb 2006    Added syncrst generic
-- 1.9.4    MI       27 Mar 2007    Driving HSIZE with address
-- 1.9.5    SH       14 Dec 2007    Automatic 1kbyte boundary crossing (merged)
-- 1.9.6    JA       14 Dec 2007    Support for halfword and byte bursts
-- 1.9.7    MI        4 Aug 2008    Support for Lock
--------------------------------------------------------------------------------
library  IEEE;
use      IEEE.Std_Logic_1164.all;

library  GRLIB;
use      GRLIB.AMBA.all;
use      GRLIB.STDLIB.all;
use      GRLIB.DMA2AHB_Package.all;

entity DMA2AHB is
   generic(
      hindex:        in    Integer := 0;
      vendorid:      in    Integer := 0;
      deviceid:      in    Integer := 0;
      version:       in    Integer := 0;
      syncrst:       in    Integer := 1;
      boundary:      in    Integer := 1);
   port(
      -- AMBA AHB system signals
      HCLK:          in    Std_ULogic;                   -- system clock
      HRESETn:       in    Std_ULogic;                   -- asynchronous reset

      -- Direct Memory Access Interface
      DMAIn:         in    DMA_In_Type;
      DMAOut:        out   DMA_OUt_Type;

      -- AMBA AHB Master Interface
      AHBIn:         in    AHB_Mst_In_Type;
      AHBOut:        out   AHB_Mst_Out_Type);
end entity DMA2AHB;

--============================== Architecture ================================--

architecture RTL of DMA2AHB is
   --=========================================================================--
   -- Configuration GRLIB
   -----------------------------------------------------------------------------
   constant HConfig:          AHB_Config_Type := (
      0        => ahb_device_reg(vendorid, deviceid, 0, version, 0),
      others   => (others => '0'));
   --=========================================================================--

   -----------------------------------------------------------------------------
   -- Local signals
   -----------------------------------------------------------------------------
   signal   Address:             Std_Logic_Vector(31 downto 0);
   signal   AddressSave:         Std_Logic_Vector(31 downto 0);

   signal   ActivePhase:         Std_ULogic;             -- ongoing access

   signal   AddressPhase:        Std_ULogic;             -- address phase
   signal   DataPhase:           Std_ULogic;             -- data phase

   signal   ReDataPhase:         Std_ULogic;             -- restart first
   signal   ReAddrPhase:         Std_ULogic;             -- restart second

   signal   IdlePhase:           Std_ULogic;             -- idle phase
   signal   EarlyPhase:          Std_ULogic;             -- early termination

   signal   BoundaryPhase:       Std_ULogic;             -- boundary crossing
   
   signal   SingleAcc:           Std_ULogic;             -- single access
   signal   WriteAcc:            Std_ULogic;             -- write access

   signal   DelDataPhase:        Std_ULogic;             -- restart first
   signal   DelAddrPhase:        Std_ULogic;             -- restart second

   signal   AHBInHGRANTx:        Std_ULogic;             -- decoded grant

begin
   --=========================================================================--
   -- AMBA AHB master interface
   -----------------------------------------------------------------------------
   AHBOut.HIRQ                   <= (others => '0');
   AHBOut.HCONFIG                <= HConfig;
   AHBOut.HINDEX                 <= hindex;

   AHBInHGRANTx                  <= AHBIn.HGRANT(hindex);
   --=========================================================================--

   -----------------------------------------------------------------------------
   -- AMBA AHB Master interface with fast issuing of accesses
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- Fixed AMBA AHB signals
   -----------------------------------------------------------------------------
   AHBOut.HPROT               <= (others => '0');

   -----------------------------------------------------------------------------
   -- Combinatorial paths
   -----------------------------------------------------------------------------
   AHBOut.HADDR               <= Address;                -- internal to external

   AHBOut.HWDATA              <= DMAIn.Data;             -- combinatorial path

   DMAOut.OKAY                <= '1' when AHBIn.HREADY='1' and
                                          DataPhase ='1' and
                                          AHBIN.HRESP=HRESP_OKAY else
                                 '0';

   DMAOut.Retry               <= '1' when AHBIn.HREADY='0' and
                                          DataPhase ='1' and
                                          (AHBIN.HRESP=HRESP_RETRY or
                                           AHBIN.HRESP=HRESP_SPLIT) else
                                 '0';

   DMAOut.Fault               <= '1' when AHBIn.HREADY='0' and
                                          DataPhase ='1' and
                                          AHBIN.HRESP=HRESP_ERROR else
                                 '0';

   DMAOut.Grant               <= '0' when DelDataPhase='1' or ReDataPhase='1' else
                                 '1' when AHBIn.HREADY='1' and
                                          AHBInHGRANTx='1' and
                                          DMAIn.Request='1' else
                                 '0';

   AHBOut.HBUSREQ             <= '0' when IdlePhase='1' else
                                 '1' when DMAIn.Request='1' else
                                 '1' when DMAIn.Burst='1' else
                                 '1' when ReDataPhase='1' else
                                 '1' when ReAddrPhase='1' else
                                 '0';
   
   AHBOut.HLOCK               <= '0' when IdlePhase='1' else
                                 '1' when (DMAIn.Lock and
                                          (DMAIn.Request or ReDataPhase)) = '1'else
                                 '0';

   -----------------------------------------------------------------------------
   -- The AMBA AHB interfacing is done in this process
   -----------------------------------------------------------------------------
   AHBMaster: process(HCLK, HRESETn)
      variable BoundaryCrossing:    Std_ULogic;
      variable AddressInc:          Std_Logic_Vector(3 downto 0);
      --------------------------------------------------------------------------
      -- This procedure is used to define all reset values for the
      -- asynchronous or synchronous reset statements in this process. This
      -- is done to avoid source code duplication.
      --------------------------------------------------------------------------
      procedure Reset is
      begin
         ActivePhase          <= '0';
         EarlyPhase           <= '0';

         AddressPhase         <= '0';
         DataPhase            <= '0';
         ReDataPhase          <= '0';
         ReAddrPhase          <= '0';

         DelDataPhase         <= '0';
         DelAddrPhase         <= '0';

         BoundaryPhase        <= '0';

         IdlePhase            <= '0';
         EarlyPhase           <= '0';

         SingleAcc            <= '0';
         WriteAcc             <= '0';

         Address              <= (others => '0');
         AddressSave          <= (others => '0');

         DMAOut.Ready         <= '0';
         DMAOut.Data          <= (others => '0');

         AHBOut.HSIZE         <= HSIZE_BYTE;
         AHBOut.HBURST        <= HBURST_SINGLE;
         AHBOut.HTRANS        <= HTRANS_IDLE;
         AHBOut.HWRITE        <= '0';

      end Reset; ---------------------------------------------------------------
   begin
      if HRESETn='0' and syncrst=0 then                  -- asynchronous reset
         Reset;
      elsif Rising_Edge(HCLK) then
         if DMAIn.Reset='1' or                           -- functional reset
            (syncrst/=0 and HRESETn='0') then            -- synchronous reset
            Reset;
         else                                            -- no reset
            --------------------------------------------------------------------
            -- Temporary variables
            --------------------------------------------------------------------
            BoundaryCrossing := '0';
            AddressInc := (others => '0');
           
            --------------------------------------------------------------------
            -- AMBA AHB interface - data phase handling
            --------------------------------------------------------------------
            -- indicate when no more activies are pending
            if AddressPhase='0' and DataPhase='0' and
               ReDataPhase='0'  and ReAddrPhase='0' and
               DMAIn.Burst='0' then
               ActivePhase          <= '0';
            end if;

            if AHBIn.HREADY='0' and DataPhase='1' then
               -- error check
               if AHBIN.HRESP=HRESP_ERROR then
                  DataPhase         <= '0';              -- data phase aborted
               end if;
               -- split or retry check
               if AHBIN.HRESP=HRESP_SPLIT or
                  AHBIN.HRESP=HRESP_RETRY then
                  ReDataPhase       <= DataPhase;        -- restart phases
                  ReAddrPhase       <= AddressPhase or ReAddrPhase;
                  AddressPhase      <= '0';              -- addr phase aborted
                  DataPhase         <= '0';              -- data phase aborted
                  -- go back with address
                  if boundary=1 then
                     Address           <= AddressSave;
                  else
                     Address(9 downto 0) <= AddressSave(9 downto 0);    
                  end if;
                  if DMAIn.Size=HSIZE8 then
                    AHBOut.HSIZE    <= HSIZE_BYTE;
                  elsif DMAIn.Size=HSIZE16 then
                    AHBOut.HSIZE    <= HSIZE_HWORD;
                  else
                    AHBOut.HSIZE    <= HSIZE_WORD;
                  end if;
               end if;
            end if;

            if    AHBIn.HREADY='1' and DataPhase='1' then
               -- sample AHB input data at end of data phase
               DMAOut.Data          <= AHBIn.HRDATA;
               DataPhase            <= '0';              -- data phase ends
               DMAOut.Ready         <= '1';
            else
               -- remove acknowledgement after one cycle
               DMAOut.Ready         <= '0';
            end if;

            --------------------------------------------------------------------
            -- AMBA AHB interface - address phase handling
            --------------------------------------------------------------------
            -- initialize data phase on AHB after previous address phase
            if AddressPhase='1' and AHBIn.HREADY='1' then
               DataPhase            <= '1';              -- data phase start
            end if;

            -- address generation on AHB
            if AHBIn.HREADY='1' then
               if AddressPhase='1' then
                  -- burst continuation, sequential transfer
                  AddressInc(conv_integer(DMAIn.Size)) := '1';
                  if boundary=1 then                     -- automatic boundary
                     Address                 <= Address + AddressInc;
                     AddressSave             <= Address;
                     if Address(9 downto 2)="11111111" then
                        BoundaryCrossing     := '1';
                        BoundaryPhase        <= '1';
                     end if;
                  else
                     Address(31 downto 10)   <= DMAIn.Address(31 downto 10);
                     Address( 9 downto  0)   <= Address(9 downto 0) + AddressInc;
                     AddressSave(9 downto 0) <= Address(9 downto 0);
                  end if;
                  if DMAIn.Size=HSIZE8 then
                    AHBOut.HSIZE          <= HSIZE_BYTE;
                  elsif DMAIn.Size=HSIZE16 then
                    AHBOut.HSIZE          <= HSIZE_HWORD;
                  else
                    AHBOut.HSIZE          <= HSIZE_WORD;
                  end if;
               elsif AHBInHGRANTx='1' and ActivePhase='0' and DMAIn.Request='1' then
                  -- start of burst,  non-sequential transfer
                  -- start of single, non-sequential transfer
                  if boundary=1 then                     -- automatic boundary
                     Address                 <= DMAIn.Address;
                     AddressSave             <= DMAIn.Address;
                     BoundaryCrossing        := '0';
                     BoundaryPhase           <= '0';
                  else
                     Address                 <= DMAIn.Address;
                     AddressSave(9 downto 0) <= DMAIn.Address(9 downto 0);
                  end if;
                  
                  if DMAIn.Size=HSIZE8 then
                    AHBOut.HSIZE          <= HSIZE_BYTE;
                  elsif DMAIn.Size=HSIZE16 then
                    AHBOut.HSIZE          <= HSIZE_HWORD;
                  else
                    AHBOut.HSIZE          <= HSIZE_WORD;
                  end if;
               end if;
            end if;

            -- address generation on AHB
            if AHBIn.HREADY='1' then
               IdlePhase            <= '0';              -- one clock cycle only
            end if;

            -- initialize address phase on AHB
            if AHBIn.HREADY='1' then
               -- granted the AHB bus
               if    AHBInHGRANTx='1' then
                  if    ReDataPhase='1' then
                     ReDataPhase       <= '0';
                     AddressPhase      <= '1';           -- address phase start
                     EarlyPhase        <= '0';
                     AHBOut.HTRANS     <= HTRANS_NONSEQ;
                     if SingleAcc='1' then
                        AHBOut.HBURST  <= HBURST_SINGLE;
                     else
                        AHBOut.HBURST  <= HBURST_INCR;
                     end if;
                     AHBOut.HWRITE     <= WriteAcc;

                  elsif ReAddrPhase='1' then
                     AddressPhase      <= '1';           -- address phase start
                     ReAddrPhase       <= '0';
                     if AddressPhase='1' then
                        if boundary=1 and (BoundaryCrossing='1' or BoundaryPhase='1') then
                           -- new bursts, non-sequential transfer
                           AHBOut.HTRANS <= HTRANS_NONSEQ;
                           BoundaryPhase <= '0';
                        else
                           -- burst continuation, sequential transfer
                           AHBOut.HTRANS <= HTRANS_SEQ;
                        end if;
                     else
                        AHBOut.HTRANS  <= HTRANS_NONSEQ;
                     end if;
                     EarlyPhase        <= '0';
                     if SingleAcc='1' then
                        AHBOut.HBURST  <= HBURST_SINGLE;
                     else
                        AHBOut.HBURST  <= HBURST_INCR;
                     end if;
                     AHBOut.HWRITE     <= WriteAcc;

                  elsif EarlyPhase='1' then
                     -- early terminated burst resumed
                     AddressPhase      <= '1';           -- address phase start
                     EarlyPhase        <= '0';
                     AHBOut.HTRANS     <= HTRANS_NONSEQ;
                     AHBOut.HBURST     <= HBURST_INCR;
                     AHBOut.HWRITE     <= WriteAcc;

                  elsif DMAIn.Request='1' and DMAIn.Burst='1' then
                     AddressPhase      <= '1';           -- address phase start
                     if ActivePhase='1' then
                        -- burst continuation, sequential transfer
                        if boundary=1 and (BoundaryCrossing='1' or BoundaryPhase='1') then
                           -- new bursts, non-sequential transfer
                           AHBOut.HTRANS <= HTRANS_NONSEQ;
                           BoundaryPhase <= '0';
                        else
                           -- burst continuation, sequential transfer
                           AHBOut.HTRANS <= HTRANS_SEQ;
                        end if;                        
                     else
                        -- start of burst, non-sequential transfer
                        AHBOut.HTRANS  <= HTRANS_NONSEQ;
                        if    DMAIn.Beat ="00" then
                           AHBOut.HBURST  <= HBURST_INCR;
                        elsif DMAIn.Beat ="01" then
                           AHBOut.HBURST  <= HBURST_INCR4;
                        elsif DMAIn.Beat ="10" then
                           AHBOut.HBURST  <= HBURST_INCR8;
                        else
                           AHBOut.HBURST  <= HBURST_INCR16;
                        end if;
                        AHBOut.HWRITE  <= DMAIn.Store;
                        ActivePhase    <= '1';
                        SingleAcc      <= '0';
                        WriteAcc       <= DMAIn.Store;
                     end if;

                  elsif DMAIn.Request='0' and DMAIn.Burst='1' and ActivePhase='1' then
                     -- burst in wait state
                     AddressPhase      <= '0';           -- no address phase
                     AHBOut.HTRANS     <= HTRANS_BUSY;

                  elsif DMAIn.Request='1' and DMAIn.Burst='0' then
                     -- start of single, non-sequential transfer
                     AddressPhase      <= '1';           -- address phase start
                     ActivePhase       <= '1';
                     SingleAcc         <= '1';
                     WriteAcc          <= DMAIn.Store;
                     AHBOut.HTRANS     <= HTRANS_NONSEQ;
                     AHBOut.HBURST     <= HBURST_SINGLE;
                     AHBOut.HWRITE     <= DMAIn.Store;
                  else
                     -- drive idle transfer as default master
                     -- the next cycle will start the address phase
                     AddressPhase      <= '0';              -- no useful address
                     AHBOut.HTRANS     <= HTRANS_IDLE;
                     AHBOut.HBURST     <= HBURST_SINGLE;
                     AHBOut.HWRITE     <= '0';
                  end if;

               -- not granted the AHB bus, but early burst termination
               elsif (DMAIn.Request='1' or DMAIn.Burst='1') and ActivePhase='1'then
                  -- must restart a burst transfer since grant removed
                  AddressPhase      <= '0';              -- no address phase
                  EarlyPhase        <= '1';
                  AHBOut.HTRANS     <= HTRANS_IDLE;
                  AHBOut.HBURST     <= HBURST_SINGLE;
                  AHBOut.HWRITE     <= '0';

               -- not granted the AHB bus
               else
                  -- drive idle transfer as default master
                  -- the next cycle will start the address phase
                  AddressPhase      <= '0';              -- no useful address
                  AHBOut.HTRANS     <= HTRANS_IDLE;
                  AHBOut.HBURST     <= HBURST_SINGLE;
                  AHBOut.HWRITE     <= '0';
               end if;

            elsif AHBIn.HREADY='0' and DataPhase='1' then
               if AHBIN.HRESP=HRESP_ERROR or
                  AHBIN.HRESP=HRESP_SPLIT or
                  AHBIN.HRESP=HRESP_RETRY then
                  -- drive idle transfer due to error, retry or split
                  -- the next cycle will start the address phase
                  AddressPhase      <= '0';              -- no useful address
                  IdlePhase         <= '1';
                  AHBOut.HTRANS     <= HTRANS_IDLE;
                  AHBOut.HBURST     <= HBURST_SINGLE;
                  AHBOut.HWRITE     <= '0';
               end if;
            end if;
          end if;

         if AHBIn.HREADY='1' then                        -- delay one phase
            DelDataPhase         <= ReDataPhase;
            DelAddrPhase         <= ReAddrPhase;
         end if;

         -- temporary variables cleared
         BoundaryCrossing        := '0';
         AddressInc              := (others => '0');
      else
         null;
      end if;
   end process AHBMaster;
end architecture RTL; --======================================================--

