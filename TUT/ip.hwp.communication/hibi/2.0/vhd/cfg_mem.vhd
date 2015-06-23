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
-- File        : cfg_mem.vhdl
-- Description : Stores the configuration values. There can be more than one
--               configuration pages.
-- Author      : Erno Salminen
-- e-mail      : erno.salminen@tut.fi
-- Project     : huuhaa
-- Design      : Do not use term design when you mean system
-- Date        : 29.04.2002
-- Modified    : Vesa Lahtinen 10.05.2002 Functionality added
--
-- 24.07.02        ES: removed outputs Curr_cycle and Time_Frame_Length
-- 14.11.02        ES: changed the type of memory register
-- 18.11.02        ES: time slot signal decoding separated
-- 03.02.03        ES: comparison_type added
-- 15.04.03        ES: base addr made constant to speed up the  addr decoder
-- 19.05.03        ES: counter_width changed to generic value
-- 31.07.03        ES: added checks for illegal page and param nums
--                      In illegal cases, internal write and read enable
--                      signals are reset to zero
-- 
--
-- 09.12.04         TK: bit width of ID and Num_Of_Agents signals/port changed
--                     from Counter_Width to ID_Width
-- 15.12.04        ES: names changed
-- 20.01.05        ES: constant for enabling/disabling read operation
-- 21.01.05        ES: constant for enabling/disabling write operation
--                      -> enable=0 cfg_mem is rom, same code can be used for
--                      both ram and rom
-- 03.02.05        ES  addr_width_g is now in BITS! New generic cfg_rom_en_g
--                      added
-- 28.02.05       ES generic cfg_we and cfg_re added, cfg_rom_en_g removed
-- 16.12.05       ES Extra parameters are removed
--                   Use package for intializing time_slots
-- TO DO:         Time_slot_r should be implemented with records to benefit
--                from the modified signal widths made by TK in 9.12.04 
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.cfg_init_pkg.all;              -- init values for tiem slots

entity cfg_mem is
  generic (
    id_width_g       : integer := 4;
    id_g             : integer := 5;
    base_id_g        : integer := 5;
    data_width_g     : integer := 16;     -- in bits. 14.12.05: TURHA??
    -- addr_width_g     : integer := 16;  -- in bits
    counter_width_g  : integer := 8;
    cfg_addr_width_g : integer := 7;      -- 16.12.05

    inv_addr_en_g      : integer := 0;
    addr_g             : integer := 46;
    prior_g            : integer := 2;
    max_send_g         : integer := 50;

    arb_type_g : integer := 0;
    
    n_agents_g     : integer := 4;
    n_cfg_pages_g  : integer := 1;
    n_time_slots_g : integer := 0;
    -- n_extra_params_g : integer := 0;
    cfg_re_g       : integer := 0;
    cfg_we_g       : integer := 0
    );

  port (
    clk            : in std_logic;
    rst_n          : in std_logic;

    -- addr_in could be narrower, since id is only in addr decoder
    addr_in              : in  std_logic_vector ( cfg_addr_width_g -1 downto 0);  --04.03.05
    data_in              : in  std_logic_vector ( data_width_g -1 downto 0);
    re_in                : in  std_logic;
    we_in                : in  std_logic;

    curr_slot_ends_out   : out std_logic;
    curr_slot_own_out    : out std_logic;
    next_slot_starts_out : out std_logic;
    next_slot_own_out    : out std_logic;
    dbg_out              : out integer range 0 to 100;  -- For debug

    data_out     : out std_logic_vector ( data_width_g-1 downto 0);
    arb_type_out : out std_logic_vector ( 1 downto 0);
    n_agents_out : out std_logic_vector ( id_width_g-1 downto 0);
    max_send_out : out std_logic_vector ( counter_width_g-1 downto 0);
    prior_out    : out std_logic_vector ( id_width_g-1 downto 0);
    pwr_mode_out : out std_logic_vector ( 1 downto 0)
    );
end cfg_mem;


