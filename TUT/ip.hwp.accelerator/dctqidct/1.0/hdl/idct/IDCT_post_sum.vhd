------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 21.06.2004 13:10:10
-- File                 : IDCT_post_sum.vhd
-- Design               : VHDL Entity IDCT_post_sum.rtl
------------------------------------------------------------------------------
-- Description  : Y0=X0+X4
--                Y1=X1+X5
--                Y2=X2+X6
--                Y3=X3+X7
--                Y7=X0-X4
--                Y6=X1-X5
--                Y5=X2-X6
--                Y4=X3-X7
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
LIBRARY idct;
USE idct.IDCT_pkg.ALL;

ENTITY IDCT_post_sum IS
   PORT( 
      post_sum_in  : IN     std_logic_vector (8*IDCT_dataw_co-1 DOWNTO 0);
      post_sum_out : OUT    std_logic_vector (8*IDCT_dataw_co-1 DOWNTO 0)
   );

-- Declarations

END IDCT_post_sum ;

--
ARCHITECTURE rtl OF IDCT_post_sum IS
BEGIN

  post_sum_out(1*IDCT_dataw_co-1 DOWNTO 0*IDCT_dataw_co)
 <= conv_std_logic_vector(signed(post_sum_in(1*IDCT_dataw_co-1 DOWNTO 0*IDCT_dataw_co)) +
                             signed(post_sum_in(5*IDCT_dataw_co-1 DOWNTO 4*IDCT_dataw_co)), IDCT_dataw_co);
  
  post_sum_out(2*IDCT_dataw_co-1 DOWNTO 1*IDCT_dataw_co)
 <= conv_std_logic_vector(signed(post_sum_in(2*IDCT_dataw_co-1 DOWNTO 1*IDCT_dataw_co)) +
                             signed(post_sum_in(6*IDCT_dataw_co-1 DOWNTO 5*IDCT_dataw_co)), IDCT_dataw_co);
  
  post_sum_out(3*IDCT_dataw_co-1 DOWNTO 2*IDCT_dataw_co)
 <= conv_std_logic_vector(signed(post_sum_in(3*IDCT_dataw_co-1 DOWNTO 2*IDCT_dataw_co)) +
                             signed(post_sum_in(7*IDCT_dataw_co-1 DOWNTO 6*IDCT_dataw_co)), IDCT_dataw_co);
  
  post_sum_out(4*IDCT_dataw_co-1 DOWNTO 3*IDCT_dataw_co)
 <= conv_std_logic_vector(signed(post_sum_in(4*IDCT_dataw_co-1 DOWNTO 3*IDCT_dataw_co)) +
                             signed(post_sum_in(8*IDCT_dataw_co-1 DOWNTO 7*IDCT_dataw_co)), IDCT_dataw_co);
  
  post_sum_out(8*IDCT_dataw_co-1 DOWNTO 7*IDCT_dataw_co)
 <= conv_std_logic_vector(signed(post_sum_in(1*IDCT_dataw_co-1 DOWNTO 0*IDCT_dataw_co)) -
                             signed(post_sum_in(5*IDCT_dataw_co-1 DOWNTO 4*IDCT_dataw_co)), IDCT_dataw_co);
  
  post_sum_out(7*IDCT_dataw_co-1 DOWNTO 6*IDCT_dataw_co)
 <= conv_std_logic_vector(signed(post_sum_in(2*IDCT_dataw_co-1 DOWNTO 1*IDCT_dataw_co)) -
                             signed(post_sum_in(6*IDCT_dataw_co-1 DOWNTO 5*IDCT_dataw_co)), IDCT_dataw_co);
  
  post_sum_out(6*IDCT_dataw_co-1 DOWNTO 5*IDCT_dataw_co)
 <= conv_std_logic_vector(signed(post_sum_in(3*IDCT_dataw_co-1 DOWNTO 2*IDCT_dataw_co)) -
                             signed(post_sum_in(7*IDCT_dataw_co-1 DOWNTO 6*IDCT_dataw_co)), IDCT_dataw_co);
  
  post_sum_out(5*IDCT_dataw_co-1 DOWNTO 4*IDCT_dataw_co)
 <= conv_std_logic_vector(signed(post_sum_in(4*IDCT_dataw_co-1 DOWNTO 3*IDCT_dataw_co)) -
                             signed(post_sum_in(8*IDCT_dataw_co-1 DOWNTO 7*IDCT_dataw_co)), IDCT_dataw_co);
  


  
END rtl;

