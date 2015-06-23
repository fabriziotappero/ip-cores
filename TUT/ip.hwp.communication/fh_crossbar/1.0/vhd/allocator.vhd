-----------------------------------------------------------------
-- File         : allocator.vhd
-- Description  : Allocates one-sided crossbar buses
-- Designer     : Hannu Penttinen 28.08.2006
--
-- Last modified
-----------------------------------------------------------------
-------------------------------------------------------------------------------
-- Copyright (c) 2011 Tampere University of Technology
-------------------------------------------------------------------------------
--  This file is part of Transaction Generator.
--
--  Transaction Generator is free software: you can redistribute it and/or
--  modify it under the terms of the Lesser GNU General Public License as
--  published by the Free Software Foundation, either version 3 of the License,
--  or (at your option) any later version.
--
--  Transaction Generator is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  Lesser GNU General Public License for more details.
--
--  You should have received a copy of the Lesser GNU General Public License
--  along with Transaction Generator.  If not, see
--  <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use Work.txt_util.all;

entity allocator is
  generic (
    n_ag_g              :     integer;
    addr_width_g        :     integer;
    switch_addr_width_g :     integer
    );
  port(
    clk                 : in  std_logic;
    rst_n               : in  std_logic;
    req_addr_in         : in  std_logic_vector(n_ag_g * addr_width_g - 1 downto 0);
    req_in              : in  std_logic_vector(n_ag_g - 1 downto 0);
    hold_in             : in  std_logic_vector(n_ag_g - 1 downto 0);
    grant_out           : out std_logic_vector(n_ag_g - 1 downto 0);
    src_id_out          : out std_logic_vector(n_ag_g * switch_addr_width_g - 1 downto 0)
    );
end allocator;

architecture rtl of allocator is

  component arbiter
    generic (
      arb_width_g : integer
      );
    port (
      clk       : in  std_logic;
      rst_n     : in  std_logic;
      req_in    : in  std_logic_vector(arb_width_g - 1 downto 0);
      hold_in   : in  std_logic_vector(arb_width_g - 1 downto 0);
      grant_out : out std_logic_vector(arb_width_g - 1 downto 0)
      );
  end component;

  type req_vec_type is array (0 to n_ag_g - 1)
    of std_logic_vector(n_ag_g - 1 downto 0);

  signal grant_from_arb : req_vec_type;
  signal grant_tmp        : std_logic_vector(n_ag_g - 1 downto 0);
  signal req            : req_vec_type;

  type   src_id_type is array (0 to n_ag_g - 1) of std_logic_vector(switch_addr_width_g - 1 downto 0);
  signal src_id_r : src_id_type;

begin  -- rtl

  -- generate arbiters for each dst
  gen_arbs : for i in n_ag_g - 1 downto 0 generate
    arb : arbiter
      generic map (
        arb_width_g => n_ag_g
        )
      port map (
        clk       => clk,
        rst_n     => rst_n,
        req_in    => req(i),
        hold_in   => hold_in,
        grant_out => grant_from_arb(i)
        );
  end generate gen_arbs;

  -- maps req_addr_in from input port to 2-D req for arbs
  -- req(1)(2) <=> src 2 requests dst 1
  map_requests : process (req_in, req_addr_in)
  begin  -- process map_requests

    for i in n_ag_g - 1 downto 0 loop
      for j in n_ag_g - 1 downto 0 loop

        if req_addr_in((i+1) * addr_width_g - 1 downto i * addr_width_g) =
          std_logic_vector(to_unsigned(j, addr_width_g))
        then
          req(j)(i) <= req_in(i);
        else
          req(j)(i) <= '0';
        end if;
      end loop;  -- j


    end loop;  -- i

  end process map_requests;

  -- maps grant from arb to output port
  -- grant_from_arb(1)(2) <=> dst 1 granted for src 2
  map_grants : process (grant_from_arb)
  begin  -- process map_grants

    grant_tmp <= (others => '0');

    for i in n_ag_g - 1 downto 0 loop
      for j in n_ag_g - 1 downto 0 loop
        if grant_from_arb (i)(j) = '1' then
          grant_tmp(j) <= '1';
        end if;
      end loop;  -- j
    end loop;  -- i

  end process map_grants;

  -- register grant_out
  reg_grant_out : process (clk, rst_n)
  begin  -- process reg_grant_out
    if rst_n = '0' then                 -- asynchronous reset (active low)
      grant_out <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      grant_out <= grant_tmp;
    end if;
  end process reg_grant_out;


  
  ctrl_switches : process (clk, rst_n)
    variable req_addr_v : integer;
  begin  -- process ctrl_switches
    if rst_n = '0' then                 -- asynchronous reset (active low)
      src_id_r <= (others => std_logic_vector(to_unsigned(n_ag_g, switch_addr_width_g)));

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- Default assigment: Illegal src_id 

      -- a) osoite vakio koko siirron ajan
       src_id_r <= (others => std_logic_vector (to_unsigned(n_ag_g, switch_addr_width_g)));

       for i in n_ag_g - 1 downto 0 loop

         if grant_tmp(i) = '1' then
           req_addr_v := to_integer (unsigned(req_addr_in((i+1)*addr_width_g - 1 downto i*addr_width_g)));
           src_id_r (req_addr_v) <= std_logic_vector(to_unsigned(i, switch_addr_width_g));
         end if;  -- grant_tmp
       end loop;  -- i

--       -- b) uus yritys, osoite ei tarvi olla vakio koko siirron ajan
--        for i in n_ag_g - 1 downto 0 loop
--          if grant_tmp(i) = '1' then
--            if req_in (i) = '1' then
--              assert false report "Start of tx, store addr" severity note;
--              -- Start of the transfer
--              -- set dst mux to receive src
--              req_addr_v := to_integer (unsigned(req_addr_in((i+1)*addr_width_g - 1 downto i*addr_width_g)));
--              src_id_r (req_addr_v) <= std_logic_vector(to_unsigned(i, switch_addr_width_g));
--             else
--              assert false report "keep old addr" severity note;
--            end if;
--          else
--            -- No grant          
-- --           -- src_id_r (mikä indeksi??)            <= std_logic_vector (to_unsigned(n_ag_g, switch_addr_width_g));

--            for dst in 0 to n_ag_g-1 loop
--              if src_id_r( dst) = std_logic_vector(to_unsigned(i, switch_addr_width_g)) then
--                assert false report "reset src_id_r" severity note;
--                src_id_r (dst) <= std_logic_vector(to_unsigned(n_ag_g, switch_addr_width_g));
--              end if;             
--            end loop;  -- dst

--          end if;  -- grant_tmp
--        end loop;  -- i
      -- b) loppuu


      
    end if;
  end process ctrl_switches;

  
  -- map src_id_r to std_logic_vector and to out port
  map_src_id_out : process (src_id_r)
  begin  -- process map_src_id_out
    for i in n_ag_g - 1 downto 0 loop
      src_id_out((i+1)* switch_addr_width_g - 1 downto i*switch_addr_width_g) <= src_id_r(i);
    end loop;  -- i
  end process map_src_id_out;

end rtl;