architecture rtl of cfg_mem is

  -- Calculate minimum of 1 and "value"
  -- Required for reserving signals for tslots ans extra_params
  -- (Design compiler does not handle empty arrays (e.g. 0 downto -1),
  -- Precision handles them well)
  function max_with_1 (
    constant value : integer)
    return integer is
  begin  -- max_with_1
    if value = 0 then
      return 1;
    else
      return value;
    end if;
  end max_with_1;

  constant n_time_slots_tmp_c   : integer := max_with_1 ( n_time_slots_g);
  -- constant n_extra_params_tmp_c : integer := max_with_1 ( n_extra_params_g);

  function log2 (
    constant value : integer)
    return integer is
    variable temp : integer := 1;
    variable counter : integer := 0;
  begin  -- log2
    -- Unbounded loops are NOT synthesizable
    
    --     while temp < value loop
    --       temp                     := temp*2;
    --       counter                  := counter+1;
    --     end loop;

    temp        := 1;
    counter     := 0;
    for i in 0 to 30 loop
      if temp < value then
        temp    := temp*2;
        counter := counter+1;
      end if;
    end loop;

    
    return counter;    
  end log2;

  constant page_addr_width_c  : integer := log2 (n_cfg_pages_g) + 1;

  -- Calculate the maximum size of configuration
  -- memory page. There are 8 parameters and  address (which nowadays requires exactly one
  -- place in mem), each time slots requires 3 parameters (start, stop, owner),
  -- and there may be some application specific parameters as well.
  -- E.g. if n_time_slots_g=n_extra_params_g=0 then page_size_c= 8+1+3+1= 13 parameters
  constant page_size_c : integer := 8 + 1 + ( n_time_slots_tmp_c * 3); -- + n_extra_params_tmp_c;

  -- 16.12.05
  constant param_addr_width_c : integer := log2 (page_size_c);
  constant cfg_addr_width_c   : integer := param_addr_width_c + page_addr_width_c;
  -- Signals can be viewed from Modelsim. These are not used for any other purpose.
  signal   pag                : integer := page_addr_width_c;
  signal   par                : integer := param_addr_width_c;
  signal   cfg_a              : integer := cfg_addr_width_c;


  
  -- Logic for dbg_out adds roughly 16% to area (at least when 16b data is used) 
  constant dbg_level          : integer range 0 to 3 := 0;  -- 0= no debug, use 0 for synthesis
  --  constant enable_cfg_read_c  : integer range 0 to 1 := 1;
  --  constant enable_cfg_write_c : integer range 0 to 1 := 1-cfg_rom_en_g;


  -- Define indexes for parameters
  constant ind_cycle_c : integer := 0;
  constant ind_prior_c : integer := 1;
  constant ind_n_ag_c  : integer := 2;  -- Num of AGents
  constant ind_arb_c   : integer := 3;
  constant ind_pwr_c   : integer := 4;
  constant ind_msend_c : integer := 5;
  constant ind_frame_c : integer := 6;  -- ei tarvita ellei ole slotteja!
  constant ind_inva_c  : integer := 7;  -- INVert Addr
  constant ind_baddr_c : integer := 8;  -- address requires nowadays exactly one memory slot
  constant ind_tslot_c : integer := 9;
  constant ind_extra_c : integer := ind_tslot_c + (n_time_slots_tmp_c *3);


 
  -- Output registers for time slots
  signal curr_slot_ends_r   : std_logic;
  signal curr_slot_own_r    : std_logic;
  signal next_slot_starts_r : std_logic;
  signal next_slot_own_r    : std_logic;

  -- Register for storing current page number,
  -- page number zero reserved for special purposes!
  signal curr_page_r : integer range 1 to n_cfg_pages_g;

  
  -- Own register type for clock cycle counters
  type curr_cycle_array_type is array ( 1 to n_cfg_pages_g) of std_logic_vector (counter_width_g-1 downto 0);
  signal curr_cycle_r : curr_cycle_array_type;

  

  -- Internal signals for address slices
  signal page_num  : integer range 0 to n_cfg_pages_g;
  signal param_num : integer range 0 to page_size_c;

  -- Internal write and read enable
  -- If page and param numbers are valid, these are identical to inputs
  -- Otherwise, they are reset to zero
  signal we_int : std_logic;
  signal re_int : std_logic;



  -- Define type and register for configuration memory
  -- Use record instead of array => fields can have different widths
  type cfg_page_type is record
                               Prior : std_logic_vector ( id_width_g-1 downto 0);
                               N_ag  : std_logic_vector ( id_width_g-1 downto 0);
                               Arb   : std_logic_vector ( 1 downto 0);
                               Power : std_logic_vector ( 1 downto 0);
                               MSend : std_logic_vector ( counter_width_g-1 downto 0);
                               Frame : std_logic_vector ( counter_width_g-1 downto 0);
                               --Inva  : std_logic;
                             end record;

  type cfg_array is array ( 1 to n_cfg_pages_g) of cfg_page_type;
  signal memory_r : cfg_array;


  
  -- Own register type for time slots (conf_page, time_slot_param)
  -- Note the indexing! This way the incoming addr can be used for indexing without modification..

  type tslot_page_type is array ( (ind_tslot_c) to (ind_tslot_c + 3*n_time_slots_tmp_c-1))
    of std_logic_vector ( counter_width_g-1 downto 0);

  type tslot_page_array_type is array (1 to n_cfg_pages_g) of tslot_page_type;

  signal tslot_r              : tslot_page_array_type;


  -- 19.12.2005
  -- Slot owner needs (usually) less bits than start and stop times
  type tslot_start_type is array ( (ind_tslot_c)                        to (ind_tslot_c + 1*n_time_slots_tmp_c-1)) of std_logic_vector ( counter_width_g-1 downto 0);
  type tslot_stop_type is array  ( (ind_tslot_c + 1*n_time_slots_tmp_c) to (ind_tslot_c + 2*n_time_slots_tmp_c-1)) of std_logic_vector ( counter_width_g-1 downto 0);
  type tslot_id_type is array    ( (ind_tslot_c + 2*n_time_slots_tmp_c) to (ind_tslot_c + 3*n_time_slots_tmp_c-1)) of std_logic_vector ( id_width_g-1 downto 0);

  type tslot_start_array_type is array (1 to n_cfg_pages_g) of tslot_start_type;
  type tslot_stop_array_type is array (1 to n_cfg_pages_g) of tslot_stop_type;
  type tslot_id_array_type is array (1 to n_cfg_pages_g) of tslot_id_type;

  signal tslot_start_r : tslot_start_array_type;
  signal tslot_stop_r  : tslot_stop_array_type;
  signal tslot_id_r    : tslot_id_array_type;


  
