-------------------------------------------------------------------------------
-- File        : switch_matrix.vhdl
-- Description : Full crossbar switch matrix. One mux per agent
-- 
-- Author      : Hannu Penttinen
-- Date        : 30.08.2006
-- Modified    : 
--
--
-------------------------------------------------------------------------------
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

entity switch_matrix is
  generic (
    n_ag_g       :     integer;
    data_width_g :     integer;
    addr_width_g :     integer
    );
  port (
    src_id_in    : in  std_logic_vector (n_ag_g * addr_width_g - 1 downto 0);
    av_in        : in  std_logic_vector (n_ag_g - 1 downto 0);
    data_in      : in  std_logic_vector (n_ag_g * data_width_g - 1 downto 0);
    we_in        : in  std_logic_vector (n_ag_g - 1 downto 0);
    full_out     : out std_logic_vector (n_ag_g - 1 downto 0);
    av_out       : out std_logic_vector (n_ag_g - 1 downto 0);
    data_out     : out std_logic_vector (n_ag_g * data_width_g - 1 downto 0);
    we_out       : out std_logic_vector (n_ag_g - 1 downto 0);
    full_in      : in  std_logic_vector (n_ag_g - 1 downto 0)
    );

end switch_matrix;


architecture rtl of switch_matrix is

  type   src_id_type is array (n_ag_g - 1 downto 0) of integer range n_ag_g downto 0;
  signal src_id : src_id_type;

  type data_array_type is array (n_ag_g downto 0) of std_logic_vector (data_width_g - 1 downto 0);
  signal pkt          : data_array_type;
  signal data_to_out_arr : data_array_type;
  signal we           : std_logic_vector (n_ag_g downto 0);
  signal av           : std_logic_vector (n_ag_g downto 0);
begin  -- rtl

  -- map input std_logic_vector to internal array type
  map_src_id : for i in n_ag_g - 1 downto 0 generate
    src_id(i) <= to_integer (unsigned(src_id_in((i+1) * addr_width_g - 1 downto i * addr_width_g)));
  end generate map_src_id;

  pkt (n_ag_g) <= (others => '1');
  we (n_ag_g)  <= '0';
  av (n_ag_g)  <= '0';

  -- map input std_logic_vector to internal array type
  connect_io : for i in n_ag_g - 1 downto 0 generate
    -- from agents to crossbar
    pkt(i) <= data_in((i+1)*data_width_g - 1 downto i*data_width_g);
    we(i)  <= we_in  (i);
    av(i)  <= av_in  (i);
  end generate connect_io;

  -- full signal
  status_muxes : process (full_in, src_id)
  begin  -- process status_muxes  
    full_out <= (others => '0');
    for i in n_ag_g - 1 downto 0 loop
      if src_id(i) /= n_ag_g then
        full_out(src_id(i)) <= full_in(i);
      end if;
    end loop;
  end process status_muxes;

  -- data multiplexers
  gen_data_muxes : for i in n_ag_g - 1 downto 0 generate
    data_to_out_arr(i) <= pkt(src_id(i));
    we_out         (i) <= we (src_id(i));
    av_out         (i) <= av (src_id(i));
  end generate gen_data_muxes;

  -- map from internal array type to std_logic_vector output
  map_output : for i in n_ag_g - 1 downto 0 generate
    data_out((i+1) * data_width_g - 1 downto i * data_width_g) <= data_to_out_arr(i);
  end generate map_output;

end rtl;
