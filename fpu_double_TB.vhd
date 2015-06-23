---------------------------------------------------------------------
----                                                             ----
----  FPU                                                        ----
----  Floating Point Unit (Double precision)                     ----
----                                                             ----
----  Author: David Lundgren                                     ----
----          davidklun@gmail.com                                ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2009 David Lundgren                           ----
----                  davidklun@gmail.com                        ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
----     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ----
---- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ----
---- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ----
---- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ----
---- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ----
---- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ----
---- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ----
---- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ----
---- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ----
---- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ----
---- POSSIBILITY OF SUCH DAMAGE.                                 ----
----                                                             ----
---------------------------------------------------------------------

library ieee;
use work.fpupack.all;
use work.comppack.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;


entity fpu_double_tb is
end fpu_double_tb;

architecture TB_ARCHITECTURE of fpu_double_tb is

	component fpu_double
	port(
		clk : in std_logic;
		rst : in std_logic;
		enable : in std_logic;
		rmode : in std_logic_vector(1 downto 0);
		fpu_op : in std_logic_vector(2 downto 0);
		opa : in std_logic_vector(63 downto 0);
		opb : in std_logic_vector(63 downto 0);
		out_fp : out std_logic_vector(63 downto 0);
		ready : out std_logic;
		underflow : out std_logic;
		overflow : out std_logic;
		inexact : out std_logic;
		exception : out std_logic;
		invalid : out std_logic );
	end component;

	signal clk : std_logic;
	signal rst : std_logic;
	signal enable : std_logic;
	signal rmode : std_logic_vector(1 downto 0);
	signal fpu_op : std_logic_vector(2 downto 0);
	signal opa : std_logic_vector(63 downto 0);
	signal opb : std_logic_vector(63 downto 0);
	signal out_fp : std_logic_vector(63 downto 0);	   
	
	signal ready : std_logic;
	signal underflow : std_logic;
	signal overflow : std_logic;
	signal inexact : std_logic;
	signal exception : std_logic;
	signal invalid : std_logic;

	signal END_SIM: BOOLEAN:=FALSE;
	signal out_fp1 : std_logic_vector(63 downto 0);


begin
	out_fp1 <= out_fp;
	UUT : fpu_double
		port map (
			clk => clk,
			rst => rst,
			enable => enable,
			rmode => rmode,
			fpu_op => fpu_op,
			opa => opa,
			opb => opb,
			out_fp => out_fp,
			ready => ready,
			underflow => underflow,
			overflow => overflow,
			inexact => inexact,
			exception => exception,
			invalid => invalid
		);

	
STIMULUS: process
begin  



	rst <= '1';
    wait for 20 ns; 
	rst <= '0';
