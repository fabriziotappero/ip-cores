---------------------------------------------------------------------
----                                                             ----
----  Reed Solomon decoder/encoder IP core                       ----
----                                                             ----
----  Authors: Anatoliy Sergienko, Volodya Lepeha                ----
----  Company: Unicore Systems http://unicore.co.ua              ----
----                                                             ----
----  Downloaded from: http://www.opencores.org                  ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2006-2010 Unicore Systems LTD                 ----
---- www.unicore.co.ua                                           ----
---- o.uzenkov@unicore.co.ua                                     ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
---- THIS SOFTWARE IS PROVIDED "AS IS"                           ----
---- AND ANY EXPRESSED OR IMPLIED WARRANTIES,                    ----
---- INCLUDING, BUT NOT LIMITED TO, THE IMPLIED                  ----
---- WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT              ----
---- AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.        ----
---- IN NO EVENT SHALL THE UNICORE SYSTEMS OR ITS                ----
---- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,            ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL            ----
---- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT         ----
---- OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,               ----
---- DATA, OR PROFITS; OR BUSINESS INTERRUPTION)                 ----
---- HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,              ----
---- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING                 ----
---- IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,                 ----
---- EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.          ----
----                                                             ----
---------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {RS_EN4} architecture {RS_EN4}}

library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all;   
use type1.all;

entity RS_EN4 is   
	
--	generic( G_range:  integer := 4;
--		A_range:  integer := 9);
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		D_IN : in STD_LOGIC_VECTOR(7 downto 0);  
		STR : in STD_LOGIC;
		RD : in STD_LOGIC;
		D_OUT : out STD_LOGIC_VECTOR(7 downto 0);
		SNB : out STD_LOGIC
		);
end RS_EN4;

--}} End of automatically maintained section

architecture RS_EN4 of RS_EN4 is type trom is array(0 to 255) of integer; 
	
	--  GV4 : 1, 30,216,231,116	 
	
	constant rm30 : trom :=
	(0,30,60,34,120,102,68,90,240,238,204,210,136,150,180,170,253,227,193,223,133,155,185,
	167,13,19,49,47,117,107,73,87,231,249,219,197,159,129,163,189,23,9,43,53,111,113,83,
	77,26,4,38,56,98,124,94,64,234,244,214,200,146,140,174,176,211,205,239,241,171,181,151,
	137,35,61,31,1,91,69,103,121,46,48,18,12,86,72,106,116,222,192,226,252,166,184,154,132,
	52,42,8,22,76,82,112,110,196,218,248,230,188,162,128,158,201,215,245,235,177,175,141,
	147,57,39,5,27,65,95,125,99,187,165,135,153,195,221,255,225,75,85,119,105,51,45,15,17,
	70,88,122,100,62,32,2,28,182,168,138,148,206,208,242,236,92,66,96,126,36,58,24,6,172,
	178,144,142,212,202,232,246,161,191,157,131,217,199,229,251,81,79,109,115,41,55,21,11,
	104,118,84,74,16,14,44,50,152,134,164,186,224,254,220,194,149,139,169,183,237,243,209,
	207,101,123,89,71,29,3,33,63,143,145,179,173,247,233,203,213,127,97,67,93,7,25,59,37,
	114,108,78,80,10,20,54,40,130,156,190,160,250,228,198,216);
	
	
	constant rm216 : trom :=
	(0,216,173,117,71,159,234,50,142,86,35,251,201,17,100,188,1,217,172,116,70,158,235,51,143,
	87,34,250,200,16,101,189,2,218,175,119,69,157,232,48,140,84,33,249,203,19,102,190,3,219,
	174,118,68,156,233,49,141,85,32,248,202,18,103,191,4,220,169,113,67,155,238,54,138,82,39,
	255,205,21,96,184,5,221,168,112,66,154,239,55,139,83,38,254,204,20,97,185,6,222,171,115,65,
	153,236,52,136,80,37,253,207,23,98,186,7,223,170,114,64,152,237,53,137,81,36,252,206,22,99,
	187,8,208,165,125,79,151,226,58,134,94,43,243,193,25,108,180,9,209,164,124,78,150,227,59,
	135,95,42,242,192,24,109,181,10,210,167,127,77,149,224,56,132,92,41,241,195,27,110,182,11,
	211,166,126,76,148,225,57,133,93,40,240,194,26,111,183,12,212,161,121,75,147,230,62,130,90,
	47,247,197,29,104,176,13,213,160,120,74,146,231,63,131,91,46,246,196,28,105,177,14,214,163,
	123,73,145,228,60,128,88,45,245,199,31,106,178,15,215,162,122,72,144,229,61,129,89,44,244,
	198,30,107,179
	);
	
	
	constant rm231 : trom :=
	(0,231,211,52,187,92,104,143,107,140,184,95,208,55,3,228,214,49,5,226,109,138,190,89,189,
	90,110,137,6,225,213,50,177,86,98,133,10,237,217,62,218,61,9,238,97,134,178,85,103,128,
	180,83,220,59,15,232,12,235,223,56,183,80,100,131,127,152,172,75,196,35,23,240,20,243,
	199,32,175,72,124,155,169,78,122,157,18,245,193,38,194,37,17,246,121,158,170,77,206,41,
	29,250,117,146,166,65,165,66,118,145,30,249,205,42,24,255,203,44,163,68,112,151,115,148,
	160,71,200,47,27,252,254,25,45,202,69,162,150,113,149,114,70,161,46,201,253,26,40,207,251,
	28,147,116,64,167,67,164,144,119,248,31,43,204,79,168,156,123,244,19,39,192,36,195,247,16,
	159,120,76,171,153,126,74,173,34,197,241,22,242,21,33,198,73,174,154,125,129,102,82,181,58,
	221,233,14,234,13,57,222,81,182,130,101,87,176,132,99,236,11,63,216,60,219,239,8,135,96,84,
	179,48,215,227,4,139,108,88,191,91,188,136,111,224,7,51,212,230,1,53,210,93,186,142,105,141,
	106,94,185,54,209,229,2
	);
	
	constant rm116 : trom :=
	(0,116,232,156,205,185,37,81,135,243,111,27,74,62,162,214,19,103,251,143,222,170,54,66,148,
	224,124,8,89,45,177,197,38,82,206,186,235,159,3,119,161,213,73,61,108,24,132,240,53,65,221,
	169,248,140,16,100,178,198,90,46,127,11,151,227,76,56,164,208,129,245,105,29,203,191,35,87,
	6,114,238,154,95,43,183,195,146,230,122,14,216,172,48,68,21,97,253,137,106,30,130,246,167,
	211,79,59,237,153,5,113,32,84,200,188,121,13,145,229,180,192,92,40,254,138,22,98,51,71,219,
	175,152,236,112,4,85,33,189,201,31,107,247,131,210,166,58,78,139,255,99,23,70,50,174,218,
	12,120,228,144,193,181,41,93,190,202,86,34,115,7,155,239,57,77,209,165,244,128,28,104,173,
	217,69,49,96,20,136,252,42,94,194,182,231,147,15,123,212,160,60,72,25,109,241,133,83,39,
	187,207,158,234,118,2,199,179,47,91,10,126,226,150,64,52,168,220,141,249,101,17,242,134,26,
	110,63,75,215,163,117,1,157,233,184,204,80,36,225,149,9,125,44,88,196,176,102,18,142,250,
	171,223,67,55
	);
	type treg is array(A_range downto 0) of std_logic_vector(7 downto 0);  
	type treg1 is array(G_range + 1  downto 0) of std_logic_vector(7 downto 0);
	signal reg2 : treg;		
	signal reg,reg1 : treg1;
	signal run,snb1 : std_logic;	 
	signal cnt : std_logic_vector(7 downto 0); 
	signal pr30,pr216,pr231,pr116,sd : std_logic_vector(7 downto 0); 
	
