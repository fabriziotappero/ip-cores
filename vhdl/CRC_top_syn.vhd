
library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity CRC_top is

   port( phi1, phi2, reset : in std_logic;  input : in std_logic_vector (0 to 
         15);  fcs_out : out std_logic_vector (0 to 31));

end CRC_top;

architecture SYN_structural of CRC_top is

   component ff_reset
      port( phi2, reset_glitch : in std_logic;  reset_clean : out std_logic);
   end component;
   
   component input_wait
      port( phi1, phi2, reset : in std_logic;  input : in std_logic_vector (0 
            to 15);  output : out std_logic_vector (0 to 15));
   end component;
   
   component gf_multiplier
      port( reset, phi1, phi2 : in std_logic;  input : in std_logic_vector (0 
            to 31);  output_fcs, output_xor : out std_logic_vector (0 to 15));
   end component;
   
   component big_xor
      port( reset, phi2 : in std_logic;  input_input, fcs_input, gf_input : in 
            std_logic_vector (0 to 15);  output : out std_logic_vector (0 to 
            31));
   end component;
   
   signal wait_intermediate_10, xor_intermediate_0, fcs_out_15, fcs_out_4, 
      fcs_intermediate_10, fcs_intermediate_8, fcs_out_29, xor_intermediate_9, 
      wait_intermediate_2, fcs_intermediate_6, fcs_intermediate_1, fcs_out_27, 
      fcs_out_20, wait_intermediate_5, reset_intermediate, xor_intermediate_11,
      fcs_out_3, wait_intermediate_15, wait_intermediate_14, 
      wait_intermediate_13, wait_intermediate_11, wait_intermediate_4, 
      xor_intermediate_7, fcs_out_12, wait_intermediate_3, fcs_intermediate_7, 
      fcs_out_26, fcs_out_13, xor_intermediate_6, fcs_out_2, 
      xor_intermediate_10, fcs_intermediate_9, fcs_out_28, fcs_out_5, 
      fcs_intermediate_0, xor_intermediate_1, fcs_out_14, fcs_out_21, 
      xor_intermediate_8, wait_intermediate_8, fcs_intermediate_11, 
      xor_intermediate_15, xor_intermediate_3, fcs_out_31, fcs_out_16, 
      fcs_out_7, fcs_intermediate_13, wait_intermediate_6, wait_intermediate_1,
      fcs_intermediate_5, fcs_intermediate_2, fcs_out_24, fcs_out_23, fcs_out_9
      , fcs_intermediate_14, fcs_out_18, xor_intermediate_12, 
      fcs_intermediate_15, xor_intermediate_4, fcs_out_11, fcs_out_0, 
      wait_intermediate_7, fcs_out_19, fcs_intermediate_4, fcs_out_8, 
      fcs_out_25, xor_intermediate_13, xor_intermediate_5, fcs_out_10, 
      fcs_out_1, xor_intermediate_14, wait_intermediate_12, wait_intermediate_9
      , wait_intermediate_0, fcs_intermediate_3, xor_intermediate_2, fcs_out_30
      , fcs_out_6, fcs_out_17, fcs_out_22, fcs_intermediate_12 : std_logic;

begin
   fcs_out <= ( fcs_out_31, fcs_out_30, fcs_out_29, fcs_out_28, fcs_out_27, 
      fcs_out_26, fcs_out_25, fcs_out_24, fcs_out_23, fcs_out_22, fcs_out_21, 
      fcs_out_20, fcs_out_19, fcs_out_18, fcs_out_17, fcs_out_16, fcs_out_15, 
      fcs_out_14, fcs_out_13, fcs_out_12, fcs_out_11, fcs_out_10, fcs_out_9, 
      fcs_out_8, fcs_out_7, fcs_out_6, fcs_out_5, fcs_out_4, fcs_out_3, 
      fcs_out_2, fcs_out_1, fcs_out_0 );
   
   ff_reset_1 : ff_reset port map( phi2 => phi2, reset_glitch => reset, 
                           reset_clean => reset_intermediate);
   input_wait_1 : input_wait port map( phi1 => phi1, phi2 => phi2, reset => 
                           reset_intermediate, input(0) => input(0), input(1) 
                           => input(1), input(2) => input(2), input(3) => 
                           input(3), input(4) => input(4), input(5) => input(5)
                           , input(6) => input(6), input(7) => input(7), 
                           input(8) => input(8), input(9) => input(9), 
                           input(10) => input(10), input(11) => input(11), 
                           input(12) => input(12), input(13) => input(13), 
                           input(14) => input(14), input(15) => input(15), 
                           output(0) => wait_intermediate_15, output(1) => 
                           wait_intermediate_14, output(2) => 
                           wait_intermediate_13, output(3) => 
                           wait_intermediate_12, output(4) => 
                           wait_intermediate_11, output(5) => 
                           wait_intermediate_10, output(6) => 
                           wait_intermediate_9, output(7) => 
                           wait_intermediate_8, output(8) => 
                           wait_intermediate_7, output(9) => 
                           wait_intermediate_6, output(10) => 
                           wait_intermediate_5, output(11) => 
                           wait_intermediate_4, output(12) => 
                           wait_intermediate_3, output(13) => 
                           wait_intermediate_2, output(14) => 
                           wait_intermediate_1, output(15) => 
                           wait_intermediate_0);
   gf_multiplier_1 : gf_multiplier port map( reset => reset_intermediate, phi1 
                           => phi1, phi2 => phi2, input(0) => fcs_out_31, 
                           input(1) => fcs_out_30, input(2) => fcs_out_29, 
                           input(3) => fcs_out_28, input(4) => fcs_out_27, 
                           input(5) => fcs_out_26, input(6) => fcs_out_25, 
                           input(7) => fcs_out_24, input(8) => fcs_out_23, 
                           input(9) => fcs_out_22, input(10) => fcs_out_21, 
                           input(11) => fcs_out_20, input(12) => fcs_out_19, 
                           input(13) => fcs_out_18, input(14) => fcs_out_17, 
                           input(15) => fcs_out_16, input(16) => fcs_out_15, 
                           input(17) => fcs_out_14, input(18) => fcs_out_13, 
                           input(19) => fcs_out_12, input(20) => fcs_out_11, 
                           input(21) => fcs_out_10, input(22) => fcs_out_9, 
                           input(23) => fcs_out_8, input(24) => fcs_out_7, 
                           input(25) => fcs_out_6, input(26) => fcs_out_5, 
                           input(27) => fcs_out_4, input(28) => fcs_out_3, 
                           input(29) => fcs_out_2, input(30) => fcs_out_1, 
                           input(31) => fcs_out_0, output_fcs(0) => 
                           fcs_intermediate_15, output_fcs(1) => 
                           fcs_intermediate_14, output_fcs(2) => 
                           fcs_intermediate_13, output_fcs(3) => 
                           fcs_intermediate_12, output_fcs(4) => 
                           fcs_intermediate_11, output_fcs(5) => 
                           fcs_intermediate_10, output_fcs(6) => 
                           fcs_intermediate_9, output_fcs(7) => 
                           fcs_intermediate_8, output_fcs(8) => 
                           fcs_intermediate_7, output_fcs(9) => 
                           fcs_intermediate_6, output_fcs(10) => 
                           fcs_intermediate_5, output_fcs(11) => 
                           fcs_intermediate_4, output_fcs(12) => 
                           fcs_intermediate_3, output_fcs(13) => 
                           fcs_intermediate_2, output_fcs(14) => 
                           fcs_intermediate_1, output_fcs(15) => 
                           fcs_intermediate_0, output_xor(0) => 
                           xor_intermediate_15, output_xor(1) => 
                           xor_intermediate_14, output_xor(2) => 
                           xor_intermediate_13, output_xor(3) => 
                           xor_intermediate_12, output_xor(4) => 
                           xor_intermediate_11, output_xor(5) => 
                           xor_intermediate_10, output_xor(6) => 
                           xor_intermediate_9, output_xor(7) => 
                           xor_intermediate_8, output_xor(8) => 
                           xor_intermediate_7, output_xor(9) => 
                           xor_intermediate_6, output_xor(10) => 
                           xor_intermediate_5, output_xor(11) => 
                           xor_intermediate_4, output_xor(12) => 
                           xor_intermediate_3, output_xor(13) => 
                           xor_intermediate_2, output_xor(14) => 
                           xor_intermediate_1, output_xor(15) => 
                           xor_intermediate_0);
   big_xor_1 : big_xor port map( reset => reset_intermediate, phi2 => phi2, 
                           input_input(0) => wait_intermediate_15, 
                           input_input(1) => wait_intermediate_14, 
                           input_input(2) => wait_intermediate_13, 
                           input_input(3) => wait_intermediate_12, 
                           input_input(4) => wait_intermediate_11, 
                           input_input(5) => wait_intermediate_10, 
                           input_input(6) => wait_intermediate_9, 
                           input_input(7) => wait_intermediate_8, 
                           input_input(8) => wait_intermediate_7, 
                           input_input(9) => wait_intermediate_6, 
                           input_input(10) => wait_intermediate_5, 
                           input_input(11) => wait_intermediate_4, 
                           input_input(12) => wait_intermediate_3, 
                           input_input(13) => wait_intermediate_2, 
                           input_input(14) => wait_intermediate_1, 
                           input_input(15) => wait_intermediate_0, fcs_input(0)
                           => fcs_intermediate_15, fcs_input(1) => 
                           fcs_intermediate_14, fcs_input(2) => 
                           fcs_intermediate_13, fcs_input(3) => 
                           fcs_intermediate_12, fcs_input(4) => 
                           fcs_intermediate_11, fcs_input(5) => 
                           fcs_intermediate_10, fcs_input(6) => 
                           fcs_intermediate_9, fcs_input(7) => 
                           fcs_intermediate_8, fcs_input(8) => 
                           fcs_intermediate_7, fcs_input(9) => 
                           fcs_intermediate_6, fcs_input(10) => 
                           fcs_intermediate_5, fcs_input(11) => 
                           fcs_intermediate_4, fcs_input(12) => 
                           fcs_intermediate_3, fcs_input(13) => 
                           fcs_intermediate_2, fcs_input(14) => 
                           fcs_intermediate_1, fcs_input(15) => 
                           fcs_intermediate_0, gf_input(0) => 
                           xor_intermediate_15, gf_input(1) => 
                           xor_intermediate_14, gf_input(2) => 
                           xor_intermediate_13, gf_input(3) => 
                           xor_intermediate_12, gf_input(4) => 
                           xor_intermediate_11, gf_input(5) => 
                           xor_intermediate_10, gf_input(6) => 
                           xor_intermediate_9, gf_input(7) => 
                           xor_intermediate_8, gf_input(8) => 
                           xor_intermediate_7, gf_input(9) => 
                           xor_intermediate_6, gf_input(10) => 
                           xor_intermediate_5, gf_input(11) => 
                           xor_intermediate_4, gf_input(12) => 
                           xor_intermediate_3, gf_input(13) => 
                           xor_intermediate_2, gf_input(14) => 
                           xor_intermediate_1, gf_input(15) => 
                           xor_intermediate_0, output(0) => fcs_out_31, 
                           output(1) => fcs_out_30, output(2) => fcs_out_29, 
                           output(3) => fcs_out_28, output(4) => fcs_out_27, 
                           output(5) => fcs_out_26, output(6) => fcs_out_25, 
                           output(7) => fcs_out_24, output(8) => fcs_out_23, 
                           output(9) => fcs_out_22, output(10) => fcs_out_21, 
                           output(11) => fcs_out_20, output(12) => fcs_out_19, 
                           output(13) => fcs_out_18, output(14) => fcs_out_17, 
                           output(15) => fcs_out_16, output(16) => fcs_out_15, 
                           output(17) => fcs_out_14, output(18) => fcs_out_13, 
                           output(19) => fcs_out_12, output(20) => fcs_out_11, 
                           output(21) => fcs_out_10, output(22) => fcs_out_9, 
                           output(23) => fcs_out_8, output(24) => fcs_out_7, 
                           output(25) => fcs_out_6, output(26) => fcs_out_5, 
                           output(27) => fcs_out_4, output(28) => fcs_out_3, 
                           output(29) => fcs_out_2, output(30) => fcs_out_1, 
                           output(31) => fcs_out_0);

end SYN_structural;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity ff_reset is

   port( phi2, reset_glitch : in std_logic;  reset_clean : out std_logic);

end ff_reset;

architecture SYN_behavior of ff_reset is

   component IN8
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component DF8
      port( C, D : in std_logic;  Q, QN : out std_logic);
   end component;
   
   signal n15, n20 : std_logic;

begin
   
   U9 : IN8 port map( A => n15, Q => reset_clean);
   reset_clean_reg : DF8 port map( C => phi2, D => reset_glitch, Q => n20, QN 
                           => n15);

end SYN_behavior;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity input_phi2_register_0 is

   port( reset, phi2 : in std_logic;  input : in std_logic_vector (0 to 15);  
         output : out std_logic_vector (0 to 15));

end input_phi2_register_0;

architecture SYN_behavior_0 of input_phi2_register_0 is

   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component BU4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n75, n108, n109, n110, n111, n112, n113, n114, n115, n116, n117, n118
      , n119, n120, n121, n122, n123 : std_logic;

begin
   
   output_reg_15 : DFA2 port map( C => phi2, D => input(0), Q => output(0), QN 
                           => n108, RN => n75);
   output_reg_14 : DFA2 port map( C => phi2, D => input(1), Q => output(1), QN 
                           => n109, RN => n75);
   output_reg_13 : DFA2 port map( C => phi2, D => input(2), Q => output(2), QN 
                           => n110, RN => n75);
   output_reg_12 : DFA2 port map( C => phi2, D => input(3), Q => output(3), QN 
                           => n111, RN => n75);
   output_reg_11 : DFA2 port map( C => phi2, D => input(4), Q => output(4), QN 
                           => n112, RN => n75);
   output_reg_10 : DFA2 port map( C => phi2, D => input(5), Q => output(5), QN 
                           => n113, RN => n75);
   output_reg_9 : DFA2 port map( C => phi2, D => input(6), Q => output(6), QN 
                           => n114, RN => n75);
   output_reg_8 : DFA2 port map( C => phi2, D => input(7), Q => output(7), QN 
                           => n115, RN => n75);
   output_reg_7 : DFA2 port map( C => phi2, D => input(8), Q => output(8), QN 
                           => n116, RN => n75);
   output_reg_6 : DFA2 port map( C => phi2, D => input(9), Q => output(9), QN 
                           => n117, RN => n75);
   output_reg_5 : DFA2 port map( C => phi2, D => input(10), Q => output(10), QN
                           => n118, RN => n75);
   output_reg_4 : DFA2 port map( C => phi2, D => input(11), Q => output(11), QN
                           => n119, RN => n75);
   output_reg_3 : DFA2 port map( C => phi2, D => input(12), Q => output(12), QN
                           => n120, RN => n75);
   output_reg_2 : DFA2 port map( C => phi2, D => input(13), Q => output(13), QN
                           => n121, RN => n75);
   output_reg_1 : DFA2 port map( C => phi2, D => input(14), Q => output(14), QN
                           => n122, RN => n75);
   output_reg_0 : DFA2 port map( C => phi2, D => input(15), Q => output(15), QN
                           => n123, RN => n75);
   U48 : BU4 port map( A => reset, Q => n75);

end SYN_behavior_0;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity input_phi2_register_1 is

   port( reset, phi2 : in std_logic;  input : in std_logic_vector (0 to 15);  
         output : out std_logic_vector (0 to 15));

end input_phi2_register_1;

architecture SYN_behavior_1 of input_phi2_register_1 is

   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component BU2
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n82, n115, n116, n117, n118, n119, n120, n121, n122, n123, n124, n125
      , n126, n127, n128, n129, n130 : std_logic;

begin
   
   output_reg_15 : DFA port map( C => phi2, D => input(0), Q => output(0), QN 
                           => n115, RN => n82);
   output_reg_14 : DFA port map( C => phi2, D => input(1), Q => output(1), QN 
                           => n116, RN => n82);
   output_reg_13 : DFA2 port map( C => phi2, D => input(2), Q => output(2), QN 
                           => n117, RN => reset);
   output_reg_12 : DFA2 port map( C => phi2, D => input(3), Q => output(3), QN 
                           => n118, RN => reset);
   output_reg_11 : DFA2 port map( C => phi2, D => input(4), Q => output(4), QN 
                           => n119, RN => reset);
   output_reg_10 : DFA2 port map( C => phi2, D => input(5), Q => output(5), QN 
                           => n120, RN => reset);
   output_reg_9 : DFA2 port map( C => phi2, D => input(6), Q => output(6), QN 
                           => n121, RN => reset);
   output_reg_8 : DFA2 port map( C => phi2, D => input(7), Q => output(7), QN 
                           => n122, RN => reset);
   output_reg_7 : DFA2 port map( C => phi2, D => input(8), Q => output(8), QN 
                           => n123, RN => reset);
   output_reg_6 : DFA port map( C => phi2, D => input(9), Q => output(9), QN =>
                           n124, RN => n82);
   output_reg_5 : DFA2 port map( C => phi2, D => input(10), Q => output(10), QN
                           => n125, RN => reset);
   output_reg_4 : DFA2 port map( C => phi2, D => input(11), Q => output(11), QN
                           => n126, RN => reset);
   output_reg_3 : DFA2 port map( C => phi2, D => input(12), Q => output(12), QN
                           => n127, RN => reset);
   output_reg_2 : DFA port map( C => phi2, D => input(13), Q => output(13), QN 
                           => n128, RN => n82);
   output_reg_1 : DFA2 port map( C => phi2, D => input(14), Q => output(14), QN
                           => n129, RN => reset);
   output_reg_0 : DFA2 port map( C => phi2, D => input(15), Q => output(15), QN
                           => n130, RN => reset);
   U48 : BU2 port map( A => reset, Q => n82);

end SYN_behavior_1;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity input_phi2_register_2 is

   port( reset, phi2 : in std_logic;  input : in std_logic_vector (0 to 15);  
         output : out std_logic_vector (0 to 15));

end input_phi2_register_2;

architecture SYN_behavior_2 of input_phi2_register_2 is

   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   signal n107, n108, n109, n110, n111, n112, n113, n114, n115, n116, n117, 
      n118, n119, n120, n121, n122 : std_logic;

begin
   
   output_reg_15 : DFA2 port map( C => phi2, D => input(0), Q => output(0), QN 
                           => n107, RN => reset);
   output_reg_14 : DFA2 port map( C => phi2, D => input(1), Q => output(1), QN 
                           => n108, RN => reset);
   output_reg_13 : DFA2 port map( C => phi2, D => input(2), Q => output(2), QN 
                           => n109, RN => reset);
   output_reg_12 : DFA2 port map( C => phi2, D => input(3), Q => output(3), QN 
                           => n110, RN => reset);
   output_reg_11 : DFA2 port map( C => phi2, D => input(4), Q => output(4), QN 
                           => n111, RN => reset);
   output_reg_10 : DFA2 port map( C => phi2, D => input(5), Q => output(5), QN 
                           => n112, RN => reset);
   output_reg_9 : DFA2 port map( C => phi2, D => input(6), Q => output(6), QN 
                           => n113, RN => reset);
   output_reg_8 : DFA2 port map( C => phi2, D => input(7), Q => output(7), QN 
                           => n114, RN => reset);
   output_reg_7 : DFA2 port map( C => phi2, D => input(8), Q => output(8), QN 
                           => n115, RN => reset);
   output_reg_6 : DFA2 port map( C => phi2, D => input(9), Q => output(9), QN 
                           => n116, RN => reset);
   output_reg_5 : DFA2 port map( C => phi2, D => input(10), Q => output(10), QN
                           => n117, RN => reset);
   output_reg_4 : DFA port map( C => phi2, D => input(11), Q => output(11), QN 
                           => n118, RN => reset);
   output_reg_3 : DFA port map( C => phi2, D => input(12), Q => output(12), QN 
                           => n119, RN => reset);
   output_reg_2 : DFA port map( C => phi2, D => input(13), Q => output(13), QN 
                           => n120, RN => reset);
   output_reg_1 : DFA port map( C => phi2, D => input(14), Q => output(14), QN 
                           => n121, RN => reset);
   output_reg_0 : DFA port map( C => phi2, D => input(15), Q => output(15), QN 
                           => n122, RN => reset);

end SYN_behavior_2;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity input_phi2_register_3 is

   port( reset, phi2 : in std_logic;  input : in std_logic_vector (0 to 15);  
         output : out std_logic_vector (0 to 15));

end input_phi2_register_3;

architecture SYN_behavior_3 of input_phi2_register_3 is

   component IN3
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component IN1
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n97, n99, n132, n133, n134, n135, n136, n137, n138, n139, n140, n141,
      n142, n143, n144, n145, n146, n147 : std_logic;

begin
   
   U48 : IN3 port map( A => n97, Q => n99);
   output_reg_15 : DFA port map( C => phi2, D => input(0), Q => output(0), QN 
                           => n132, RN => n99);
   output_reg_14 : DFA port map( C => phi2, D => input(1), Q => output(1), QN 
                           => n133, RN => n99);
   output_reg_13 : DFA port map( C => phi2, D => input(2), Q => output(2), QN 
                           => n134, RN => n99);
   output_reg_12 : DFA port map( C => phi2, D => input(3), Q => output(3), QN 
                           => n135, RN => n99);
   output_reg_11 : DFA port map( C => phi2, D => input(4), Q => output(4), QN 
                           => n136, RN => n99);
   output_reg_10 : DFA port map( C => phi2, D => input(5), Q => output(5), QN 
                           => n137, RN => n99);
   output_reg_9 : DFA port map( C => phi2, D => input(6), Q => output(6), QN =>
                           n138, RN => n99);
   output_reg_8 : DFA port map( C => phi2, D => input(7), Q => output(7), QN =>
                           n139, RN => n99);
   output_reg_7 : DFA port map( C => phi2, D => input(8), Q => output(8), QN =>
                           n140, RN => n99);
   output_reg_6 : DFA port map( C => phi2, D => input(9), Q => output(9), QN =>
                           n141, RN => n99);
   output_reg_5 : DFA port map( C => phi2, D => input(10), Q => output(10), QN 
                           => n142, RN => n99);
   output_reg_4 : DFA port map( C => phi2, D => input(11), Q => output(11), QN 
                           => n143, RN => n99);
   output_reg_3 : DFA port map( C => phi2, D => input(12), Q => output(12), QN 
                           => n144, RN => n99);
   output_reg_2 : DFA port map( C => phi2, D => input(13), Q => output(13), QN 
                           => n145, RN => n99);
   output_reg_1 : DFA port map( C => phi2, D => input(14), Q => output(14), QN 
                           => n146, RN => n99);
   output_reg_0 : DFA port map( C => phi2, D => input(15), Q => output(15), QN 
                           => n147, RN => n99);
   U49 : IN1 port map( A => reset, Q => n97);

end SYN_behavior_3;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity input_phi1_register_0 is

   port( reset, phi1 : in std_logic;  input : in std_logic_vector (0 to 15);  
         output : out std_logic_vector (0 to 15));

end input_phi1_register_0;

architecture SYN_behavior_0 of input_phi1_register_0 is

   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component IN1
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN3
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n76, n80, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
      n123, n124, n125, n126, n127, n128 : std_logic;

begin
   
   output_reg_15 : DFA2 port map( C => phi1, D => input(0), Q => output(0), QN 
                           => n113, RN => n80);
   output_reg_14 : DFA2 port map( C => phi1, D => input(1), Q => output(1), QN 
                           => n114, RN => n80);
   output_reg_13 : DFA2 port map( C => phi1, D => input(2), Q => output(2), QN 
                           => n115, RN => n80);
   output_reg_12 : DFA2 port map( C => phi1, D => input(3), Q => output(3), QN 
                           => n116, RN => n80);
   output_reg_11 : DFA2 port map( C => phi1, D => input(4), Q => output(4), QN 
                           => n117, RN => n80);
   output_reg_10 : DFA2 port map( C => phi1, D => input(5), Q => output(5), QN 
                           => n118, RN => n80);
   output_reg_9 : DFA2 port map( C => phi1, D => input(6), Q => output(6), QN 
                           => n119, RN => n80);
   output_reg_8 : DFA2 port map( C => phi1, D => input(7), Q => output(7), QN 
                           => n120, RN => n80);
   output_reg_7 : DFA2 port map( C => phi1, D => input(8), Q => output(8), QN 
                           => n121, RN => n80);
   output_reg_6 : DFA2 port map( C => phi1, D => input(9), Q => output(9), QN 
                           => n122, RN => n80);
   output_reg_5 : DFA2 port map( C => phi1, D => input(10), Q => output(10), QN
                           => n123, RN => n80);
   output_reg_4 : DFA2 port map( C => phi1, D => input(11), Q => output(11), QN
                           => n124, RN => n80);
   output_reg_3 : DFA2 port map( C => phi1, D => input(12), Q => output(12), QN
                           => n125, RN => n80);
   output_reg_2 : DFA2 port map( C => phi1, D => input(13), Q => output(13), QN
                           => n126, RN => n80);
   output_reg_1 : DFA2 port map( C => phi1, D => input(14), Q => output(14), QN
                           => n127, RN => n80);
   output_reg_0 : DFA2 port map( C => phi1, D => input(15), Q => output(15), QN
                           => n128, RN => n80);
   U48 : IN1 port map( A => reset, Q => n76);
   U49 : IN3 port map( A => n76, Q => n80);

end SYN_behavior_0;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity input_phi1_register_1 is

   port( reset, phi1 : in std_logic;  input : in std_logic_vector (0 to 15);  
         output : out std_logic_vector (0 to 15));

end input_phi1_register_1;

architecture SYN_behavior_1 of input_phi1_register_1 is

   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   signal n107, n108, n109, n110, n111, n112, n113, n114, n115, n116, n117, 
      n118, n119, n120, n121, n122 : std_logic;

begin
   
   output_reg_15 : DFA2 port map( C => phi1, D => input(0), Q => output(0), QN 
                           => n107, RN => reset);
   output_reg_14 : DFA2 port map( C => phi1, D => input(1), Q => output(1), QN 
                           => n108, RN => reset);
   output_reg_13 : DFA2 port map( C => phi1, D => input(2), Q => output(2), QN 
                           => n109, RN => reset);
   output_reg_12 : DFA2 port map( C => phi1, D => input(3), Q => output(3), QN 
                           => n110, RN => reset);
   output_reg_11 : DFA2 port map( C => phi1, D => input(4), Q => output(4), QN 
                           => n111, RN => reset);
   output_reg_10 : DFA2 port map( C => phi1, D => input(5), Q => output(5), QN 
                           => n112, RN => reset);
   output_reg_9 : DFA2 port map( C => phi1, D => input(6), Q => output(6), QN 
                           => n113, RN => reset);
   output_reg_8 : DFA2 port map( C => phi1, D => input(7), Q => output(7), QN 
                           => n114, RN => reset);
   output_reg_7 : DFA2 port map( C => phi1, D => input(8), Q => output(8), QN 
                           => n115, RN => reset);
   output_reg_6 : DFA2 port map( C => phi1, D => input(9), Q => output(9), QN 
                           => n116, RN => reset);
   output_reg_5 : DFA2 port map( C => phi1, D => input(10), Q => output(10), QN
                           => n117, RN => reset);
   output_reg_4 : DFA2 port map( C => phi1, D => input(11), Q => output(11), QN
                           => n118, RN => reset);
   output_reg_3 : DFA2 port map( C => phi1, D => input(12), Q => output(12), QN
                           => n119, RN => reset);
   output_reg_2 : DFA2 port map( C => phi1, D => input(13), Q => output(13), QN
                           => n120, RN => reset);
   output_reg_1 : DFA2 port map( C => phi1, D => input(14), Q => output(14), QN
                           => n121, RN => reset);
   output_reg_0 : DFA2 port map( C => phi1, D => input(15), Q => output(15), QN
                           => n122, RN => reset);

end SYN_behavior_1;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity input_phi1_register_2 is

   port( reset, phi1 : in std_logic;  input : in std_logic_vector (0 to 15);  
         output : out std_logic_vector (0 to 15));

end input_phi1_register_2;

architecture SYN_behavior_2 of input_phi1_register_2 is

   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component IN1
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN3
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n84, n86, n119, n120, n121, n122, n123, n124, n125, n126, n127, n128,
      n129, n130, n131, n132, n133, n134 : std_logic;

begin
   
   output_reg_15 : DFA2 port map( C => phi1, D => input(0), Q => output(0), QN 
                           => n119, RN => n86);
   output_reg_14 : DFA2 port map( C => phi1, D => input(1), Q => output(1), QN 
                           => n120, RN => n86);
   output_reg_13 : DFA2 port map( C => phi1, D => input(2), Q => output(2), QN 
                           => n121, RN => n86);
   output_reg_12 : DFA2 port map( C => phi1, D => input(3), Q => output(3), QN 
                           => n122, RN => n86);
   output_reg_11 : DFA2 port map( C => phi1, D => input(4), Q => output(4), QN 
                           => n123, RN => n86);
   output_reg_10 : DFA2 port map( C => phi1, D => input(5), Q => output(5), QN 
                           => n124, RN => n86);
   output_reg_9 : DFA2 port map( C => phi1, D => input(6), Q => output(6), QN 
                           => n125, RN => n86);
   output_reg_8 : DFA2 port map( C => phi1, D => input(7), Q => output(7), QN 
                           => n126, RN => n86);
   output_reg_7 : DFA2 port map( C => phi1, D => input(8), Q => output(8), QN 
                           => n127, RN => n86);
   output_reg_6 : DFA2 port map( C => phi1, D => input(9), Q => output(9), QN 
                           => n128, RN => n86);
   output_reg_5 : DFA2 port map( C => phi1, D => input(10), Q => output(10), QN
                           => n129, RN => n86);
   output_reg_4 : DFA2 port map( C => phi1, D => input(11), Q => output(11), QN
                           => n130, RN => n86);
   output_reg_3 : DFA2 port map( C => phi1, D => input(12), Q => output(12), QN
                           => n131, RN => n86);
   output_reg_2 : DFA2 port map( C => phi1, D => input(13), Q => output(13), QN
                           => n132, RN => n86);
   output_reg_1 : DFA2 port map( C => phi1, D => input(14), Q => output(14), QN
                           => n133, RN => n86);
   output_reg_0 : DFA2 port map( C => phi1, D => input(15), Q => output(15), QN
                           => n134, RN => n86);
   U48 : IN1 port map( A => reset, Q => n84);
   U49 : IN3 port map( A => n84, Q => n86);

end SYN_behavior_2;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity input_phi1_register_3 is

   port( reset, phi1 : in std_logic;  input : in std_logic_vector (0 to 15);  
         output : out std_logic_vector (0 to 15));

end input_phi1_register_3;

architecture SYN_behavior_3 of input_phi1_register_3 is

   component IN3
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN1
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component IN4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n88, n90, n92, n98, n100, n102, n104, n106, n111, n115, n119, n123, 
      n127, n131, n135, n139, n157, n159, n209, n210, n211, n212, n213, n214, 
      n215, n216, n217, n218, n219, n220, n221, n222, n223, n224 : std_logic;

begin
   
   U48 : IN3 port map( A => n92, Q => output(9));
   U49 : IN3 port map( A => n98, Q => output(5));
   U50 : IN3 port map( A => n100, Q => output(15));
   U51 : IN3 port map( A => n102, Q => output(1));
   U52 : IN3 port map( A => n104, Q => output(2));
   U53 : IN3 port map( A => n106, Q => output(12));
   U54 : IN1 port map( A => reset, Q => n88);
   U55 : IN3 port map( A => n88, Q => n90);
   output_reg_6 : DFA2 port map( C => phi1, D => input(9), Q => n209, QN => n92
                           , RN => n90);
   output_reg_10 : DFA2 port map( C => phi1, D => input(5), Q => n210, QN => 
                           n98, RN => n90);
   output_reg_0 : DFA2 port map( C => phi1, D => input(15), Q => n211, QN => 
                           n100, RN => n90);
   output_reg_14 : DFA2 port map( C => phi1, D => input(1), Q => n212, QN => 
                           n102, RN => n90);
   output_reg_13 : DFA2 port map( C => phi1, D => input(2), Q => n213, QN => 
                           n104, RN => n90);
   output_reg_3 : DFA2 port map( C => phi1, D => input(12), Q => n214, QN => 
                           n106, RN => n90);
   U56 : IN4 port map( A => n111, Q => output(0));
   output_reg_15 : DFA2 port map( C => phi1, D => input(0), Q => n215, QN => 
                           n111, RN => n90);
   U57 : IN4 port map( A => n115, Q => output(3));
   output_reg_12 : DFA2 port map( C => phi1, D => input(3), Q => n216, QN => 
                           n115, RN => n90);
   U58 : IN4 port map( A => n119, Q => output(11));
   output_reg_4 : DFA2 port map( C => phi1, D => input(11), Q => n217, QN => 
                           n119, RN => n90);
   U59 : IN4 port map( A => n123, Q => output(10));
   output_reg_5 : DFA2 port map( C => phi1, D => input(10), Q => n218, QN => 
                           n123, RN => n90);
   U60 : IN4 port map( A => n127, Q => output(13));
   output_reg_2 : DFA2 port map( C => phi1, D => input(13), Q => n219, QN => 
                           n127, RN => n90);
   U61 : IN4 port map( A => n131, Q => output(6));
   output_reg_9 : DFA2 port map( C => phi1, D => input(6), Q => n220, QN => 
                           n131, RN => n90);
   U62 : IN4 port map( A => n135, Q => output(4));
   output_reg_11 : DFA2 port map( C => phi1, D => input(4), Q => n221, QN => 
                           n135, RN => n90);
   U63 : IN4 port map( A => n139, Q => output(8));
   output_reg_7 : DFA2 port map( C => phi1, D => input(8), Q => n222, QN => 
                           n139, RN => n90);
   U64 : IN4 port map( A => n157, Q => output(14));
   output_reg_1 : DFA2 port map( C => phi1, D => input(14), Q => n223, QN => 
                           n157, RN => n90);
   U65 : IN4 port map( A => n159, Q => output(7));
   output_reg_8 : DFA2 port map( C => phi1, D => input(7), Q => n224, QN => 
                           n159, RN => n90);

end SYN_behavior_3;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity input_wait is

   port( phi1, phi2, reset : in std_logic;  input : in std_logic_vector (0 to 
         15);  output : out std_logic_vector (0 to 15));

end input_wait;

architecture SYN_structural_architecture of input_wait is

   component input_phi2_register_0
      port( reset, phi2 : in std_logic;  input : in std_logic_vector (0 to 15);
            output : out std_logic_vector (0 to 15));
   end component;
   
   component input_phi2_register_1
      port( reset, phi2 : in std_logic;  input : in std_logic_vector (0 to 15);
            output : out std_logic_vector (0 to 15));
   end component;
   
   component input_phi2_register_2
      port( reset, phi2 : in std_logic;  input : in std_logic_vector (0 to 15);
            output : out std_logic_vector (0 to 15));
   end component;
   
   component input_phi2_register_3
      port( reset, phi2 : in std_logic;  input : in std_logic_vector (0 to 15);
            output : out std_logic_vector (0 to 15));
   end component;
   
   component input_phi1_register_0
      port( reset, phi1 : in std_logic;  input : in std_logic_vector (0 to 15);
            output : out std_logic_vector (0 to 15));
   end component;
   
   component input_phi1_register_1
      port( reset, phi1 : in std_logic;  input : in std_logic_vector (0 to 15);
            output : out std_logic_vector (0 to 15));
   end component;
   
   component input_phi1_register_2
      port( reset, phi1 : in std_logic;  input : in std_logic_vector (0 to 15);
            output : out std_logic_vector (0 to 15));
   end component;
   
   component input_phi1_register_3
      port( reset, phi1 : in std_logic;  input : in std_logic_vector (0 to 15);
            output : out std_logic_vector (0 to 15));
   end component;
   
   signal btw1and2_12, btw1and2_7, btw6and7_11, btw3and4_9, btw4and5_1, 
      btw5and6_14, btw5and6_4, btw6and7_9, btw7and8_2, btw2and3_10, btw2and3_3,
      btw7and8_12, btw3and4_7, btw3and4_0, btw4and5_14, btw4and5_8, btw6and7_0,
      btw6and7_7, btw3and4_11, btw4and5_13, btw1and2_15, btw1and2_9, btw2and3_4
      , btw7and8_15, btw5and6_3, btw7and8_5, btw1and2_14, btw1and2_0, 
      btw4and5_6, btw5and6_13, btw1and2_13, btw1and2_8, btw7and8_4, btw1and2_6,
      btw1and2_1, btw2and3_11, btw2and3_5, btw7and8_14, btw3and4_10, btw3and4_6
      , btw4and5_12, btw6and7_6, btw4and5_7, btw5and6_12, btw3and4_8, 
      btw5and6_2, btw5and6_5, btw6and7_8, btw4and5_0, btw5and6_15, btw3and4_1, 
      btw6and7_10, btw4and5_15, btw6and7_1, btw4and5_9, btw2and3_2, btw7and8_13
      , btw7and8_3, btw1and2_11, btw1and2_4, btw2and3_9, btw6and7_12, 
      btw7and8_8, btw4and5_2, btw5and6_7, btw1and2_10, btw1and2_5, btw1and2_3, 
      btw2and3_14, btw2and3_0, btw7and8_11, btw7and8_1, btw3and4_15, 
      btw2and3_13, btw3and4_4, btw3and4_3, btw6and7_3, btw5and6_9, btw6and7_4, 
      btw2and3_7, btw3and4_12, btw4and5_10, btw4and5_5, btw5and6_10, btw5and6_0
      , btw7and8_6, btw1and2_2, btw2and3_12, btw2and3_6, btw6and7_15, 
      btw7and8_7, btw3and4_13, btw3and4_5, btw4and5_11, btw5and6_8, btw6and7_5,
      btw6and7_14, btw4and5_4, btw5and6_11, btw5and6_6, btw5and6_1, btw2and3_8,
      btw4and5_3, btw2and3_15, btw3and4_14, btw3and4_2, btw6and7_13, btw6and7_2
      , btw7and8_9, btw2and3_1, btw7and8_10, btw7and8_0 : std_logic;

