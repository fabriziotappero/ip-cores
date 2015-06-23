---------------------------------------------------------------------
-- TITLE: Bus Multiplexer / Signal Router
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 2/8/01
-- FILENAME: bus_mux.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    This entity is the main signal router.  
--    It multiplexes signals from multiple sources to the correct location.
--    The outputs are as follows:
--       a_bus        : goes to the ALU
--       b_bus        : goes to the ALU
--       reg_dest_out : goes to the register bank
--       take_branch  : goes to pc_next
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.mlite_pack.all;

entity bus_mux is
   port(imm_in       : in  std_logic_vector(15 downto 0);
        reg_source   : in  std_logic_vector(31 downto 0);
        a_mux        : in  a_source_type;
        a_out        : out std_logic_vector(31 downto 0);

        reg_target   : in  std_logic_vector(31 downto 0);
        b_mux        : in  b_source_type;
        b_out        : out std_logic_vector(31 downto 0);

        c_bus        : in  std_logic_vector(31 downto 0);
        c_memory     : in  std_logic_vector(31 downto 0);
        c_pc         : in  std_logic_vector(31 downto 2);
        c_pc_plus4   : in  std_logic_vector(31 downto 2);
        c_mux        : in  c_source_type;
        reg_dest_out : out std_logic_vector(31 downto 0);

        branch_func  : in  branch_function_type;
        take_branch  : out std_logic);
end; --entity bus_mux

architecture logic of bus_mux is
begin

--Determine value of a_bus
amux: process(reg_source, imm_in, a_mux, c_pc) 
begin
   case a_mux is
   when A_FROM_REG_SOURCE =>
      a_out <= reg_source;
   when A_FROM_IMM10_6 =>
      a_out <= ZERO(31 downto 5) & imm_in(10 downto 6);
   when A_FROM_PC =>
      a_out <= c_pc & "00";
   when others =>
      a_out <= c_pc & "00";
   end case;
end process;

--Determine value of b_bus
bmux: process(reg_target, imm_in, b_mux) 
begin
   case b_mux is
   when B_FROM_REG_TARGET =>
      b_out <= reg_target;
   when B_FROM_IMM =>
      b_out <= ZERO(31 downto 16) & imm_in;
   when B_FROM_SIGNED_IMM =>
      if imm_in(15) = '0' then
         b_out(31 downto 16) <= ZERO(31 downto 16);
      else
         b_out(31 downto 16) <= "1111111111111111";
      end if;
      b_out(15 downto 0) <= imm_in;
   when B_FROM_IMMX4 =>
      if imm_in(15) = '0' then
         b_out(31 downto 18) <= "00000000000000";
      else
         b_out(31 downto 18) <= "11111111111111";
      end if;
      b_out(17 downto 0) <= imm_in & "00";
   when others =>
      b_out <= reg_target;
   end case;
end process;

--Determine value of c_bus								
cmux: process(c_bus, c_memory, c_pc, c_pc_plus4, imm_in, c_mux) 
begin
   case c_mux is
   when C_FROM_ALU =>  -- | C_FROM_SHIFT | C_FROM_MULT =>
      reg_dest_out <= c_bus;
   when C_FROM_MEMORY =>
      reg_dest_out <= c_memory;
   when C_FROM_PC =>
      reg_dest_out <= c_pc(31 downto 2) & "00"; 
   when C_FROM_PC_PLUS4 =>
      reg_dest_out <= c_pc_plus4 & "00";
   when C_FROM_IMM_SHIFT16 =>
      reg_dest_out <= imm_in & ZERO(15 downto 0);
   when others =>
      reg_dest_out <= c_bus;
   end case;
end process;

--Determine value of take_branch
pc_mux: process(branch_func, reg_source, reg_target) 
   variable is_equal : std_logic;
begin
   if reg_source = reg_target then
      is_equal := '1';
   else
      is_equal := '0';
   end if;
   case branch_func is
   when BRANCH_LTZ =>
      take_branch <= reg_source(31);
   when BRANCH_LEZ =>
      take_branch <= reg_source(31) or is_equal;
   when BRANCH_EQ =>
      take_branch <= is_equal;
   when BRANCH_NE =>
      take_branch <= not is_equal;
   when BRANCH_GEZ =>
      take_branch <= not reg_source(31);
   when BRANCH_GTZ =>
      take_branch <= not reg_source(31) and not is_equal;
   when BRANCH_YES =>
      take_branch <= '1';
   when others =>
      take_branch <= '0';
   end case;
end process;

end; --architecture logic