begin
	
	process(clk,rst)  
	begin  			
		if rst = '1' then 
			reg <= (others => (others => '0'));	 
			reg1 <= (others => (others => '0'));
			cnt <= (others => '0');	
			run <= '0';	  
			snb1 <= '0';
		elsif clk= '1' and clk'event then 	  
			if str = '1' then           			run <= '1';
			elsif cnt = (A_range) then	run <= '0';
			end if;
			if str = '1' then 						cnt <= (others => '0');
			elsif run = '1' then					cnt <= cnt + 1;
			end if;		
			if cnt = (A_range) then	snb1 <= '1';  
			else     								snb1 <= '0'; 
			end if;							
			
			if snb1 = '1' then	  
				reg <= (others => (others => '0'));
			elsif run = '1' then   	 
				reg(4) <= (pr30 xor reg(3));
				reg(3) <= (pr216 xor reg(2));
				reg(2) <= (pr231 xor reg(1));
				reg(1) <= (pr116 xor reg(0));
				reg(0) <= D_IN;
			end if;		 
			
			if run = '1' then 
				reg2(A_range downto 1) <= reg2(A_range - 1 downto 0);
				reg2(0) <=  d_in; 
			elsif snb1 = '1' then	
				reg2(4) <= reg(4); 
				reg2(3) <= reg(3);
				reg2(2) <= reg(2); 
				reg2(1) <= reg(1);
			elsif rd = '1' then
				reg2(A_range downto 1) <= reg2(A_range - 1 downto 0);
			end if;		
		end if;
	end process; 
	snb <= snb1;
	D_OUT <= reg2(A_range);  			  		   
	
	sd <= reg(G_range ); 
	
	pr30  <= conv_std_logic_vector (rm30(conv_integer(sd)),8);
	pr216 <= conv_std_logic_vector (rm216(conv_integer(sd)),8);	  
	pr231 <= conv_std_logic_vector (rm231(conv_integer(sd)),8);
	pr116 <= conv_std_logic_vector (rm116(conv_integer(sd)),8);
	
	
end RS_EN4;
