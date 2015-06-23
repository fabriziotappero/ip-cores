------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 15.06.2004 19:03:50
-- File                 : Mux2to1.vhd
-- Design               : VHDL Entity Mux2to1.rtl
------------------------------------------------------------------------------
-- Description  : Generic 2->1 multiplexer
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY Mux2to1 IS
   GENERIC( 
      dataw_g : integer := 16
   );
   PORT( 
      in0     : IN     std_logic_vector (dataw_g-1 DOWNTO 0);
      in1     : IN     std_logic_vector (dataw_g-1 DOWNTO 0);
      sel     : IN     std_logic;
      mux_out : OUT    std_logic_vector (dataw_g-1 DOWNTO 0)
   );

-- Declarations

END Mux2to1 ;

--
ARCHITECTURE rtl OF Mux2to1 IS
BEGIN
  -- purpose: selects input
  -- type   : combinational
  -- inputs : sel, in0, in1
  -- outputs: 
  selector : PROCESS (sel, in0, in1)
  BEGIN  -- PROCESS selector
    IF (sel = '0') THEN
      mux_out <= in0;
    ELSE
      mux_out <= in1;
    END IF;
  END PROCESS selector;
END rtl;

