library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tx_control is
     generic (
        WIDTH  : natural := 12;
        POINT  : natural := 64;
        STAGE  : natural := 3);

      port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        mem_ready     : out  std_logic;
        mem_block     : in std_logic;
        Output_enable : in std_logic;
        bank0_busy    : in std_logic;
        bank1_busy    : in std_logic;
        wen_in        : out  std_logic;
        addrin_in     : out  std_logic_vector(2*stage-1 downto 0);
        addrout_out   : out  std_logic_vector(2*stage-1 downto 0));

   
end tx_control;

architecture tx_control of tx_control is

signal cont: std_logic_vector(2*stage-2 downto 0);
begin

process (clk, rst)
begin
   if rst ='1' then
	   cont <= (others => '0');
	elsif clk'event and clk='1' then
	   if unsigned(cont) /= 32 then
	      cont <= cont+1;
      else 
		   cont <= x'1';
		end if;
	end if;
end process;

end tx_control;
