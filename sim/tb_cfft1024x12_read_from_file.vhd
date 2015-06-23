library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity tb_cfft1024x12 is

end tb_cfft1024x12;

architecture tb of tb_cfft1024x12 is

component cfft1024X12
         port(
                 clk : in STD_LOGIC;
                 rst : in STD_LOGIC;
                 start : in STD_LOGIC;
                 invert : in std_logic;
                 Iin : in STD_LOGIC_VECTOR(11 downto 0);
                 Qin : in STD_LOGIC_VECTOR(11 downto 0);
                 inputbusy : out STD_LOGIC;
                 outdataen : out STD_LOGIC;
                 Iout : out STD_LOGIC_VECTOR(13 downto 0);
                 Qout : out STD_LOGIC_VECTOR(13 downto 0);
                 OutPosition : out STD_LOGIC_VECTOR( 9 downto 0 )
             );
end component;

signal  clk : STD_LOGIC;
signal  rst : STD_LOGIC;
signal  start : STD_LOGIC;
signal  invert : std_logic;
signal  Iin : STD_LOGIC_VECTOR(11 downto 0);
signal  Qin : STD_LOGIC_VECTOR(11 downto 0);
signal  inputbusy : STD_LOGIC;
signal  outdataen : STD_LOGIC;
signal  Iout : STD_LOGIC_VECTOR(13 downto 0);
signal  Qout : STD_LOGIC_VECTOR(13 downto 0);
signal  output_position:std_logic_vector(9 downto 0 );
constant clkprd : time:=10 ns;

begin
f: cfft1024x12 port map(clk=>clk,
                        rst =>rst,
                        start=> start,
                        invert=>invert,
                        Iin=>Iin,
                        Qin=>Qin,
                        inputbusy=>inputbusy,
                        outdataen=>outdataen,
                        Iout=>Iout,
                        Qout=>Qout,
                        OutPosition=>output_position);

clockgen: process
begin
        clk <= '1';
        wait for clkprd/2;
        clk <= '0';
        wait for clkprd/2;
end process;

fileread: process
file FileIn1 : text is in  "bindata"; -- bindata is a file containing 1-1024
in binary.
variable LineIn1   : line;
variable InputTmp1 :std_logic_vector(11 downto 0);
begin
                rst<='1';
                wait until clk'EVENT and clk='1';
                rst<='0';
                wait until clk'EVENT and clk='1';
                invert<='0';
                start<='1';
                wait until clk'EVENT and clk='1';
                start<='0';

                while  not( endfile( FileIn1)) loop
                        readline( FileIn1, LineIn1);
                        read(LineIn1, InputTmp1);
                        Iin<=InputTmp1;
                        Qin<="000000000000";
                        wait until clk'EVENT and clk='1';
                end loop;

                wait until outdataen'EVENT and outdataen='1';
                wait for 15000 ns;
end process;

end tb;
