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
-------------------------------------------------------------------------------
-- Entity: i2cslv
-- File:   i2cslv.vhd
-- Author: Jan Andersson - Gaisler Research
--         jan@gaisler.com
--
-- Description: Simple I2C-slave with AMBA APB interface
--
-- Documentation of generics:
--
-- [hardaddr]
-- If this generic is set to 1 the core uses i2caddr as the hard coded address.
-- If hardaddr is set to 0 the core's address can be changed via the SLVADDR
-- register.
--
-- [tenbit]
-- Support for ten bit addresses.
--
-- [i2caddr]
-- The slave's (initial) i2c address.
--
-- [oepol]
-- Output enable polarity
--
-- The slave has four different modes operation. The mode is defined by the
-- value of the bits RMODE and TMODE.
-- RMODE TMODE   I2CSLAVE Mode
--   0     0          0
--   0     1          1
--   1     0          2
--   1     1          3
--
-- RMODE 0:
-- The slave accepts one byte and NAKs all other transfers until software has
-- acknowledged the received byte.
-- RMODE 1:
-- The slave accepts one byte and keeps SCL low until software has acknowledged
-- the received byte
-- TMODE 0:
-- The slave transmits the same byte to all if the master requests more than
-- one byte in the transfer. The slave then NAKs all read requests unless the
-- Transmit Always Valid (TAV) bit in the control register is set.
-- TMODE 1:
-- The slave transmits one byte and then keeps SCL low until software has
-- acknowledged that the byte has been transmitted.


library ieee;
use ieee.std_logic_1164.all;

library gaisler;
use gaisler.misc.all;

library grlib;
use grlib.amba.all;
use grlib.devices.all;
use grlib.stdlib.all;

entity i2cslv is
 generic (
   -- APB generics
   pindex : integer := 0;         -- slave bus index
   paddr  : integer := 0;
   pmask  : integer := 16#fff#;
   pirq   : integer := 0;         -- interrupt index
   -- I2C configuration
   hardaddr : integer range 0 to 1 := 0; -- See description above
   tenbit   : integer range 0 to 1 := 0;
   i2caddr  : integer range 0 to 1023 := 0;
   oepol    : integer range 0 to 1 := 0
   );
 port (
   rstn   : in  std_ulogic;
   clk    : in  std_ulogic;
   -- APB signals
   apbi   : in  apb_slv_in_type;
   apbo   : out apb_slv_out_type;
   -- I2C signals
   i2ci   : in  i2c_in_type;
   i2co   : out i2c_out_type
   );
end entity i2cslv;

