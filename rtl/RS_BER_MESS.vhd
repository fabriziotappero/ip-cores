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
--{entity {RS_BER_MESS} architecture {RS_BER_MESS}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all;     
use type1.all;

entity RS_BER_MESS is		 
	--generic( G_range:  integer := 4;
--		A_range:  integer := 9);
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		STR : in STD_LOGIC;
		D_IN : in STD_LOGIC_VECTOR(7 downto 0);
		S_OK : out STD_LOGIC;
		SNB : out STD_LOGIC;
		D_OUT : out kgx8; 
		D_OUT1 : out tregA  
		);
end RS_BER_MESS;


architecture RS_BER_MESS of RS_BER_MESS is 
	
component VEC_MUL is
	 port(
		 CLK : in STD_LOGIC;
		 RST : in STD_LOGIC;  		 
		 m_d : in STD_LOGIC;
		 A,B : in kgx8;	  
		 C : out kgx8
	     );
end component;	

type trom2 is array(0 to 255) of integer;  --(2**i v G8 )
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
44, 88, 176,125,250,233,207,131,27, 54, 108,216,173,71, 142,1
);

constant rmx2 : trom2 :=
(
1,  4,  16, 64, 29, 116,205,19 ,76, 45, 180,234,143,6,  24, 96,
157,78, 37, 148,106,181,238,159,70, 5,  20, 80, 93, 105,185,222,
95, 97, 153,94, 101,137,30, 120,253,211,107,177,254,223,91, 113,
217,67, 17, 68, 13, 52, 208,103,129,62, 248,199,59, 236,151,102,
133,46, 184,218,79, 33, 132,42, 168,154,82, 85, 73, 57, 228,183,
230,191,198,63, 252,215,123,241,227,171,150,98, 149,110,165,174,
130,50, 200,7,  28, 112,221,83, 81, 89, 121,249,195,43, 172,138,
18, 72, 61, 244,247,251,203,11, 44, 176,250,207,27, 108,173,142,
2,  8,  32, 128,58, 232,135,38, 152,90, 117,201,3,  12, 48, 192,
39, 156,74, 53, 212,119,193,35, 140,10, 40, 160,186,210,111,161,
190,194,47, 188,202,15, 60, 240,231,187,214,127,225,163,182,226,
175,134,34, 136,26, 104,189,206,31, 124,237,147,118,197,51, 204,
23, 92, 109,169,158,66, 21, 84, 77, 41, 164,170,146,114,213,115,
209,99, 145,126,229,179,246,255,219,75, 49, 196,55, 220,87, 65,
25, 100,141,14, 56, 224,167,166,162,178,242,239,155,86, 69, 9,
36, 144,122,245,243,235,139,22, 88, 125,233,131,54, 216,71, 1 
);
	


	type treg1 is array(G_range-1  downto 0) of std_logic_vector(7 downto 0);	
	signal reg,reg1,reg2,reg3,reg4: kgx8;   	
	signal rg0,rg1,rg2: kgx8; 
	signal s1,s2,s3,md,run,r1,s10 : std_logic;  
	signal cnt,cnt1,cnt2,cnt3 : std_logic_vector (7 downto 0) := (others => '0'); 
	signal del,Q,L,M,subb  : std_logic_vector (7 downto 0) := (others => '0'); 
	
	
	signal cnt4,sm,cnt5,cnt4i,cnt6 : std_logic_vector (7 downto 0) := (others => '0'); 	
	signal reg6i,reg6,reg5,reg7,reg8: kgx8;  
	signal rn0,rn1,rn2,md1,rn00,rn01 : std_logic;	  
--	type tregA is array(A_range - 1 downto 0) of std_logic_vector(7 downto 0); 
	signal rgA1,rgA2,rgA3,rgAo : tregA; 
	signal er0,er1 : std_logic_vector (7 downto 0):= (others => '0');  
	signal er10,er11 : std_logic_vector (7 downto 0):= (others => '0');	
	signal ercnt : std_logic_vector (7 downto 0):= (others => '0');
	signal r11 : std_logic;
	
	
	
