library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity io_control is
  generic (
    stage : natural:=3);

  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
	 mem_bk : in std_logic;
    Gen_state : in  std_logic_vector(2*stage+2 downto 0);
	 bank0_busy : out std_logic;
	 bank1_busy : out std_logic;
    Output_enable: out std_logic);
end io_control;

architecture io_control of io_control is

alias state: std_logic_vector(2 downto 0) is Gen_state(2*stage+2 downto 2*stage);
alias counter: std_logic_vector(2*stage-1 downto 0) is Gen_state(2*stage-1 downto 0);

begin

Outen:process (clk, rst)
  begin  -- process
    if rst = '1' then                   -- asynchronous reset (active low)
      Output_enable <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if  unsigned(state)=stage-1 and unsigned(counter)=55 then
        Output_enable <= '1';
      else
        Output_enable <= '0';
      end if;      
    end if;
  end process;

Bank_busy:process(clk, rst)
  begin
    if rst = '1' then
	    bank0_busy <= '0';
	    bank1_busy <= '0';
    elsif clk'event and clk = '1' then
       if unsigned(state)=0 then
          if mem_bk = '0' then
             bank0_busy <= '1';
          else
	         bank1_busy <= '1';
          end if;
		 else
          bank0_busy <= '0';
          bank1_busy <= '0';		      
       end if;
    end if;
  end process;

end io_control;
