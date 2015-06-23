------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 21.06.2004 11:33:04
-- File                 : Rom_idct_odd.vhd
-- Design               : VHDL Entity Rom_idct_odd.rtl
------------------------------------------------------------------------------
-- Description  : Pre-calculated 1D-IDCT coefficients for odd-half of idct
-- kernel 
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY Rom_idct_odd IS
   GENERIC( 
      coeffw_g : integer := 14
   );
   PORT( 
      addr_in  : IN     std_logic_vector (3 DOWNTO 0);
      clk      : IN     std_logic;
      data_out : OUT    std_logic_vector (4*coeffw_g-1 DOWNTO 0)
   );

-- Declarations

END Rom_idct_odd ;

--
ARCHITECTURE rtl OF Rom_idct_odd IS
  TYPE Rom16x4x15 IS ARRAY (0 TO 15) OF signed(15*4-1 DOWNTO 0);
  CONSTANT ROM_IDCT_ODD : Rom16x4x15 := (
    conv_signed(0, 15) & conv_signed(0, 15) & conv_signed(0, 15) & conv_signed(0, 15),
    conv_signed(4096, 15) & conv_signed(4096, 15) & conv_signed(4096, 15) & conv_signed(4096, 15),
    conv_signed(5352, 15) & conv_signed(2217, 15) & conv_signed(-2217, 15) & conv_signed(-5352, 15),
    conv_signed(9448, 15) & conv_signed(6313, 15) & conv_signed(1879, 15) & conv_signed(-1256, 15),
    conv_signed(4096, 15) & conv_signed(-4096, 15) & conv_signed(-4096, 15) & conv_signed(4096, 15),
    conv_signed(8192, 15) & conv_signed(0, 15) & conv_signed(0, 15) & conv_signed(8192, 15),
    conv_signed(9448, 15) & conv_signed(-1879, 15) & conv_signed(-6313, 15) & conv_signed(-1256, 15),
    conv_signed(13544, 15) & conv_signed(2217, 15) & conv_signed(-2217, 15) & conv_signed(2840, 15),
    conv_signed(2217, 15) & conv_signed(-5352, 15) & conv_signed(5352, 15) & conv_signed(-2217, 15),
    conv_signed(6313, 15) & conv_signed(-1256, 15) & conv_signed(9448, 15) & conv_signed(1879, 15),
    conv_signed(7568, 15) & conv_signed(-3135, 15) & conv_signed(3135, 15) & conv_signed(-7568, 15),
    conv_signed(11664, 15) & conv_signed(961, 15) & conv_signed(7231, 15) & conv_signed(-3472, 15),
    conv_signed(6313, 15) & conv_signed(-9448, 15) & conv_signed(1256, 15) & conv_signed(1879, 15),
    conv_signed(10409, 15) & conv_signed(-5352, 15) & conv_signed(5352, 15) & conv_signed(5975, 15),
    conv_signed(11664, 15) & conv_signed(-7231, 15) & conv_signed(-961, 15) & conv_signed(-3472, 15),
    conv_signed(15760, 15) & conv_signed(-3135, 15) & conv_signed(3135, 15) & conv_signed(624, 15));

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
    data_out <= conv_std_logic_vector(ROM_IDCT_ODD(address), 4*coeffw_g);
  END PROCESS access_rom;

END rtl;



