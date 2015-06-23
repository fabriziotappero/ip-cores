-------------------------------------------------------------------------------
-- File        : mesh_2d.vhdl
-- Description : Connect several mesh_routers together to form a network.       
--               Routes packets in 2D mesh network.
--               Network parameters are defined in a mesh_2d_pkg.
--               Edit only the beginnning of the package.
--
-- Author      : Erno Salminen
-- Date        : 17.06.2003
-- Modified    : 
-- 24.07.2003   ES full signals added
-- 11.08.2003   ES fifo added to router, it stores data coming from ip
--              ports definitions modified at the same time
-- 21.08.2006  AK multiclk
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--  This file is part of Transaction Generator.
--
--  Transaction Generator is free software: you can redistribute it and/or modify
--  it under the terms of the Lesser GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  Transaction Generator is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  Lesser GNU General Public License for more details.
--
--  You should have received a copy of the Lesser GNU General Public License
--  along with Transaction Generator.  If not, see <http://www.gnu.org/licenses/>.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity mesh_2d is
  generic (
    stfwd_en_g      : integer := 1;     --24.08.2006 es
    data_width_g    : integer := 16;
    addr_width_g    : integer := 16;
    fifo_depth_g    : integer;          -- := 5;
    pkt_len_g       : integer;          -- := 5;
    len_flit_en_g   : integer := 1;     -- 2007/08/03 where to place a pkt_len
    oaddr_flit_en_g : integer := 1;     -- 2007/08/03 whether to send the orig address

    mesh_freq_g   :    integer := 1;    -- relative mesh freq
    ip_freq_g     :    integer := 1;    --relative IP freq
    rows_g        :    integer := 4;
    cols_g        :    integer := 4;
    debug_ena_g   :    integer := 0;    --if debug_out is enabled, now 1=re and empty in
    -- debug_out
    debug_width_g :    integer := 0     -- for ena=1, rows*(cols-1)*2*2*2 (links,re+empty, bidir)
    );
  port (
    rst_n         : in std_logic;
    clk_mesh      : in std_logic;
    clk_ip        : in std_logic;
    tx_data_in    : in std_logic_vector(rows_g*cols_g*data_width_g-1 downto 0);
    tx_we_in      : in std_logic_vector(rows_g*cols_g-1 downto 0);
    rx_re_in      : in std_logic_vector(rows_g*cols_g-1 downto 0);

    rx_data_out  : out std_logic_vector(rows_g*cols_g*data_width_g-1 downto 0);  --data_array_type;
    rx_empty_out : out std_logic_vector(rows_g*cols_g-1 downto 0);
    rx_full_out  : out std_logic_vector(rows_g*cols_g-1 downto 0);
    tx_full_out  : out std_logic_vector(rows_g*cols_g-1 downto 0);
    tx_empty_out : out std_logic_vector(rows_g*cols_g-1 downto 0);

    debug_out : out std_logic_vector(debug_width_g-1 downto 0)  -- for debug
    -- signals (or monitor)
    );

end mesh_2d;