begin
	process(clk,rst) 	
	begin  			 
		if rst = '1' then
			s1 <= '0'; 	
			s2 <= '0';
			cnt <= x"00"; 
			reg <= (others => (others => '0'));
		elsif clk = '1' and clk'event then	
			if str = '1' then s1 <= '1'; 
			elsif (cnt = G_range -1 and s1 = '1') then s1 <= '0'; 
			end if; 
			if str = '1' then cnt <= (others => '0'); 
			elsif (cnt /= G_range -1 and s1 = '1') then cnt <= cnt + 1; 
			end if;	 
			if s1 = '1' then
				reg (conv_integer(cnt)) <= d_in;
			end if;		
			s2 <= s1;
			s3 <= not s1 and s2;
		end if;	
	end process;	
	
	process(clk,rst)  
	begin  
		if rst = '1' then 					   		
			reg1 <= (others => (others => '0'));				   		
			reg2 <= (others => (others => '0'));					   		
			reg3 <= (others => (others => '0'));	
		elsif clk = '1' and clk'event then	
			-- S
			if s3 = '1' then reg1 <= reg; --reg1(0) <= reg(3);reg1(1) <= reg(2);reg1(2) <= reg(1);reg1(3) <= reg(0);
			end if;	  
			-- L* 
			if cnt3 = x"06" and del /= x"00" then
				for i in 0 to G_range-1 loop reg4(i) <= reg2(i) xor rg0(i); end loop;	
			end if;	
			-- L
			if s3 = '1' then 
				reg2(0) <= x"01";
			for i in 1 to G_range-1 loop reg2(i) <= x"00"; end loop;  
			elsif run = '1' and cnt3 = x"08" and del /= x"00" then
				for i in 0 to G_range-1 loop reg2(i) <= reg4(i); end loop;
			end if;
			-- B
			if s3 = '1' then 
				reg3(0) <= x"00";reg3(1) <= x"01";
				for i in 2 to G_range-1 loop reg3(i) <= x"00"; end loop; 
			elsif cnt3 = x"08" then
				if del /= x"00" and subb(7) = '1' then	 
					reg3(0) <= x"00";
					for i in 1 to G_range-1 loop reg3(i) <= rg0(i-1); end loop;
				else	
					reg3(0) <= x"00";
					for i in 1 to G_range-1 loop reg3(i) <= reg3(i-1); end loop;
				end if;	
			end if;
		end if;
	end process;   
	process(clk,rst)  
	begin  
		if rst = '1' then 					   		
			cnt3 <= x"00";		
		elsif clk = '1' and clk'event then		
			if s3 = '1' or cnt3 = x"09" then cnt3 <= x"00";
			else cnt3 <= cnt3 + 1;
			end if;	
			if run = '1' then
			if cnt3 = x"01" then rg1 <= reg2;
		
				case Q is
					when x"00"  => rg2(0) <= reg1(0);rg2(1) <= x"00";	rg2(2) <= x"00";  rg2(3) <= x"00";
					when x"01"  => rg2(0) <= reg1(1);rg2(1) <= reg1(0);	rg2(2) <= x"00";  rg2(3) <= x"00";  
					when x"02"  => rg2(0) <= reg1(2);rg2(1) <= reg1(1);	rg2(2) <= reg1(0);rg2(3) <= x"00";
					when others => rg2(0) <= reg1(3);rg2(1) <= reg1(2);	rg2(2) <= reg1(1);rg2(3) <= reg1(0);
				end case;				
				md <= '0';
			elsif cnt3 = x"04" then rg1 <= (others => del); rg2 <= reg3; md <= '0';
			elsif cnt3 = x"05" then rg1 <= (others => del); rg2 <= reg2; md <= '1';	
			end if;	  
			else   	 
				md <= '0';
				if cnt4 = x"01" then 
				rg2(0) <= reg5(0); rg2(1) <= reg5(0); rg2(2) <= reg5(1); rg2(3) <= x"00"; 
				rg1(0) <= reg1(0); rg1(1) <= reg1(1); rg1(2) <= reg1(0); rg1(3) <= x"00";
				elsif cnt4 = x"02" then   
				rg2(0) <= reg5(2); rg2(1) <= reg5(1); rg2(2) <= reg5(0); rg2(3) <= x"00"; 
				rg1(0) <= reg1(0); rg1(1) <= reg1(1); rg1(2) <= reg1(2); rg1(3) <= x"00";
				elsif cnt4 = x"03" then   
				rg2(0) <= reg5(2); rg2(1) <= reg5(1); rg2(2) <= reg5(0);  rg2(3) <= x"00"; 
				rg1(0) <= reg1(1); rg1(1) <= reg1(2); rg1(2) <= reg1(3);  rg1(3) <= x"00";
				end if;	
			end if;	 
			if cnt3 = x"03" then  	
			--	del <= rg0(0) xor rg0(1) xor rg0(2) xor rg0(3);				
					case L is 
						when x"00"  => del <= rg0(0);
						when x"01"  => del <= rg0(0) xor rg0(1);
						when x"02"  => del <= rg0(0) xor rg0(1) xor rg0(2);
						when others => del <= rg0(0) xor rg0(1) xor rg0(2) xor rg0(3);	
					end case;				
				
			end if;			
		end if;
	end process;   
	
	
