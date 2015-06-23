---------------------------------------------------------------------
-- TITLE: Pipeline
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 6/24/02
-- FILENAME: pipeline.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Controls the three stage pipeline by delaying the signals:
--      a_bus, b_bus, alu/shift/mult_func, c_source, and rs_index.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.mlite_pack.all;

--Note: sigD <= sig after rising_edge(clk)
entity pipeline is
   port(clk            : in  std_logic;
        reset          : in  std_logic;
        a_bus          : in  std_logic_vector(31 downto 0);
        a_busD         : out std_logic_vector(31 downto 0);
        b_bus          : in  std_logic_vector(31 downto 0);
        b_busD         : out std_logic_vector(31 downto 0);
        alu_func       : in  alu_function_type;
        alu_funcD      : out alu_function_type;
        shift_func     : in  shift_function_type;
        shift_funcD    : out shift_function_type;
        mult_func      : in  mult_function_type;
        mult_funcD     : out mult_function_type;
        reg_dest       : in  std_logic_vector(31 downto 0);
        reg_destD      : out std_logic_vector(31 downto 0);
        rd_index       : in  std_logic_vector(5 downto 0);
        rd_indexD      : out std_logic_vector(5 downto 0);

        rs_index       : in  std_logic_vector(5 downto 0);
        rt_index       : in  std_logic_vector(5 downto 0);
        pc_source      : in  pc_source_type;
        mem_source     : in  mem_source_type;
        a_source       : in  a_source_type;
        b_source       : in  b_source_type;
        c_source       : in  c_source_type;
        c_bus          : in  std_logic_vector(31 downto 0);
        pause_any      : in  std_logic;
        pause_pipeline : out std_logic);
end; --entity pipeline

architecture logic of pipeline is
   signal rd_index_reg     : std_logic_vector(5 downto 0);
   signal reg_dest_reg     : std_logic_vector(31 downto 0);
   signal reg_dest_delay   : std_logic_vector(31 downto 0);
   signal c_source_reg     : c_source_type;
   signal pause_enable_reg : std_logic;
begin

--When operating in three stage pipeline mode, the following signals
--are delayed by one clock cycle:  a_bus, b_bus, alu/shift/mult_func,
--c_source, and rd_index.
pipeline3: process(clk, reset, a_bus, b_bus, alu_func, shift_func, mult_func,
      rd_index, rd_index_reg, pause_any, pause_enable_reg, 
      rs_index, rt_index,
      pc_source, mem_source, a_source, b_source, c_source, c_source_reg, 
      reg_dest, reg_dest_reg, reg_dest_delay, c_bus)
   variable pause_mult_clock : std_logic;
   variable freeze_pipeline  : std_logic;
begin
   if (pc_source /= FROM_INC4 and pc_source /= FROM_OPCODE25_0) or
         mem_source /= MEM_FETCH or
         (mult_func = MULT_READ_LO or mult_func = MULT_READ_HI) then
      pause_mult_clock := '1';
   else
      pause_mult_clock := '0';
   end if;

   freeze_pipeline := not (pause_mult_clock and pause_enable_reg) and pause_any;
   pause_pipeline <= pause_mult_clock and pause_enable_reg;
   rd_indexD <= rd_index_reg;

   -- The value written back into the register bank, signal reg_dest is tricky.
   -- If reg_dest comes from the ALU via the signal c_bus, it is already delayed 
   -- into stage #3, because a_busD and b_busD are delayed.  If reg_dest comes from 
   -- c_memory, pc_current, or pc_plus4 then reg_dest hasn't yet been delayed into 
   -- stage #3.
   -- Instead of delaying c_memory, pc_current, and pc_plus4, these signals
   -- are multiplexed into reg_dest which is then delayed.  The decision to use
   -- the already delayed c_bus or the delayed value of reg_dest (reg_dest_reg) is 
   -- based on a delayed value of c_source (c_source_reg).
   
   if c_source_reg = C_FROM_ALU then
      reg_dest_delay <= c_bus;        --delayed by 1 clock cycle via a_busD & b_busD
   else
      reg_dest_delay <= reg_dest_reg; --need to delay 1 clock cycle from reg_dest
   end if;
   reg_destD <= reg_dest_delay;

   if reset = '1' then
      a_busD <= ZERO;
      b_busD <= ZERO;
      alu_funcD <= ALU_NOTHING;
      shift_funcD <= SHIFT_NOTHING;
      mult_funcD <= MULT_NOTHING;
      reg_dest_reg <= ZERO;
      c_source_reg <= "000";
      rd_index_reg <= "000000";
      pause_enable_reg <= '0';
   elsif rising_edge(clk) then
      if freeze_pipeline = '0' then
         if (rs_index = "000000" or rs_index /= rd_index_reg) or 
            (a_source /= A_FROM_REG_SOURCE or pause_enable_reg = '0') then
            a_busD <= a_bus;
         else
            a_busD <= reg_dest_delay;  --rs from previous operation (bypass stage)
         end if;

         if (rt_index = "000000" or rt_index /= rd_index_reg) or
               (b_source /= B_FROM_REG_TARGET or pause_enable_reg = '0') then
            b_busD <= b_bus;
         else
            b_busD <= reg_dest_delay;  --rt from previous operation
         end if;

         alu_funcD <= alu_func;
         shift_funcD <= shift_func;
         mult_funcD <= mult_func;
         reg_dest_reg <= reg_dest;
         c_source_reg <= c_source;
         rd_index_reg <= rd_index;
      end if;

      if pause_enable_reg = '0' and pause_any = '0' then
         pause_enable_reg <= '1';   --enable pause_pipeline
      elsif pause_mult_clock = '1' then
         pause_enable_reg <= '0';   --disable pause_pipeline
      end if;
   end if;

end process; --pipeline3

end; --logic