--inputA:4.0000000000e+000
--inputB:-4.0000000000e+000
enable <= '1';
opa <= "0100000000010000000000000000000000000000000000000000000000000000";
opb <= "1100000000010000000000000000000000000000000000000000000000000000";
fpu_op <= "000";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:0.000000000000000e+000
-- out_fp = 0000000000000000
--inputA:3.0000000000e-312
--inputB:1.0000000000e-025
enable <= '1';
opa <= "0000000000000000000000001000110101100000010101111101110111110010";
opb <= "0011101010111110111100101101000011110101110110100111110111011001";
fpu_op <= "011";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:3.000000000000337e-287
-- out_fp = 047245C02F8B68C5
--inputA:4.0000000000e-304
--inputB:2.0000000000e-007
enable <= '1';
opa <= "0000000011110001100011100011101110011011001101110100000101101001";
opb <= "0011111010001010110101111111001010011010101111001010111101001000";
fpu_op <= "010";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:8.000000000000074e-311
-- out_fp = 00000EBA09271E89
--inputA:3.4445600000e+002
--inputB:3.4445599000e+002
enable <= '1';
opa <= "0100000001110101100001110100101111000110101001111110111110011110";
opb <= "0100000001110101100001110100101110111100001010111001010011011001";
fpu_op <= "001";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.000000003159585e-005
-- out_fp = 3EE4F8B58A000000
--inputA:-8.8899000000e+002
--inputB:7.8898020000e+002
enable <= '1';
opa <= "1100000010001011110001111110101110000101000111101011100001010010";
opb <= "0100000010001000101001111101011101110011000110001111110001010000";
fpu_op <= "000";
rmode <= "11";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:-1.000098000000000e+002
-- out_fp = C05900A0902DE010
--inputA:4.5600000000e+002
--inputB:2.3700000000e+001
enable <= '1';
opa <= "0100000001111100100000000000000000000000000000000000000000000000";
opb <= "0100000000110111101100110011001100110011001100110011001100110011";
fpu_op <= "011";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.924050632911392e+001
-- out_fp = 40333D91D2A2067B
--inputA:4.9990000000e+003
--inputB:0.0000000000e+000
enable <= '1';
opa <= "0100000010110011100001110000000000000000000000000000000000000000";
opb <= "0000000000000000000000000000000000000000000000000000000000000000";
fpu_op <= "010";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:0.000000000000000e+000
-- out_fp = 0000000000000000
--inputA:-9.8883300000e+005
--inputB:4.4444440000e+006
enable <= '1';
opa <= "1100000100101110001011010100001000000000000000000000000000000000";
opb <= "0100000101010000111101000100011100000000000000000000000000000000";
fpu_op <= "001";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:-5.433277000000000e+006
-- out_fp = C154B9EF40000000
--inputA:-4.8000000000e-311
--inputB:4.0000000000e-050
enable <= '1';
opa <= "1000000000000000000010001101011000000101011111011101111100011111";
opb <= "0011010110101101111011100111101001001010110101001011100000011111";
fpu_op <= "011";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:-1.200000000000011e-261
-- out_fp = 89C2E4AE4EAE705E
--inputA:1.9500000000e-308
--inputB:1.8800000000e-308
enable <= '1';
opa <= "0000000000001110000001011010001000110110111111110101001011001101";
opb <= "0000000000001101100001001100011001100110111010010000011110011111";
fpu_op <= "000";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:3.830000000000000e-308
-- out_fp = 001B8A689DE85A6C
--inputA:-3.0000000000e-309
--inputB:9.0000000000e+100
enable <= '1';
opa <= "1000000000000010001010000100000001010111001110101111100100001100";
opb <= "0101010011100100100100101110001011001010010001110101101111101101";
fpu_op <= "010";
rmode <= "11";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:-2.700000000000001e-208
-- out_fp = 94D630F25FC26702
--inputA:3.0000000000e-308
--inputB:2.9900000000e-308
enable <= '1';
opa <= "0000000000010101100100101000001101101000010011011011101001110111";
opb <= "0000000000010101100000000001101011011100110111001101010001001011";
fpu_op <= "001";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.000000000000046e-310
-- out_fp = 000012688B70E62C
--inputA:-9.0000000000e-300
--inputB:5.0000000000e+100
enable <= '1';
opa <= "1000000111011000000110111110001110111011010110000001000111000100";
opb <= "0101010011010110110111000001100001101110111110011111010001011100";
fpu_op <= "011";
rmode <= "11";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:-4.940656458412465e-324
-- out_fp = 8000000000000001
--inputA:4.0000000000e+100
--inputB:3.0000000000e-090
enable <= '1';
opa <= "0101010011010010010010011010110100100101100101001100001101111101";
opb <= "0010110101011000011100011100011001000110111001011001010110100111";
fpu_op <= "010";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.200000000000000e+011
-- out_fp = 423BF08EB0000001
--inputA:-9.9000000000e-002
--inputB:4.0220000000e+001
enable <= '1';
opa <= "1011111110111001010110000001000001100010010011011101001011110010";
opb <= "0100000001000100000111000010100011110101110000101000111101011100";
fpu_op <= "000";
rmode <= "11";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:4.012100000000000e+001
-- out_fp = 40440F7CED916872
--inputA:9.0770000000e+001
--inputB:-2.0330000000e+001
enable <= '1';
opa <= "0100000001010110101100010100011110101110000101000111101011100001";
opb <= "1100000000110100010101000111101011100001010001111010111000010100";
fpu_op <= "000";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:7.044000000000000e+001
-- out_fp = 40519C28F5C28F5C
--inputA:4.9077000000e+002
--inputB:-3.4434000000e+002
enable <= '1';
opa <= "0100000001111110101011000101000111101011100001010001111010111000";
opb <= "1100000001110101100001010111000010100011110101110000101000111101";
fpu_op <= "001";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:8.351100000000000e+002
-- out_fp = 408A18E147AE147B
--inputA:9.0000000000e+034
--inputB:2.7700000000e+000
enable <= '1';
opa <= "0100011100110001010101010101011110110100000110011100010111000010";
opb <= "0100000000000110001010001111010111000010100011110101110000101001";
fpu_op <= "011";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:3.249097472924188e+034
-- out_fp = 471907B705EBEABE
--inputA:3.9999999989e-315
--inputB:1.0000000000e-002
enable <= '1';
opa <= "0000000000000000000000000000000000110000010000011010011100110101";
opb <= "0011111110000100011110101110000101000111101011100001010001111011";
fpu_op <= "010";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:4.000000428704504e-317
-- out_fp = 00000000007B895B
--inputA:-9.0000000000e+003
--inputB:8.0000000000e+003
enable <= '1';
opa <= "1100000011000001100101000000000000000000000000000000000000000000";
opb <= "0100000010111111010000000000000000000000000000000000000000000000";
fpu_op <= "011";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:-1.125000000000000e+000
-- out_fp = BFF2000000000000
--inputA:9.8440000000e+003
--inputB:0.0000000000e+000
enable <= '1';
opa <= "0100000011000011001110100000000000000000000000000000000000000000";
opb <= "0000000000000000000000000000000000000000000000000000000000000000";
fpu_op <= "011";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.#INF00000000000e+000
-- out_fp = 7FF0000000000000
--inputA:4.4440000000e+002
--inputB:-8.8800000000e+002
enable <= '1';
opa <= "0100000001111011110001100110011001100110011001100110011001100110";
opb <= "1100000010001011110000000000000000000000000000000000000000000000";
fpu_op <= "001";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.332400000000000e+003
-- out_fp = 4094D1999999999A
--inputA:3.0000000000e-309
--inputB:3.0000000000e+080
enable <= '1';
opa <= "0000000000000010001010000100000001010111001110101111100100001100";
opb <= "0101000010100100001111011011001101111101011101001011110010000111";
fpu_op <= "011";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:0.000000000000000e+000
-- out_fp = 0000000000000000
--inputA:4.9900000000e+002
--inputB:-3.3000000000e-003
enable <= '1';
opa <= "0100000001111111001100000000000000000000000000000000000000000000";
opb <= "1011111101101011000010001001101000000010011101010010010101000110";
fpu_op <= "010";
rmode <= "11";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:-1.646700000000000e+000
-- out_fp = BFFA58E219652BD4
--inputA:9.0000000000e+034
--inputB:4.0000000000e+023
enable <= '1';
opa <= "0100011100110001010101010101011110110100000110011100010111000010";
opb <= "0100010011010101001011010000001011000111111000010100101011110110";
fpu_op <= "000";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:9.000000000040000e+034
-- out_fp = 47315557B41A1A76
--inputA:4.0000000000e+080
--inputB:3.0000000000e-002
enable <= '1';
opa <= "0101000010101010111111001110111101010001111100001111101101011111";
opb <= "0011111110011110101110000101000111101011100001010001111010111000";
fpu_op <= "000";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:4.000000000000001e+080
-- out_fp = 50AAFCEF51F0FB60
--inputA:-5.4770000000e+000
--inputB:-8.9990000000e+000
enable <= '1';
opa <= "1100000000010101111010000111001010110000001000001100010010011100";
opb <= "1100000000100001111111110111110011101101100100010110100001110011";
fpu_op <= "011";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:6.086231803533726e-001
-- out_fp = 3FE379D751E6915E
--inputA:-7.7000000000e+001
--inputB:-8.8400000000e+001
enable <= '1';
opa <= "1100000001010011010000000000000000000000000000000000000000000000";
opb <= "1100000001010110000110011001100110011001100110011001100110011010";
fpu_op <= "010";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:6.806800000000001e+003
-- out_fp = 40BA96CCCCCCCCCE
--inputA:4.0000000000e+009
--inputB:3.0000000000e+008
enable <= '1';
opa <= "0100000111101101110011010110010100000000000000000000000000000000";
opb <= "0100000110110001111000011010001100000000000000000000000000000000";
fpu_op <= "011";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.333333333333333e+001
-- out_fp = 402AAAAAAAAAAAAB
--inputA:9.0000000000e-311
--inputB:8.0000000000e-311
enable <= '1';
opa <= "0000000000000000000100001001000101001010010011000000001001011010";
opb <= "0000000000000000000011101011101000001001001001110001111010001001";
fpu_op <= "000";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.700000000000010e-310
-- out_fp = 00001F4B537320E3
--inputA:1.9999777344e-320
--inputB:5.0000000000e+099
enable <= '1';
opa <= "0000000000000000000000000000000000000000000000000000111111010000";
opb <= "0101010010100010010010011010110100100101100101001100001101111101";
fpu_op <= "010";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:9.999888671826831e-221
-- out_fp = 124212D01E240533
--inputA:4.4444000000e+004
--inputB:3.3000000000e+001
enable <= '1';
opa <= "0100000011100101101100111000000000000000000000000000000000000000";
opb <= "0100000001000000100000000000000000000000000000000000000000000000";
fpu_op <= "011";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.346787878787879e+003
-- out_fp = 40950B26C9B26C9B
--inputA:9.7730000000e+000
--inputB:9.7720000000e+000
enable <= '1';
opa <= "0100000000100011100010111100011010100111111011111001110110110010";
opb <= "0100000000100011100010110100001110010101100000010000011000100101";
fpu_op <= "011";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.000102333196889e+000
-- out_fp = 3FF0006B4DDBBE31
--inputA:8.3345700000e+003
--inputB:1.0000000000e+000
enable <= '1';
opa <= "0100000011000000010001110100100011110101110000101000111101011100";
opb <= "0011111111110000000000000000000000000000000000000000000000000000";
fpu_op <= "010";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:8.334570000000000e+003
-- out_fp = 40C04748F5C28F5C
--inputA:-1.0000000000e+000
--inputB:5.8990000000e+003
enable <= '1';
opa <= "1011111111110000000000000000000000000000000000000000000000000000";
opb <= "0100000010110111000010110000000000000000000000000000000000000000";
fpu_op <= "010";
rmode <= "11";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:-5.899000000000000e+003
-- out_fp = C0B70B0000000000
--inputA:6.1000000000e+000
--inputB:-6.0990000000e+000
enable <= '1';
opa <= "0100000000011000011001100110011001100110011001100110011001100110";
opb <= "1100000000011000011001010110000001000001100010010011011101001100";
fpu_op <= "000";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:9.999999999994458e-004
-- out_fp = 3F50624DD2F1A000
--inputA:3.0000000000e-300
--inputB:3.0000000000e-015
enable <= '1';
opa <= "0000000111000000000100101001011111010010001110101011011010000011";
opb <= "0011110011101011000001011000011101101110010110110000000100100000";
fpu_op <= "010";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:9.000000001157124e-315
-- out_fp = 000000006C93B838
--inputA:-9.0000000000e+088
--inputB:4.0000000000e+084
enable <= '1';
opa <= "1101001001100110100111110000000010010101111101001101000000000000";
opb <= "0101000110000000011110001110000100010001110000110101010101101101";
fpu_op <= "000";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:-8.999600000000000e+088
-- out_fp = D2669EBEB27088F3
--inputA:6.6210000000e+001
--inputB:6.9892000000e+001
enable <= '1';
opa <= "0100000001010000100011010111000010100011110101110000101000111101";
opb <= "0100000001010001011110010001011010000111001010110000001000001100";
fpu_op <= "011";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:9.473187203113375e-001
-- out_fp = 3FEE506F59540645
--inputA:-5.0000000000e-309
--inputB:4.0000000000e-310
enable <= '1';
opa <= "1000000000000011100110000110101100111100000011001111010001101001";
opb <= "0000000000000000010010011010001000101101110000111001100010101100";
fpu_op <= "000";
rmode <= "11";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:-4.600000000000001e-309
-- out_fp = 80034EC90E495BBD
--inputA:8.8000000000e+001
--inputB:0.0000000000e+000
enable <= '1';
opa <= "0100000001010110000000000000000000000000000000000000000000000000";
opb <= "0000000000000000000000000000000000000000000000000000000000000000";
fpu_op <= "011";
rmode <= "01";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.#INF00000000000e+000
-- out_fp = 7FEFFFFFFFFFFFFF
--inputA:4.5570000000e+002
--inputB:3.4229100000e+003
enable <= '1';
opa <= "0100000001111100011110110011001100110011001100110011001100110011";
opb <= "0100000010101010101111011101000111101011100001010001111010111000";
fpu_op <= "000";
rmode <= "01";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:3.878610000000000e+003
-- out_fp = 40AE4D3851EB851E
--inputA:9.9440000000e+003
--inputB:2.3000000000e+001
enable <= '1';
opa <= "0100000011000011011011000000000000000000000000000000000000000000";
opb <= "0100000000110111000000000000000000000000000000000000000000000000";
fpu_op <= "011";
rmode <= "01";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:4.323478260869565e+002
-- out_fp = 407B0590B21642C8
--inputA:-9.0054400000e+005
--inputB:-3.4445500000e+005
enable <= '1';
opa <= "1100000100101011011110111000000000000000000000000000000000000000";
opb <= "1100000100010101000001100001110000000000000000000000000000000000";
fpu_op <= "001";
rmode <= "01";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:-5.560890000000000e+005
-- out_fp = C120F87200000000
--inputA:5.5500000000e-002
--inputB:3.2444400000e+005
enable <= '1';
opa <= "0011111110101100011010100111111011111001110110110010001011010001";
opb <= "0100000100010011110011010111000000000000000000000000000000000000";
fpu_op <= "011";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.710618781669564e-007
-- out_fp = 3E86F5A431628F6D
--inputA:1.2330000000e+000
--inputB:1.5666600000e+000
enable <= '1';
opa <= "0011111111110011101110100101111000110101001111110111110011101110";
opb <= "0011111111111001000100010000101000010011011111110011100011000101";
fpu_op <= "010";
rmode <= "10";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:1.931691780000000e+000
-- out_fp = 3FFEE835A3D0D51B
--inputA:9.7770000000e-001
--inputB:3.0000000000e+099
enable <= '1';
opa <= "0011111111101111010010010101000110000010101010011001001100001100";
opb <= "0101010010010101111100100000001011111001111001011011011101100011";
fpu_op <= "011";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:3.259000000000000e-100
-- out_fp = 2B46CF7665DCED50
--inputA:4.4000000000e+007
--inputB:6.0000000000e+002
enable <= '1';
opa <= "0100000110000100111110110001100000000000000000000000000000000000";
opb <= "0100000010000010110000000000000000000000000000000000000000000000";
fpu_op <= "010";
rmode <= "00";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:2.640000000000000e+010
-- out_fp = 4218964020000000
--inputA:3.9800000000e+000
--inputB:3.7700000000e+000
enable <= '1';
opa <= "0100000000001111110101110000101000111101011100001010001111010111";
opb <= "0100000000001110001010001111010111000010100011110101110000101001";
fpu_op <= "000";
rmode <= "01";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:7.750000000000000e+000
-- out_fp = 401F000000000000
--inputA:8.0400000000e+000
--inputB:8.0395700000e+000
enable <= '1';
opa <= "0100000000100000000101000111101011100001010001111010111000010100";
opb <= "0100000000100000000101000100001010000100110111111100111000110001";
fpu_op <= "001";
rmode <= "01";
wait for 20ns;
enable <= '0';
wait for 800 ns;
--Output:4.299999999997084e-004
-- out_fp = 3F3C2E33EFF18000


	END_SIM <= TRUE;

	wait;
end process; 
	
CLOCK_clk : process
begin
	
	if END_SIM = FALSE then
		clk <= '0';
		wait for 5 ns;
	else
		wait;
	end if;
	if END_SIM = FALSE then
		clk <= '1';
		wait for 5 ns; 
	else
		wait;
	end if;
end process;



end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_fpu_double of fpu_double_tb is
	for TB_ARCHITECTURE
		for UUT : fpu_double
			use entity work.fpu_double(rtl);
		end for;
	end for;
end TESTBENCH_FOR_fpu_double;