begin
   
   Input1 : input_phi2_register_3 port map( reset => reset, phi2 => phi2, 
                           input(0) => input(0), input(1) => input(1), input(2)
                           => input(2), input(3) => input(3), input(4) => 
                           input(4), input(5) => input(5), input(6) => input(6)
                           , input(7) => input(7), input(8) => input(8), 
                           input(9) => input(9), input(10) => input(10), 
                           input(11) => input(11), input(12) => input(12), 
                           input(13) => input(13), input(14) => input(14), 
                           input(15) => input(15), output(0) => btw1and2_15, 
                           output(1) => btw1and2_14, output(2) => btw1and2_13, 
                           output(3) => btw1and2_12, output(4) => btw1and2_11, 
                           output(5) => btw1and2_10, output(6) => btw1and2_9, 
                           output(7) => btw1and2_8, output(8) => btw1and2_7, 
                           output(9) => btw1and2_6, output(10) => btw1and2_5, 
                           output(11) => btw1and2_4, output(12) => btw1and2_3, 
                           output(13) => btw1and2_2, output(14) => btw1and2_1, 
                           output(15) => btw1and2_0);
   Input8 : input_phi1_register_3 port map( reset => reset, phi1 => phi1, 
                           input(0) => btw7and8_15, input(1) => btw7and8_14, 
                           input(2) => btw7and8_13, input(3) => btw7and8_12, 
                           input(4) => btw7and8_11, input(5) => btw7and8_10, 
                           input(6) => btw7and8_9, input(7) => btw7and8_8, 
                           input(8) => btw7and8_7, input(9) => btw7and8_6, 
                           input(10) => btw7and8_5, input(11) => btw7and8_4, 
                           input(12) => btw7and8_3, input(13) => btw7and8_2, 
                           input(14) => btw7and8_1, input(15) => btw7and8_0, 
                           output(0) => output(0), output(1) => output(1), 
                           output(2) => output(2), output(3) => output(3), 
                           output(4) => output(4), output(5) => output(5), 
                           output(6) => output(6), output(7) => output(7), 
                           output(8) => output(8), output(9) => output(9), 
                           output(10) => output(10), output(11) => output(11), 
                           output(12) => output(12), output(13) => output(13), 
                           output(14) => output(14), output(15) => output(15));
   Input2 : input_phi1_register_2 port map( reset => reset, phi1 => phi1, 
                           input(0) => btw1and2_15, input(1) => btw1and2_14, 
                           input(2) => btw1and2_13, input(3) => btw1and2_12, 
                           input(4) => btw1and2_11, input(5) => btw1and2_10, 
                           input(6) => btw1and2_9, input(7) => btw1and2_8, 
                           input(8) => btw1and2_7, input(9) => btw1and2_6, 
                           input(10) => btw1and2_5, input(11) => btw1and2_4, 
                           input(12) => btw1and2_3, input(13) => btw1and2_2, 
                           input(14) => btw1and2_1, input(15) => btw1and2_0, 
                           output(0) => btw2and3_15, output(1) => btw2and3_14, 
                           output(2) => btw2and3_13, output(3) => btw2and3_12, 
                           output(4) => btw2and3_11, output(5) => btw2and3_10, 
                           output(6) => btw2and3_9, output(7) => btw2and3_8, 
                           output(8) => btw2and3_7, output(9) => btw2and3_6, 
                           output(10) => btw2and3_5, output(11) => btw2and3_4, 
                           output(12) => btw2and3_3, output(13) => btw2and3_2, 
                           output(14) => btw2and3_1, output(15) => btw2and3_0);
   Input6 : input_phi1_register_1 port map( reset => reset, phi1 => phi1, 
                           input(0) => btw5and6_15, input(1) => btw5and6_14, 
                           input(2) => btw5and6_13, input(3) => btw5and6_12, 
                           input(4) => btw5and6_11, input(5) => btw5and6_10, 
                           input(6) => btw5and6_9, input(7) => btw5and6_8, 
                           input(8) => btw5and6_7, input(9) => btw5and6_6, 
                           input(10) => btw5and6_5, input(11) => btw5and6_4, 
                           input(12) => btw5and6_3, input(13) => btw5and6_2, 
                           input(14) => btw5and6_1, input(15) => btw5and6_0, 
                           output(0) => btw6and7_15, output(1) => btw6and7_14, 
                           output(2) => btw6and7_13, output(3) => btw6and7_12, 
                           output(4) => btw6and7_11, output(5) => btw6and7_10, 
                           output(6) => btw6and7_9, output(7) => btw6and7_8, 
                           output(8) => btw6and7_7, output(9) => btw6and7_6, 
                           output(10) => btw6and7_5, output(11) => btw6and7_4, 
                           output(12) => btw6and7_3, output(13) => btw6and7_2, 
                           output(14) => btw6and7_1, output(15) => btw6and7_0);
   Input7 : input_phi2_register_2 port map( reset => reset, phi2 => phi2, 
                           input(0) => btw6and7_15, input(1) => btw6and7_14, 
                           input(2) => btw6and7_13, input(3) => btw6and7_12, 
                           input(4) => btw6and7_11, input(5) => btw6and7_10, 
                           input(6) => btw6and7_9, input(7) => btw6and7_8, 
                           input(8) => btw6and7_7, input(9) => btw6and7_6, 
                           input(10) => btw6and7_5, input(11) => btw6and7_4, 
                           input(12) => btw6and7_3, input(13) => btw6and7_2, 
                           input(14) => btw6and7_1, input(15) => btw6and7_0, 
                           output(0) => btw7and8_15, output(1) => btw7and8_14, 
                           output(2) => btw7and8_13, output(3) => btw7and8_12, 
                           output(4) => btw7and8_11, output(5) => btw7and8_10, 
                           output(6) => btw7and8_9, output(7) => btw7and8_8, 
                           output(8) => btw7and8_7, output(9) => btw7and8_6, 
                           output(10) => btw7and8_5, output(11) => btw7and8_4, 
                           output(12) => btw7and8_3, output(13) => btw7and8_2, 
                           output(14) => btw7and8_1, output(15) => btw7and8_0);
   Input3 : input_phi2_register_1 port map( reset => reset, phi2 => phi2, 
                           input(0) => btw2and3_15, input(1) => btw2and3_14, 
                           input(2) => btw2and3_13, input(3) => btw2and3_12, 
                           input(4) => btw2and3_11, input(5) => btw2and3_10, 
                           input(6) => btw2and3_9, input(7) => btw2and3_8, 
                           input(8) => btw2and3_7, input(9) => btw2and3_6, 
                           input(10) => btw2and3_5, input(11) => btw2and3_4, 
                           input(12) => btw2and3_3, input(13) => btw2and3_2, 
                           input(14) => btw2and3_1, input(15) => btw2and3_0, 
                           output(0) => btw3and4_15, output(1) => btw3and4_14, 
                           output(2) => btw3and4_13, output(3) => btw3and4_12, 
                           output(4) => btw3and4_11, output(5) => btw3and4_10, 
                           output(6) => btw3and4_9, output(7) => btw3and4_8, 
                           output(8) => btw3and4_7, output(9) => btw3and4_6, 
                           output(10) => btw3and4_5, output(11) => btw3and4_4, 
                           output(12) => btw3and4_3, output(13) => btw3and4_2, 
                           output(14) => btw3and4_1, output(15) => btw3and4_0);
   Input4 : input_phi1_register_0 port map( reset => reset, phi1 => phi1, 
                           input(0) => btw3and4_15, input(1) => btw3and4_14, 
                           input(2) => btw3and4_13, input(3) => btw3and4_12, 
                           input(4) => btw3and4_11, input(5) => btw3and4_10, 
                           input(6) => btw3and4_9, input(7) => btw3and4_8, 
                           input(8) => btw3and4_7, input(9) => btw3and4_6, 
                           input(10) => btw3and4_5, input(11) => btw3and4_4, 
                           input(12) => btw3and4_3, input(13) => btw3and4_2, 
                           input(14) => btw3and4_1, input(15) => btw3and4_0, 
                           output(0) => btw4and5_15, output(1) => btw4and5_14, 
                           output(2) => btw4and5_13, output(3) => btw4and5_12, 
                           output(4) => btw4and5_11, output(5) => btw4and5_10, 
                           output(6) => btw4and5_9, output(7) => btw4and5_8, 
                           output(8) => btw4and5_7, output(9) => btw4and5_6, 
                           output(10) => btw4and5_5, output(11) => btw4and5_4, 
                           output(12) => btw4and5_3, output(13) => btw4and5_2, 
                           output(14) => btw4and5_1, output(15) => btw4and5_0);
   Input5 : input_phi2_register_0 port map( reset => reset, phi2 => phi2, 
                           input(0) => btw4and5_15, input(1) => btw4and5_14, 
                           input(2) => btw4and5_13, input(3) => btw4and5_12, 
                           input(4) => btw4and5_11, input(5) => btw4and5_10, 
                           input(6) => btw4and5_9, input(7) => btw4and5_8, 
                           input(8) => btw4and5_7, input(9) => btw4and5_6, 
                           input(10) => btw4and5_5, input(11) => btw4and5_4, 
                           input(12) => btw4and5_3, input(13) => btw4and5_2, 
                           input(14) => btw4and5_1, input(15) => btw4and5_0, 
                           output(0) => btw5and6_15, output(1) => btw5and6_14, 
                           output(2) => btw5and6_13, output(3) => btw5and6_12, 
                           output(4) => btw5and6_11, output(5) => btw5and6_10, 
                           output(6) => btw5and6_9, output(7) => btw5and6_8, 
                           output(8) => btw5and6_7, output(9) => btw5and6_6, 
                           output(10) => btw5and6_5, output(11) => btw5and6_4, 
                           output(12) => btw5and6_3, output(13) => btw5and6_2, 
                           output(14) => btw5and6_1, output(15) => btw5and6_0);

end SYN_structural_architecture;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_xor_input is

   port( input_fcs : in std_logic_vector (0 to 31);  output_wip : out 
         std_logic_vector (0 to 31));

end gf_xor_input;

architecture SYN_behavior of gf_xor_input is

   component EO1
      port( A, B : in std_logic;  Q : out std_logic);
   end component;
   
   signal output_wip_22, output_wip_6, output_wip_28, output_wip_8, 
      output_wip_26, output_wip_27, output_wip_20, output_wip_0, output_wip_7, 
      output_wip_29, net8524, output_wip_11, output_wip_14, net8460, 
      output_wip_4, net6785, output_wip_31, output_wip_23, output_wip_5, 
      output_wip_9 : std_logic;

begin
   output_wip <= ( output_wip_31, net6785, output_wip_29, output_wip_28, 
      output_wip_27, output_wip_26, output_wip_31, net6785, output_wip_23, 
      output_wip_22, output_wip_5, output_wip_20, output_wip_31, output_wip_11,
      net8460, output_wip_9, output_wip_4, output_wip_14, net8460, 
      output_wip_23, output_wip_11, net8524, output_wip_9, output_wip_8, 
      output_wip_7, output_wip_6, output_wip_5, output_wip_4, output_wip_14, 
      net8524, output_wip_9, output_wip_0 );
   
   U7 : EO1 port map( A => input_fcs(1), B => input_fcs(2), Q => net8524);
   U8 : EO1 port map( A => input_fcs(1), B => input_fcs(2), Q => net8460);
   U9 : EO1 port map( A => input_fcs(1), B => input_fcs(5), Q => net6785);
   U10 : EO1 port map( A => input_fcs(7), B => input_fcs(3), Q => output_wip_28
                           );
   U11 : EO1 port map( A => input_fcs(5), B => input_fcs(9), Q => output_wip_26
                           );
   U12 : EO1 port map( A => input_fcs(5), B => input_fcs(3), Q => output_wip_0)
                           ;
   U13 : EO1 port map( A => input_fcs(1), B => input_fcs(0), Q => output_wip_11
                           );
   U14 : EO1 port map( A => input_fcs(1), B => input_fcs(0), Q => output_wip_14
                           );
   U15 : EO1 port map( A => input_fcs(4), B => input_fcs(8), Q => output_wip_27
                           );
   U16 : EO1 port map( A => input_fcs(3), B => input_fcs(6), Q => output_wip_20
                           );
   U17 : EO1 port map( A => input_fcs(3), B => input_fcs(4), Q => output_wip_8)
                           ;
   U18 : EO1 port map( A => input_fcs(1), B => input_fcs(3), Q => output_wip_22
                           );
   U19 : EO1 port map( A => input_fcs(1), B => input_fcs(4), Q => output_wip_6)
                           ;
   U20 : EO1 port map( A => input_fcs(2), B => input_fcs(6), Q => output_wip_29
                           );
   U21 : EO1 port map( A => input_fcs(2), B => input_fcs(3), Q => output_wip_9)
                           ;
   U22 : EO1 port map( A => input_fcs(2), B => input_fcs(5), Q => output_wip_5)
                           ;
   U23 : EO1 port map( A => input_fcs(0), B => input_fcs(5), Q => output_wip_7)
                           ;
   U24 : EO1 port map( A => input_fcs(2), B => input_fcs(0), Q => output_wip_23
                           );
   U25 : EO1 port map( A => input_fcs(0), B => input_fcs(4), Q => output_wip_31
                           );
   U26 : EO1 port map( A => input_fcs(3), B => input_fcs(0), Q => output_wip_4)
                           ;

end SYN_behavior;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_xor_2x is

   port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip : 
         out std_logic_vector (0 to 31));

end gf_xor_2x;

architecture SYN_behavior of gf_xor_2x is

   component EO1
      port( A, B : in std_logic;  Q : out std_logic);
   end component;

begin
   
   U7 : EO1 port map( A => input_wip(16), B => input_fcs(6), Q => 
                           output_wip(16));
   U8 : EO1 port map( A => input_wip(14), B => input_fcs(6), Q => 
                           output_wip(14));
   U9 : EO1 port map( A => input_wip(21), B => input_fcs(6), Q => 
                           output_wip(21));
   U10 : EO1 port map( A => input_wip(29), B => input_fcs(6), Q => 
                           output_wip(29));
   U11 : EO1 port map( A => input_wip(10), B => input_fcs(6), Q => 
                           output_wip(10));
   U12 : EO1 port map( A => input_wip(24), B => input_fcs(7), Q => 
                           output_wip(24));
   U13 : EO1 port map( A => input_wip(1), B => input_fcs(7), Q => output_wip(1)
                           );
   U14 : EO1 port map( A => input_wip(9), B => input_fcs(4), Q => output_wip(9)
                           );
   U15 : EO1 port map( A => input_wip(12), B => input_fcs(7), Q => 
                           output_wip(12));
   U16 : EO1 port map( A => input_wip(13), B => input_fcs(5), Q => 
                           output_wip(13));
   U17 : EO1 port map( A => input_wip(17), B => input_fcs(4), Q => 
                           output_wip(17));
   U18 : EO1 port map( A => input_wip(18), B => input_fcs(5), Q => 
                           output_wip(18));
   U19 : EO1 port map( A => input_wip(23), B => input_fcs(5), Q => 
                           output_wip(23));
   U20 : EO1 port map( A => input_wip(25), B => input_fcs(7), Q => 
                           output_wip(25));
   U21 : EO1 port map( A => input_wip(30), B => input_fcs(4), Q => 
                           output_wip(30));
   U22 : EO1 port map( A => input_wip(0), B => input_fcs(6), Q => output_wip(0)
                           );
   U23 : EO1 port map( A => input_wip(31), B => input_fcs(6), Q => 
                           output_wip(31));
   U24 : EO1 port map( A => input_wip(6), B => input_fcs(7), Q => output_wip(6)
                           );
   U25 : EO1 port map( A => input_wip(11), B => input_fcs(7), Q => 
                           output_wip(11));
   U26 : EO1 port map( A => input_wip(8), B => input_fcs(6), Q => output_wip(8)
                           );
   U27 : EO1 port map( A => input_wip(3), B => input_fcs(9), Q => output_wip(3)
                           );
   U28 : EO1 port map( A => input_wip(4), B => input_fcs(10), Q => 
                           output_wip(4));
   U29 : EO1 port map( A => input_wip(5), B => input_fcs(11), Q => 
                           output_wip(5));
   U30 : EO1 port map( A => input_wip(20), B => input_fcs(3), Q => 
                           output_wip(20));
   U31 : EO1 port map( A => input_wip(7), B => input_fcs(8), Q => output_wip(7)
                           );
   U32 : EO1 port map( A => input_wip(2), B => input_fcs(8), Q => output_wip(2)
                           );
   U33 : EO1 port map( A => input_wip(26), B => input_fcs(8), Q => 
                           output_wip(26));
   U34 : EO1 port map( A => input_wip(28), B => input_fcs(5), Q => 
                           output_wip(28));
   U35 : EO1 port map( A => input_wip(15), B => input_fcs(7), Q => 
                           output_wip(15));
   U36 : EO1 port map( A => input_wip(27), B => input_fcs(4), Q => 
                           output_wip(27));
   U37 : EO1 port map( A => input_wip(22), B => input_fcs(4), Q => 
                           output_wip(22));
   U38 : EO1 port map( A => input_wip(19), B => input_fcs(3), Q => 
                           output_wip(19));

end SYN_behavior;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_xor_3x is

   port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip : 
         out std_logic_vector (0 to 31));

end gf_xor_3x;

architecture SYN_behavior of gf_xor_3x is

   component EO1
      port( A, B : in std_logic;  Q : out std_logic);
   end component;

begin
   
   U7 : EO1 port map( A => input_wip(25), B => input_fcs(8), Q => 
                           output_wip(25));
   U8 : EO1 port map( A => input_wip(12), B => input_fcs(8), Q => 
                           output_wip(12));
   U9 : EO1 port map( A => input_wip(13), B => input_fcs(8), Q => 
                           output_wip(13));
   U10 : EO1 port map( A => input_wip(18), B => input_fcs(8), Q => 
                           output_wip(18));
   U11 : EO1 port map( A => input_wip(24), B => input_fcs(8), Q => 
                           output_wip(24));
   U12 : EO1 port map( A => input_wip(23), B => input_fcs(7), Q => 
                           output_wip(23));
   U13 : EO1 port map( A => input_wip(27), B => input_fcs(7), Q => 
                           output_wip(27));
   U14 : EO1 port map( A => input_wip(16), B => input_fcs(7), Q => 
                           output_wip(16));
   U15 : EO1 port map( A => input_wip(17), B => input_fcs(7), Q => 
                           output_wip(17));
   U16 : EO1 port map( A => input_wip(29), B => input_fcs(7), Q => 
                           output_wip(29));
   U17 : EO1 port map( A => input_wip(22), B => input_fcs(6), Q => 
                           output_wip(22));
   U18 : EO1 port map( A => input_wip(28), B => input_fcs(6), Q => 
                           output_wip(28));
   U19 : EO1 port map( A => input_wip(19), B => input_fcs(6), Q => 
                           output_wip(19));
   U20 : EO1 port map( A => input_wip(20), B => input_fcs(6), Q => 
                           output_wip(20));
   U21 : EO1 port map( A => input_wip(30), B => input_fcs(6), Q => 
                           output_wip(30));
   U22 : EO1 port map( A => input_wip(7), B => input_fcs(13), Q => 
                           output_wip(7));
   U23 : EO1 port map( A => input_wip(11), B => input_fcs(11), Q => 
                           output_wip(11));
   U24 : EO1 port map( A => input_fcs(11), B => input_wip(4), Q => 
                           output_wip(4));
   U25 : EO1 port map( A => input_wip(6), B => input_fcs(12), Q => 
                           output_wip(6));
   U26 : EO1 port map( A => input_fcs(12), B => input_wip(5), Q => 
                           output_wip(5));
   U27 : EO1 port map( A => input_wip(21), B => input_fcs(10), Q => 
                           output_wip(21));
   U28 : EO1 port map( A => input_wip(15), B => input_fcs(10), Q => 
                           output_wip(15));
   U29 : EO1 port map( A => input_wip(10), B => input_fcs(10), Q => 
                           output_wip(10));
   U30 : EO1 port map( A => input_fcs(10), B => input_wip(3), Q => 
                           output_wip(3));
   U31 : EO1 port map( A => input_wip(31), B => input_fcs(9), Q => 
                           output_wip(31));
   U32 : EO1 port map( A => input_wip(14), B => input_fcs(9), Q => 
                           output_wip(14));
   U33 : EO1 port map( A => input_wip(8), B => input_fcs(9), Q => output_wip(8)
                           );
   U34 : EO1 port map( A => input_fcs(9), B => input_wip(2), Q => output_wip(2)
                           );
   U35 : EO1 port map( A => input_wip(26), B => input_fcs(9), Q => 
                           output_wip(26));
   U36 : EO1 port map( A => input_fcs(8), B => input_wip(1), Q => output_wip(1)
                           );
   U37 : EO1 port map( A => input_fcs(7), B => input_wip(0), Q => output_wip(0)
                           );
   U38 : EO1 port map( A => input_fcs(6), B => input_wip(9), Q => output_wip(9)
                           );

end SYN_behavior;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_xor_4x is

   port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip : 
         out std_logic_vector (0 to 31));

end gf_xor_4x;

architecture SYN_behavior of gf_xor_4x is

   component EO1
      port( A, B : in std_logic;  Q : out std_logic);
   end component;

begin
   
   U7 : EO1 port map( A => input_wip(26), B => input_fcs(10), Q => 
                           output_wip(26));
   U8 : EO1 port map( A => input_wip(0), B => input_fcs(10), Q => output_wip(0)
                           );
   U9 : EO1 port map( A => input_wip(1), B => input_fcs(11), Q => output_wip(1)
                           );
   U10 : EO1 port map( A => input_wip(7), B => input_fcs(14), Q => 
                           output_wip(7));
   U11 : EO1 port map( A => input_wip(12), B => input_fcs(12), Q => 
                           output_wip(12));
   U12 : EO1 port map( A => input_wip(14), B => input_fcs(10), Q => 
                           output_wip(14));
   U13 : EO1 port map( A => input_wip(16), B => input_fcs(8), Q => 
                           output_wip(16));
   U14 : EO1 port map( A => input_wip(18), B => input_fcs(9), Q => 
                           output_wip(18));
   U15 : EO1 port map( A => input_wip(19), B => input_fcs(9), Q => 
                           output_wip(19));
   U16 : EO1 port map( A => input_wip(25), B => input_fcs(9), Q => 
                           output_wip(25));
   U17 : EO1 port map( A => input_wip(8), B => input_fcs(14), Q => 
                           output_wip(8));
   U18 : EO1 port map( A => input_wip(13), B => input_fcs(9), Q => 
                           output_wip(13));
   U19 : EO1 port map( A => input_wip(15), B => input_fcs(11), Q => 
                           output_wip(15));
   U20 : EO1 port map( A => input_wip(20), B => input_fcs(11), Q => 
                           output_wip(20));
   U21 : EO1 port map( A => input_wip(21), B => input_fcs(12), Q => 
                           output_wip(21));
   U22 : EO1 port map( A => input_wip(22), B => input_fcs(10), Q => 
                           output_wip(22));
   U23 : EO1 port map( A => input_wip(24), B => input_fcs(10), Q => 
                           output_wip(24));
   U24 : EO1 port map( A => input_wip(27), B => input_fcs(9), Q => 
                           output_wip(27));
   U25 : EO1 port map( A => input_wip(29), B => input_fcs(8), Q => 
                           output_wip(29));
   U26 : EO1 port map( A => input_wip(30), B => input_fcs(8), Q => 
                           output_wip(30));
   U27 : EO1 port map( A => input_wip(28), B => input_fcs(7), Q => 
                           output_wip(28));
   U28 : EO1 port map( A => input_wip(10), B => input_fcs(26), Q => 
                           output_wip(10));
   U29 : EO1 port map( A => input_wip(11), B => input_fcs(27), Q => 
                           output_wip(11));
   U30 : EO1 port map( A => input_wip(6), B => input_fcs(13), Q => 
                           output_wip(6));
   U31 : EO1 port map( A => input_wip(3), B => input_fcs(13), Q => 
                           output_wip(3));
   U32 : EO1 port map( A => input_wip(2), B => input_fcs(12), Q => 
                           output_wip(2));
   U33 : EO1 port map( A => input_wip(4), B => input_fcs(14), Q => 
                           output_wip(4));
   U34 : EO1 port map( A => input_wip(31), B => input_fcs(15), Q => 
                           output_wip(31));
   U35 : EO1 port map( A => input_wip(9), B => input_fcs(15), Q => 
                           output_wip(9));
   U36 : EO1 port map( A => input_wip(5), B => input_fcs(15), Q => 
                           output_wip(5));
   U37 : EO1 port map( A => input_wip(23), B => input_fcs(11), Q => 
                           output_wip(23));
   U38 : EO1 port map( A => input_wip(17), B => input_fcs(8), Q => 
                           output_wip(17));

end SYN_behavior;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_xor_5x is

   port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip : 
         out std_logic_vector (0 to 31));

end gf_xor_5x;

architecture SYN_behavior of gf_xor_5x is

   component EO1
      port( A, B : in std_logic;  Q : out std_logic);
   end component;
   
   signal output_wip_5, output_wip_22, output_wip_30, output_wip_17, 
      output_wip_10, output_wip_2, output_wip_25, output_wip_19, output_wip_11,
      output_wip_18, output_wip_3, output_wip_24, output_wip_4, output_wip_23, 
      output_wip_31, output_wip_16, output_wip_6, output_wip_14, output_wip_28,
      output_wip_8, output_wip_13, output_wip_26, output_wip_1, output_wip_12, 
      output_wip_9, output_wip_27, output_wip_7, output_wip_29, output_wip_15 :
      std_logic;

begin
   output_wip <= ( output_wip_31, output_wip_30, output_wip_29, output_wip_28, 
      output_wip_27, output_wip_26, output_wip_25, output_wip_24, output_wip_23
      , output_wip_22, input_wip(10), input_wip(11), output_wip_19, 
      output_wip_18, output_wip_17, output_wip_16, output_wip_15, output_wip_14
      , output_wip_13, output_wip_12, output_wip_11, output_wip_10, 
      output_wip_9, output_wip_8, output_wip_7, output_wip_6, output_wip_5, 
      output_wip_4, output_wip_3, output_wip_2, output_wip_1, input_wip(31) );
   
   U7 : EO1 port map( A => input_wip(28), B => input_fcs(8), Q => output_wip_3)
                           ;
   U8 : EO1 port map( A => input_wip(0), B => input_fcs(16), Q => output_wip_31
                           );
   U9 : EO1 port map( A => input_wip(1), B => input_fcs(17), Q => output_wip_30
                           );
   U10 : EO1 port map( A => input_wip(2), B => input_fcs(18), Q => 
                           output_wip_29);
   U11 : EO1 port map( A => input_wip(3), B => input_fcs(19), Q => 
                           output_wip_28);
   U12 : EO1 port map( A => input_wip(4), B => input_fcs(20), Q => 
                           output_wip_27);
   U13 : EO1 port map( A => input_wip(5), B => input_fcs(21), Q => 
                           output_wip_26);
   U14 : EO1 port map( A => input_wip(6), B => input_fcs(22), Q => 
                           output_wip_25);
   U15 : EO1 port map( A => input_wip(7), B => input_fcs(23), Q => 
                           output_wip_24);
   U16 : EO1 port map( A => input_wip(9), B => input_fcs(25), Q => 
                           output_wip_22);
   U17 : EO1 port map( A => input_wip(12), B => input_fcs(28), Q => 
                           output_wip_19);
   U18 : EO1 port map( A => input_wip(14), B => input_fcs(14), Q => 
                           output_wip_17);
   U19 : EO1 port map( A => input_wip(15), B => input_fcs(15), Q => 
                           output_wip_16);
   U20 : EO1 port map( A => input_fcs(15), B => input_wip(8), Q => 
                           output_wip_23);
   U21 : EO1 port map( A => input_wip(21), B => input_fcs(13), Q => 
                           output_wip_10);
   U22 : EO1 port map( A => input_fcs(13), B => input_wip(13), Q => 
                           output_wip_18);
   U23 : EO1 port map( A => input_wip(30), B => input_fcs(9), Q => output_wip_1
                           );
   U24 : EO1 port map( A => input_fcs(9), B => input_wip(17), Q => 
                           output_wip_14);
   U25 : EO1 port map( A => input_wip(29), B => input_fcs(9), Q => output_wip_2
                           );
   U26 : EO1 port map( A => input_fcs(12), B => input_wip(20), Q => 
                           output_wip_11);
   U27 : EO1 port map( A => input_wip(24), B => input_fcs(12), Q => 
                           output_wip_7);
   U28 : EO1 port map( A => input_wip(23), B => input_fcs(12), Q => 
                           output_wip_8);
   U29 : EO1 port map( A => input_wip(27), B => input_fcs(11), Q => 
                           output_wip_4);
   U30 : EO1 port map( A => input_wip(26), B => input_fcs(11), Q => 
                           output_wip_5);
   U31 : EO1 port map( A => input_fcs(11), B => input_wip(22), Q => 
                           output_wip_9);
   U32 : EO1 port map( A => input_wip(19), B => input_fcs(10), Q => 
                           output_wip_12);
   U33 : EO1 port map( A => input_wip(18), B => input_fcs(10), Q => 
                           output_wip_13);
   U34 : EO1 port map( A => input_fcs(10), B => input_wip(16), Q => 
                           output_wip_15);
   U35 : EO1 port map( A => input_wip(25), B => input_fcs(10), Q => 
                           output_wip_6);

end SYN_behavior;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_xor_6x is

   port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip : 
         out std_logic_vector (0 to 31));

end gf_xor_6x;

architecture SYN_behavior of gf_xor_6x is

   component EO1
      port( A, B : in std_logic;  Q : out std_logic);
   end component;
   
   signal output_wip_5, output_wip_17, output_wip_10, output_wip_2, 
      output_wip_11, output_wip_18, output_wip_3, output_wip_4, output_wip_23, 
      output_wip_6, output_wip_16, output_wip_8, output_wip_14, output_wip_13, 
      output_wip_1, output_wip_12, output_wip_9, output_wip_7, output_wip_15 : 
      std_logic;

begin
   output_wip <= ( input_wip(0), input_wip(1), input_wip(2), input_wip(3), 
      input_wip(4), input_wip(5), input_wip(6), input_wip(7), output_wip_23, 
      input_wip(9), input_wip(10), input_wip(11), input_wip(12), output_wip_18,
      output_wip_17, output_wip_16, output_wip_15, output_wip_14, output_wip_13
      , output_wip_12, output_wip_11, output_wip_10, output_wip_9, output_wip_8
      , output_wip_7, output_wip_6, output_wip_5, output_wip_4, output_wip_3, 
      output_wip_2, output_wip_1, input_wip(31) );
   
   U7 : EO1 port map( A => input_wip(27), B => input_fcs(12), Q => output_wip_4
                           );
   U8 : EO1 port map( A => input_wip(28), B => input_fcs(12), Q => output_wip_3
                           );
   U9 : EO1 port map( A => input_wip(18), B => input_fcs(12), Q => 
                           output_wip_13);
   U10 : EO1 port map( A => input_wip(19), B => input_fcs(11), Q => 
                           output_wip_12);
   U11 : EO1 port map( A => input_wip(23), B => input_fcs(14), Q => 
                           output_wip_8);
   U12 : EO1 port map( A => input_wip(25), B => input_fcs(11), Q => 
                           output_wip_6);
   U13 : EO1 port map( A => input_wip(30), B => input_fcs(14), Q => 
                           output_wip_1);
   U14 : EO1 port map( A => input_wip(16), B => input_fcs(11), Q => 
                           output_wip_15);
   U15 : EO1 port map( A => input_wip(22), B => input_fcs(13), Q => 
                           output_wip_9);
   U16 : EO1 port map( A => input_wip(29), B => input_fcs(13), Q => 
                           output_wip_2);
   U17 : EO1 port map( A => input_wip(8), B => input_fcs(24), Q => 
                           output_wip_23);
   U18 : EO1 port map( A => input_wip(13), B => input_fcs(29), Q => 
                           output_wip_18);
   U19 : EO1 port map( A => input_wip(14), B => input_fcs(30), Q => 
                           output_wip_17);
   U20 : EO1 port map( A => input_wip(15), B => input_fcs(31), Q => 
                           output_wip_16);
   U21 : EO1 port map( A => input_wip(21), B => input_fcs(15), Q => 
                           output_wip_10);
   U22 : EO1 port map( A => input_wip(20), B => input_fcs(14), Q => 
                           output_wip_11);
   U23 : EO1 port map( A => input_wip(24), B => input_fcs(13), Q => 
                           output_wip_7);
   U24 : EO1 port map( A => input_wip(17), B => input_fcs(11), Q => 
                           output_wip_14);
   U25 : EO1 port map( A => input_wip(26), B => input_fcs(12), Q => 
                           output_wip_5);

end SYN_behavior;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_xor_7x is

   port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip : 
         out std_logic_vector (0 to 31));

end gf_xor_7x;

architecture SYN_behavior of gf_xor_7x is

   component EO1
      port( A, B : in std_logic;  Q : out std_logic);
   end component;
   
   signal output_wip_5, output_wip_2, output_wip_11, output_wip_3, output_wip_4
      , output_wip_6, output_wip_8, output_wip_14, output_wip_13, output_wip_1,
      output_wip_12, output_wip_9, output_wip_7, output_wip_15 : std_logic;

begin
   output_wip <= ( input_wip(0), input_wip(1), input_wip(2), input_wip(3), 
      input_wip(4), input_wip(5), input_wip(6), input_wip(7), input_wip(8), 
      input_wip(9), input_wip(10), input_wip(11), input_wip(12), input_wip(13),
      input_wip(14), input_wip(15), output_wip_15, output_wip_14, output_wip_13
      , output_wip_12, output_wip_11, input_wip(21), output_wip_9, output_wip_8
      , output_wip_7, output_wip_6, output_wip_5, output_wip_4, output_wip_3, 
      output_wip_2, output_wip_1, input_wip(31) );
   
   U7 : EO1 port map( A => input_wip(17), B => input_fcs(12), Q => 
                           output_wip_14);
   U8 : EO1 port map( A => input_fcs(12), B => input_wip(16), Q => 
                           output_wip_15);
   U9 : EO1 port map( A => input_wip(29), B => input_fcs(14), Q => output_wip_2
                           );
   U10 : EO1 port map( A => input_wip(26), B => input_fcs(14), Q => 
                           output_wip_5);
   U11 : EO1 port map( A => input_fcs(14), B => input_wip(22), Q => 
                           output_wip_9);
   U12 : EO1 port map( A => input_wip(30), B => input_fcs(15), Q => 
                           output_wip_1);
   U13 : EO1 port map( A => input_fcs(15), B => input_wip(20), Q => 
                           output_wip_11);
   U14 : EO1 port map( A => input_wip(24), B => input_fcs(15), Q => 
                           output_wip_7);
   U15 : EO1 port map( A => input_wip(23), B => input_fcs(15), Q => 
                           output_wip_8);
   U16 : EO1 port map( A => input_wip(19), B => input_fcs(13), Q => 
                           output_wip_12);
   U17 : EO1 port map( A => input_fcs(13), B => input_wip(18), Q => 
                           output_wip_13);
   U18 : EO1 port map( A => input_wip(28), B => input_fcs(13), Q => 
                           output_wip_3);
   U19 : EO1 port map( A => input_wip(27), B => input_fcs(13), Q => 
                           output_wip_4);
   U20 : EO1 port map( A => input_wip(25), B => input_fcs(13), Q => 
                           output_wip_6);

end SYN_behavior;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_xor_8x is

   port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip : 
         out std_logic_vector (0 to 31));

end gf_xor_8x;

architecture SYN_behavior of gf_xor_8x is

   component EO1
      port( A, B : in std_logic;  Q : out std_logic);
   end component;
   
   signal output_wip_5, output_wip_2, output_wip_3, output_wip_4, output_wip_6,
      output_wip_14, output_wip_13, output_wip_12 : std_logic;