architecture structural of mesh_2d is

  -- Structure and indexing of the mesh. Signals coming from the outside are
  -- reset to zero.
  -- Note:(r,c)= (row,col)
  --
  --                             
  --            S(0, 0)  N(0,0)                 . . .    S(0, col-1)  N(0,col-1)
  --             =0                                         =0 
  --                  |  ^                                         |  ^
  --                  |  |                                         |  |            
  --                  V  |                                         V  |
  --             
  --  E(0, 0)=0  -->  ROUTER  --> E(0, 1) -->    . . .             ROUTER   --> E(0, col)     
  --  W(0, 0)   <--   (0,0)   <-- W(0, 1) <--                      (0,c-1)  <-- W(0, col)=0
  --
  --                  |  ^                                         |  ^
  --                  |  |                                         |  |
  --                  V  |                                         V  |
  --
  --             S(1,0)  N(1, 0)                . . .     S(1,col-1) N(1, col-1)       
  --
  --                  |  ^                                         |  ^     
  --                  |  |                                         |  |
  --                  V  |                                         V  |
  --
  --  E(1, 0)=0 -->  ROUTER   --> E(1, 1)-->     . . .            ROUTER  --> E(1, col)     
  --  W(1, 0)   <--   (1,0)  <--  W(1, 1)<--                   (1,col-1)  <-- W(1, col)=0
  --
  --                                            . . .             
  --                  . . .                                         . . . 
  --                    
  --                                            . . .
  -- E(row-1,0)=0 -->  ROUTER                                     ROUTER  --> E(row-1, col)     
  -- W(row-1,0)   <-- (row-1)(0)                               (r-1,c-1)  <-- W(row-1, col)=0     
  --
  --                   |   ^                                       |   ^
  --                   |   |                                       |   | 
  --                   V   |                                       V   |
  --
  --           S(row, 0)   N(row,0)=0                  S(row, col-1)   N(row, col-1)=0
  --                                        

  -- Top half of the addr is the row addr (vertical),
  -- and the lower half is the colums (horizontal) address 
  --  8b / 2 = 4b => max   4 rows ja   4 colums
  -- 16b / 2 = 8b => max 256 rows ja 256 colums => enough for most cases

  -- Number of routers = (rows-1)*(columns-1) 
  -- Indexing order (row_num, col_num)
  -- Smallest index (0,0) is the NorthWest corner (top-left)
  -- Biggest index is SouthEast corner (bottom-right)  
  -- constant num_of_agents : integer := mesh_rows * mesh_columns;
  -- 11.08.03 es: this constant is already set in system_package

  -- Own array types are needed for interface ports
  -- This is propably the only way to do it ?  
  -- Subtype needed for two-dimensional arrays
  subtype data_type is std_logic_vector (data_width_g-1 downto 0);

  -- Types for vertical (N <-> S) signals between router rows
  -- Note! Num_of_rows is (num_of_routers in vertical direction) +1 !
  type mesh_row_data_type is array (0 to cols_g-1) of data_type;
  type mesh_vert_data_type is array (0 to rows_g) of mesh_row_data_type;

  type mesh_row_one_bit_type is array (0 to cols_g-1) of std_logic;
  type mesh_vert_one_bit_type is array (0 to rows_g) of mesh_row_one_bit_type;

  -- Types for horizontal (W <-> E) signals between router columss
  -- Note! Num_of_colums is (num_of_routers in horizontal direction) +1 !
  type mesh_col_data_type is array (0 to cols_g) of data_type;
  type mesh_horiz_data_type is array (0 to rows_g-1) of mesh_col_data_type;

  type mesh_col_one_bit_type is array (0 to cols_g) of std_logic;
  type mesh_horiz_one_bit_type is array (0 to rows_g-1) of mesh_col_one_bit_type;

  -- Types for ip signals
  type data_array_type is array (0 to rows_g-1) of mesh_row_data_type;
  type one_bit_array_type is array (0 to rows_g-1) of mesh_row_one_bit_type;



  -- Top row is the row zero
  -- Left column is the colum zero
  signal Mesh_data_S_N        : mesh_vert_data_type;  -- south -> north
  signal Mesh_read_enable_S_N : mesh_vert_one_bit_type;
  signal Mesh_empty_S_N       : mesh_vert_one_bit_type;
  signal Mesh_full_S_N        : mesh_vert_one_bit_type;

  signal Mesh_data_N_S        : mesh_vert_data_type;  -- north -> south
  signal Mesh_read_enable_N_S : mesh_vert_one_bit_type;
  signal Mesh_empty_N_S       : mesh_vert_one_bit_type;
  signal Mesh_full_N_S        : mesh_vert_one_bit_type;

  signal Mesh_data_E_W        : mesh_horiz_data_type;  -- east -> west
  signal Mesh_read_enable_E_W : mesh_horiz_one_bit_type;
  signal Mesh_empty_E_W       : mesh_horiz_one_bit_type;
  signal Mesh_full_E_W        : mesh_horiz_one_bit_type;

  signal Mesh_data_W_E        : mesh_horiz_data_type;  -- west -> east
  signal Mesh_read_enable_W_E : mesh_horiz_one_bit_type;
  signal Mesh_empty_W_E       : mesh_horiz_one_bit_type;
  signal Mesh_full_W_E        : mesh_horiz_one_bit_type;




  component mesh_router
    generic (
      stfwd_en_g      : integer := 1;   -- 24.08.2006 es
      data_width_g    : integer := 0;
      addr_width_g    : integer := 0;   -- at least 2 bits,A = row & col
      fifo_depth_g    : integer := 0;
      pkt_len_g       : integer := 5;
      len_flit_en_g   : integer := 1;   -- 2007/08/03 where to place a pkt_len
      oaddr_flit_en_g : integer := 1;    -- 2007/08/03 whether to send the orig address

      ip_freq_g   : integer := 1;       -- relative IP frequency
      mesh_freq_g : integer := 1;       --relative router frequency      
      col_addr_g  : integer := 0;
      row_addr_g  : integer := 0;

      num_cols_g : integer;
      num_rows_g : integer
      );
    port (

      clk_ip   : in std_logic;
      clk_mesh : in std_logic;
      rst_n    : in std_logic;

      data_n_in  : in std_logic_vector (data_width_g-1 downto 0);
      empty_n_in : in std_logic;
      full_n_in  : in std_logic;
      re_n_in    : in std_logic;
      data_s_in  : in std_logic_vector (data_width_g-1 downto 0);
      empty_s_in : in std_logic;
      full_s_in  : in std_logic;
      re_s_in    : in std_logic;
      data_w_in  : in std_logic_vector (data_width_g-1 downto 0);
      empty_w_in : in std_logic;
      full_w_in  : in std_logic;
      re_w_in    : in std_logic;
      data_e_in  : in std_logic_vector (data_width_g-1 downto 0);
      empty_e_in : in std_logic;
      full_e_in  : in std_logic;
      re_e_in    : in std_logic;

      data_ip_tx_in : in std_logic_vector (data_width_g-1 downto 0);
      we_ip_tx_in   : in std_logic;
      re_ip_rx_in   : in std_logic;

      data_n_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_n_out : out std_logic;
      full_n_out  : out std_logic;
      re_n_out    : out std_logic;
      data_s_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_s_out : out std_logic;
      full_s_out  : out std_logic;
      re_s_out    : out std_logic;
      data_w_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_w_out : out std_logic;
      full_w_out  : out std_logic;
      re_w_out    : out std_logic;
      data_e_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_e_out : out std_logic;
      full_e_out  : out std_logic;
      re_e_out    : out std_logic;

      -- Ip signals modified 11.08.03
      data_ip_rx_out  : out std_logic_vector (data_width_g-1 downto 0);
      empty_ip_rx_out : out std_logic;
      full_ip_rx_out  : out std_logic;
      empty_ip_tx_out : out std_logic;
      full_ip_tx_out  : out std_logic
      -- re_ip_out : out std_logic
      );
  end component;  --router

