-------------------------------------------------------------------------------
-- Title      : Dual port RAM
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dual_ram.vhd
-- Author     : 
-- Company    : 
-- Created    : 2005-05-26
-- Last update: 2005-05-31
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: dual port RAM with asynchronous read for QuartusII
-------------------------------------------------------------------------------
-- Copyright (c) 2005 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2005-05-26  1.0      penttin5        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dual_ram_async_read is

  generic (
    ram_width : integer := 0;
    ram_depth : integer := 0);
  port
    (
      clock1        : in  std_logic;
      clock2        : in  std_logic;
      data          : in  std_logic_vector(0 to ram_width - 1);
      write_address : in  integer range 0 to ram_depth - 1;
      read_address  : in  integer range 0 to ram_depth - 1;
      we            : in  std_logic;
      q             : out std_logic_vector(0 to ram_width - 1)
      );

  type    word is array(0 to ram_width - 1) of std_logic;
  type    ram is array(0 to ram_depth - 1) of std_logic_vector(0 to ram_width - 1);
  subtype address_vector is integer range 0 to ram_depth - 1;

--  signal read_address_reg : address_vector;

end dual_ram_async_read;

architecture rtl of dual_ram_async_read is

  signal ram_block        : RAM;
begin

  process (clock1)
  begin
    if (clock1'event and clock1 = '1') then
      if (we = '1') then
        ram_block(write_address) <= data;
      end if;
    end if;
  end process;

  
  process (clock2)
  begin
    if (clock2'event and clock2 = '1') then
    --q                <= ram_block(read_address);
    --     read_address_reg <= read_address;
    end if;
 end process;

    q <= ram_block (read_address);
    
end rtl;