begin
   output_wip <= ( input_wip(0), input_wip(1), input_wip(2), input_wip(3), 
      input_wip(4), input_wip(5), input_wip(6), input_wip(7), input_wip(8), 
      input_wip(9), input_wip(10), input_wip(11), input_wip(12), input_wip(13),
      input_wip(14), input_wip(15), input_wip(16), output_wip_14, output_wip_13
      , output_wip_12, input_wip(20), input_wip(21), input_wip(22), 
      input_wip(23), input_wip(24), output_wip_6, output_wip_5, output_wip_4, 
      output_wip_3, output_wip_2, input_wip(30), input_wip(31) );
   
   U7 : EO1 port map( A => input_wip(18), B => input_fcs(14), Q => 
                           output_wip_13);
   U8 : EO1 port map( A => input_wip(19), B => input_fcs(14), Q => 
                           output_wip_12);
   U9 : EO1 port map( A => input_wip(28), B => input_fcs(14), Q => output_wip_3
                           );
   U10 : EO1 port map( A => input_wip(27), B => input_fcs(15), Q => 
                           output_wip_4);
   U11 : EO1 port map( A => input_wip(29), B => input_fcs(15), Q => 
                           output_wip_2);
   U12 : EO1 port map( A => input_wip(17), B => input_fcs(13), Q => 
                           output_wip_14);
   U13 : EO1 port map( A => input_wip(25), B => input_fcs(14), Q => 
                           output_wip_6);
   U14 : EO1 port map( A => input_wip(26), B => input_fcs(15), Q => 
                           output_wip_5);

end SYN_behavior;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_xor_9x is

   port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip : 
         out std_logic_vector (0 to 31));

end gf_xor_9x;

architecture SYN_behavior of gf_xor_9x is

   component EO1
      port( A, B : in std_logic;  Q : out std_logic);
   end component;
   
   signal output_wip_12 : std_logic;

begin
   output_wip <= ( input_wip(0), input_wip(1), input_wip(2), input_wip(3), 
      input_wip(4), input_wip(5), input_wip(6), input_wip(7), input_wip(8), 
      input_wip(9), input_wip(10), input_wip(11), input_wip(12), input_wip(13),
      input_wip(14), input_wip(15), input_wip(16), input_wip(17), input_wip(18)
      , output_wip_12, input_wip(20), input_wip(21), input_wip(22), 
      input_wip(23), input_wip(24), input_wip(25), input_wip(26), input_wip(27)
      , input_wip(28), input_wip(29), input_wip(30), input_wip(31) );
   
   U7 : EO1 port map( A => input_wip(19), B => input_fcs(15), Q => 
                           output_wip_12);

end SYN_behavior;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_phi1_register_out is

   port( reset, phi1 : in std_logic;  input_wip : in std_logic_vector (0 to 31)
         ;  output_final : out std_logic_vector (0 to 31));

end gf_phi1_register_out;

architecture SYN_behavior of gf_phi1_register_out is

   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component BU8
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN2
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component IN3
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n107, n108, n110, n112, n114, n116, n118, n120, n122, n124, n126, 
      n128, n130, n132, n134, n136, n138, n220, n221, n222, n223, n224, n225, 
      n226, n227, n228, n229, n230, n231, n232, n233, n234, n235, n236, n237, 
      n238, n239, n240, n241, n242, n243, n244, n245, n246, n247, n248, n249, 
      n250, n251 : std_logic;

begin
   
   output_final_reg_29 : DFA2 port map( C => phi1, D => input_wip(2), Q => 
                           output_final(2), QN => n220, RN => n107);
   output_final_reg_27 : DFA2 port map( C => phi1, D => input_wip(4), Q => 
                           output_final(4), QN => n221, RN => n107);
   output_final_reg_25 : DFA2 port map( C => phi1, D => input_wip(6), Q => 
                           output_final(6), QN => n222, RN => n107);
   output_final_reg_24 : DFA2 port map( C => phi1, D => input_wip(7), Q => 
                           output_final(7), QN => n223, RN => n107);
   output_final_reg_23 : DFA2 port map( C => phi1, D => input_wip(8), Q => 
                           output_final(8), QN => n224, RN => n107);
   output_final_reg_22 : DFA2 port map( C => phi1, D => input_wip(9), Q => 
                           output_final(9), QN => n225, RN => n107);
   output_final_reg_21 : DFA2 port map( C => phi1, D => input_wip(10), Q => 
                           output_final(10), QN => n226, RN => n107);
   output_final_reg_20 : DFA2 port map( C => phi1, D => input_wip(11), Q => 
                           output_final(11), QN => n227, RN => n107);
   output_final_reg_19 : DFA2 port map( C => phi1, D => input_wip(12), Q => 
                           output_final(12), QN => n228, RN => n107);
   output_final_reg_18 : DFA2 port map( C => phi1, D => input_wip(13), Q => 
                           output_final(13), QN => n229, RN => n107);
   output_final_reg_17 : DFA2 port map( C => phi1, D => input_wip(14), Q => 
                           output_final(14), QN => n230, RN => n107);
   output_final_reg_16 : DFA2 port map( C => phi1, D => input_wip(15), Q => 
                           output_final(15), QN => n231, RN => n107);
   U80 : BU8 port map( A => reset, Q => n107);
   U81 : IN2 port map( A => n108, Q => output_final(25));
   U82 : IN2 port map( A => n110, Q => output_final(21));
   U83 : IN2 port map( A => n112, Q => output_final(31));
   U84 : IN2 port map( A => n114, Q => output_final(17));
   U85 : IN2 port map( A => n116, Q => output_final(18));
   U86 : IN2 port map( A => n118, Q => output_final(28));
   output_final_reg_3 : DFA port map( C => phi1, D => input_wip(28), Q => n232,
                           QN => n118, RN => n107);
   output_final_reg_13 : DFA port map( C => phi1, D => input_wip(18), Q => n233
                           , QN => n116, RN => n107);
   output_final_reg_14 : DFA port map( C => phi1, D => input_wip(17), Q => n234
                           , QN => n114, RN => n107);
   output_final_reg_0 : DFA port map( C => phi1, D => input_wip(31), Q => n235,
                           QN => n112, RN => n107);
   output_final_reg_10 : DFA port map( C => phi1, D => input_wip(21), Q => n236
                           , QN => n110, RN => n107);
   output_final_reg_6 : DFA port map( C => phi1, D => input_wip(25), Q => n237,
                           QN => n108, RN => n107);
   U87 : IN3 port map( A => n120, Q => output_final(16));
   output_final_reg_15 : DFA2 port map( C => phi1, D => input_wip(16), Q => 
                           n238, QN => n120, RN => n107);
   U88 : IN3 port map( A => n122, Q => output_final(19));
   output_final_reg_12 : DFA2 port map( C => phi1, D => input_wip(19), Q => 
                           n239, QN => n122, RN => n107);
   U89 : IN3 port map( A => n124, Q => output_final(27));
   output_final_reg_4 : DFA2 port map( C => phi1, D => input_wip(27), Q => n240
                           , QN => n124, RN => n107);
   U90 : IN3 port map( A => n126, Q => output_final(26));
   output_final_reg_5 : DFA2 port map( C => phi1, D => input_wip(26), Q => n241
                           , QN => n126, RN => n107);
   U91 : IN3 port map( A => n128, Q => output_final(29));
   output_final_reg_2 : DFA2 port map( C => phi1, D => input_wip(29), Q => n242
                           , QN => n128, RN => n107);
   U92 : IN3 port map( A => n130, Q => output_final(22));
   output_final_reg_9 : DFA2 port map( C => phi1, D => input_wip(22), Q => n243
                           , QN => n130, RN => n107);
   U93 : IN3 port map( A => n132, Q => output_final(20));
   output_final_reg_11 : DFA2 port map( C => phi1, D => input_wip(20), Q => 
                           n244, QN => n132, RN => n107);
   U94 : IN3 port map( A => n134, Q => output_final(24));
   output_final_reg_7 : DFA2 port map( C => phi1, D => input_wip(24), Q => n245
                           , QN => n134, RN => n107);
   U95 : IN3 port map( A => n136, Q => output_final(30));
   output_final_reg_1 : DFA2 port map( C => phi1, D => input_wip(30), Q => n246
                           , QN => n136, RN => n107);
   U96 : IN3 port map( A => n138, Q => output_final(23));
   output_final_reg_8 : DFA2 port map( C => phi1, D => input_wip(23), Q => n247
                           , QN => n138, RN => n107);
   output_final_reg_26 : DFA2 port map( C => phi1, D => input_wip(5), Q => 
                           output_final(5), QN => n248, RN => n107);
   output_final_reg_30 : DFA2 port map( C => phi1, D => input_wip(1), Q => 
                           output_final(1), QN => n249, RN => n107);
   output_final_reg_31 : DFA2 port map( C => phi1, D => input_wip(0), Q => 
                           output_final(0), QN => n250, RN => n107);
   output_final_reg_28 : DFA2 port map( C => phi1, D => input_wip(3), Q => 
                           output_final(3), QN => n251, RN => n107);

end SYN_behavior;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_phi1_register_0 is

   port( reset, phi1 : in std_logic;  input_wip, input_fcs : in 
         std_logic_vector (0 to 31);  output_wip, output_fcs : out 
         std_logic_vector (0 to 31));

end gf_phi1_register_0;

architecture SYN_behavior_0 of gf_phi1_register_0 is

   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component IN1
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN3
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component BU4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component BU8
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n187, n188, n189, n191, n193, n195, n197, n199, n201, n203, n205, 
      n207, n209, n211, n213, n215, n217, n219, n221, n223, n225, n227, n229, 
      n231, n233, n235, n237, n239, n241, n243, n245, n247, n249, n251, n253, 
      n255, n257, n259, n261, n263, n265, n267, n269, n271, n273, n442, n443, 
      n444, n445, n446, n447, n448, n449, n450, n451, n452, n453, n454, n455, 
      n456, n457, n458, n459, n460, n461, n462, n463, n464, n465, n466, n467, 
      n468, n469, n470, n471, n472, n473, n474, n475, n476, n477, n478, n479, 
      n480, n481, n482, n483, n484, n485, n486, n487, n488, n489, n490, n491, 
      n492, n493, n494, n495, n496, n497, n498, n499, n500, n501, n502, n503, 
      n504, n505 : std_logic;

begin
   
   output_wip_reg_27 : DFA port map( C => phi1, D => input_wip(4), Q => n442, 
                           QN => n203, RN => n188);
   output_wip_reg_24 : DFA port map( C => phi1, D => input_wip(7), Q => n443, 
                           QN => n209, RN => n187);
   output_wip_reg_22 : DFA port map( C => phi1, D => input_wip(9), Q => n444, 
                           QN => n211, RN => n187);
   output_wip_reg_23 : DFA port map( C => phi1, D => input_wip(8), Q => n445, 
                           QN => n227, RN => n188);
   U147 : IN1 port map( A => n197, Q => output_wip(1));
   U148 : IN1 port map( A => n199, Q => output_wip(2));
   U149 : IN1 port map( A => n203, Q => output_wip(4));
   U150 : IN1 port map( A => n207, Q => output_wip(6));
   U151 : IN1 port map( A => n209, Q => output_wip(7));
   U152 : IN1 port map( A => n211, Q => output_wip(9));
   U153 : IN1 port map( A => n213, Q => output_wip(12));
   U154 : IN1 port map( A => n215, Q => output_wip(14));
   U155 : IN1 port map( A => n217, Q => output_wip(28));
   U156 : IN1 port map( A => n219, Q => output_wip(16));
   U157 : IN1 port map( A => n221, Q => output_wip(18));
   U158 : IN1 port map( A => n223, Q => output_wip(19));
   U159 : IN1 port map( A => n225, Q => output_wip(25));
   U160 : IN1 port map( A => n227, Q => output_wip(8));
   U161 : IN1 port map( A => n229, Q => output_wip(13));
   U162 : IN1 port map( A => n231, Q => output_wip(15));
   U163 : IN1 port map( A => n233, Q => output_wip(17));
   U164 : IN1 port map( A => n235, Q => output_wip(20));
   U165 : IN1 port map( A => n237, Q => output_wip(21));
   U166 : IN1 port map( A => n239, Q => output_wip(22));
   U167 : IN1 port map( A => n241, Q => output_wip(23));
   U168 : IN1 port map( A => n243, Q => output_wip(24));
   U169 : IN1 port map( A => n245, Q => output_wip(26));
   U170 : IN1 port map( A => n247, Q => output_wip(27));
   U171 : IN1 port map( A => n249, Q => output_wip(29));
   U172 : IN1 port map( A => n251, Q => output_wip(30));
   U173 : IN1 port map( A => n257, Q => output_fcs(7));
   U174 : IN3 port map( A => n263, Q => output_fcs(14));
   U175 : IN3 port map( A => n269, Q => output_fcs(8));
   output_fcs_reg_31 : DFA2 port map( C => phi1, D => input_fcs(0), Q => 
                           output_fcs(0), QN => n446, RN => n188);
   output_fcs_reg_30 : DFA2 port map( C => phi1, D => input_fcs(1), Q => 
                           output_fcs(1), QN => n447, RN => n188);
   output_fcs_reg_29 : DFA2 port map( C => phi1, D => input_fcs(2), Q => 
                           output_fcs(2), QN => n448, RN => n188);
   output_fcs_reg_28 : DFA2 port map( C => phi1, D => input_fcs(3), Q => 
                           output_fcs(3), QN => n449, RN => n187);
   output_fcs_reg_26 : DFA2 port map( C => phi1, D => input_fcs(5), Q => 
                           output_fcs(5), QN => n450, RN => n188);
   output_fcs_reg_15 : DFA2 port map( C => phi1, D => input_fcs(16), Q => 
                           output_fcs(16), QN => n451, RN => n187);
   output_fcs_reg_14 : DFA2 port map( C => phi1, D => input_fcs(17), Q => 
                           output_fcs(17), QN => n452, RN => n187);
   output_fcs_reg_13 : DFA2 port map( C => phi1, D => input_fcs(18), Q => 
                           output_fcs(18), QN => n453, RN => n188);
   output_fcs_reg_12 : DFA2 port map( C => phi1, D => input_fcs(19), Q => 
                           output_fcs(19), QN => n454, RN => n188);
   output_fcs_reg_11 : DFA2 port map( C => phi1, D => input_fcs(20), Q => 
                           output_fcs(20), QN => n455, RN => n187);
   output_fcs_reg_10 : DFA2 port map( C => phi1, D => input_fcs(21), Q => 
                           output_fcs(21), QN => n456, RN => n187);
   output_fcs_reg_9 : DFA2 port map( C => phi1, D => input_fcs(22), Q => 
                           output_fcs(22), QN => n457, RN => n188);
   output_fcs_reg_8 : DFA2 port map( C => phi1, D => input_fcs(23), Q => 
                           output_fcs(23), QN => n458, RN => n188);
   output_fcs_reg_7 : DFA2 port map( C => phi1, D => input_fcs(24), Q => 
                           output_fcs(24), QN => n459, RN => n187);
   output_fcs_reg_6 : DFA2 port map( C => phi1, D => input_fcs(25), Q => 
                           output_fcs(25), QN => n460, RN => n188);
   output_fcs_reg_3 : DFA2 port map( C => phi1, D => input_fcs(28), Q => 
                           output_fcs(28), QN => n461, RN => n187);
   output_fcs_reg_2 : DFA2 port map( C => phi1, D => input_fcs(29), Q => 
                           output_fcs(29), QN => n462, RN => n187);
   output_fcs_reg_1 : DFA2 port map( C => phi1, D => input_fcs(30), Q => 
                           output_fcs(30), QN => n463, RN => n188);
   output_fcs_reg_0 : DFA2 port map( C => phi1, D => input_fcs(31), Q => 
                           output_fcs(31), QN => n464, RN => n188);
   U176 : BU4 port map( A => reset, Q => n187);
   U177 : BU8 port map( A => n187, Q => n188);
   U178 : IN3 port map( A => n189, Q => output_wip(31));
   output_wip_reg_0 : DFA2 port map( C => phi1, D => input_wip(31), Q => n465, 
                           QN => n189, RN => n188);
   U179 : IN3 port map( A => n191, Q => output_wip(10));
   output_wip_reg_21 : DFA2 port map( C => phi1, D => input_wip(10), Q => n466,
                           QN => n191, RN => n188);
   U180 : IN3 port map( A => n193, Q => output_wip(11));
   output_wip_reg_20 : DFA2 port map( C => phi1, D => input_wip(11), Q => n467,
                           QN => n193, RN => n188);
   U181 : IN3 port map( A => n195, Q => output_wip(0));
   output_wip_reg_31 : DFA2 port map( C => phi1, D => input_wip(0), Q => n468, 
                           QN => n195, RN => n188);
   output_wip_reg_30 : DFA2 port map( C => phi1, D => input_wip(1), Q => n469, 
                           QN => n197, RN => n188);
   output_wip_reg_29 : DFA2 port map( C => phi1, D => input_wip(2), Q => n470, 
                           QN => n199, RN => n187);
   U182 : IN3 port map( A => n201, Q => output_wip(3));
   output_wip_reg_28 : DFA2 port map( C => phi1, D => input_wip(3), Q => n471, 
                           QN => n201, RN => n187);
   U183 : IN3 port map( A => n205, Q => output_wip(5));
   output_wip_reg_26 : DFA2 port map( C => phi1, D => input_wip(5), Q => n472, 
                           QN => n205, RN => n188);
   output_wip_reg_25 : DFA2 port map( C => phi1, D => input_wip(6), Q => n473, 
                           QN => n207, RN => n187);
   output_wip_reg_19 : DFA2 port map( C => phi1, D => input_wip(12), Q => n474,
                           QN => n213, RN => n187);
   output_wip_reg_17 : DFA2 port map( C => phi1, D => input_wip(14), Q => n475,
                           QN => n215, RN => n187);
   output_wip_reg_3 : DFA2 port map( C => phi1, D => input_wip(28), Q => n476, 
                           QN => n217, RN => n187);
   output_wip_reg_15 : DFA2 port map( C => phi1, D => input_wip(16), Q => n477,
                           QN => n219, RN => n188);
   output_wip_reg_13 : DFA2 port map( C => phi1, D => input_wip(18), Q => n478,
                           QN => n221, RN => n188);
   output_wip_reg_12 : DFA2 port map( C => phi1, D => input_wip(19), Q => n479,
                           QN => n223, RN => n188);
   output_wip_reg_6 : DFA2 port map( C => phi1, D => input_wip(25), Q => n480, 
                           QN => n225, RN => n188);
   output_wip_reg_18 : DFA2 port map( C => phi1, D => input_wip(13), Q => n481,
                           QN => n229, RN => n188);
   output_wip_reg_16 : DFA2 port map( C => phi1, D => input_wip(15), Q => n482,
                           QN => n231, RN => n187);
   output_wip_reg_14 : DFA2 port map( C => phi1, D => input_wip(17), Q => n483,
                           QN => n233, RN => n187);
   output_wip_reg_11 : DFA2 port map( C => phi1, D => input_wip(20), Q => n484,
                           QN => n235, RN => n188);
   output_wip_reg_10 : DFA2 port map( C => phi1, D => input_wip(21), Q => n485,
                           QN => n237, RN => n187);
   output_wip_reg_9 : DFA2 port map( C => phi1, D => input_wip(22), Q => n486, 
                           QN => n239, RN => n187);
   output_wip_reg_8 : DFA2 port map( C => phi1, D => input_wip(23), Q => n487, 
                           QN => n241, RN => n188);
   output_wip_reg_7 : DFA2 port map( C => phi1, D => input_wip(24), Q => n488, 
                           QN => n243, RN => n188);
   output_wip_reg_5 : DFA2 port map( C => phi1, D => input_wip(26), Q => n489, 
                           QN => n245, RN => n188);
   output_wip_reg_4 : DFA2 port map( C => phi1, D => input_wip(27), Q => n490, 
                           QN => n247, RN => n187);
   output_wip_reg_2 : DFA2 port map( C => phi1, D => input_wip(29), Q => n491, 
                           QN => n249, RN => n188);
   output_wip_reg_1 : DFA2 port map( C => phi1, D => input_wip(30), Q => n492, 
                           QN => n251, RN => n188);
   U184 : IN4 port map( A => n253, Q => output_fcs(26));
   U185 : IN4 port map( A => n255, Q => output_fcs(27));
   U186 : IN4 port map( A => n259, Q => output_fcs(13));
   U187 : IN4 port map( A => n261, Q => output_fcs(15));
   U188 : IN4 port map( A => n265, Q => output_fcs(12));
   U189 : IN4 port map( A => n267, Q => output_fcs(11));
   U190 : IN4 port map( A => n271, Q => output_fcs(10));
   output_fcs_reg_21 : DFA2 port map( C => phi1, D => input_fcs(10), Q => n493,
                           QN => n271, RN => n187);
   U191 : IN4 port map( A => n273, Q => output_fcs(9));
   output_fcs_reg_22 : DFA2 port map( C => phi1, D => input_fcs(9), Q => n494, 
                           QN => n273, RN => n188);
   output_fcs_reg_24 : DFA2 port map( C => phi1, D => input_fcs(7), Q => n495, 
                           QN => n257, RN => n188);
   output_fcs_reg_25 : DFA2 port map( C => phi1, D => input_fcs(6), Q => 
                           output_fcs(6), QN => n496, RN => n188);
   output_fcs_reg_4 : DFA2 port map( C => phi1, D => input_fcs(27), Q => n497, 
                           QN => n255, RN => n187);
   output_fcs_reg_5 : DFA2 port map( C => phi1, D => input_fcs(26), Q => n498, 
                           QN => n253, RN => n187);
   output_fcs_reg_27 : DFA2 port map( C => phi1, D => input_fcs(4), Q => 
                           output_fcs(4), QN => n499, RN => n187);
   output_fcs_reg_17 : DFA2 port map( C => phi1, D => input_fcs(14), Q => n500,
                           QN => n263, RN => n188);
   output_fcs_reg_16 : DFA2 port map( C => phi1, D => input_fcs(15), Q => n501,
                           QN => n261, RN => n188);
   output_fcs_reg_23 : DFA2 port map( C => phi1, D => input_fcs(8), Q => n502, 
                           QN => n269, RN => n188);
   output_fcs_reg_18 : DFA2 port map( C => phi1, D => input_fcs(13), Q => n503,
                           QN => n259, RN => n187);
   output_fcs_reg_19 : DFA2 port map( C => phi1, D => input_fcs(12), Q => n504,
                           QN => n265, RN => n187);
   output_fcs_reg_20 : DFA2 port map( C => phi1, D => input_fcs(11), Q => n505,
                           QN => n267, RN => n188);

end SYN_behavior_0;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_phi1_register_1 is

   port( reset, phi1 : in std_logic;  input_wip, input_fcs : in 
         std_logic_vector (0 to 31);  output_wip, output_fcs : out 
         std_logic_vector (0 to 31));

end gf_phi1_register_1;

architecture SYN_behavior_1 of gf_phi1_register_1 is

   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component IN1
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component BU8
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component BU4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component DFA4
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component IN3
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN8
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n214, n232, n236, n244, n252, n270, n274, n315, n317, n319, n321, 
      n323, n325, n327, n329, n331, n333, n335, n337, n339, n341, n343, n345, 
      n347, n349, n351, n353, n355, n357, n359, n361, n363, n365, n367, n369, 
      n371, n373, n375, n377, n379, n381, n383, n385, n549, n550, n551, n552, 
      n553, n554, n555, n556, n557, n558, n559, n560, n561, n562, n563, n564, 
      n565, n566, n567, n568, n569, n570, n571, n572, n573, n574, n575, n576, 
      n577, n578, n579, n580, n581, n582, n583, n584, n585, n586, n587, n588, 
      n589, n590, n591, n592, n593, n594, n595, n596, n597, n598, n599, n600, 
      n601, n602, n603, n604, n605, n606, n607, n608, n609, n610, n611, n612 : 
      std_logic;

begin
   
   output_wip_reg_24 : DFA port map( C => phi1, D => input_wip(7), Q => n549, 
                           QN => n236, RN => n232);
   output_wip_reg_29 : DFA port map( C => phi1, D => input_wip(2), Q => n550, 
                           QN => n270, RN => n214);
   output_wip_reg_28 : DFA port map( C => phi1, D => input_wip(3), Q => n551, 
                           QN => n274, RN => n232);
   output_wip_reg_12 : DFA port map( C => phi1, D => input_wip(19), Q => n552, 
                           QN => n335, RN => n232);
   output_wip_reg_5 : DFA port map( C => phi1, D => input_wip(26), Q => n553, 
                           QN => n349, RN => n232);
   U147 : IN1 port map( A => n236, Q => output_wip(7));
   U148 : IN1 port map( A => n270, Q => output_wip(2));
   U149 : IN1 port map( A => n274, Q => output_wip(3));
   U150 : IN1 port map( A => n317, Q => output_wip(9));
   U151 : IN1 port map( A => n323, Q => output_wip(13));
   U152 : IN1 port map( A => n331, Q => output_wip(17));
   U153 : IN1 port map( A => n335, Q => output_wip(19));
   U154 : IN1 port map( A => n341, Q => output_wip(22));
   U155 : IN1 port map( A => n345, Q => output_wip(24));
   U156 : IN1 port map( A => n349, Q => output_wip(26));
   U157 : IN1 port map( A => n351, Q => output_wip(27));
   U158 : IN1 port map( A => n353, Q => output_wip(28));
   U159 : IN1 port map( A => n357, Q => output_wip(30));
   U160 : IN1 port map( A => n359, Q => output_wip(31));
   U161 : IN1 port map( A => n361, Q => output_wip(4));
   U162 : IN1 port map( A => n363, Q => output_wip(5));
   U163 : IN1 port map( A => n365, Q => output_wip(6));
   U164 : IN1 port map( A => n367, Q => output_wip(11));
   U165 : IN1 port map( A => n373, Q => output_fcs(11));
   U166 : IN1 port map( A => n371, Q => output_fcs(10));
   output_fcs_reg_19 : DFA2 port map( C => phi1, D => input_fcs(12), Q => 
                           output_fcs(12), QN => n554, RN => n214);
   output_fcs_reg_18 : DFA2 port map( C => phi1, D => input_fcs(13), Q => 
                           output_fcs(13), QN => n555, RN => n232);
   output_fcs_reg_17 : DFA2 port map( C => phi1, D => input_fcs(14), Q => 
                           output_fcs(14), QN => n556, RN => n214);
   output_fcs_reg_16 : DFA2 port map( C => phi1, D => input_fcs(15), Q => 
                           output_fcs(15), QN => n557, RN => n232);
   output_fcs_reg_15 : DFA2 port map( C => phi1, D => input_fcs(16), Q => 
                           output_fcs(16), QN => n558, RN => n232);
   output_fcs_reg_14 : DFA2 port map( C => phi1, D => input_fcs(17), Q => 
                           output_fcs(17), QN => n559, RN => n232);
   output_fcs_reg_13 : DFA2 port map( C => phi1, D => input_fcs(18), Q => 
                           output_fcs(18), QN => n560, RN => n232);
   output_fcs_reg_12 : DFA2 port map( C => phi1, D => input_fcs(19), Q => 
                           output_fcs(19), QN => n561, RN => n232);
   output_fcs_reg_11 : DFA2 port map( C => phi1, D => input_fcs(20), Q => 
                           output_fcs(20), QN => n562, RN => n232);
   output_fcs_reg_10 : DFA2 port map( C => phi1, D => input_fcs(21), Q => 
                           output_fcs(21), QN => n563, RN => n232);
   output_fcs_reg_9 : DFA2 port map( C => phi1, D => input_fcs(22), Q => 
                           output_fcs(22), QN => n564, RN => n232);
   output_fcs_reg_8 : DFA2 port map( C => phi1, D => input_fcs(23), Q => 
                           output_fcs(23), QN => n565, RN => n232);
   output_fcs_reg_7 : DFA2 port map( C => phi1, D => input_fcs(24), Q => 
                           output_fcs(24), QN => n566, RN => n232);
   output_fcs_reg_6 : DFA2 port map( C => phi1, D => input_fcs(25), Q => 
                           output_fcs(25), QN => n567, RN => n232);
   output_fcs_reg_5 : DFA2 port map( C => phi1, D => input_fcs(26), Q => 
                           output_fcs(26), QN => n568, RN => n232);
   output_fcs_reg_4 : DFA2 port map( C => phi1, D => input_fcs(27), Q => 
                           output_fcs(27), QN => n569, RN => n232);
   output_fcs_reg_3 : DFA2 port map( C => phi1, D => input_fcs(28), Q => 
                           output_fcs(28), QN => n570, RN => n232);
   output_fcs_reg_2 : DFA2 port map( C => phi1, D => input_fcs(29), Q => 
                           output_fcs(29), QN => n571, RN => n232);
   output_fcs_reg_1 : DFA2 port map( C => phi1, D => input_fcs(30), Q => 
                           output_fcs(30), QN => n572, RN => n232);
   output_fcs_reg_0 : DFA2 port map( C => phi1, D => input_fcs(31), Q => 
                           output_fcs(31), QN => n573, RN => n232);
   U167 : BU8 port map( A => n214, Q => n232);
   U168 : BU4 port map( A => reset, Q => n214);
   output_fcs_reg_24 : DFA4 port map( C => phi1, D => input_fcs(7), Q => n574, 
                           QN => n383, RN => n232);
   output_fcs_reg_25 : DFA4 port map( C => phi1, D => input_fcs(6), Q => n575, 
                           QN => n385, RN => n232);
   U169 : IN3 port map( A => n244, Q => output_wip(0));
   output_wip_reg_31 : DFA2 port map( C => phi1, D => input_wip(0), Q => n576, 
                           QN => n244, RN => n232);
   U170 : IN3 port map( A => n252, Q => output_wip(1));
   output_wip_reg_30 : DFA2 port map( C => phi1, D => input_wip(1), Q => n577, 
                           QN => n252, RN => n232);
   U171 : IN3 port map( A => n315, Q => output_wip(8));
   output_wip_reg_23 : DFA2 port map( C => phi1, D => input_wip(8), Q => n578, 
                           QN => n315, RN => n232);
   output_wip_reg_22 : DFA2 port map( C => phi1, D => input_wip(9), Q => n579, 
                           QN => n317, RN => n214);
   U172 : IN3 port map( A => n319, Q => output_wip(10));
   output_wip_reg_21 : DFA2 port map( C => phi1, D => input_wip(10), Q => n580,
                           QN => n319, RN => n214);
   U173 : IN3 port map( A => n321, Q => output_wip(12));
   output_wip_reg_19 : DFA2 port map( C => phi1, D => input_wip(12), Q => n581,
                           QN => n321, RN => n214);
   output_wip_reg_18 : DFA2 port map( C => phi1, D => input_wip(13), Q => n582,
                           QN => n323, RN => n232);
   U174 : IN3 port map( A => n325, Q => output_wip(14));
   output_wip_reg_17 : DFA2 port map( C => phi1, D => input_wip(14), Q => n583,
                           QN => n325, RN => n232);
   U175 : IN3 port map( A => n327, Q => output_wip(15));
   output_wip_reg_16 : DFA2 port map( C => phi1, D => input_wip(15), Q => n584,
                           QN => n327, RN => n214);
   U176 : IN3 port map( A => n329, Q => output_wip(16));
   output_wip_reg_15 : DFA2 port map( C => phi1, D => input_wip(16), Q => n585,
                           QN => n329, RN => n214);
   output_wip_reg_14 : DFA2 port map( C => phi1, D => input_wip(17), Q => n586,
                           QN => n331, RN => n232);
   U177 : IN3 port map( A => n333, Q => output_wip(18));
   output_wip_reg_13 : DFA2 port map( C => phi1, D => input_wip(18), Q => n587,
                           QN => n333, RN => n232);
   U178 : IN3 port map( A => n337, Q => output_wip(20));
   output_wip_reg_11 : DFA2 port map( C => phi1, D => input_wip(20), Q => n588,
                           QN => n337, RN => n232);
   U179 : IN3 port map( A => n339, Q => output_wip(21));
   output_wip_reg_10 : DFA2 port map( C => phi1, D => input_wip(21), Q => n589,
                           QN => n339, RN => n232);
   output_wip_reg_9 : DFA2 port map( C => phi1, D => input_wip(22), Q => n590, 
                           QN => n341, RN => n232);
   U180 : IN3 port map( A => n343, Q => output_wip(23));
   output_wip_reg_8 : DFA2 port map( C => phi1, D => input_wip(23), Q => n591, 
                           QN => n343, RN => n214);
   output_wip_reg_7 : DFA2 port map( C => phi1, D => input_wip(24), Q => n592, 
                           QN => n345, RN => n214);
   U181 : IN3 port map( A => n347, Q => output_wip(25));
   output_wip_reg_6 : DFA2 port map( C => phi1, D => input_wip(25), Q => n593, 
                           QN => n347, RN => n232);
   output_wip_reg_4 : DFA2 port map( C => phi1, D => input_wip(27), Q => n594, 
                           QN => n351, RN => n214);
   output_wip_reg_3 : DFA2 port map( C => phi1, D => input_wip(28), Q => n595, 
                           QN => n353, RN => n232);
   U182 : IN3 port map( A => n355, Q => output_wip(29));
   output_wip_reg_2 : DFA2 port map( C => phi1, D => input_wip(29), Q => n596, 
                           QN => n355, RN => n232);
   output_wip_reg_1 : DFA2 port map( C => phi1, D => input_wip(30), Q => n597, 
                           QN => n357, RN => n232);
   output_wip_reg_0 : DFA2 port map( C => phi1, D => input_wip(31), Q => n598, 
                           QN => n359, RN => n232);
   output_wip_reg_27 : DFA2 port map( C => phi1, D => input_wip(4), Q => n599, 
                           QN => n361, RN => n232);
   output_wip_reg_26 : DFA2 port map( C => phi1, D => input_wip(5), Q => n600, 
                           QN => n363, RN => n214);
   output_wip_reg_25 : DFA2 port map( C => phi1, D => input_wip(6), Q => n601, 
                           QN => n365, RN => n214);
   output_wip_reg_20 : DFA2 port map( C => phi1, D => input_wip(11), Q => n602,
                           QN => n367, RN => n214);
   U183 : IN4 port map( A => n369, Q => output_fcs(9));
   output_fcs_reg_20 : DFA2 port map( C => phi1, D => input_fcs(11), Q => n603,
                           QN => n373, RN => n214);
   U184 : IN4 port map( A => n375, Q => output_fcs(3));
   U185 : IN4 port map( A => n377, Q => output_fcs(8));
   U186 : IN8 port map( A => n385, Q => output_fcs(6));
   U187 : IN8 port map( A => n383, Q => output_fcs(7));
   U188 : IN4 port map( A => n379, Q => output_fcs(5));
   U189 : IN4 port map( A => n381, Q => output_fcs(4));
   output_fcs_reg_27 : DFA2 port map( C => phi1, D => input_fcs(4), Q => n604, 
                           QN => n381, RN => n214);
   output_fcs_reg_21 : DFA2 port map( C => phi1, D => input_fcs(10), Q => n605,
                           QN => n371, RN => n214);
   output_fcs_reg_30 : DFA2 port map( C => phi1, D => input_fcs(1), Q => 
                           output_fcs(1), QN => n606, RN => n214);
   output_fcs_reg_23 : DFA2 port map( C => phi1, D => input_fcs(8), Q => n607, 
                           QN => n377, RN => n214);
   output_fcs_reg_22 : DFA2 port map( C => phi1, D => input_fcs(9), Q => n608, 
                           QN => n369, RN => n214);
   output_fcs_reg_26 : DFA2 port map( C => phi1, D => input_fcs(5), Q => n609, 
                           QN => n379, RN => n214);
   output_fcs_reg_29 : DFA2 port map( C => phi1, D => input_fcs(2), Q => 
                           output_fcs(2), QN => n610, RN => n232);
   output_fcs_reg_28 : DFA2 port map( C => phi1, D => input_fcs(3), Q => n611, 
                           QN => n375, RN => n214);
   output_fcs_reg_31 : DFA2 port map( C => phi1, D => input_fcs(0), Q => 
                           output_fcs(0), QN => n612, RN => n232);

end SYN_behavior_1;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_phi1_register_2 is

   port( reset, phi1 : in std_logic;  input_wip, input_fcs : in 
         std_logic_vector (0 to 31);  output_wip, output_fcs : out 
         std_logic_vector (0 to 31));

end gf_phi1_register_2;

architecture SYN_behavior_2 of gf_phi1_register_2 is

   component IN1
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component BU4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component BU2
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN3
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n318, n322, n326, n330, n342, n346, n350, n354, n358, n362, n366, 
      n370, n374, n378, n557, n558, n559, n560, n561, n562, n563, n564, n565, 
      n566, n567, n568, n569, n570, n571, n572, n573, n574, n575, n576, n577, 
      n578, n579, n580, n581, n582, n583, n584, n585, n586, n587, n588, n589, 
      n590, n591, n592, n593, n594, n595, n596, n597, n598, n599, n600, n601, 
      n602, n603, n604, n605, n606, n607, n608, n609, n610, n611, n612, n613, 
      n614, n615, n616, n617, n618, n619, n620 : std_logic;

