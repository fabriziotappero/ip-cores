------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 14.06.2004 14:39:16
-- File                 : Rom_dct_sum.vhd
-- Design               : 
------------------------------------------------------------------------------
-- Description  : Pre-calculated DCT-coefficients for sum terms.
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY Rom_dct_sum IS
   GENERIC( 
      coeffw_g : integer := 14
   );
   PORT( 
      addr_in  : IN     std_logic_vector (3 DOWNTO 0);
      clk      : IN     std_logic;
      data_out : OUT    std_logic_vector (4*coeffw_g-1 DOWNTO 0)
   );

-- Declarations

END Rom_dct_sum ;

--
ARCHITECTURE rtl OF Rom_dct_sum IS
  TYPE Rom16x4x15 IS ARRAY (0 TO 15) OF signed(15*4-1 DOWNTO 0);
  CONSTANT ROM_SUM : Rom16x4x15 := (
    conv_signed(0, 15) & conv_signed(0, 15) & conv_signed(0, 15) & conv_signed(0, 15),
    conv_signed(4096, 15) & conv_signed(5352, 15) & conv_signed(4096, 15) & conv_signed(2217, 15),
    conv_signed(4096, 15) & conv_signed(2217, 15) & conv_signed(-4096, 15) & conv_signed(-5352, 15),
    conv_signed(8192, 15) & conv_signed(7568, 15) & conv_signed(0, 15) & conv_signed(-3135, 15),
    conv_signed(4096, 15) & conv_signed(-2217, 15) & conv_signed(-4096, 15) & conv_signed(5352, 15),
    conv_signed(8192, 15) & conv_signed(3135, 15) & conv_signed(0, 15) & conv_signed(7568, 15),
    conv_signed(8192, 15) & conv_signed(0, 15) & conv_signed(-8192, 15) & conv_signed(0, 15),
    conv_signed(12288, 15) & conv_signed(5352, 15) & conv_signed(-4096, 15) & conv_signed(2217, 15),
    conv_signed(4096, 15) & conv_signed(-5352, 15) & conv_signed(4096, 15) & conv_signed(-2217, 15),
    conv_signed(8192, 15) & conv_signed(0, 15) & conv_signed(8192, 15) & conv_signed(0, 15),
    conv_signed(8192, 15) & conv_signed(-3135, 15) & conv_signed(0, 15) & conv_signed(-7568, 15),
    conv_signed(12288, 15) & conv_signed(2217, 15) & conv_signed(4096, 15) & conv_signed(-5352, 15),
    conv_signed(8192, 15) & conv_signed(-7568, 15) & conv_signed(0, 15) & conv_signed(3135, 15),
    conv_signed(12288, 15) & conv_signed(-2217, 15) & conv_signed(4096, 15) & conv_signed(5352, 15),
    conv_signed(12288, 15) & conv_signed(-5352, 15) & conv_signed(-4096, 15) & conv_signed(-2217, 15),
    conv_signed(16383, 15) & conv_signed(0, 15) & conv_signed(0, 15) & conv_signed(0, 15));

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
    data_out <= conv_std_logic_vector(ROM_SUM(address), 4*coeffw_g);
  END PROCESS access_rom;

END rtl;

