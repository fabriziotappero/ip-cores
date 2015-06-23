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


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all;    
use type1.all;

entity RS_DEC_SINDDROM is		 
	--generic( G_range:  integer := 4;
--	A_range:  integer := 9);
	 port(
		 CLK : in STD_LOGIC;
		 RST : in STD_LOGIC;
		 STR : in STD_LOGIC;
		 D_IN : in STD_LOGIC_VECTOR(7 downto 0);
		 RD : in STD_LOGIC;
		 D_OUT : out STD_LOGIC_VECTOR(7 downto 0);
		 S_er : out STD_LOGIC;
		 SNB : out STD_LOGIC; 
		 D_OUT1 : out tregA
	     );
end RS_DEC_SINDDROM;

--}} End of automatically maintained section

architecture RS_DEC_SINDDROM of RS_DEC_SINDDROM is 
-- 
--type trom2 is array(0 to 255) of integer;  --(2**i v G8 )  
type trom2 is array(0 to 1020) of integer;  --(2**i v G8 )
constant tb2si : trom2 :=(
1,  2,  4,  8,  16, 32, 64, 128,29, 58, 116,232,205,135,19, 38, 
76, 152,45, 90, 180,117,234,201,143,3,  6,  12, 24, 48, 96, 192,
157,39, 78, 156,37, 74, 148,53,	106,212,181,119,238,193,159,35,
70, 140,5,  10, 20, 40, 80, 160,93, 186,105,210,185,111,222,161,
95, 190,97, 194,153,47, 94, 188,101,202,137,15, 30, 60, 120,240,
253,231,211,187,107,214,177,127,254,225,223,163,91, 182,113,226,
217,175,67, 134,17, 34, 68, 136,13, 26, 52, 104,208,189,103,206,
129,31, 62, 124,248,237,199,147,59, 118,236,197,151,51, 102,204,
133,23, 46, 92, 184,109,218,169,79, 158,33, 66, 132,21, 42, 84,
168,77, 154,41, 82, 164,85, 170,73, 146,57, 114,228,213,183,115,
230,209,191,99, 198,145,63, 126,252,229,215,179,123,246,241,255,
227,219,171,75, 150,49, 98, 196,149,55, 110,220,165,87, 174,65,
130,25, 50, 100,200,141,7,  14, 28, 56, 112,224,221,167,83, 166,
81, 162,89, 178,121,242,249,239,195,155,43, 86, 172,69, 138,9,
18, 36, 72, 144,61, 122,244,245,247,243,251,235,203,139,11, 22,
44, 88, 176,125,250,233,207,131,27, 54, 108,216,173,71, 142,1,	

    2,  4,  8,  16, 32, 64, 128,29, 58, 116,232,205,135,19, 38, 
76, 152,45, 90, 180,117,234,201,143,3,  6,  12, 24, 48, 96, 192,
157,39, 78, 156,37, 74, 148,53,	106,212,181,119,238,193,159,35,
70, 140,5,  10, 20, 40, 80, 160,93, 186,105,210,185,111,222,161,
95, 190,97, 194,153,47, 94, 188,101,202,137,15, 30, 60, 120,240,
253,231,211,187,107,214,177,127,254,225,223,163,91, 182,113,226,
217,175,67, 134,17, 34, 68, 136,13, 26, 52, 104,208,189,103,206,
129,31, 62, 124,248,237,199,147,59, 118,236,197,151,51, 102,204,
133,23, 46, 92, 184,109,218,169,79, 158,33, 66, 132,21, 42, 84,
168,77, 154,41, 82, 164,85, 170,73, 146,57, 114,228,213,183,115,
230,209,191,99, 198,145,63, 126,252,229,215,179,123,246,241,255,
227,219,171,75, 150,49, 98, 196,149,55, 110,220,165,87, 174,65,
130,25, 50, 100,200,141,7,  14, 28, 56, 112,224,221,167,83, 166,
81, 162,89, 178,121,242,249,239,195,155,43, 86, 172,69, 138,9,
18, 36, 72, 144,61, 122,244,245,247,243,251,235,203,139,11, 22,
44, 88, 176,125,250,233,207,131,27, 54, 108,216,173,71, 142,1,	 

    2,  4,  8,  16, 32, 64, 128,29, 58, 116,232,205,135,19, 38, 
76, 152,45, 90, 180,117,234,201,143,3,  6,  12, 24, 48, 96, 192,
157,39, 78, 156,37, 74, 148,53,	106,212,181,119,238,193,159,35,
70, 140,5,  10, 20, 40, 80, 160,93, 186,105,210,185,111,222,161,
95, 190,97, 194,153,47, 94, 188,101,202,137,15, 30, 60, 120,240,
253,231,211,187,107,214,177,127,254,225,223,163,91, 182,113,226,
217,175,67, 134,17, 34, 68, 136,13, 26, 52, 104,208,189,103,206,
129,31, 62, 124,248,237,199,147,59, 118,236,197,151,51, 102,204,
133,23, 46, 92, 184,109,218,169,79, 158,33, 66, 132,21, 42, 84,
168,77, 154,41, 82, 164,85, 170,73, 146,57, 114,228,213,183,115,
230,209,191,99, 198,145,63, 126,252,229,215,179,123,246,241,255,
227,219,171,75, 150,49, 98, 196,149,55, 110,220,165,87, 174,65,
130,25, 50, 100,200,141,7,  14, 28, 56, 112,224,221,167,83, 166,
81, 162,89, 178,121,242,249,239,195,155,43, 86, 172,69, 138,9,
18, 36, 72, 144,61, 122,244,245,247,243,251,235,203,139,11, 22,
44, 88, 176,125,250,233,207,131,27, 54, 108,216,173,71, 142,1,

    2,  4,  8,  16, 32, 64, 128,29, 58, 116,232,205,135,19, 38, 
76, 152,45, 90, 180,117,234,201,143,3,  6,  12, 24, 48, 96, 192,
157,39, 78, 156,37, 74, 148,53,	106,212,181,119,238,193,159,35,
70, 140,5,  10, 20, 40, 80, 160,93, 186,105,210,185,111,222,161,
95, 190,97, 194,153,47, 94, 188,101,202,137,15, 30, 60, 120,240,
253,231,211,187,107,214,177,127,254,225,223,163,91, 182,113,226,
217,175,67, 134,17, 34, 68, 136,13, 26, 52, 104,208,189,103,206,
129,31, 62, 124,248,237,199,147,59, 118,236,197,151,51, 102,204,
133,23, 46, 92, 184,109,218,169,79, 158,33, 66, 132,21, 42, 84,
168,77, 154,41, 82, 164,85, 170,73, 146,57, 114,228,213,183,115,
230,209,191,99, 198,145,63, 126,252,229,215,179,123,246,241,255,
227,219,171,75, 150,49, 98, 196,149,55, 110,220,165,87, 174,65,
130,25, 50, 100,200,141,7,  14, 28, 56, 112,224,221,167,83, 166,
81, 162,89, 178,121,242,249,239,195,155,43, 86, 172,69, 138,9,
18, 36, 72, 144,61, 122,244,245,247,243,251,235,203,139,11, 22,
44, 88, 176,125,250,233,207,131,27, 54, 108,216,173,71, 142,1

);

