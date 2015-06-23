--------------------------------------------------------------------------------
----                                                                        ----
---- WISHBONE wishbone out port from b3 spec IP Core                        ----
----                                                                        ----
---- This file is part of the wishbone out port from b3 spec project        ----
---- http://www.opencores.org/cores/wishbone_out_port                       ----
----                                                                        ----
---- Description                                                            ----
---- Implementation of the wishbone out port from b3 spec IP core           ----
----  according to wishbone out port from b3 spec IP core specification     ----
----    document.                                                           ----
----                                                                        ----
---- To Do:                                                                 ----
----	NA                                                                  ----
----                                                                        ----
---- Taken directly from the wishbone out port from b3 spec, appendix A     ----
----  Changes made, 'tidy up', I like things in lines                       ----
----                change name, as Xilinx tools ( 9.2 sp 4 ) do not like   ----
----                      entity same name as the file name.                ----
----                 Used others clause for sync reset.                     ----
----                                                                        ----
---- Author(s):                                                             ----
----   Andrew Mulcock, amulcock@opencores.org                               ----
----                                                                        ----
--------------------------------------------------------------------------------
----                                                                        ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG                           ----
----                                                                        ----
---- This source file may be used and distributed without                   ----
---- restriction provided that this copyright statement is not              ----
---- removed from the file and that any derivative work contains            ----
---- the original copyright notice and the associated disclaimer.           ----
----                                                                        ----
---- This source file is free software; you can redistribute it             ----
---- and/or modify it under the terms of the GNU Lesser General             ----
---- Public License as published by the Free Software Foundation;           ----
---- either version 2.1 of the License, or (at your option) any             ----
---- later version.                                                         ----
----                                                                        ----
---- This source is distributed in the hope that it will be                 ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied             ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR                ----
---- PURPOSE. See the GNU Lesser General Public License for more            ----
---- details.                                                               ----
----                                                                        ----
---- You should have received a copy of the GNU Lesser General              ----
---- Public License along with this source; if not, download it             ----
---- from http://www.opencores.org/lgpl.shtml                               ----
----                                                                        ----
--------------------------------------------------------------------------------
----                                                                        ----
-- CVS Revision History                                                     ----
----                                                                        ----
-- $Log: not supported by cvs2svn $                                                                    ----
----                                                                        ----

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WB_MEM_32X16 is
    port(
-- WISHBONE SLAVE interface:
-- Single-Port RAM with Asynchronous Read
--
    ACK_O   : out   std_logic;
    ADR_I   : in    std_logic_vector( 3 downto 0 );
    CLK_I   : in    std_logic;
    DAT_I   : in    std_logic_vector( 31 downto 0 );
    DAT_O   : out   std_logic_vector( 31 downto 0 );
    STB_I   : in    std_logic;
    WE_I    : in    std_logic
    );
end entity WB_MEM_32X16;


architecture rtl of WB_MEM_32X16 is

    type ram_type is array (15 downto 0) of std_logic_vector (31 downto 0);
    signal RAM : ram_type;

    
begin

REG: process( CLK_I )
begin
    if( rising_edge( CLK_I ) ) then
        if( (STB_I and WE_I) = '1' ) then
            RAM(to_integer(unsigned(ADR_I))) <= DAT_I;
        end if;
    end if;
end process REG;

    ACK_O <= STB_I;

    DAT_O <= RAM(to_integer(unsigned(ADR_I)));

end architecture rtl;