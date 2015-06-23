------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 14.06.2004 14:00:59
-- File                 : Parallel2Serial.vhd
-- Design               : VHDL Entity DCT2_lib.Parallel2Serial.rtl
------------------------------------------------------------------------------
-- Description  : Parallel to serial converter. When signal 'load' is active,
-- new data from input 'd_in' is loaded into registers. Otherwise contents of
-- registers is shifted (arithmetically) to right by one, and last bit is sent
-- to 'd_out'.
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

LIBRARY common_da;

ENTITY Parallel2Serial IS
   GENERIC( 
      dataw_g : integer := 18
   );
   PORT( 
      clk   : IN     std_logic;
      d_in  : IN     std_logic_vector (dataw_g-1 DOWNTO 0);  --parallel input data
      load  : IN     std_logic;                              --'1' => d_in is loaded in
      rst_n : IN     std_logic;
      d_out : OUT    std_logic                               --serial output data
   );

-- Declarations

END Parallel2Serial ;

--
ARCHITECTURE rtl OF Parallel2Serial IS
  SIGNAL data_r : std_logic_vector(dataw_g-1 DOWNTO 0);
BEGIN

  clocked : PROCESS (clk, rst_n)
  BEGIN  -- PROCESS clocked
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      data_r <= (OTHERS => '0');

    ELSIF clk'event AND clk = '1' THEN  -- rising clock edge
      IF (load = '1') THEN
        --load new data into shiftregister
        data_r <= d_in;
      ELSE
        --shift data by one
        data_r <= conv_std_logic_vector(SHR(signed(data_r),
                                            conv_unsigned(1, 1)), dataw_g);
      END IF;
    END IF;
  END PROCESS clocked;

  --concurrent signal assignment
  d_out <= data_r(0);
END rtl;

