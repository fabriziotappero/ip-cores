-- $Id: fx2rlinklib.vhd 672 2015-05-02 21:58:28Z mueller $
--
-- Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   fx2rlinklib
-- Description:    Definitions for rlink + fx2 interface combos
--
-- Dependencies:   -
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-11   666   1.2    rlink_sp1c_fx2: drop ENAESC
-- 2014-08-28   588   1.1    use new rlink v4 iface generics and 4 bit STAT
-- 2013-04-20   509   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rlinklib.all;
use work.serportlib.all;
use work.fx2lib.all;

package fx2rlinklib is

--
-- core + fx2 interface combo
--

component rlink_sp1c_fx2 is             -- rlink_core8+serport_1clk+fx2_ic combo
  generic (
    BTOWIDTH : positive :=  5;          -- rbus timeout counter width
    RTAWIDTH : positive := 12;          -- retransmit buffer address width
    SYSID : slv32 := (others=>'0');     -- rlink system id
    IFAWIDTH : natural :=  5;           -- ser input fifo addr width  (0=none)
    OFAWIDTH : natural :=  5;           -- ser output fifo addr width (0=none)
    PETOWIDTH : positive := 10;         -- fx2 packet end time-out counter width
    CCWIDTH :   positive :=  5;         -- fx2 chunk counter width
    ENAPIN_RLMON : integer := -1;       -- SB_CNTL for rlmon  (-1=none)
    ENAPIN_RLBMON: integer := -1;       -- SB_CNTL for rlbmon (-1=none)
    ENAPIN_RBMON : integer := -1;       -- SB_CNTL for rbmon  (-1=none)
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15;           -- clk divider initial/reset setting
    RBMON_AWIDTH : natural := 0;        -- rbmon: buffer size (0=none)
    RBMON_RBADDR : slv16 := slv(to_unsigned(16#ffe8#,16))); -- rbmon: base addr
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    CE_INT : in slbit := '0';           -- rri ato time unit clock enable
    RESET  : in slbit;                  -- reset
    ENAXON : in slbit;                  -- enable xon/xoff handling
    ENAFX2 : in slbit;                  -- enable fx2 usage
    RXSD : in slbit;                    -- receive serial data      (board view)
    TXSD : out slbit;                   -- transmit serial data     (board view)
    CTS_N : in slbit := '0';            -- clear to send   (act.low, board view)
    RTS_N : out slbit;                  -- request to send (act.low, board view)
    RB_MREQ : out rb_mreq_type;         -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16;                  -- rbus: look at me
    RB_STAT : in slv4;                  -- rbus: status flags
    RL_MONI : out rl_moni_type;         -- rlink_core: monitor port
    RLB_MONI : out rlb_moni_type;       -- rlink 8b: monitor port
    SER_MONI : out serport_moni_type;   -- ser: monitor port
    FX2_MONI : out fx2ctl_moni_type;    -- fx2: monitor port
    I_FX2_IFCLK : in slbit;             -- fx2: interface clock
    O_FX2_FIFO : out slv2;              -- fx2: fifo address
    I_FX2_FLAG : in slv4;               -- fx2: fifo flags
    O_FX2_SLRD_N : out slbit;           -- fx2: read enable    (act.low)
    O_FX2_SLWR_N : out slbit;           -- fx2: write enable   (act.low)
    O_FX2_SLOE_N : out slbit;           -- fx2: output enable  (act.low)
    O_FX2_PKTEND_N : out slbit;         -- fx2: packet end     (act.low)
    IO_FX2_DATA : inout slv8            -- fx2: data lines
  );
end component;

component ioleds_sp1c_fx2               -- io activity leds for rlink_sp1c_fx2
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    RESET  : in slbit;                  -- reset
    ENAFX2 : in slbit;                  -- enable fx2 usage
    RB_SRES : in rb_sres_type;          -- rbus: response
    RLB_MONI : in rlb_moni_type;        -- rlink 8b: monitor port
    SER_MONI : in serport_moni_type;    -- ser: monitor port
    IOLEDS : out slv4                   -- 4 bit IO monitor (e.g. for DSP_DP)
  );
end component;

end package fx2rlinklib;
