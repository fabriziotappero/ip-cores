-- Library declarations
--
-- Standard IEEE libraries
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pb_irc is
Port (         
      BRAM_DATA    : in    std_logic_vector(17 downto 0);
      BRAM_ADDR    : in    std_logic_vector(9 downto 0);
      BRAM_EN      : in    std_logic;
      PB_RST       : in    std_logic;
      P_OUT_4      : out   std_logic_vector(7 downto 0);
      P_IN_0       : in    std_logic_vector(7 downto 0);
      INT          : in    std_logic;
      I_ACK        : out   std_logic;
      CLK          : in    std_logic);
    end pb_irc;

architecture Behavioral of pb_irc is
-- declaration of KCPSM3
component kcpsm3
Port (
      address        : out    std_logic_vector(9 downto 0);
      instruction    : in     std_logic_vector(17 downto 0);
      port_id        : out    std_logic_vector(7 downto 0);
      write_strobe   : out    std_logic;
      out_port       : out    std_logic_vector(7 downto 0);
      read_strobe    : out    std_logic;
      in_port        : in     std_logic_vector(7 downto 0);
      interrupt      : in     std_logic;
      interrupt_ack  : out    std_logic;
      reset          : in     std_logic;
      clk            : in     std_logic);
end component;
--
-- declaration of program ROM
--
component int_test 
Port (
      BRAM_DATA      : in     std_logic_vector(17 downto 0);
      BRAM_ADDR      : in     std_logic_vector(9 downto 0);
      BRAM_EN        : in     std_logic;
      address        : in     std_logic_vector(9 downto 0);
      instruction    : out    std_logic_vector(17 downto 0);
      clk            : in     std_logic);
end component;
--
------------------------------------------------------------------------------------
--
-- Signals used to connect KCPSM3 to program ROM and I/O logic
--
signal address       : std_logic_vector(9 downto 0);
signal instruction   : std_logic_vector(17 downto 0);
signal port_id       : std_logic_vector(7 downto 0);
signal out_port      : std_logic_vector(7 downto 0);
signal in_port       : std_logic_vector(7 downto 0);
signal write_strobe  : std_logic;
signal read_strobe   : std_logic;
signal interrupt     : std_logic :='0';
signal interrupt_ack : std_logic;
signal reset         : std_logic;
signal int_r, int_i  : std_logic;
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Start of circuit description
--
begin

reset <= PB_RST;

-- Inserting KCPSM3 and the program memory

  processor: kcpsm3
    port map(      address => address,
               instruction => instruction,
                   port_id => port_id,
              write_strobe => write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     reset => reset,
                       clk => clk);
 
  program: int_test
    port map(
             BRAM_DATA     =>  BRAM_DATA,
             BRAM_ADDR     =>  BRAM_ADDR,
             BRAM_EN       =>  BRAM_EN,
             address       =>  address,
             instruction   =>  instruction,
             clk           =>   clk);


PROCESS(clk)
BEGIN
   If clk'event And clk = '1' Then
      If port_id = x"00" Then
         in_port <= P_IN_0;
      End If;
   End If;
END PROCESS;
   
IO_registers: process(clk)
begin
   If clk'event and clk='1' then
      If port_id(2)='1' and write_strobe='1' then
        P_OUT_4 <= out_port;
      End If;
   End If;   
end process IO_registers;


-- Adding the interrupt input
-- Note that the initial value of interrupt (low) is  
-- defined at signal declaration.
   
PROCESS(clk)
BEGIN
   If clk'event And clk = '1' Then
      int_i <= INT;
      If int_i = '0' And INT = '1' Then      -- Detect rising edge @ INT
         int_r <= '1';
      Else
         int_r <= '0';
      End If;
   End If;
END PROCESS;

interrupt_control: process(clk)
BEGIN
   if clk'event and clk = '1' then
      if interrupt_ack = '1' then
         interrupt <= '0';
      elsif int_r = '1' then
         interrupt <= '1';
      else
         interrupt <= interrupt;
      end if;
   end if; 
END PROCESS;

end Behavioral;
