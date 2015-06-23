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

library IEEE;
use IEEE.std_logic_1164.all;   
use IEEE.std_logic_arith.all;   
use IEEE.math_real.all;   

entity TEST_DCT is	 
	generic( SIGNED_DATA : integer:= 1;   --  input data - 0 - unsigned, 1 - signed
	RANDOM:integer:=0; 				 --1 - random test data 	; 0 - predefined   
	scale_out:integer:=0	 );

end TEST_DCT;



architecture TEST_DCT of TEST_DCT is   

	signal DATAIN : STD_LOGIC_VECTOR (7 downto 0);
	signal DCT,dct1 : STD_LOGIC_VECTOR (11 downto 0);
	signal DCTi : STD_LOGIC_VECTOR (11 downto 0);
	signal DCTRES : integer;
	signal DCTRES_STD : integer;
	signal DCT_STD : STD_LOGIC_VECTOR (11 downto 0);
	signal ERROR : integer;
	signal QUADMEAN : REAL;
	signal READY,ready1 : STD_LOGIC;
	signal READY_STD : STD_LOGIC;
	signal START,EN : STD_LOGIC;
	signal CLK,clk1 : STD_LOGIC;
	signal RST : STD_LOGIC;	  
	
	signal r,rb,max, serror1,	num,num1, serror : integer;
	
	
	component  DCT_AAN is  
		generic(
			d_signed:integer:=1;	--1 input data signed; 0 - unsigned, and for compression 1/2 is subtracted
			scale_out:integer:=1); 		   -- 1 output data are scaled; 0 - genuine DCT 
		port(
			CLK : in STD_LOGIC;
			RST : in STD_LOGIC;
			START: in STD_LOGIC;	     -- after this impulse the 0-th datum is sampled
			EN: in STD_LOGIC;		     -- operation enable to slow-down the calculations
			DATA_IN : in STD_LOGIC_VECTOR(7 downto 0);
			RDY : out STD_LOGIC;
			DATA_OUT : out STD_LOGIC_VECTOR(11 downto 0)
			);
	end component;				  
	
	component DCT_BEH	  	
		generic(  SIGNED_DATA: integer);
		port (
			CLK : in STD_LOGIC;
			DATAIN : in STD_LOGIC_VECTOR (7 downto 0);
			RST : in STD_LOGIC;
			EN: in STD_LOGIC;   
			START : in STD_LOGIC;
			DATAOUT : out STD_LOGIC_VECTOR (11 downto 0);
			READY : out STD_LOGIC := '0'
			);
	end component;		
	
	component BMP_GENERATOR	 
		generic(  SIGNED_DATA : integer:= 0;   --  input data - 0 - unsigned, 1 - signed
	RANDOM:integer:=1 );
		port (
			CLK : in STD_LOGIC;
			RST : in STD_LOGIC;
			DATA : out STD_LOGIC_VECTOR (7 downto 0);
			START : out STD_LOGIC
			);
	end component; 
	
	
	
begin
	
	process begin CLK<='0'; wait for 5ns;CLK<='1'; wait for 5ns;
	end process;
	process begin RST<='1'; wait for 50ns;RST<='0'; wait;
	end process;
	
	en <= '1';					  
	clk1 <= clk; 
	
	U1 : BMP_GENERATOR 
	generic map( SIGNED_DATA,    --  input data - 0 - unsigned, 1 - signed
	RANDOM)
	port map(
		CLK => CLK,
		DATA => DATAIN,
		RST => RST,
		START => START
		);	
	
	U2 : DCT_AAN	   	
	generic map( d_SIGNED => SIGNED_DATA, scale_out =>scale_out )
	port map(
		CLK => CLK1,
		DATA_IN => DATAIN,		
		EN => EN,
		DATA_OUT => DCT,
		RDY => READY,
		RST => RST,
		START => START
		);
	
		
	U3 : DCT_BEH	  
	generic map( SIGNED_DATA => SIGNED_DATA)
	port map(
		CLK => CLK,
		DATAIN => DATAIN,
		DATAOUT => DCT_STD,
		EN => EN,
		READY => READY_STD,
		RST => RST,
		START => START
		);
	
	
	
	r<=CONV_INTEGER(SIGNED(DCT));	  
	rb<=CONV_INTEGER(SIGNED(DCT_STD));		 	  
	ERROR <= r - rb;	
	
	ERROR_CALC:process(start,error,  READY_STD,clk)
		variable SUMERROR:integer;			 
		variable start_acc:boolean:=false;
	begin 			  
		if start = '1' or RST='1' then   
			max <= 0;  serror1 <= 0;	num <= 0;     serror <= 0;
			QUADMEAN<=0.0;	 SUMERROR:=0;  
			start_acc:=false;
		end if;			
		if READY='1' then
			start_acc:=true;		  
		end if;
		if READY_STD = '0' and READY_STD'event then	
			num <= num + 1;		 	
			serror <= 0;
			serror1 <= serror;		
			if start_acc then
				SUMERROR:=serror;		 -- SUMERROR  + 
			end if;
			if num>0 then
				QUADMEAN<=SQRT(REAL(SUMERROR)/(64.0*REAL(num)));
			end if;
			if max <  serror  		then
				max <= serror; 
				num1 <= num;
			end if;
		end if;		 
		if clk = '1' and clk'event  and start_acc then
			serror <= serror + (error * error);		--
		end if;	 
		
	end process;
	
	
end TEST_DCT;