MULL:	VEC_MUL 
	 port map(
		 CLK => clk,
		 RST => rst,		 
		 m_d => md,
		 A => rg2, B => rg1,	  
		 C => rg0
	     );
process(clk,rst)  
	begin  
		if rst = '1' then 					   		
			run <= '0';	 r1 <= '0';
			Q <= x"00";
			M <= x"FF";
			L <= x"00";	   
			s_ok <= '0';  
			--snb <= '0';	   
			d_out <= (others => (others => '0'));
		elsif clk = '1' and clk'event then		
			if s3 = '1'  then run <= '1';
			elsif Q = x"04" then  run <= '0';	
			end if;	 
			if s3 = '1'  then Q <= x"00";
			elsif cnt3 = x"09"	and run = '1' then Q <= Q + 1;
			end if;	 
			if s3 = '1'  then M <= x"FF";
			elsif (cnt3 = x"04" and subb(7) = '1' and del /= x"00")	then M <= Q - L;
			end if;		  
			if s3 = '1'  then L <= x"00";
			elsif run = '1' and (cnt3 = x"04" and subb(7) = '1' and del /= x"00")	then L <= Q - M;
			end if;	
			if cnt3 = x"02"	then  subb <= L - Q + M; end if;	
				r1 <= run;	
			if r1 = '1' and run = '0' then d_out <= reg2; end if;
			--	snb <= not run and r1;
			if s3 = '1' then s_ok <= '0';	
		--	elsif r1 = '1' and run = '0' then s_ok <= s10;	  
			elsif rn01 = '1' and rn00 = '0' and (ercnt =  L) then s_ok <= s10;
			end if;	
		end if;
	end process; 	
	s10 <= '1' when reg2(3) = x"00" and 
	((reg2(2) /= x"00" and L = x"02") or 
	(reg2(2) = x"00" and reg2(1) /= x"00" and L = x"01")) else '0';	
		
--- адреса и полином ошибок	
process(clk,rst)  
	begin  
		if rst = '1' then 					   		
			reg5 <= (others => (others => '0')); 					   		
			reg6 <= (others => (others => '0')); 				   		
			reg8 <= (others => (others => '0')); 
			cnt4 <= x"00";			  
			cnt4i <= x"00";
			rn0 <= '0';      
			rn00 <= '0';     
			md1 <= '0';	  
			r11 <= '0';
		elsif clk = '1' and clk'event then	
			
			--rn00 <= rn0;  
			rn00 <= r11;    
		if r1 = '1' and run = '0' then 
		  	reg5 <= reg2;   
			md1 <= '0';
		elsif rn2 = '1' and cnt6 = x"01" then reg5 <= reg8;   
		elsif rn2 = '1' and cnt6 = x"05" then reg5(0) <= er10; reg5(1) <= er11; md1 <= '1';
		end if; 
			r11 <= rn0; 
			if r1 = '1' and run = '0' then cnt4 <= x"00";
			elsif cnt4 /= x"FF" then cnt4 <= cnt4 + 1;
			end if;	
			if r1 = '1' and run = '0' then rn0 <= '1';  
			elsif cnt4 = x"FF" then rn0 <= '0'; --elsif cnt4i = x"FF" then rn0 <= '0';
			end if;	  
			if cnt4 = x"03" then 
				reg8(0) <= rg0(0);
				reg8(1) <= rg0(1) xor rg0(2);  
			elsif cnt4 = x"04" then  
				reg8(2) <= rg0(0) xor rg0(1) xor rg0(2); 
			elsif cnt4 = x"05" then 
				reg8(3) <= rg0(2) xor rg0(1) xor rg0(0);
			end if;		
			cnt4i <= cnt4; 
			if rn0 = '1' then 
			reg6(0) <= x"01";
			reg6(1) <= conv_std_logic_vector (tb2si(conv_integer(cnt4)),8); 
			reg6(2) <= conv_std_logic_vector (rmx2(conv_integer(cnt4)),8); 
			reg6(3) <= x"00";	
			elsif rn2 = '1' and cnt6 = x"01" then  
			reg6(0) <= x"01";	
			reg6(1) <= rgA1(conv_integer(er0));
			reg6(2) <= rgA2(conv_integer(er0));
			reg6(3) <= rgA3(conv_integer(er0));
			elsif rn2 = '1' and cnt6 = x"02" then	
			reg6(0) <= x"01";	
			reg6(1) <= rgA1(conv_integer(er1));
			reg6(2) <= rgA2(conv_integer(er1));
			reg6(3) <= rgA3(conv_integer(er1));	 
		    elsif rn2 = '1' and cnt6 = x"05" then 
				reg6(0) <= reg2(1); reg6(1) <= reg2(1); 
			end if;
			
		end if;
	end process;  
	
