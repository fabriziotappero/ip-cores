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


--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- -------------------------------------------------------------------------
package io_pack is
-- -------------------------------------------------------------------------

constant write32_time_out   : integer := 6;    -- number of clocks to wait 
                                                -- on w32, before an error
constant read32_time_out    : integer := 6;    -- number of clocks to wait 
                                                -- on r32, before an error

constant clk_period         : time := 10 ns;    -- period of simulation clock

constant max_block_size     : integer := 128;   -- maximum number of read or write 
                                                -- locations in a block transfer

type cycle_type is (    unknown,
                        bus_rst,
                        bus_idle,
                        rd32,  rd16,  rd8,  -- read 
                        wr32,  wr16,  wr8,  -- write
                        rmw32, rmw16, rmw8, -- read modify write
                        bkr32, bkr16, brw8, -- block read
                        bkw32, bkw16, bkw8  -- block write
                    );
  
type bus_cycle is
  record
     c_type     : cycle_type;
     add_o      : std_logic_vector( 31 downto 0);
     dat_o      : std_logic_vector( 31 downto 0);
     dat_i      : std_logic_vector( 31 downto 0);
     we         : std_logic;
     stb        : std_logic;
     cyc        : std_logic;
     ack        : std_logic;
     err        : std_logic;
     rty        : std_logic;
     lock       : std_logic;
     sel        : std_logic_vector( 3 downto 0);
     clk        : std_logic;
  end record;



-- define the wishbone bus signal to share 
--  with main procedure
-- Need to define it as the weekest possible ( 'Z' ) 
--  not so that we get a tri state bus, but so that 
--  procedures called can over drive the signal in the test bench.
--  else test bench gets 'U's.
--
signal bus_c    : bus_cycle :=
            (   unknown,
                (others => 'Z'),
                (others => 'Z'),
                (others => 'Z'),
                'Z',
                'Z',
                'Z',
                'Z',
                'Z',
                'Z',
                'Z',
                (others => 'Z'),
                'Z'
            );

type block_type is array ( max_block_size downto 0 ) of std_logic_vector( 31 downto 0 );


-- ----------------------------------------------------------------------
--  to_nibble
-- ----------------------------------------------------------------------
-- usage to_nibble( slv  ); -- convert 4 bit slv to a character
function to_nibble( s:std_logic_vector(3 downto 0)) return character;


-- ----------------------------------------------------------------------
--  to_hex
-- ----------------------------------------------------------------------
-- usage to_hex( slv  ); -- convert a slv to a string
function to_hex( v:std_logic_vector) return string;








-- ----------------------------------------------------------------------
--  clock_wait
-- ----------------------------------------------------------------------
-- usage clock_wait( number of cycles, bus_record ); -- wait n number of clock cycles
procedure clock_wait(
            constant    no_of_clocks  : in    integer;
            signal      bus_c         : inout bus_cycle
                    );


-- ----------------------------------------------------------------------
--  wb_init
-- ----------------------------------------------------------------------
-- usage wb_init( bus_record ); -- Initalises the wishbone bus
procedure wb_init( 
            signal   bus_c          : inout bus_cycle
                );           


-- ----------------------------------------------------------------------
--  wb_rst
-- ----------------------------------------------------------------------
-- usage wb_rst( 10, RST_sys, bus_record ); -- reset system for 10 clocks
procedure wb_rst ( 
            constant no_of_clocks   : in integer;
            signal   reset          : out std_logic;
            signal   bus_c          : inout bus_cycle
                );           



-- ----------------------------------------------------------------------
--  wr_32
-- ----------------------------------------------------------------------
-- usage wr_32 ( address, data , bus_record )-- write 32 bit data to a 32 bit address
procedure wr_32 ( 
            constant address_data   : in std_logic_vector( 31 downto 0);
            constant write_data     : in std_logic_vector( 31 downto 0);
            signal   bus_c          : inout bus_cycle
                );           

-- ----------------------------------------------------------------------
--  rd_32
-- ----------------------------------------------------------------------
-- usage rd_32 ( address, data , bus_record )-- read 32 bit data from a 32 bit address
procedure rd_32 ( 
            constant address_data   : in std_logic_vector( 31 downto 0);
            variable read_data      : out std_logic_vector( 31 downto 0);
            signal   bus_c          : inout bus_cycle
                );           


