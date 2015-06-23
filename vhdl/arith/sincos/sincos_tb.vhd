
--------------------------------------------------------------------------------
-- (c) 2005.. Hoffmann RF & DSP  opencores@hoffmann-hochfrequenz.de
-- V1.0 published under BSD license
-- V1.1 2010-feb-25 added tests for combined sine and cosine module
--------------------------------------------------------------------------------
-- file name:      sincos_tb.vhd
-- tool version:   Modelsim 6.1, 6.5
-- description:    test bed for portable sine table
-- calls libs:     ieee standard
-- calls entities: clk_rst, 
--                 sincostab, sintab, 
--                 unsigned_pipestage, 
--                 sl_pipestage
--------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.un_signed_sprt.all;

entity sincos_tb is begin end sincos_tb;


architecture rtl of sincos_tb is

signal   verbose:           boolean := true;


constant theta_bits:        integer := 8;
constant amplitude_bits:    integer := 8;

constant pipestages:        integer :=0;

constant clock_frequency:   real := 100.0e6;
signal   clk:               std_logic;
signal   rst:               std_logic;

signal   ce:                std_logic := '1';

signal   theta:             unsigned(theta_bits - 1 downto 0) := (others => '0');
signal   y:                 signed(amplitude_bits - 1 downto 0);
signal   o_sin:             signed(amplitude_bits - 1 downto 0);
signal   o_cos:             signed(amplitude_bits - 1 downto 0);

signal   f_y, f_sin, f_cos: real;

signal   del_rst:           std_logic;   -- delayed inputs for result checking
signal   del_theta:         unsigned(theta_bits - 1 downto 0);

signal   ErrorInLsb_y:      real;
signal   WorstError_y:      real := 0.0;

signal   ErrorInLsb_o_sin:  real;
signal   WorstError_o_sin:  real := 0.0;

signal   ErrorInLsb_o_cos:  real;
signal   WorstError_o_cos:  real := 0.0;

signal   log_on:            std_logic;



-- In a system with 8 bit signed sines, the computed value should be -127....+127
-- The error should be less than 0.5, because otherwise a different value would be closer.