begin
   
   U147 : IN1 port map( A => n366, Q => output_wip(19));
   output_fcs_reg_31 : DFA2 port map( C => phi1, D => input_fcs(0), Q => 
                           output_fcs(0), QN => n557, RN => n326);
   output_fcs_reg_30 : DFA2 port map( C => phi1, D => input_fcs(1), Q => 
                           output_fcs(1), QN => n558, RN => n322);
   output_fcs_reg_29 : DFA2 port map( C => phi1, D => input_fcs(2), Q => 
                           output_fcs(2), QN => n559, RN => n326);
   output_fcs_reg_28 : DFA2 port map( C => phi1, D => input_fcs(3), Q => 
                           output_fcs(3), QN => n560, RN => n322);
   output_fcs_reg_27 : DFA2 port map( C => phi1, D => input_fcs(4), Q => 
                           output_fcs(4), QN => n561, RN => n326);
   output_fcs_reg_26 : DFA2 port map( C => phi1, D => input_fcs(5), Q => 
                           output_fcs(5), QN => n562, RN => n322);
   output_fcs_reg_25 : DFA2 port map( C => phi1, D => input_fcs(6), Q => 
                           output_fcs(6), QN => n563, RN => n326);
   output_fcs_reg_24 : DFA2 port map( C => phi1, D => input_fcs(7), Q => 
                           output_fcs(7), QN => n564, RN => n322);
   output_fcs_reg_23 : DFA2 port map( C => phi1, D => input_fcs(8), Q => 
                           output_fcs(8), QN => n565, RN => n326);
   output_fcs_reg_22 : DFA2 port map( C => phi1, D => input_fcs(9), Q => 
                           output_fcs(9), QN => n566, RN => n322);
   output_fcs_reg_21 : DFA2 port map( C => phi1, D => input_fcs(10), Q => 
                           output_fcs(10), QN => n567, RN => n318);
   output_fcs_reg_20 : DFA2 port map( C => phi1, D => input_fcs(11), Q => 
                           output_fcs(11), QN => n568, RN => n326);
   output_fcs_reg_15 : DFA2 port map( C => phi1, D => input_fcs(16), Q => 
                           output_fcs(16), QN => n569, RN => n322);
   output_fcs_reg_14 : DFA2 port map( C => phi1, D => input_fcs(17), Q => 
                           output_fcs(17), QN => n570, RN => n322);
   output_fcs_reg_13 : DFA2 port map( C => phi1, D => input_fcs(18), Q => 
                           output_fcs(18), QN => n571, RN => n322);
   output_fcs_reg_12 : DFA2 port map( C => phi1, D => input_fcs(19), Q => 
                           output_fcs(19), QN => n572, RN => n322);
   output_fcs_reg_11 : DFA2 port map( C => phi1, D => input_fcs(20), Q => 
                           output_fcs(20), QN => n573, RN => n322);
   output_fcs_reg_10 : DFA2 port map( C => phi1, D => input_fcs(21), Q => 
                           output_fcs(21), QN => n574, RN => n322);
   output_fcs_reg_9 : DFA2 port map( C => phi1, D => input_fcs(22), Q => 
                           output_fcs(22), QN => n575, RN => n322);
   output_fcs_reg_8 : DFA2 port map( C => phi1, D => input_fcs(23), Q => 
                           output_fcs(23), QN => n576, RN => n318);
   output_fcs_reg_7 : DFA2 port map( C => phi1, D => input_fcs(24), Q => 
                           output_fcs(24), QN => n577, RN => n322);
   output_fcs_reg_6 : DFA2 port map( C => phi1, D => input_fcs(25), Q => 
                           output_fcs(25), QN => n578, RN => n322);
   output_fcs_reg_5 : DFA2 port map( C => phi1, D => input_fcs(26), Q => 
                           output_fcs(26), QN => n579, RN => n322);
   output_fcs_reg_4 : DFA2 port map( C => phi1, D => input_fcs(27), Q => 
                           output_fcs(27), QN => n580, RN => n322);
   output_fcs_reg_3 : DFA2 port map( C => phi1, D => input_fcs(28), Q => 
                           output_fcs(28), QN => n581, RN => n322);
   output_fcs_reg_2 : DFA2 port map( C => phi1, D => input_fcs(29), Q => 
                           output_fcs(29), QN => n582, RN => n326);
   output_fcs_reg_1 : DFA2 port map( C => phi1, D => input_fcs(30), Q => 
                           output_fcs(30), QN => n583, RN => n322);
   output_fcs_reg_0 : DFA2 port map( C => phi1, D => input_fcs(31), Q => 
                           output_fcs(31), QN => n584, RN => n326);
   output_wip_reg_31 : DFA2 port map( C => phi1, D => input_wip(0), Q => 
                           output_wip(0), QN => n585, RN => n322);
   output_wip_reg_30 : DFA2 port map( C => phi1, D => input_wip(1), Q => 
                           output_wip(1), QN => n586, RN => n322);
   output_wip_reg_29 : DFA2 port map( C => phi1, D => input_wip(2), Q => 
                           output_wip(2), QN => n587, RN => n322);
   output_wip_reg_28 : DFA2 port map( C => phi1, D => input_wip(3), Q => 
                           output_wip(3), QN => n588, RN => n318);
   output_wip_reg_27 : DFA2 port map( C => phi1, D => input_wip(4), Q => 
                           output_wip(4), QN => n589, RN => n326);
   output_wip_reg_26 : DFA2 port map( C => phi1, D => input_wip(5), Q => 
                           output_wip(5), QN => n590, RN => n326);
   output_wip_reg_25 : DFA2 port map( C => phi1, D => input_wip(6), Q => 
                           output_wip(6), QN => n591, RN => n326);
   output_wip_reg_24 : DFA2 port map( C => phi1, D => input_wip(7), Q => 
                           output_wip(7), QN => n592, RN => n326);
   output_wip_reg_23 : DFA2 port map( C => phi1, D => input_wip(8), Q => 
                           output_wip(8), QN => n593, RN => n326);
   output_wip_reg_22 : DFA2 port map( C => phi1, D => input_wip(9), Q => 
                           output_wip(9), QN => n594, RN => n326);
   output_wip_reg_21 : DFA2 port map( C => phi1, D => input_wip(10), Q => 
                           output_wip(10), QN => n595, RN => n326);
   output_wip_reg_20 : DFA2 port map( C => phi1, D => input_wip(11), Q => 
                           output_wip(11), QN => n596, RN => n318);
   output_wip_reg_19 : DFA2 port map( C => phi1, D => input_wip(12), Q => 
                           output_wip(12), QN => n597, RN => n326);
   output_wip_reg_18 : DFA2 port map( C => phi1, D => input_wip(13), Q => 
                           output_wip(13), QN => n598, RN => n326);
   output_wip_reg_17 : DFA2 port map( C => phi1, D => input_wip(14), Q => 
                           output_wip(14), QN => n599, RN => n326);
   output_wip_reg_16 : DFA2 port map( C => phi1, D => input_wip(15), Q => 
                           output_wip(15), QN => n600, RN => n326);
   output_wip_reg_10 : DFA2 port map( C => phi1, D => input_wip(21), Q => 
                           output_wip(21), QN => n601, RN => n326);
   output_wip_reg_0 : DFA2 port map( C => phi1, D => input_wip(31), Q => 
                           output_wip(31), QN => n602, RN => n326);
   U148 : BU4 port map( A => n318, Q => n326);
   U149 : BU4 port map( A => n318, Q => n322);
   U150 : BU2 port map( A => reset, Q => n318);
   U151 : IN3 port map( A => n330, Q => output_wip(27));
   output_wip_reg_4 : DFA2 port map( C => phi1, D => input_wip(27), Q => n603, 
                           QN => n330, RN => n318);
   U152 : IN3 port map( A => n342, Q => output_wip(29));
   output_wip_reg_2 : DFA2 port map( C => phi1, D => input_wip(29), Q => n604, 
                           QN => n342, RN => n318);
   U153 : IN3 port map( A => n346, Q => output_wip(26));
   output_wip_reg_5 : DFA2 port map( C => phi1, D => input_wip(26), Q => n605, 
                           QN => n346, RN => n318);
   U154 : IN3 port map( A => n350, Q => output_wip(17));
   output_wip_reg_14 : DFA2 port map( C => phi1, D => input_wip(17), Q => n606,
                           QN => n350, RN => n318);
   U155 : IN3 port map( A => n354, Q => output_wip(25));
   output_wip_reg_6 : DFA2 port map( C => phi1, D => input_wip(25), Q => n607, 
                           QN => n354, RN => n318);
   U156 : IN3 port map( A => n358, Q => output_wip(28));
   output_wip_reg_3 : DFA2 port map( C => phi1, D => input_wip(28), Q => n608, 
                           QN => n358, RN => n326);
   U157 : IN3 port map( A => n362, Q => output_wip(18));
   output_wip_reg_13 : DFA2 port map( C => phi1, D => input_wip(18), Q => n609,
                           QN => n362, RN => n326);
   output_wip_reg_12 : DFA2 port map( C => phi1, D => input_wip(19), Q => n610,
                           QN => n366, RN => n326);
   U158 : IN4 port map( A => n370, Q => output_fcs(13));
   U159 : IN4 port map( A => n374, Q => output_fcs(15));
   U160 : IN4 port map( A => n378, Q => output_fcs(14));
   output_fcs_reg_18 : DFA2 port map( C => phi1, D => input_fcs(13), Q => n611,
                           QN => n370, RN => n322);
   output_fcs_reg_16 : DFA2 port map( C => phi1, D => input_fcs(15), Q => n612,
                           QN => n374, RN => n326);
   output_wip_reg_15 : DFA2 port map( C => phi1, D => input_wip(16), Q => 
                           output_wip(16), QN => n613, RN => n322);
   output_wip_reg_9 : DFA2 port map( C => phi1, D => input_wip(22), Q => 
                           output_wip(22), QN => n614, RN => n326);
   output_wip_reg_11 : DFA2 port map( C => phi1, D => input_wip(20), Q => 
                           output_wip(20), QN => n615, RN => n322);
   output_wip_reg_8 : DFA2 port map( C => phi1, D => input_wip(23), Q => 
                           output_wip(23), QN => n616, RN => n326);
   output_wip_reg_7 : DFA2 port map( C => phi1, D => input_wip(24), Q => 
                           output_wip(24), QN => n617, RN => n322);
   output_wip_reg_1 : DFA2 port map( C => phi1, D => input_wip(30), Q => 
                           output_wip(30), QN => n618, RN => n326);
   output_fcs_reg_19 : DFA2 port map( C => phi1, D => input_fcs(12), Q => 
                           output_fcs(12), QN => n619, RN => n322);
   output_fcs_reg_17 : DFA2 port map( C => phi1, D => input_fcs(14), Q => n620,
                           QN => n378, RN => n322);

end SYN_behavior_2;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_phi1_register_3 is

   port( reset, phi1 : in std_logic;  input_wip, input_fcs : in 
         std_logic_vector (0 to 31);  output_wip, output_fcs : out 
         std_logic_vector (0 to 31));

end gf_phi1_register_3;

architecture SYN_behavior_3 of gf_phi1_register_3 is

   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component IN1
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component BU4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component BU8
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN3
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n340, n344, n348, n356, n364, n372, n380, n430, n432, n434, n436, 
      n438, n440, n442, n444, n446, n448, n450, n452, n454, n456, n458, n460, 
      n462, n464, n466, n468, n470, n472, n474, n627, n628, n629, n630, n631, 
      n632, n633, n634, n635, n636, n637, n638, n639, n640, n641, n642, n643, 
      n644, n645, n646, n647, n648, n649, n650, n651, n652, n653, n654, n655, 
      n656, n657, n658, n659, n660, n661, n662, n663, n664, n665, n666, n667, 
      n668, n669, n670, n671, n672, n673, n674, n675, n676, n677, n678, n679, 
      n680, n681, n682, n683, n684, n685, n686, n687, n688, n689, n690 : 
      std_logic;

begin
   
   output_wip_reg_11 : DFA port map( C => phi1, D => input_wip(20), Q => n627, 
                           QN => n434, RN => n344);
   output_wip_reg_8 : DFA port map( C => phi1, D => input_wip(23), Q => n628, 
                           QN => n436, RN => n344);
   output_wip_reg_1 : DFA port map( C => phi1, D => input_wip(30), Q => n629, 
                           QN => n446, RN => n340);
   output_wip_reg_9 : DFA port map( C => phi1, D => input_wip(22), Q => n630, 
                           QN => n452, RN => n344);
   output_wip_reg_2 : DFA port map( C => phi1, D => input_wip(29), Q => n631, 
                           QN => n456, RN => n344);
   U147 : IN1 port map( A => n430, Q => output_wip(18));
   U148 : IN1 port map( A => n432, Q => output_wip(19));
   U149 : IN1 port map( A => n434, Q => output_wip(20));
   U150 : IN1 port map( A => n436, Q => output_wip(23));
   U151 : IN1 port map( A => n438, Q => output_wip(24));
   U152 : IN1 port map( A => n440, Q => output_wip(25));
   U153 : IN1 port map( A => n442, Q => output_wip(27));
   U154 : IN1 port map( A => n444, Q => output_wip(28));
   U155 : IN1 port map( A => n446, Q => output_wip(30));
   U156 : IN1 port map( A => n448, Q => output_wip(16));
   U157 : IN1 port map( A => n450, Q => output_wip(17));
   U158 : IN1 port map( A => n452, Q => output_wip(22));
   U159 : IN1 port map( A => n454, Q => output_wip(26));
   U160 : IN1 port map( A => n456, Q => output_wip(29));
   output_fcs_reg_31 : DFA2 port map( C => phi1, D => input_fcs(0), Q => 
                           output_fcs(0), QN => n632, RN => n340);
   output_fcs_reg_30 : DFA2 port map( C => phi1, D => input_fcs(1), Q => 
                           output_fcs(1), QN => n633, RN => n340);
   output_fcs_reg_29 : DFA2 port map( C => phi1, D => input_fcs(2), Q => 
                           output_fcs(2), QN => n634, RN => n344);
   output_fcs_reg_28 : DFA2 port map( C => phi1, D => input_fcs(3), Q => 
                           output_fcs(3), QN => n635, RN => n344);
   output_fcs_reg_27 : DFA2 port map( C => phi1, D => input_fcs(4), Q => 
                           output_fcs(4), QN => n636, RN => n340);
   output_fcs_reg_26 : DFA2 port map( C => phi1, D => input_fcs(5), Q => 
                           output_fcs(5), QN => n637, RN => n344);
   output_fcs_reg_25 : DFA2 port map( C => phi1, D => input_fcs(6), Q => 
                           output_fcs(6), QN => n638, RN => n340);
   output_fcs_reg_24 : DFA2 port map( C => phi1, D => input_fcs(7), Q => 
                           output_fcs(7), QN => n639, RN => n340);
   output_fcs_reg_5 : DFA2 port map( C => phi1, D => input_fcs(26), Q => 
                           output_fcs(26), QN => n640, RN => n344);
   output_fcs_reg_4 : DFA2 port map( C => phi1, D => input_fcs(27), Q => 
                           output_fcs(27), QN => n641, RN => n344);
   output_wip_reg_21 : DFA2 port map( C => phi1, D => input_wip(10), Q => 
                           output_wip(10), QN => n642, RN => n340);
   output_wip_reg_20 : DFA2 port map( C => phi1, D => input_wip(11), Q => 
                           output_wip(11), QN => n643, RN => n344);
   output_wip_reg_0 : DFA2 port map( C => phi1, D => input_wip(31), Q => 
                           output_wip(31), QN => n644, RN => n344);
   U161 : BU4 port map( A => reset, Q => n340);
   U162 : BU8 port map( A => n340, Q => n344);
   U163 : IN3 port map( A => n348, Q => output_wip(21));
   output_wip_reg_10 : DFA2 port map( C => phi1, D => input_wip(21), Q => n645,
                           QN => n348, RN => n344);
   U164 : IN3 port map( A => n356, Q => output_wip(8));
   output_wip_reg_23 : DFA2 port map( C => phi1, D => input_wip(8), Q => n646, 
                           QN => n356, RN => n344);
   U165 : IN3 port map( A => n364, Q => output_wip(13));
   output_wip_reg_18 : DFA2 port map( C => phi1, D => input_wip(13), Q => n647,
                           QN => n364, RN => n344);
   U166 : IN3 port map( A => n372, Q => output_wip(14));
   output_wip_reg_17 : DFA2 port map( C => phi1, D => input_wip(14), Q => n648,
                           QN => n372, RN => n344);
   U167 : IN3 port map( A => n380, Q => output_wip(15));
   output_wip_reg_16 : DFA2 port map( C => phi1, D => input_wip(15), Q => n649,
                           QN => n380, RN => n344);
   output_wip_reg_13 : DFA2 port map( C => phi1, D => input_wip(18), Q => n650,
                           QN => n430, RN => n340);
   output_wip_reg_12 : DFA2 port map( C => phi1, D => input_wip(19), Q => n651,
                           QN => n432, RN => n340);
   output_wip_reg_7 : DFA2 port map( C => phi1, D => input_wip(24), Q => n652, 
                           QN => n438, RN => n340);
   output_wip_reg_6 : DFA2 port map( C => phi1, D => input_wip(25), Q => n653, 
                           QN => n440, RN => n340);
   output_wip_reg_4 : DFA2 port map( C => phi1, D => input_wip(27), Q => n654, 
                           QN => n442, RN => n340);
   output_wip_reg_3 : DFA2 port map( C => phi1, D => input_wip(28), Q => n655, 
                           QN => n444, RN => n340);
   output_wip_reg_15 : DFA2 port map( C => phi1, D => input_wip(16), Q => n656,
                           QN => n448, RN => n340);
   output_wip_reg_14 : DFA2 port map( C => phi1, D => input_wip(17), Q => n657,
                           QN => n450, RN => n344);
   output_wip_reg_5 : DFA2 port map( C => phi1, D => input_wip(26), Q => n658, 
                           QN => n454, RN => n344);
   U168 : IN4 port map( A => n458, Q => output_fcs(24));
   U169 : IN4 port map( A => n460, Q => output_fcs(29));
   U170 : IN4 port map( A => n462, Q => output_fcs(30));
   U171 : IN4 port map( A => n464, Q => output_fcs(31));
   U172 : IN4 port map( A => n466, Q => output_fcs(15));
   U173 : IN4 port map( A => n468, Q => output_fcs(14));
   U174 : IN4 port map( A => n470, Q => output_fcs(13));
   U175 : IN4 port map( A => n472, Q => output_fcs(12));
   U176 : IN4 port map( A => n474, Q => output_fcs(11));
   output_fcs_reg_21 : DFA2 port map( C => phi1, D => input_fcs(10), Q => 
                           output_fcs(10), QN => n659, RN => n340);
   output_fcs_reg_0 : DFA2 port map( C => phi1, D => input_fcs(31), Q => n660, 
                           QN => n464, RN => n344);
   output_fcs_reg_1 : DFA2 port map( C => phi1, D => input_fcs(30), Q => n661, 
                           QN => n462, RN => n340);
   output_fcs_reg_2 : DFA2 port map( C => phi1, D => input_fcs(29), Q => n662, 
                           QN => n460, RN => n340);
   output_fcs_reg_7 : DFA2 port map( C => phi1, D => input_fcs(24), Q => n663, 
                           QN => n458, RN => n344);
   output_wip_reg_31 : DFA2 port map( C => phi1, D => input_wip(0), Q => 
                           output_wip(0), QN => n664, RN => n344);
   output_wip_reg_30 : DFA2 port map( C => phi1, D => input_wip(1), Q => 
                           output_wip(1), QN => n665, RN => n344);
   output_wip_reg_29 : DFA2 port map( C => phi1, D => input_wip(2), Q => 
                           output_wip(2), QN => n666, RN => n340);
   output_wip_reg_28 : DFA2 port map( C => phi1, D => input_wip(3), Q => 
                           output_wip(3), QN => n667, RN => n344);
   output_wip_reg_27 : DFA2 port map( C => phi1, D => input_wip(4), Q => 
                           output_wip(4), QN => n668, RN => n344);
   output_wip_reg_26 : DFA2 port map( C => phi1, D => input_wip(5), Q => 
                           output_wip(5), QN => n669, RN => n340);
   output_wip_reg_25 : DFA2 port map( C => phi1, D => input_wip(6), Q => 
                           output_wip(6), QN => n670, RN => n344);
   output_wip_reg_24 : DFA2 port map( C => phi1, D => input_wip(7), Q => 
                           output_wip(7), QN => n671, RN => n340);
   output_wip_reg_22 : DFA2 port map( C => phi1, D => input_wip(9), Q => 
                           output_wip(9), QN => n672, RN => n344);
   output_wip_reg_19 : DFA2 port map( C => phi1, D => input_wip(12), Q => 
                           output_wip(12), QN => n673, RN => n344);
   output_fcs_reg_15 : DFA2 port map( C => phi1, D => input_fcs(16), Q => 
                           output_fcs(16), QN => n674, RN => n344);
   output_fcs_reg_14 : DFA2 port map( C => phi1, D => input_fcs(17), Q => 
                           output_fcs(17), QN => n675, RN => n340);
   output_fcs_reg_13 : DFA2 port map( C => phi1, D => input_fcs(18), Q => 
                           output_fcs(18), QN => n676, RN => n340);
   output_fcs_reg_12 : DFA2 port map( C => phi1, D => input_fcs(19), Q => 
                           output_fcs(19), QN => n677, RN => n340);
   output_fcs_reg_11 : DFA2 port map( C => phi1, D => input_fcs(20), Q => 
                           output_fcs(20), QN => n678, RN => n344);
   output_fcs_reg_10 : DFA2 port map( C => phi1, D => input_fcs(21), Q => 
                           output_fcs(21), QN => n679, RN => n344);
   output_fcs_reg_9 : DFA2 port map( C => phi1, D => input_fcs(22), Q => 
                           output_fcs(22), QN => n680, RN => n344);
   output_fcs_reg_8 : DFA2 port map( C => phi1, D => input_fcs(23), Q => 
                           output_fcs(23), QN => n681, RN => n340);
   output_fcs_reg_6 : DFA2 port map( C => phi1, D => input_fcs(25), Q => 
                           output_fcs(25), QN => n682, RN => n340);
   output_fcs_reg_3 : DFA2 port map( C => phi1, D => input_fcs(28), Q => 
                           output_fcs(28), QN => n683, RN => n344);
   output_fcs_reg_17 : DFA2 port map( C => phi1, D => input_fcs(14), Q => n684,
                           QN => n468, RN => n344);
   output_fcs_reg_23 : DFA2 port map( C => phi1, D => input_fcs(8), Q => 
                           output_fcs(8), QN => n685, RN => n344);
   output_fcs_reg_16 : DFA2 port map( C => phi1, D => input_fcs(15), Q => n686,
                           QN => n466, RN => n344);
   output_fcs_reg_18 : DFA2 port map( C => phi1, D => input_fcs(13), Q => n687,
                           QN => n470, RN => n340);
   output_fcs_reg_19 : DFA2 port map( C => phi1, D => input_fcs(12), Q => n688,
                           QN => n472, RN => n340);
   output_fcs_reg_20 : DFA2 port map( C => phi1, D => input_fcs(11), Q => n689,
                           QN => n474, RN => n344);
   output_fcs_reg_22 : DFA2 port map( C => phi1, D => input_fcs(9), Q => 
                           output_fcs(9), QN => n690, RN => n344);

end SYN_behavior_3;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_phi2_register_0 is

   port( reset, phi2 : in std_logic;  input_wip, input_fcs : in 
         std_logic_vector (0 to 31);  output_wip, output_fcs : out 
         std_logic_vector (0 to 31));

end gf_phi2_register_0;

architecture SYN_behavior_0 of gf_phi2_register_0 is

   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component BU4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component BU2
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n190, n192, n194, n196, n200, n204, n208, n212, n216, n359, n360, 
      n361, n362, n363, n364, n365, n366, n367, n368, n369, n370, n371, n372, 
      n373, n374, n375, n376, n377, n378, n379, n380, n381, n382, n383, n384, 
      n385, n386, n387, n388, n389, n390, n391, n392, n393, n394, n395, n396, 
      n397, n398, n399, n400, n401, n402, n403, n404, n405, n406, n407, n408, 
      n409, n410, n411, n412, n413, n414, n415, n416, n417, n418, n419, n420, 
      n421, n422 : std_logic;

begin
   
   output_wip_reg_30 : DFA port map( C => phi2, D => input_wip(1), Q => 
                           output_wip(1), QN => n359, RN => n192);
   output_wip_reg_29 : DFA port map( C => phi2, D => input_wip(2), Q => 
                           output_wip(2), QN => n360, RN => n192);
   output_wip_reg_27 : DFA port map( C => phi2, D => input_wip(4), Q => 
                           output_wip(4), QN => n361, RN => n192);
   output_wip_reg_25 : DFA port map( C => phi2, D => input_wip(6), Q => 
                           output_wip(6), QN => n362, RN => n194);
   output_wip_reg_24 : DFA port map( C => phi2, D => input_wip(7), Q => 
                           output_wip(7), QN => n363, RN => n192);
   output_wip_reg_22 : DFA port map( C => phi2, D => input_wip(9), Q => 
                           output_wip(9), QN => n364, RN => n194);
   output_wip_reg_19 : DFA port map( C => phi2, D => input_wip(12), Q => 
                           output_wip(12), QN => n365, RN => n192);
   output_wip_reg_17 : DFA port map( C => phi2, D => input_wip(14), Q => 
                           output_wip(14), QN => n366, RN => n190);
   output_wip_reg_3 : DFA port map( C => phi2, D => input_wip(28), Q => 
                           output_wip(28), QN => n367, RN => n192);
   output_wip_reg_15 : DFA port map( C => phi2, D => input_wip(16), Q => 
                           output_wip(16), QN => n368, RN => n190);
   output_wip_reg_13 : DFA port map( C => phi2, D => input_wip(18), Q => 
                           output_wip(18), QN => n369, RN => n190);
   output_wip_reg_12 : DFA port map( C => phi2, D => input_wip(19), Q => 
                           output_wip(19), QN => n370, RN => n190);
   output_wip_reg_6 : DFA port map( C => phi2, D => input_wip(25), Q => 
                           output_wip(25), QN => n371, RN => n194);
   output_wip_reg_23 : DFA port map( C => phi2, D => input_wip(8), Q => 
                           output_wip(8), QN => n372, RN => n194);
   output_wip_reg_18 : DFA port map( C => phi2, D => input_wip(13), Q => 
                           output_wip(13), QN => n373, RN => n194);
   output_wip_reg_16 : DFA port map( C => phi2, D => input_wip(15), Q => 
                           output_wip(15), QN => n374, RN => n192);
   output_wip_reg_14 : DFA port map( C => phi2, D => input_wip(17), Q => 
                           output_wip(17), QN => n375, RN => n194);
   output_wip_reg_11 : DFA port map( C => phi2, D => input_wip(20), Q => 
                           output_wip(20), QN => n376, RN => n194);
   output_wip_reg_10 : DFA port map( C => phi2, D => input_wip(21), Q => 
                           output_wip(21), QN => n377, RN => n194);
   output_wip_reg_9 : DFA port map( C => phi2, D => input_wip(22), Q => 
                           output_wip(22), QN => n378, RN => n194);
   output_wip_reg_8 : DFA port map( C => phi2, D => input_wip(23), Q => 
                           output_wip(23), QN => n379, RN => n192);
   output_wip_reg_7 : DFA port map( C => phi2, D => input_wip(24), Q => 
                           output_wip(24), QN => n380, RN => n194);
   output_wip_reg_5 : DFA port map( C => phi2, D => input_wip(26), Q => 
                           output_wip(26), QN => n381, RN => n192);
   output_wip_reg_4 : DFA port map( C => phi2, D => input_wip(27), Q => 
                           output_wip(27), QN => n382, RN => n194);
   output_wip_reg_2 : DFA port map( C => phi2, D => input_wip(29), Q => 
                           output_wip(29), QN => n383, RN => n192);
   output_wip_reg_1 : DFA port map( C => phi2, D => input_wip(30), Q => 
                           output_wip(30), QN => n384, RN => n194);
   output_fcs_reg_31 : DFA2 port map( C => phi2, D => input_fcs(0), Q => 
                           output_fcs(0), QN => n385, RN => n192);
   output_fcs_reg_30 : DFA2 port map( C => phi2, D => input_fcs(1), Q => 
                           output_fcs(1), QN => n386, RN => n194);
   output_fcs_reg_29 : DFA2 port map( C => phi2, D => input_fcs(2), Q => 
                           output_fcs(2), QN => n387, RN => n194);
   output_fcs_reg_28 : DFA2 port map( C => phi2, D => input_fcs(3), Q => 
                           output_fcs(3), QN => n388, RN => n190);
   output_fcs_reg_27 : DFA2 port map( C => phi2, D => input_fcs(4), Q => 
                           output_fcs(4), QN => n389, RN => n194);
   output_fcs_reg_26 : DFA2 port map( C => phi2, D => input_fcs(5), Q => 
                           output_fcs(5), QN => n390, RN => n194);
   output_fcs_reg_7 : DFA port map( C => phi2, D => input_fcs(24), Q => 
                           output_fcs(24), QN => n391, RN => n194);
   output_fcs_reg_2 : DFA port map( C => phi2, D => input_fcs(29), Q => 
                           output_fcs(29), QN => n392, RN => n194);
   output_fcs_reg_1 : DFA port map( C => phi2, D => input_fcs(30), Q => 
                           output_fcs(30), QN => n393, RN => n194);
   output_fcs_reg_0 : DFA port map( C => phi2, D => input_fcs(31), Q => 
                           output_fcs(31), QN => n394, RN => n194);
   U147 : BU4 port map( A => n190, Q => n194);
   U148 : BU4 port map( A => n190, Q => n192);
   U149 : BU2 port map( A => reset, Q => n190);
   U150 : IN4 port map( A => n196, Q => output_fcs(13));
   U151 : IN4 port map( A => n200, Q => output_fcs(15));
   output_fcs_reg_24 : DFA port map( C => phi2, D => input_fcs(7), Q => 
                           output_fcs(7), QN => n395, RN => n192);
   output_wip_reg_0 : DFA port map( C => phi2, D => input_wip(31), Q => 
                           output_wip(31), QN => n396, RN => n194);
   output_fcs_reg_17 : DFA2 port map( C => phi2, D => input_fcs(14), Q => 
                           output_fcs(14), QN => n397, RN => n194);
   U152 : IN4 port map( A => n204, Q => output_fcs(12));
   U153 : IN4 port map( A => n208, Q => output_fcs(9));
   U154 : IN4 port map( A => n212, Q => output_fcs(11));
   U155 : IN4 port map( A => n216, Q => output_fcs(10));
   output_fcs_reg_25 : DFA2 port map( C => phi2, D => input_fcs(6), Q => 
                           output_fcs(6), QN => n398, RN => n190);
   output_wip_reg_21 : DFA port map( C => phi2, D => input_wip(10), Q => 
                           output_wip(10), QN => n399, RN => n194);
   output_wip_reg_20 : DFA port map( C => phi2, D => input_wip(11), Q => 
                           output_wip(11), QN => n400, RN => n192);
   output_fcs_reg_5 : DFA port map( C => phi2, D => input_fcs(26), Q => 
                           output_fcs(26), QN => n401, RN => n194);
   output_fcs_reg_4 : DFA port map( C => phi2, D => input_fcs(27), Q => 
                           output_fcs(27), QN => n402, RN => n192);
   output_wip_reg_31 : DFA2 port map( C => phi2, D => input_wip(0), Q => 
                           output_wip(0), QN => n403, RN => n190);
   output_wip_reg_28 : DFA2 port map( C => phi2, D => input_wip(3), Q => 
                           output_wip(3), QN => n404, RN => n194);
   output_wip_reg_26 : DFA2 port map( C => phi2, D => input_wip(5), Q => 
                           output_wip(5), QN => n405, RN => n194);
   output_fcs_reg_23 : DFA2 port map( C => phi2, D => input_fcs(8), Q => 
                           output_fcs(8), QN => n406, RN => n192);
   output_fcs_reg_3 : DFA2 port map( C => phi2, D => input_fcs(28), Q => 
                           output_fcs(28), QN => n407, RN => n194);
   output_fcs_reg_6 : DFA2 port map( C => phi2, D => input_fcs(25), Q => 
                           output_fcs(25), QN => n408, RN => n194);
   output_fcs_reg_8 : DFA2 port map( C => phi2, D => input_fcs(23), Q => 
                           output_fcs(23), QN => n409, RN => n192);
   output_fcs_reg_9 : DFA2 port map( C => phi2, D => input_fcs(22), Q => 
                           output_fcs(22), QN => n410, RN => n190);
   output_fcs_reg_10 : DFA2 port map( C => phi2, D => input_fcs(21), Q => 
                           output_fcs(21), QN => n411, RN => n192);
   output_fcs_reg_11 : DFA2 port map( C => phi2, D => input_fcs(20), Q => 
                           output_fcs(20), QN => n412, RN => n192);
   output_fcs_reg_12 : DFA2 port map( C => phi2, D => input_fcs(19), Q => 
                           output_fcs(19), QN => n413, RN => n192);
   output_fcs_reg_13 : DFA2 port map( C => phi2, D => input_fcs(18), Q => 
                           output_fcs(18), QN => n414, RN => n192);
   output_fcs_reg_14 : DFA2 port map( C => phi2, D => input_fcs(17), Q => 
                           output_fcs(17), QN => n415, RN => n192);
   output_fcs_reg_15 : DFA2 port map( C => phi2, D => input_fcs(16), Q => 
                           output_fcs(16), QN => n416, RN => n192);
   output_fcs_reg_16 : DFA2 port map( C => phi2, D => input_fcs(15), Q => n417,
                           QN => n200, RN => n192);
   output_fcs_reg_18 : DFA2 port map( C => phi2, D => input_fcs(13), Q => n418,
                           QN => n196, RN => n190);
   output_fcs_reg_19 : DFA2 port map( C => phi2, D => input_fcs(12), Q => n419,
                           QN => n204, RN => n192);
   output_fcs_reg_20 : DFA2 port map( C => phi2, D => input_fcs(11), Q => n420,
                           QN => n212, RN => n192);
   output_fcs_reg_22 : DFA2 port map( C => phi2, D => input_fcs(9), Q => n421, 
                           QN => n208, RN => n192);
   output_fcs_reg_21 : DFA2 port map( C => phi2, D => input_fcs(10), Q => n422,
                           QN => n216, RN => n192);

end SYN_behavior_0;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_phi2_register_1 is

   port( reset, phi2 : in std_logic;  input_wip, input_fcs : in 
         std_logic_vector (0 to 31);  output_wip, output_fcs : out 
         std_logic_vector (0 to 31));

end gf_phi2_register_1;

architecture SYN_behavior_1 of gf_phi2_register_1 is

   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component BU4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component BU2
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   signal n198, n202, n206, n210, n218, n234, n238, n242, n246, n250, n395, 
      n396, n397, n398, n399, n400, n401, n402, n403, n404, n405, n406, n407, 
      n408, n409, n410, n411, n412, n413, n414, n415, n416, n417, n418, n419, 
      n420, n421, n422, n423, n424, n425, n426, n427, n428, n429, n430, n431, 
      n432, n433, n434, n435, n436, n437, n438, n439, n440, n441, n442, n443, 
      n444, n445, n446, n447, n448, n449, n450, n451, n452, n453, n454, n455, 
      n456, n457, n458 : std_logic;

