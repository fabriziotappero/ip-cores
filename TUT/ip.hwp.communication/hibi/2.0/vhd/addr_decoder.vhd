-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- File        : addr_decode.vhdl
-- Description : Decodes the incoming address
-- Author      : Erno Salminen
-- e-mail      : erno.salminen@tut.fi
-- Project     : huuhaa
-- Design      : Do not use term design when you mean system
-- Date        : 29.04.2002
-- Modified    : 05.05.2002 Vesa Lahtinen Optimized for synthesis
--
--
-- 03.02.2003   Comparison_type input added, es
--              0=normal, 1=negated comparison
--              negation = xor comparison_type with addr match signal
-- 15.05.2003   Xor with comparison_type added
-- 27.07.2004   Clk+Rst removed, ES
-- 19.08.2004   ES: Index_Of_Lowest_Compared_Bit removed
--
--
-- 15.12.04     ES  names changes
-- 21.01.05     ES: constants for disbaling features
-- 07.02.05     ES new generics
-- TO DO:
-- BASE_ID SHOULD BE ADDED SO THAT HIERARCHICAL SYSTEMS CAN BE CONFIGURED

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.hibiv2_pkg.all;                -- for commands+comm_width

entity addr_decoder is
  generic (
    data_width_g      :     integer := 32;
    addr_width_g      :     integer := 32;  -- in bits
    id_width_g        :     integer := 4;
    id_g              :     integer := 5;
    base_id_g         :     integer := 5;
    addr_g            :     integer := 46;
    cfg_re_g          :     integer := 1;   -- 07.02.05
    cfg_we_g          :     integer := 1;   -- 07.02.05
    multicast_en_g    :     integer := 1;   -- 07.02.05
    inv_addr_en_g     :     integer := 0
    );
  port (
    addr_in           : in  std_logic_vector ( addr_width_g -1 downto 0);
    comm_in           : in  std_logic_vector ( comm_width_c -1 downto 0);
    enable_in         : in  std_logic;
    base_id_match_out : out std_logic;
    addr_match_out    : out std_logic
    );

end addr_decoder;


architecture rtl of addr_decoder is

  -- added 31,01.05
  -- changed to genrics values 07.02.05
  -- constant multicast_en_c      : integer range 0 to 1 := 1;
  -- constant enable_cfg_write_c  : integer range 0 to 1 := 1;
  -- constant enable_cfg_read_c   : integer range 0 to 1 := 1;


  -- Signals
  -- Index_Of_Lowest_Compared_Bitin voisis muuttaa sopivaksi integeriksi!
  -- signal Index_Of_Lowest_Compared_Bit : integer range 0 to addr_width_g;
  signal addr_in_slice                : std_logic_vector ( addr_width_g-1 downto 0);
  signal mask                         : std_logic_vector ( addr_width_g-1 downto 0);

  constant base_addr_c   : std_logic_vector ( addr_width_g -1 downto 0) := conv_std_logic_vector ( addr_g, addr_width_g);
  constant inv_addr_en_c : std_logic                                    := conv_std_logic_vector ( inv_addr_en_g, 1)(0);

  
  --   -- Debug signals for determining the valid addresses 
  --   -- These can be removed in synthesis!
  --   signal Top_addr          : std_logic_vector (addr_width_g-1 downto 0);
  --   signal multicast_00_addr : std_logic_vector (addr_width_g-1 downto 0);
  --   signal multicast_01_addr : std_logic_vector (addr_width_g-1 downto 0);
  --   signal multicast_10_addr : std_logic_vector (addr_width_g-1 downto 0);
  --   signal multicast_11_addr : std_logic_vector (addr_width_g-1 downto 0);