--   -- Own register type for extra parameters (conf_page, extra_param_num)
--   -- Note the indexing! This way the incoming addr can be used for indexing without modification..
--   -- type extra_param_page_type is array (ind_extra_c to ind_extra_c + n_extra_params_g-1)
--   --  of std_logic_vector ( data_width_g-1 downto 0);
--   type extra_param_page_type is array (ind_extra_c to ind_extra_c + n_extra_params_tmp_c-1)
--     of std_logic_vector ( data_width_g-1 downto 0);
--   type extra_param_array_type is array (1 to n_cfg_pages_g) of extra_param_page_type;
--   signal extra_param_r : extra_param_array_type;


  
  
  
  
begin  -- rtl

  -- Continuous assignments
  curr_slot_ends_out   <= curr_slot_ends_r;
  curr_slot_own_out    <= curr_slot_own_r;
  next_slot_starts_out <= next_slot_starts_r;
  next_slot_own_out    <= next_slot_own_r;


  prior_out    <= memory_r (curr_page_r).Prior;  --1
  n_agents_out <= memory_r (curr_page_r).N_ag;   --2
  arb_type_out <= memory_r (curr_page_r).Arb;    --3
  pwr_mode_out <= memory_r (curr_page_r).Power;  --4 
  max_send_out <= memory_r (curr_page_r).MSend;  --5



  -- Check generic values
--   assert (id_width_g + cfg_addr_width_g < addr_width_g+1) report
--     "Illegal generic values (Id-, page- or param_addr_width_c" severity error;