begin
   
   output_fcs_reg_27 : DFA port map( C => phi2, D => input_fcs(4), Q => 
                           output_fcs(4), QN => n395, RN => n202);
   output_wip_reg_24 : DFA port map( C => phi2, D => input_wip(7), Q => 
                           output_wip(7), QN => n396, RN => n202);
   output_wip_reg_29 : DFA port map( C => phi2, D => input_wip(2), Q => 
                           output_wip(2), QN => n397, RN => n202);
   output_wip_reg_28 : DFA port map( C => phi2, D => input_wip(3), Q => 
                           output_wip(3), QN => n398, RN => n202);
   output_wip_reg_22 : DFA port map( C => phi2, D => input_wip(9), Q => 
                           output_wip(9), QN => n399, RN => n202);
   output_wip_reg_18 : DFA port map( C => phi2, D => input_wip(13), Q => 
                           output_wip(13), QN => n400, RN => n202);
   output_wip_reg_14 : DFA port map( C => phi2, D => input_wip(17), Q => 
                           output_wip(17), QN => n401, RN => n202);
   output_wip_reg_12 : DFA port map( C => phi2, D => input_wip(19), Q => 
                           output_wip(19), QN => n402, RN => n202);
   output_wip_reg_9 : DFA port map( C => phi2, D => input_wip(22), Q => 
                           output_wip(22), QN => n403, RN => n202);
   output_wip_reg_7 : DFA port map( C => phi2, D => input_wip(24), Q => 
                           output_wip(24), QN => n404, RN => n202);
   output_wip_reg_5 : DFA port map( C => phi2, D => input_wip(26), Q => 
                           output_wip(26), QN => n405, RN => n206);
   output_wip_reg_4 : DFA port map( C => phi2, D => input_wip(27), Q => 
                           output_wip(27), QN => n406, RN => n202);
   output_wip_reg_3 : DFA port map( C => phi2, D => input_wip(28), Q => 
                           output_wip(28), QN => n407, RN => n206);
   output_wip_reg_1 : DFA port map( C => phi2, D => input_wip(30), Q => 
                           output_wip(30), QN => n408, RN => n202);
   output_wip_reg_0 : DFA port map( C => phi2, D => input_wip(31), Q => 
                           output_wip(31), QN => n409, RN => n206);
   output_wip_reg_27 : DFA port map( C => phi2, D => input_wip(4), Q => 
                           output_wip(4), QN => n410, RN => n206);
   output_wip_reg_26 : DFA port map( C => phi2, D => input_wip(5), Q => 
                           output_wip(5), QN => n411, RN => n202);
   output_wip_reg_25 : DFA port map( C => phi2, D => input_wip(6), Q => 
                           output_wip(6), QN => n412, RN => n206);
   output_wip_reg_20 : DFA port map( C => phi2, D => input_wip(11), Q => 
                           output_wip(11), QN => n413, RN => n202);
   output_fcs_reg_31 : DFA port map( C => phi2, D => input_fcs(0), Q => 
                           output_fcs(0), QN => n414, RN => n202);
   output_fcs_reg_17 : DFA port map( C => phi2, D => input_fcs(14), Q => 
                           output_fcs(14), QN => n415, RN => n202);
   output_fcs_reg_16 : DFA port map( C => phi2, D => input_fcs(15), Q => 
                           output_fcs(15), QN => n416, RN => n202);
   output_fcs_reg_15 : DFA port map( C => phi2, D => input_fcs(16), Q => 
                           output_fcs(16), QN => n417, RN => n202);
   output_fcs_reg_14 : DFA port map( C => phi2, D => input_fcs(17), Q => 
                           output_fcs(17), QN => n418, RN => n198);
   output_fcs_reg_13 : DFA port map( C => phi2, D => input_fcs(18), Q => 
                           output_fcs(18), QN => n419, RN => n206);
   output_fcs_reg_12 : DFA port map( C => phi2, D => input_fcs(19), Q => 
                           output_fcs(19), QN => n420, RN => n206);
   output_fcs_reg_11 : DFA port map( C => phi2, D => input_fcs(20), Q => 
                           output_fcs(20), QN => n421, RN => n206);
   output_fcs_reg_10 : DFA port map( C => phi2, D => input_fcs(21), Q => 
                           output_fcs(21), QN => n422, RN => n206);
   output_fcs_reg_9 : DFA port map( C => phi2, D => input_fcs(22), Q => 
                           output_fcs(22), QN => n423, RN => n206);
   output_fcs_reg_8 : DFA port map( C => phi2, D => input_fcs(23), Q => 
                           output_fcs(23), QN => n424, RN => n206);
   output_fcs_reg_7 : DFA port map( C => phi2, D => input_fcs(24), Q => 
                           output_fcs(24), QN => n425, RN => n206);
   output_fcs_reg_6 : DFA port map( C => phi2, D => input_fcs(25), Q => 
                           output_fcs(25), QN => n426, RN => n198);
   output_fcs_reg_5 : DFA port map( C => phi2, D => input_fcs(26), Q => 
                           output_fcs(26), QN => n427, RN => n206);
   output_fcs_reg_4 : DFA port map( C => phi2, D => input_fcs(27), Q => 
                           output_fcs(27), QN => n428, RN => n206);
   output_fcs_reg_3 : DFA port map( C => phi2, D => input_fcs(28), Q => 
                           output_fcs(28), QN => n429, RN => n206);
   output_fcs_reg_2 : DFA port map( C => phi2, D => input_fcs(29), Q => 
                           output_fcs(29), QN => n430, RN => n198);
   output_fcs_reg_1 : DFA port map( C => phi2, D => input_fcs(30), Q => 
                           output_fcs(30), QN => n431, RN => n206);
   output_fcs_reg_0 : DFA port map( C => phi2, D => input_fcs(31), Q => 
                           output_fcs(31), QN => n432, RN => n206);
   U147 : BU4 port map( A => n198, Q => n206);
   U148 : BU4 port map( A => n198, Q => n202);
   output_wip_reg_15 : DFA port map( C => phi2, D => input_wip(16), Q => 
                           output_wip(16), QN => n433, RN => n198);
   output_wip_reg_10 : DFA port map( C => phi2, D => input_wip(21), Q => 
                           output_wip(21), QN => n434, RN => n198);
   output_wip_reg_2 : DFA port map( C => phi2, D => input_wip(29), Q => 
                           output_wip(29), QN => n435, RN => n198);
   output_wip_reg_21 : DFA port map( C => phi2, D => input_wip(10), Q => 
                           output_wip(10), QN => n436, RN => n198);
   output_wip_reg_31 : DFA port map( C => phi2, D => input_wip(0), Q => 
                           output_wip(0), QN => n437, RN => n198);
   output_fcs_reg_30 : DFA port map( C => phi2, D => input_fcs(1), Q => 
                           output_fcs(1), QN => n438, RN => n206);
   U149 : BU2 port map( A => reset, Q => n198);
   U150 : IN4 port map( A => n210, Q => output_fcs(11));
   U151 : IN4 port map( A => n218, Q => output_fcs(12));
   output_fcs_reg_28 : DFA port map( C => phi2, D => input_fcs(3), Q => 
                           output_fcs(3), QN => n439, RN => n206);
   output_fcs_reg_26 : DFA port map( C => phi2, D => input_fcs(5), Q => 
                           output_fcs(5), QN => n440, RN => n202);
   U152 : IN4 port map( A => n242, Q => output_fcs(8));
   U153 : IN4 port map( A => n246, Q => output_fcs(7));
   U154 : IN4 port map( A => n250, Q => output_fcs(6));
   U155 : IN4 port map( A => n234, Q => output_fcs(10));
   U156 : IN4 port map( A => n238, Q => output_fcs(9));
   output_fcs_reg_29 : DFA2 port map( C => phi2, D => input_fcs(2), Q => 
                           output_fcs(2), QN => n441, RN => n202);
   output_fcs_reg_18 : DFA2 port map( C => phi2, D => input_fcs(13), Q => 
                           output_fcs(13), QN => n442, RN => n202);
   output_wip_reg_30 : DFA2 port map( C => phi2, D => input_wip(1), Q => 
                           output_wip(1), QN => n443, RN => n206);
   output_wip_reg_23 : DFA2 port map( C => phi2, D => input_wip(8), Q => 
                           output_wip(8), QN => n444, RN => n206);
   output_wip_reg_19 : DFA2 port map( C => phi2, D => input_wip(12), Q => 
                           output_wip(12), QN => n445, RN => n206);
   output_wip_reg_17 : DFA2 port map( C => phi2, D => input_wip(14), Q => 
                           output_wip(14), QN => n446, RN => n206);
   output_wip_reg_16 : DFA2 port map( C => phi2, D => input_wip(15), Q => 
                           output_wip(15), QN => n447, RN => n206);
   output_wip_reg_13 : DFA2 port map( C => phi2, D => input_wip(18), Q => 
                           output_wip(18), QN => n448, RN => n206);
   output_wip_reg_11 : DFA2 port map( C => phi2, D => input_wip(20), Q => 
                           output_wip(20), QN => n449, RN => n206);
   output_wip_reg_8 : DFA2 port map( C => phi2, D => input_wip(23), Q => 
                           output_wip(23), QN => n450, RN => n206);
   output_wip_reg_6 : DFA2 port map( C => phi2, D => input_wip(25), Q => 
                           output_wip(25), QN => n451, RN => n206);
   output_fcs_reg_19 : DFA2 port map( C => phi2, D => input_fcs(12), Q => n452,
                           QN => n218, RN => n202);
   output_fcs_reg_20 : DFA2 port map( C => phi2, D => input_fcs(11), Q => n453,
                           QN => n210, RN => n202);
   output_fcs_reg_21 : DFA2 port map( C => phi2, D => input_fcs(10), Q => n454,
                           QN => n234, RN => n202);
   output_fcs_reg_22 : DFA2 port map( C => phi2, D => input_fcs(9), Q => n455, 
                           QN => n238, RN => n198);
   output_fcs_reg_23 : DFA2 port map( C => phi2, D => input_fcs(8), Q => n456, 
                           QN => n242, RN => n202);
   output_fcs_reg_24 : DFA2 port map( C => phi2, D => input_fcs(7), Q => n457, 
                           QN => n246, RN => n202);
   output_fcs_reg_25 : DFA2 port map( C => phi2, D => input_fcs(6), Q => n458, 
                           QN => n250, RN => n202);

end SYN_behavior_1;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_phi2_register_2 is

   port( reset, phi2 : in std_logic;  input_wip, input_fcs : in 
         std_logic_vector (0 to 31);  output_wip, output_fcs : out 
         std_logic_vector (0 to 31));

end gf_phi2_register_2;

architecture SYN_behavior_2 of gf_phi2_register_2 is

   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component BU8
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component BU4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n240, n248, n377, n378, n379, n380, n381, n382, n383, n384, n385, 
      n386, n387, n388, n389, n390, n391, n392, n393, n394, n395, n396, n397, 
      n398, n399, n400, n401, n402, n403, n404, n405, n406, n407, n408, n409, 
      n410, n411, n412, n413, n414, n415, n416, n417, n418, n419, n420, n421, 
      n422, n423, n424, n425, n426, n427, n428, n429, n430, n431, n432, n433, 
      n434, n435, n436, n437, n438, n439, n440 : std_logic;

begin
   
   output_fcs_reg_16 : DFA port map( C => phi2, D => input_fcs(15), Q => 
                           output_fcs(15), QN => n377, RN => n240);
   output_wip_reg_12 : DFA port map( C => phi2, D => input_wip(19), Q => 
                           output_wip(19), QN => n378, RN => n248);
   output_fcs_reg_31 : DFA2 port map( C => phi2, D => input_fcs(0), Q => 
                           output_fcs(0), QN => n379, RN => n248);
   output_fcs_reg_30 : DFA2 port map( C => phi2, D => input_fcs(1), Q => 
                           output_fcs(1), QN => n380, RN => n248);
   output_fcs_reg_29 : DFA2 port map( C => phi2, D => input_fcs(2), Q => 
                           output_fcs(2), QN => n381, RN => n240);
   output_fcs_reg_28 : DFA2 port map( C => phi2, D => input_fcs(3), Q => 
                           output_fcs(3), QN => n382, RN => n240);
   output_fcs_reg_27 : DFA2 port map( C => phi2, D => input_fcs(4), Q => 
                           output_fcs(4), QN => n383, RN => n240);
   output_fcs_reg_26 : DFA2 port map( C => phi2, D => input_fcs(5), Q => 
                           output_fcs(5), QN => n384, RN => n248);
   output_fcs_reg_25 : DFA2 port map( C => phi2, D => input_fcs(6), Q => 
                           output_fcs(6), QN => n385, RN => n240);
   output_fcs_reg_24 : DFA2 port map( C => phi2, D => input_fcs(7), Q => 
                           output_fcs(7), QN => n386, RN => n240);
   output_fcs_reg_23 : DFA2 port map( C => phi2, D => input_fcs(8), Q => 
                           output_fcs(8), QN => n387, RN => n248);
   output_fcs_reg_22 : DFA2 port map( C => phi2, D => input_fcs(9), Q => 
                           output_fcs(9), QN => n388, RN => n248);
   output_fcs_reg_21 : DFA2 port map( C => phi2, D => input_fcs(10), Q => 
                           output_fcs(10), QN => n389, RN => n248);
   output_fcs_reg_20 : DFA2 port map( C => phi2, D => input_fcs(11), Q => 
                           output_fcs(11), QN => n390, RN => n240);
   output_fcs_reg_15 : DFA2 port map( C => phi2, D => input_fcs(16), Q => 
                           output_fcs(16), QN => n391, RN => n240);
   output_fcs_reg_14 : DFA2 port map( C => phi2, D => input_fcs(17), Q => 
                           output_fcs(17), QN => n392, RN => n248);
   output_fcs_reg_13 : DFA2 port map( C => phi2, D => input_fcs(18), Q => 
                           output_fcs(18), QN => n393, RN => n248);
   output_fcs_reg_12 : DFA2 port map( C => phi2, D => input_fcs(19), Q => 
                           output_fcs(19), QN => n394, RN => n240);
   output_fcs_reg_11 : DFA2 port map( C => phi2, D => input_fcs(20), Q => 
                           output_fcs(20), QN => n395, RN => n248);
   output_fcs_reg_10 : DFA2 port map( C => phi2, D => input_fcs(21), Q => 
                           output_fcs(21), QN => n396, RN => n248);
   output_fcs_reg_9 : DFA2 port map( C => phi2, D => input_fcs(22), Q => 
                           output_fcs(22), QN => n397, RN => n248);
   output_fcs_reg_8 : DFA2 port map( C => phi2, D => input_fcs(23), Q => 
                           output_fcs(23), QN => n398, RN => n240);
   output_fcs_reg_7 : DFA2 port map( C => phi2, D => input_fcs(24), Q => 
                           output_fcs(24), QN => n399, RN => n240);
   output_fcs_reg_6 : DFA2 port map( C => phi2, D => input_fcs(25), Q => 
                           output_fcs(25), QN => n400, RN => n248);
   output_fcs_reg_5 : DFA2 port map( C => phi2, D => input_fcs(26), Q => 
                           output_fcs(26), QN => n401, RN => n240);
   output_fcs_reg_4 : DFA2 port map( C => phi2, D => input_fcs(27), Q => 
                           output_fcs(27), QN => n402, RN => n240);
   output_fcs_reg_3 : DFA2 port map( C => phi2, D => input_fcs(28), Q => 
                           output_fcs(28), QN => n403, RN => n240);
   output_fcs_reg_2 : DFA2 port map( C => phi2, D => input_fcs(29), Q => 
                           output_fcs(29), QN => n404, RN => n248);
   output_fcs_reg_1 : DFA2 port map( C => phi2, D => input_fcs(30), Q => 
                           output_fcs(30), QN => n405, RN => n248);
   output_fcs_reg_0 : DFA2 port map( C => phi2, D => input_fcs(31), Q => 
                           output_fcs(31), QN => n406, RN => n248);
   output_wip_reg_31 : DFA port map( C => phi2, D => input_wip(0), Q => 
                           output_wip(0), QN => n407, RN => n240);
   output_wip_reg_30 : DFA port map( C => phi2, D => input_wip(1), Q => 
                           output_wip(1), QN => n408, RN => n240);
   output_wip_reg_29 : DFA port map( C => phi2, D => input_wip(2), Q => 
                           output_wip(2), QN => n409, RN => n240);
   output_wip_reg_28 : DFA port map( C => phi2, D => input_wip(3), Q => 
                           output_wip(3), QN => n410, RN => n240);
   output_wip_reg_27 : DFA port map( C => phi2, D => input_wip(4), Q => 
                           output_wip(4), QN => n411, RN => n240);
   output_wip_reg_26 : DFA port map( C => phi2, D => input_wip(5), Q => 
                           output_wip(5), QN => n412, RN => n240);
   output_wip_reg_25 : DFA port map( C => phi2, D => input_wip(6), Q => 
                           output_wip(6), QN => n413, RN => n240);
   output_wip_reg_24 : DFA port map( C => phi2, D => input_wip(7), Q => 
                           output_wip(7), QN => n414, RN => n240);
   output_wip_reg_23 : DFA port map( C => phi2, D => input_wip(8), Q => 
                           output_wip(8), QN => n415, RN => n240);
   output_wip_reg_22 : DFA port map( C => phi2, D => input_wip(9), Q => 
                           output_wip(9), QN => n416, RN => n240);
   output_wip_reg_21 : DFA port map( C => phi2, D => input_wip(10), Q => 
                           output_wip(10), QN => n417, RN => n240);
   output_wip_reg_20 : DFA port map( C => phi2, D => input_wip(11), Q => 
                           output_wip(11), QN => n418, RN => n240);
   output_wip_reg_19 : DFA port map( C => phi2, D => input_wip(12), Q => 
                           output_wip(12), QN => n419, RN => n240);
   output_wip_reg_18 : DFA port map( C => phi2, D => input_wip(13), Q => 
                           output_wip(13), QN => n420, RN => n240);
   output_wip_reg_17 : DFA port map( C => phi2, D => input_wip(14), Q => 
                           output_wip(14), QN => n421, RN => n240);
   output_wip_reg_16 : DFA port map( C => phi2, D => input_wip(15), Q => 
                           output_wip(15), QN => n422, RN => n240);
   output_wip_reg_15 : DFA port map( C => phi2, D => input_wip(16), Q => 
                           output_wip(16), QN => n423, RN => n240);
   output_wip_reg_11 : DFA port map( C => phi2, D => input_wip(20), Q => 
                           output_wip(20), QN => n424, RN => n240);
   output_wip_reg_10 : DFA port map( C => phi2, D => input_wip(21), Q => 
                           output_wip(21), QN => n425, RN => n240);
   output_wip_reg_9 : DFA port map( C => phi2, D => input_wip(22), Q => 
                           output_wip(22), QN => n426, RN => n240);
   output_wip_reg_8 : DFA port map( C => phi2, D => input_wip(23), Q => 
                           output_wip(23), QN => n427, RN => n240);
   output_wip_reg_7 : DFA port map( C => phi2, D => input_wip(24), Q => 
                           output_wip(24), QN => n428, RN => n240);
   output_wip_reg_1 : DFA port map( C => phi2, D => input_wip(30), Q => 
                           output_wip(30), QN => n429, RN => n240);
   output_wip_reg_0 : DFA port map( C => phi2, D => input_wip(31), Q => 
                           output_wip(31), QN => n430, RN => n240);
   U147 : BU8 port map( A => reset, Q => n240);
   U148 : BU4 port map( A => n240, Q => n248);
   output_wip_reg_4 : DFA port map( C => phi2, D => input_wip(27), Q => 
                           output_wip(27), QN => n431, RN => n240);
   output_wip_reg_2 : DFA port map( C => phi2, D => input_wip(29), Q => 
                           output_wip(29), QN => n432, RN => n240);
   output_wip_reg_5 : DFA port map( C => phi2, D => input_wip(26), Q => 
                           output_wip(26), QN => n433, RN => n240);
   output_wip_reg_14 : DFA port map( C => phi2, D => input_wip(17), Q => 
                           output_wip(17), QN => n434, RN => n240);
   output_wip_reg_13 : DFA port map( C => phi2, D => input_wip(18), Q => 
                           output_wip(18), QN => n435, RN => n240);
   output_wip_reg_3 : DFA port map( C => phi2, D => input_wip(28), Q => 
                           output_wip(28), QN => n436, RN => n240);
   output_wip_reg_6 : DFA port map( C => phi2, D => input_wip(25), Q => 
                           output_wip(25), QN => n437, RN => n240);
   output_fcs_reg_18 : DFA2 port map( C => phi2, D => input_fcs(13), Q => 
                           output_fcs(13), QN => n438, RN => n240);
   output_fcs_reg_19 : DFA2 port map( C => phi2, D => input_fcs(12), Q => 
                           output_fcs(12), QN => n439, RN => n248);
   output_fcs_reg_17 : DFA2 port map( C => phi2, D => input_fcs(14), Q => 
                           output_fcs(14), QN => n440, RN => n240);

end SYN_behavior_2;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_phi2_register_3 is

   port( reset, phi2 : in std_logic;  input_wip, input_fcs : in 
         std_logic_vector (0 to 31);  output_wip, output_fcs : out 
         std_logic_vector (0 to 31));

end gf_phi2_register_3;

architecture SYN_behavior_3 of gf_phi2_register_3 is

   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component BU4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component BU2
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   signal n268, n272, n314, n316, n320, n324, n328, n467, n468, n469, n470, 
      n471, n472, n473, n474, n475, n476, n477, n478, n479, n480, n481, n482, 
      n483, n484, n485, n486, n487, n488, n489, n490, n491, n492, n493, n494, 
      n495, n496, n497, n498, n499, n500, n501, n502, n503, n504, n505, n506, 
      n507, n508, n509, n510, n511, n512, n513, n514, n515, n516, n517, n518, 
      n519, n520, n521, n522, n523, n524, n525, n526, n527, n528, n529, n530 : 
      std_logic;

begin
   
   output_wip_reg_13 : DFA port map( C => phi2, D => input_wip(18), Q => 
                           output_wip(18), QN => n467, RN => n314);
   output_wip_reg_12 : DFA port map( C => phi2, D => input_wip(19), Q => 
                           output_wip(19), QN => n468, RN => n314);
   output_wip_reg_11 : DFA port map( C => phi2, D => input_wip(20), Q => 
                           output_wip(20), QN => n469, RN => n268);
   output_wip_reg_8 : DFA port map( C => phi2, D => input_wip(23), Q => 
                           output_wip(23), QN => n470, RN => n268);
   output_wip_reg_7 : DFA port map( C => phi2, D => input_wip(24), Q => 
                           output_wip(24), QN => n471, RN => n268);
   output_wip_reg_6 : DFA port map( C => phi2, D => input_wip(25), Q => 
                           output_wip(25), QN => n472, RN => n314);
   output_wip_reg_4 : DFA port map( C => phi2, D => input_wip(27), Q => 
                           output_wip(27), QN => n473, RN => n314);
   output_wip_reg_3 : DFA port map( C => phi2, D => input_wip(28), Q => 
                           output_wip(28), QN => n474, RN => n272);
   output_wip_reg_1 : DFA port map( C => phi2, D => input_wip(30), Q => 
                           output_wip(30), QN => n475, RN => n268);
   output_wip_reg_15 : DFA port map( C => phi2, D => input_wip(16), Q => 
                           output_wip(16), QN => n476, RN => n314);
   output_wip_reg_14 : DFA port map( C => phi2, D => input_wip(17), Q => 
                           output_wip(17), QN => n477, RN => n314);
   output_wip_reg_9 : DFA port map( C => phi2, D => input_wip(22), Q => 
                           output_wip(22), QN => n478, RN => n268);
   output_wip_reg_5 : DFA port map( C => phi2, D => input_wip(26), Q => 
                           output_wip(26), QN => n479, RN => n314);
   output_wip_reg_2 : DFA port map( C => phi2, D => input_wip(29), Q => 
                           output_wip(29), QN => n480, RN => n314);
   output_fcs_reg_31 : DFA2 port map( C => phi2, D => input_fcs(0), Q => 
                           output_fcs(0), QN => n481, RN => n314);
   output_fcs_reg_30 : DFA2 port map( C => phi2, D => input_fcs(1), Q => 
                           output_fcs(1), QN => n482, RN => n272);
   output_fcs_reg_29 : DFA2 port map( C => phi2, D => input_fcs(2), Q => 
                           output_fcs(2), QN => n483, RN => n314);
   output_fcs_reg_28 : DFA2 port map( C => phi2, D => input_fcs(3), Q => 
                           output_fcs(3), QN => n484, RN => n268);
   output_fcs_reg_27 : DFA2 port map( C => phi2, D => input_fcs(4), Q => 
                           output_fcs(4), QN => n485, RN => n272);
   output_fcs_reg_26 : DFA2 port map( C => phi2, D => input_fcs(5), Q => 
                           output_fcs(5), QN => n486, RN => n314);
   output_fcs_reg_25 : DFA2 port map( C => phi2, D => input_fcs(6), Q => 
                           output_fcs(6), QN => n487, RN => n272);
   output_fcs_reg_24 : DFA2 port map( C => phi2, D => input_fcs(7), Q => 
                           output_fcs(7), QN => n488, RN => n314);
   output_fcs_reg_23 : DFA2 port map( C => phi2, D => input_fcs(8), Q => 
                           output_fcs(8), QN => n489, RN => n272);
   output_fcs_reg_15 : DFA2 port map( C => phi2, D => input_fcs(16), Q => 
                           output_fcs(16), QN => n490, RN => n314);
   output_fcs_reg_14 : DFA2 port map( C => phi2, D => input_fcs(17), Q => 
                           output_fcs(17), QN => n491, RN => n272);
   output_fcs_reg_13 : DFA2 port map( C => phi2, D => input_fcs(18), Q => 
                           output_fcs(18), QN => n492, RN => n268);
   output_fcs_reg_12 : DFA2 port map( C => phi2, D => input_fcs(19), Q => 
                           output_fcs(19), QN => n493, RN => n314);
   output_fcs_reg_11 : DFA2 port map( C => phi2, D => input_fcs(20), Q => 
                           output_fcs(20), QN => n494, RN => n272);
   output_fcs_reg_10 : DFA2 port map( C => phi2, D => input_fcs(21), Q => 
                           output_fcs(21), QN => n495, RN => n314);
   output_fcs_reg_9 : DFA2 port map( C => phi2, D => input_fcs(22), Q => 
                           output_fcs(22), QN => n496, RN => n314);
   output_fcs_reg_8 : DFA2 port map( C => phi2, D => input_fcs(23), Q => 
                           output_fcs(23), QN => n497, RN => n272);
   output_fcs_reg_6 : DFA2 port map( C => phi2, D => input_fcs(25), Q => 
                           output_fcs(25), QN => n498, RN => n272);
   output_fcs_reg_5 : DFA2 port map( C => phi2, D => input_fcs(26), Q => 
                           output_fcs(26), QN => n499, RN => n272);
   output_fcs_reg_4 : DFA2 port map( C => phi2, D => input_fcs(27), Q => 
                           output_fcs(27), QN => n500, RN => n268);
   output_fcs_reg_3 : DFA2 port map( C => phi2, D => input_fcs(28), Q => 
                           output_fcs(28), QN => n501, RN => n272);
   output_wip_reg_31 : DFA2 port map( C => phi2, D => input_wip(0), Q => 
                           output_wip(0), QN => n502, RN => n272);
   output_wip_reg_30 : DFA2 port map( C => phi2, D => input_wip(1), Q => 
                           output_wip(1), QN => n503, RN => n272);
   output_wip_reg_29 : DFA2 port map( C => phi2, D => input_wip(2), Q => 
                           output_wip(2), QN => n504, RN => n272);
   output_wip_reg_28 : DFA2 port map( C => phi2, D => input_wip(3), Q => 
                           output_wip(3), QN => n505, RN => n272);
   output_wip_reg_27 : DFA2 port map( C => phi2, D => input_wip(4), Q => 
                           output_wip(4), QN => n506, RN => n272);
   output_wip_reg_26 : DFA2 port map( C => phi2, D => input_wip(5), Q => 
                           output_wip(5), QN => n507, RN => n272);
   output_wip_reg_25 : DFA2 port map( C => phi2, D => input_wip(6), Q => 
                           output_wip(6), QN => n508, RN => n272);
   output_wip_reg_24 : DFA2 port map( C => phi2, D => input_wip(7), Q => 
                           output_wip(7), QN => n509, RN => n272);
   output_wip_reg_22 : DFA2 port map( C => phi2, D => input_wip(9), Q => 
                           output_wip(9), QN => n510, RN => n272);
   output_wip_reg_21 : DFA2 port map( C => phi2, D => input_wip(10), Q => 
                           output_wip(10), QN => n511, RN => n314);
   output_wip_reg_20 : DFA2 port map( C => phi2, D => input_wip(11), Q => 
                           output_wip(11), QN => n512, RN => n314);
   output_wip_reg_19 : DFA2 port map( C => phi2, D => input_wip(12), Q => 
                           output_wip(12), QN => n513, RN => n314);
   output_wip_reg_0 : DFA2 port map( C => phi2, D => input_wip(31), Q => 
                           output_wip(31), QN => n514, RN => n314);
   U147 : BU4 port map( A => n268, Q => n314);
   U148 : BU4 port map( A => n268, Q => n272);
   U149 : BU2 port map( A => reset, Q => n268);
   U150 : IN4 port map( A => n316, Q => output_fcs(12));
   output_wip_reg_10 : DFA port map( C => phi2, D => input_wip(21), Q => 
                           output_wip(21), QN => n515, RN => n272);
   output_fcs_reg_20 : DFA port map( C => phi2, D => input_fcs(11), Q => 
                           output_fcs(11), QN => n516, RN => n314);
   U151 : IN4 port map( A => n320, Q => output_fcs(14));
   U152 : IN4 port map( A => n324, Q => output_fcs(15));
   output_fcs_reg_21 : DFA2 port map( C => phi2, D => input_fcs(10), Q => 
                           output_fcs(10), QN => n517, RN => n314);
   U153 : IN4 port map( A => n328, Q => output_fcs(13));
   output_wip_reg_23 : DFA port map( C => phi2, D => input_wip(8), Q => 
                           output_wip(8), QN => n518, RN => n272);
   output_wip_reg_18 : DFA port map( C => phi2, D => input_wip(13), Q => 
                           output_wip(13), QN => n519, RN => n314);
   output_wip_reg_17 : DFA port map( C => phi2, D => input_wip(14), Q => 
                           output_wip(14), QN => n520, RN => n272);
   output_wip_reg_16 : DFA port map( C => phi2, D => input_wip(15), Q => 
                           output_wip(15), QN => n521, RN => n314);
   output_fcs_reg_7 : DFA port map( C => phi2, D => input_fcs(24), Q => 
                           output_fcs(24), QN => n522, RN => n314);
   output_fcs_reg_2 : DFA port map( C => phi2, D => input_fcs(29), Q => 
                           output_fcs(29), QN => n523, RN => n314);
   output_fcs_reg_1 : DFA port map( C => phi2, D => input_fcs(30), Q => 
                           output_fcs(30), QN => n524, RN => n272);
   output_fcs_reg_0 : DFA port map( C => phi2, D => input_fcs(31), Q => 
                           output_fcs(31), QN => n525, RN => n272);
   output_fcs_reg_22 : DFA2 port map( C => phi2, D => input_fcs(9), Q => 
                           output_fcs(9), QN => n526, RN => n314);
   output_fcs_reg_19 : DFA2 port map( C => phi2, D => input_fcs(12), Q => n527,
                           QN => n316, RN => n272);
   output_fcs_reg_17 : DFA2 port map( C => phi2, D => input_fcs(14), Q => n528,
                           QN => n320, RN => n314);
   output_fcs_reg_16 : DFA2 port map( C => phi2, D => input_fcs(15), Q => n529,
                           QN => n324, RN => n272);
   output_fcs_reg_18 : DFA2 port map( C => phi2, D => input_fcs(13), Q => n530,
                           QN => n328, RN => n268);

end SYN_behavior_3;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity gf_multiplier is

   port( reset, phi1, phi2 : in std_logic;  input : in std_logic_vector (0 to 
         31);  output_fcs, output_xor : out std_logic_vector (0 to 15));

end gf_multiplier;