begin  -- rtl

  -- PROCESSES ----------------------------------------------------------------

  
  
  -- 1) 
  -- Count the number of bits needed in address comparison
  -- Needed bit range = (highest bits) downto (lowest '1' bit)

  -- !!!!!!!!!!!!!!!!
  -- 09.02.2005
  -- Muuta funktioksi ja jatkuvaksi sijoitukseksi
  -- !!!!!!!!!!!!!!!!
  
  Count_Compared_Bits          : process (mask) --(addr_in) 
  --Count_Compared_Bits          : process

    variable idx_found_var     : integer;
    variable mask_internal_var : std_logic_vector ( addr_width_g -1 downto 0);
  begin  -- process Count_Compared_Bits

    idx_found_var     := 0;
    mask_internal_var := (others => '1');

    perse : for i in 0 to (addr_width_g - 1) loop
      if base_addr_c (i) = '0' and idx_found_var = 0 then
        mask_internal_var (i) := '0';
      else
        idx_found_var         := 1;
        mask_internal_var (i) := '1';

      end if;
    end loop;  -- i

    -- Assign the Index value to signal
    mask                        <= mask_internal_var;

    -- NOTE! If base addr= 0, the Index goes to maximum value addr_width_g
    -- => mask is all zeros => no bits are used for comparison =>  all addresses match 
    -- Must be careful because the biggest valid Index is addr_width_g-1!

    -- 25.02.05 wait;
  end process Count_Compared_Bits;

  
  -- 2) CONCURRENT ASSIGNMENT
  addr_in_slice         <= addr_in and mask;


  
  


  -- 3) PROC
  -- Comparison
  -- The compared bits are determines with incoming command
  -- Four choices : nornal, multicast, config or idle.
  

  compare_addr : process (addr_in,
                          addr_in_slice,
                          comm_in,
                          enable_in
                          )

    -- For the part of the address telling the multicast type
    variable multicast_Part_var : std_logic_vector(1 downto 0);
  begin  -- process

    -- Two lowest bits define the compared bits in multicast
    multicast_part_var := addr_in (1 downto 0);

    if enable_in = '1' then

      if comm_in = w_data_c
        or comm_in = w_msg_c
        or comm_in = r_data_c
      then

        -- Direct comparison        
        -- inv_addr_en_c
        -- 0 = normal
        -- 1 = addr ranges inverted (useful in bridges)

        if base_addr_c = addr_in_slice then
          addr_match_out <= '1' xor inv_addr_en_c;
        else
          addr_match_out <= '0' xor inv_addr_en_c;  
        end if;
        

        -- 31.01.05
      elsif multicast_en_g = 1
        and (comm_in = multicast_data_c
             or comm_in = multicast_msg_c)
      --elsif comm_in = multicast_data_c
      --  or comm_in = multicast_msg_c
      then

        -- Compare only part of the address
        case multicast_part_var is
          when "00" =>
            -- Vertaillaan puolta osoitebiteista
            if addr_in (addr_width_g-1 downto addr_width_g/2)
                 = base_addr_c (addr_width_g-1 downto addr_width_g/2) then
              addr_match_out <= '1' xor inv_addr_en_c;  
            else
              addr_match_out <= '0' xor inv_addr_en_c;  
            end if;

          when "01" =>
            -- Vertaillaan neljasosaa osoitebiteista
            if addr_in (addr_width_g-1 downto addr_width_g - (addr_width_g/4))
                = base_addr_c (addr_width_g-1 downto addr_width_g - (addr_width_g/4)) then
              addr_match_out <= '1' xor inv_addr_en_c;  
            else
              addr_match_out <= '0' xor inv_addr_en_c;  
           end if;

          when "10" =>
            -- Vertaillaan kahdeksasosaa osoitebiteista
            if addr_in (addr_width_g-1 downto addr_width_g - (addr_width_g/8))
                = base_addr_c (addr_width_g-1 downto addr_width_g - (addr_width_g/8)) then
              addr_match_out <= '1' xor inv_addr_en_c;  
            else
              addr_match_out <= '0' xor inv_addr_en_c;  
            end if;

            
          when others =>
            -- Vertaillaan kahdeksasosaa osoitebiteista
            -- With 8b addr, this does no comparison and all addresses (0-255)
            -- yield an address match.

            if addr_width_g/16 = 0 then
              -- Jos osoite 8b tai vahemman
              -- lisatty 11.04
              addr_match_out   <= '1' xor inv_addr_en_c;
            else
              if addr_in (addr_width_g-1 downto addr_width_g - (addr_width_g/16))
                 = base_addr_c (addr_width_g-1 downto addr_width_g - (addr_width_g/16)) then
                addr_match_out <= '1' xor inv_addr_en_c;
              else
                addr_match_out <= '0' xor inv_addr_en_c;
              end if;  -- addr_in
            end if;  -- addr_width_g

        end case;


        -- Condition modified 2007/04/17
      elsif (cfg_re_g = 1
             or cfg_we_g = 1)
        and (comm_in = w_cfg_c
             or comm_in = r_cfg_c)
--       elsif cfg_re_g = 1
--         and cfg_we_g = 1
--         and (comm_in = w_cfg_c
--              or comm_in = r_cfg_c)
      then

        -- Compare the id-part of the config address 
        -- and check if id-part is 0 which means configuration broadcast

        if (addr_in ( addr_width_g-1 downto addr_width_g - id_width_g) = id_g)
          or (addr_in ( addr_width_g-1 downto addr_width_g - id_width_g) = conv_std_logic_vector(0, id_width_g))
        then

          addr_match_out <= '1';-- xor inv_addr_en_c;  
        else
          addr_match_out <= '0';-- xor inv_addr_en_c;  
        end if;

      else
        -- Idle
        addr_match_out <= '0';
      end if;
      

    else
      -- enable_in = 0 => do nothing
      addr_match_out <= '0';
    end if;  -- enable

  end process;


--   -- 4) PROC  
--   -- Assign value for test signals
--   -- This can be removed in synthesis!
--   testi: process (base_addr_c, Index_Of_Lowest_Compared_Bit)
--   begin  -- process testi
    
--     Top_addr (addr_width_g-1 downto conv_integer (Index_Of_Lowest_Compared_Bit))
--       <= base_addr_c (addr_width_g-1 downto conv_integer (Index_Of_Lowest_Compared_Bit));
--     Top_addr (conv_integer (Index_Of_Lowest_Compared_Bit)-1 downto 0) <= (others => '1');    

--     multicast_00_addr (addr_width_g-1 downto addr_width_g/2)
--       <= base_addr_c (addr_width_g-1 downto addr_width_g/2);
--     multicast_00_addr (addr_width_g/2 -1 downto 0) <= (others => '0');

--     multicast_01_addr (addr_width_g-1 downto addr_width_g -addr_width_g/4)
--       <= base_addr_c (addr_width_g-1 downto addr_width_g -addr_width_g/4);
--     multicast_01_addr (addr_width_g-addr_width_g/4 -1 downto 0) <= (others => '0');      

--     multicast_10_addr (addr_width_g-1 downto addr_width_g -addr_width_g/8)
--       <= base_addr_c (addr_width_g-1 downto addr_width_g -addr_width_g/8);
--     multicast_10_addr (addr_width_g-addr_width_g/8 -1 downto 0) <= (others => '0');      

--     multicast_11_addr (addr_width_g-1 downto addr_width_g -addr_width_g/16)
--       <= base_addr_c (addr_width_g-1 downto addr_width_g -addr_width_g/16);
--     multicast_11_addr (addr_width_g-addr_width_g/16 -1 downto 0) <= (others => '0');      
--      
--  end process;





  

end rtl;
