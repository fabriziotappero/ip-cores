---------------------------------------------------------------------
----                                                             ----
----  DCT IP core                                                ----
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
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
--		DESCRIPTION:
--
--	FUNCTION	 Discrete Cosine Transform of   8 samples using algorithm by
--							Arai, Agui, and Nakajama
--                       input data bit width: 8 bit ,	signed or unsigned
--      	         output   data bit width: 10 bit   
--                       coefficient bit width: 11 bit         
--			Synthesable for  FPGAs of any vendor, preferably for Xilinx FPGA
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


library IEEE;
use IEEE.std_logic_1164.all;	 
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

entity DCT8AAN1 is 		
	generic( d_signed:integer:=1;--1 input data signed 0 - unsigned, and for compression 1/2 is subtracted
		scale_out:integer:=1); -- 1 output data are scaled 0 - genuine DCT 
	port (
		CLK: in STD_LOGIC;
		RST: in STD_LOGIC;		
		START: in STD_LOGIC;	     -- after this impulse the 0-th datum is sampled
		EN: in STD_LOGIC;		     -- operation enable to slow-down the calculations
		DATA_IN: in STD_LOGIC_VECTOR (7 downto 0);
		RDY: out   STD_LOGIC;	  -- delayed START impulse, after it the 0-th result is outputted
		DATA_OUT: out STD_LOGIC_VECTOR (9 downto 0) --  output data
		);
end DCT8AAN1;


architecture STAGE of DCT8AAN1 is   
	
	type Tarr8 is array(0 to 7) of STD_LOGIC_VECTOR (10 downto 0);	
	type Tarr16 is array (0 to 15) of STD_LOGIC_VECTOR (7 downto 0);
	signal sr16:TARR16:=(others=>(others=>'0'));                 -- SRL16 array
	
	constant S:Tarr8:=--(0.5/sqrt(2.0), 0.25/cos(pii*1.0),0.25/cos(pii*2.0),0.25/cos(pii*3.0),
	-- 0.25/cos(pii*4.0),0.25/cos(pii*5.0),0.25/cos(pii*6.0),0.25/cos(pii*7.0));
	(conv_std_logic_vector(integer(0.35355*2.0**9),11),
	conv_std_logic_vector(integer(0.2549*2.0**9),11),
	conv_std_logic_vector(integer(0.2706*2.0**9),11),			
	conv_std_logic_vector(integer(0.30067*2.0**9),11),	 
	conv_std_logic_vector(integer(0.35355*2.0**9),11),
	conv_std_logic_vector(integer(0.44999*2.0**9),11),
	conv_std_logic_vector(integer(0.65328*2.0**9),11),
	conv_std_logic_vector(integer(1.2815*2.0**9),11) );
	
	constant m1  : STD_LOGIC_VECTOR (10 downto 0) := conv_std_logic_vector(integer(0.70711*2.0**9),11); --cos(pii*4.0); -- 
	constant m2  : STD_LOGIC_VECTOR (10 downto 0) := conv_std_logic_vector(integer(0.38268*2.0**9),11);--cos(pii*6.0);  --
	constant m3  : STD_LOGIC_VECTOR (10 downto 0) := conv_std_logic_vector(integer(0.5412 *2.0**9),11);--(cos(pii*2.0) - cos(pii*6.0)); -- 
	constant m4  : STD_LOGIC_VECTOR (10 downto 0) := conv_std_logic_vector(integer(1.3066*2.0**9),11);--cos(pii*2.0) + cos(pii*6.0);  --
	
	constant zeros : STD_LOGIC_VECTOR (5 downto 0) := (others => '0');	
	constant a1_2 : STD_LOGIC_VECTOR (7 downto 0) := "10"&zeros;	  
	
	signal sr: STD_LOGIC_VECTOR (10 downto 0) ;
	
	signal cycle,ad1,cycle6: integer range 0 to 7;	 
	signal cycles: integer range 0 to 31;	 
	signal di,a1,a2,a3,a4: STD_LOGIC_VECTOR (7 downto 0);	
	signal bp,bm,b1,b2,b3,b4,b6:STD_LOGIC_VECTOR (8 downto 0);  	
	signal cp,cm,c1,c2,c3,c4:STD_LOGIC_VECTOR (10 downto 0);		  
	signal dp,dm:STD_LOGIC_VECTOR (11 downto 0);	   
	signal rd:STD_LOGIC_VECTOR (11 downto 0);	   
	
	signal ep:STD_LOGIC_VECTOR (22 downto 0);  		  
	signal e27:STD_LOGIC_VECTOR (10 downto 0);	 	   
	signal m1_4:STD_LOGIC_VECTOR (10 downto 0);	 	   
	signal fp,fm,f45,s7,s07,spt:STD_LOGIC_VECTOR (11 downto 0);   
	signal SP : 	STD_LOGIC_VECTOR (22 downto 0);  
	
	
