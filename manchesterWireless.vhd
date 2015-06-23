-----------------------------------------------------------------------------
--	Copyright (C) 2009 Sam Green
--
-- This code is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
--
--  Revision  Date        Author                Comment
--  --------  ----------  --------------------  ----------------
--  1.0       09/06/09    S. Green              Initial version
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.globals.all;

entity manchesterWireless is
  port ( 
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    data_i  : in  std_logic;
    q_o     : out std_logic_vector(WORD_LENGTH-1 downto 0);
    ready_o : out std_logic;
    recieved_debug : out std_logic_vector(3 downto 0);
    waitforstart_rdy : out std_logic
  );
end;

architecture behavioral of manchesterWireless is

  component waitForStart
  port (
    data_i  : in  std_logic;
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;           
    ready_o : out std_logic    
  );
  end component; 
  
  component singleDouble
  port (
    clk_i   :  in  std_logic;
    ce_i    :  in  std_logic;    
    rst_i   :  in  std_logic;
    data_i  :  in  std_logic;
    q_o     :  out std_logic_vector(3 downto 0);
    ready_o :  out std_logic    
  );
  end component;
  
  component decode
  port (
    clk_i     : in  std_logic;
    rst_i     : in  std_logic;
    nd_i      : in  std_logic;
    encoded_i : in  std_logic_vector(3 downto 0);
    decoded_o : out std_logic_vector(WORD_LENGTH-1 downto 0);
    nd_o      : out std_logic
  );
  end component;

  signal wait_rdy             : std_logic;
  signal md16_nd              : std_logic;
  signal md16_q_o             : std_logic_vector(3 downto 0);

begin

  inst_waitForStart: waitForStart
  port map(
    data_i => data_i,
    clk_i => clk_i,
    rst_i => rst_i,
    ready_o => wait_rdy
  );

  waitforstart_rdy <= wait_rdy;

  inst_singleDouble : singleDouble
  port map(
    clk_i   => clk_i,
    ce_i    => wait_rdy,
    rst_i   => rst_i,
    data_i  => data_i,
    q_o     => md16_q_o,
    ready_o => md16_nd
  );

  recieved_debug <= md16_q_o;

  inst_decode: decode
  port map(
    clk_i     => clk_i,
    rst_i     => rst_i,
    nd_i      => md16_nd,
    encoded_i => md16_q_o,
    decoded_o => q_o,
    nd_o      => ready_o
  );   
   
end;

