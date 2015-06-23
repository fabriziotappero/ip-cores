library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm is
  generic( counter_factor : NATURAL := 4*1e8-1; --4s period for the joystick
--sample with 100Mhz, it means that you need 4s to get from 0 to max pwm signal
--wisth
           pwm_period : NATURAL := 1e5-1;  --1ms period for the pwm signal with 100MHz,
           pwm_steps_factor : NATURAL := 500-1;  --500 steps for one pwm
--period to vary the width
           j_sample_factor : NATURAL := 8e5-1;--((counter_factor+1)/(pwm_steps_factor+1)-1);
           pwm_period_factor : NATURAL := 200-1 );--((pwm_period+1)/(pwm_steps_factor+1)-1) );
  port( clk, rst : in std_logic;
        j_left, j_right : IN std_logic; 
        led : out std_logic_vector (7 downto 0) );
end pwm;


architecture behavioral of pwm is
  SIGNAL pwm_variable_s : NATURAL RANGE 0 TO pwm_steps_factor := 0;
begin

joystick: process(clk)
  VARIABLE j_count : NATURAL RANGE 0 TO j_sample_factor := 0;
  VARIABLE pwm_variable : NATURAL RANGE 0 TO pwm_steps_factor  := 0;
BEGIN
    if clk'EVENT AND clk='1' then
      IF rst='0' THEN
        pwm_variable := 256;
        j_count := 0;
      ELSE
        if j_count>=j_sample_factor then
          j_count := 0;
          if j_left='0' AND pwm_variable>0 THEN  --with j_left increase the
--positive part of the period
            pwm_variable := pwm_variable - 1;
          elsif j_right='0' AND pwm_variable<pwm_steps_factor THEN  --width
--j_right increase the zero part of the period
            pwm_variable := pwm_variable + 1;
          END if;
        else
          j_count := j_count + 1;
        END if;
      END if;
    END if;
    pwm_variable_s <= pwm_variable;     --holds the period width, measured in steps
END process;

pwm_signal: process(clk)
  VARIABLE pwm_count : NATURAL RANGE 0 TO pwm_period_factor := 0;
  VARIABLE pwm_int : NATURAL RANGE 0 TO pwm_steps_factor := 0;
BEGIN
  if clk'EVENT AND clk='1' THEN
    IF rst='0' THEN
      pwm_count := 0;
      pwm_int := 0;
    else
      if pwm_count>=pwm_period_factor THEN  --detect one pwm step
        pwm_count := 0;
        IF pwm_int>=pwm_steps_factor THEN  --start new period
          pwm_int := 0;
          IF pwm_variable_s=0 THEN      --with 1 if we have 100% duty cicle
            led <= (OTHERS => '1');
          ELSE
            led <= (OTHERS => '0');     
          END IF;
        ELSE
          if pwm_int>=pwm_variable_s THEN  --start the positive part of the period
            pwm_int := pwm_int + 1;
            led <= (OTHERS => '1');
          ELSE
            pwm_int := pwm_int + 1; --stay in the zero part of the period
            led <= (OTHERS => '0');
          END if;
        END if;
      ELSE
        pwm_count := pwm_count + 1;
      END if;
    END if;
  END if;
END process;    
  
END behavioral;
