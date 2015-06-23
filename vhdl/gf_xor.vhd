library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.all;

-------------------------------------------------------------------------------

entity gf_xor_input is
  
  port (
    input_fcs  : in  std_logic_vector(31 downto 0);
    output_wip : out std_logic_vector(31 downto 0));

end gf_xor_input;

architecture behavior of gf_xor_input is

begin  -- behavior

  -- purpose: GF1x
  -- type   : combinational
  -- inputs : input_fcs
  -- outputs: output_wip
  p_gf_xor_input: process (input_fcs)
  begin  -- process p_gf_xor_input
                 output_wip(31) <= (input_fcs(31) xor input_fcs(27));
                 output_wip(30) <= (input_fcs(30) xor input_fcs(26));
                 output_wip(29) <= (input_fcs(29) xor input_fcs(25));
                 output_wip(28) <= (input_fcs(28) xor input_fcs(24));
                 output_wip(27) <= (input_fcs(27) xor input_fcs(23));
                 output_wip(26) <= (input_fcs(26) xor input_fcs(22));
                 output_wip(25) <= (input_fcs(31) xor input_fcs(27));
                 output_wip(24) <= (input_fcs(30) xor input_fcs(26));
                 output_wip(23) <= (input_fcs(31) xor input_fcs(29));
                 output_wip(22) <= (input_fcs(30) xor input_fcs(28));
                 output_wip(21) <= (input_fcs(29) xor input_fcs(26));
                 output_wip(20) <= (input_fcs(28) xor input_fcs(25));
                 output_wip(19) <= (input_fcs(31) xor input_fcs(27));
                 output_wip(18) <= (input_fcs(31) xor input_fcs(30));
                 output_wip(17) <= (input_fcs(30) xor input_fcs(29));
                 output_wip(16) <= (input_fcs(29) xor input_fcs(28));
                 output_wip(15) <= (input_fcs(31) xor input_fcs(28));
                 output_wip(14) <= (input_fcs(31) xor input_fcs(30));
                 output_wip(13) <= (input_fcs(30) xor input_fcs(29));
                 output_wip(12) <= (input_fcs(31) xor input_fcs(29));
                 output_wip(11) <= (input_fcs(31) xor input_fcs(30));
                 output_wip(10) <= (input_fcs(30) xor input_fcs(29));
                 output_wip(9) <= (input_fcs(29) xor input_fcs(28));
                 output_wip(8) <= (input_fcs(28) xor input_fcs(27));
                 output_wip(7) <= (input_fcs(31) xor input_fcs(26));
                 output_wip(6) <= (input_fcs(30) xor input_fcs(27));
                 output_wip(5) <= (input_fcs(29) xor input_fcs(26));
                 output_wip(4) <= (input_fcs(31) xor input_fcs(28));
                 output_wip(3) <= (input_fcs(31) xor input_fcs(30));
                 output_wip(2) <= (input_fcs(30) xor input_fcs(29));
                 output_wip(1) <= (input_fcs(29) xor input_fcs(28));
                 output_wip(0) <= (input_fcs(28) xor input_fcs(26));
  end process p_gf_xor_input;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.all;

entity gf_xor_2x is
  
   port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));

end gf_xor_2x;

architecture behavior of gf_xor_2x is