architecture rtl of i2cslv is
 -----------------------------------------------------------------------------
 -- Constants
 -----------------------------------------------------------------------------
 -- Core version
 constant I2CSLV_REV : integer := 0;

 -- AMBA PnP
 constant PCONFIG : apb_config_type := (
   0 => ahb_device_reg(VENDOR_GAISLER, GAISLER_I2CSLV, 0, I2CSLV_REV, pirq),
   1 => apb_iobar(paddr, pmask));

 -- Register addresses
 constant SLV_ADDR  : std_logic_vector(7 downto 2) := "000000";
 constant CTRL_ADDR : std_logic_vector(7 downto 2) := "000001";
 constant STS_ADDR  : std_logic_vector(7 downto 2) := "000010";
 constant MSK_ADDR  : std_logic_vector(7 downto 2) := "000011";
 constant RD_ADDR   : std_logic_vector(7 downto 2) := "000100";
 constant TD_ADDR   : std_logic_vector(7 downto 2) := "000101";

 -- Core configuration
 constant TENBIT_SUPPORT : integer := tenbit;
 constant I2CADDRLEN     : integer := 7 + tenbit*3;
 constant HARDCADDR      : integer := hardaddr;
 constant I2CSLVADDR     : std_logic_vector((I2CADDRLEN-1) downto 0) :=
   conv_std_logic_vector(i2caddr, I2CADDRLEN);

 -- Misc constants
 constant I2C_READ  : std_ulogic := '1';  -- R/Wn bit
 constant I2C_WRITE : std_ulogic := '0';

 constant OEPOL_LEVEL : std_ulogic := conv_std_logic(oepol = 1);
 
 constant I2C_LOW   : std_ulogic := OEPOL_LEVEL;  -- OE
 constant I2C_HIZ   : std_ulogic := not OEPOL_LEVEL;

 constant I2C_ACK   : std_ulogic := '0';

 constant TENBIT_ADDR_START : std_logic_vector(4 downto 0) := "11110";
 
 -----------------------------------------------------------------------------
 -- Types
 -----------------------------------------------------------------------------

 type ctrl_reg_type is record          -- Control register
      rmode : std_ulogic;              -- Receive mode
      tmode : std_ulogic;              -- Transmit mode
      tv    : std_ulogic;              -- Transmit valid
      tav   : std_ulogic;              -- Transmit always valid
      en    : std_ulogic;              -- Enable
 end record;

 type sts_reg_type is record           -- Status/Mask registers
      rec : std_ulogic;                -- Received byte
      tra : std_ulogic;                -- Transmitted byte
      nak : std_ulogic;                -- NAK'd address
 end record;

 type slvaddr_reg_type is record        -- Slave address register
      tba      : std_ulogic;            -- 10-bit address
      slvaddr  : std_logic_vector((I2CADDRLEN-1) downto 0);
 end record;
 
 type i2cslv_reg_bank is record        -- APB registers
      slvaddr  : slvaddr_reg_type;
      ctrl     : ctrl_reg_type;
      sts      : sts_reg_type;
      msk      : sts_reg_type;
      receive  : std_logic_vector(7 downto 0);
      transmit : std_logic_vector(7 downto 0);
 end record;

 type i2c_in_array is array (6 downto 0) of i2c_in_type;

 type slv_state_type is (idle, checkaddr, check10bitaddr, sclhold,
                         movebyte, handshake);
 
 type i2cslv_reg_type is record
      slvstate : slv_state_type;
      --
      reg      : i2cslv_reg_bank;
      irq      : std_ulogic;
      -- Transfer phase
      active   : boolean;
      addr     : boolean;
      transmit : boolean;
      receive  : boolean;
      -- Shift register
      sreg     : std_logic_vector(7 downto 0);
      cnt      : std_logic_vector(2 downto 0);
      -- Synchronizers for inputs SCL and SDA
      scl      : std_ulogic;
      sda      : std_ulogic;
      i2ci     : i2c_in_array;
      -- Output enables
      scloen   : std_ulogic;
      sdaoen   : std_ulogic;
 end record;

 -----------------------------------------------------------------------------
 -- Subprograms
 -----------------------------------------------------------------------------
 -- purpose: Compares the first byte of a received address with the slave's
 -- address. The tba input determines if the slave is using a ten bit address.
 function compaddr1stb (
   ibyte : std_logic_vector(7 downto 0);      -- I2C byte
   sr    : slvaddr_reg_type)                  -- slave address register
   return boolean is
   variable correct : std_logic_vector(7 downto 1);
 begin  -- compaddr1stb
   if sr.tba = '1' then
     correct(7 downto 3) := TENBIT_ADDR_START;
     correct(2 downto 1):= sr.slvaddr((I2CADDRLEN-1) downto (I2CADDRLEN-2));
   else
     correct(7 downto 1) := sr.slvaddr(6 downto 0);
   end if;
   return ibyte(7 downto 1) = correct(7 downto 1);
 end compaddr1stb;

 -- purpose: Compares the 2nd byte of a ten bit address with the slave address
 function compaddr2ndb (
   ibyte   : std_logic_vector(7 downto 0);               -- I2C byte
   slvaddr : std_logic_vector((I2CADDRLEN-1) downto 0))  -- slave address
   return boolean is
 begin  -- compaddr2ndb
   return ibyte((I2CADDRLEN-3) downto 0) = slvaddr((I2CADDRLEN-3) downto 0);
 end compaddr2ndb;
 
 -----------------------------------------------------------------------------
 -- Signals
 -----------------------------------------------------------------------------

 -- Register interface
 signal r, rin : i2cslv_reg_type;

