--------------------------------------------------------------------------
-- 
-- Title        :   RSP-517 Mitrion platform support
-- Platform     :   Platform is rsp517-vlx160 (ROSTA RSP-517 V4VLX160)
-- Design       :   Types defenition
-- Project      :   rsp517_mitrion 
-- Package      :   ctrl_types
-- Author       :   Alexey Shmatok <alexey.shmatok@gmail.com>
-- Company      :   Rosta Ltd, www.rosta.ru
-- 
--------------------------------------------------------------------------
--
-- Description  :  This module provides some types definition
--
--------------------------------------------------------------------------
--
-- Declaimer    : This design is distributed on an "as is" basis, 
--		  without warranty of any kind, either express
--		  or implied. 
--
--------------------------------------------------------------------------
--
-- License      : This design is licensed under the GPL. 
--
--------------------------------------------------------------------------

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
package ctrl_types is
type reg32_array_type is array (integer range <>) of std_logic_vector (31 downto 0); 	
type reg64_array_type is array (integer range <>) of std_logic_vector (63 downto 0);
type reg128_array_type is array (integer range <>) of std_logic_vector (127 downto 0); 	 	
type reg256_array_type is array (integer range <>) of std_logic_vector (255 downto 0); 	 	
type bool_array_type is array (integer range <>) of boolean;
type natural_array_type is array (integer range <>) of natural; 

type mvp_scalar_out_port_type is
record
  Dout:  std_logic_vector(31 downto 0);
  Vout:  std_logic;
  Cout:  std_logic;
  cmd:  std_logic;
  data: std_logic_vector(31 downto 0);
  status : std_logic;
end record;
type mvp_scalar_out_port_array_type is array (integer range <>) of mvp_scalar_out_port_type; 
type mvp_scalar_in_port_type is
record
  Din:  std_logic_vector(31 downto 0);
  Vin:  std_logic;
  Cin:  std_logic;
  cmd:  std_logic;
  data: std_logic_vector(31 downto 0);
  status : std_logic;
  bk : std_logic;
  wt : std_logic;
end record;
type mvp_scalar_in_port_array_type is array (integer range <>) of mvp_scalar_in_port_type; 

end package;
