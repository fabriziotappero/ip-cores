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
--DESCRIPTION:
--
--	FUNCTION	 64 data are stored to the FIFO buffer
--			64 data read from FIFO taps in the transposed order.
--		        Synthesable for Xilinx  FPGAs.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


library IEEE;
use IEEE.std_logic_1164.all;	 
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

entity DCT_BUF is 
	generic( wi: integer:= 10    -- input data width
		); 	   
	port (
		CLK: in STD_LOGIC;
		RST: in STD_LOGIC;		
		START: in STD_LOGIC;	     -- after this impulse the 0-th datum is sampled
		EN: in STD_LOGIC;		     -- operation enable to slow-down the calculations
		DATA_IN: in STD_LOGIC_VECTOR (wi-1 downto 0);
		RDY: out   STD_LOGIC;	  -- delayed START impulse, after it the 0-th result is outputted
		DATA_OUT: out STD_LOGIC_VECTOR (wi-1 downto 0) --  output data
		);
end DCT_BUF;


architecture SRL16 of DCT_BUF is   
	
	constant rnd: STD_LOGIC:='0';
	
	type Tarr100 is array (0 to 99) of STD_LOGIC_VECTOR (wi -1 downto 0);	 
	type Tarr64i is array (0 to 63) of integer range 0 to 127 ;	 
	constant Addrr:Tarr64i:=
	(49,50-8,  51-16,52-24,  53-32,54-40,55-48,56-56,
	56, 57-8,  58-16,59-24,  60-32,61-40,62-48,63-56,
	63, 64-8,  65-16,66-24,  67-32,68-40,69-48,70-56,  
	70, 71-8,  72-16,73-24,  74-32,75-40,76-48,77-56,
	
	77, 78-8,  79-16,80-24,  81-32,82-40,83-48,84-56,
	84, 85-8,  86-16,87-24,  88-32,89-40,90-48,91-56,
	91, 92-8,  93-16,94-24,  95-32,96-40,97-48,98-56,
	98, 99-8,100-16,101-24,102-32,103-40,104-48,105-56);
									   
	signal sr64:TARR100:=(others=>(others=>'0'));                                                -- масив регiстрiв SRL16
	
	
	signal cycle,ad1: integer range 0 to 63;	 
	signal  ad2: integer range 0 to 99;	 
	signal cycles: integer range 0 to 63;	 	 
	
	
begin	   	 	 
	UU_COUN:process(CLK,RST)
	begin
		if RST = '1' then	
			ad1<= ( - 5) mod 64;	  
			cycles <=63;				  
			RDY<='0';
		elsif CLK = '1' and CLK'event then 	
			if en = '1' then		
				RDY<='0';
				if START = '1' then	   
					ad1<= ( - 48) mod 64;	  
					cycles <=0;	
				elsif en = '1' then	
					ad1<=(ad1 +1) mod 64;  	 
					RDY<='0';
					if cycles/=63 then 
						cycles<=(cycles +1) ;
					end if;
					if 	cycles=48 then
						RDY<='1';	
						ad1 <=0;
					end if;		
				end if;		  
			end if;
		end if;
	end process;	   			 
	
	SRL16_a:process(CLK)  begin                        --  SRL16
		if CLK'event and CLK='1' then 
			if en='1' then	 
				sr64<=DATA_IN & sr64(0 to 98);                  -- shift SRL16		  
				ad2<=  Addrr(ad1) ;			   --FIFO address recoding
			end if;
		end if;
	end process;	 		   
	
	DATA_OUT <=sr64(ad2);                 -- output from SRL16
	
	
	
	
	
	
end SRL16;
