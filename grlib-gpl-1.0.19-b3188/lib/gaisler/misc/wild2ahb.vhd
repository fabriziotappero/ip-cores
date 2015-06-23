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
-- Design unit  : WildCard CardBus to AMBA interface (entity and architecture)
--
-- File name    : wild2ahb.vhd
--
-- Purpose      : WildCard CardBus to AMBA interface
--
-- Library      : gaisler
--
-- Authors      : Mr Sandi Alexander Habinc
--                Gaisler Research
--
-- Contact      : mailto:support@gaisler.com
--                http://www.gaisler.com
--
-- Disclaimer   : All information is provided "as is", there is no warranty that
--                the information is correct or suitable for any purpose,
--                neither implicit nor explicit.
--============================================================================--

library  IEEE;
use      IEEE.Std_Logic_1164.all;

library  grlib;
use      grlib.amba.all;

library  gaisler;
use      gaisler.wild.all;

entity Wild2AHB is
   generic (
      hindex:        in    Integer := 0;
      burst:         in    Integer := 0;
      syncrst:       in    Integer := 0);
   port (
      rstkn:         in    Std_ULogic;
      clkk:          in    Std_ULogic;

      rstfn:         in    Std_ULogic;
      clkf:          in    Std_ULogic;

      ahbmi:         in    AHB_Mst_In_Type;
      ahbmo:         out   AHB_Mst_Out_Type;

      ladi:          in    LAD_In_Type;
      lado:          out   LAD_Out_Type);
end entity Wild2AHB; --=======================================================--

library  IEEE;
use      IEEE.Std_Logic_1164.all;

library  grlib;
use      grlib.amba.all;
use      grlib.stdlib.all;
use      grlib.stdlib.all;
use      grlib.devices.all;
use      grlib.dma2ahb_package.all;