-- ----------------------------------------------------------------------
--  rmw_32
-- ----------------------------------------------------------------------
-- usage rmw_32 ( address, read_data, write_data , bus_record )-- read 32 bit data from a 32 bit address
--                                                                then write new 32 bit data to that address

procedure rmw_32 ( 
            constant address_data   : in std_logic_vector( 31 downto 0);
            variable read_data      : out std_logic_vector( 31 downto 0);
            constant write_data     : in std_logic_vector( 31 downto 0);
            signal   bus_c          : inout bus_cycle
                );           


-- ----------------------------------------------------------------------
--  bkw_32
-- ----------------------------------------------------------------------
-- usage bkw_32 ( address_array, write_data_array, array_size , bus_record )
-- write each data to the coresponding address of the array

procedure bkw_32 ( 
            constant address_data   : in block_type;
            constant write_data     : in block_type;
            constant array_size     : in integer;
            signal   bus_c          : inout bus_cycle
                );           

-- ----------------------------------------------------------------------
--  bkr_32
-- ----------------------------------------------------------------------
-- usage bkr_32 ( address_array, read_data_array, array_size , bus_record )
-- read from each address data to the coresponding address of the array

procedure bkr_32 ( 
            constant address_data   : in block_type;
            variable read_data      : out block_type;
            constant array_size     : in integer;
            signal   bus_c          : inout bus_cycle
                ) ;



-- -------------------------------------------------------------------------
end io_pack;
-- -------------------------------------------------------------------------





-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
package body io_pack is
-- -------------------------------------------------------------------------

-- ----------------------------------------------------------------------
--  to_nibble
-- ----------------------------------------------------------------------
-- usage to_nibble( slv  ); -- convert 4 bit slv to a character
function to_nibble( s:std_logic_vector(3 downto 0)) return character is
begin
	case s is
		when "0000" => return '0';
		when "0001" => return '1';
		when "0010" => return '2';
		when "0011" => return '3';
		when "0100" => return '4';
		when "0101" => return '5';
		when "0110" => return '6';
		when "0111" => return '7';
		when "1000" => return '8';
		when "1001" => return '9';
		when "1010" => return 'A';
		when "1011" => return 'B';
		when "1100" => return 'C';
		when "1101" => return 'D';
		when "1110" => return 'E';
		when "1111" => return 'F';
		when others=> return '?';
	end case;
end function to_nibble;


