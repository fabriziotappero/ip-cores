------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 21.06.2004 11:30:18
-- File                 : Rom_idct_even.vhd
-- Design               : VHDL Entity Rom_idct_even.rtl
------------------------------------------------------------------------------
-- Description  : Pre-calculated 1D-IDCT coefficients for even-half of idct
-- kernel 
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY Rom_idct_even IS
   GENERIC( 
      coeffw_g : integer := 14
   );
   PORT( 
      addr_in  : IN     std_logic_vector (3 DOWNTO 0);
      clk      : IN     std_logic;
      data_out : OUT    std_logic_vector (4*coeffw_g-1 DOWNTO 0)
   );

-- Declarations

END Rom_idct_even ;

--
ARCHITECTURE rtl OF Rom_idct_even IS
  TYPE Rom16x4x15 IS ARRAY (0 TO 15) OF signed(15*4-1 DOWNTO 0);
  CONSTANT ROM_IDCT_EVEN : Rom16x4x15 := (
    conv_signed(0, 15) & conv_signed(0, 15) & conv_signed(0, 15) & conv_signed(0, 15),
    conv_signed(5681, 15) & conv_signed(4816, 15) & conv_signed(3218, 15) & conv_signed(1130, 15),
    conv_signed(4816, 15) & conv_signed(-1130, 15) & conv_signed(-5681, 15) & conv_signed(-3218, 15),
    conv_signed(10498, 15) & conv_signed(3686, 15) & conv_signed(-2463, 15) & conv_signed(-2088, 15),
    conv_signed(3218, 15) & conv_signed(-5681, 15) & conv_signed(1130, 15) & conv_signed(4816, 15),
    conv_signed(8900, 15) & conv_signed(-865, 15) & conv_signed(4348, 15) & conv_signed(5946, 15),
    conv_signed(8035, 15) & conv_signed(-6811, 15) & conv_signed(-4551, 15) & conv_signed(1598, 15),
    conv_signed(13716, 15) & conv_signed(-1995, 15) & conv_signed(-1333, 15) & conv_signed(2728, 15),
    conv_signed(1130, 15) & conv_signed(-3218, 15) & conv_signed(4816, 15) & conv_signed(-5681, 15),
    conv_signed(6811, 15) & conv_signed(1598, 15) & conv_signed(8035, 15) & conv_signed(-4551, 15),
    conv_signed(5946, 15) & conv_signed(-4348, 15) & conv_signed(-865, 15) & conv_signed(-8900, 15),
    conv_signed(11628, 15) & conv_signed(468, 15) & conv_signed(2353, 15) & conv_signed(-7769, 15),
    conv_signed(4348, 15) & conv_signed(-8900, 15) & conv_signed(5946, 15) & conv_signed(-865, 15),
    conv_signed(10030, 15) & conv_signed(-4083, 15) & conv_signed(9165, 15) & conv_signed(265, 15),
    conv_signed(9165, 15) & conv_signed(-10030, 15) & conv_signed(265, 15) & conv_signed(-4083, 15),
    conv_signed(14846, 15) & conv_signed(-5213, 15) & conv_signed(3483, 15) & conv_signed(-2953, 15));

  SIGNAL addr_r : std_logic_vector(3 DOWNTO 0);
BEGIN

  clocked : PROCESS (clk)
  BEGIN  -- PROCESS clocked
    IF clk'event AND clk = '1' THEN     -- rising clock edge
      addr_r <= addr_in;
    END IF;
  END PROCESS clocked;

  access_rom         : PROCESS (addr_r)
    VARIABLE address : integer;
  BEGIN
    address := conv_integer(unsigned(addr_r));
    data_out <= conv_std_logic_vector(ROM_IDCT_EVEN(address), 4*coeffw_g);
  END PROCESS access_rom;

END rtl;