architecture RTL of Wild2AHB is
   -----------------------------------------------------------------------------
   -- configuration constants
   -----------------------------------------------------------------------------
   constant REVISION:         Integer := 0;

   -----------------------------------------------------------------------------
   -- WildCard revision constants
   -----------------------------------------------------------------------------
   constant PE_CORE_MAJOR_VERSION:  Std_Logic_Vector(7 downto 0) := x"01";
   constant PE_CORE_MINOR_VERSION:  Std_Logic_Vector(7 downto 0) := x"03";

   constant PE_CORE_VERSION:        Std_Logic_Vector(31 downto 0) :=
               x"0000" & PE_CORE_MAJOR_VERSION & PE_CORE_MINOR_VERSION;

   -----------------------------------------------------------------------------
   -- general
   -----------------------------------------------------------------------------
   signal   vcc, gnd:         Std_Logic_Vector(7 downto 0);

   -----------------------------------------------------------------------------
   -- memory buffer type
   -----------------------------------------------------------------------------
   constant bits:             Integer := burst;
   constant depth:            Integer := 2**bits;
   subtype  memory_type is    Std_Logic_Vector(31 downto 0);
   type     memory_array is   array (0 to depth-1) of memory_type;

   -----------------------------------------------------------------------------
   -- registers - Main clock domain, X MHz, Clk_F
   -----------------------------------------------------------------------------
   type register_type is record
      -- ahb/dma handling
      dmai:             dma_in_type;

      -- ctrl
      error:            Std_ULogic;
      ready:            Std_ULogic;
      ongoing:          Std_ULogic;

      cntr:             Integer range 0 to depth;
      index:            Integer range 0 to depth-1;
      rarray:           memory_array;

      -- sync
      active_1st:       Std_ULogic;
      active_2nd:       Std_ULogic;
      active:           Std_ULogic;
   end record;

   signal   r, rin:     register_type;

   -----------------------------------------------------------------------------
   -- data types - PCI clock domain, 33 MHz, Clk_K
   -----------------------------------------------------------------------------
   type ctrl_type is record
      warray:           memory_array;
      wsize:            Integer range 0 to depth;

      wdata:            Std_Logic_Vector(31 downto 0);
      waddr:            Std_Logic_Vector(31 downto 0);
      store:            Std_ULogic;

      addr:             Std_Logic_Vector(16 downto 0);
      active:           Std_ULogic;
      fetch:            Std_ULogic;

      error:            Std_ULogic;
      error_1st:        Std_ULogic;
      error_2nd:        Std_ULogic;

      ready:            Std_ULogic;
      ready_1st:        Std_ULogic;
      ready_2nd:        Std_ULogic;
   end record;

   -----------------------------------------------------------------------------
   -- registers - PCI clock domain, 33 MHz, Clk_K
   -----------------------------------------------------------------------------
   type register_lad_type is record
      -- input
      ladi:             LAD_In_Type;

      -- lad access control
      ctrl:             ctrl_type;
   end record;

   signal   rk, rkin:   register_lad_type;

   -----------------------------------------------------------------------------
   -- local unregistered signals
   -----------------------------------------------------------------------------
   signal   dmao:       dma_out_type;                    -- dma output
   signal   dmai:       dma_in_type;                     -- dma input

   -----------------------------------------------------------------------------
   -- Reserved space    : 0x00008000 - 0x0000FFFC
   -- User space        : 0x00010000 - 0x0001FFFC
   -- Version register  : 0x00008000 - (decode bits 15 and 14 only)
   -----------------------------------------------------------------------------
   constant cUser:      Std_Logic_Vector(16 downto 15) := "10";
   constant cVersion:   Std_Logic_Vector(16 downto 14) := "010";
   constant cReserved:  Std_Logic_Vector(16 downto 14) := "011";

   -----------------------------------------------------------------------------
   -- Register addresses:
   -----------------------------------------------------------------------------
   constant cStat:      Std_Logic_Vector(7 downto 0) := X"00";
   constant cCtrl:      Std_Logic_Vector(7 downto 0) := X"04";
   constant cSize:      Std_Logic_Vector(7 downto 0) := X"08";
   constant cVer:       Std_Logic_Vector(7 downto 0) := X"0C";
   constant cRAddr:     Std_Logic_Vector(7 downto 0) := X"10";
   constant cWAddr:     Std_Logic_Vector(7 downto 0) := X"20";
   constant cRData:     Std_Logic_Vector(9 downto 0) := "10" & X"00";
   constant cWData:     Std_Logic_Vector(9 downto 0) := "11" & X"00";

   -- 00 0000 00--
   -- 00 0000 01--
   -- 00 0000 10--
   -- 00 0000 11--
   -- 00 0001 ----
   -- 00 0010 ----
   -- 10 ---- ----
   -- 11 ---- ----

   -- Read(Addr, Ptr)
   --    -> transfer read address (command) - cRAddr
   --    -> loop
   --    ->    check status - cStat
   --    -> retreive read data - cRData
   --
   -- WriteAddr(Addr, Ptr)
   --    -> transfer write data - cWData
   --    -> transfer write address (command) - cWAddr
   --    -> loop
   --    ->    check status - cStat

   -----------------------------------------------------------------------------
   -- Status register:
   -----------------------------------------------------------------------------
   -- Bit:     Name:       Mode:    Remark:
   -----------------------------------------------------------------------------
   -- 2        Error       r/w      AMBA error
   -- 1        Active      r        Access on-going
   -- 0        Ready       r/w      Access completed
   -----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Data output
   -----------------------------------------------------------------------------
   signal      Addr_Data, iAddr_Data:           Std_Logic_Vector(31 downto 0);
   signal      Addr_Data_OE_n, iAddr_Data_OE_n: Std_Logic_Vector(31 downto 0);
   signal      Addr_Data_In:                    Std_Logic_Vector(31 downto 0);

   attribute   syn_preserve : Boolean;
   attribute   syn_preserve of Addr_Data :      signal is True;
   attribute   syn_preserve of Addr_Data_OE_n : signal is True;
   attribute   syn_preserve of Addr_Data_In :   signal is True;