--   assert (param_addr_width_c + page_addr_width_c < cfg_addr_width_g+1) report
--     "Illegal generic values (Id-, page- or param_addr_width_c" severity error;

  

  -- PROCESSES                          -----------------------------------------------------------------
  --
  -- 1) PROC
  -- Split the incoming config address to separate page and parameter number.
  -- Check incoming page and param numbers
  -- If they are illegal, internal write and read enbale signals are reset to
  -- zero => Nothing happens inside config mem, no checks needed elsewhere than here
  -- 
  Split_addr_in : process (addr_in,
                           we_in,
                           re_in
                           )
  begin  -- process Split_addr_in
    if conv_integer ( addr_in ( page_addr_width_c + param_addr_width_c-1 downto param_addr_width_c)) > n_cfg_pages_g
      or conv_integer ( addr_in ( param_addr_width_c-1 downto 0)) > page_size_c then
      -- Illegal page or parameter  number
      page_num  <= 0;
      param_num <= 0;
      we_int    <= '0';
      re_int    <= '0';
      assert false report "Illegal addr to cfg mem" severity note;
    else
      -- Valid page and parameter numbers
      page_num  <= conv_integer ( addr_in ( page_addr_width_c+param_addr_width_c-1 downto param_addr_width_c));
      param_num <= conv_integer ( addr_in ( param_addr_width_c-1 downto 0));
      we_int    <= we_in;
      re_int    <= re_in;
    end if;

  end process Split_addr_in;

  

  -- 2) PROC
  -- Write new values to memory if needed, count clock cycles and time slots
   Main : process (clk, rst_n)

    variable Start_v            : std_logic_vector( counter_width_g-1 downto 0);
    variable Stop_v             : std_logic_vector( counter_width_g-1 downto 0);
    variable Owner_v            : std_logic_vector( id_width_g-1 downto 0);
    variable curr_slot_own_v    : std_logic;
    variable curr_slot_ends_v   : std_logic;
    variable next_slot_own_v    : std_logic;
    variable next_slot_starts_v : std_logic;

  begin  -- process Main

    if rst_n = '0' then                 -- asynchronous reset (active low)

      -- Reset cycle counter
      for i in 1 to n_cfg_pages_g loop
        curr_cycle_r (i) <= (others => '0');  -- vai 1?
      end loop;  -- i

      -- Reset all values in memory
      for i in 1 to n_cfg_pages_g loop
        memory_r (i).Arb   <= conv_std_logic_vector(arb_type_g, 2);  -- 3
        memory_r (i).Power <= (others => '0');  -- 4
        memory_r (i).Frame <= conv_std_logic_vector (tframe_c (i), counter_width_g);  -- 6
        --memory_r (i).Frame <= conv_std_logic_vector (60, counter_width_g); -- (others => '0');  -- 6
        --memory_r (i).Inva  <= '0';              -- 7
      end loop;  -- i

      -- Assign generic values to memory
      for i in 1 to n_cfg_pages_g loop
        memory_r (i).Prior  <= conv_std_logic_vector ( prior_g, id_width_g);
        memory_r (i).N_ag   <= conv_std_logic_vector ( n_agents_g, id_width_g);
        memory_r (i).MSend  <= conv_std_logic_vector ( max_send_g, counter_width_g);
        --if inv_addr_en_g = 0 then
        --  memory_r (i).Inva <= '0';
        --else
        --  memory_r (i).Inva <= '1';
        --end if;

      end loop;  -- i


      if n_time_slots_g > 0 then --16.02.05
        for p in 1 to n_cfg_pages_g loop
          for s in 0 to n_time_slots_g-1 loop
            tslot_r (p) (ind_tslot_c + s*3+0) <= conv_std_logic_vector (9,counter_width_g);
            tslot_r (p) (ind_tslot_c + s*3+1) <= conv_std_logic_vector (13,counter_width_g);
            tslot_r (p) (ind_tslot_c + s*3+2) <= conv_std_logic_vector (3,counter_width_g);


            if p < (max_n_cfg_pages_c+1) and s < max_n_tslots_c then
              
              tslot_start_r (p) (ind_tslot_c + s)                          <= conv_std_logic_vector (tslot_start_c (p) (s), counter_width_g);
              tslot_stop_r  (p) (ind_tslot_c +    n_time_slots_tmp_c + s)  <= conv_std_logic_vector (tslot_stop_c  (p) (s), counter_width_g);
              tslot_id_r    (p) (ind_tslot_c + 2* n_time_slots_tmp_c + s)  <= conv_std_logic_vector (tslot_id_c    (p) (s), id_width_g);

            else
              tslot_start_r (p) (ind_tslot_c + s)                          <= (others => '0');
              tslot_stop_r  (p) (ind_tslot_c +    n_time_slots_tmp_c + s)  <= (others => '0');
              tslot_id_r    (p) (ind_tslot_c + 2* n_time_slots_tmp_c + s)  <= (others => '0');
              
            end if;


          end loop;  -- s
        end loop;  -- p
      end if;
      
      -- Reset extra parameters