function compute_sin_error (verbose: boolean; theta: unsigned; result: signed) return real is

  variable scalefactor:     real := real((2 ** (result'length-1)-1));
  variable r_theta:         real;  -- the given phase 0...2pi
  variable TrueSine:        real;  -- the true sine value
  variable computed:        real;  -- result computed by the table
  variable ErrorInLsb:      real; 
  
begin

      r_theta      := 2.0* Math_pi * (real(to_integer(theta))+ 0.5) / (2.0 ** theta'length);
      TrueSine     := sin(r_theta) * scalefactor;
      
      computed     := real(to_integer(result));
      ErrorInLsb   := TrueSine - computed;
      if verbose 
      then
        report 
               "theta = "         & integer'image(to_integer(theta))
             & "  r_theta = "     & real'image(r_theta)
             & "  exact = "       & real'image(TrueSine)
             & "  computed = "    & real'image(computed)
             & "  error LSB = "   & real'image(ErrorInLsb)
             ;
      end if; --verbose
      return ErrorInLsb;
      
end function compute_sin_error;



function compute_cos_error (verbose: boolean; theta: unsigned; result: signed) return real is

  variable scalefactor:     real := real((2 ** (result'length-1)-1));
  variable r_theta:         real;     -- the given phase 0...2pi
  variable TrueCos:         real;     -- the true cosine value
  variable computed:        real;     -- result computed by the table
  variable ErrorInLsb:      real; 
  
begin

      r_theta      := 2.0* Math_pi * (real(to_integer(theta))+ 0.5) / (2.0 ** theta'length);
      TrueCos      := cos(r_theta) * scalefactor;
      
      computed     := real(to_integer(result));
      ErrorInLsb   := TrueCos - computed;
      if verbose 
      then
        report 
               "theta = "         & integer'image(to_integer(theta))
             & "  r_theta = "     & real'image(r_theta)
             & "  exact = "       & real'image(TrueCos)
             & "  computed = "    & real'image(computed)
             & "  error LSB = "   & real'image(ErrorInLsb)
             ;
      end if; --verbose
      return ErrorInLsb;
      
end function compute_cos_error;


----------------------------------------------------------------------------------------------------

BEGIN
   

u_clk_rst: entity work.clk_rst
  generic map(
    verbose         => false,
    clock_frequency => clock_frequency,
    min_resetwidth  => 46 ns
  )
  port map (
    clk             => clk,
    rst             => rst
  );


u_sin: entity work.sintab   -- convert phase to sine
  generic map (
     pipestages => pipestages  
  )
  port map (
    clk         => clk,
    ce          => ce,
    rst         => rst,

    theta       => theta,
    sine        => y
  );  



u_sincos: entity work.sincostab   -- convert phase to sine and cosine
  generic map (
     pipestages => pipestages  
  )
  port map (
    clk         => clk,
    ce          => ce,
    rst         => rst,

    theta       => theta,
    sine        => o_sin,
    cosine      => o_cos
  );  


--------------------------------------------------------------------------------
-- delay the input of the sinetable for result checking
-- and keep track when the first valid results should arrive.


u_delphase:	entity work.unsigned_pipestage
generic map (
  n_stages	=> pipestages
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => theta,
  o   => del_theta
);


u_delrst:	entity work.sl_pipestage
generic map (
  n_stages	=> pipestages
)
Port map ( 
  clk => clk,
  ce  => ce,
  rst => rst,
  
  i   => rst,
  o   => del_rst
);


--------------------------------------------------------------------------------

u_stimulus: process(clk) is begin
  if rising_edge(clk) then
    if rst = '1' then
      theta    <= (others => '0');
    elsif ce = '1' then
      theta    <= theta + 1;    -- phase accumulator
    end if;
  end if;
end process;


--------------------------------------------------------------------------------
-- check the output side of the sine module against the expected values.
-- This tests not only the table ROM but also address mirrorring,
-- output inversion and pipelining.



u_worst_sin: process(clk) is  
begin
  if rising_edge(clk) 
  then
  
    ErrorInLsb_y     <=  compute_sin_error (verbose, del_theta, y); 
    ErrorInLsb_o_sin <=  compute_sin_error (verbose, del_theta, o_sin); 
    ErrorInLsb_o_cos <=  compute_cos_error (verbose, del_theta, o_cos);

    if (ce = '1') and (del_rst = '0') then
                  
     if abs(ErrorInLsb_y) > WorstError_y then 
          WorstError_y <= abs(ErrorInLsb_y);
      end if;
      
      if abs(ErrorInLsb_o_sin) > WorstError_o_sin then 
          WorstError_o_sin <= abs(ErrorInLsb_o_sin);
      end if;
      
      if abs(ErrorInLsb_o_cos) > WorstError_o_cos then 
          WorstError_o_cos <= abs(ErrorInLsb_o_cos);
      end if;     
      
      if verbose 
      then
        report 
          "  worst error upto now for y = "       
          & real'image(WorstError_y)
          & "   for o_sin = "       
          & real'image(WorstError_o_sin)
          & "   for o_cos = "       
          & real'image(WorstError_o_cos)
          ;
      end if; --verbose
    end if; -- ce, del_rst
  end if; -- rising_edge()
end process;



-- log the generated sines and cosine to files so we can inspect them with matlab
log_on <= not del_rst;


-- convert amplitudes to floating point in -1.0 to 0.9999 range
-- from package work.un_signed_sprt

f_y   <= fract_signed2real(y);     
f_sin <= fract_signed2real(o_sin);
f_cos <= fract_signed2real(o_cos);


u_log_y: entity work.real_file_log 
   port map ( 
      clk      => clk,
      ce       => ce,
      filename => "logged_y.m",
      log_on   => log_on,
      d        => f_y
   ); 


u_log_sin: entity work.real_file_log 
   port map ( 
      clk      => clk,
      ce       => ce,
      filename => "logged_sin.m",
      log_on   => log_on,
      d        => f_sin
   ); 


u_log_cos: entity work.real_file_log 
   port map ( 
      clk      => clk,
      ce       => ce,
      filename => "logged_cos.m",
      log_on   => log_on,
      d        => f_cos
   ); 



END ARCHITECTURE rtl;