-- ----------------------------------------------------------------------
--  to_hex
-- ----------------------------------------------------------------------
-- usage to_hex( slv  ); -- convert a slv to a string
function to_hex( v:std_logic_vector) return string is
	constant c:std_logic_vector(v'length+3 downto 1) := "000" & to_x01(v);
begin
	if v'length < 1 then return ""; end if;
	return to_hex(c(v'length downto 5)) & to_nibble(c(4 downto 1));
end function to_hex;



-- ----------------------------------------------------------------------
--  clock_wait
-- ----------------------------------------------------------------------
-- usage clock_wait( number of cycles, bus_record ); -- wait n number of clock cycles
procedure clock_wait(
            constant    no_of_clocks  : in    integer;
            signal      bus_c         : inout bus_cycle
                    ) is
begin
                    
    for n in 1 to no_of_clocks loop
        wait until rising_edge( bus_c.clk );
    end loop;

end procedure clock_wait;



-- --------------------------------------------------------------------
-- usage wb_init( bus_record ); -- Initalises the wishbone bus
procedure wb_init(
            signal   bus_c          : inout bus_cycle
                ) is           
begin

     bus_c.c_type <= bus_idle;
     bus_c.add_o <= ( others => '0');
     bus_c.dat_o <= ( others => '0');
     bus_c.we   <= '0';
     bus_c.stb  <= '0';
     bus_c.cyc  <= '0';
     bus_c.lock <= '0';

     wait until rising_edge( bus_c.clk );   -- allign to next clock
     
end procedure wb_init;


-- --------------------------------------------------------------------
-- usage wb_rst( 10, RST_sys, bus_record ); -- reset system for 10 clocks
procedure wb_rst ( 
            constant no_of_clocks   : in integer;
            signal   reset          : out std_logic;
            signal   bus_c          : inout bus_cycle
                ) is
begin
     bus_c.c_type <= bus_rst;
     bus_c.stb  <= '0';
     bus_c.cyc  <= '0';

     reset <= '1';
        for n in 1 to no_of_clocks loop 
            wait until falling_edge( bus_c.clk );
        end loop;
     reset <= '0';
            wait until rising_edge( bus_c.clk);
end procedure wb_rst;

-- --------------------------------------------------------------------
procedure wr_32 ( 
            constant address_data  : in std_logic_vector( 31 downto 0);
            constant write_data    : in std_logic_vector( 31 downto 0);
            signal   bus_c         : inout bus_cycle
                ) is

variable  bus_write_timer : integer;

begin

    bus_c.c_type    <= wr32;
    bus_c.add_o     <= address_data;
    bus_c.dat_o     <= write_data;    
    bus_c.we        <= '1';                 -- write cycle
    bus_c.sel       <= ( others => '1');    -- on all four banks
    bus_c.cyc       <= '1';
    bus_c.stb       <= '1';
    
    bus_write_timer := 0;
    
    wait until rising_edge( bus_c.clk );
    
    while bus_c.ack = '0' loop
        bus_write_timer := bus_write_timer + 1;
        wait until rising_edge( bus_c.clk );
        
        exit when bus_write_timer >= write32_time_out;
        
    end loop;

    bus_c.c_type    <= bus_idle;
    bus_c.add_o     <= ( others => '0');
    bus_c.dat_o     <= ( others => '0');    
    bus_c.we        <= '0';
    bus_c.sel       <= ( others => '0');
    bus_c.cyc       <= '0';
    bus_c.stb       <= '0';

    
    
end procedure wr_32;



-- ----------------------------------------------------------------------
--  rd_32
-- ----------------------------------------------------------------------
-- usage rd_32 ( address, data , bus_record )-- read 32 bit data from a 32 bit address
--
--  Note: need read data to be a variable to be passed back to calling process;
--   If it's a signal, it's one delta out, and in the calling process
--    it will have the wrong value, the one after the clock !
--

procedure rd_32 ( 
            constant address_data   : in std_logic_vector( 31 downto 0);
            variable read_data      : out std_logic_vector( 31 downto 0);
            signal   bus_c          : inout bus_cycle
                ) is

variable  bus_read_timer : integer;

begin

    bus_c.c_type    <= rd32;
    bus_c.add_o     <= address_data;
    bus_c.we        <= '0';                 -- read cycle
    bus_c.sel       <= ( others => '1');    -- on all four banks
    bus_c.cyc       <= '1';
    bus_c.stb       <= '1';
    
    bus_read_timer := 0;

    wait until rising_edge( bus_c.clk );
    while bus_c.ack = '0' loop
        bus_read_timer := bus_read_timer + 1;
        wait until rising_edge( bus_c.clk );
        
        exit when bus_read_timer >= read32_time_out;
        
    end loop;

    read_data       := bus_c.dat_i;
    bus_c.c_type    <= bus_idle;
    bus_c.add_o     <= ( others => '0');
    bus_c.dat_o     <= ( others => '0');    
    bus_c.we        <= '0';
    bus_c.sel       <= ( others => '0');
    bus_c.cyc       <= '0';
    bus_c.stb       <= '0';

end procedure rd_32;
    

-- ----------------------------------------------------------------------
--  rmw_32
-- ----------------------------------------------------------------------
-- usage rmw_32 ( address, read_data, write_data , bus_record )-- read 32 bit data from a 32 bit address
--                                                                then write new 32 bit data to that address

procedure rmw_32 ( 
            constant address_data   : in std_logic_vector( 31 downto 0);
            variable read_data      : out std_logic_vector( 31 downto 0);
            constant write_data     : in std_logic_vector( 31 downto 0);
            signal   bus_c          : inout bus_cycle
                ) is

variable  bus_read_timer : integer;
variable  bus_write_timer : integer;

begin
-- first read
    bus_c.c_type    <= rmw32;
    bus_c.add_o     <= address_data;
    bus_c.we        <= '0';                 -- read cycle
    bus_c.sel       <= ( others => '1');    -- on all four banks
    bus_c.cyc       <= '1';
    bus_c.stb       <= '1';
    
    bus_read_timer := 0;

    wait until rising_edge( bus_c.clk );
    while bus_c.ack = '0' loop
        bus_read_timer := bus_read_timer + 1;
        wait until rising_edge( bus_c.clk );
        
        exit when bus_read_timer >= read32_time_out;
        
    end loop;

    read_data       := bus_c.dat_i;

-- now write
    bus_c.dat_o     <= write_data;    
    bus_c.we        <= '1';                 -- write cycle
    
    bus_write_timer := 0;
    
    wait until rising_edge( bus_c.clk );
    
    while bus_c.ack = '0' loop
        bus_write_timer := bus_write_timer + 1;
        wait until rising_edge( bus_c.clk );
        
        exit when bus_write_timer >= write32_time_out;
        
    end loop;

    bus_c.c_type    <= bus_idle;
    bus_c.add_o     <= ( others => '0');
    bus_c.dat_o     <= ( others => '0');    
    bus_c.we        <= '0';
    bus_c.sel       <= ( others => '0');
    bus_c.cyc       <= '0';
    bus_c.stb       <= '0';

end procedure rmw_32;


-- ----------------------------------------------------------------------
--  bkw_32
-- ----------------------------------------------------------------------
-- usage bkw_32 ( address_array, write_data_array, array_size , bus_record )
-- write each data to the coresponding address of the array

procedure bkw_32 ( 
            constant address_data   : in block_type;
            constant write_data     : in block_type;
            constant array_size     : in integer;
            signal   bus_c          : inout bus_cycle
                ) is
variable  bus_write_timer : integer;

begin
-- for each element, perform a write 32.

for n in 0 to array_size - 1 loop
    bus_c.c_type    <= bkw32;
    bus_c.add_o     <= address_data(n);
    bus_c.dat_o     <= write_data(n);    
    bus_c.we        <= '1';                 -- write cycle
    bus_c.sel       <= ( others => '1');    -- on all four banks
    bus_c.cyc       <= '1';
    bus_c.stb       <= '1';
    
    bus_write_timer := 0;
    
    wait until rising_edge( bus_c.clk );
    
        while bus_c.ack = '0' loop
            bus_write_timer := bus_write_timer + 1;
            wait until rising_edge( bus_c.clk );
            
            exit when bus_write_timer >= write32_time_out;
            
        end loop;
    bus_c.c_type    <= bus_idle;
    bus_c.add_o     <= ( others => '0');
    bus_c.dat_o     <= ( others => '0');    
    bus_c.we        <= '0';
    bus_c.sel       <= ( others => '0');
    bus_c.cyc       <= '0';
    bus_c.stb       <= '0';
end loop;

end procedure bkw_32;

-- ----------------------------------------------------------------------
--  bkr_32
-- ----------------------------------------------------------------------
-- usage bkr_32 ( address_array, read_data_array, array_size , bus_record )
-- read from each address data to the coresponding address of the array

procedure bkr_32 ( 
            constant address_data   : in block_type;
            variable read_data      : out block_type;
            constant array_size     : in integer;
            signal   bus_c          : inout bus_cycle
                ) is
variable  bus_read_timer : integer;

begin
-- for each element, perform a read  32.

for n in 0 to array_size - 1 loop
    bus_c.c_type    <= bkr32;
    bus_c.add_o     <= address_data(n);
    bus_c.we        <= '0';                 -- read cycle
    bus_c.sel       <= ( others => '1');    -- on all four banks
    bus_c.cyc       <= '1';
    bus_c.stb       <= '1';
    
    bus_read_timer := 0;
    
    wait until rising_edge( bus_c.clk );
    
    while bus_c.ack = '0' loop
        bus_read_timer := bus_read_timer + 1;
        wait until rising_edge( bus_c.clk );
        
        exit when bus_read_timer >= read32_time_out;
        
    end loop;

    read_data(n)    := bus_c.dat_i;
    bus_c.c_type    <= bus_idle;
    bus_c.add_o     <= ( others => '0');
    bus_c.dat_o     <= ( others => '0');    
    bus_c.we        <= '0';
    bus_c.sel       <= ( others => '0');
    bus_c.cyc       <= '0';
    bus_c.stb       <= '0';
end loop;

end procedure bkr_32;


-- -------------------------------------------------------------------------
end io_pack;
-- -------------------------------------------------------------------------