begin  -- structural

  

  
  Map_router_rows : for r in 0 to rows_g-1 generate
    Map_router_colums : for c in 0 to cols_g-1 generate

      router_r_c : mesh_router
        generic map(
          stfwd_en_g      => stfwd_en_g,      --24.08.2006 es
          data_width_g    => data_width_g,
          addr_width_g    => addr_width_g,
          fifo_depth_g    => fifo_depth_g,
          pkt_len_g       => pkt_len_g,
          len_flit_en_g   => len_flit_en_g,   -- 2007/08/03
          oaddr_flit_en_g => oaddr_flit_en_g,  -- 2007/08/03

          ip_freq_g    => ip_freq_g,
          mesh_freq_g  => mesh_freq_g,
          col_addr_g   => c,
          row_addr_g   => r,
          num_cols_g   => cols_g,
          num_rows_g   => rows_g
          )

        port map(
          rst_n      => rst_n,
          clk_mesh   => clk_mesh,
          clk_ip     => clk_ip,

          data_n_in  => Mesh_data_N_S  (r) (c),
          empty_n_in => Mesh_empty_N_S (r) (c),
          full_n_in  => Mesh_full_N_S  (r) (c),
          re_n_in    => Mesh_read_enable_N_S (r) (c),
          data_s_in  => Mesh_data_S_N  (r+1)(c),
          empty_s_in => Mesh_empty_S_N (r+1)(c),
          full_s_in  => Mesh_full_S_N  (r+1)(c),
          re_s_in    => Mesh_read_enable_S_N (r+1)(c),
          data_w_in  => Mesh_data_W_E  (r) (c),
          empty_w_in => Mesh_empty_W_E (r) (c),
          full_w_in  => Mesh_full_W_E  (r) (c),
          re_w_in    => Mesh_read_enable_W_E (r) (c),
          data_e_in  => Mesh_data_E_W  (r) (c+1),
          empty_e_in => Mesh_empty_E_W (r) (c+1),
          full_e_in  => Mesh_full_E_W  (r) (c+1),
          re_e_in    => Mesh_read_enable_E_W (r) (c+1),

          -- Modified 11.08.03
          data_ip_tx_in => tx_data_in ((r*cols_g+c+1)*data_width_g-1 downto (r*cols_g+c)*data_width_g),  --(r) (c),
          we_ip_tx_in   => tx_we_in (r*cols_g+c),  --(r) (c),
          re_ip_rx_in   => rx_re_in (r*cols_g+c),  --(r) (c),


          data_n_out  => Mesh_data_S_N        (r) (c),
          empty_n_out => Mesh_empty_S_N       (r) (c),
          full_n_out  => Mesh_full_S_N        (r) (c),
          re_n_out    => Mesh_read_enable_S_N (r) (c),
          data_s_out  => Mesh_data_N_S        (r+1)(c),
          empty_s_out => Mesh_empty_N_S       (r+1)(c),
          full_s_out  => Mesh_full_N_S        (r+1)(c),
          re_s_out    => Mesh_read_enable_N_S (r+1)(c),
          data_w_out  => Mesh_data_E_W        (r) (c),
          empty_w_out => Mesh_empty_E_W       (r) (c),
          full_w_out  => Mesh_full_E_W        (r) (c),
          re_w_out    => Mesh_read_enable_E_W (r) (c),
          data_e_out  => Mesh_data_W_E        (r) (c+1),
          empty_e_out => Mesh_empty_W_E       (r) (c+1),
          full_e_out  => Mesh_full_W_E        (r) (c+1),
          re_e_out    => Mesh_read_enable_W_E (r) (c+1),

          data_ip_rx_out  => rx_data_out ((r*cols_g+c+1)*data_width_g-1 downto (r*cols_g+c)*data_width_g),  --(r) (c),
          empty_ip_rx_out => rx_empty_out (r*cols_g+c),
          full_ip_rx_out  => rx_full_out  (r*cols_g+c),   --(r) (c),
          empty_ip_tx_out => tx_empty_out (r*cols_g+c),  --(r) (c),
          full_ip_tx_out  => tx_full_out  (r*cols_g+c)    --(r) (c)
          );

    end generate Map_router_colums;
  end generate Map_router_rows;



  -- Reset values coming from the outside of the mesh
  -- For test purposes, data lines can be set corresponding to signals' index

  -- 1) vertical 
  Reset_values_from_north_and_south : for c in 0 to cols_g-1 generate
    -- Row 0 toward south comes from the outside
    Mesh_data_N_S (0)(c)        <= (others => 'Z');
    --<= conv_std_logic_vector (0, data_width/2) & conv_std_logic_vector (c, data_width/2);--test indexing 
    Mesh_empty_N_S (0)(c)       <= '1';
    Mesh_full_N_S (0)(c)        <= '0';  --24.07
    Mesh_read_enable_N_S (0)(c) <= '0';

    -- Bottom row toward north comes from the outside
    Mesh_data_S_N (rows_g)(c)        <= (others => 'Z');
    --<= conv_std_logic_vector (rows_g, data_width/2) & conv_std_logic_vector (c, data_width/2);--test indexing
    Mesh_empty_S_N (rows_g)(c)       <= '1';
    Mesh_full_S_N (rows_g)(c)        <= '0';  --24.07
    Mesh_read_enable_S_N (rows_g)(c) <= '0';
  end generate Reset_values_from_north_and_south;


  --2) horizontal
  Reset_values_from_west_and_east : for r in 0 to rows_g-1 generate
    -- Leftmost (west) colums toward east comes from the outside
    Mesh_data_W_E (r)(0)        <= (others => 'Z');
    --<= conv_std_logic_vector (r, data_width/2) & conv_std_logic_vector (0, data_width/2);--test indexing
    Mesh_empty_W_E (r)(0)       <= '1';
    Mesh_full_W_E (r)(0)        <= '0';  --24.07
    Mesh_read_enable_W_E (r)(0) <= '0';

    -- Rightmost (east) colums toward west comes from the outside
    Mesh_data_E_W (r)(cols_g)        <= (others => 'Z');
    --<= conv_std_logic_vector (r, data_width/2) & conv_std_logic_vector (cols_g, data_width/2);--test indexing
    Mesh_empty_E_W (r)(cols_g)       <= '1';
    Mesh_full_E_W (r)(cols_g)        <= '0';  --24.07
    Mesh_read_enable_E_W (r)(cols_g) <= '0';
  end generate Reset_values_from_west_and_east;