begin

 comb: process (r, rstn, apbi, i2ci)
   variable v         : i2cslv_reg_type;
   variable irq       : std_logic_vector((NAHBIRQ-1) downto 0);
   variable apbaddr   : std_logic_vector(5 downto 0);
   variable apbout    : std_logic_vector(31 downto 0);
   variable sclfilt   : std_logic_vector(3 downto 0);
   variable sdafilt   : std_logic_vector(3 downto 0);
   variable tba       : boolean;
 begin  -- process comb
   v := r;  v.irq := '0'; irq := (others=>'0'); irq(pirq) := r.irq;
   apbaddr := apbi.paddr(7 downto 2); apbout := (others => '0');
   v.i2ci(0) := i2ci; v.i2ci(6 downto 1) := r.i2ci(5 downto 0); tba := false;
   
   ---------------------------------------------------------------------------
   -- APB register interface
   ---------------------------------------------------------------------------
   -- read registers
   if (apbi.psel(pindex) and apbi.penable and (not apbi.pwrite)) = '1' then
     case apbaddr is
       when SLV_ADDR =>
         apbout(31) := r.reg.slvaddr.tba;
         apbout((I2CADDRLEN-1) downto 0) := r.reg.slvaddr.slvaddr;
       when CTRL_ADDR =>
         apbout(4 downto 0) := r.reg.ctrl.rmode & r.reg.ctrl.tmode &
                               r.reg.ctrl.tv & r.reg.ctrl.tav & r.reg.ctrl.en;
       when STS_ADDR  =>
         apbout(2 downto 0) := r.reg.sts.rec & r.reg.sts.tra & r.reg.sts.nak;
       when MSK_ADDR  =>
         apbout(2 downto 0) := r.reg.msk.rec & r.reg.msk.tra & r.reg.msk.nak;
       when RD_ADDR =>
         v.reg.sts.rec := '0';
         apbout(7 downto 0) := r.reg.receive;
       when TD_ADDR =>
         apbout(7 downto 0) := r.reg.transmit;
       when others => null;
     end case;
   end if;

   -- write registers
   if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
     case apbaddr is
       when SLV_ADDR =>
         if HARDCADDR = 0 then
           if TENBIT_SUPPORT = 1 then
             v.reg.slvaddr.tba := apbi.pwdata(31);
           end if;
           v.reg.slvaddr.slvaddr := apbi.pwdata((I2CADDRLEN-1) downto 0);
         end if;
       when CTRL_ADDR =>
         v.reg.ctrl.rmode := apbi.pwdata(4);
         v.reg.ctrl.tmode := apbi.pwdata(3);
         v.reg.ctrl.tv  := apbi.pwdata(2);
         v.reg.ctrl.tav := apbi.pwdata(1);
         v.reg.ctrl.en  := apbi.pwdata(0);
       when STS_ADDR  =>
         v.reg.sts.tra := r.reg.sts.tra and not apbi.pwdata(1);
         v.reg.sts.nak := r.reg.sts.nak and not apbi.pwdata(0);
       when MSK_ADDR  =>
         v.reg.msk.rec := apbi.pwdata(2);
         v.reg.msk.tra := apbi.pwdata(1);
         v.reg.msk.nak := apbi.pwdata(0);
       when TD_ADDR =>
         v.reg.transmit := apbi.pwdata(7 downto 0);
       when others => null;
     end case;
   end if;

   ----------------------------------------------------------------------------
   -- Bus filtering
   ----------------------------------------------------------------------------
   for i in 0 to 3 loop 
     sclfilt(i) := r.i2ci(i+2).scl; sdafilt(i) := r.i2ci(i+2).sda;
   end loop;  -- i
   if sclfilt = "1111" then v.scl := '1'; end if;
   if sclfilt = "0000" then v.scl := '0'; end if;
   if sdafilt = "1111" then v.sda := '1'; end if;
   if sdafilt = "0000" then v.sda := '0'; end if;
   
   ---------------------------------------------------------------------------
   -- I2C slave control FSM
   ---------------------------------------------------------------------------
   case r.slvstate is
     when idle =>
       -- Release bus
       if (r.scl and not v.scl) = '1' then
         v.sdaoen := I2C_HIZ;
       end if;
     
     when checkaddr =>
       tba := r.reg.slvaddr.tba = '1';
       if compaddr1stb(r.sreg, r.reg.slvaddr) then
         if r.sreg(0) = I2C_READ then
           if (not tba or (tba and r.active)) then
             if r.reg.ctrl.tv = '1' then
               -- Transmit data
               v.transmit := true;
               v.slvstate := handshake;
             else
               -- No data to transmit, NAK
               if (not v.reg.sts.nak and r.reg.msk.nak) = '1' then
                 v.irq := '1';
               end if;
               v.reg.sts.nak := '1';
               v.slvstate := idle;
             end if;
           else
             -- Ten bit address with R/Wn = 1 and slave not previously
             -- addressed.
             v.slvstate := idle;
           end if;
         else
           v.receive := not tba;
           v.slvstate := handshake;
         end if;
       else
         -- Slave address did not match
         v.active := false;
         v.slvstate := idle;
       end if;
       v.sreg := r.reg.transmit;
       
     when check10bitaddr =>
       if compaddr2ndb(r.sreg, r.reg.slvaddr.slvaddr) then
         -- Slave has been addressed with a matching 10 bit address
         -- If we receive a repeated start condition, matching address
         -- and R/Wn = 1 we will transmit data. Without start condition we
         -- will receive data.
         v.addr := true;
         v.active := true;
         v.receive := true;
         v.slvstate := handshake;
       else
         v.slvstate := idle;
       end if;
       
     when sclhold =>
       -- This state is used when the device has been addressed to see if SCL
       -- should be kept low until the receive register is free or the
       -- transmit register is filled. It is also used when a data byte has
       -- been transmitted or received to SCL low until software acknowledges
       -- the transfer.
       if (r.scl and not v.scl) = '1' then
         v.scloen := I2C_LOW;
         v.sdaoen := I2C_HIZ;
       end if;
       if ((r.receive and (not r.reg.sts.rec or not r.reg.ctrl.rmode) = '1') or
           (r.transmit and (r.reg.ctrl.tv or not r.reg.ctrl.tmode) = '1')) then
         v.slvstate := movebyte;
         v.scloen := I2C_HIZ;
       end if;
       v.sreg := r.reg.transmit;

     when movebyte =>
       if (r.scl and not v.scl) = '1' then
         if r.transmit then
           v.sdaoen := r.sreg(7) xor OEPOL_LEVEL;
         else
           v.sdaoen := I2C_HIZ;
         end if;
       end if;
       if (not r.scl and v.scl) = '1' then
         v.sreg := r.sreg(6 downto 0) & r.sda;
         if r.cnt = "111" then
           if r.addr then
             v.slvstate := checkaddr;
           elsif r.receive nor r.transmit then
             v.slvstate := check10bitaddr;
           else
             v.slvstate := handshake;
           end if;
           v.cnt := (others => '0');
         else
           v.cnt := r.cnt + 1;
         end if;
       end if;
      
     when handshake =>
       -- Falling edge
       if (r.scl and not v.scl) = '1' then
         if r.addr then
           v.sdaoen := I2C_LOW;
         elsif r.receive then
           -- Receive, send ACK/NAK
           -- Acknowledge byte if core has room in receive register
           -- This code assumes that the core's receive register is free if we are
           -- in RMODE 1. This should always be the case unless software has
           -- reconfigured the core during operation.
           if r.reg.sts.rec = '0' then
             v.sdaoen := I2C_LOW;
             v.reg.receive := r.sreg;
             if r.reg.msk.rec = '1' then
               v.irq := '1';
             end if;
             v.reg.sts.rec := '1';
           else
             -- NAK the byte, the master must abort the transfer
             v.sdaoen := I2C_HIZ;
             v.slvstate := idle;
           end if;
         else
           -- Transmit, release bus
           v.sdaoen := I2C_HIZ;
           -- Byte transmitted, unset TV unless TAV is set.
           v.reg.ctrl.tv := r.reg.ctrl.tav;
           -- Set status bit and check if interrupt should be generated
           if (not v.reg.sts.tra and r.reg.msk.tra) = '1' then
             v.irq := '1';
           end if;
           v.reg.sts.tra := '1';
         end if;
         if not r.addr and r.receive and v.sdaoen = I2C_HIZ then
           if (not v.reg.sts.nak and r.reg.msk.nak) = '1' then
             v.irq := '1';
           end if;
           v.reg.sts.nak := '1';
         end if;
       end if;
       -- Risinge edge
       if (not r.scl and v.scl) = '1' then
         if r.addr then
           v.slvstate := movebyte;
         else
           if r.receive then
             -- RMODE 0: Be ready to accept one more byte which will be NAK'd if
             -- software has not read the receive register
             -- RMODE 1: Keep SCL low until software has acknowledged received byte
             if r.reg.ctrl.rmode = '0' then
               v.slvstate := movebyte;
             else
               v.slvstate := sclhold;
             end if;
           else
             -- Transmit, check ACK/NAK from master
             -- If the master NAKs the transmitted byte the transfer has ended and
             -- we should wait for the master's next action. If the master ACKs the
             -- byte the core will act depending on tmode:
             -- TMODE 0:
             -- If the master ACKs the byte we must continue to transmit and will
             -- transmit the same byte on all requests.
             -- TMODE 1:
             -- IF the master ACKs the byte we will keep SCL low until software has
             -- put new transmit data into the transmit register.
             if r.sda = I2C_ACK then
               if r.reg.ctrl.tmode = '0' then
                 v.slvstate := movebyte;
               else
                 v.slvstate := sclhold;
               end if;
             else
               v.slvstate := idle;
             end if;
           end if;
         end if;
         v.addr := false;
         v.sreg := r.reg.transmit;
       end if;
   end case;
   
   if r.reg.ctrl.en = '1' then
     -- STOP condition
     if sclfilt = "1111" and sdafilt = "0011" then
       v.active := false;
       v.slvstate := idle;
     end if;

     -- START or repeated START condition
     if sclfilt = "1111" and sdafilt = "1100" then
       v.slvstate := movebyte;
       v.cnt := (others => '0');
       v.addr := true;
       v.transmit := false;
       v.receive := false;
     end if;
   end if;
   
   ----------------------------------------------------------------------------
   -- Reset and idle operation
   ----------------------------------------------------------------------------

   if rstn = '0' then
     v.slvstate := idle;
     v.reg.slvaddr.slvaddr := I2CSLVADDR;
     if TENBIT_SUPPORT = 1 then v.reg.slvaddr.tba := '1';
     else v.reg.slvaddr.tba := '0'; end if;
     v.reg.ctrl.en := '0';
     v.reg.sts := ('0', '0', '0');
     v.scl := '0';
     v.active := false;
     v.scloen := I2C_HIZ; v.sdaoen := I2C_HIZ;
   end if;

   ----------------------------------------------------------------------------
   -- Signal assignments
   ----------------------------------------------------------------------------
   
   -- Update registers
   rin <= v;

   -- Update outputs
   apbo.prdata <= apbout;
   apbo.pirq <= irq;
   apbo.pconfig <= PCONFIG;
   apbo.pindex <= pindex;

   i2co.scl <= '0';
   i2co.scloen <= r.scloen;
   i2co.sda <= '0';
   i2co.sdaoen <= r.sdaoen;
 end process comb;

 reg: process (clk)
 begin  -- process reg
   if rising_edge(clk) then
     r <= rin;
   end if;
 end process reg;

 -- Boot message
 -- pragma translate_off
 bootmsg : report_version
   generic map (
     "i2cslv" & tost(pindex) & ": I2C slave rev " &
     tost(I2CSLV_REV) & ", irq " & tost(pirq));
 -- pragma translate_on

end architecture rtl;
