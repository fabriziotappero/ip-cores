-------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_arith.all;
use work.riscompatible_package.all;
-------------------------------------------------------------------------------------------------------------------
entity riscompatible_tb is
end riscompatible_tb;
-------------------------------------------------------------------------------------------------------------------
architecture behavioral of riscompatible_tb is
    constant C_NumBitsProgramMemory  : Natural:=14;
    constant C_NumBitsDataMemory     : Natural:=7;
    constant C_NumBitsRegBank        : natural:=5;
    constant C_NumBitsInputPorts     : natural:=2;
    constant C_NumBitsOutputPorts    : natural:=2;
    component riscompatible is
        generic
        (
            NumBitsProgramMemory : Natural:=5;
            NumBitsDataMemory    : Natural:=5;
            NumBitsRegBank       : natural:=5;
            NumBitsInputPorts    : natural:=2;
            NumBitsOutputPorts   : natural:=2  
        );
        port
        (
            Clk_I         : in  std_logic;
            Reset_I       : in  std_logic;
            Int_I         : in  std_logic;
            IntAck_O      : out std_logic;
            InputPorts_I  : in  std_logic_vector(NumBitsInputPorts-1 downto 0);
            OutputPorts_O : out std_logic_vector(NumBitsOutputPorts-1 downto 0)
        );
    end component;
    signal Clk_W         : std_logic;
    signal Reset_W       : std_logic;
    signal Int_W         : std_logic;
    signal IntAck_W      : std_logic; 
    signal InputPorts_W  : std_logic_vector(C_NumBitsInputPorts-1 downto 0):="10";
    signal OutputPorts_W : std_logic_vector(C_NumBitsOutputPorts-1 downto 0);
begin
---------------------------------------------
-- Clock Generation
---------------------------------------------
process
begin
    Clk_W <= '1';
    wait for 10 ns;
    Clk_W <= '0';
    wait for 10 ns;
end process;

---------------------------------------------
-- Reset Generation
---------------------------------------------
process
begin
    Reset_W <= '1';
    wait for 20 ns;
    Reset_W <= '0';
    wait;
end process;

---------------------------------------------
-- Interruption Generation
---------------------------------------------
process
begin
    Int_W <= '0';
    wait for 1 us;
    Int_W <= '1';
    wait for 500 ns;
    Int_W <= '0';
    wait;
end process;
    
---------------------------------------------
-- Risco Instance
---------------------------------------------
Riscompatible1: riscompatible 
    generic map
    (
        NumBitsProgramMemory  => C_NumBitsProgramMemory,
        NumBitsDataMemory     => C_NumBitsDataMemory,
        NumBitsRegBank        => C_NumBitsRegBank,
        NumBitsInputPorts     => C_NumBitsInputPorts,
        NumBitsOutputPorts    => C_NumBitsOutputPorts
    )
    port map
    (
        Clk_I         => Clk_W,
        Reset_I       => Reset_W,
        Int_I         => Int_W,
        IntAck_O      => IntAck_W,
        InputPorts_I  => InputPorts_W,
        OutputPorts_O => OutputPorts_W
    );
end behavioral;