MULL1:	VEC_MUL 
	 port map(
		 CLK => clk,
		 RST => rst,		 
		 m_d => md1,
		 A => reg5, B => reg6,	  
		 C => reg7
	     );	
		
sm <= reg7(2) xor reg7(1) xor reg7(0);	
process(clk,rst)  
	begin  
		if rst = '1' then 					   		
			rgA3 <= (others => (others => '0')); 	   		
			rgA2 <= (others => (others => '0')); 	   		
			rgA1 <= (others => (others => '0')); 
			cnt5 <= x"FF";	
			er0 <= (others => '0');	 
			er1 <= (others => '0');	 
			ercnt  <= (others => '0');	 
			rn01  <= '0';
		elsif clk = '1' and clk'event then	
			rn01 <= rn00;
            cnt5 <= 255 - cnt4i;	 
			reg6i <= reg6;
			if cnt5 < A_range then
			if sm = x"00" and rn00 = '1' then
				rgA1(conv_integer(cnt5)) <= reg6i(1); 
				rgA2(conv_integer(cnt5)) <= reg6i(2);  
				rgA3(conv_integer(cnt5)) <= reg6i(3); 				
			end if;	 
			end if;
			
			if r1 = '1' and run = '0' then 	ercnt  <= (others => '0');
			elsif sm = x"00" and rn00 = '1' and cnt5 < A_range then 
				ercnt  <= ercnt + 1; 
			end if;
			
			if cnt5 < A_range then
			if sm = x"00" and rn00 = '1' then
			if ercnt = x"00" then 
				er0 <= cnt5; er1  <= cnt5;
			elsif ercnt = x"01" then
				er0 <= cnt5; 
			end if;	
			end if;	
			end if;
		end if;
	end process;  
	
	
----	
process(clk,rst)  
	begin  
		if rst = '1' then 
			cnt6 <= x"00";	
			rn1 <= '0';    rn2 <= '0';		   		
			rgAo <= (others => (others => '0'));  
			snb <= '0';	  
			rn2 <= '0';
		elsif clk = '1' and clk'event then
			rn1 <= rn0;
		if rn1 = '1' and rn0 = '0' then cnt6 <= x"00"; 
			elsif cnt6 /= x"10" then cnt6 <= cnt6 + 1; 
		end if;  
		if rn1 = '1' and rn0 = '0' then  rn2 <= '1';
		elsif cnt6 = x"10" then  rn2 <= '0';
		end if;  
		
		if cnt6 = x"09" then  d_out1 <= rgAo;	end if;  
			
		if cnt6 = x"0A" then  snb <= rn2; else snb <= '0';	end if; 	
		if cnt6 = x"03" then  er10 <= sm;	end if; 	
		if cnt6 = x"04" then  er11 <= sm;	end if; 	
		if str = '1' then  rgAo <= (others => (others => '0'));  
		elsif cnt6 = x"07" then  
		rgAo(conv_integer(er0)) <= reg7(0);	 
		rgAo(conv_integer(er1)) <= reg7(1);	
		end if; 			
		end if;
	end process;  
	
	

end RS_BER_MESS;

	