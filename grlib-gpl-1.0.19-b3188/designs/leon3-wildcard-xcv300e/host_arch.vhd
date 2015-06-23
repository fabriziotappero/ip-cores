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
-- Design unit  : Host emulation (architecture declarations)
--
-- File name    : host_arch.vhd
--
-- Purpose      : Host emulator for test bench
--
-- Library      : System
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

--============================== Architecture ================================--

library  Std;
use      Std.TextIO.all;

library  IEEE;
use      IEEE.Std_Logic_1164.all;
use      IEEE.Std_Logic_Arith.all;
use      IEEE.Std_Logic_TextIO.all;

library  PE_Lib;
use      PE_Lib.PE_Package.all;

library  SYSTEM;
use      SYSTEM.Host_Package.all;

architecture Validate of Host is
   -----------------------------------------------------------------------------
   -- Registers
   -----------------------------------------------------------------------------
   constant cStat:      DWORD := 16#00000000#;
   constant cCtrl:      DWORD := 16#00000004#;
   constant cSize:      DWORD := 16#00000008#;
   constant cVer:       DWORD := 16#0000000c#;
   constant cRAddr:     DWORD := 16#00000010#;
   constant cWAddr:     DWORD := 16#00000020#;
   constant cRData:     DWORD := 16#00000200#;
   constant cWData:     DWORD := 16#00000300#;

   constant cSSRAML:    DWORD := 16#40000000#;
   constant cSSRAMR:    DWORD := 16#60000000#;
   constant cAHBRam:    DWORD := 16#a0000000#;

