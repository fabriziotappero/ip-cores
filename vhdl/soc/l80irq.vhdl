--##############################################################################
-- l80irq : light8080 interrupt controller for l80soc 
--##############################################################################
--
-- This is a basic interrupt controller for the light8080 core. It is meant for
-- demonstration purposes only (demonstration of the light8080 core) and has 
-- not passed any serious verification test bench.
-- It has been built on the same principles as the rest of the modules in this
-- project: no more functionality than strictly needed, minimized area.
--
-- The interrupt controller operates under these rules:
--
-- -# All interrupt inputs are active at rising edge.
-- -# No logic is included for input sinchronization. You must take care to 
--    prevent metastability issues yourself by the usual means.
-- -# If a new edge is detected before the first is serviced, it is lost.
-- -# As soon as a rising edge in enabled irq input K is detected, bit K in the
--    interrupt pending register 'irq_pending_reg' will be asserted.
--    Than is, disabled interrupts never get detected at all.
-- -# Output cpu_intr_o will be asserted as long as there's a bit asserted in
--    the interrupt pending register.
-- -# For each interrupt there is a predefined priority level and a predefined 
--    interrupt vector -- see comments below. 
-- -# As soon as an INTA cycle is done by the CPU (inta=1 and fetch=1) the 
--    following will happen:
--    * The module will supply the interrupt vector of the highes priority
--      pending interrupt.
--    * The highest priority pending interrupt bit in the pending interrupt 
--      register will be deasserted -- UNLESS the interrupts happens to trigger
--      again at the same time, in which case the pending bit will remain
--      asserted.
--    * If there are no more interrupts pending, the cpu_intr_o output will
--      be deasserted.
-- -# The CPU will have its interrupts disabled from the INTA cycle to the 
--    execution of instruction EI. 
-- -# The cpu_intr_o will be asserted for a single cycle.
-- -# The irq vectors are hardcoded to RST instructions (single byte calls).
-- 
-- The priorities and vectors are hardcoded to the following values:
--
--    irq_i(3)    Priority 3    Vector RST 7
--    irq_i(2)    Priority 2    Vector RST 5
--    irq_i(1)    Priority 1    Vector RST 3
--    irq_i(0)    Priority 0    Vector RST 1
--
-- (Priority order: 3 > 2 > 1 > 0).
--
-- This module is used in the l80soc module, for which a basic test bench 
-- exists. Both can be used as usage example.
-- The module and its application is so simple than no documentation other than 
-- these comments should be necessary.
--
-- This file and all the light8080 project files are freeware (See COPYING.TXT)
--##############################################################################
-- (See timing diagrams at bottom of file. More comprehensive explainations can 
-- be found in the design notes)
--##############################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--##############################################################################
--
--##############################################################################

entity L80irq is
  port (  
    cpu_inta_i :    in std_logic;                
    cpu_intr_o :    out std_logic;    
    cpu_fetch_i :   in std_logic;
    
    data_we_i :     in std_logic;
    addr_i :        in std_logic;
    data_i :        in std_logic_vector(7 downto 0);
    data_o :        out std_logic_vector(7 downto 0);

    irq_i :         in std_logic_vector(3 downto 0);   
            
    clk :           in std_logic;
    reset :         in std_logic );
end L80irq;

--##############################################################################
--
--##############################################################################

architecture hardwired of L80irq is

-- irq_pending: 1 when irq[i] is pending service
signal irq_pending_reg :  std_logic_vector(3 downto 0);
-- irq_enable: 1 when irq[i] is enabled 
signal irq_enable_reg :   std_logic_vector(3 downto 0);
-- irq_q: registered irq input used to catch rising edges
signal irq_q :        std_logic_vector(3 downto 0);
-- irq_trigger: asserted to 1 when a rising edge is detected
signal irq_trigger :  std_logic_vector(3 downto 0);
signal irq_clear :    std_logic_vector(3 downto 0);
signal irq_clear_mask:std_logic_vector(3 downto 0);

signal data_rd :      std_logic_vector(7 downto 0);
signal vector :       std_logic_vector(7 downto 0);
signal irq_level :    std_logic_vector(2 downto 0);


begin

edge_detection:
for i in 0 to 3 generate
begin
  irq_trigger(i) <= '1' when  -- IRQ(i) is triggered when...
      irq_q(i)='0' and        -- ...we see a rising edge...
      irq_i(i)='1' and 
      irq_enable_reg(i)='1'   -- ...and the irq input us enabled.
      else '0';
end generate edge_detection;

interrupt_pending_reg:
process(clk)
begin
  if clk'event and clk='1' then
    if reset = '1' then
      irq_pending_reg <= (others => '0');
      irq_q <= (others => '0');
    else
      irq_pending_reg <= (irq_pending_reg and (not irq_clear)) or irq_trigger;
      irq_q <= irq_i;
    end if;
  end if;
end process interrupt_pending_reg;

with irq_level select irq_clear_mask <=
  "1000" when "111",
  "0100" when "101",
  "0010" when "011",
  "0001" when others;

irq_clear <= irq_clear_mask when cpu_inta_i='1' and cpu_fetch_i='1' else "0000";  
  

interrupt_enable_reg:
process(clk)
begin
  if clk'event and clk='1' then
    if reset = '1' then
      -- All interrupts disabled at reset
      irq_enable_reg <= (others => '0');
    else
      if data_we_i = '1' and addr_i = '0' then
        irq_enable_reg <= data_i(3 downto 0);
      end if;
    end if;
  end if;
end process interrupt_enable_reg;

-- Interrupt priority & vector decoding
irq_level <=
  "001" when irq_pending_reg(0) = '1' else
  "011" when irq_pending_reg(1) = '1' else
  "110" when irq_pending_reg(2) = '1' else
  "111";

-- Raise interrupt request when there's any irq pending
cpu_intr_o <= '1' when irq_pending_reg /= "0000" else '0';

-- The IRQ vector is hardcoded to a RST instruction, whose opcode is 
-- RST <n> ---> 11nnn111
process(clk)
begin
  if clk'event and clk='1' then
    if cpu_inta_i='1' and cpu_fetch_i='1' then
      vector <= "11" & irq_level & "111";
    end if;
  end if;
end process;

-- There's only an internal register, the irq enable register, so we
-- don't need an output register mux.
data_rd <= "0000" & irq_enable_reg;

-- The mdule will output the register being read, if any, OR the irq vector.
data_o <= vector when cpu_inta_i = '1' else data_rd;




end hardwired;

