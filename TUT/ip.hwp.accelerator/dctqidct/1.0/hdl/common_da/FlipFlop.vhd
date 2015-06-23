------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 22.07.2004 10:00:00
-- File                 : FlipFlop.vhd
-- Design               : VHDL Entity common_da.FlipFlop.rtl
------------------------------------------------------------------------------
-- Description  : Generic Flipflop
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY FlipFlop IS
   GENERIC( 
      dataw_g : INTEGER := 16
   );
   PORT( 
      clk   : IN     std_logic;
      d_in  : IN     std_logic_vector (dataw_g-1 DOWNTO 0);
      rst_n : IN     std_logic;
      d_out : OUT    std_logic_vector (dataw_g-1 DOWNTO 0)
   );

-- Declarations

END FlipFlop ;

--
ARCHITECTURE rtl OF FlipFlop IS
  SIGNAL data_r : std_logic_vector(dataw_g-1 DOWNTO 0);
BEGIN

  clocked       : PROCESS (clk, rst_n)
  BEGIN  -- PROCESS clocked
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      data_r <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN  -- rising clock edge
      data_r <= d_in;
    END IF;
  END PROCESS clocked;

  d_out <= data_r;
END rtl;