architecture SYN_structural_architecture2 of gf_multiplier is

   component gf_xor_input
      port( input_fcs : in std_logic_vector (0 to 31);  output_wip : out 
            std_logic_vector (0 to 31));
   end component;
   
   component gf_xor_2x
      port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip :
            out std_logic_vector (0 to 31));
   end component;
   
   component gf_xor_3x
      port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip :
            out std_logic_vector (0 to 31));
   end component;
   
   component gf_xor_4x
      port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip :
            out std_logic_vector (0 to 31));
   end component;
   
   component gf_xor_5x
      port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip :
            out std_logic_vector (0 to 31));
   end component;
   
   component gf_xor_6x
      port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip :
            out std_logic_vector (0 to 31));
   end component;
   
   component gf_xor_7x
      port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip :
            out std_logic_vector (0 to 31));
   end component;
   
   component gf_xor_8x
      port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip :
            out std_logic_vector (0 to 31));
   end component;
   
   component gf_xor_9x
      port( input_wip, input_fcs : in std_logic_vector (0 to 31);  output_wip :
            out std_logic_vector (0 to 31));
   end component;
   
   component gf_phi1_register_out
      port( reset, phi1 : in std_logic;  input_wip : in std_logic_vector (0 to 
            31);  output_final : out std_logic_vector (0 to 31));
   end component;
   
   component gf_phi1_register_0
      port( reset, phi1 : in std_logic;  input_wip, input_fcs : in 
            std_logic_vector (0 to 31);  output_wip, output_fcs : out 
            std_logic_vector (0 to 31));
   end component;
   
   component gf_phi1_register_1
      port( reset, phi1 : in std_logic;  input_wip, input_fcs : in 
            std_logic_vector (0 to 31);  output_wip, output_fcs : out 
            std_logic_vector (0 to 31));
   end component;
   
   component gf_phi1_register_2
      port( reset, phi1 : in std_logic;  input_wip, input_fcs : in 
            std_logic_vector (0 to 31);  output_wip, output_fcs : out 
            std_logic_vector (0 to 31));
   end component;
   
   component gf_phi1_register_3
      port( reset, phi1 : in std_logic;  input_wip, input_fcs : in 
            std_logic_vector (0 to 31);  output_wip, output_fcs : out 
            std_logic_vector (0 to 31));
   end component;
   
   component gf_phi2_register_0
      port( reset, phi2 : in std_logic;  input_wip, input_fcs : in 
            std_logic_vector (0 to 31);  output_wip, output_fcs : out 
            std_logic_vector (0 to 31));
   end component;
   
   component gf_phi2_register_1
      port( reset, phi2 : in std_logic;  input_wip, input_fcs : in 
            std_logic_vector (0 to 31);  output_wip, output_fcs : out 
            std_logic_vector (0 to 31));
   end component;
   
   component gf_phi2_register_2
      port( reset, phi2 : in std_logic;  input_wip, input_fcs : in 
            std_logic_vector (0 to 31);  output_wip, output_fcs : out 
            std_logic_vector (0 to 31));
   end component;
   
   component gf_phi2_register_3
      port( reset, phi2 : in std_logic;  input_wip, input_fcs : in 
            std_logic_vector (0 to 31);  output_wip, output_fcs : out 
            std_logic_vector (0 to 31));
   end component;
   
   signal btw1x_2_7, btw2x_3_4, btw3_4_29, btw3_3x_14, btw6_7_7, btw7_8_0, 
      btw7x_8_3, btw9_9x_31, btw9_9x_16, btw8x_9_26, btw7x_8_27, btw1x_2_20, 
      btw4x_5_28, btw6x_7_21, btw7_7x_16, btw7_7x_31, btw2_3_23, btw3x_4_21, 
      btw5_5x_14, btw8_9_26, btw4_4x_11, btw4_4x_2, btw6_6x_13, btw9_10_0, 
      btw4x_5_7, btw5x_6_5, btw6x_7_6, btw9_10_10, btw5_6_11, btw7_8_12, 
      btw9x_10_7, btw1x_2_29, btw2_3_6, btw3_4_15, btw3_4_0, btw4_5_13, 
      btw4x_5_14, btw5_5x_28, btw8_9_5, btw2_2x_24, btw2_2x_11, btw2x_3_10, 
      btw3_3x_28, btw5x_6_11, btw6_6x_2, btw3_3x_1, btw3x_4_0, btw6_7_13, 
      btw8_8x_13, btw9_9x_4, btw9x_10_20, btw7_8_9, btw9x_10_15, btw2x_3_25, 
      btw6_7_26, btw8_8x_26, btw4_5_26, btw5x_6_24, btw4x_5_21, btw6x_7_28, 
      btw3_4_20, btw1x_2_15, btw2_3_31, btw2_3_16, btw3x_4_28, btw4_5_4, 
      btw5_6_24, btw7_8_27, btw4_4x_24, btw6_6x_26, btw8x_9_3, btw9_10_25, 
      btw4_4x_18, btw3_4_9, btw3x_4_14, btw9_10_19, btw9_10_9, btw7_7x_4, 
      btw8_9_13, btw8_8x_2, btw5_5x_21, btw2_3_11, btw2_3_8, btw2_2x_18, 
      btw2_2x_7, btw7_7x_23, btw2x_3_19, btw3_3x_8, btw5_6_18, btw6x_7_14, 
      btw7x_8_12, btw3x_4_9, btw3_3x_21, btw5_6_4, btw5x_6_18, btw8x_9_13, 
      btw5_6_3, btw5_5x_4, btw9x_10_29, btw8x_9_14, btw9_9x_23, btw3_3x_26, 
      btw3x_4_13, btw5_5x_3, btw8_8x_5, btw9_9x_24, btw4x_5_9, btw6x_7_8, 
      btw7x_8_15, btw9x_10_9, btw1x_2_12, btw2_2x_0, btw6x_7_13, btw7_7x_24, 
      btw3_4_27, btw5_6_23, btw5_5x_26, btw7_7x_3, btw7x_8_29, btw8_9_14, 
      btw1x_2_9, btw4_5_21, btw4x_5_26, btw7_7x_18, btw8_9_28, btw4_5_3, 
      btw4_4x_23, btw6_6x_21, btw8x_9_4, btw9_10_22, btw7_8_20, btw2_3_1, 
      btw2_2x_23, btw6_7_21, btw9_9x_18, btw2x_3_30, btw2x_3_22, btw5x_6_23, 
      btw8x_9_28, btw9x_10_12, btw6_7_9, btw2x_3_17, btw3_3x_6, btw8_8x_21, 
      btw3x_4_7, btw5x_6_31, btw8_8x_14, btw6_6x_5, btw5x_6_16, btw2_2x_31, 
      btw2_2x_16, btw6_7_14, btw9_9x_3, btw9x_10_27, btw2_3_18, btw7_8_15, 
      btw9x_10_0, btw2_2x_9, btw3_4_7, btw4_4x_31, btw4_4x_16, btw4x_5_0, 
      btw9_10_30, btw4_4x_5, btw5x_6_2, btw9_10_17, btw6_6x_14, btw6x_7_1, 
      btw9_10_7, btw4_5_14, btw5_6_31, btw8_9_2, btw4x_5_13, btw3_4_12, 
      btw1x_2_27, btw4_5_28, btw5_6_16, btw5_5x_13, btw8_9_21, btw6x_7_26, 
      btw7_7x_11, btw7x_8_20, btw1x_2_8, btw1x_2_0, btw2_3_24, btw7_8_29, 
      btw2x_3_3, btw3x_4_26, btw6_7_28, btw6_6x_28, btw7_8_7, btw7x_8_4, 
      btw9_9x_11, btw3_3x_13, btw8_8x_28, btw6_7_0, btw8x_9_21, btw2_2x_22, 
      btw6_7_20, btw9_9x_19, btw9x_10_13, btw2x_3_23, btw5x_6_22, btw6_7_8, 
      btw8x_9_29, btw5_6_22, btw7x_8_28, btw8_8x_20, btw1x_2_26, btw1x_2_13, 
      btw2_3_10, btw3_4_26, btw3x_4_12, btw4_5_20, btw4x_5_27, btw7_7x_19, 
      btw4_5_2, btw4_4x_22, btw6_6x_20, btw8_9_29, btw8x_9_5, btw9_10_23, 
      btw7_8_21, btw6x_7_9, btw8_8x_4, btw2_2x_1, btw4x_5_8, btw7_7x_25, 
      btw7x_8_14, btw9x_10_8, btw6x_7_12, btw1x_2_1, btw2_3_9, btw5_6_2, 
      btw5_5x_27, btw7_7x_2, btw8_9_15, btw8x_9_15, btw2x_3_2, btw3_3x_27, 
      btw5_5x_2, btw6_7_29, btw7_8_6, btw9_9x_25, btw7x_8_5, btw9_9x_10, 
      btw3_3x_12, btw8_8x_29, btw4_5_29, btw6_7_1, btw8_9_20, btw8x_9_20, 
      btw5_5x_12, btw6x_7_27, btw7_7x_10, btw7x_8_21, btw2_3_25, btw7_8_28, 
      btw2_3_19, btw3x_4_27, btw4x_5_1, btw6_6x_29, btw7_8_14, btw9x_10_1, 
      btw9_10_31, btw2_2x_8, btw3_4_6, btw4_5_15, btw4_4x_30, btw4_4x_17, 
      btw9_10_16, btw4_4x_4, btw6_6x_15, btw9_10_6, btw5_6_30, btw5x_6_3, 
      btw6x_7_0, btw4x_5_12, btw8_9_3, btw2_3_7, btw2_3_0, btw2x_3_16, 
      btw3_4_13, btw3_3x_7, btw3x_4_6, btw5_6_17, btw5x_6_30, btw8_8x_15, 
      btw2_2x_30, btw2_2x_17, btw2x_3_31, btw6_6x_4, btw5x_6_17, btw9x_10_26, 
      btw6_7_15, btw9_9x_2, btw5x_6_10, btw6_6x_3, btw2_2x_10, btw2x_3_11, 
      btw3_3x_29, btw3_3x_0, btw3x_4_1, btw6_7_12, btw8_8x_12, btw9_9x_5, 
      btw3_4_14, btw4_4x_10, btw4_4x_3, btw5x_6_4, btw9x_10_21, btw6_6x_12, 
      btw6x_7_7, btw9_10_1, btw9_10_11, btw4x_5_6, btw5_6_10, btw7_8_13, 
      btw9x_10_6, btw3_4_28, btw3_4_1, btw4x_5_15, btw8_9_4, btw4_5_12, 
      btw5_5x_29, btw7x_8_26, btw1x_2_28, btw1x_2_21, btw6x_7_20, btw7_7x_17, 
      btw1x_2_14, btw1x_2_6, btw2_3_22, btw3x_4_20, btw4x_5_29, btw5_5x_15, 
      btw7_7x_30, btw8_9_27, btw2x_3_5, btw2_3_30, btw2_3_17, btw2_2x_19, 
      btw2x_3_18, btw3_3x_20, btw3_3x_15, btw6_7_6, btw7_8_1, btw7x_8_2, 
      btw9_9x_30, btw9_9x_17, btw8x_9_27, btw3_3x_9, btw3x_4_8, btw5_6_5, 
      btw5x_6_19, btw8x_9_12, btw9x_10_28, btw4_4x_19, btw5_5x_5, btw9_9x_22, 
      btw9_10_18, btw3_4_8, btw3x_4_15, btw5_5x_20, btw8_8x_3, btw9_10_8, 
      btw7_7x_5, btw8_9_12, btw2_2x_6, btw4_5_27, btw5_6_19, btw6x_7_15, 
      btw7_7x_22, btw7x_8_13, btw4x_5_20, btw3_4_21, btw6x_7_29, btw5_6_25, 
      btw1x_2_23, btw1x_2_4, btw2_2x_25, btw3x_4_29, btw4_5_5, btw4_4x_25, 
      btw7_8_26, btw6_6x_27, btw8x_9_2, btw9_10_24, btw2x_3_24, btw6_7_27, 
      btw7_8_8, btw9x_10_14, btw8_8x_27, btw2x_3_7, btw3_3x_30, btw3_3x_17, 
      btw5x_6_25, btw6_7_4, btw8x_9_25, btw7_8_3, btw9_9x_15, btw7x_8_0, 
      btw2_3_20, btw3x_4_22, btw8x_9_9, btw5_5x_17, btw8_9_25, btw7x_8_24, 
      btw3_4_31, btw4x_5_17, btw5_5x_30, btw6x_7_22, btw7_7x_15, btw3_4_16, 
      btw3_4_3, btw4_5_10, btw8_9_19, btw8_9_6, btw2_3_29, btw2_3_5, btw2_2x_12
      , btw4_4x_12, btw4x_5_30, btw5_6_12, btw7x_8_18, btw7_7x_29, btw4x_5_4, 
      btw4_4x_1, btw5x_6_6, btw6_6x_10, btw7_8_11, btw9x_10_4, btw8_8x_8, 
      btw6_7_10, btw6x_7_5, btw9_10_3, btw9_10_13, btw9_9x_7, btw9_9x_29, 
      btw2x_3_13, btw9x_10_23, btw3_3x_2, btw3x_4_3, btw8_8x_10, btw8x_9_19, 
      btw2_2x_27, btw2x_3_26, btw5x_6_27, btw5x_6_12, btw6_6x_1, btw8_8x_25, 
      btw7x_8_9, btw9x_10_31, btw4_5_7, btw6_7_25, btw9x_10_16, btw6_6x_25, 
      btw8x_9_0, btw9_10_26, btw7_8_24, btw4_4x_27, btw3_4_23, btw5_6_27, 
      btw1x_2_31, btw4_5_25, btw4x_5_22, btw7_7x_20, btw2_2x_4, btw6x_7_17, 
      btw1x_2_16, btw4_5_19, btw5_5x_22, btw7_7x_7, btw7x_8_11, btw8_9_10, 
      btw6x_7_30, btw1x_2_11, btw2_3_15, btw3x_4_30, btw3x_4_17, btw4_4x_8, 
      btw6_6x_19, btw8_8x_1, btw7_8_18, btw3_3x_25, btw3_3x_22, btw5_6_7, 
      btw5_5x_7, btw6_7_19, btw9_9x_20, btw6_6x_8, btw8_8x_19, btw8x_9_10, 
      btw5_5x_0, btw9_9x_9, btw9_9x_27, btw5_6_0, btw8x_9_30, btw8x_9_17, 
      btw2_3_12, btw2_2x_3, btw3_4_18, btw4x_5_19, btw5_5x_25, btw7x_8_31, 
      btw7_7x_0, btw8_9_17, btw8_9_8, btw7x_8_16, btw8_9_30, btw6x_7_10, 
      btw7_7x_27, btw3x_4_10, btw4_5_22, btw4_5_0, btw4_4x_20, btw5x_6_8, 
      btw8_8x_6, btw4x_5_25, btw6_6x_22, btw7_8_23, btw8x_9_7, btw9_10_21, 
      btw5_5x_19, btw2_3_2, btw2_2x_20, btw2x_3_21, btw3_4_24, btw5_6_20, 
      btw3_3x_19, btw5x_6_20, btw8_8x_22, btw6_7_22, btw9x_10_11, btw2_2x_15, 
      btw2x_3_9, btw6_7_30, btw9x_10_24, btw5_5x_9, btw5x_6_15, btw6_7_17, 
      btw9_9x_0, btw6_6x_6, btw2x_3_14, btw3_3x_5, btw3x_4_4, btw5_6_9, 
      btw8_8x_30, btw8_8x_17, btw4_5_30, btw6x_7_19, btw5_6_15, btw3_4_11, 
      btw3_4_4, btw7_7x_9, btw8_9_1, btw4_5_17, btw1x_2_18, btw4x_5_10, 
      btw2_3_27, btw3x_4_25, btw3x_4_19, btw4_4x_6, btw9_10_14, btw9_10_4, 
      btw5x_6_1, btw6x_7_2, btw4_4x_15, btw6_6x_30, btw6_6x_17, btw7_8_31, 
      btw7_8_16, btw9x_10_3, btw4x_5_3, btw9_10_28, btw4_5_9, btw4_4x_29, 
      btw5_6_29, btw6x_7_25, btw7_7x_12, btw7x_8_23, btw1x_2_24, btw5_5x_10, 
      btw8_9_22, btw1x_2_3, btw2x_3_28, btw3_3x_10, btw5x_6_29, btw6_7_3, 
      btw8x_9_22, btw2x_3_0, btw2_2x_29, btw7_8_4, btw7x_8_7, btw2_2x_21, 
      btw2x_3_20, btw3_3x_18, btw9_9x_12, btw9x_10_18, btw5x_6_21, btw8_8x_23, 
      btw6_7_23, btw2x_3_8, btw9x_10_10, btw3_4_25, btw4_5_23, btw4_5_1, 
      btw4_4x_21, btw7_8_22, btw4x_5_24, btw6_6x_23, btw8x_9_6, btw9_10_20, 
      btw5_5x_18, btw1x_2_10, btw4x_5_18, btw5_6_21, btw1x_2_2, btw2_3_13, 
      btw2_2x_2, btw3_4_19, btw5_5x_24, btw7_7x_1, btw8_9_16, btw8_9_9, 
      btw7x_8_30, btw7x_8_17, btw8_9_31, btw7_7x_26, btw6x_7_11, btw2x_3_29, 
      btw3_3x_24, btw3x_4_11, btw5x_6_9, btw5_5x_1, btw8_8x_7, btw9_9x_26, 
      btw9_9x_8, btw5_6_1, btw8x_9_31, btw5x_6_28, btw8x_9_16, btw6_7_2, 
      btw8x_9_23, btw2x_3_1, btw3_3x_11, btw2_3_26, btw2_2x_28, btw9x_10_19, 
      btw3x_4_24, btw7_8_5, btw7x_8_6, btw9_10_29, btw9_9x_13, btw4_5_8, 
      btw4_4x_28, btw6x_7_24, btw7_7x_13, btw7x_8_22, btw1x_2_25, btw5_6_28, 
      btw5_5x_11, btw8_9_23, btw3_4_10, btw4_5_31, btw6x_7_18, btw5_6_14, 
      btw4_5_16, btw1x_2_19, btw3_4_5, btw7_7x_8, btw8_9_0, btw2_3_4, btw2_3_3,
      btw2_2x_14, btw3x_4_18, btw4x_5_11, btw7_8_30, btw9_10_15, btw4_4x_14, 
      btw4_4x_7, btw5x_6_0, btw6_6x_16, btw4x_5_2, btw6_6x_31, btw6x_7_3, 
      btw9_10_5, btw7_8_17, btw9x_10_2, btw6_7_31, btw5_5x_8, btw6_7_16, 
      btw9x_10_25, btw9_9x_1, btw2_2x_13, btw2x_3_15, btw3_3x_4, btw5_6_8, 
      btw5x_6_14, btw6_6x_7, btw8_8x_31, btw3x_4_5, btw8_8x_16, btw6_7_11, 
      btw9_9x_28, btw9_9x_6, btw9x_10_22, btw2x_3_12, btw3_3x_3, btw3x_4_2, 
      btw5x_6_13, btw6_6x_0, btw8_8x_11, btw8x_9_18, btw3_4_30, btw3_4_2, 
      btw4x_5_16, btw8_9_18, btw8_9_7, btw4_5_11, btw1x_2_22, btw2_3_21, 
      btw3_4_17, btw4_4x_13, btw4x_5_31, btw5_6_13, btw7x_8_19, btw7_7x_28, 
      btw4_4x_0, btw4x_5_5, btw7_8_10, btw9x_10_5, btw9_10_2, btw5x_6_7, 
      btw6_6x_11, btw6x_7_4, btw8_8x_9, btw9_10_12, btw3x_4_23, btw8x_9_8, 
      btw5_5x_16, btw7x_8_25, btw8_9_24, btw1x_2_30, btw1x_2_5, btw2x_3_6, 
      btw3_3x_31, btw3_3x_16, btw5_5x_31, btw6x_7_23, btw7_7x_14, btw8x_9_24, 
      btw6_7_5, btw7_8_2, btw9_9x_14, btw7x_8_1, btw2_2x_5, btw3_3x_23, 
      btw5_6_6, btw5_5x_6, btw6_7_18, btw6_6x_9, btw9_9x_21, btw8x_9_11, 
      btw8_8x_18, btw6x_7_16, btw7_7x_21, btw1x_2_17, btw4_5_18, btw5_5x_23, 
      btw7x_8_10, btw6x_7_31, btw7_7x_6, btw8_9_11, btw2_3_28, btw2_3_14, 
      btw3x_4_31, btw3x_4_16, btw6_6x_18, btw8_8x_0, btw4_4x_9, btw7_8_19, 
      btw4_5_6, btw6_6x_24, btw8x_9_1, btw9_10_27, btw4_4x_26, btw7_8_25, 
      btw5_6_26, btw2_2x_26, btw2x_3_27, btw3_4_22, btw4_5_24, btw4x_5_23, 
      btw5x_6_26, btw8_8x_24, btw9x_10_30, btw9x_10_17, btw6_7_24, btw7x_8_8 : 
      std_logic;