begin  -- behavior

  p_gf_xor_2x: process (input_fcs, input_wip)
  begin  -- process p_gf_xor_2x
                 output_wip(31) <= (input_wip(31) xor input_fcs(25));
                 output_wip(30) <= (input_wip(30) xor input_fcs(24));
                 output_wip(29) <= (input_wip(29) xor input_fcs(23));
                 output_wip(28) <= (input_wip(28) xor input_fcs(22));
                 output_wip(27) <= (input_wip(27) xor input_fcs(21));
                 output_wip(26) <= (input_wip(26) xor input_fcs(20));
                 output_wip(25) <= (input_wip(25) xor input_fcs(24));
                 output_wip(24) <= (input_wip(24) xor input_fcs(23));
                 output_wip(23) <= (input_wip(23) xor input_fcs(25));
                 output_wip(22) <= (input_wip(22) xor input_fcs(27));
                 output_wip(21) <= (input_wip(21) xor input_fcs(25));
                 output_wip(20) <= (input_wip(20) xor input_fcs(24));
                 output_wip(19) <= (input_wip(19) xor input_fcs(24));
                 output_wip(18) <= (input_wip(18) xor input_fcs(26));
                 output_wip(17) <= (input_wip(17) xor input_fcs(25));
                 output_wip(16) <= (input_wip(16) xor input_fcs(24));
                 output_wip(15) <= (input_wip(15) xor input_fcs(25));
                 output_wip(14) <= (input_wip(14) xor input_fcs(27));
                 output_wip(13) <= (input_wip(13) xor input_fcs(26));
                 output_wip(12) <= (input_wip(12) xor input_fcs(28));
                 output_wip(11) <= (input_wip(11) xor input_fcs(28));
                 output_wip(10) <= (input_wip(10) xor input_fcs(25));
                 output_wip(9) <= (input_wip(9) xor input_fcs(27));
                 output_wip(8) <= (input_wip(8) xor input_fcs(26));
                 output_wip(7) <= (input_wip(7) xor input_fcs(24));
                 output_wip(6) <= (input_wip(6) xor input_fcs(24));
                 output_wip(5) <= (input_wip(5) xor input_fcs(23));
                 output_wip(4) <= (input_wip(4) xor input_fcs(27));
                 output_wip(3) <= (input_wip(3) xor input_fcs(26));
                 output_wip(2) <= (input_wip(2) xor input_fcs(25));
                 output_wip(1) <= (input_wip(1) xor input_fcs(27));
                 output_wip(0) <= (input_wip(0) xor input_fcs(25));
  end process p_gf_xor_2x;

end behavior;

------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.all;

entity gf_xor_3x is
  
   port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));

end gf_xor_3x;


architecture behavior of gf_xor_3x is

begin  -- behavior

p_gf_xor_3x: process (input_fcs, input_wip)
 begin  -- process p_gf_xor_3x
                 output_wip(31) <= (input_wip(31) xor input_fcs(24));
                 output_wip(30) <= (input_wip(30) xor input_fcs(23));
                 output_wip(29) <= (input_wip(29) xor input_fcs(22));
                 output_wip(28) <= (input_wip(28) xor input_fcs(21));
                 output_wip(27) <= (input_wip(27) xor input_fcs(20));
                 output_wip(26) <= (input_wip(26) xor input_fcs(19));
                 output_wip(25) <= (input_wip(25) xor input_fcs(19));
                 output_wip(24) <= (input_wip(24) xor input_fcs(18));
                 output_wip(23) <= (input_wip(23) xor input_fcs(22));
                 output_wip(22) <= (input_wip(22) xor input_fcs(25));
                 output_wip(21) <= (input_wip(21) xor input_fcs(21));
                 output_wip(20) <= (input_wip(20) xor input_fcs(20));
                 output_wip(19) <= (input_wip(19) xor input_fcs(23));
                 output_wip(18) <= (input_wip(18) xor input_fcs(23));
                 output_wip(17) <= (input_wip(17) xor input_fcs(22));
                 output_wip(16) <= (input_wip(16) xor input_fcs(21));
                 output_wip(15) <= (input_wip(15) xor input_fcs(24));
                 output_wip(14) <= (input_wip(14) xor input_fcs(24));
                 output_wip(13) <= (input_wip(13) xor input_fcs(23));
                 output_wip(12) <= (input_wip(12) xor input_fcs(25));
                 output_wip(11) <= (input_wip(11) xor input_fcs(25));
                 output_wip(10) <= (input_wip(10) xor input_fcs(21));
                 output_wip(9) <= (input_wip(9) xor input_fcs(25));
                 output_wip(8) <= (input_wip(8) xor input_fcs(24));
                 output_wip(7) <= (input_wip(7) xor input_fcs(23));
                 output_wip(6) <= (input_wip(6) xor input_fcs(23));
                 output_wip(5) <= (input_wip(5) xor input_fcs(22));
                 output_wip(4) <= (input_wip(4) xor input_fcs(24));
                 output_wip(3) <= (input_wip(3) xor input_fcs(25));
                 output_wip(2) <= (input_wip(2) xor input_fcs(24));
                 output_wip(1) <= (input_wip(1) xor input_fcs(25));
                 output_wip(0) <= (input_wip(0) xor input_fcs(22));
    end process p_gf_xor_3x;

 end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.all;