begin

   -----------------------------------------------------------------------------
   -- combinatorial logic
   -----------------------------------------------------------------------------
   comb: process(rstfn, rstkn, r, rk, ladi, dmao, Addr_Data_In)
      variable v:             register_type;
      variable vk:            register_lad_type;
   begin
      --------------------------------------------------------------------------
      -- local variable copy of register signal
      v                    := r;
      vk                   := rk;

      --------------------------------------------------------------------------
      -- synchronization of external inputs
      vk.ladi              := ladi;

      --------------------------------------------------------------------------
      -- synchronization internally
      v.active_1st         := rk.ctrl.active;
      v.active_2nd         := r.active_1st;
      if r.active_1st='1' and r.active_2nd='0' then
         v.active          := '1';
      end if;
      if r.active_1st='0' and r.active_2nd='0' then
         v.active          := '0';
      end if;

      vk.ctrl.error_1st    := r.error;
      vk.ctrl.error_2nd    := rk.ctrl.error_1st;
      if rk.ctrl.error_1st='1' and rk.ctrl.error_2nd='0' then
         vk.ctrl.error     := '1';
      end if;

      vk.ctrl.ready_1st    := r.ready;
      vk.ctrl.ready_2nd    := rk.ctrl.ready_1st;
      if rk.ctrl.ready_1st='1' and not rk.ctrl.ready_2nd='0' then
         vk.ctrl.ready     := '1';
      end if;

      --------------------------------------------------------------------------
      -- lad interface
      --------------------------------------------------------------------------
      -- address phase
      if rk.ladi.AS_N='0' and rk.ladi.CS_N='0' then
         if rk.ladi.Reg_N='0' then
            -- register space
            if rk.ladi.WR_N='0' then
               -- write access
               vk.ctrl.store  := '1';
            else
               -- read access
               vk.ctrl.store  := '0';
            end if;
         else
            -- no access
            vk.ctrl.store     := '0';
         end if;
         vk.ctrl.addr         := Addr_Data_In(16 downto 0);
      end if;

      -- data phase - write access
      if rk.ladi.DS_N='0' and rk.ladi.CS_N='0' then
         if rk.ctrl.store='1' then
            if    rk.ctrl.addr(9 downto 8)=cWData(9 downto 8) and (burst = 0) then
               vk.ctrl.wdata     := Addr_Data_In;
            elsif rk.ctrl.addr(9 downto 8)=cWData(9 downto 8) and (burst /= 0) then
               vk.ctrl.warray(Conv_Integer(rk.ctrl.addr(bits+1 downto 2))):= Addr_Data_In;
            elsif rk.ctrl.addr(7 downto 0)=cStat then
               vk.ctrl.error     := '0';
               vk.ctrl.ready     := '0';
            elsif rk.ctrl.addr(7 downto 0)=cRAddr then
               vk.ctrl.waddr     := Addr_Data_In;
               vk.ctrl.active    := '1';
               vk.ctrl.fetch     := '1';
            elsif rk.ctrl.addr(7 downto 0)=cWAddr then
               vk.ctrl.waddr     := Addr_Data_In;
               vk.ctrl.active    := '1';
               vk.ctrl.fetch     := '0';
            elsif rk.ctrl.addr(7 downto 0)=cSize and (burst /= 0) then
               vk.ctrl.wsize     := Conv_Integer(Addr_Data_In);
            end if;
         end if;
      end if;

      if rk.ladi.DS_N='0' and rk.ladi.CS_N='0' and (burst /= 0) then
         if rk.ladi.Reg_N='0' then
            -- register space
            -- address increment
            vk.ctrl.addr(bits+1 downto 2) := rk.ctrl.addr(bits+1 downto 2) + 1;
         end if;
      end if;

      -- data phase - read access
      iAddr_Data           <= (others => '0');
      if    rk.ctrl.addr(16 downto 14)=cVersion then
         iAddr_Data        <= PE_CORE_VERSION;
      elsif rk.ctrl.addr(9 downto 8)=cRData(9 downto 8) and (burst = 0) then
         iAddr_Data        <= dmao.Data;
      elsif rk.ctrl.addr(9 downto 8)=cRData(9 downto 8) and (burst /= 0) then
         iAddr_Data        <= r.rarray(Conv_Integer(vk.ctrl.addr(bits+1 downto 2)));
      elsif rk.ctrl.addr(7 downto 0)=cStat then
         iAddr_Data(2)     <= rk.ctrl.error;
         iAddr_Data(1)     <= rk.ctrl.active;
         iAddr_Data(0)     <= rk.ctrl.ready;
      elsif rk.ctrl.addr(7 downto 0)=cVer then
         iAddr_Data(11 downto 0) <= Conv_Std_Logic_Vector(depth, 8) & Conv_Std_Logic_Vector(REVISION, 4);
      end if;

      if rk.ctrl.ready_1st='1' and not rk.ctrl.ready_2nd='0' then
         vk.ctrl.active       := '0';
      end if;

      -- combinatorial output enable control
      if rk.ladi.CS_N='0' and rk.ladi.WR_N='1' then
         iAddr_Data_OE_n <= (others => '0');
      else
         iAddr_Data_OE_n <= (others => '1');
      end if;

      --------------------------------------------------------------------------
      -- dma interface
      --------------------------------------------------------------------------
      if r.active='1' and r.ongoing='0' and r.ready='0' then
         v.ongoing            := '1';
         if (burst /= 0) then
            if rk.ctrl.fetch='1' then
               v.index        := 0;
            else
               v.index        := 1;
            end if;
            if (rk.ctrl.wsize > 0) then
               v.cntr         := rk.ctrl.wsize-1;
            end if;
            v.dmai.Data       := rk.ctrl.warray(0);
         end if;
         if (burst /= 0) and (rk.ctrl.wsize > 1) then
            v.dmai.Burst      := '1';
         else
            v.dmai.Burst      := '0';
         end if;
         if rk.ctrl.fetch='1' then
            v.dmai.Store      := '0';
         else
            v.dmai.Store      := '1';
         end if;
         v.dmai.Request       := '1';

      elsif r.ongoing='1' then
         if dmao.Grant = '1' then
            if (burst /= 0) and r.cntr > 0 then
               v.cntr      := r.cntr - 1;
            else
               v.dmai.Request := '0';
               v.dmai.Burst   := '0';
            end if;
         end if;

         if rk.ctrl.fetch='1' then
            if dmao.Ready='1' then
               if (burst /= 0) then
                  v.rarray(r.index) := dmao.Data;
               end if;
               if (burst /= 0) and (r.index < rk.ctrl.wsize-1) and (rk.ctrl.wsize > 0) then
                  v.index     := r.index + 1;
               else
                  v.ready     := '1';
                  v.ongoing   := '0';
               end if;
            end if;
         else
            if dmao.OKAY='1' then
               if (burst /= 0) then
                  v.dmai.Data := rk.ctrl.warray(r.index);
               end if;
               if (burst /= 0) and (r.index < rk.ctrl.wsize-1) and (rk.ctrl.wsize > 0) then
                  v.index     := r.index + 1;
               else
                  v.ready     := '1';
                  v.ongoing   := '0';
                  v.dmai.Store:= '0';
               end if;
            end if;
         end if;
         if dmao.Fault='1' then
            v.error           := '1';
            v.ready           := '1';
            v.ongoing         := '0';
            v.dmai.Burst      := '0';
            v.dmai.Store      := '0';
            v.dmai.Request    := '0';
         end if;

      elsif r.active='0' and r.ongoing='0' and (r.ready='1') then
         v.ready              := '0';
      else
         v.dmai.Burst         := '0';
         v.dmai.Request       := '0';
         v.dmai.Store         := '0';
      end if;


      --======================================================================--
      -- Synchronous reset operation
      --------------------------------------------------------------------------
      if rstfn = '0' then
         v.dmai.Request          := '0';
         v.dmai.Store            := '0';

         v.error                 := '0';
         v.ready                 := '0';
         v.ongoing               := '0';
         if (burst /= 0) then
            v.cntr               := 0;
            v.index              := 0;
            v.dmai.Burst         := '0';
         end if;

         v.active_1st            := '0';
         v.active_2nd            := '0';
         v.active                := '0';
      end if;

      if rstkn = '0' then
         vk.ladi.WR_n            := '1';
         vk.ladi.CS_n            := '1';
         vk.ladi.AS_n            := '1';
         vk.ladi.Reg_n           := '1';

         vk.ctrl.addr            := (others => '0');
         vk.ctrl.store           := '0';
         vk.ctrl.active          := '0';
         vk.ctrl.fetch           := '0';
         if (burst /= 0) then
            vk.ctrl.wsize        := 0;
         end if;

         vk.ctrl.error           := '0';
         vk.ctrl.error_1st       := '0';
         vk.ctrl.error_2nd       := '0';
         vk.ctrl.ready           := '0';
         vk.ctrl.ready_1st       := '0';
         vk.ctrl.ready_2nd       := '0';

         vk.ctrl.waddr           := (others => '0');
         vk.ctrl.wdata           := (others => '0');
      end if;

      --------------------------------------------------------------------------
      -- variable to signal assigment
      rin               <= v;
      rkin              <= vk;
   end process comb;

   -----------------------------------------------------------------------------
   -- general
   -----------------------------------------------------------------------------
   vcc <= (others => '1');
   gnd <= (others => '0');

   -----------------------------------------------------------------------------
   -- output ports - non-registered signals
   -----------------------------------------------------------------------------
   lado.Addr_Data          <= Addr_Data;
   lado.Addr_Data_OE_n     <= Addr_Data_OE_n;

   -----------------------------------------------------------------------------
   -- output ports  - fixed signals
   -----------------------------------------------------------------------------
   lado.Ack_n              <= vcc(0);
   lado.Int_Req_n          <= vcc(0);
   lado.DMA_0_Data_OK_n    <= vcc(0);
   lado.DMA_0_Burst_OK     <= gnd(0);
   lado.DMA_1_Data_OK_n    <= vcc(0);
   lado.DMA_1_Burst_OK     <= gnd(0);
   lado.Reg_Data_OK_n      <= gnd(0);
   lado.Reg_Burst_OK       <= vcc(0);
   lado.Force_K_Clk_n      <= gnd(0);
   lado.Reserved           <= gnd(0);

   -----------------------------------------------------------------------------
   -- registered signals
   -----------------------------------------------------------------------------
   dmai.Reset              <= '0';
   dmai.Request            <= r.dmai.Request;
   dmai.Burst              <= r.dmai.Burst when (burst /= 0) else '0';
   dmai.Beat               <= HINCR;
   dmai.Store              <= r.dmai.Store;
   dmai.Data               <= r.dmai.Data when (burst /= 0) else rk.ctrl.wdata;
   dmai.Address            <= rk.ctrl.waddr;
   dmai.Size               <= HSIZE32;

   -----------------------------------------------------------------------------
   -- registers, Main clock domain, X MHz, Clk_F
   -----------------------------------------------------------------------------
   regs: process(clkf, rstfn)
   begin
      if Rising_Edge(clkf) then
         r              <= rin;
      end if;
   end process regs;

   -----------------------------------------------------------------------------
   -- registers, PCI clock domain, 33 MHz, Clk_K
   -----------------------------------------------------------------------------
   regs_falling: process(clkk, rstkn)
   begin
      if Falling_Edge(clkk) then
         rk             <= rkin;
      end if;
   end process regs_falling;

   -- explicit flip-flops for LAD data-address signals for placement in IOB
   regs_explicit: process(clkk, rstkn)
   begin
      if rstkn='0' then
         Addr_Data      <= (others => '1');
         Addr_Data_OE_N <= (others => '1');
         Addr_Data_In   <= (others => '1');
      elsif Falling_Edge(clkk) then
         Addr_Data      <= iAddr_Data;
         Addr_Data_OE_N <= iAddr_Data_OE_N;
         Addr_Data_In   <= ladi.Addr_Data;
      end if;
   end process regs_explicit;

   ---------------------------------------------------------------------------
   -- amba ahb master with dma
   ---------------------------------------------------------------------------
   dma2ahb_unit: dma2ahb
      generic map(
         hindex            => hindex,
         vendorid          => vendor_gaisler,
         deviceid          => gaisler_wild2ahb,
         version           => REVISION,
         syncrst           => syncrst)
      port map(
         hclk              => clkf,
         hresetn           => rstfn,
         dmain             => dmai,
         dmaout            => dmao,
         ahbin             => ahbmi,
         ahbout            => ahbmo);

end architecture RTL; --======================================================--