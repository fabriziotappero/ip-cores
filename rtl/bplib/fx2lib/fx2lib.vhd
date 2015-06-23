-- $Id: fx2lib.vhd 638 2015-01-25 22:01:38Z mueller $
--
-- Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   fx2lib
-- Description:    Cypress ez-usb fx2 support
-- 
-- Dependencies:   -
-- Tool versions:  xst 12.1-14.7; ghdl 0.26-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-01-25   638   1.4    retire fx2_2fifoctl_as
-- 2012-01-14   453   1.3    use afull/aempty logic instead of exporting size
-- 2012-01-03   449   1.2.1  reorganize fx2ctl_moni; hardcode ep's
-- 2012-01-01   448   1.2    add fx2_2fifoctl_ic
-- 2011-12-25   445   1.1    change pktend iface in fx2_2fifoctl_as
-- 2011-07-17   394   1.0.1  add c_fifo_epx and fx2ctl_moni_type
-- 2011-07-07   389   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package fx2lib is

  constant c_fifo_ep2   : slv2 := "00";   -- fifo address: end point 2
  constant c_fifo_ep4   : slv2 := "01";   -- fifo address: end point 4
  constant c_fifo_ep6   : slv2 := "10";   -- fifo address: end point 6
  constant c_fifo_ep8   : slv2 := "11";   -- fifo address: end point 8

  type fx2ctl_moni_type is record       -- fx2ctl monitor port
    fifo_ep4 : slbit;                   -- fifo 1 (ep4) active;
    fifo_ep6 : slbit;                   -- fifo 2 (ep6) active;
    fifo_ep8 : slbit;                   -- fifo 3 (ep8) active;
    flag_ep4_empty  : slbit;            -- ep4 empty flag        (latched);
    flag_ep4_almost : slbit;            -- ep4 almost empty flag (latched);
    flag_ep6_full   : slbit;            -- ep6 full flag         (latched);
    flag_ep6_almost : slbit;            -- ep6 almost full flag  (latched);
    flag_ep8_full   : slbit;            -- ep8 full flag         (latched);
    flag_ep8_almost : slbit;            -- ep8 almost full flag  (latched);
    slrd : slbit;                       -- read strobe
    slwr : slbit;                       -- write strobe
    pktend : slbit;                     -- pktend strobe
  end record fx2ctl_moni_type;

  constant fx2ctl_moni_init : fx2ctl_moni_type := (
    '0','0','0',                        -- fifo_ep[468]
    '0','0',                            -- flag_ep4_(empty|almost)
    '0','0',                            -- flag_ep6_(full|almost)
    '0','0',                            -- flag_ep8_(full|almost)
    '0','0','0'                         -- slrd, slwr, pktend
  );


-- -------------------------------------
component fx2_2fifoctl_ic is            -- EZ-USB FX2 driver (2 fifo; int clk)
  generic (
    RXFAWIDTH : positive :=  5;         -- receive  fifo address width
    TXFAWIDTH : positive :=  5;         -- transmit fifo address width
    PETOWIDTH : positive :=  7;         -- packet end time-out counter width
    CCWIDTH :   positive :=  5;         -- chunk counter width
    RXAEMPTY_THRES : natural := 1;      -- threshold for rx aempty flag
    TXAFULL_THRES  : natural := 1);     -- threshold for tx afull flag
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RXDATA : out slv8;                  -- receive data out
    RXVAL : out slbit;                  -- receive data valid
    RXHOLD : in slbit;                  -- receive data hold
    RXAEMPTY : out slbit;               -- receive almost empty flag
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit;                 -- transmit data busy
    TXAFULL : out slbit;                -- transmit almost full flag
    MONI : out fx2ctl_moni_type;        -- monitor port data
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

component fx2_3fifoctl_ic is            -- EZ-USB FX2 driver (3 fifo; int clk)
  generic (
    RXFAWIDTH : positive :=  5;         -- receive  fifo address width
    TXFAWIDTH : positive :=  5;         -- transmit fifo address width
    PETOWIDTH : positive :=  7;         -- packet end time-out counter width
    CCWIDTH :   positive :=  5;         -- chunk counter width
    RXAEMPTY_THRES : natural := 1;      -- threshold for rx aempty flag
    TXAFULL_THRES  : natural := 1;      -- threshold for tx afull flag
    TX2AFULL_THRES : natural := 1);     -- threshold for tx2 afull flag
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit := '0';            -- reset
    RXDATA : out slv8;                  -- receive data out
    RXVAL : out slbit;                  -- receive data valid
    RXHOLD : in slbit;                  -- receive data hold
    RXAEMPTY : out slbit;               -- receive almost empty flag
    TXDATA : in slv8;                   -- transmit 1 data in
    TXENA : in slbit;                   -- transmit 1 data enable
    TXBUSY : out slbit;                 -- transmit 1 data busy
    TXAFULL : out slbit;                -- transmit 1 almost full flag
    TX2DATA : in slv8;                  -- transmit 2 data in
    TX2ENA : in slbit;                  -- transmit 2 data enable
    TX2BUSY : out slbit;                -- transmit 2 data busy
    TX2AFULL : out slbit;               -- transmit 2 almost full flag
    MONI : out fx2ctl_moni_type;        -- monitor port data
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

end package fx2lib;