component mul_g8 is
	 port(
		 clk : in STD_LOGIC;
		 rst : in STD_LOGIC;		 
		 m_d : in STD_LOGIC;
		 a : in STD_LOGIC_VECTOR(7 downto 0);
		 b : in STD_LOGIC_VECTOR(7 downto 0);
		 res : out STD_LOGIC_VECTOR(7 downto 0)
	     );
end component;


type treg is array(A_range - 1 downto 0) of std_logic_vector(7 downto 0);  
type treg1 is array(G_range + 1  downto 0) of std_logic_vector(7 downto 0);
signal reg2 : tregA;	
signal reg,reg1 : treg1; 

signal cnt,cnt1,cnt2,rg0 : std_logic_vector (9 downto 0) := (others => '0'); 
signal data,dm : std_logic_vector (7 downto 0);  
signal run, st1, run1,s0,s1,s2,r1 : std_logic; 
signal m2i : std_logic_vector (7 downto 0);  
signal ds : std_logic_vector (7 downto 0);  
signal	rgA :  tregA;  
signal dd :integer;
begin
process(clk,rst) 	
begin  			 
	if rst = '1' then
		cnt <=  (others => '0');
		cnt1 <= (others => '0'); 
		cnt2 <= (others => '0');
		run <= '0';	 
		st1 <= '0';	   
		rg0 <= conv_std_logic_vector(A_range -1,10);
	elsif clk = '1' and clk'event then	 
	if str = '1' then st1 <= '1'; end if; 
	if str = '1' then cnt <= (others => '0'); 
	elsif (cnt /= A_range -1 and st1 = '1') then cnt <= cnt + 1; 
	end if;
	if (str = '1' or (cnt1 = 0 and cnt2 = G_range)or cnt2 = G_range + 1) then run <= '0'; 
	elsif cnt = A_range -1 then run <= '1'; 
	end if;
	
	if str = '1' then rg0 <= conv_std_logic_vector(A_range -1,10);
	elsif cnt1 = 0 then rg0 <= rg0 + conv_std_logic_vector(A_range -1,10); 
	end if;	
	if str = '1' then  cnt1 <=  conv_std_logic_vector(A_range -1,10); 
	elsif cnt1 = 0 then cnt1 <= rg0 + conv_std_logic_vector(A_range -1,10); 
	elsif run = '1' then cnt1 <= cnt1 - cnt2;	
	end if;	
	if str = '1' then cnt2 <= ext("01",10);
	elsif cnt1 = 0 then cnt2 <= cnt2 + 1; end if;  
		r1 <= run;
		if r1 = '0' and run = '1' then d_out1 <= reg2; end if;
	end if;	