entity gf_xor_4x is
  
   port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));

end gf_xor_4x;


architecture behavior of gf_xor_4x is

begin  -- behavior

  p_gf_xor_4x: process (input_fcs, input_wip)
  begin  -- process p_gf_xor_4x
                 output_wip (31) <= (input_wip(31) xor input_fcs(21));
                 output_wip (30) <= (input_wip(30) xor input_fcs(20));
                 output_wip (29) <= (input_wip(29) xor input_fcs(19));
                 output_wip (28) <= (input_wip(28) xor input_fcs(18));
                 output_wip (27) <= (input_wip(27) xor input_fcs(17));
                 output_wip (26) <= (input_wip(26) xor input_fcs(16));
                 output_wip (25) <= (input_wip(25) xor input_fcs(18));
                 output_wip (24) <= (input_wip(24) xor input_fcs(17));
                 output_wip (23) <= (input_wip(23) xor input_fcs(17));
                 output_wip (22) <= (input_wip(22) xor input_fcs(16));
                 output_wip (21) <= (input_wip(21) xor input_fcs(5));
                 output_wip (20) <= (input_wip(20) xor input_fcs(4));
                 output_wip (19) <= (input_wip(19) xor input_fcs(19));
                 output_wip (18) <= (input_wip(18) xor input_fcs(22));
                 output_wip (17) <= (input_wip(17) xor input_fcs(21));
                 output_wip (16) <= (input_wip(16) xor input_fcs(20));
                 output_wip (15) <= (input_wip(15) xor input_fcs(23));
                 output_wip (14) <= (input_wip(14) xor input_fcs(23));
                 output_wip (13) <= (input_wip(13) xor input_fcs(22));
                 output_wip (12) <= (input_wip(12) xor input_fcs(22));
                 output_wip (11) <= (input_wip(11) xor input_fcs(20));
                 output_wip (10) <= (input_wip(10) xor input_fcs(19));
                 output_wip (9) <= (input_wip(9) xor input_fcs(21));
                 output_wip (8) <= (input_wip(8) xor input_fcs(20));
                 output_wip (7) <= (input_wip(7) xor input_fcs(21));
                 output_wip (6) <= (input_wip(6) xor input_fcs(22));
                 output_wip (5) <= (input_wip(5) xor input_fcs(21));
                 output_wip (4) <= (input_wip(4) xor input_fcs(22));
                 output_wip (3) <= (input_wip(3) xor input_fcs(24));
                 output_wip (2) <= (input_wip(2) xor input_fcs(23));
                 output_wip (1) <= (input_wip(1) xor input_fcs(23));
                 output_wip (0) <= (input_wip(0) xor input_fcs(16));
  end process p_gf_xor_4x;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.all;

entity gf_xor_5x is
  
   port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));

end gf_xor_5x;

architecture behavior of gf_xor_5x is