begin	   	 	 
	UU_COUN0:process(CLK,RST)
	begin
		if RST = '1' then	
			cycle <=0;	   
			cycle6 <=(-6) mod 8;	
			ad1<= ( - 5) mod 8;	  
			cycles <=16;				  
			RDY<='0';
		elsif CLK = '1' and CLK'event then 	
			if en = '1' then		
				RDY<='0';
				if START = '1' then	   
					cycle <=0;		
					cycle6 <=(-6) mod 8;	
					ad1<= ( - 5) mod 8;	  
					cycles <=0;	
				elsif en = '1' then	
					cycle<=(cycle +1) mod 8 ;	  
					cycle6<=(cycle6 +1) mod 8 ;	  
					ad1<=(ad1 +1) mod 8;  
					if cycles=15 then 
						RDY<='1';  
					end if;
					if cycles/=17	then
						cycles<=(cycles +1) ;	  
					end if;		
				end if;		  
			end if;
		end if;
	end process;	   			 
	
	SRL16_a:process(CLK)  begin                        --  SRL16
		if CLK'event and CLK='1' then 
			if en='1' and (cycle=1 or cycle=2 or cycle=3 or cycle=4) then	 
				sr16<=di & sr16(0 to 14);                  -- shift SRL16		  
			end if;
		end if;
	end process;	 
	a1<= sr16(ad1);                 -- output from SRL16
	
	
	SM_B:process(clk,rst)	
	begin
		if RST = '1' then	  
			di <= (others => '0');		  
			bp <= (others => '0');      
			bm <= (others => '0');
		elsif CLK = '1' and CLK'event then 	 
			if en = '1' then	  				  
				if 	d_signed =0 then
					di<=unsigned(DATA_IN) - unsigned( a1_2);
				else
					di<=DATA_IN;
				end if;	   
				bp<=SXT(di,9) + a1;
				bm<=a1 - SXT(di,9);
			end if;
		end if;
	end process;	   	
	
	SM_C:process(clk,rst)	
	begin
		if RST = '1' then	  
			b1 <= (others => '0');		  
			b2 <= (others => '0');      
			b3 <= (others => '0');
			b4 <= (others => '0');		  
			b6 <= (others => '0');      
			cp <= (others => '0');
			cm <= (others => '0');	
			c1 <= (others => '0');
			
		elsif CLK = '1' and CLK'event then 	 
			if en = '1' then	  	
				b1<=bp;
				b2<=b1;
				if cycle = 2 then 
					b3<=b4;
				else
					b3<=b2;
				end if;
				b4<=b3;
				b6<=bm;
				case cycle is
					when 0|1|7 =>cp<=SXT(bm,11)+b6;	
					when 2|3 =>cp<= SXT(b2,11)+b3;
					when others=> cp<=cp+c1;
				end case;
				c1<=cp;
				
				if 	cycle=2 or  cycle=3 then
					cm<=SXT(b2,11) - b3;
				else
					cm<=cp - c1;
				end if;	   
				
			end if;
		end if;
	end process;	  
	
	
	SM_D:process(clk,rst)	
	begin
		if RST = '1' then	  
			c2 <= (others => '0');      
			c3 <= (others => '0');
			c4 <= (others => '0');		  
			--s6 <= (others => '0');      
			dp <= (others => '0');
			dm <= (others => '0');	
		elsif CLK = '1' and CLK'event then 	 
			if en = '1' then	  	
				if cycle=3 or  cycle=4 or cycle=5 then
					c2<=cm;											
				end if;
				if cycle = 1 then 
					c3<=c1;
				end if;						 
				if cycle = 2 then 
					c4<=SXT(b6,11);	
				elsif cycle=5 then
					c4<=c2;
				end if;		   
				if cycle = 4 then 
					dp<= SXT(cm, 12)+c2(10 downto 0); 
				else
					dp<= ep(20 downto 9)+c4(10 downto 0); 
				end if;	   
				
				if cycle = 2 then 
					dm<= c3(10 downto 0) - SXT(cp, 12); 
				elsif cycle=3  or cycle =7 then
					dm<= c4(10 downto 0) - ep(20 downto 9); 		
				end if;		   
				
			end if;
		end if;
	end process;	 	  
	
	MPU1:process(clk,rst)	
	begin
		if CLK = '1' and CLK'event then 	 
			if en = '1' then
				case cycle is
					when 1|5 => m1_4<=m1;
					when 2 => m1_4<=m4;
					when 3 => m1_4<=m2;
					when others => m1_4<=m3;
				end case ;	   
				case cycle is
					when 1|2 => rd<= SXT(cp,12);
					when 3 => rd<=dm;
					when 4 => rd<= SXT(c3,12);
					when others => rd<=dp;
				end case ;	   
				ep<=rd*m1_4;
				e27<= ep(19 downto 9);
			end if;
		end if;
	end process;	   
	
	SM_F:process(clk,rst)	
	begin
		if RST = '1' then	  
			fp <= (others => '0');		  
			fm <= (others => '0');      
			f45 <= (others => '0');		   
			s7 <= (others => '0');		   
		elsif CLK = '1' and CLK'event then 	 
			if en = '1' then	  				  
				case 	cycle is
					when 3 =>	fp<=ep(19 downto 9) + SXT(c4,12);
					when 5 =>	fp<=ep(19 downto 9) + SXT(e27,12);
					when 6|0 =>	fp<=fp + f45;				
					when 7 =>	fp<=e27 +f45; 	
					when others=> null;
				end case;	   
				
				if cycle=4 then
					f45<=fp;
				elsif cycle=6 then
					f45<=SXT(e27,12);	
				elsif cycle=7 or cycle=0 then
					f45<=SXT(dm,12);
				end if;
				fm<=f45 - fp;
				if cycle=7 then
					s7<=fm;
				end if;
			end if;
		end if;
	end process;	   
	
	MPU2:process(clk,rst)	
	begin
		if CLK = '1' and CLK'event then 	 
			if en = '1' then
				sr<=s(cycle6);
				case cycle is
					when 6 => s07<= SXT(c1,12);
					when 7|3 => s07<=fp;
					when 0 => s07<= SXT(dp,12);
					when 1 => s07<= SXT(fm,12);
					when 2 => s07<= SXT(c2,12);
					when 4 => s07<= SXT(f45,12);
					when others => s07<=s7;
				end case ;	  
				if 	scale_out =0 then
					sp<=s07*sr;	 
					DATA_OUT <=sp(18 downto 9);		  
				else	 
					spt<=s07;	 
					DATA_OUT <= spt(10 downto 1);	
				end if;
			end if;
		end if;
	end process;	 
	
	
end STAGE;