end process;		  

data <= d_in when run = '0' else reg2(A_range -1);
process(clk) 	
begin  			 
	if clk = '1' and clk'event then	
		reg2(A_range - 1 downto 1) <= reg2(A_range - 2 downto 0);
		reg2(0) <= data; 
	end if;	
end process;   	
m2i <= conv_std_logic_vector(tb2si(conv_integer(cnt1)),8);
dd <= conv_integer(cnt1);

mul : mul_g8 
	 port map(
		 clk => clk, rst => rst,	 
		 m_d => '0',
		 a => m2i,	 b => data,
		 res => dm
	     );	
process(clk,rst) 	
begin  			 
	if rst = '1' then
		ds <=  (others => '0');
		run1 <= '0'; 
		s0 <= '0';
		s1 <= '0';
	elsif clk = '1' and clk'event then
	if run = '1' and cnt1 = 0 then s0 <= '1'; else s0 <= '0'; end if; 
		s1 <= s0;
		run1 <= run;
		if run1 = '0' then ds <= x"00";
		elsif s1 = '1' then ds <= dm;	
		else ds <= ds xor dm; 
		end if;
		if s1 = '1' then
			reg(g_range downto 1) <= reg(g_range -1 downto 0);
			reg(0) <= ds;
		end if;	   
		if str = '1' then s_er <= '0';
		elsif s1 = '1' and ds /= x"00" then s_er <= '1';
		end if;
		
		
	end if;	
end process;			 
process(clk,rst) 
begin
	if rst = '1' then	 
		snb <= '0';
	elsif clk = '1' and clk'event then
		s2 <= s1 and not run;
		if s2 = '1' then 
			reg1 <= reg; 
		else
	   		reg1(g_range downto 1) <= reg1(g_range -1 downto 0);reg1(0) <= x"00";
		end if; 
		snb <= s2;	 
		d_out <= reg1(g_range -1);
	end if;	
end process;


	 -- enter your statements here --

end RS_DEC_SINDDROM;