begin
   -----------------------------------------------------------------------------
   --
   -----------------------------------------------------------------------------
   Main: process
      --------------------------------------------------------------------------
      --
      --------------------------------------------------------------------------
      variable device:              WC_DeviceNum   := 0;
      variable enable:              Boolean        := False;
      variable burstLength:         Integer;
      variable fClkFreq:            Float          := 10.0;
      variable dwordOffset:         DWORD;
      variable dwordCount:          DWORD;
      variable regData:             DWORD_array (0 to 255);
      variable memData:             DWORD_array (0 to 255);
      variable Done:                Boolean;
      variable timeoutMilliSeconds: DWORD;
      variable data:                DWORD;
      variable dv:                  DWORD_array (0 to 255);
      variable cv:                  DWORD_array (0 to 255);

      variable ready:               Integer;

      variable L:                   Line;

      procedure wcmd (a: in DWORD; d: in DWORD) is
      begin
         Write(L, Now, Right, 15);
         Write(L, String'(" : Write: addr = "));
         HWrite(L, Conv_Std_Logic_Vector(a, 32));
         Write(L, String'(" : data = "));
         HWrite(L, Conv_Std_Logic_Vector(d, 32));
         WriteLine(Output, L);

         dwordOffset       := cWData/4;
         dwordCount        := 1;
         regData(0)        := d;
         WC_PeRegWrite(Cmd_Req,
                       Cmd_Ack,
                       device,
                       dwordOffset,
                       dwordCount,
                       regData);

         dwordOffset       := cSize/4;
         dwordCount        := 1;
         regData(0)        := 0;
         WC_PeRegWrite(Cmd_Req,
                       Cmd_Ack,
                       device,
                       dwordOffset,
                       dwordCount,
                       regData);

         dwordOffset       := cWAddr/4;
         dwordCount        := 1;
         regData(0)        := a;
         WC_PeRegWrite(Cmd_Req,
                       Cmd_Ack,
                       device,
                       dwordOffset,
                       dwordCount,
                       regData);

         ready := 0;
         while ready=0 loop
            dwordOffset       := cStat/4;
            dwordCount        := 1;
            WC_PeRegRead(Cmd_Req,
                         Cmd_Ack,
                         device,
                         dwordOffset,
                         dwordCount,
                         regData);
            ready := regData(0) mod 2;
         end loop;
      end procedure;

      procedure rcmd (a: in DWORD; d: out DWORD) is
      begin
         dwordOffset       := cSize/4;
         dwordCount        := 1;
         regData(0)        := 0;
         WC_PeRegWrite(Cmd_Req,
                       Cmd_Ack,
                       device,
                       dwordOffset,
                       dwordCount,
                       regData);

         dwordOffset       := cRAddr/4;
         dwordCount        := 1;
         regData(0)        := a;
         WC_PeRegWrite(Cmd_Req,
                       Cmd_Ack,
                       device,
                       dwordOffset,
                       dwordCount,
                       regData);

         ready := 0;
         while ready=0 loop
            dwordOffset       := cStat/4;
            dwordCount        := 1;
            WC_PeRegRead(Cmd_Req,
                         Cmd_Ack,
                         device,
                         dwordOffset,
                         dwordCount,
                         regData);
            ready := regData(0) mod 2;
         end loop;

         dwordOffset       := cRData/4;
         dwordCount        := 1;
         WC_PeRegRead(Cmd_Req,
                      Cmd_Ack,
                      device,
                      dwordOffset,
                      dwordCount,
                      regData);
         d :=  regData(0);

         Write(L, Now, Right, 15);
         Write(L, String'(" : Read:  addr = "));
         HWrite(L, Conv_Std_Logic_Vector(a, 32));
         Write(L, String'(" : data = "));
         HWrite(L, Conv_Std_Logic_Vector(regData(0), 32));
         WriteLine(Output, L);
      end procedure;



      procedure wcmd (a: in DWORD; d: in DWORD_array) is
      begin
         for i in 0 to d'Length-1 loop
            Write(L, Now, Right, 15);
            Write(L, String'(" : Write: addr = "));
            HWrite(L, Conv_Std_Logic_Vector(a+i*4, 32));
            Write(L, String'(" : data = "));
            HWrite(L, Conv_Std_Logic_Vector(d(i), 32));
            WriteLine(Output, L);
         end loop;

         dwordOffset       := cWData/4;
         dwordCount        := d'Length;
         regData(0 to d'length-1) := d;
         WC_PeRegWrite(Cmd_Req,
                       Cmd_Ack,
                       device,
                       dwordOffset,
                       dwordCount,
                       regData);

         dwordOffset       := cSize/4;
         dwordCount        := 1;
         regData(0)        := d'Length;
         WC_PeRegWrite(Cmd_Req,
                       Cmd_Ack,
                       device,
                       dwordOffset,
                       dwordCount,
                       regData);

         dwordOffset       := cWAddr/4;
         dwordCount        := 1;
         regData(0)        := a;
         WC_PeRegWrite(Cmd_Req,
                       Cmd_Ack,
                       device,
                       dwordOffset,
                       dwordCount,
                       regData);

         ready := 0;
         while ready=0 loop
            dwordOffset       := cStat/4;
            dwordCount        := 1;
            WC_PeRegRead(Cmd_Req,
                         Cmd_Ack,
                         device,
                         dwordOffset,
                         dwordCount,
                         regData);
            ready := regData(0) mod 2;
         end loop;
      end procedure;

      procedure rcmd (a: in DWORD; d: out DWORD_array) is
      begin

         dwordOffset       := cSize/4;
         dwordCount        := 1;
         regData(0)        := d'Length;
         WC_PeRegWrite(Cmd_Req,
                       Cmd_Ack,
                       device,
                       dwordOffset,
                       dwordCount,
                       regData);


         dwordOffset       := cRAddr/4;
         dwordCount        := 1;
         regData(0)        := a;
         WC_PeRegWrite(Cmd_Req,
                       Cmd_Ack,
                       device,
                       dwordOffset,
                       dwordCount,
                       regData);

         ready := 0;

         while ready=0 loop
            dwordOffset       := cStat/4;
            dwordCount        := 1;
            WC_PeRegRead(Cmd_Req,
                         Cmd_Ack,
                         device,
                         dwordOffset,
                         dwordCount,
                         regData);
            ready := regData(0) mod 2;
         end loop;

         dwordOffset       := cRData/4;
         dwordCount        := d'Length;
         WC_PeRegRead(Cmd_Req,
                      Cmd_Ack,
                      device,
                      dwordOffset,
                      dwordCount,
                      regData);
         d :=  regData(0 to d'Length-1);
         for i in 0 to d'Length-1 loop
            Write(L, Now, Right, 15);
            Write(L, String'(" : Read:  addr = "));
            HWrite(L, Conv_Std_Logic_Vector(a+i*4, 32));
            Write(L, String'(" : data = "));
            HWrite(L, Conv_Std_Logic_Vector(regData(i), 32));
            WriteLine(Output, L);
         end loop;
      end procedure;

      variable burst:   Integer := 0;
   begin

      --------------------------------------------------------------------------
      -- At first, deassert the command request signal
      --------------------------------------------------------------------------
      Cmd_Req        <= False;

      --------------------------------------------------------------------------
      -- We are using device 0
      --------------------------------------------------------------------------
      device         := 0;

      --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      --
      -- Step 1: Initialize the simulated CardBus controller.
      --
      --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

      --------------------------------------------------------------------------
      -- Enable the K_Clk (CardBus/LAD-bus clock) to the device
      --------------------------------------------------------------------------
      enable         := True;
      Debug_Enable_K_Clk(Cmd_Req,
                         Cmd_Ack,
                         device,
                         enable);

      --------------------------------------------------------------------------
      --  Enable LAD bus bursts to/from the device
      --------------------------------------------------------------------------
      enable         := True;
      Debug_Enable_Burst(Cmd_Req,
                         Cmd_Ack,
                         device,
                         enable);

      --------------------------------------------------------------------------
      -- Set the length of read bursts from the device
      --------------------------------------------------------------------------
      burstLength    := 4;
      Debug_Set_Read_Burst_Length(Cmd_Req,
                                  Cmd_Ack,
                                  device,
                                  burstLength);

      --------------------------------------------------------------------------
      -- Set the length of write bursts from the device
      --------------------------------------------------------------------------
      burstLength    := 32;
      Debug_Set_Write_Burst_Length(Cmd_Req,
                                    Cmd_Ack,
                                    device,
                                    burstLength);

      --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      --
      -- Step 2: Configure the memory clock and processing element clock.
      --
      --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

      --------------------------------------------------------------------------
      --  Set the F_Clk frequency (which will set the M_Clk and P_Clk
      --  frequencies to F_CLK and F_CLK/2, respectively)
      --------------------------------------------------------------------------
      fClkFreq       := 40.0;
      WC_ClkSetFrequency(Cmd_Req,
                         Cmd_Ack,
                         device,
                         fClkFreq);

      --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      --
      -- Step 3: Reset the PE, clear any PE interrupts, and enable PE interrupts
      --
      --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

      --------------------------------------------------------------------------
      -- Set up the PE's interrupt and toggle the reset line
      --------------------------------------------------------------------------
      enable         := True;
      WC_PeReset(Cmd_Req,
                 Cmd_Ack,
                 device,
                 enable);

      WC_IntReset(Cmd_Req,
                   Cmd_Ack,
                   device);

      enable         := False;
      WC_IntEnable(Cmd_Req,
                   Cmd_Ack,
                   device,
                   enable);
      wait for 5 us;

      enable         := False;
      WC_PeReset(Cmd_Req,
                  Cmd_Ack,
                  device,
                  enable);

      wait for 20 us;

      report "======== PE is now reset and the clocks are running ========"
         severity Note;

      --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      --
      --
      --
      --@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      Write(L, String'(""));
      WriteLine(Output, L);
      WriteLine(Output, L);


      WriteLine(Output, L);
      Write(L, Now, Right, 15);
      Write(L, String'(" : Check burst capability."));
      WriteLine(Output, L);
      dwordOffset       := cVer/4;
      dwordCount        := 1;
      WC_PeRegRead(Cmd_Req,
                   Cmd_Ack,
                   device,
                   dwordOffset,
                   dwordCount,
                   regData);

      Write(L, Now, Right, 15);
      Write(L, String'(" : Read:  addr = "));
      HWrite(L, Conv_Std_Logic_Vector(cVer, 32));
      Write(L, String'(" : data = "));
      HWrite(L, Conv_Std_Logic_Vector(regData(0), 32));
      WriteLine(Output, L);
      burst := regData(0) / 16;

      for i in 0 to 255 loop dv(i) := i; end loop;

      if burst > 1 then
         WriteLine(Output, L);
         Write(L, Now, Right, 15);
         Write(L, String'(" : Test left memory, burst access."));
         WriteLine(Output, L);

         wcmd(cSSRAML, dv(0 to burst-1));
         rcmd(cSSRAML, cv(0 to burst-1));

         for i in 0 to burst-1 loop
            if cv(i) /= dv(i) then
               Write(L, Now, Right, 15);
               Write(L, String'(" : Error:  read = "));
               HWrite(L, Conv_Std_Logic_Vector(cv(i), 32));
               Write(L, String'(" : expected = "));
               HWrite(L, Conv_Std_Logic_Vector(dv(i), 32));
               WriteLine(Output, L);
            end if;
         end loop;
      end if;

      WriteLine(Output, L);
      Write(L, Now, Right, 15);
      Write(L, String'(" : Test on-chip memory, single access."));
      WriteLine(Output, L);
      wcmd(cAHBRam, 16#12345678#);
      rcmd(cAHBRam, data);

      WriteLine(Output, L);
      Write(L, Now, Right, 15);
      Write(L, String'(" : Test left memory, single burst."));
      WriteLine(Output, L);
      wcmd(cSSRAML, dv(255));
      rcmd(cSSRAML, cv(255));

      WriteLine(Output, L);
      Write(L, Now, Right, 15);
      Write(L, String'(" : Test left memory, single access."));
      WriteLine(Output, L);
      wcmd(cSSRAML, 16#abcd0001#);
      rcmd(cSSRAML, data);

      WriteLine(Output, L);
      Write(L, Now, Right, 15);
      Write(L, String'(" : Test right memory, single access."));
      WriteLine(Output, L);
      wcmd(cSSRAMR, 16#abcd0002#);
      rcmd(cSSRAMR, data);

      WriteLine(Output, L);
      WriteLine(Output, L);
      wait for 10 us;
      --------------------------------------------------------------------------
      -- End of the simulated host program
      --------------------------------------------------------------------------
      report "End of test"
         severity Failure;

      wait;
   end process Main;
end architecture Validate; --=================================================--
