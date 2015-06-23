-------------------------------------------------------------------------------
--* 
--* @short Control Unit for IRQ detection, enable and clear
--* 
--* @generic C_ACTIVE_EDGE  Select active edge for IRQ-Source 0: H->L;1: L->H
--*
--*    @author: Daniel Köthe
--*   @version: 1.0
--* @date:      2007-11-11
--/
-- Version 1.1
-- Bugfix
-- added syncronisation registers opb_fifo_flg_int_r[0,1] to prevent
-- metastability
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity irq_ctl is
  generic (
    C_ACTIVE_EDGE : std_logic := '0');
  port (
    rst          : in  std_logic;
    clk          : in  std_logic;
    opb_fifo_flg : in  std_logic;
    opb_ier      : in  std_logic;
    opb_isr      : out std_logic;
    opb_isr_clr  : in  std_logic);

end irq_ctl;

architecture behavior of irq_ctl is

  signal opb_fifo_flg_int : std_logic;
  -- Sync to clock domain register
  signal opb_fifo_flg_int_r0 : std_logic;
  signal opb_fifo_flg_int_r1 : std_logic;


  signal opb_fifo_flg_reg : std_logic;
begin  -- behavior

  opb_fifo_flg_int_r0 <= opb_fifo_flg when (C_ACTIVE_EDGE = '1') else
                         not opb_fifo_flg;
  
  irq_ctl_proc : process(rst, clk)
  begin
    if (rst = '1') then
      opb_isr <= '0';
    elsif rising_edge(clk) then
      -- sync to clock domain
      opb_fifo_flg_int_r1 <= opb_fifo_flg_int_r0;
      opb_fifo_flg_int    <= opb_fifo_flg_int_r1;

      opb_fifo_flg_reg <= opb_fifo_flg_int;
      if (opb_ier = '1' and opb_fifo_flg_int = '1' and opb_fifo_flg_reg = '0') then
        opb_isr <= '1';
      elsif (opb_isr_clr = '1') then
        opb_isr <= '0';
      end if;
    end if;
  end process irq_ctl_proc;
  

end behavior;
