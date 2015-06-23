--===========================================================================--
--
--  S Y N T H E Z I A B L E    timer  dual 8 Bit timer
--
--  This core adheres to the GNU public license  
--
-- File name      : timer.vhd
--
-- Purpose        : Implements 2 x 8 bit timers
--                  
-- Dependencies   : ieee.Std_Logic_1164
--                  ieee.std_logic_unsigned
--
-- Uses           : None
--
-- Author         : John E. Kent      
--
--===========================================================================----
--
-- Revision History:
--===========================================================================--
--
-- Initial version - John Kent - 6 Sept 2002
--	Make CS & reset positive sense - John Kent - 30th May 2004
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity timer is
	port (	
	 clk       : in  std_logic;
    rst       : in  std_logic;
    cs        : in  std_logic;
    rw        : in  std_logic;
    addr      : in  std_logic_vector(2 downto 0);
    data_in   : in  std_logic_vector(7 downto 0);
	 data_out  : out std_logic_vector(7 downto 0);
	 irq_out   : out std_logic;
	 tim0_in   : in  std_logic;
	 tim0_out  : out std_logic;
	 tim1_in   : in  std_logic;
	 tim1_out  : out std_logic
  );
end;

architecture timer_arch of timer is
signal timer_ctrl_reg : std_logic_vector(7 downto 0);
signal timer0_reg : std_logic_vector(7 downto 0);
signal timer1_reg : std_logic_vector(7 downto 0);
signal count0     : std_logic_vector(7 downto 0);
signal count1     : std_logic_vector(7 downto 0);
begin

--------------------------------
--
-- write control registers
-- doesn't do anything yet
--
--------------------------------
write_timer_control : process( clk, rst, cs, rw, addr, data_in, timer0_reg, timer1_reg, timer_ctrl_reg )
begin
  if clk'event and clk = '0' then
    if cs = '1' and rw = '0' then
	   case addr is
	   when "000" =>
		  timer_ctrl_reg <= data_in;
		  timer0_reg <= timer0_reg;
		  timer1_reg <= timer1_reg;
      when "010" =>
	     timer_ctrl_reg <= timer_ctrl_reg;
		  timer0_reg <= data_in;
		  timer1_reg <= timer1_reg;
	   when "011" =>
	     timer_ctrl_reg <= timer_ctrl_reg;
		  timer0_reg <= timer0_reg;
		  timer1_reg <= data_in;
	   when others =>
	     timer_ctrl_reg <= timer_ctrl_reg;
		  timer0_reg <= timer0_reg;
		  timer1_reg <= timer1_reg;
		end case;
	 else
	   timer_ctrl_reg <= timer_ctrl_reg;
		timer0_reg <= timer0_reg;
		timer1_reg <= timer1_reg;
    end if;
  end if;
end process;

read_timer_control : process( addr, timer_ctrl_reg, timer0_reg, timer1_reg, count0, count1 )
begin
  case addr is
  when "000" =>
    data_out <= timer_ctrl_reg;
  when "010" =>
    data_out <= timer0_reg;
  when "011" =>
    data_out <= timer1_reg;
  when "110" =>
    data_out <= count0;
  when "111" =>
    data_out <= count1;
  when others =>
    data_out <= "00000000";
  end case;
  irq_out <= timer_ctrl_reg(0);
end process;

--------------------------------
--
-- counters
--
--------------------------------

my_counter: process( clk, rst, count0, count1, tim0_in, tim1_in )
begin
  if rst = '1' then
	 count0 <= "00000000";
  elsif tim0_in'event and tim0_in = '0' then
	   if count0 = timer0_reg then
		  count0 <= "00000000";
		else
	     count0 <= count0 + 1;
		end if;
  end if;

  if rst = '1' then
	 count1 <= "00000000";
  elsif tim1_in'event and tim1_in = '1' then
	   if count1 = timer1_reg then
		  count1 <= "00000000";
		else
	     count1 <= count1 + 1;
		end if;
  end if;

  tim0_out <= count0(7);
  tim1_out <= count1(7);
end process;
	
end timer_arch;
	
