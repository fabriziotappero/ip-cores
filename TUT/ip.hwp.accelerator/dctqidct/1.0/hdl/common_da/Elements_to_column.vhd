------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 15.06.2004 18:53:38
-- File                 : Elements_to_column.vhd
-- Design               : VHDL Entity DCT_RC_DA.Elements_to_column.rtl
------------------------------------------------------------------------------
-- Description  : Serial to parallel converter.
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY Elements_to_column IS
   GENERIC( 
      dataw_g : integer := 18
   );
   PORT( 
      clk        : IN     std_logic;
      --serial input
      d_in       : IN     std_logic_vector (dataw_g-1 DOWNTO 0);
      --'1' serial input is loaded into shiftregister
      load       : IN     std_logic;
      rst_n      : IN     std_logic;
      --parallel output
      column_out : OUT    std_logic_vector (8*dataw_g-1 DOWNTO 0)
   );

-- Declarations

END Elements_to_column ;

--
ARCHITECTURE rtl OF Elements_to_column IS
  SIGNAL shiftreg_r : std_logic_vector(8*dataw_g-1 DOWNTO 0);
BEGIN

  -- purpose: loads and shifts data
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
        FOR i IN 0 TO 6 LOOP
          shiftreg_r((i+1)*dataw_g-1 DOWNTO i*dataw_g) <= shiftreg_r((i+2)*dataw_g-1 DOWNTO (i+1)*dataw_g);
        END LOOP;  -- i

        shiftreg_r(8*dataw_g-1 DOWNTO 7*dataw_g) <= d_in;
      END IF;
    END IF;
  END PROCESS clocked;

  column_out <= shiftreg_r;
END rtl;