--       for p in 1 to n_cfg_pages_g loop
--         for e in ind_extra_c to ind_extra_c+ n_extra_params_g-1 loop
--           extra_param_r (p) (e) <= (others => '0');
--         end loop;  -- e
--       end loop;  -- p

      curr_page_r                   <= 1;
      curr_slot_own_r               <= '0';
      curr_slot_ends_r              <= '0';
      next_slot_own_r               <= '0';
      next_slot_starts_r            <= '0';
      if dbg_level > 0 then dbg_out <= 55; end if;


      
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- default assignments
      tslot_r       <= tslot_r;
      tslot_start_r <= tslot_start_r;
      tslot_stop_r  <= tslot_stop_r;
      tslot_id_r    <= tslot_id_r;
      curr_cycle_r  <= curr_cycle_r;
      -- extra_param_r <= extra_param_r;

      
      if cfg_we_g = 1
        and we_int = '1'
      then
        
        if page_num = conv_std_logic_vector (0, page_addr_width_c) then
          -- Special case when page num is zero

          if param_num = conv_std_logic_vector ( 0, param_addr_width_c) then
            -- Change page when both page and parameter number are zero
            -- Check that the new page num is valid (i.e. not zero)
            if data_in (page_addr_width_c-1 downto 0) <= n_cfg_pages_g
              and data_in (page_addr_width_c-1 downto 0) /= conv_std_logic_vector (0, page_addr_width_c)  -- 04.03.05
            then

              curr_page_r                      <= conv_integer (data_in ( page_addr_width_c-1 downto 0));
              memory_r                         <= memory_r;
              --assert false report "Change page number" severity note;
              if dbg_level > 0 then dbg_out    <= 100; end if;
            else
              -- Galaxies will explode, if illegal page number is written into
              -- curr page register
              curr_page_r                      <= curr_page_r;
              memory_r                         <= memory_r;
              assert false report "Switch to illegal page number cancelled!" severity note;
              if dbg_level > 0 then dbg_out    <= 80; end if;
            end if;  --data_in
          else
            -- page num zero, but param num is not => do nothing
            curr_page_r                        <= curr_page_r;
            memory_r                           <= memory_r;
                 if dbg_level > 0 then dbg_out <= 81; end if;
          end if;  -- param_num =0


        else
          -- 0 < page_num < n_cfg_pages_g
          -- Write new parameter value
          curr_page_r <= curr_page_r;
          memory_r    <= memory_r;

          if param_num < ind_tslot_c then
          -- if param_num < ind_baddr_c then
            case param_num is
              when ind_cycle_c =>
                -- param=0, different reg for cycle count
                -- Updated elsewhere
                if dbg_level > 0 then dbg_out <= ind_cycle_c; end if;
              when ind_prior_c =>
                memory_r (page_num).Prior     <= data_in ( id_width_g-1 downto 0);  -- param = 1                  
                if dbg_level > 0 then dbg_out <= ind_prior_c; end if;
              when ind_n_ag_c  =>
                memory_r (page_num).N_ag      <= data_in ( id_width_g-1 downto 0);  -- param = 2
                if dbg_level > 0 then dbg_out <= ind_n_ag_c; end if;
              when ind_arb_c   =>
                memory_r (page_num).Arb       <= data_in (1 downto 0);  -- param = 3
                if dbg_level > 0 then dbg_out <= ind_arb_c; end if;
              when ind_pwr_c   =>
                memory_r (page_num).Power     <= data_in (1 downto 0);  -- param = 4 
                if dbg_level > 0 then dbg_out <= ind_pwr_c; end if;
              when ind_msend_c =>
                memory_r (page_num).MSend     <= data_in ( counter_width_g-1 downto 0);  -- param = 5  
                if dbg_level > 0 then dbg_out <= ind_msend_c; end if;
              when ind_frame_c =>
                if n_time_slots_g > 0 then  -- 24.01.05
                  memory_r (page_num).Frame   <= data_in ( counter_width_g-1 downto 0);  -- param = 6 
                end if;
                if dbg_level > 0 then dbg_out <= ind_frame_c; end if;
              when ind_inva_c  =>
                --memory_r (page_num).Inva      <= data_in ( 0);  -- param = 7  
                if dbg_level > 0 then dbg_out <= ind_inva_c; end if;
                assert false report "Trying to write address invert enable" severity warning;
                
              when ind_baddr_c =>       -- param = 8
                -- moved here 16.12.2005
                -- Address is now constant, do not updata
                if dbg_level > 0 then dbg_out <= ind_baddr_c; end if;
                assert false report "Trying to write address" severity warning;                
                
              when others =>
                assert false report "Incorrect parameter number" severity warning;
                if dbg_level > 0 then dbg_out <= 99; end if;
            end case;

          else
            -- 16.12.2005 elsif param_num < ind_extra_c then
            -- Assign time slot parameters
            if n_time_slots_g > 0 then
              tslot_r (page_num) ( param_num) <= data_in (counter_width_g-1 downto 0);

              if param_num < (ind_tslot_c + n_time_slots_tmp_c)  then
                tslot_start_r  (page_num) ( param_num) <= data_in (counter_width_g-1 downto 0);
                
              elsif param_num < (ind_tslot_c + 2*n_time_slots_tmp_c)  then
                tslot_stop_r  (page_num) ( param_num) <= data_in (counter_width_g-1 downto 0);
                
              else
                tslot_id_r   (page_num) ( param_num) <= data_in (id_width_g-1 downto 0);                
              end if;


              
            end if;            
            assert dbg_level < 1 report "Set time slots" severity note;
            if dbg_level > 0 then dbg_out     <= ind_tslot_c; end if;

