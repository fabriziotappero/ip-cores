------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 15.06.2004 19:00:37
-- File                 : Column_to_elements.vhd
-- Design               : VHDL Entity Column_to_elements.rtl
------------------------------------------------------------------------------
-- Description  : Parallel to serial converter.
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY Column_to_elements IS
   GENERIC( 
      dataw_g : integer := 18
   );
   PORT( 
      clk       : IN     std_logic;
      --enable shifting:
      --if '1' one value is shifted to output
      clk_en    : IN     std_logic;
      --parallel input (8 * (dataw_g-1 downto 0))
      column_in : IN     std_logic_vector (8*dataw_g-1 DOWNTO 0);
      --if '1' parallel input is loaded into shiftregister
      load      : IN     std_logic;
      rst_n     : IN     std_logic;
      --serial output
      d_out     : OUT    std_logic_vector (dataw_g-1 DOWNTO 0)
   );

-- Declarations

END Column_to_elements ;

--
ARCHITECTURE rtl OF Column_to_elements IS
  SIGNAL shiftreg_r : std_logic_vector(8*dataw_g-1 DOWNTO 0);
BEGIN

  -- purpose: loads and shifts
  -- type   : sequential
  -- inputs : clk, rst_n
  -- outputs: 
  clocked      : PROCESS (clk, rst_n)
    VARIABLE i : integer;
  BEGIN  -- PROCESS clocked
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      shiftreg_r <= (OTHERS => '0');

    ELSIF clk'event AND clk = '1' THEN  -- rising clock edge
      IF (load = '1') THEN
        shiftreg_r <= column_in;

      ELSIF (clk_en = '1') THEN
        FOR i IN 0 TO 6 LOOP
          shiftreg_r((i+1)*dataw_g-1 DOWNTO i*dataw_g) <= shiftreg_r((i+2)*dataw_g-1 DOWNTO (i+1)*dataw_g);
        END LOOP;  -- i

      ELSE
        shiftreg_r <= shiftreg_r;
      END IF;
    END IF;
  END PROCESS clocked;

  d_out <= shiftreg_r(dataw_g-1 DOWNTO 0);
END rtl;

