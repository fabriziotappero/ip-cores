-- $Id: pdp11_gpr.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_gpr - syn
-- Description:    pdp11: general purpose registers
--
-- Dependencies:   memlib/ram_1swar_1ar_gen
--
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-18   427   1.0.4  now numeric_std clean
-- 2008-08-22   161   1.0.3  rename ubf_ -> ibf_; use iblib
-- 2007-12-30   108   1.0.2  use ubf_byte[01]
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_gpr is                     -- general purpose registers
  port (
    CLK    : in slbit;                  -- clock
    DIN   : in slv16;                   -- input data
    ASRC   : in slv3;                   -- source register number
    ADST   : in slv3;                   -- destination register number
    MODE   : in slv2;                   -- processor mode (k=>00,s=>01,u=>11)
    RSET   : in slbit;                  -- register set
    WE     : in slbit;                  -- write enable
    BYTOP  : in slbit;                  -- byte operation (write low byte only)
    PCINC  : in slbit;                  -- increment PC
    DSRC : out slv16;                   -- source register data
    DDST : out slv16;                   -- destination register data
    PC     : out slv16                  -- current PC value
  );
end pdp11_gpr;

architecture syn of pdp11_gpr is

-- --------------------------------------
-- the register map determines the internal register file storage address
-- of a register. The mapping is
--    ADDR  RNUM SET MODE
--    0000   000  0  --    R0 set 0
--    0001   001  0  --    R1 set 0
--    0010   010  0  --    R2 set 0
--    0011   011  0  --    R3 set 0
--    0100   100  0  --    R4 set 0
--    0101   101  0  --    R5 set 0
--    0110   110  -  00    SP kernel mode
--    0111   110  -  01    SP supervisor mode
--    1000   000  1  --    R0 set 1
--    1001   001  1  --    R1 set 1
--    1010   010  1  --    R2 set 1
--    1011   011  1  --    R3 set 1
--    1100   100  1  --    R4 set 1
--    1101   101  1  --    R5 set 1
--    1110   111  -  --    PC 
--    1111   110  -  11    SP user mode

  procedure do_regmap (
      signal RNUM : in slv3;            -- register number
      signal MODE : in slv2;            -- processor mode (k=>00,s=>01,u=>11)
      signal RSET : in slbit;           -- register set
      signal ADDR : out slv4            -- internal address in regfile
    ) is
  begin
    if RNUM = c_gpr_pc then
      ADDR <= "1110";
    elsif RNUM = c_gpr_sp then
      ADDR <= MODE(1) & "11" & MODE(0);
    else
      ADDR <= RSET & RNUM;
    end if;
  end procedure do_regmap;

-- --------------------------------------

  signal MASRC : slv4 := (others=>'0'); -- mapped source register address
  signal MADST : slv4 := (others=>'0'); -- mapped destination register address
  signal WE1 : slbit := '0';            -- write enable high byte
  signal MEMSRC : slv16 := (others=>'0');-- source reg data from memory
  signal MEMDST : slv16 := (others=>'0');-- destination reg data from memory
  signal R_PC : slv16 := (others=>'0'); -- PC register

begin

  do_regmap(RNUM => ASRC, MODE => MODE, RSET => RSET, ADDR => MASRC);
  do_regmap(RNUM => ADST, MODE => MODE, RSET => RSET, ADDR => MADST);

  WE1 <= WE and not BYTOP;

  GPR_LOW : ram_1swar_1ar_gen
    generic map (
      AWIDTH => 4,
      DWIDTH => 8)
    port map (
      CLK   => CLK,
      WE    => WE,
      ADDRA => MADST,
      ADDRB => MASRC,
      DI    => DIN(ibf_byte0),
      DOA   => MEMDST(ibf_byte0),
      DOB   => MEMSRC(ibf_byte0));

  GPR_HIGH : ram_1swar_1ar_gen
    generic map (
      AWIDTH => 4,
      DWIDTH => 8)
    port map (
      CLK   => CLK,
      WE    => WE1,
      ADDRA => MADST,
      ADDRB => MASRC,
      DI    => DIN(ibf_byte1),
      DOA   => MEMDST(ibf_byte1),
      DOB   => MEMSRC(ibf_byte1));

  proc_pc : process (CLK)
    alias R_PC15 : slv15 is R_PC(15 downto 1);  -- upper 15 bit of PC
  begin 
    if rising_edge(CLK) then
      if WE='1' and ADST=c_gpr_pc then
        R_PC(ibf_byte0) <= DIN(ibf_byte0);
        if BYTOP = '0' then
          R_PC(ibf_byte1) <= DIN(ibf_byte1);
        end if;
      elsif PCINC = '1' then
        R_PC15 <= slv(unsigned(R_PC15) + 1);
      end if;
    end if;
  end process proc_pc;

  DSRC <= R_PC when ASRC=c_gpr_pc else MEMSRC;
  DDST <= R_PC when ADST=c_gpr_pc else MEMDST;
  PC <= R_PC;
    
end syn;
