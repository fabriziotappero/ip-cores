------------------------------------------------------------------------------
-- Author		: Timo Alho
-- e-mail		: timo.a.alho@tut.fi
-- Date  		: 14.06.2004 14:11:03
-- File  		: Serial_subtractor.vhd
-- Design		: 
------------------------------------------------------------------------------
-- Description	: Serial subtractor (in0 - in1). 
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY Serial_subtractor IS
   PORT( 
      clk     : IN     std_logic;
      in0     : IN     std_logic;   --serial data in 0
      in1     : IN     std_logic;   --serial data in 1
      rst_n   : IN     std_logic;
      start   : IN     std_logic;   --start (ignores borrowbit)
      sub_out : OUT    std_logic    --serial data out
   );

-- Declarations

END Serial_subtractor ;

--
ARCHITECTURE rtl OF Serial_subtractor IS
  SIGNAL borrow_bit_r : std_logic;      -- register for borrow bit
  SIGNAL borrow_bit   : std_logic;      -- internal signal for borrow bit
  SIGNAL sub : std_logic;               -- internal signal for result

BEGIN

  clocked : PROCESS (clk, rst_n)
  BEGIN  -- PROCESS clocked
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      borrow_bit_r <= '0';

    ELSIF clk'event AND clk = '1' THEN  -- rising clock edge
      borrow_bit_r <= borrow_bit;
    END IF;
  END PROCESS clocked;

  calc             : PROCESS (borrow_bit_r, start, in0, in1)
    VARIABLE temp1 : std_logic_vector(1 DOWNTO 0);
    VARIABLE temp2 : std_logic_vector(2 DOWNTO 0);
  BEGIN  -- PROCESS calc

    IF (start = '1') THEN
      temp1 := in0 & in1;
      CASE temp1 IS
        WHEN "00"   =>
          sub      <= '0';
          borrow_bit <= '0';
        WHEN "01"   =>
          sub      <= '1';
          borrow_bit <= '1';
        WHEN "10"   =>
          sub      <= '1';
          borrow_bit <= '0';
        WHEN OTHERS =>
          sub      <= '0';
          borrow_bit <= '0';
      END CASE;

    ELSE
      temp2 := borrow_bit_r & in0 & in1;
      CASE temp2 IS
        WHEN "000"  =>
          sub      <= '0';
          borrow_bit <= '0';
        WHEN "001"  =>
          sub      <= '1';
          borrow_bit <= '1';
        WHEN "010"  =>
          sub      <= '1';
          borrow_bit <= '0';
        WHEN "011"  =>
          sub      <= '0';
          borrow_bit <= '0';
        WHEN "100"  =>
          sub      <= '1';
          borrow_bit <= '1';
        WHEN "101"  =>
          sub      <= '0';
          borrow_bit <= '1';
        WHEN "110"  =>
          sub      <= '0';
          borrow_bit <= '0';
        WHEN OTHERS =>
          sub      <= '1';
          borrow_bit <= '1';
      END CASE;
    END IF;
  END PROCESS calc;

  sub_out <= sub; 
END rtl;

