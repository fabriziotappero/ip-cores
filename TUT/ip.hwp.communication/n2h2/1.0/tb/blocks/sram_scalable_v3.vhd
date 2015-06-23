---------------------------------------------------------------------------------
-- Original code modified by Vesa Lahtinen and Tero Kangas
-- Both address and data width are now configurable
--
-- Modified by Ari Kulmala. Reads in integers and stores them into
-- consequent addresses, interface modified
-- to resemble the current scheme.
--
-- sram_scalable.vhdl
--
-- Original code:
--
-- sram64kx8.vhd 
-- standard SRAM vhdl code, 256K*32 Bit,
--                          simplistic model without timing
--                          with startup initialization from file
--
-- (C) 1993,1994 Norman Hendrich, Dept. Computer Science
--                                University of Hamburg
--                                22041 Hamburg, Germany
--                                hendrich@informatik.uni-hamburg.de
--
-- initialization code taken and modified from DLX memory-behaviour.vhdl: 
--                    Copyright (C) 1993, Peter J. Ashenden
--                    Mail:       Dept. Computer Science
--                                University of Adelaide, SA 5005, Australia
--                    e-mail:     petera@cs.adelaide.edu.au
----------------------------------------------------------------------------------

use std.textio.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_arith.all;

entity sram_scalable is
  generic (
    rom_data_file_name_g : string  := "none";
    output_file_name_g   : string  := "none";
    write_trigger_g      : natural := 0;  --dumps the memory contents to a file
    addr_width_g         : integer := 0;  --width of address bus
    data_width_g         : integer := 0   --width of data bus
    );
  port (
    cs1_n_in   : in    std_logic;         -- not chip select 1
    cs2_in     : in    std_logic;         -- cs2. both have to be active
                                          -- for memory to do something
    addr_in    : in    std_logic_vector(addr_width_g-1 downto 0);
    data_inout : inout std_logic_vector(data_width_g-1 downto 0);
    we_n_in    : in    std_logic;         -- not write enable
    oe_n_in    : in    std_logic          -- not output enable 
    );
end sram_scalable;



architecture sram_behaviour of sram_scalable is
begin

  mem : process

    constant low_address_c  : natural := 0;
    constant high_address_c : natural := 2**addr_width_g - 1;

    subtype word is std_logic_vector(data_width_g-1 downto 0);

    type memory_array is
      array (natural range low_address_c to high_address_c) of word;

    variable mem_v     : memory_array;

    
    variable address_v : natural;
    variable l       : line;


   ----------------------------------------------------------------------------         
    -- Load initial memory contents from text-file,
    -- One decimal number per line is read
    -- First value of line goes to location mem(0), value on 2nd line goes to mem(1) and so on
    ---------------------------------------------------------------------------
    procedure load(mem : out memory_array) is

      file binary_file : text is in rom_data_file_name_g;
      variable l       : line;
      variable a, i    : natural;
      variable val     : natural;
      variable c       : integer;

    begin
      
      -- first initialize the ram array with zeroes
      for a in low_address_c to high_address_c loop
        mem(a) := (others => '0');
      end loop;
      
      a := low_address_c;               -- turha sijoitus?

      
      -- and now read the data file
      for a in low_address_c to high_address_c loop
        if not endfile(binary_file) then
          readline(binary_file, l);
          read (l, c);
          -- convert integer value to std_logic_vector and store it into mem
          mem(a) := conv_std_logic_vector(c, data_width_g);
        end if;
      end loop;
    end load;

    
   ----------------------------------------------------------------------------       
    -- Dump memory contents to a text-file
    -- Line format: address data
    -- Nuber format: decimal numbers
    ---------------------------------------------------------------------------
    procedure dump(mem : in memory_array) is

      file binary_file : text is out output_file_name_g;
      variable l       : line;
      variable i       : natural;
      variable val2    : integer;

    begin
      report "Dump memory contents into txt file";
      -- and now write the data into a file
      for i in 0 to high_address_c loop
        val2 := conv_integer(mem(i));
        write(l, i);
        write(l, ' ');
        write(l, val2);
        writeline(binary_file, l);
      end loop;
    end dump;


    
    
  begin  -- mem : process

    -- sram initialization:
    -- first initialize the ram array with zeroes
    for a in low_address_c to high_address_c loop
      mem_v(a) := (others => '0');
    end loop;


    if (rom_data_file_name_g /= "none") then
      load(mem_v);
    end if;


    

    ----------------------------------------------------------------------------
    -- Process memory cycles,
    -- after init the model stays in this loop forever
    ---------------------------------------------------------------------------
    loop
      --
      -- wait for chip-select,
      -- 
      if (cs1_n_in = '0') and (cs2_in = '1') then

        -- decode address
        address_v := conv_integer(unsigned(addr_in));

        if we_n_in = '0' then
          --- write cycle
          mem_v(address_v) := data_inout;
          data_inout <= (others => 'Z');

        elsif we_n_in = '1' then
          -- read cycle
          if oe_n_in = '0' then
            data_inout <= mem_v(address_v);
          else
            data_inout <= (others => 'Z');
          end if;

        else
          data_inout <= (others => 'Z');
        end if;
      else
        --
        -- chip not selected, disable output
        --
        data_inout <= (others => 'Z');
      end if;


      
      -------------------------
      -- For debugging: accessing certain location, dumps memory contents to file
      if address_v = write_trigger_g then
        if output_file_name_g /= "none" then
          dump(mem_v);
        end if;
      end if;
      -----------------------

      wait on cs1_n_in, cs2_in, we_n_in, oe_n_in, addr_in, data_inout;
    end loop;
  end process;


end sram_behaviour;


configuration cfg_sram of sram_scalable is
  for sram_behaviour
  end for;
end cfg_sram;

