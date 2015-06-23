---------------------------------------------------------------------
-- Design unit: lfsr(rtl) (Entity and Architecture)
--            :
-- File name  : lfsr.vhd
--            :
-- Description: RTL model of LFSR
--            :
-- Limitations: None
--            : 
-- System     : VHDL'93, STD_LOGIC_1164
--            :
-- Author     : Mark Zwolinski
--            : Department of Electronics and Computer Science
--            : University of Southampton
--            : Southampton SO17 1BJ, UK
--            : mz@ecs.soton.ac.uk
--
-- Revision   : Version 1.0 08/03/00
-- 09.05.2007 AK mod: uses 0.5x registers compared to the orig.
---------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity lfsr is
  generic(
    width_g : integer range 1 to 36 := 8
    );
  port(
    rst_n     : in  std_logic;
    enable_in : in  std_logic;
    q_out     : out std_logic_vector(width_g-1 downto 0);
    clk       : in  std_logic
    );
end entity lfsr;

architecture rtl of lfsr is
  type tap_table is array (1 to 36, 1 to 4) of
    integer range -1 to 36;
  constant taps : tap_table := (
    (0, -1, -1, -1),                    -- 1
    (1, 0, -1, -1),                     -- 2
    (1, 0, -1, -1),                     -- 3
    (1, 0, -1, -1),                     -- 4
    (2, 0, -1, -1),                     -- 5
    (1, 0, -1, -1),                     -- 6
    (1, 0, -1, -1),                     -- 7
    (6, 5, 1, 0),                       -- 8
    (4, 0, -1, -1),                     -- 9
    (3, 0, -1, -1),                     --10
    (2, 0, -1, -1),                     --11
    (7, 4, 3, 0),                       --12
    (4, 3, 1, 0),                       --13
    (12, 11, 1, 0),                     --14
    (1, 0, -1, -1),                     --15
    (5, 3, 2, 0),                       --16
    (3, 0, -1, -1),                     --17
    (7, 0, -1, -1),                     --18
    (6, 5, 1, 0),                       --19
    (3, 0, -1, -1),                     --20
    (2, 0, -1, -1),                     --21
    (1, 0, -1, -1),                     --22
    (5, 0, -1, -1),                     --23
    (4, 3, 1, 0),                       --24
    (3, 0, -1, -1),                     --25
    (8, 7, 1, 0),                       --26
    (8, 7, 1, 0),                       --27
    (3, 0, -1, -1),                     --28
    (2, 0, -1, -1),                     --29
    (16, 15, 1, 0),                     --30
    (3, 0, -1, -1),                     --31
    (28, 27, 1, 0),                     --32
    (13, 0, -1, -1),                    --33
    (15, 14, 1, 0),                     --34
    (2, 0, -1, -1),                     --35
    (11, 0, -1, -1));                   --36
  signal ak_test : std_logic_vector(width_g-1 downto 0);
begin
  p0 : process (clk, rst_n) is
    variable reg      : std_logic_vector(width_g-1 downto 0);
    variable feedback : std_logic;
  begin
    if rst_n = '0' then
      reg     := (others => '1');
--      q_out   <= (others => '0');
      ak_test <= (others => '1');
    elsif  clk'event and clk = '1' then
      if enable_in = '1' then
        feedback := ak_test(taps(width_g, 1));
        for i in 2 to 4 loop
          if taps(width_g, i) >= 0 then
            feedback := feedback xor ak_test(taps(width_g, i));
          end if;
        end loop;
        reg     := feedback & reg(width_g-1 downto 1);
        ak_test <= reg;
      else
        ak_test <= ak_test;
      end if;
    end if;
  end process p0;
    q_out <= ak_test;
  
end architecture rtl;

