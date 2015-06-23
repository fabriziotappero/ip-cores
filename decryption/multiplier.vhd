
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity multiplier is
port( B  :in std_logic_vector(15 downto 0);
    Product :out std_logic_vector(15 downto 0)
    );
end multiplier;

architecture Behavioral of multiplier is

signal  P1:std_logic_vector(15 downto 0);
signal  P2:std_logic_vector(15 downto 0);
signal  P3:std_logic_vector(15 downto 0);
signal  P4:std_logic_vector(15 downto 0);
signal  P5:std_logic_vector(15 downto 0);
signal  P6:std_logic_vector(15 downto 0);
signal  P7:std_logic_vector(15 downto 0);
signal  P8:std_logic_vector(15 downto 0);
signal  P9:std_logic_vector(15 downto 0);

component wallace_structure is
port(P1,P2,P3,P4,P5,P6,P7,P8,P9 :in std_logic_vector( 15 downto 0);
       product                  :out std_logic_vector( 15 downto 0));
end component;

begin
-- partial products reduced to 9 from 16 due to the multiplication of B and 2B+1

P1 <= B;

gen1:for i in 13 downto 1 generate
p2(i+2) <= B(0) and B(i);   --P2 = {{B[3:15] & {13{B[15]}}},1'd0,B[15],1'd0};
end generate;

p2(2 downto 0)<=('0' & B(0) & '0');


gen2:for i in 12 downto 2 generate
p3(i+3) <= B(1) and B(i);   --P3 <= {{B[5:15] & {11{B[14]}}},1'd0,B[14],3'd0};
end generate;

p3(4 downto 0)<=( '0' & B(1) & "000");

gen3:for i in 11 downto 3 generate
p4(i+4) <= B(2) and B(i);   -- P4 <= {{B[4:12] & {9{B[13]}}},1'd0,B[13],5'd0};
end generate;

p4(6 downto 0)<=('0'& B(2) & "00000");
 

gen5:for i in 10 downto 4 generate
p5(i+5) <= B(3) and B(i);   --  P5 <= {{B[5:11] & {7{B[12]}}},1'd0,B[12],7'd0};
end generate;

p5(8 downto 0)<=('0' & B(3) & "0000000");


gen6:for i in 9 downto 5 generate
p6(i+6) <= B(4) and B(i);   --P6 <= {{B[6:10] & {5{B[11]}}},1'd0,B[11],9'd0};  
end generate;

p6(10 downto 0)<=( '0' & B(4) & "000000000");

       
gen7:for i in 8 downto 6 generate
p7(i+7) <= B(5) and B(i);   -- P7 <= {{B[7:9] & {3{B[10]}}},1'd0,B[10],11'd0};
end generate;

p7(12 downto 0)<=( '0' & B(5) & "00000000000");


 P8 <= ((B(7) AND  B(6)) & '0'& B(6) & "0000000000000");


  P9 <= (B(7) & "000000000000000");
 
w1: wallace_structure port map (P1,P2,P3,P4,P5,P6,P7,P8,P9,product); --Wallace tree




end Behavioral;