begin
   
   GF1x : gf_xor_input port map( input_fcs(0) => input(0), input_fcs(1) => 
                           input(1), input_fcs(2) => input(2), input_fcs(3) => 
                           input(3), input_fcs(4) => input(4), input_fcs(5) => 
                           input(5), input_fcs(6) => input(6), input_fcs(7) => 
                           input(7), input_fcs(8) => input(8), input_fcs(9) => 
                           input(9), input_fcs(10) => input(10), input_fcs(11) 
                           => input(11), input_fcs(12) => input(12), 
                           input_fcs(13) => input(13), input_fcs(14) => 
                           input(14), input_fcs(15) => input(15), input_fcs(16)
                           => input(16), input_fcs(17) => input(17), 
                           input_fcs(18) => input(18), input_fcs(19) => 
                           input(19), input_fcs(20) => input(20), input_fcs(21)
                           => input(21), input_fcs(22) => input(22), 
                           input_fcs(23) => input(23), input_fcs(24) => 
                           input(24), input_fcs(25) => input(25), input_fcs(26)
                           => input(26), input_fcs(27) => input(27), 
                           input_fcs(28) => input(28), input_fcs(29) => 
                           input(29), input_fcs(30) => input(30), input_fcs(31)
                           => input(31), output_wip(0) => btw1x_2_31, 
                           output_wip(1) => btw1x_2_30, output_wip(2) => 
                           btw1x_2_29, output_wip(3) => btw1x_2_28, 
                           output_wip(4) => btw1x_2_27, output_wip(5) => 
                           btw1x_2_26, output_wip(6) => btw1x_2_25, 
                           output_wip(7) => btw1x_2_24, output_wip(8) => 
                           btw1x_2_23, output_wip(9) => btw1x_2_22, 
                           output_wip(10) => btw1x_2_21, output_wip(11) => 
                           btw1x_2_20, output_wip(12) => btw1x_2_19, 
                           output_wip(13) => btw1x_2_18, output_wip(14) => 
                           btw1x_2_17, output_wip(15) => btw1x_2_16, 
                           output_wip(16) => btw1x_2_15, output_wip(17) => 
                           btw1x_2_14, output_wip(18) => btw1x_2_13, 
                           output_wip(19) => btw1x_2_12, output_wip(20) => 
                           btw1x_2_11, output_wip(21) => btw1x_2_10, 
                           output_wip(22) => btw1x_2_9, output_wip(23) => 
                           btw1x_2_8, output_wip(24) => btw1x_2_7, 
                           output_wip(25) => btw1x_2_6, output_wip(26) => 
                           btw1x_2_5, output_wip(27) => btw1x_2_4, 
                           output_wip(28) => btw1x_2_3, output_wip(29) => 
                           btw1x_2_2, output_wip(30) => btw1x_2_1, 
                           output_wip(31) => btw1x_2_0);
   GF2x : gf_xor_2x port map( input_wip(0) => btw2_2x_31, input_wip(1) => 
                           btw2_2x_30, input_wip(2) => btw2_2x_29, input_wip(3)
                           => btw2_2x_28, input_wip(4) => btw2_2x_27, 
                           input_wip(5) => btw2_2x_26, input_wip(6) => 
                           btw2_2x_25, input_wip(7) => btw2_2x_24, input_wip(8)
                           => btw2_2x_23, input_wip(9) => btw2_2x_22, 
                           input_wip(10) => btw2_2x_21, input_wip(11) => 
                           btw2_2x_20, input_wip(12) => btw2_2x_19, 
                           input_wip(13) => btw2_2x_18, input_wip(14) => 
                           btw2_2x_17, input_wip(15) => btw2_2x_16, 
                           input_wip(16) => btw2_2x_15, input_wip(17) => 
                           btw2_2x_14, input_wip(18) => btw2_2x_13, 
                           input_wip(19) => btw2_2x_12, input_wip(20) => 
                           btw2_2x_11, input_wip(21) => btw2_2x_10, 
                           input_wip(22) => btw2_2x_9, input_wip(23) => 
                           btw2_2x_8, input_wip(24) => btw2_2x_7, input_wip(25)
                           => btw2_2x_6, input_wip(26) => btw2_2x_5, 
                           input_wip(27) => btw2_2x_4, input_wip(28) => 
                           btw2_2x_3, input_wip(29) => btw2_2x_2, input_wip(30)
                           => btw2_2x_1, input_wip(31) => btw2_2x_0, 
                           input_fcs(0) => btw2_3_31, input_fcs(1) => btw2_3_30
                           , input_fcs(2) => btw2_3_29, input_fcs(3) => 
                           btw2_3_28, input_fcs(4) => btw2_3_27, input_fcs(5) 
                           => btw2_3_26, input_fcs(6) => btw2_3_25, 
                           input_fcs(7) => btw2_3_24, input_fcs(8) => btw2_3_23
                           , input_fcs(9) => btw2_3_22, input_fcs(10) => 
                           btw2_3_21, input_fcs(11) => btw2_3_20, input_fcs(12)
                           => btw2_3_19, input_fcs(13) => btw2_3_18, 
                           input_fcs(14) => btw2_3_17, input_fcs(15) => 
                           btw2_3_16, input_fcs(16) => btw2_3_15, input_fcs(17)
                           => btw2_3_14, input_fcs(18) => btw2_3_13, 
                           input_fcs(19) => btw2_3_12, input_fcs(20) => 
                           btw2_3_11, input_fcs(21) => btw2_3_10, input_fcs(22)
                           => btw2_3_9, input_fcs(23) => btw2_3_8, 
                           input_fcs(24) => btw2_3_7, input_fcs(25) => btw2_3_6
                           , input_fcs(26) => btw2_3_5, input_fcs(27) => 
                           btw2_3_4, input_fcs(28) => btw2_3_3, input_fcs(29) 
                           => btw2_3_2, input_fcs(30) => btw2_3_1, 
                           input_fcs(31) => btw2_3_0, output_wip(0) => 
                           btw2x_3_31, output_wip(1) => btw2x_3_30, 
                           output_wip(2) => btw2x_3_29, output_wip(3) => 
                           btw2x_3_28, output_wip(4) => btw2x_3_27, 
                           output_wip(5) => btw2x_3_26, output_wip(6) => 
                           btw2x_3_25, output_wip(7) => btw2x_3_24, 
                           output_wip(8) => btw2x_3_23, output_wip(9) => 
                           btw2x_3_22, output_wip(10) => btw2x_3_21, 
                           output_wip(11) => btw2x_3_20, output_wip(12) => 
                           btw2x_3_19, output_wip(13) => btw2x_3_18, 
                           output_wip(14) => btw2x_3_17, output_wip(15) => 
                           btw2x_3_16, output_wip(16) => btw2x_3_15, 
                           output_wip(17) => btw2x_3_14, output_wip(18) => 
                           btw2x_3_13, output_wip(19) => btw2x_3_12, 
                           output_wip(20) => btw2x_3_11, output_wip(21) => 
                           btw2x_3_10, output_wip(22) => btw2x_3_9, 
                           output_wip(23) => btw2x_3_8, output_wip(24) => 
                           btw2x_3_7, output_wip(25) => btw2x_3_6, 
                           output_wip(26) => btw2x_3_5, output_wip(27) => 
                           btw2x_3_4, output_wip(28) => btw2x_3_3, 
                           output_wip(29) => btw2x_3_2, output_wip(30) => 
                           btw2x_3_1, output_wip(31) => btw2x_3_0);
   GF6 : gf_phi1_register_3 port map( reset => reset, phi1 => phi1, 
                           input_wip(0) => btw5x_6_31, input_wip(1) => 
                           btw5x_6_30, input_wip(2) => btw5x_6_29, input_wip(3)
                           => btw5x_6_28, input_wip(4) => btw5x_6_27, 
                           input_wip(5) => btw5x_6_26, input_wip(6) => 
                           btw5x_6_25, input_wip(7) => btw5x_6_24, input_wip(8)
                           => btw5x_6_23, input_wip(9) => btw5x_6_22, 
                           input_wip(10) => btw5x_6_21, input_wip(11) => 
                           btw5x_6_20, input_wip(12) => btw5x_6_19, 
                           input_wip(13) => btw5x_6_18, input_wip(14) => 
                           btw5x_6_17, input_wip(15) => btw5x_6_16, 
                           input_wip(16) => btw5x_6_15, input_wip(17) => 
                           btw5x_6_14, input_wip(18) => btw5x_6_13, 
                           input_wip(19) => btw5x_6_12, input_wip(20) => 
                           btw5x_6_11, input_wip(21) => btw5x_6_10, 
                           input_wip(22) => btw5x_6_9, input_wip(23) => 
                           btw5x_6_8, input_wip(24) => btw5x_6_7, input_wip(25)
                           => btw5x_6_6, input_wip(26) => btw5x_6_5, 
                           input_wip(27) => btw5x_6_4, input_wip(28) => 
                           btw5x_6_3, input_wip(29) => btw5x_6_2, input_wip(30)
                           => btw5x_6_1, input_wip(31) => btw5x_6_0, 
                           input_fcs(0) => btw5_6_31, input_fcs(1) => btw5_6_30
                           , input_fcs(2) => btw5_6_29, input_fcs(3) => 
                           btw5_6_28, input_fcs(4) => btw5_6_27, input_fcs(5) 
                           => btw5_6_26, input_fcs(6) => btw5_6_25, 
                           input_fcs(7) => btw5_6_24, input_fcs(8) => btw5_6_23
                           , input_fcs(9) => btw5_6_22, input_fcs(10) => 
                           btw5_6_21, input_fcs(11) => btw5_6_20, input_fcs(12)
                           => btw5_6_19, input_fcs(13) => btw5_6_18, 
                           input_fcs(14) => btw5_6_17, input_fcs(15) => 
                           btw5_6_16, input_fcs(16) => btw5_6_15, input_fcs(17)
                           => btw5_6_14, input_fcs(18) => btw5_6_13, 
                           input_fcs(19) => btw5_6_12, input_fcs(20) => 
                           btw5_6_11, input_fcs(21) => btw5_6_10, input_fcs(22)
                           => btw5_6_9, input_fcs(23) => btw5_6_8, 
                           input_fcs(24) => btw5_6_7, input_fcs(25) => btw5_6_6
                           , input_fcs(26) => btw5_6_5, input_fcs(27) => 
                           btw5_6_4, input_fcs(28) => btw5_6_3, input_fcs(29) 
                           => btw5_6_2, input_fcs(30) => btw5_6_1, 
                           input_fcs(31) => btw5_6_0, output_wip(0) => 
                           btw6_6x_31, output_wip(1) => btw6_6x_30, 
                           output_wip(2) => btw6_6x_29, output_wip(3) => 
                           btw6_6x_28, output_wip(4) => btw6_6x_27, 
                           output_wip(5) => btw6_6x_26, output_wip(6) => 
                           btw6_6x_25, output_wip(7) => btw6_6x_24, 
                           output_wip(8) => btw6_6x_23, output_wip(9) => 
                           btw6_6x_22, output_wip(10) => btw6_6x_21, 
                           output_wip(11) => btw6_6x_20, output_wip(12) => 
                           btw6_6x_19, output_wip(13) => btw6_6x_18, 
                           output_wip(14) => btw6_6x_17, output_wip(15) => 
                           btw6_6x_16, output_wip(16) => btw6_6x_15, 
                           output_wip(17) => btw6_6x_14, output_wip(18) => 
                           btw6_6x_13, output_wip(19) => btw6_6x_12, 
                           output_wip(20) => btw6_6x_11, output_wip(21) => 
                           btw6_6x_10, output_wip(22) => btw6_6x_9, 
                           output_wip(23) => btw6_6x_8, output_wip(24) => 
                           btw6_6x_7, output_wip(25) => btw6_6x_6, 
                           output_wip(26) => btw6_6x_5, output_wip(27) => 
                           btw6_6x_4, output_wip(28) => btw6_6x_3, 
                           output_wip(29) => btw6_6x_2, output_wip(30) => 
                           btw6_6x_1, output_wip(31) => btw6_6x_0, 
                           output_fcs(0) => btw6_7_31, output_fcs(1) => 
                           btw6_7_30, output_fcs(2) => btw6_7_29, output_fcs(3)
                           => btw6_7_28, output_fcs(4) => btw6_7_27, 
                           output_fcs(5) => btw6_7_26, output_fcs(6) => 
                           btw6_7_25, output_fcs(7) => btw6_7_24, output_fcs(8)
                           => btw6_7_23, output_fcs(9) => btw6_7_22, 
                           output_fcs(10) => btw6_7_21, output_fcs(11) => 
                           btw6_7_20, output_fcs(12) => btw6_7_19, 
                           output_fcs(13) => btw6_7_18, output_fcs(14) => 
                           btw6_7_17, output_fcs(15) => btw6_7_16, 
                           output_fcs(16) => btw6_7_15, output_fcs(17) => 
                           btw6_7_14, output_fcs(18) => btw6_7_13, 
                           output_fcs(19) => btw6_7_12, output_fcs(20) => 
                           btw6_7_11, output_fcs(21) => btw6_7_10, 
                           output_fcs(22) => btw6_7_9, output_fcs(23) => 
                           btw6_7_8, output_fcs(24) => btw6_7_7, output_fcs(25)
                           => btw6_7_6, output_fcs(26) => btw6_7_5, 
                           output_fcs(27) => btw6_7_4, output_fcs(28) => 
                           btw6_7_3, output_fcs(29) => btw6_7_2, output_fcs(30)
                           => btw6_7_1, output_fcs(31) => btw6_7_0);
   GF8 : gf_phi1_register_2 port map( reset => reset, phi1 => phi1, 
                           input_wip(0) => btw7x_8_31, input_wip(1) => 
                           btw7x_8_30, input_wip(2) => btw7x_8_29, input_wip(3)
                           => btw7x_8_28, input_wip(4) => btw7x_8_27, 
                           input_wip(5) => btw7x_8_26, input_wip(6) => 
                           btw7x_8_25, input_wip(7) => btw7x_8_24, input_wip(8)
                           => btw7x_8_23, input_wip(9) => btw7x_8_22, 
                           input_wip(10) => btw7x_8_21, input_wip(11) => 
                           btw7x_8_20, input_wip(12) => btw7x_8_19, 
                           input_wip(13) => btw7x_8_18, input_wip(14) => 
                           btw7x_8_17, input_wip(15) => btw7x_8_16, 
                           input_wip(16) => btw7x_8_15, input_wip(17) => 
                           btw7x_8_14, input_wip(18) => btw7x_8_13, 
                           input_wip(19) => btw7x_8_12, input_wip(20) => 
                           btw7x_8_11, input_wip(21) => btw7x_8_10, 
                           input_wip(22) => btw7x_8_9, input_wip(23) => 
                           btw7x_8_8, input_wip(24) => btw7x_8_7, input_wip(25)
                           => btw7x_8_6, input_wip(26) => btw7x_8_5, 
                           input_wip(27) => btw7x_8_4, input_wip(28) => 
                           btw7x_8_3, input_wip(29) => btw7x_8_2, input_wip(30)
                           => btw7x_8_1, input_wip(31) => btw7x_8_0, 
                           input_fcs(0) => btw7_8_31, input_fcs(1) => btw7_8_30
                           , input_fcs(2) => btw7_8_29, input_fcs(3) => 
                           btw7_8_28, input_fcs(4) => btw7_8_27, input_fcs(5) 
                           => btw7_8_26, input_fcs(6) => btw7_8_25, 
                           input_fcs(7) => btw7_8_24, input_fcs(8) => btw7_8_23
                           , input_fcs(9) => btw7_8_22, input_fcs(10) => 
                           btw7_8_21, input_fcs(11) => btw7_8_20, input_fcs(12)
                           => btw7_8_19, input_fcs(13) => btw7_8_18, 
                           input_fcs(14) => btw7_8_17, input_fcs(15) => 
                           btw7_8_16, input_fcs(16) => btw7_8_15, input_fcs(17)
                           => btw7_8_14, input_fcs(18) => btw7_8_13, 
                           input_fcs(19) => btw7_8_12, input_fcs(20) => 
                           btw7_8_11, input_fcs(21) => btw7_8_10, input_fcs(22)
                           => btw7_8_9, input_fcs(23) => btw7_8_8, 
                           input_fcs(24) => btw7_8_7, input_fcs(25) => btw7_8_6
                           , input_fcs(26) => btw7_8_5, input_fcs(27) => 
                           btw7_8_4, input_fcs(28) => btw7_8_3, input_fcs(29) 
                           => btw7_8_2, input_fcs(30) => btw7_8_1, 
                           input_fcs(31) => btw7_8_0, output_wip(0) => 
                           btw8_8x_31, output_wip(1) => btw8_8x_30, 
                           output_wip(2) => btw8_8x_29, output_wip(3) => 
                           btw8_8x_28, output_wip(4) => btw8_8x_27, 
                           output_wip(5) => btw8_8x_26, output_wip(6) => 
                           btw8_8x_25, output_wip(7) => btw8_8x_24, 
                           output_wip(8) => btw8_8x_23, output_wip(9) => 
                           btw8_8x_22, output_wip(10) => btw8_8x_21, 
                           output_wip(11) => btw8_8x_20, output_wip(12) => 
                           btw8_8x_19, output_wip(13) => btw8_8x_18, 
                           output_wip(14) => btw8_8x_17, output_wip(15) => 
                           btw8_8x_16, output_wip(16) => btw8_8x_15, 
                           output_wip(17) => btw8_8x_14, output_wip(18) => 
                           btw8_8x_13, output_wip(19) => btw8_8x_12, 
                           output_wip(20) => btw8_8x_11, output_wip(21) => 
                           btw8_8x_10, output_wip(22) => btw8_8x_9, 
                           output_wip(23) => btw8_8x_8, output_wip(24) => 
                           btw8_8x_7, output_wip(25) => btw8_8x_6, 
                           output_wip(26) => btw8_8x_5, output_wip(27) => 
                           btw8_8x_4, output_wip(28) => btw8_8x_3, 
                           output_wip(29) => btw8_8x_2, output_wip(30) => 
                           btw8_8x_1, output_wip(31) => btw8_8x_0, 
                           output_fcs(0) => btw8_9_31, output_fcs(1) => 
                           btw8_9_30, output_fcs(2) => btw8_9_29, output_fcs(3)
                           => btw8_9_28, output_fcs(4) => btw8_9_27, 
                           output_fcs(5) => btw8_9_26, output_fcs(6) => 
                           btw8_9_25, output_fcs(7) => btw8_9_24, output_fcs(8)
                           => btw8_9_23, output_fcs(9) => btw8_9_22, 
                           output_fcs(10) => btw8_9_21, output_fcs(11) => 
                           btw8_9_20, output_fcs(12) => btw8_9_19, 
                           output_fcs(13) => btw8_9_18, output_fcs(14) => 
                           btw8_9_17, output_fcs(15) => btw8_9_16, 
                           output_fcs(16) => btw8_9_15, output_fcs(17) => 
                           btw8_9_14, output_fcs(18) => btw8_9_13, 
                           output_fcs(19) => btw8_9_12, output_fcs(20) => 
                           btw8_9_11, output_fcs(21) => btw8_9_10, 
                           output_fcs(22) => btw8_9_9, output_fcs(23) => 
                           btw8_9_8, output_fcs(24) => btw8_9_7, output_fcs(25)
                           => btw8_9_6, output_fcs(26) => btw8_9_5, 
                           output_fcs(27) => btw8_9_4, output_fcs(28) => 
                           btw8_9_3, output_fcs(29) => btw8_9_2, output_fcs(30)
                           => btw8_9_1, output_fcs(31) => btw8_9_0);
   GF6x : gf_xor_6x port map( input_wip(0) => btw6_6x_31, input_wip(1) => 
                           btw6_6x_30, input_wip(2) => btw6_6x_29, input_wip(3)
                           => btw6_6x_28, input_wip(4) => btw6_6x_27, 
                           input_wip(5) => btw6_6x_26, input_wip(6) => 
                           btw6_6x_25, input_wip(7) => btw6_6x_24, input_wip(8)
                           => btw6_6x_23, input_wip(9) => btw6_6x_22, 
                           input_wip(10) => btw6_6x_21, input_wip(11) => 
                           btw6_6x_20, input_wip(12) => btw6_6x_19, 
                           input_wip(13) => btw6_6x_18, input_wip(14) => 
                           btw6_6x_17, input_wip(15) => btw6_6x_16, 
                           input_wip(16) => btw6_6x_15, input_wip(17) => 
                           btw6_6x_14, input_wip(18) => btw6_6x_13, 
                           input_wip(19) => btw6_6x_12, input_wip(20) => 
                           btw6_6x_11, input_wip(21) => btw6_6x_10, 
                           input_wip(22) => btw6_6x_9, input_wip(23) => 
                           btw6_6x_8, input_wip(24) => btw6_6x_7, input_wip(25)
                           => btw6_6x_6, input_wip(26) => btw6_6x_5, 
                           input_wip(27) => btw6_6x_4, input_wip(28) => 
                           btw6_6x_3, input_wip(29) => btw6_6x_2, input_wip(30)
                           => btw6_6x_1, input_wip(31) => btw6_6x_0, 
                           input_fcs(0) => btw6_7_31, input_fcs(1) => btw6_7_30
                           , input_fcs(2) => btw6_7_29, input_fcs(3) => 
                           btw6_7_28, input_fcs(4) => btw6_7_27, input_fcs(5) 
                           => btw6_7_26, input_fcs(6) => btw6_7_25, 
                           input_fcs(7) => btw6_7_24, input_fcs(8) => btw6_7_23
                           , input_fcs(9) => btw6_7_22, input_fcs(10) => 
                           btw6_7_21, input_fcs(11) => btw6_7_20, input_fcs(12)
                           => btw6_7_19, input_fcs(13) => btw6_7_18, 
                           input_fcs(14) => btw6_7_17, input_fcs(15) => 
                           btw6_7_16, input_fcs(16) => btw6_7_15, input_fcs(17)
                           => btw6_7_14, input_fcs(18) => btw6_7_13, 
                           input_fcs(19) => btw6_7_12, input_fcs(20) => 
                           btw6_7_11, input_fcs(21) => btw6_7_10, input_fcs(22)
                           => btw6_7_9, input_fcs(23) => btw6_7_8, 
                           input_fcs(24) => btw6_7_7, input_fcs(25) => btw6_7_6
                           , input_fcs(26) => btw6_7_5, input_fcs(27) => 
                           btw6_7_4, input_fcs(28) => btw6_7_3, input_fcs(29) 
                           => btw6_7_2, input_fcs(30) => btw6_7_1, 
                           input_fcs(31) => btw6_7_0, output_wip(0) => 
                           btw6x_7_31, output_wip(1) => btw6x_7_30, 
                           output_wip(2) => btw6x_7_29, output_wip(3) => 
                           btw6x_7_28, output_wip(4) => btw6x_7_27, 
                           output_wip(5) => btw6x_7_26, output_wip(6) => 
                           btw6x_7_25, output_wip(7) => btw6x_7_24, 
                           output_wip(8) => btw6x_7_23, output_wip(9) => 
                           btw6x_7_22, output_wip(10) => btw6x_7_21, 
                           output_wip(11) => btw6x_7_20, output_wip(12) => 
                           btw6x_7_19, output_wip(13) => btw6x_7_18, 
                           output_wip(14) => btw6x_7_17, output_wip(15) => 
                           btw6x_7_16, output_wip(16) => btw6x_7_15, 
                           output_wip(17) => btw6x_7_14, output_wip(18) => 
                           btw6x_7_13, output_wip(19) => btw6x_7_12, 
                           output_wip(20) => btw6x_7_11, output_wip(21) => 
                           btw6x_7_10, output_wip(22) => btw6x_7_9, 
                           output_wip(23) => btw6x_7_8, output_wip(24) => 
                           btw6x_7_7, output_wip(25) => btw6x_7_6, 
                           output_wip(26) => btw6x_7_5, output_wip(27) => 
                           btw6x_7_4, output_wip(28) => btw6x_7_3, 
                           output_wip(29) => btw6x_7_2, output_wip(30) => 
                           btw6x_7_1, output_wip(31) => btw6x_7_0);
   GF7 : gf_phi2_register_3 port map( reset => reset, phi2 => phi2, 
                           input_wip(0) => btw6x_7_31, input_wip(1) => 
                           btw6x_7_30, input_wip(2) => btw6x_7_29, input_wip(3)
                           => btw6x_7_28, input_wip(4) => btw6x_7_27, 
                           input_wip(5) => btw6x_7_26, input_wip(6) => 
                           btw6x_7_25, input_wip(7) => btw6x_7_24, input_wip(8)
                           => btw6x_7_23, input_wip(9) => btw6x_7_22, 
                           input_wip(10) => btw6x_7_21, input_wip(11) => 
                           btw6x_7_20, input_wip(12) => btw6x_7_19, 
                           input_wip(13) => btw6x_7_18, input_wip(14) => 
                           btw6x_7_17, input_wip(15) => btw6x_7_16, 
                           input_wip(16) => btw6x_7_15, input_wip(17) => 
                           btw6x_7_14, input_wip(18) => btw6x_7_13, 
                           input_wip(19) => btw6x_7_12, input_wip(20) => 
                           btw6x_7_11, input_wip(21) => btw6x_7_10, 
                           input_wip(22) => btw6x_7_9, input_wip(23) => 
                           btw6x_7_8, input_wip(24) => btw6x_7_7, input_wip(25)
                           => btw6x_7_6, input_wip(26) => btw6x_7_5, 
                           input_wip(27) => btw6x_7_4, input_wip(28) => 
                           btw6x_7_3, input_wip(29) => btw6x_7_2, input_wip(30)
                           => btw6x_7_1, input_wip(31) => btw6x_7_0, 
                           input_fcs(0) => btw6_7_31, input_fcs(1) => btw6_7_30
                           , input_fcs(2) => btw6_7_29, input_fcs(3) => 
                           btw6_7_28, input_fcs(4) => btw6_7_27, input_fcs(5) 
                           => btw6_7_26, input_fcs(6) => btw6_7_25, 
                           input_fcs(7) => btw6_7_24, input_fcs(8) => btw6_7_23
                           , input_fcs(9) => btw6_7_22, input_fcs(10) => 
                           btw6_7_21, input_fcs(11) => btw6_7_20, input_fcs(12)
                           => btw6_7_19, input_fcs(13) => btw6_7_18, 
                           input_fcs(14) => btw6_7_17, input_fcs(15) => 
                           btw6_7_16, input_fcs(16) => btw6_7_15, input_fcs(17)
                           => btw6_7_14, input_fcs(18) => btw6_7_13, 
                           input_fcs(19) => btw6_7_12, input_fcs(20) => 
                           btw6_7_11, input_fcs(21) => btw6_7_10, input_fcs(22)
                           => btw6_7_9, input_fcs(23) => btw6_7_8, 
                           input_fcs(24) => btw6_7_7, input_fcs(25) => btw6_7_6
                           , input_fcs(26) => btw6_7_5, input_fcs(27) => 
                           btw6_7_4, input_fcs(28) => btw6_7_3, input_fcs(29) 
                           => btw6_7_2, input_fcs(30) => btw6_7_1, 
                           input_fcs(31) => btw6_7_0, output_wip(0) => 
                           btw7_7x_31, output_wip(1) => btw7_7x_30, 
                           output_wip(2) => btw7_7x_29, output_wip(3) => 
                           btw7_7x_28, output_wip(4) => btw7_7x_27, 
                           output_wip(5) => btw7_7x_26, output_wip(6) => 
                           btw7_7x_25, output_wip(7) => btw7_7x_24, 
                           output_wip(8) => btw7_7x_23, output_wip(9) => 
                           btw7_7x_22, output_wip(10) => btw7_7x_21, 
                           output_wip(11) => btw7_7x_20, output_wip(12) => 
                           btw7_7x_19, output_wip(13) => btw7_7x_18, 
                           output_wip(14) => btw7_7x_17, output_wip(15) => 
                           btw7_7x_16, output_wip(16) => btw7_7x_15, 
                           output_wip(17) => btw7_7x_14, output_wip(18) => 
                           btw7_7x_13, output_wip(19) => btw7_7x_12, 
                           output_wip(20) => btw7_7x_11, output_wip(21) => 
                           btw7_7x_10, output_wip(22) => btw7_7x_9, 
                           output_wip(23) => btw7_7x_8, output_wip(24) => 
                           btw7_7x_7, output_wip(25) => btw7_7x_6, 
                           output_wip(26) => btw7_7x_5, output_wip(27) => 
                           btw7_7x_4, output_wip(28) => btw7_7x_3, 
                           output_wip(29) => btw7_7x_2, output_wip(30) => 
                           btw7_7x_1, output_wip(31) => btw7_7x_0, 
                           output_fcs(0) => btw7_8_31, output_fcs(1) => 
                           btw7_8_30, output_fcs(2) => btw7_8_29, output_fcs(3)
                           => btw7_8_28, output_fcs(4) => btw7_8_27, 
                           output_fcs(5) => btw7_8_26, output_fcs(6) => 
                           btw7_8_25, output_fcs(7) => btw7_8_24, output_fcs(8)
                           => btw7_8_23, output_fcs(9) => btw7_8_22, 
                           output_fcs(10) => btw7_8_21, output_fcs(11) => 
                           btw7_8_20, output_fcs(12) => btw7_8_19, 
                           output_fcs(13) => btw7_8_18, output_fcs(14) => 
                           btw7_8_17, output_fcs(15) => btw7_8_16, 
                           output_fcs(16) => btw7_8_15, output_fcs(17) => 
                           btw7_8_14, output_fcs(18) => btw7_8_13, 
                           output_fcs(19) => btw7_8_12, output_fcs(20) => 
                           btw7_8_11, output_fcs(21) => btw7_8_10, 
                           output_fcs(22) => btw7_8_9, output_fcs(23) => 
                           btw7_8_8, output_fcs(24) => btw7_8_7, output_fcs(25)
                           => btw7_8_6, output_fcs(26) => btw7_8_5, 
                           output_fcs(27) => btw7_8_4, output_fcs(28) => 
                           btw7_8_3, output_fcs(29) => btw7_8_2, output_fcs(30)
                           => btw7_8_1, output_fcs(31) => btw7_8_0);
   GF4x : gf_xor_4x port map( input_wip(0) => btw4_4x_31, input_wip(1) => 
                           btw4_4x_30, input_wip(2) => btw4_4x_29, input_wip(3)
                           => btw4_4x_28, input_wip(4) => btw4_4x_27, 
                           input_wip(5) => btw4_4x_26, input_wip(6) => 
                           btw4_4x_25, input_wip(7) => btw4_4x_24, input_wip(8)
                           => btw4_4x_23, input_wip(9) => btw4_4x_22, 
                           input_wip(10) => btw4_4x_21, input_wip(11) => 
                           btw4_4x_20, input_wip(12) => btw4_4x_19, 
                           input_wip(13) => btw4_4x_18, input_wip(14) => 
                           btw4_4x_17, input_wip(15) => btw4_4x_16, 
                           input_wip(16) => btw4_4x_15, input_wip(17) => 
                           btw4_4x_14, input_wip(18) => btw4_4x_13, 
                           input_wip(19) => btw4_4x_12, input_wip(20) => 
                           btw4_4x_11, input_wip(21) => btw4_4x_10, 
                           input_wip(22) => btw4_4x_9, input_wip(23) => 
                           btw4_4x_8, input_wip(24) => btw4_4x_7, input_wip(25)
                           => btw4_4x_6, input_wip(26) => btw4_4x_5, 
                           input_wip(27) => btw4_4x_4, input_wip(28) => 
                           btw4_4x_3, input_wip(29) => btw4_4x_2, input_wip(30)
                           => btw4_4x_1, input_wip(31) => btw4_4x_0, 
                           input_fcs(0) => btw4_5_31, input_fcs(1) => btw4_5_30
                           , input_fcs(2) => btw4_5_29, input_fcs(3) => 
                           btw4_5_28, input_fcs(4) => btw4_5_27, input_fcs(5) 
                           => btw4_5_26, input_fcs(6) => btw4_5_25, 
                           input_fcs(7) => btw4_5_24, input_fcs(8) => btw4_5_23
                           , input_fcs(9) => btw4_5_22, input_fcs(10) => 
                           btw4_5_21, input_fcs(11) => btw4_5_20, input_fcs(12)
                           => btw4_5_19, input_fcs(13) => btw4_5_18, 
                           input_fcs(14) => btw4_5_17, input_fcs(15) => 
                           btw4_5_16, input_fcs(16) => btw4_5_15, input_fcs(17)
                           => btw4_5_14, input_fcs(18) => btw4_5_13, 
                           input_fcs(19) => btw4_5_12, input_fcs(20) => 
                           btw4_5_11, input_fcs(21) => btw4_5_10, input_fcs(22)
                           => btw4_5_9, input_fcs(23) => btw4_5_8, 
                           input_fcs(24) => btw4_5_7, input_fcs(25) => btw4_5_6
                           , input_fcs(26) => btw4_5_5, input_fcs(27) => 
                           btw4_5_4, input_fcs(28) => btw4_5_3, input_fcs(29) 
                           => btw4_5_2, input_fcs(30) => btw4_5_1, 
                           input_fcs(31) => btw4_5_0, output_wip(0) => 
                           btw4x_5_31, output_wip(1) => btw4x_5_30, 
                           output_wip(2) => btw4x_5_29, output_wip(3) => 
                           btw4x_5_28, output_wip(4) => btw4x_5_27, 
                           output_wip(5) => btw4x_5_26, output_wip(6) => 
                           btw4x_5_25, output_wip(7) => btw4x_5_24, 
                           output_wip(8) => btw4x_5_23, output_wip(9) => 
                           btw4x_5_22, output_wip(10) => btw4x_5_21, 
                           output_wip(11) => btw4x_5_20, output_wip(12) => 
                           btw4x_5_19, output_wip(13) => btw4x_5_18, 
                           output_wip(14) => btw4x_5_17, output_wip(15) => 
                           btw4x_5_16, output_wip(16) => btw4x_5_15, 
                           output_wip(17) => btw4x_5_14, output_wip(18) => 
                           btw4x_5_13, output_wip(19) => btw4x_5_12, 
                           output_wip(20) => btw4x_5_11, output_wip(21) => 
                           btw4x_5_10, output_wip(22) => btw4x_5_9, 
                           output_wip(23) => btw4x_5_8, output_wip(24) => 
                           btw4x_5_7, output_wip(25) => btw4x_5_6, 
                           output_wip(26) => btw4x_5_5, output_wip(27) => 
                           btw4x_5_4, output_wip(28) => btw4x_5_3, 
                           output_wip(29) => btw4x_5_2, output_wip(30) => 
                           btw4x_5_1, output_wip(31) => btw4x_5_0);
   GF9 : gf_phi2_register_2 port map( reset => reset, phi2 => phi2, 
                           input_wip(0) => btw8x_9_31, input_wip(1) => 
                           btw8x_9_30, input_wip(2) => btw8x_9_29, input_wip(3)
                           => btw8x_9_28, input_wip(4) => btw8x_9_27, 
                           input_wip(5) => btw8x_9_26, input_wip(6) => 
                           btw8x_9_25, input_wip(7) => btw8x_9_24, input_wip(8)
                           => btw8x_9_23, input_wip(9) => btw8x_9_22, 
                           input_wip(10) => btw8x_9_21, input_wip(11) => 
                           btw8x_9_20, input_wip(12) => btw8x_9_19, 
                           input_wip(13) => btw8x_9_18, input_wip(14) => 
                           btw8x_9_17, input_wip(15) => btw8x_9_16, 
                           input_wip(16) => btw8x_9_15, input_wip(17) => 
                           btw8x_9_14, input_wip(18) => btw8x_9_13, 
                           input_wip(19) => btw8x_9_12, input_wip(20) => 
                           btw8x_9_11, input_wip(21) => btw8x_9_10, 
                           input_wip(22) => btw8x_9_9, input_wip(23) => 
                           btw8x_9_8, input_wip(24) => btw8x_9_7, input_wip(25)
                           => btw8x_9_6, input_wip(26) => btw8x_9_5, 
                           input_wip(27) => btw8x_9_4, input_wip(28) => 
                           btw8x_9_3, input_wip(29) => btw8x_9_2, input_wip(30)
                           => btw8x_9_1, input_wip(31) => btw8x_9_0, 
                           input_fcs(0) => btw8_9_31, input_fcs(1) => btw8_9_30
                           , input_fcs(2) => btw8_9_29, input_fcs(3) => 
                           btw8_9_28, input_fcs(4) => btw8_9_27, input_fcs(5) 
                           => btw8_9_26, input_fcs(6) => btw8_9_25, 
                           input_fcs(7) => btw8_9_24, input_fcs(8) => btw8_9_23
                           , input_fcs(9) => btw8_9_22, input_fcs(10) => 
                           btw8_9_21, input_fcs(11) => btw8_9_20, input_fcs(12)
                           => btw8_9_19, input_fcs(13) => btw8_9_18, 
                           input_fcs(14) => btw8_9_17, input_fcs(15) => 
                           btw8_9_16, input_fcs(16) => btw8_9_15, input_fcs(17)
                           => btw8_9_14, input_fcs(18) => btw8_9_13, 
                           input_fcs(19) => btw8_9_12, input_fcs(20) => 
                           btw8_9_11, input_fcs(21) => btw8_9_10, input_fcs(22)
                           => btw8_9_9, input_fcs(23) => btw8_9_8, 
                           input_fcs(24) => btw8_9_7, input_fcs(25) => btw8_9_6
                           , input_fcs(26) => btw8_9_5, input_fcs(27) => 
                           btw8_9_4, input_fcs(28) => btw8_9_3, input_fcs(29) 
                           => btw8_9_2, input_fcs(30) => btw8_9_1, 
                           input_fcs(31) => btw8_9_0, output_wip(0) => 
                           btw9_9x_31, output_wip(1) => btw9_9x_30, 
                           output_wip(2) => btw9_9x_29, output_wip(3) => 
                           btw9_9x_28, output_wip(4) => btw9_9x_27, 
                           output_wip(5) => btw9_9x_26, output_wip(6) => 
                           btw9_9x_25, output_wip(7) => btw9_9x_24, 
                           output_wip(8) => btw9_9x_23, output_wip(9) => 
                           btw9_9x_22, output_wip(10) => btw9_9x_21, 
                           output_wip(11) => btw9_9x_20, output_wip(12) => 
                           btw9_9x_19, output_wip(13) => btw9_9x_18, 
                           output_wip(14) => btw9_9x_17, output_wip(15) => 
                           btw9_9x_16, output_wip(16) => btw9_9x_15, 
                           output_wip(17) => btw9_9x_14, output_wip(18) => 
                           btw9_9x_13, output_wip(19) => btw9_9x_12, 
                           output_wip(20) => btw9_9x_11, output_wip(21) => 
                           btw9_9x_10, output_wip(22) => btw9_9x_9, 
                           output_wip(23) => btw9_9x_8, output_wip(24) => 
                           btw9_9x_7, output_wip(25) => btw9_9x_6, 
                           output_wip(26) => btw9_9x_5, output_wip(27) => 
                           btw9_9x_4, output_wip(28) => btw9_9x_3, 
                           output_wip(29) => btw9_9x_2, output_wip(30) => 
                           btw9_9x_1, output_wip(31) => btw9_9x_0, 
                           output_fcs(0) => btw9_10_31, output_fcs(1) => 
                           btw9_10_30, output_fcs(2) => btw9_10_29, 
                           output_fcs(3) => btw9_10_28, output_fcs(4) => 
                           btw9_10_27, output_fcs(5) => btw9_10_26, 
                           output_fcs(6) => btw9_10_25, output_fcs(7) => 
                           btw9_10_24, output_fcs(8) => btw9_10_23, 
                           output_fcs(9) => btw9_10_22, output_fcs(10) => 
                           btw9_10_21, output_fcs(11) => btw9_10_20, 
                           output_fcs(12) => btw9_10_19, output_fcs(13) => 
                           btw9_10_18, output_fcs(14) => btw9_10_17, 
                           output_fcs(15) => btw9_10_16, output_fcs(16) => 
                           btw9_10_15, output_fcs(17) => btw9_10_14, 
                           output_fcs(18) => btw9_10_13, output_fcs(19) => 
                           btw9_10_12, output_fcs(20) => btw9_10_11, 
                           output_fcs(21) => btw9_10_10, output_fcs(22) => 
                           btw9_10_9, output_fcs(23) => btw9_10_8, 
                           output_fcs(24) => btw9_10_7, output_fcs(25) => 
                           btw9_10_6, output_fcs(26) => btw9_10_5, 
                           output_fcs(27) => btw9_10_4, output_fcs(28) => 
                           btw9_10_3, output_fcs(29) => btw9_10_2, 
                           output_fcs(30) => btw9_10_1, output_fcs(31) => 
                           btw9_10_0);
   GF9x : gf_xor_9x port map( input_wip(0) => btw9_9x_31, input_wip(1) => 
                           btw9_9x_30, input_wip(2) => btw9_9x_29, input_wip(3)
                           => btw9_9x_28, input_wip(4) => btw9_9x_27, 
                           input_wip(5) => btw9_9x_26, input_wip(6) => 
                           btw9_9x_25, input_wip(7) => btw9_9x_24, input_wip(8)
                           => btw9_9x_23, input_wip(9) => btw9_9x_22, 
                           input_wip(10) => btw9_9x_21, input_wip(11) => 
                           btw9_9x_20, input_wip(12) => btw9_9x_19, 
                           input_wip(13) => btw9_9x_18, input_wip(14) => 
                           btw9_9x_17, input_wip(15) => btw9_9x_16, 
                           input_wip(16) => btw9_9x_15, input_wip(17) => 
                           btw9_9x_14, input_wip(18) => btw9_9x_13, 
                           input_wip(19) => btw9_9x_12, input_wip(20) => 
                           btw9_9x_11, input_wip(21) => btw9_9x_10, 
                           input_wip(22) => btw9_9x_9, input_wip(23) => 
                           btw9_9x_8, input_wip(24) => btw9_9x_7, input_wip(25)
                           => btw9_9x_6, input_wip(26) => btw9_9x_5, 
                           input_wip(27) => btw9_9x_4, input_wip(28) => 
                           btw9_9x_3, input_wip(29) => btw9_9x_2, input_wip(30)
                           => btw9_9x_1, input_wip(31) => btw9_9x_0, 
                           input_fcs(0) => btw9_10_31, input_fcs(1) => 
                           btw9_10_30, input_fcs(2) => btw9_10_29, input_fcs(3)
                           => btw9_10_28, input_fcs(4) => btw9_10_27, 
                           input_fcs(5) => btw9_10_26, input_fcs(6) => 
                           btw9_10_25, input_fcs(7) => btw9_10_24, input_fcs(8)
                           => btw9_10_23, input_fcs(9) => btw9_10_22, 
                           input_fcs(10) => btw9_10_21, input_fcs(11) => 
                           btw9_10_20, input_fcs(12) => btw9_10_19, 
                           input_fcs(13) => btw9_10_18, input_fcs(14) => 
                           btw9_10_17, input_fcs(15) => btw9_10_16, 
                           input_fcs(16) => btw9_10_15, input_fcs(17) => 
                           btw9_10_14, input_fcs(18) => btw9_10_13, 
                           input_fcs(19) => btw9_10_12, input_fcs(20) => 
                           btw9_10_11, input_fcs(21) => btw9_10_10, 
                           input_fcs(22) => btw9_10_9, input_fcs(23) => 
                           btw9_10_8, input_fcs(24) => btw9_10_7, input_fcs(25)
                           => btw9_10_6, input_fcs(26) => btw9_10_5, 
                           input_fcs(27) => btw9_10_4, input_fcs(28) => 
                           btw9_10_3, input_fcs(29) => btw9_10_2, input_fcs(30)
                           => btw9_10_1, input_fcs(31) => btw9_10_0, 
                           output_wip(0) => btw9x_10_31, output_wip(1) => 
                           btw9x_10_30, output_wip(2) => btw9x_10_29, 
                           output_wip(3) => btw9x_10_28, output_wip(4) => 
                           btw9x_10_27, output_wip(5) => btw9x_10_26, 
                           output_wip(6) => btw9x_10_25, output_wip(7) => 
                           btw9x_10_24, output_wip(8) => btw9x_10_23, 
                           output_wip(9) => btw9x_10_22, output_wip(10) => 
                           btw9x_10_21, output_wip(11) => btw9x_10_20, 
                           output_wip(12) => btw9x_10_19, output_wip(13) => 
                           btw9x_10_18, output_wip(14) => btw9x_10_17, 
                           output_wip(15) => btw9x_10_16, output_wip(16) => 
                           btw9x_10_15, output_wip(17) => btw9x_10_14, 
                           output_wip(18) => btw9x_10_13, output_wip(19) => 
                           btw9x_10_12, output_wip(20) => btw9x_10_11, 
                           output_wip(21) => btw9x_10_10, output_wip(22) => 
                           btw9x_10_9, output_wip(23) => btw9x_10_8, 
                           output_wip(24) => btw9x_10_7, output_wip(25) => 
                           btw9x_10_6, output_wip(26) => btw9x_10_5, 
                           output_wip(27) => btw9x_10_4, output_wip(28) => 
                           btw9x_10_3, output_wip(29) => btw9x_10_2, 
                           output_wip(30) => btw9x_10_1, output_wip(31) => 
                           btw9x_10_0);
   GF5x : gf_xor_5x port map( input_wip(0) => btw5_5x_31, input_wip(1) => 
                           btw5_5x_30, input_wip(2) => btw5_5x_29, input_wip(3)
                           => btw5_5x_28, input_wip(4) => btw5_5x_27, 
                           input_wip(5) => btw5_5x_26, input_wip(6) => 
                           btw5_5x_25, input_wip(7) => btw5_5x_24, input_wip(8)
                           => btw5_5x_23, input_wip(9) => btw5_5x_22, 
                           input_wip(10) => btw5_5x_21, input_wip(11) => 
                           btw5_5x_20, input_wip(12) => btw5_5x_19, 
                           input_wip(13) => btw5_5x_18, input_wip(14) => 
                           btw5_5x_17, input_wip(15) => btw5_5x_16, 
                           input_wip(16) => btw5_5x_15, input_wip(17) => 
                           btw5_5x_14, input_wip(18) => btw5_5x_13, 
                           input_wip(19) => btw5_5x_12, input_wip(20) => 
                           btw5_5x_11, input_wip(21) => btw5_5x_10, 
                           input_wip(22) => btw5_5x_9, input_wip(23) => 
                           btw5_5x_8, input_wip(24) => btw5_5x_7, input_wip(25)
                           => btw5_5x_6, input_wip(26) => btw5_5x_5, 
                           input_wip(27) => btw5_5x_4, input_wip(28) => 
                           btw5_5x_3, input_wip(29) => btw5_5x_2, input_wip(30)
                           => btw5_5x_1, input_wip(31) => btw5_5x_0, 
                           input_fcs(0) => btw5_6_31, input_fcs(1) => btw5_6_30
                           , input_fcs(2) => btw5_6_29, input_fcs(3) => 
                           btw5_6_28, input_fcs(4) => btw5_6_27, input_fcs(5) 
                           => btw5_6_26, input_fcs(6) => btw5_6_25, 
                           input_fcs(7) => btw5_6_24, input_fcs(8) => btw5_6_23
                           , input_fcs(9) => btw5_6_22, input_fcs(10) => 
                           btw5_6_21, input_fcs(11) => btw5_6_20, input_fcs(12)
                           => btw5_6_19, input_fcs(13) => btw5_6_18, 
                           input_fcs(14) => btw5_6_17, input_fcs(15) => 
                           btw5_6_16, input_fcs(16) => btw5_6_15, input_fcs(17)
                           => btw5_6_14, input_fcs(18) => btw5_6_13, 
                           input_fcs(19) => btw5_6_12, input_fcs(20) => 
                           btw5_6_11, input_fcs(21) => btw5_6_10, input_fcs(22)
                           => btw5_6_9, input_fcs(23) => btw5_6_8, 
                           input_fcs(24) => btw5_6_7, input_fcs(25) => btw5_6_6
                           , input_fcs(26) => btw5_6_5, input_fcs(27) => 
                           btw5_6_4, input_fcs(28) => btw5_6_3, input_fcs(29) 
                           => btw5_6_2, input_fcs(30) => btw5_6_1, 
                           input_fcs(31) => btw5_6_0, output_wip(0) => 
                           btw5x_6_31, output_wip(1) => btw5x_6_30, 
                           output_wip(2) => btw5x_6_29, output_wip(3) => 
                           btw5x_6_28, output_wip(4) => btw5x_6_27, 
                           output_wip(5) => btw5x_6_26, output_wip(6) => 
                           btw5x_6_25, output_wip(7) => btw5x_6_24, 
                           output_wip(8) => btw5x_6_23, output_wip(9) => 
                           btw5x_6_22, output_wip(10) => btw5x_6_21, 
                           output_wip(11) => btw5x_6_20, output_wip(12) => 
                           btw5x_6_19, output_wip(13) => btw5x_6_18, 
                           output_wip(14) => btw5x_6_17, output_wip(15) => 
                           btw5x_6_16, output_wip(16) => btw5x_6_15, 
                           output_wip(17) => btw5x_6_14, output_wip(18) => 
                           btw5x_6_13, output_wip(19) => btw5x_6_12, 
                           output_wip(20) => btw5x_6_11, output_wip(21) => 
                           btw5x_6_10, output_wip(22) => btw5x_6_9, 
                           output_wip(23) => btw5x_6_8, output_wip(24) => 
                           btw5x_6_7, output_wip(25) => btw5x_6_6, 
                           output_wip(26) => btw5x_6_5, output_wip(27) => 
                           btw5x_6_4, output_wip(28) => btw5x_6_3, 
                           output_wip(29) => btw5x_6_2, output_wip(30) => 
                           btw5x_6_1, output_wip(31) => btw5x_6_0);
   GF2 : gf_phi1_register_1 port map( reset => reset, phi1 => phi1, 
                           input_wip(0) => btw1x_2_31, input_wip(1) => 
                           btw1x_2_30, input_wip(2) => btw1x_2_29, input_wip(3)
                           => btw1x_2_28, input_wip(4) => btw1x_2_27, 
                           input_wip(5) => btw1x_2_26, input_wip(6) => 
                           btw1x_2_25, input_wip(7) => btw1x_2_24, input_wip(8)
                           => btw1x_2_23, input_wip(9) => btw1x_2_22, 
                           input_wip(10) => btw1x_2_21, input_wip(11) => 
                           btw1x_2_20, input_wip(12) => btw1x_2_19, 
                           input_wip(13) => btw1x_2_18, input_wip(14) => 
                           btw1x_2_17, input_wip(15) => btw1x_2_16, 
                           input_wip(16) => btw1x_2_15, input_wip(17) => 
                           btw1x_2_14, input_wip(18) => btw1x_2_13, 
                           input_wip(19) => btw1x_2_12, input_wip(20) => 
                           btw1x_2_11, input_wip(21) => btw1x_2_10, 
                           input_wip(22) => btw1x_2_9, input_wip(23) => 
                           btw1x_2_8, input_wip(24) => btw1x_2_7, input_wip(25)
                           => btw1x_2_6, input_wip(26) => btw1x_2_5, 
                           input_wip(27) => btw1x_2_4, input_wip(28) => 
                           btw1x_2_3, input_wip(29) => btw1x_2_2, input_wip(30)
                           => btw1x_2_1, input_wip(31) => btw1x_2_0, 
                           input_fcs(0) => input(0), input_fcs(1) => input(1), 
                           input_fcs(2) => input(2), input_fcs(3) => input(3), 
                           input_fcs(4) => input(4), input_fcs(5) => input(5), 
                           input_fcs(6) => input(6), input_fcs(7) => input(7), 
                           input_fcs(8) => input(8), input_fcs(9) => input(9), 
                           input_fcs(10) => input(10), input_fcs(11) => 
                           input(11), input_fcs(12) => input(12), input_fcs(13)
                           => input(13), input_fcs(14) => input(14), 
                           input_fcs(15) => input(15), input_fcs(16) => 
                           input(16), input_fcs(17) => input(17), input_fcs(18)
                           => input(18), input_fcs(19) => input(19), 
                           input_fcs(20) => input(20), input_fcs(21) => 
                           input(21), input_fcs(22) => input(22), input_fcs(23)
                           => input(23), input_fcs(24) => input(24), 
                           input_fcs(25) => input(25), input_fcs(26) => 
                           input(26), input_fcs(27) => input(27), input_fcs(28)
                           => input(28), input_fcs(29) => input(29), 
                           input_fcs(30) => input(30), input_fcs(31) => 
                           input(31), output_wip(0) => btw2_2x_31, 
                           output_wip(1) => btw2_2x_30, output_wip(2) => 
                           btw2_2x_29, output_wip(3) => btw2_2x_28, 
                           output_wip(4) => btw2_2x_27, output_wip(5) => 
                           btw2_2x_26, output_wip(6) => btw2_2x_25, 
                           output_wip(7) => btw2_2x_24, output_wip(8) => 
                           btw2_2x_23, output_wip(9) => btw2_2x_22, 
                           output_wip(10) => btw2_2x_21, output_wip(11) => 
                           btw2_2x_20, output_wip(12) => btw2_2x_19, 
                           output_wip(13) => btw2_2x_18, output_wip(14) => 
                           btw2_2x_17, output_wip(15) => btw2_2x_16, 
                           output_wip(16) => btw2_2x_15, output_wip(17) => 
                           btw2_2x_14, output_wip(18) => btw2_2x_13, 
                           output_wip(19) => btw2_2x_12, output_wip(20) => 
                           btw2_2x_11, output_wip(21) => btw2_2x_10, 
                           output_wip(22) => btw2_2x_9, output_wip(23) => 
                           btw2_2x_8, output_wip(24) => btw2_2x_7, 
                           output_wip(25) => btw2_2x_6, output_wip(26) => 
                           btw2_2x_5, output_wip(27) => btw2_2x_4, 
                           output_wip(28) => btw2_2x_3, output_wip(29) => 
                           btw2_2x_2, output_wip(30) => btw2_2x_1, 
                           output_wip(31) => btw2_2x_0, output_fcs(0) => 
                           btw2_3_31, output_fcs(1) => btw2_3_30, output_fcs(2)
                           => btw2_3_29, output_fcs(3) => btw2_3_28, 
                           output_fcs(4) => btw2_3_27, output_fcs(5) => 
                           btw2_3_26, output_fcs(6) => btw2_3_25, output_fcs(7)
                           => btw2_3_24, output_fcs(8) => btw2_3_23, 
                           output_fcs(9) => btw2_3_22, output_fcs(10) => 
                           btw2_3_21, output_fcs(11) => btw2_3_20, 
                           output_fcs(12) => btw2_3_19, output_fcs(13) => 
                           btw2_3_18, output_fcs(14) => btw2_3_17, 
                           output_fcs(15) => btw2_3_16, output_fcs(16) => 
                           btw2_3_15, output_fcs(17) => btw2_3_14, 
                           output_fcs(18) => btw2_3_13, output_fcs(19) => 
                           btw2_3_12, output_fcs(20) => btw2_3_11, 
                           output_fcs(21) => btw2_3_10, output_fcs(22) => 
                           btw2_3_9, output_fcs(23) => btw2_3_8, output_fcs(24)
                           => btw2_3_7, output_fcs(25) => btw2_3_6, 
                           output_fcs(26) => btw2_3_5, output_fcs(27) => 
                           btw2_3_4, output_fcs(28) => btw2_3_3, output_fcs(29)
                           => btw2_3_2, output_fcs(30) => btw2_3_1, 
                           output_fcs(31) => btw2_3_0);
   GF3 : gf_phi2_register_1 port map( reset => reset, phi2 => phi2, 
                           input_wip(0) => btw2x_3_31, input_wip(1) => 
                           btw2x_3_30, input_wip(2) => btw2x_3_29, input_wip(3)
                           => btw2x_3_28, input_wip(4) => btw2x_3_27, 
                           input_wip(5) => btw2x_3_26, input_wip(6) => 
                           btw2x_3_25, input_wip(7) => btw2x_3_24, input_wip(8)
                           => btw2x_3_23, input_wip(9) => btw2x_3_22, 
                           input_wip(10) => btw2x_3_21, input_wip(11) => 
                           btw2x_3_20, input_wip(12) => btw2x_3_19, 
                           input_wip(13) => btw2x_3_18, input_wip(14) => 
                           btw2x_3_17, input_wip(15) => btw2x_3_16, 
                           input_wip(16) => btw2x_3_15, input_wip(17) => 
                           btw2x_3_14, input_wip(18) => btw2x_3_13, 
                           input_wip(19) => btw2x_3_12, input_wip(20) => 
                           btw2x_3_11, input_wip(21) => btw2x_3_10, 
                           input_wip(22) => btw2x_3_9, input_wip(23) => 
                           btw2x_3_8, input_wip(24) => btw2x_3_7, input_wip(25)
                           => btw2x_3_6, input_wip(26) => btw2x_3_5, 
                           input_wip(27) => btw2x_3_4, input_wip(28) => 
                           btw2x_3_3, input_wip(29) => btw2x_3_2, input_wip(30)
                           => btw2x_3_1, input_wip(31) => btw2x_3_0, 
                           input_fcs(0) => btw2_3_31, input_fcs(1) => btw2_3_30
                           , input_fcs(2) => btw2_3_29, input_fcs(3) => 
                           btw2_3_28, input_fcs(4) => btw2_3_27, input_fcs(5) 
                           => btw2_3_26, input_fcs(6) => btw2_3_25, 
                           input_fcs(7) => btw2_3_24, input_fcs(8) => btw2_3_23
                           , input_fcs(9) => btw2_3_22, input_fcs(10) => 
                           btw2_3_21, input_fcs(11) => btw2_3_20, input_fcs(12)
                           => btw2_3_19, input_fcs(13) => btw2_3_18, 
                           input_fcs(14) => btw2_3_17, input_fcs(15) => 
                           btw2_3_16, input_fcs(16) => btw2_3_15, input_fcs(17)
                           => btw2_3_14, input_fcs(18) => btw2_3_13, 
                           input_fcs(19) => btw2_3_12, input_fcs(20) => 
                           btw2_3_11, input_fcs(21) => btw2_3_10, input_fcs(22)
                           => btw2_3_9, input_fcs(23) => btw2_3_8, 
                           input_fcs(24) => btw2_3_7, input_fcs(25) => btw2_3_6
                           , input_fcs(26) => btw2_3_5, input_fcs(27) => 
                           btw2_3_4, input_fcs(28) => btw2_3_3, input_fcs(29) 
                           => btw2_3_2, input_fcs(30) => btw2_3_1, 
                           input_fcs(31) => btw2_3_0, output_wip(0) => 
                           btw3_3x_31, output_wip(1) => btw3_3x_30, 
                           output_wip(2) => btw3_3x_29, output_wip(3) => 
                           btw3_3x_28, output_wip(4) => btw3_3x_27, 
                           output_wip(5) => btw3_3x_26, output_wip(6) => 
                           btw3_3x_25, output_wip(7) => btw3_3x_24, 
                           output_wip(8) => btw3_3x_23, output_wip(9) => 
                           btw3_3x_22, output_wip(10) => btw3_3x_21, 
                           output_wip(11) => btw3_3x_20, output_wip(12) => 
                           btw3_3x_19, output_wip(13) => btw3_3x_18, 
                           output_wip(14) => btw3_3x_17, output_wip(15) => 
                           btw3_3x_16, output_wip(16) => btw3_3x_15, 
                           output_wip(17) => btw3_3x_14, output_wip(18) => 
                           btw3_3x_13, output_wip(19) => btw3_3x_12, 
                           output_wip(20) => btw3_3x_11, output_wip(21) => 
                           btw3_3x_10, output_wip(22) => btw3_3x_9, 
                           output_wip(23) => btw3_3x_8, output_wip(24) => 
                           btw3_3x_7, output_wip(25) => btw3_3x_6, 
                           output_wip(26) => btw3_3x_5, output_wip(27) => 
                           btw3_3x_4, output_wip(28) => btw3_3x_3, 
                           output_wip(29) => btw3_3x_2, output_wip(30) => 
                           btw3_3x_1, output_wip(31) => btw3_3x_0, 
                           output_fcs(0) => btw3_4_31, output_fcs(1) => 
                           btw3_4_30, output_fcs(2) => btw3_4_29, output_fcs(3)
                           => btw3_4_28, output_fcs(4) => btw3_4_27, 
                           output_fcs(5) => btw3_4_26, output_fcs(6) => 
                           btw3_4_25, output_fcs(7) => btw3_4_24, output_fcs(8)
                           => btw3_4_23, output_fcs(9) => btw3_4_22, 
                           output_fcs(10) => btw3_4_21, output_fcs(11) => 
                           btw3_4_20, output_fcs(12) => btw3_4_19, 
                           output_fcs(13) => btw3_4_18, output_fcs(14) => 
                           btw3_4_17, output_fcs(15) => btw3_4_16, 
                           output_fcs(16) => btw3_4_15, output_fcs(17) => 
                           btw3_4_14, output_fcs(18) => btw3_4_13, 
                           output_fcs(19) => btw3_4_12, output_fcs(20) => 
                           btw3_4_11, output_fcs(21) => btw3_4_10, 
                           output_fcs(22) => btw3_4_9, output_fcs(23) => 
                           btw3_4_8, output_fcs(24) => btw3_4_7, output_fcs(25)
                           => btw3_4_6, output_fcs(26) => btw3_4_5, 
                           output_fcs(27) => btw3_4_4, output_fcs(28) => 
                           btw3_4_3, output_fcs(29) => btw3_4_2, output_fcs(30)
                           => btw3_4_1, output_fcs(31) => btw3_4_0);
   GF3x : gf_xor_3x port map( input_wip(0) => btw3_3x_31, input_wip(1) => 
                           btw3_3x_30, input_wip(2) => btw3_3x_29, input_wip(3)
                           => btw3_3x_28, input_wip(4) => btw3_3x_27, 
                           input_wip(5) => btw3_3x_26, input_wip(6) => 
                           btw3_3x_25, input_wip(7) => btw3_3x_24, input_wip(8)
                           => btw3_3x_23, input_wip(9) => btw3_3x_22, 
                           input_wip(10) => btw3_3x_21, input_wip(11) => 
                           btw3_3x_20, input_wip(12) => btw3_3x_19, 
                           input_wip(13) => btw3_3x_18, input_wip(14) => 
                           btw3_3x_17, input_wip(15) => btw3_3x_16, 
                           input_wip(16) => btw3_3x_15, input_wip(17) => 
                           btw3_3x_14, input_wip(18) => btw3_3x_13, 
                           input_wip(19) => btw3_3x_12, input_wip(20) => 
                           btw3_3x_11, input_wip(21) => btw3_3x_10, 
                           input_wip(22) => btw3_3x_9, input_wip(23) => 
                           btw3_3x_8, input_wip(24) => btw3_3x_7, input_wip(25)
                           => btw3_3x_6, input_wip(26) => btw3_3x_5, 
                           input_wip(27) => btw3_3x_4, input_wip(28) => 
                           btw3_3x_3, input_wip(29) => btw3_3x_2, input_wip(30)
                           => btw3_3x_1, input_wip(31) => btw3_3x_0, 
                           input_fcs(0) => btw3_4_31, input_fcs(1) => btw3_4_30
                           , input_fcs(2) => btw3_4_29, input_fcs(3) => 
                           btw3_4_28, input_fcs(4) => btw3_4_27, input_fcs(5) 
                           => btw3_4_26, input_fcs(6) => btw3_4_25, 
                           input_fcs(7) => btw3_4_24, input_fcs(8) => btw3_4_23
                           , input_fcs(9) => btw3_4_22, input_fcs(10) => 
                           btw3_4_21, input_fcs(11) => btw3_4_20, input_fcs(12)
                           => btw3_4_19, input_fcs(13) => btw3_4_18, 
                           input_fcs(14) => btw3_4_17, input_fcs(15) => 
                           btw3_4_16, input_fcs(16) => btw3_4_15, input_fcs(17)
                           => btw3_4_14, input_fcs(18) => btw3_4_13, 
                           input_fcs(19) => btw3_4_12, input_fcs(20) => 
                           btw3_4_11, input_fcs(21) => btw3_4_10, input_fcs(22)
                           => btw3_4_9, input_fcs(23) => btw3_4_8, 
                           input_fcs(24) => btw3_4_7, input_fcs(25) => btw3_4_6
                           , input_fcs(26) => btw3_4_5, input_fcs(27) => 
                           btw3_4_4, input_fcs(28) => btw3_4_3, input_fcs(29) 
                           => btw3_4_2, input_fcs(30) => btw3_4_1, 
                           input_fcs(31) => btw3_4_0, output_wip(0) => 
                           btw3x_4_31, output_wip(1) => btw3x_4_30, 
                           output_wip(2) => btw3x_4_29, output_wip(3) => 
                           btw3x_4_28, output_wip(4) => btw3x_4_27, 
                           output_wip(5) => btw3x_4_26, output_wip(6) => 
                           btw3x_4_25, output_wip(7) => btw3x_4_24, 
                           output_wip(8) => btw3x_4_23, output_wip(9) => 
                           btw3x_4_22, output_wip(10) => btw3x_4_21, 
                           output_wip(11) => btw3x_4_20, output_wip(12) => 
                           btw3x_4_19, output_wip(13) => btw3x_4_18, 
                           output_wip(14) => btw3x_4_17, output_wip(15) => 
                           btw3x_4_16, output_wip(16) => btw3x_4_15, 
                           output_wip(17) => btw3x_4_14, output_wip(18) => 
                           btw3x_4_13, output_wip(19) => btw3x_4_12, 
                           output_wip(20) => btw3x_4_11, output_wip(21) => 
                           btw3x_4_10, output_wip(22) => btw3x_4_9, 
                           output_wip(23) => btw3x_4_8, output_wip(24) => 
                           btw3x_4_7, output_wip(25) => btw3x_4_6, 
                           output_wip(26) => btw3x_4_5, output_wip(27) => 
                           btw3x_4_4, output_wip(28) => btw3x_4_3, 
                           output_wip(29) => btw3x_4_2, output_wip(30) => 
                           btw3x_4_1, output_wip(31) => btw3x_4_0);
   GF5 : gf_phi2_register_0 port map( reset => reset, phi2 => phi2, 
                           input_wip(0) => btw4x_5_31, input_wip(1) => 
                           btw4x_5_30, input_wip(2) => btw4x_5_29, input_wip(3)
                           => btw4x_5_28, input_wip(4) => btw4x_5_27, 
                           input_wip(5) => btw4x_5_26, input_wip(6) => 
                           btw4x_5_25, input_wip(7) => btw4x_5_24, input_wip(8)
                           => btw4x_5_23, input_wip(9) => btw4x_5_22, 
                           input_wip(10) => btw4x_5_21, input_wip(11) => 
                           btw4x_5_20, input_wip(12) => btw4x_5_19, 
                           input_wip(13) => btw4x_5_18, input_wip(14) => 
                           btw4x_5_17, input_wip(15) => btw4x_5_16, 
                           input_wip(16) => btw4x_5_15, input_wip(17) => 
                           btw4x_5_14, input_wip(18) => btw4x_5_13, 
                           input_wip(19) => btw4x_5_12, input_wip(20) => 
                           btw4x_5_11, input_wip(21) => btw4x_5_10, 
                           input_wip(22) => btw4x_5_9, input_wip(23) => 
                           btw4x_5_8, input_wip(24) => btw4x_5_7, input_wip(25)
                           => btw4x_5_6, input_wip(26) => btw4x_5_5, 
                           input_wip(27) => btw4x_5_4, input_wip(28) => 
                           btw4x_5_3, input_wip(29) => btw4x_5_2, input_wip(30)
                           => btw4x_5_1, input_wip(31) => btw4x_5_0, 
                           input_fcs(0) => btw4_5_31, input_fcs(1) => btw4_5_30
                           , input_fcs(2) => btw4_5_29, input_fcs(3) => 
                           btw4_5_28, input_fcs(4) => btw4_5_27, input_fcs(5) 
                           => btw4_5_26, input_fcs(6) => btw4_5_25, 
                           input_fcs(7) => btw4_5_24, input_fcs(8) => btw4_5_23
                           , input_fcs(9) => btw4_5_22, input_fcs(10) => 
                           btw4_5_21, input_fcs(11) => btw4_5_20, input_fcs(12)
                           => btw4_5_19, input_fcs(13) => btw4_5_18, 
                           input_fcs(14) => btw4_5_17, input_fcs(15) => 
                           btw4_5_16, input_fcs(16) => btw4_5_15, input_fcs(17)
                           => btw4_5_14, input_fcs(18) => btw4_5_13, 
                           input_fcs(19) => btw4_5_12, input_fcs(20) => 
                           btw4_5_11, input_fcs(21) => btw4_5_10, input_fcs(22)
                           => btw4_5_9, input_fcs(23) => btw4_5_8, 
                           input_fcs(24) => btw4_5_7, input_fcs(25) => btw4_5_6
                           , input_fcs(26) => btw4_5_5, input_fcs(27) => 
                           btw4_5_4, input_fcs(28) => btw4_5_3, input_fcs(29) 
                           => btw4_5_2, input_fcs(30) => btw4_5_1, 
                           input_fcs(31) => btw4_5_0, output_wip(0) => 
                           btw5_5x_31, output_wip(1) => btw5_5x_30, 
                           output_wip(2) => btw5_5x_29, output_wip(3) => 
                           btw5_5x_28, output_wip(4) => btw5_5x_27, 
                           output_wip(5) => btw5_5x_26, output_wip(6) => 
                           btw5_5x_25, output_wip(7) => btw5_5x_24, 
                           output_wip(8) => btw5_5x_23, output_wip(9) => 
                           btw5_5x_22, output_wip(10) => btw5_5x_21, 
                           output_wip(11) => btw5_5x_20, output_wip(12) => 
                           btw5_5x_19, output_wip(13) => btw5_5x_18, 
                           output_wip(14) => btw5_5x_17, output_wip(15) => 
                           btw5_5x_16, output_wip(16) => btw5_5x_15, 
                           output_wip(17) => btw5_5x_14, output_wip(18) => 
                           btw5_5x_13, output_wip(19) => btw5_5x_12, 
                           output_wip(20) => btw5_5x_11, output_wip(21) => 
                           btw5_5x_10, output_wip(22) => btw5_5x_9, 
                           output_wip(23) => btw5_5x_8, output_wip(24) => 
                           btw5_5x_7, output_wip(25) => btw5_5x_6, 
                           output_wip(26) => btw5_5x_5, output_wip(27) => 
                           btw5_5x_4, output_wip(28) => btw5_5x_3, 
                           output_wip(29) => btw5_5x_2, output_wip(30) => 
                           btw5_5x_1, output_wip(31) => btw5_5x_0, 
                           output_fcs(0) => btw5_6_31, output_fcs(1) => 
                           btw5_6_30, output_fcs(2) => btw5_6_29, output_fcs(3)
                           => btw5_6_28, output_fcs(4) => btw5_6_27, 
                           output_fcs(5) => btw5_6_26, output_fcs(6) => 
                           btw5_6_25, output_fcs(7) => btw5_6_24, output_fcs(8)
                           => btw5_6_23, output_fcs(9) => btw5_6_22, 
                           output_fcs(10) => btw5_6_21, output_fcs(11) => 
                           btw5_6_20, output_fcs(12) => btw5_6_19, 
                           output_fcs(13) => btw5_6_18, output_fcs(14) => 
                           btw5_6_17, output_fcs(15) => btw5_6_16, 
                           output_fcs(16) => btw5_6_15, output_fcs(17) => 
                           btw5_6_14, output_fcs(18) => btw5_6_13, 
                           output_fcs(19) => btw5_6_12, output_fcs(20) => 
                           btw5_6_11, output_fcs(21) => btw5_6_10, 
                           output_fcs(22) => btw5_6_9, output_fcs(23) => 
                           btw5_6_8, output_fcs(24) => btw5_6_7, output_fcs(25)
                           => btw5_6_6, output_fcs(26) => btw5_6_5, 
                           output_fcs(27) => btw5_6_4, output_fcs(28) => 
                           btw5_6_3, output_fcs(29) => btw5_6_2, output_fcs(30)
                           => btw5_6_1, output_fcs(31) => btw5_6_0);
   GF8x : gf_xor_8x port map( input_wip(0) => btw8_8x_31, input_wip(1) => 
                           btw8_8x_30, input_wip(2) => btw8_8x_29, input_wip(3)
                           => btw8_8x_28, input_wip(4) => btw8_8x_27, 
                           input_wip(5) => btw8_8x_26, input_wip(6) => 
                           btw8_8x_25, input_wip(7) => btw8_8x_24, input_wip(8)
                           => btw8_8x_23, input_wip(9) => btw8_8x_22, 
                           input_wip(10) => btw8_8x_21, input_wip(11) => 
                           btw8_8x_20, input_wip(12) => btw8_8x_19, 
                           input_wip(13) => btw8_8x_18, input_wip(14) => 
                           btw8_8x_17, input_wip(15) => btw8_8x_16, 
                           input_wip(16) => btw8_8x_15, input_wip(17) => 
                           btw8_8x_14, input_wip(18) => btw8_8x_13, 
                           input_wip(19) => btw8_8x_12, input_wip(20) => 
                           btw8_8x_11, input_wip(21) => btw8_8x_10, 
                           input_wip(22) => btw8_8x_9, input_wip(23) => 
                           btw8_8x_8, input_wip(24) => btw8_8x_7, input_wip(25)
                           => btw8_8x_6, input_wip(26) => btw8_8x_5, 
                           input_wip(27) => btw8_8x_4, input_wip(28) => 
                           btw8_8x_3, input_wip(29) => btw8_8x_2, input_wip(30)
                           => btw8_8x_1, input_wip(31) => btw8_8x_0, 
                           input_fcs(0) => btw8_9_31, input_fcs(1) => btw8_9_30
                           , input_fcs(2) => btw8_9_29, input_fcs(3) => 
                           btw8_9_28, input_fcs(4) => btw8_9_27, input_fcs(5) 
                           => btw8_9_26, input_fcs(6) => btw8_9_25, 
                           input_fcs(7) => btw8_9_24, input_fcs(8) => btw8_9_23
                           , input_fcs(9) => btw8_9_22, input_fcs(10) => 
                           btw8_9_21, input_fcs(11) => btw8_9_20, input_fcs(12)
                           => btw8_9_19, input_fcs(13) => btw8_9_18, 
                           input_fcs(14) => btw8_9_17, input_fcs(15) => 
                           btw8_9_16, input_fcs(16) => btw8_9_15, input_fcs(17)
                           => btw8_9_14, input_fcs(18) => btw8_9_13, 
                           input_fcs(19) => btw8_9_12, input_fcs(20) => 
                           btw8_9_11, input_fcs(21) => btw8_9_10, input_fcs(22)
                           => btw8_9_9, input_fcs(23) => btw8_9_8, 
                           input_fcs(24) => btw8_9_7, input_fcs(25) => btw8_9_6
                           , input_fcs(26) => btw8_9_5, input_fcs(27) => 
                           btw8_9_4, input_fcs(28) => btw8_9_3, input_fcs(29) 
                           => btw8_9_2, input_fcs(30) => btw8_9_1, 
                           input_fcs(31) => btw8_9_0, output_wip(0) => 
                           btw8x_9_31, output_wip(1) => btw8x_9_30, 
                           output_wip(2) => btw8x_9_29, output_wip(3) => 
                           btw8x_9_28, output_wip(4) => btw8x_9_27, 
                           output_wip(5) => btw8x_9_26, output_wip(6) => 
                           btw8x_9_25, output_wip(7) => btw8x_9_24, 
                           output_wip(8) => btw8x_9_23, output_wip(9) => 
                           btw8x_9_22, output_wip(10) => btw8x_9_21, 
                           output_wip(11) => btw8x_9_20, output_wip(12) => 
                           btw8x_9_19, output_wip(13) => btw8x_9_18, 
                           output_wip(14) => btw8x_9_17, output_wip(15) => 
                           btw8x_9_16, output_wip(16) => btw8x_9_15, 
                           output_wip(17) => btw8x_9_14, output_wip(18) => 
                           btw8x_9_13, output_wip(19) => btw8x_9_12, 
                           output_wip(20) => btw8x_9_11, output_wip(21) => 
                           btw8x_9_10, output_wip(22) => btw8x_9_9, 
                           output_wip(23) => btw8x_9_8, output_wip(24) => 
                           btw8x_9_7, output_wip(25) => btw8x_9_6, 
                           output_wip(26) => btw8x_9_5, output_wip(27) => 
                           btw8x_9_4, output_wip(28) => btw8x_9_3, 
                           output_wip(29) => btw8x_9_2, output_wip(30) => 
                           btw8x_9_1, output_wip(31) => btw8x_9_0);
   GF4 : gf_phi1_register_0 port map( reset => reset, phi1 => phi1, 
                           input_wip(0) => btw3x_4_31, input_wip(1) => 
                           btw3x_4_30, input_wip(2) => btw3x_4_29, input_wip(3)
                           => btw3x_4_28, input_wip(4) => btw3x_4_27, 
                           input_wip(5) => btw3x_4_26, input_wip(6) => 
                           btw3x_4_25, input_wip(7) => btw3x_4_24, input_wip(8)
                           => btw3x_4_23, input_wip(9) => btw3x_4_22, 
                           input_wip(10) => btw3x_4_21, input_wip(11) => 
                           btw3x_4_20, input_wip(12) => btw3x_4_19, 
                           input_wip(13) => btw3x_4_18, input_wip(14) => 
                           btw3x_4_17, input_wip(15) => btw3x_4_16, 
                           input_wip(16) => btw3x_4_15, input_wip(17) => 
                           btw3x_4_14, input_wip(18) => btw3x_4_13, 
                           input_wip(19) => btw3x_4_12, input_wip(20) => 
                           btw3x_4_11, input_wip(21) => btw3x_4_10, 
                           input_wip(22) => btw3x_4_9, input_wip(23) => 
                           btw3x_4_8, input_wip(24) => btw3x_4_7, input_wip(25)
                           => btw3x_4_6, input_wip(26) => btw3x_4_5, 
                           input_wip(27) => btw3x_4_4, input_wip(28) => 
                           btw3x_4_3, input_wip(29) => btw3x_4_2, input_wip(30)
                           => btw3x_4_1, input_wip(31) => btw3x_4_0, 
                           input_fcs(0) => btw3_4_31, input_fcs(1) => btw3_4_30
                           , input_fcs(2) => btw3_4_29, input_fcs(3) => 
                           btw3_4_28, input_fcs(4) => btw3_4_27, input_fcs(5) 
                           => btw3_4_26, input_fcs(6) => btw3_4_25, 
                           input_fcs(7) => btw3_4_24, input_fcs(8) => btw3_4_23
                           , input_fcs(9) => btw3_4_22, input_fcs(10) => 
                           btw3_4_21, input_fcs(11) => btw3_4_20, input_fcs(12)
                           => btw3_4_19, input_fcs(13) => btw3_4_18, 
                           input_fcs(14) => btw3_4_17, input_fcs(15) => 
                           btw3_4_16, input_fcs(16) => btw3_4_15, input_fcs(17)
                           => btw3_4_14, input_fcs(18) => btw3_4_13, 
                           input_fcs(19) => btw3_4_12, input_fcs(20) => 
                           btw3_4_11, input_fcs(21) => btw3_4_10, input_fcs(22)
                           => btw3_4_9, input_fcs(23) => btw3_4_8, 
                           input_fcs(24) => btw3_4_7, input_fcs(25) => btw3_4_6
                           , input_fcs(26) => btw3_4_5, input_fcs(27) => 
                           btw3_4_4, input_fcs(28) => btw3_4_3, input_fcs(29) 
                           => btw3_4_2, input_fcs(30) => btw3_4_1, 
                           input_fcs(31) => btw3_4_0, output_wip(0) => 
                           btw4_4x_31, output_wip(1) => btw4_4x_30, 
                           output_wip(2) => btw4_4x_29, output_wip(3) => 
                           btw4_4x_28, output_wip(4) => btw4_4x_27, 
                           output_wip(5) => btw4_4x_26, output_wip(6) => 
                           btw4_4x_25, output_wip(7) => btw4_4x_24, 
                           output_wip(8) => btw4_4x_23, output_wip(9) => 
                           btw4_4x_22, output_wip(10) => btw4_4x_21, 
                           output_wip(11) => btw4_4x_20, output_wip(12) => 
                           btw4_4x_19, output_wip(13) => btw4_4x_18, 
                           output_wip(14) => btw4_4x_17, output_wip(15) => 
                           btw4_4x_16, output_wip(16) => btw4_4x_15, 
                           output_wip(17) => btw4_4x_14, output_wip(18) => 
                           btw4_4x_13, output_wip(19) => btw4_4x_12, 
                           output_wip(20) => btw4_4x_11, output_wip(21) => 
                           btw4_4x_10, output_wip(22) => btw4_4x_9, 
                           output_wip(23) => btw4_4x_8, output_wip(24) => 
                           btw4_4x_7, output_wip(25) => btw4_4x_6, 
                           output_wip(26) => btw4_4x_5, output_wip(27) => 
                           btw4_4x_4, output_wip(28) => btw4_4x_3, 
                           output_wip(29) => btw4_4x_2, output_wip(30) => 
                           btw4_4x_1, output_wip(31) => btw4_4x_0, 
                           output_fcs(0) => btw4_5_31, output_fcs(1) => 
                           btw4_5_30, output_fcs(2) => btw4_5_29, output_fcs(3)
                           => btw4_5_28, output_fcs(4) => btw4_5_27, 
                           output_fcs(5) => btw4_5_26, output_fcs(6) => 
                           btw4_5_25, output_fcs(7) => btw4_5_24, output_fcs(8)
                           => btw4_5_23, output_fcs(9) => btw4_5_22, 
                           output_fcs(10) => btw4_5_21, output_fcs(11) => 
                           btw4_5_20, output_fcs(12) => btw4_5_19, 
                           output_fcs(13) => btw4_5_18, output_fcs(14) => 
                           btw4_5_17, output_fcs(15) => btw4_5_16, 
                           output_fcs(16) => btw4_5_15, output_fcs(17) => 
                           btw4_5_14, output_fcs(18) => btw4_5_13, 
                           output_fcs(19) => btw4_5_12, output_fcs(20) => 
                           btw4_5_11, output_fcs(21) => btw4_5_10, 
                           output_fcs(22) => btw4_5_9, output_fcs(23) => 
                           btw4_5_8, output_fcs(24) => btw4_5_7, output_fcs(25)
                           => btw4_5_6, output_fcs(26) => btw4_5_5, 
                           output_fcs(27) => btw4_5_4, output_fcs(28) => 
                           btw4_5_3, output_fcs(29) => btw4_5_2, output_fcs(30)
                           => btw4_5_1, output_fcs(31) => btw4_5_0);
   GF7x : gf_xor_7x port map( input_wip(0) => btw7_7x_31, input_wip(1) => 
                           btw7_7x_30, input_wip(2) => btw7_7x_29, input_wip(3)
                           => btw7_7x_28, input_wip(4) => btw7_7x_27, 
                           input_wip(5) => btw7_7x_26, input_wip(6) => 
                           btw7_7x_25, input_wip(7) => btw7_7x_24, input_wip(8)
                           => btw7_7x_23, input_wip(9) => btw7_7x_22, 
                           input_wip(10) => btw7_7x_21, input_wip(11) => 
                           btw7_7x_20, input_wip(12) => btw7_7x_19, 
                           input_wip(13) => btw7_7x_18, input_wip(14) => 
                           btw7_7x_17, input_wip(15) => btw7_7x_16, 
                           input_wip(16) => btw7_7x_15, input_wip(17) => 
                           btw7_7x_14, input_wip(18) => btw7_7x_13, 
                           input_wip(19) => btw7_7x_12, input_wip(20) => 
                           btw7_7x_11, input_wip(21) => btw7_7x_10, 
                           input_wip(22) => btw7_7x_9, input_wip(23) => 
                           btw7_7x_8, input_wip(24) => btw7_7x_7, input_wip(25)
                           => btw7_7x_6, input_wip(26) => btw7_7x_5, 
                           input_wip(27) => btw7_7x_4, input_wip(28) => 
                           btw7_7x_3, input_wip(29) => btw7_7x_2, input_wip(30)
                           => btw7_7x_1, input_wip(31) => btw7_7x_0, 
                           input_fcs(0) => btw7_8_31, input_fcs(1) => btw7_8_30
                           , input_fcs(2) => btw7_8_29, input_fcs(3) => 
                           btw7_8_28, input_fcs(4) => btw7_8_27, input_fcs(5) 
                           => btw7_8_26, input_fcs(6) => btw7_8_25, 
                           input_fcs(7) => btw7_8_24, input_fcs(8) => btw7_8_23
                           , input_fcs(9) => btw7_8_22, input_fcs(10) => 
                           btw7_8_21, input_fcs(11) => btw7_8_20, input_fcs(12)
                           => btw7_8_19, input_fcs(13) => btw7_8_18, 
                           input_fcs(14) => btw7_8_17, input_fcs(15) => 
                           btw7_8_16, input_fcs(16) => btw7_8_15, input_fcs(17)
                           => btw7_8_14, input_fcs(18) => btw7_8_13, 
                           input_fcs(19) => btw7_8_12, input_fcs(20) => 
                           btw7_8_11, input_fcs(21) => btw7_8_10, input_fcs(22)
                           => btw7_8_9, input_fcs(23) => btw7_8_8, 
                           input_fcs(24) => btw7_8_7, input_fcs(25) => btw7_8_6
                           , input_fcs(26) => btw7_8_5, input_fcs(27) => 
                           btw7_8_4, input_fcs(28) => btw7_8_3, input_fcs(29) 
                           => btw7_8_2, input_fcs(30) => btw7_8_1, 
                           input_fcs(31) => btw7_8_0, output_wip(0) => 
                           btw7x_8_31, output_wip(1) => btw7x_8_30, 
                           output_wip(2) => btw7x_8_29, output_wip(3) => 
                           btw7x_8_28, output_wip(4) => btw7x_8_27, 
                           output_wip(5) => btw7x_8_26, output_wip(6) => 
                           btw7x_8_25, output_wip(7) => btw7x_8_24, 
                           output_wip(8) => btw7x_8_23, output_wip(9) => 
                           btw7x_8_22, output_wip(10) => btw7x_8_21, 
                           output_wip(11) => btw7x_8_20, output_wip(12) => 
                           btw7x_8_19, output_wip(13) => btw7x_8_18, 
                           output_wip(14) => btw7x_8_17, output_wip(15) => 
                           btw7x_8_16, output_wip(16) => btw7x_8_15, 
                           output_wip(17) => btw7x_8_14, output_wip(18) => 
                           btw7x_8_13, output_wip(19) => btw7x_8_12, 
                           output_wip(20) => btw7x_8_11, output_wip(21) => 
                           btw7x_8_10, output_wip(22) => btw7x_8_9, 
                           output_wip(23) => btw7x_8_8, output_wip(24) => 
                           btw7x_8_7, output_wip(25) => btw7x_8_6, 
                           output_wip(26) => btw7x_8_5, output_wip(27) => 
                           btw7x_8_4, output_wip(28) => btw7x_8_3, 
                           output_wip(29) => btw7x_8_2, output_wip(30) => 
                           btw7x_8_1, output_wip(31) => btw7x_8_0);
   GF10 : gf_phi1_register_out port map( reset => reset, phi1 => phi1, 
                           input_wip(0) => btw9x_10_31, input_wip(1) => 
                           btw9x_10_30, input_wip(2) => btw9x_10_29, 
                           input_wip(3) => btw9x_10_28, input_wip(4) => 
                           btw9x_10_27, input_wip(5) => btw9x_10_26, 
                           input_wip(6) => btw9x_10_25, input_wip(7) => 
                           btw9x_10_24, input_wip(8) => btw9x_10_23, 
                           input_wip(9) => btw9x_10_22, input_wip(10) => 
                           btw9x_10_21, input_wip(11) => btw9x_10_20, 
                           input_wip(12) => btw9x_10_19, input_wip(13) => 
                           btw9x_10_18, input_wip(14) => btw9x_10_17, 
                           input_wip(15) => btw9x_10_16, input_wip(16) => 
                           btw9x_10_15, input_wip(17) => btw9x_10_14, 
                           input_wip(18) => btw9x_10_13, input_wip(19) => 
                           btw9x_10_12, input_wip(20) => btw9x_10_11, 
                           input_wip(21) => btw9x_10_10, input_wip(22) => 
                           btw9x_10_9, input_wip(23) => btw9x_10_8, 
                           input_wip(24) => btw9x_10_7, input_wip(25) => 
                           btw9x_10_6, input_wip(26) => btw9x_10_5, 
                           input_wip(27) => btw9x_10_4, input_wip(28) => 
                           btw9x_10_3, input_wip(29) => btw9x_10_2, 
                           input_wip(30) => btw9x_10_1, input_wip(31) => 
                           btw9x_10_0, output_final(0) => output_fcs(0), 
                           output_final(1) => output_fcs(1), output_final(2) =>
                           output_fcs(2), output_final(3) => output_fcs(3), 
                           output_final(4) => output_fcs(4), output_final(5) =>
                           output_fcs(5), output_final(6) => output_fcs(6), 
                           output_final(7) => output_fcs(7), output_final(8) =>
                           output_fcs(8), output_final(9) => output_fcs(9), 
                           output_final(10) => output_fcs(10), output_final(11)
                           => output_fcs(11), output_final(12) => 
                           output_fcs(12), output_final(13) => output_fcs(13), 
                           output_final(14) => output_fcs(14), output_final(15)
                           => output_fcs(15), output_final(16) => output_xor(0)
                           , output_final(17) => output_xor(1), 
                           output_final(18) => output_xor(2), output_final(19) 
                           => output_xor(3), output_final(20) => output_xor(4),
                           output_final(21) => output_xor(5), output_final(22) 
                           => output_xor(6), output_final(23) => output_xor(7),
                           output_final(24) => output_xor(8), output_final(25) 
                           => output_xor(9), output_final(26) => output_xor(10)
                           , output_final(27) => output_xor(11), 
                           output_final(28) => output_xor(12), output_final(29)
                           => output_xor(13), output_final(30) => 
                           output_xor(14), output_final(31) => output_xor(15));