begin  -- behavior

  p_gf_xor_5x: process (input_fcs, input_wip)
  begin  -- process p_gf_xor_5x
                 output_wip (31) <= (input_wip(31) xor input_fcs(15));
                 output_wip (30) <= (input_wip(30) xor input_fcs(14));
                 output_wip (29) <= (input_wip(29) xor input_fcs(13));
                 output_wip (28) <= (input_wip(28) xor input_fcs(12));
                 output_wip (27) <= (input_wip(27) xor input_fcs(11));
                 output_wip (26) <= (input_wip(26) xor input_fcs(10));
                 output_wip (25) <= (input_wip(25) xor input_fcs(9));
                 output_wip (24) <= (input_wip(24) xor input_fcs(8));
                 output_wip (23) <= (input_wip(23) xor input_fcs(16));
                 output_wip (22) <= (input_wip(22) xor input_fcs(6));
                 output_wip (21) <= (input_wip(21));
                 output_wip (20) <= (input_wip(20));
                 output_wip (19) <= (input_wip(19) xor input_fcs(3));
                 output_wip (18) <= (input_wip(18) xor input_fcs(18));
                 output_wip (17) <= (input_wip(17) xor input_fcs(17));
                 output_wip (16) <= (input_wip(16) xor input_fcs(16));
                 output_wip (15) <= (input_wip(15) xor input_fcs(21));
                 output_wip (14) <= (input_wip(14) xor input_fcs(22));
                 output_wip (13) <= (input_wip(13) xor input_fcs(21));
                 output_wip (12) <= (input_wip(12) xor input_fcs(21));
                 output_wip (11) <= (input_wip(11) xor input_fcs(19));
                 output_wip (10) <= (input_wip(10) xor input_fcs(18));
                 output_wip (9) <= (input_wip(9) xor input_fcs(20));
                 output_wip (8) <= (input_wip(8) xor input_fcs(19));
                 output_wip (7) <= (input_wip(7) xor input_fcs(19));
                 output_wip (6) <= (input_wip(6) xor input_fcs(21));
                 output_wip (5) <= (input_wip(5) xor input_fcs(20));
                 output_wip (4) <= (input_wip(4) xor input_fcs(20));
                 output_wip (3) <= (input_wip(3) xor input_fcs(23));
                 output_wip (2) <= (input_wip(2) xor input_fcs(22));
                 output_wip (1) <= (input_wip(1) xor input_fcs(22));
                 output_wip (0) <= (input_wip(0));
  end process p_gf_xor_5x;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.all;

entity gf_xor_6x is
  
   port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));

end gf_xor_6x;


architecture behavior of gf_xor_6x is

begin  -- behavior

  p_gf_xor_6x: process (input_fcs, input_wip)
  begin  -- process p_gf_xor_6x
                 output_wip (31) <= input_wip(31);
                 output_wip (30) <= input_wip(30);
                 output_wip (29) <= input_wip(29);
                 output_wip (28) <= input_wip(28);
                 output_wip (27) <= input_wip(27);
                 output_wip (26) <= input_wip(26);
                 output_wip (25) <= input_wip(25);
                 output_wip (24) <= input_wip(24);
                 output_wip (23) <= (input_wip(23) xor input_fcs(7));
                 output_wip (22) <= input_wip(22);
                 output_wip (21) <= input_wip(21);
                 output_wip (20) <= input_wip(20);
                 output_wip (19) <= input_wip(19);
                 output_wip (18) <= (input_wip(18) xor input_fcs(2));
                 output_wip (17) <= (input_wip(17) xor input_fcs(1));
                 output_wip (16) <= (input_wip(16) xor input_fcs(0));
                 output_wip (15) <= (input_wip(15) xor input_fcs(20));
                 output_wip (14) <= (input_wip(14) xor input_fcs(20));
                 output_wip (13) <= (input_wip(13) xor input_fcs(19));
                 output_wip (12) <= (input_wip(12) xor input_fcs(20));
                 output_wip (11) <= (input_wip(11) xor input_fcs(17));
                 output_wip (10) <= (input_wip(10) xor input_fcs(16));
                 output_wip (9) <= (input_wip(9) xor input_fcs(18));
                 output_wip (8) <= (input_wip(8) xor input_fcs(17));
                 output_wip (7) <= (input_wip(7) xor input_fcs(18));
                 output_wip (6) <= (input_wip(6) xor input_fcs(20));
                 output_wip (5) <= (input_wip(5) xor input_fcs(19));
                 output_wip (4) <= (input_wip(4) xor input_fcs(19));
                 output_wip (3) <= (input_wip(3) xor input_fcs(19));
                 output_wip (2) <= (input_wip(2) xor input_fcs(18));
                 output_wip (1) <= (input_wip(1) xor input_fcs(17));
                 output_wip (0) <= input_wip(0);
  end process p_gf_xor_6x;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.all;

entity gf_xor_7x is
  
   port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));

end gf_xor_7x;

architecture behavior of gf_xor_7x is