--          else
--             -- Assign extra parameters
--             if n_extra_params_g > 0 then
--               extra_param_r (page_num) (param_num) <= data_in;
--             end if;
--             assert dbg_level < 1 report "Set extra params" severity note;
--             if dbg_level > 0 then dbg_out          <= ind_extra_c; end if;
          end if;  -- param_num >= ind_baddr_c                      
        end if;  -- page_num =0

      else
        -- WE =0 or illegal addr => memory_r remains static
        curr_page_r <= curr_page_r;
        --memory_r      <= memory_r;
        if dbg_level > 0 then dbg_out <= 64; end if;
      end if;  -- WE =1


      -- Counters are only needed for time slots
      if n_time_slots_g > 0 then

        -- Clock cycle counter (parameter number is 0)
        if param_num = conv_std_logic_vector (0, param_addr_width_c)
          and page_num /= conv_std_logic_vector (0, page_addr_width_c)
          and we_int = '1' then

          -- Write new value to curr cycle register

          if page_num = curr_page_r then
            -- Write on current page
            curr_cycle_r               <= curr_cycle_r;  --just in case 
            curr_cycle_r (curr_page_r) <= data_in (counter_width_g-1 downto 0);
          else
            -- Write to inactive page, clock cycle on current page is incremented 
            curr_cycle_r               <= curr_cycle_r;  --just in case 
            curr_cycle_r (page_num)    <= data_in (counter_width_g-1 downto 0);

            -- Clock cycle counter goes from 1 to FrameLength
            -- counter is reseted to 1
            if (curr_cycle_r (curr_page_r) = memory_r (curr_page_r).Frame
                and (memory_r (curr_page_r).Frame) /= conv_std_logic_vector (0, counter_width_g) ) then --04.03.05
                -- and (memory_r (curr_page_r).Frame) /= conv_std_logic_vector (0, data_width_g) ) then
              curr_cycle_r (curr_page_r) <= conv_std_logic_vector (1, counter_width_g);
            else
              curr_cycle_r (curr_page_r) <= curr_cycle_r (curr_page_r) + 1;
            end if;
          end if;  --page_num = curr_page_r

        else
          -- current clock counter is incremented

          curr_cycle_r                 <= curr_cycle_r;
          -- Clock cycle counter goes from 1 to FrameLength
          if (curr_cycle_r (curr_page_r) = memory_r (curr_page_r).Frame
              and (memory_r (curr_page_r).Frame) /= conv_std_logic_vector (0, counter_width_g) ) then --04.03.05
              --and (memory_r (curr_page_r).Frame) /= conv_std_logic_vector (0, data_width_g) )then
            -- counter is reseted to 1
            curr_cycle_r (curr_page_r) <= conv_std_logic_vector(1, counter_width_g);
          else
            curr_cycle_r (curr_page_r) <= curr_cycle_r (curr_page_r) + 1;
          end if;
        end if;  --param_num =ind_cycle_c+1

      end if;  -- n_time_slots_g 24.01.05



      
      -- Time slot signals are produced with a loop
      
      -- Goal: Bus is reserved one cycle after start=1
      --       and start writing on the cycle following reservation
      --       However, bus is released (lock=0) on the cycle following end=1
      --       The last data is written into bus at the time as lock=0
      curr_slot_own_v    := '0';
      curr_slot_ends_v   := '0';
      next_slot_own_v    := '0';
      next_slot_starts_v := '0';

      for i in 0 to n_time_slots_g - 1 loop

        Start_v := tslot_start_r (curr_page_r)(ind_tslot_c + i);
        Stop_v  := tslot_stop_r  (curr_page_r)(ind_tslot_c + n_time_slots_tmp_c + i);
        Owner_v := tslot_id_r    (curr_page_r)(ind_tslot_c + 2 * n_time_slots_tmp_c + i);

        --Start_v := tslot_r (curr_page_r)(ind_tslot_c + 3 * i);
        --Stop_v  := tslot_r (curr_page_r)(ind_tslot_c + 3 * i + 1);
        --Owner_v := tslot_r (curr_page_r)(ind_tslot_c + 3 * i + 2)(id_width_g-1 downto 0);


        
        -- Will current time slot end
        -- elsif makes sure that active bit one is not overwritten
        -- (when rest of the time slots are compared)
        if (curr_cycle_r (curr_page_r) = Stop_v) then
          curr_slot_ends_v := '1';
        elsif (curr_slot_ends_v = '1') then
          curr_slot_ends_v := '1';
        else
          curr_slot_ends_v := '0';
        end if;

        -- Will own time slot start next        
        if ( (curr_cycle_r (curr_page_r) = Start_v)
             and (Owner_v = conv_std_logic_vector (id_g, id_width_g))) then
          next_slot_own_v := '1';
        elsif (next_slot_own_v = '1') then
          next_slot_own_v := '1';
        else
          next_slot_own_v := '0';
        end if;

        -- Will some other time slot (not own) start next
        if (curr_cycle_r (curr_page_r) = Start_v) then
          next_slot_starts_v := '1';
        elsif (next_slot_starts_v = '1') then
          next_slot_starts_v := '1';
        else
          next_slot_starts_v := '0';
        end if;

        -- current time slot is own, if
        -- 1) own time slot starts now
        -- 2) already found a matching slot
        -- 3) own time slot on the run
        -- 4) AND time slot does not stop now
        -- 5) AND no other slot will start (see below)
        -- During reconfiguration, clock cycle may jump to value
        -- that does not belong into any slot. Consequently, the
        -- agent initializing reconfiguration may think that it still
        -- has the slot (curr_own=1). This 'extra' piece of time slot
        -- ends at least when some other agent starts its own slot.
        -- It should be noted that stop signal may be absent in such situation
        -- (because actually there is no slot)
        -- 

        if ( (next_slot_starts_r = '1' and next_slot_own_r = '1' )      -- 1
             or (curr_slot_own_v = '1' or curr_slot_own_r = '1') )    -- 2 & 3
          and curr_slot_ends_r = '0'                                    -- 4
          and not (next_slot_starts_r = '1' and next_slot_own_r = '0' ) -- 5
        then

          curr_slot_own_v := '1';
        
        else
          curr_slot_own_v := '0';
        end if;
        
      end loop;  -- i

      -- Assign output register values
      curr_slot_own_r    <= curr_slot_own_v;
      curr_slot_ends_r   <= curr_slot_ends_v;
      next_slot_own_r    <= next_slot_own_v;
      next_slot_starts_r <= next_slot_starts_v;

       
    end if;                             -- rst_n elsif clk'event
  end process Main;



  -- 3) PROC
  Reading_values : process (re_int, page_num, param_num, memory_r,
                            curr_page_r, curr_cycle_r,
                            tslot_r,
                            tslot_start_r, tslot_stop_r, tslot_id_r   --, extra_param_r                          
                            )
  begin  -- process Reading_values

    -- 28.02.2005, Design compiler uses latches without this
    -- default assignment
    data_out <= (others => '0');

    if cfg_re_g = 1 then
      if re_int = '1' then

        if page_num = 0 then
          if param_num = 0 then
            -- Read curr page number        
            data_out <= conv_std_logic_vector (curr_page_r, data_width_g);

          elsif param_num = 1 then
            -- Read ID
            data_out <= conv_std_logic_vector (id_g, data_width_g);

          elsif param_num = 2 then
            -- Read base ID
            data_out <= conv_std_logic_vector (base_id_g, data_width_g);
          end if;

        elsif page_num > n_cfg_pages_g or param_num > page_size_c then
          -- Read either a non-existent param or from non-existent page
          data_out <= (others => '0');  -- 'Z'); NOTE:'Z' only for test purposes!
          assert false report "Illegal addres : I though this is obsolete line in code" severity WARNING;
          -- Obsolete since 31.07 ??
          -- Read enable should be reseted to zero, and this branch cannot be reached

        else
          -- Read a regular parameter
          -- that means 0 < page < n_cfg_pages_g

          if param_num < ind_tslot_c then
          -- if param_num < ind_baddr_c then
            case param_num is
              when ind_cycle_c =>
                data_out                              <= (others => '0');
                data_out (counter_width_g-1 downto 0) <= curr_cycle_r ( page_num);  --param = 0

              when ind_prior_c =>
                data_out                         <= (others => '0');
                data_out (id_width_g-1 downto 0) <= memory_r (page_num).Prior;  -- param = 1

              when ind_n_ag_c =>
                data_out                         <= (others => '0');
                data_out (id_width_g-1 downto 0) <= memory_r (page_num).N_ag;  -- param = 2

              when ind_arb_c =>
                data_out               <= (others => '0');
                data_out ( 1 downto 0) <= memory_r (page_num).Arb;  -- param = 3

              when ind_pwr_c =>
                data_out               <= (others => '0');
                data_out ( 1 downto 0) <= memory_r (page_num).Power;  -- param = 4 

              when ind_msend_c =>
                data_out                              <= (others => '0');
                data_out (counter_width_g-1 downto 0) <= memory_r (page_num).MSend;  -- param = 5  

              when ind_frame_c =>
                data_out                              <= (others => '0');
                data_out (counter_width_g-1 downto 0) <= memory_r (page_num).Frame;  -- param = 6

              when ind_inva_c       =>
                data_out <= (others => '0');
                -- data_out ( 0) <= memory_r (page_num).Inva;  -- param = 7  
                data_out <= conv_std_logic_vector (inv_addr_en_g, data_width_g);

              when ind_baddr_c =>       --param = 8
                -- Moved here 16.12.2005
                -- Read address
                assert false report "Read address" severity note;
                data_out <= conv_std_logic_vector ( addr_g, data_width_g); --14.04                

              when others =>
                data_out <=  (others => '0');
                assert false report "Incorrect parameter number" severity warning;
            end case;


          else                          -- 16.12.2005
            -- elsif param_num >= ind_tslot_c and param_num < ind_extra_c then
            -- Read time slot parameters
            -- param = (ind_tslot_c, ind_tslot_c + n_tslots-1)
            data_out                                <= (others => '0');
            if n_time_slots_g > 0 then
              data_out (counter_width_g-1 downto 0) <= tslot_r (page_num) ( param_num);

              if param_num < (ind_tslot_c + n_time_slots_tmp_c)  then
                data_out (counter_width_g-1 downto 0) <=  tslot_start_r  (page_num) ( param_num);
                
              elsif param_num < (ind_tslot_c + 2*n_time_slots_tmp_c)  then
                data_out (counter_width_g-1 downto 0) <=  tslot_stop_r  (page_num) ( param_num);
                
              else
                data_out (id_width_g-1 downto 0) <=  tslot_id_r   (page_num) ( param_num);
              end if;

            end if;
            assert dbg_level < 1 report "Read time slots" severity note;

            
            -- Removed 16.12.2005
--           else
--             -- Read extra parameters
--             -- param = (ind_extra_c, ind_extra_c + n_extra_params_g-1)
--             data_out   <= (others => '0');
--             if n_extra_params_g > 0 then
--               data_out <= extra_param_r (page_num) (param_num);
--             end if;
--             assert dbg_level < 1 report "Read extra params" severity note;

          end if;  -- param_num < ind_baddr_c          
        end if;  -- page_num = 0
      else
        data_out <= (others => '0');          
      end if;  --re_int
  else
    data_out <= (others => '0');
  end if;  -- cfg_re_g
end process Reading_values;



end rtl;
