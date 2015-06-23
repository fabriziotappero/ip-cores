---------------------------------------------------------------------
-- TITLE: Program Counter Next
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 2/8/01
-- FILENAME: pc_next.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Implements the Program Counter logic.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.mlite_pack.all;

entity pc_next is
   port(clk         : in std_logic;
        reset_in    : in std_logic;
        pc_new      : in std_logic_vector(31 downto 2);
        take_branch : in std_logic;
        pause_in    : in std_logic;
        opcode25_0  : in std_logic_vector(25 downto 0);
        pc_source   : in pc_source_type;
        pc_future   : out std_logic_vector(31 downto 2);
        pc_current  : out std_logic_vector(31 downto 2);
        pc_plus4    : out std_logic_vector(31 downto 2));
end; --pc_next

architecture logic of pc_next is
   signal pc_reg : std_logic_vector(31 downto 2); 
begin

pc_select: process(clk, reset_in, pc_new, take_branch, pause_in, 
                 opcode25_0, pc_source, pc_reg)
   variable pc_inc      : std_logic_vector(31 downto 2);
   variable pc_next : std_logic_vector(31 downto 2);
begin
   pc_inc := bv_increment(pc_reg);  --pc_reg+1

   case pc_source is
   when FROM_INC4 =>
      pc_next := pc_inc;
   when FROM_OPCODE25_0 =>
      pc_next := pc_reg(31 downto 28) & opcode25_0;
   when FROM_BRANCH | FROM_LBRANCH =>
      if take_branch = '1' then
         pc_next := pc_new;
      else
         pc_next := pc_inc;
      end if;
   when others =>
      pc_next := pc_inc;
   end case;

   if pause_in = '1' then
      pc_next := pc_reg;
   end if;

   if reset_in = '1' then
      pc_reg <= ZERO(31 downto 2);
      pc_next := pc_reg;
   elsif rising_edge(clk) then
      pc_reg <= pc_next;
   end if;

   pc_future <= pc_next;
   pc_current <= pc_reg;
   pc_plus4 <= pc_inc;
end process;

end; --logic