begin  -- behavior

  p_gf_xor_7x: process (input_fcs, input_wip)
  begin  -- process p_gf_xor_7x
                 output_wip (31) <= input_wip(31);
                 output_wip (30) <= input_wip(30);
                 output_wip (29) <= input_wip(29);
                 output_wip (28) <= input_wip(28);
                 output_wip (27) <= input_wip(27);
                 output_wip (26) <= input_wip(26);
                 output_wip (25) <= input_wip(25);
                 output_wip (24) <= input_wip(24);
                 output_wip (23) <= input_wip(23);
                 output_wip (22) <= input_wip(22);
                 output_wip (21) <= input_wip(21);
                 output_wip (20) <= input_wip(20);
                 output_wip (19) <= input_wip(19);
                 output_wip (18) <= input_wip(18);
                 output_wip (17) <= input_wip(17);
                 output_wip (16) <= input_wip(16);
                 output_wip (15) <= (input_wip(15) xor input_fcs(19));
                 output_wip (14) <= (input_wip(14) xor input_fcs(19));
                 output_wip (13) <= (input_wip(13) xor input_fcs(18));
                 output_wip (12) <= (input_wip(12) xor input_fcs(18));
                 output_wip (11) <= (input_wip(11) xor input_fcs(16));
                 output_wip (10) <= input_wip(10);
                 output_wip (9) <= (input_wip(9) xor input_fcs(17));
                 output_wip (8) <= (input_wip(8) xor input_fcs(16));
                 output_wip (7) <= (input_wip(7) xor input_fcs(16));
                 output_wip (6) <= (input_wip(6) xor input_fcs(18));
                 output_wip (5) <= (input_wip(5) xor input_fcs(17));
                 output_wip (4) <= (input_wip(4) xor input_fcs(18));
                 output_wip (3) <= (input_wip(3) xor input_fcs(18));
                 output_wip (2) <= (input_wip(2) xor input_fcs(17));
                 output_wip (1) <= (input_wip(1) xor input_fcs(16));
                 output_wip (0) <= input_wip(0);
  end process p_gf_xor_7x;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.all;

entity gf_xor_8x is
  
   port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));

end gf_xor_8x;

architecture behavior of gf_xor_8x is

begin  -- behavior

  p_gf_xor_8x: process (input_fcs, input_wip)
  begin  -- process p_gf_xor_8x
                 output_wip (31) <= input_wip(31);
                 output_wip (30) <= input_wip(30);
                 output_wip (29) <= input_wip(29);
                 output_wip (28) <= input_wip(28);
                 output_wip (27) <= input_wip(27);
                 output_wip (26) <= input_wip(26);
                 output_wip (25) <= input_wip(25);
                 output_wip (24) <= input_wip(24);
                 output_wip (23) <= input_wip(23);
                 output_wip (22) <= input_wip(22);
                 output_wip (21) <= input_wip(21);
                 output_wip (20) <= input_wip(20);
                 output_wip (19) <= input_wip(19);
                 output_wip (18) <= input_wip(18);
                 output_wip (17) <= input_wip(17);
                 output_wip (16) <= input_wip(16);
                 output_wip (15) <= input_wip(15);
                 output_wip (14) <= (input_wip(14) xor input_fcs(18));
                 output_wip (13) <= (input_wip(13) xor input_fcs(17));
                 output_wip (12) <= (input_wip(12) xor input_fcs(17));
                 output_wip (11) <= input_wip(11);
                 output_wip (10) <= input_wip(10);
                 output_wip (9) <= input_wip(9);
                 output_wip (8) <= input_wip(8);
                 output_wip (7) <= input_wip(7);
                 output_wip (6) <= (input_wip(6) xor input_fcs(17));
                 output_wip (5) <= (input_wip(5) xor input_fcs(16));
                 output_wip (4) <= (input_wip(4) xor input_fcs(16));
                 output_wip (3) <= (input_wip(3) xor input_fcs(17));
                 output_wip (2) <= (input_wip(2) xor input_fcs(16));
                 output_wip (1) <= input_wip(1);
                 output_wip (0) <= input_wip(0);
  end process p_gf_xor_8x;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.all;

entity gf_xor_9x is
  
   port (
      input_wip  : in  std_logic_vector(31 downto 0);
      input_fcs  : in  std_logic_vector(31 downto 0);
      output_wip : out  std_logic_vector(31 downto 0));

end gf_xor_9x;

