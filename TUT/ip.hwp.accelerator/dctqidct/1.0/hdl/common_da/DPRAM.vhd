------------------------------------------------------------------------------
-- TUT / DCS
------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 15.06.2004 16:52:53
-- File                 : DPRAM.vhd
-- Design               : VHDL Entity DPRAM.trl
------------------------------------------------------------------------------
-- Description  : Dualport ram
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY DPRAM IS
   GENERIC( 
      dataw_g : integer := 18;
      addrw_g : integer := 5
   );
   PORT( 
      clk     : IN     std_logic;
      d_in    : IN     std_logic_vector (dataw_g-1 DOWNTO 0);  --input data
      rdaddr  : IN     std_logic_vector (addrw_g-1 DOWNTO 0);  --read address
      we      : IN     std_logic;                              -- write enable
      wraddr  : IN     std_logic_vector (addrw_g-1 DOWNTO 0);  --write address
      ram_out : OUT    std_logic_vector (dataw_g-1 DOWNTO 0)   --output data
   );

-- Declarations

END DPRAM ;

--
ARCHITECTURE rtl OF DPRAM IS
  TYPE mw_I0ram_type IS ARRAY (((2**addrw_g) -1) DOWNTO 0)
    OF std_logic_vector(dataw_g-1 DOWNTO 0);
  SIGNAL mw_I0ram_table : mw_I0ram_type; -- := (OTHERS => (OTHERS => '0'));

BEGIN

  I0write : PROCESS (clk)
  BEGIN
    IF (clk'event AND clk = '1') THEN
      IF (we = '1' OR we = 'H') THEN
        mw_I0ram_table(CONV_INTEGER(unsigned(wraddr))) <= d_in;
      END IF;
    END IF;
  END PROCESS I0write;

  I0read : PROCESS (clk)
  BEGIN
    IF (clk'event AND clk = '1') THEN
      ram_out <= mw_I0ram_table(CONV_INTEGER(unsigned(rdaddr)));
    END IF;
  END PROCESS I0read;

END rtl;