end SYN_structural_architecture2;

library IEEE;
library csx_HRDLIB;
library csx_IOLIB_3M;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use csx_HRDLIB.Vcomponents.all;
use csx_IOLIB_3M.Vcomponents.all;

entity big_xor is

   port( reset, phi2 : in std_logic;  input_input, fcs_input, gf_input : in 
         std_logic_vector (0 to 15);  output : out std_logic_vector (0 to 31));

end big_xor;

architecture SYN_behavior_architecture of big_xor is

   component DFA2
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component DFA
      port( C, D : in std_logic;  Q, QN : out std_logic;  RN : in std_logic);
   end component;
   
   component DF9
      port( C, D : in std_logic;  Q, QN : out std_logic;  SN : in std_logic);
   end component;
   
   component DF92
      port( C, D : in std_logic;  Q, QN : out std_logic;  SN : in std_logic);
   end component;
   
   component BU4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component BU2
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN4
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component IN8
      port( A : in std_logic;  Q : out std_logic);
   end component;
   
   component EO1
      port( A, B : in std_logic;  Q : out std_logic);
   end component;
   
   signal output_xor_15, output_xor_12, output_xor_9, output_xor_7, 
      output_xor_0, output_xor_14, output_xor_13, output_xor_8, output_xor_6, 
      output_xor_1, output_xor_11, output_xor_10, output_xor_5, output_xor_4, 
      output_xor_3, output_xor_2, n77, n78, n79, n81, n83, n85, n87, n89, n91, 
      n161, n162, n163, n164, n165, n166, n167, n168, n169, n170, n171, n172, 
      n173, n174, n175, n176, n177, n178, n179, n180, n181, n182, n183, n184, 
      n185, n186, n187, n188, n189, n190, n191, n192 : std_logic;

begin
   
   output_reg_31 : DFA2 port map( C => phi2, D => fcs_input(0), Q => n161, QN 
                           => n91, RN => n78);
   output_reg_20 : DFA port map( C => phi2, D => fcs_input(11), Q => output(11)
                           , QN => n162, RN => n78);
   output_reg_21 : DF9 port map( C => phi2, D => fcs_input(10), Q => output(10)
                           , QN => n163, SN => n78);
   output_reg_16 : DF92 port map( C => phi2, D => fcs_input(15), Q => 
                           output(15), QN => n164, SN => n78);
   output_reg_18 : DF92 port map( C => phi2, D => fcs_input(13), Q => 
                           output(13), QN => n165, SN => n78);
   output_reg_19 : DF92 port map( C => phi2, D => fcs_input(12), Q => 
                           output(12), QN => n166, SN => n78);
   output_reg_17 : DF92 port map( C => phi2, D => fcs_input(14), Q => 
                           output(14), QN => n167, SN => n78);
   U49 : BU4 port map( A => n77, Q => n78);
   U50 : BU2 port map( A => reset, Q => n77);
   U51 : IN4 port map( A => n79, Q => output(9));
   U52 : IN8 port map( A => n89, Q => output(3));
   U53 : IN8 port map( A => n83, Q => output(5));
   U54 : IN8 port map( A => n87, Q => output(2));
   U55 : IN8 port map( A => n81, Q => output(1));
   output_reg_3 : DF9 port map( C => phi2, D => output_xor_3, Q => output(28), 
                           QN => n168, SN => n78);
   output_reg_13 : DF9 port map( C => phi2, D => output_xor_13, Q => output(18)
                           , QN => n169, SN => n78);
   output_reg_14 : DF9 port map( C => phi2, D => output_xor_14, Q => output(17)
                           , QN => n170, SN => n78);
   output_reg_0 : DF9 port map( C => phi2, D => output_xor_0, Q => output(31), 
                           QN => n171, SN => n78);
   output_reg_10 : DF9 port map( C => phi2, D => output_xor_10, Q => output(21)
                           , QN => n172, SN => n78);
   output_reg_6 : DF9 port map( C => phi2, D => output_xor_6, Q => output(25), 
                           QN => n173, SN => n78);
   output_reg_15 : DFA port map( C => phi2, D => output_xor_15, Q => output(16)
                           , QN => n174, RN => n78);
   output_reg_12 : DFA port map( C => phi2, D => output_xor_12, Q => output(19)
                           , QN => n175, RN => n78);
   output_reg_4 : DFA port map( C => phi2, D => output_xor_4, Q => output(27), 
                           QN => n176, RN => n78);
   output_reg_5 : DFA port map( C => phi2, D => output_xor_5, Q => output(26), 
                           QN => n177, RN => n78);
   output_reg_2 : DFA port map( C => phi2, D => output_xor_2, Q => output(29), 
                           QN => n178, RN => n78);
   output_reg_9 : DFA port map( C => phi2, D => output_xor_9, Q => output(22), 
                           QN => n179, RN => n78);
   output_reg_11 : DFA port map( C => phi2, D => output_xor_11, Q => output(20)
                           , QN => n180, RN => n78);
   output_reg_7 : DFA port map( C => phi2, D => output_xor_7, Q => output(24), 
                           QN => n181, RN => n78);
   output_reg_1 : DFA port map( C => phi2, D => output_xor_1, Q => output(30), 
                           QN => n182, RN => n78);
   output_reg_8 : DFA port map( C => phi2, D => output_xor_8, Q => output(23), 
                           QN => n183, RN => n78);
   U56 : EO1 port map( A => gf_input(3), B => input_input(3), Q => 
                           output_xor_12);
   U57 : EO1 port map( A => gf_input(0), B => input_input(0), Q => 
                           output_xor_15);
   U58 : EO1 port map( A => gf_input(11), B => input_input(11), Q => 
                           output_xor_4);
   U59 : EO1 port map( A => gf_input(10), B => input_input(10), Q => 
                           output_xor_5);
   U60 : EO1 port map( A => gf_input(13), B => input_input(13), Q => 
                           output_xor_2);
   U61 : EO1 port map( A => gf_input(6), B => input_input(6), Q => output_xor_9
                           );
   U62 : EO1 port map( A => gf_input(4), B => input_input(4), Q => 
                           output_xor_11);
   U63 : EO1 port map( A => gf_input(8), B => input_input(8), Q => output_xor_7
                           );
   U64 : EO1 port map( A => gf_input(14), B => input_input(14), Q => 
                           output_xor_1);
   U65 : EO1 port map( A => gf_input(7), B => input_input(7), Q => output_xor_8
                           );
   U66 : EO1 port map( A => gf_input(12), B => input_input(12), Q => 
                           output_xor_3);
   U67 : EO1 port map( A => gf_input(2), B => input_input(2), Q => 
                           output_xor_13);
   U68 : EO1 port map( A => gf_input(1), B => input_input(1), Q => 
                           output_xor_14);
   U69 : EO1 port map( A => gf_input(15), B => input_input(15), Q => 
                           output_xor_0);
   U70 : EO1 port map( A => gf_input(5), B => input_input(5), Q => 
                           output_xor_10);
   U71 : EO1 port map( A => gf_input(9), B => input_input(9), Q => output_xor_6
                           );
   output_reg_30 : DF92 port map( C => phi2, D => fcs_input(1), Q => n184, QN 
                           => n81, SN => n78);
   output_reg_26 : DF92 port map( C => phi2, D => fcs_input(5), Q => n185, QN 
                           => n83, SN => n78);
   U72 : IN4 port map( A => n85, Q => output(4));
   output_reg_28 : DFA2 port map( C => phi2, D => fcs_input(3), Q => n186, QN 
                           => n89, RN => n78);
   output_reg_29 : DFA2 port map( C => phi2, D => fcs_input(2), Q => n187, QN 
                           => n87, RN => n78);
   U73 : IN8 port map( A => n91, Q => output(0));
   output_reg_23 : DF92 port map( C => phi2, D => fcs_input(8), Q => output(8),
                           QN => n188, SN => n78);
   output_reg_25 : DF92 port map( C => phi2, D => fcs_input(6), Q => output(6),
                           QN => n189, SN => n78);
   output_reg_22 : DFA2 port map( C => phi2, D => fcs_input(9), Q => n190, QN 
                           => n79, RN => n78);
   output_reg_24 : DFA2 port map( C => phi2, D => fcs_input(7), Q => output(7),
                           QN => n191, RN => n78);
   output_reg_27 : DFA2 port map( C => phi2, D => fcs_input(4), Q => n192, QN 
                           => n85, RN => n78);

end SYN_behavior_architecture;
