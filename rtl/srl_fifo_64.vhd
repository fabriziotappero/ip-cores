----------------------------------------------------------------------------
----                                                                    ----
----                                                                    ----
---- This file is part of the srl_fifo project                          ----
---- http://www.opencores.org/cores/srl_fifo                            ----
----                                                                    ----
---- Description                                                        ----
---- Implementation of srl_fifo IP core according to                    ----
---- srl_fifo IP core specification document.                           ----
----                                                                    ----
---- To Do:                                                             ----
----	NA                                                                ----
----                                                                    ----
---- Author(s):                                                         ----
----   Andrew Mulcock, amulcock@opencores.org                           ----
----                                                                    ----
----------------------------------------------------------------------------
----                                                                    ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG                       ----
----                                                                    ----
---- This source file may be used and distributed without               ----
---- restriction provided that this copyright statement is not          ----
---- removed from the file and that any derivative work contains        ----
---- the original copyright notice and the associated disclaimer.       ----
----                                                                    ----
---- This source file is free software; you can redistribute it         ----
---- and/or modify it under the terms of the GNU Lesser General         ----
---- Public License as published by the Free Software Foundation;       ----
---- either version 2.1 of the License, or (at your option) any         ----
---- later version.                                                     ----
----                                                                    ----
---- This source is distributed in the hope that it will be             ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied         ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR            ----
---- PURPOSE. See the GNU Lesser General Public License for more        ----
---- details.                                                           ----
----                                                                    ----
---- You should have received a copy of the GNU Lesser General          ----
---- Public License along with this source; if not, download it         ----
---- from http://www.opencores.org/lgpl.shtml                           ----
----                                                                    ----
----------------------------------------------------------------------------
----                                                                    ----
-- CVS Revision History                                                 ----
----                                                                    ----
-- $Log: not supported by cvs2svn $                                                                ----
----                                                                    ----
----                                                                    ----
-- quick description
--
--  Based upon the using a shift register as a fifo which has been 
--   around for years ( decades ), but really came of use to VHDL 
--   when the Xilinx FPGA's started having SRL's. 
--
--  In my view, the definitive article on shift register logic fifo's 
--   comes from Mr Chapman at Xilinx, in the form of his BBFIFO
--    tecXeclusive article, which as at early 2008, Xilinx have
--     removed.
--
--
-- using Xilinx ISE 10.1 and later, the tools are getting real clever.
--   In previous version of ISE, SRL inferance was not this clever.
--     now if one infers a 32 bit srl in a device that has inherantly 16 
--      bit srls, then an srl and a series of registers was created.
--   In 10,1 and later, if you infer a 32 bit srl for a device with
--    16 bit srls in, then you end up with the cascaded srls as expected.
--
--    Well done Xilinx..
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.all;

entity srl_fifo_64 is
    generic ( width : integer := 8 ); -- set to how wide fifo is to be
    port( 
        data_in      : in     std_logic_vector (width -1 downto 0);
        data_out     : out    std_logic_vector (width -1 downto 0);
        reset        : in     std_logic;
        write        : in     std_logic;
        read         : in     std_logic;
        full         : out    std_logic;
        half_full    : out    std_logic;
        data_present : out    std_logic;
        clk          : in     std_logic
    );

-- Declarations

end srl_fifo_64 ;
--
------------------------------------------------------------------------------------
--
architecture rtl of srl_fifo_64 is
--
------------------------------------------------------------------------------------
--



------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------
--

constant srl_length  : integer := 64;  -- set to 16, 32, 64 etc. 
constant pointer_vec : integer := 6;    -- set to number of bits needed to store pointer = log2(srl_length)

type	srl_array	is array ( srl_length - 1  downto 0 ) of STD_LOGIC_VECTOR ( WIDTH - 1 downto 0 );
signal	fifo_store		: srl_array;

signal  pointer            : integer range 0 to srl_length - 1;

signal pointer_zero        : std_logic;
signal pointer_full        : std_logic;
signal valid_write         : std_logic;
signal half_full_int       : std_logic_vector( pointer_vec - 1 downto 0);

signal empty               : std_logic := '1';
signal valid_count         : std_logic ;

------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------
--	
begin


-- Valid write, high when valid to write data to the store.
valid_write <= '1' when ( read = '1' and write = '1' )  
                    or  ( write = '1' and pointer_full = '0' ) else '0';

-- data store SRL's
data_srl :process( clk )
begin
    if rising_edge( clk ) then
        if valid_write = '1' then
            fifo_store <= fifo_store( fifo_store'left - 1 downto 0) & data_in;
        end if;
    end if;
end process;
    
data_out <= fifo_store( pointer );


process( clk)
begin
    if rising_edge( clk ) then
        if reset = '1' then
            empty <= '1';
        elsif empty = '1' and write = '1' then
            empty <= '0';
        elsif pointer_zero = '1' and read = '1' and write = '0' then
            empty <= '1';
        end if;
    end if;
end process;



--	W	R	Action
--	0	0	pointer <= pointer
--	0	1	pointer <= pointer - 1	Read, but no write, so less data in counter
--	1	0	pointer <= pointer + 1	Write, but no read, so more data in fifo
--	1	1	pointer <= pointer		Read and write, so same number of words in fifo
--

valid_count <= '1' when (
                             (write = '1' and read = '0' and pointer_full = '0' and empty = '0' )
                        or
                             (write = '0' and read = '1' and pointer_zero = '0' )
                         ) else '0';
process( clk )
begin
    if rising_edge( clk ) then
        if valid_count = '1' then
            if write = '1' then
                pointer <= pointer + 1;
            else
                pointer <= pointer - 1;
            end if;
        end if;
    end if;
end process;


  -- Detect when pointer is zero and maximum
pointer_zero <= '1' when pointer = 0 else '0';
pointer_full <= '1' when pointer = srl_length - 1 else '0';




  -- assign internal signals to outputs
  full <= pointer_full;  
   half_full_int <= std_logic_vector(to_unsigned(pointer, pointer_vec));
   half_full <= half_full_int(half_full_int'left);
  data_present <= not( empty );

end rtl;

------------------------------------------------------------------------------------
--
------------------------------------------------------------------------------------


