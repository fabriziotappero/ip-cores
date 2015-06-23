-------------------------------------------------------------------------------
----                                                                       ----
---- WISHBONE Wishbone_BFM IP Core                                         ----
----                                                                       ----
---- This file is part of the Wishbone_BFM project                         ----
---- http://www.opencores.org/cores/Wishbone_BFM/                          ----
----                                                                       ----
---- Description                                                           ----
---- Implementation of Wishbone_BFM IP core according to                   ----
---- Wishbone_BFM IP core specification document.                          ----
----                                                                       ----
---- To Do:                                                                ----
----	NA                                                                 ----
----                                                                       ----
---- Author(s):                                                            ----
----   Andrew Mulcock, amulcock@opencores.org                              ----
----                                                                       ----
-------------------------------------------------------------------------------
----                                                                       ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG                          ----
----                                                                       ----
---- This source file may be used and distributed without                  ----
---- restriction provided that this copyright statement is not             ----
---- removed from the file and that any derivative work contains           ----
---- the original copyright notice and the associated disclaimer.          ----
----                                                                       ----
---- This source file is free software; you can redistribute it            ----
---- and/or modify it under the terms of the GNU Lesser General            ----
---- Public License as published by the Free Software Foundation           ----
---- either version 2.1 of the License, or (at your option) any            ----
---- later version.                                                        ----
----                                                                       ----
---- This source is distributed in the hope that it will be                ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied            ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               ----
---- PURPOSE. See the GNU Lesser General Public License for more           ----
---- details.                                                              ----
----                                                                       ----
---- You should have received a copy of the GNU Lesser General             ----
---- Public License along with this source; if not, download it            ----
---- from http://www.opencores.org/lgpl.shtml                              ----
----                                                                       ----
-------------------------------------------------------------------------------
----                                                                       ----
-- CVS Revision History                                                    ----
----                                                                       ----
-- $Log: not supported by cvs2svn $                                                                   ----
----                                                                       ----


-- file to 'exercise' the Wishbone bus.
--
--  Idea is to look like a wishbone master, 
--   and provide procedures to exercise the bus.
--
--  syscon is an external module that provides the reset and clocks 
--   to all the other modules in the design.
--
--  to enable the test script in this master to control
--   the syscon reset and clock stop,
--    this master provides tow 'extra' outputs
--   rst_i and clk_stop
--
--    when rst_sys is high, then syscon will issue a reset
--    when clk_stop is high, then syscon will stop the clock
--     on the next low transition. i.e. stopped clock is low.

use work.io_pack.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

entity wb_master is
    port(
    -- sys_con control ports
    RST_sys    : out  std_logic;
    CLK_stop   : out  std_logic;
    
    -- WISHBONE master interface:
    RST_I   : in    std_logic;
    CLK_I   : in    std_logic;

    ADR_O   : out   std_logic_vector( 31 downto 0 );
    DAT_I   : in    std_logic_vector( 31 downto 0 );
    DAT_O   : out   std_logic_vector( 31 downto 0 );
    WE_O    : out   std_logic;

    STB_O   : out   std_logic;
    CYC_O   : out   std_logic;
    ACK_I   : in    std_logic;
    ERR_I   : in    std_logic;
    RTY_I   : in    std_logic;
    
    LOCK_O  : out   std_logic;
    SEL_O   : out   std_logic_vector( 3 downto 0 );
    
    CYCLE_IS : out cycle_type  
    );
end entity wb_master;

-- --------------------------------------------------------------------
architecture Behavioral of wb_master is
-- --------------------------------------------------------------------

signal reset_int    : std_logic;


-- --------------------------------------------------------------------
begin
-- --------------------------------------------------------------------

-- concurrent assignemente to map record to the wishbone bus

ADR_O   <= bus_c.add_o;   -- address bus out of master
DAT_O   <= bus_c.dat_o;   -- data bus out of master
WE_O    <= bus_c.we;      -- wite enable out of master
STB_O   <= bus_c.stb;     -- wishbone strobe out of master
CYC_O   <= bus_c.cyc;     -- wishbone cycle out of master
LOCK_O  <= bus_c.lock;    -- wishbone Lock out of master
SEL_O   <= bus_c.sel;     -- slelects which of the 4 bytes to use for 32 bit
CYCLE_IS <= bus_c.c_type; -- monitor output, to know what master is up to

bus_c.dat_i <= DAT_I;
bus_c.ack   <= ACK_I;
bus_c.err   <= ERR_I;
bus_c.rty   <= RTY_I;
bus_c.clk   <= CLK_I;


-- concurent signal as can't pass out port to procedure ?
RST_sys <= reset_int;

-- --------------------------------------------------------------------
test_loop : process

-- need to use variables to get 'data' down from the procedures,
--  if we used a signal, then we get the value after the clock edge, 
--   which is not what we want, we need the value at the clock edge.
--
variable slv_32       : std_logic_vector( 31 downto 0);

variable bka_test_array : block_type :=
    ( others => x"0000_0000");
variable bkd_test_array : block_type :=
    ( others => x"0000_0000");




begin

		-- Wait 100 ns for global reset to finish
		wait for 100 ns;

--clock_wait( 2, bus_c );


wb_init( bus_c);        -- initalise wishbone bus
wb_rst( 2, reset_int, bus_c ); -- reset system for 2 clocks

-- set up some address / data pairs
bka_test_array(0) := X"0000_0002";
bkd_test_array(0) := X"5555_0002";

bka_test_array(1) := X"0000_0004";
bkd_test_array(1) := X"55AA_0004";

bka_test_array(2) := X"0000_0006";
bkd_test_array(2) := X"AAAA_0006";


bkw_32( bka_test_array, bkd_test_array, 3, bus_c);

clock_wait( 1, bus_c );

bkr_32( bka_test_array, bkd_test_array, 3, bus_c);

report to_hex(bkd_test_array(0));
report to_hex(bkd_test_array(1));
report to_hex(bkd_test_array(2));

--
--wr_32( x"8000_0004", x"5555_5555", bus_c);  -- write 32 bits address of 32 bit data
--
--rd_32( x"8000_0004", slv_32, bus_c);  -- read 32 bits address of 32 bit data
--report to_hex( slv_32);
--
--clock_wait( 2, bus_c );
--
--rmw_32( x"8000_0004", slv_32, x"ABCD_EF01", bus_c ); 
--report to_hex( slv_32);
--
--clock_wait( 2, bus_c );
--
--rmw_32( x"8000_0004", slv_32, x"01CD_EFAB", bus_c ); 
--report to_hex( slv_32);
--


clock_wait( 1, bus_c );
wb_rst( 2, reset_int, bus_c ); -- reset system for 2 clocks






-- --------------------------------------------------------------------
-- and stop the test running
-- --------------------------------------------------------------------

CLK_stop <= '1';
wait;

end process test_loop;





-- --------------------------------------------------------------------
end architecture Behavioral;
-- --------------------------------------------------------------------