-------------------------------------------------------------------------------
  -- DEBUG OUT ASSIGNEMNTS
  -- do these only here!

  debug_ena : if debug_ena_g = 1 generate
    -- Top row is the row zero
    -- Left column is the colum zero
--  signal Mesh_data_S_N        : mesh_vert_data_type;  -- south -> north
--  signal Mesh_read_enable_S_N : mesh_vert_one_bit_type;
--  signal Mesh_empty_S_N       : mesh_vert_one_bit_type;
--  signal Mesh_full_S_N        : mesh_vert_one_bit_type;

--  signal Mesh_data_N_S        : mesh_vert_data_type;  -- north -> south
--  signal Mesh_read_enable_N_S : mesh_vert_one_bit_type;
--  signal Mesh_empty_N_S       : mesh_vert_one_bit_type;
--  signal Mesh_full_N_S        : mesh_vert_one_bit_type;

--  signal Mesh_data_E_W        : mesh_horiz_data_type;  -- east -> west
--  signal Mesh_read_enable_E_W : mesh_horiz_one_bit_type;
--  signal Mesh_empty_E_W       : mesh_horiz_one_bit_type;
--  signal Mesh_full_E_W        : mesh_horiz_one_bit_type;

--  signal Mesh_data_W_E        : mesh_horiz_data_type;  -- west -> east
--  signal Mesh_read_enable_W_E : mesh_horiz_one_bit_type;
--  signal Mesh_empty_W_E       : mesh_horiz_one_bit_type;
--  signal Mesh_full_W_E        : mesh_horiz_one_bit_type;

    debug0_r: for r in 0 to rows_g-1 generate
      debug0_c: for c in 0 to cols_g-1 generate
        debug_out (r * cols_g + c) <= not (Mesh_empty_N_S (r)(c));
      end generate debug0_c;
    end generate debug0_r;

     debug1_r: for r in 0 to rows_g-1 generate
       debug1_c: for c in 0 to cols_g-1 generate
         debug_out (r * cols_g + c + 1*rows_g*cols_g) <= not (Mesh_empty_S_N (r)(c));
       end generate debug1_c;
     end generate debug1_r;

     debug2_r: for r in 0 to rows_g-1 generate
       debug2_c: for c in 0 to cols_g-1 generate
         debug_out (r * cols_g + c + 2*rows_g*cols_g) <= not (Mesh_empty_W_E (r)(c));
       end generate debug2_c;
     end generate debug2_r;

     debug3_r: for r in 0 to rows_g-1 generate
       debug3_c: for c in 0 to cols_g-1 generate
         debug_out (r * cols_g + c + 3*rows_g*cols_g) <= not (Mesh_empty_E_W (r)(c));
       end generate debug3_c;
     end generate debug3_r;

    
    
--    debug_out <= Mesh_empty_W_E & Mesh_empty_E_W & Mesh_empty_N_S & Mesh_empty_S_N;
-- & Mesh_read_enable_W_E & Mesh_read_enable_E_W & Mesh_read_enable_N_S & Mesh_read_enable_S_N;

  end generate debug_ena;
  

end structural;