architecture behavior of gf_xor_9x is

begin  -- behavior

  p_gf_xor_9x: process (input_fcs, input_wip)
  begin  -- process p_gf_xor_9x
                 output_wip (31) <= input_wip(31);
                 output_wip (30) <= input_wip(30);
                 output_wip (29) <= input_wip(29);
                 output_wip (28) <= input_wip(28);
                 output_wip (27) <= input_wip(27);
                 output_wip (26) <= input_wip(26);
                 output_wip (25) <= input_wip(25);
                 output_wip (24) <= input_wip(24);
                 output_wip (23) <= input_wip(23);
                 output_wip (22) <= input_wip(22);
                 output_wip (21) <= input_wip(21);
                 output_wip (20) <= input_wip(20);
                 output_wip (19) <= input_wip(19);
                 output_wip (18) <= input_wip(18);
                 output_wip (17) <= input_wip(17);
                 output_wip (16) <= input_wip(16);
                 output_wip (15) <= input_wip(15);
                 output_wip (14) <= input_wip(14);
                 output_wip (13) <= input_wip(13);
                 output_wip (12) <= (input_wip(12) xor input_fcs(16));
                 output_wip (11) <= input_wip(11);
                 output_wip (10) <= input_wip(10);
                 output_wip (9) <= input_wip(9);
                 output_wip (8) <= input_wip(8);
                 output_wip (7) <= input_wip(7);
                 output_wip (6) <= input_wip(6);
                 output_wip (5) <= input_wip(5);
                 output_wip (4) <= input_wip(4);
                 output_wip (3) <= input_wip(3);
                 output_wip (2) <= input_wip(2);
                 output_wip (1) <= input_wip(1);
                 output_wip (0) <= input_wip(0);
  end process p_gf_xor_9x;

end behavior;

-------------------------------------------------------------------------------
--library IEEE;
--use IEEE.std_logic_1164.all;
--use IEEE.std_logic_arith.all;
--use IEEE.std_logic_unsigned.all;
--use work.all;

--entity gf_xor_10x is
  
--   port (
--      input_wip  : in  std_logic_vector(31 downto 0);
--      input_fcs  : in  std_logic_vector(31 downto 0);
--      output_wip : out  std_logic_vector(31 downto 0));

--end gf_xor_10x;

--architecture behavior of gf_xor_10x is

--begin  -- behavior

--  p_gf_xor_10x: process (input_fcs, input_wip)
--  begin  -- process p_gf_xor_10x
--                 output_wip (31) <= input_wip(31);
--                 output_wip (30) <= input_wip(30);
--                 output_wip (29) <= input_wip(29);
--                 output_wip (28) <= input_wip(28);
--                 output_wip (27) <= input_wip(27);
--                 output_wip (26) <= input_wip(26);
--                 output_wip (25) <= input_wip(25);
--                 output_wip (24) <= input_wip(24);
--                output_wip (23) <= input_wip(23);
--                 output_wip (22) <= input_wip(22);
--                 output_wip (21) <= input_wip(21);
--                 output_wip (20) <= input_wip(20);
--                 output_wip (19) <= input_wip(19);
--                 output_wip (18) <= input_wip(18);
--                 output_wip (17) <= input_wip(17);
--                 output_wip (16) <= input_wip(16);
--                 output_wip (15) <= input_wip(15);
--                 output_wip (14) <= input_wip(14);
--                 output_wip (13) <= input_wip(13);
--                 output_wip (12) <= input_wip(12);
--                 output_wip (11) <= input_wip(11);
--                 output_wip (10) <= input_wip(10);
--                 output_wip (9) <= input_wip(9);
--                 output_wip (8) <= input_wip(8);
--                 output_wip (7) <= input_wip(7);
--                 output_wip (6) <= input_wip(6);
--                 output_wip (5) <= input_wip(5);
--                 output_wip (4) <= input_wip(4);
--                 output_wip (3) <= input_wip(3);
--                 output_wip (2) <= input_wip(2);
--                 output_wip (1) <= input_wip(1);
--                 output_wip (0) <= input_wip(0);
--  end process p_gf_xor_10x;

--end behavior;

-------------------------------------------------------------------------------





