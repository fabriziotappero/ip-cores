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
--	FUNCTION	2-D Discrete Cosine Transform of  for 8x8 samples using algorithm by
--							Arai, Agui, and Nakajama
--                       input data bit width: 8 bit ,	signed or unsigned
--      		 output   data bit width: 12 bit   
--                       coefficient bit width: 11 bit.         											
--			When output data are scaled then the number of multipliers is equal to 2. 
--			Buffer memories are based on FIFO
--			Synthesable for  FPGAs of any vendor, preferably for Xilinx FPGA					 
--	
--	
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity DCT_AAN is  
	generic(
		d_signed:integer:=1;	--1 input data signed; 0 - unsigned, and for compression 1/2 is subtracted
		scale_out:integer:=0); 		   -- 1 output data are scaled; 0 - genuine DCT 
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		START: in STD_LOGIC;	     -- after this impulse the 0-th datum is sampled
		EN: in STD_LOGIC;		     -- operation enable to slow-down the calculations
		DATA_IN : in STD_LOGIC_VECTOR(7 downto 0);
		RDY : out STD_LOGIC;
		DATA_OUT : out STD_LOGIC_VECTOR(11 downto 0)
		);
end DCT_AAN;				  

architecture CONSTR of DCT_AAN is	
	
	component DCT8AAN1 is 		
		generic( d_signed:integer:=1;		   --1 input data signed 0 - unsigned, and for compression 1/2 is subtracted
			scale_out:integer:=0); 		   -- 1 output data are scaled 0 - genuine DCT 
		port (
			CLK: in STD_LOGIC;
			RST: in STD_LOGIC;		
			START: in STD_LOGIC;	     -- after this impulse the 0-th datum is sampled
			EN: in STD_LOGIC;		     -- operation enable to slow-down the calculations
			DATA_IN: in STD_LOGIC_VECTOR (7 downto 0);
			RDY: out   STD_LOGIC;	  -- delayed START impulse, after it the 0-th result is outputted
			DATA_OUT: out STD_LOGIC_VECTOR (9 downto 0) --  output data
			);
	end  component ;
	
	component DCT8AAN2 is 		
		generic( d_signed:integer:=1;	--1 input data signed; 0 - unsigned, and for compression 1/2 is subtracted
			scale_out:integer:=0); 		   -- 1 output data are scaled; 0 - genuine DCT 
		port (
			CLK: in STD_LOGIC;
			RST: in STD_LOGIC;		
			START: in STD_LOGIC;	     -- after this impulse the 0-th datum is sampled
			EN: in STD_LOGIC;		     -- operation enable to slow-down the calculations
			DATA_IN: in STD_LOGIC_VECTOR (9 downto 0);
			RDY: out   STD_LOGIC;	  -- delayed START impulse, after it the 0-th result is outpitted
			DATA_OUT: out STD_LOGIC_VECTOR (11 downto 0) --  output data
			);
	end	 component;				 
	
	component DCT_BUF is 
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
	end	component ;		  
	
	signal rdy1,rdy2,rdy3 :	STD_LOGIC;
	signal data1,data1r: STD_LOGIC_VECTOR (9 downto 0);
	signal data2: STD_LOGIC_VECTOR (11 downto 0);
	
	
begin	 
	
	U_ST1: DCT8AAN1  		
	generic map( d_signed=>d_signed,		   --1 input data signed 0 - unsigned, and for compression 1/2 is subtracted
				scale_out=>scale_out) 		   -- 1 output data are scaled 0 - genuine DCT 
	port map(CLK, RST, 	
				START =>START,	     -- after this impulse the 0-th datum is sampled
				EN =>EN, 		     -- operation enable to slow-down the calculations
				DATA_IN =>DATA_IN, 
				RDY =>rdy1,	  -- delayed START impulse, just after it the 0-th result is outputted
				DATA_OUT=>data1 --  output data
				);
	   
	U_B1:DCT_BUF  
	generic map( wi=> 10    -- input data width
		) 	   
	port map(CLK, 	RST,		
				START=>rdy1,     -- after this impulse the 0-th datum is sampled
				EN=>EN,		     -- operation enable to slow-down the calculations
				DATA_IN=>data1,
				RDY=>rdy2,	  -- delayed START impulse, after it the 0-th result is outputted
				DATA_OUT=>data1r --  output data
				);
				
	U_ST2: DCT8AAN2  		
	generic map( d_signed=>1,		   --1 input data signed 0 - unsigned, and for compression 1/2 is subtracted
				scale_out=>scale_out) 		   -- 1 output data are scaled 0 - genuine DCT 
	port map(CLK, RST, 	
				START =>rdy2,	     -- after this impulse the 0-th datum is sampled
				EN =>EN, 		     -- operation enable to slow-down the calculations
				DATA_IN =>data1r, 
				RDY =>rdy3,	  -- delayed START impulse, after it the 0-th result is outputted
				DATA_OUT=>data2 --  output data
				);			  
				
	U_B2:DCT_BUF  
	generic map( wi=> 12    -- input data width
		) 	   
	port map(CLK, 	RST,		
				START=>rdy3,     -- after this impulse the 0-th datum is sampled
				EN=>EN,		     -- operation enable to slow-down the calculations
				DATA_IN=>data2,
				RDY=>RDY,	  -- delayed START impulse, after it the 0-th result is outputted
				DATA_OUT=>DATA_OUT --  output data
				);

	
end CONSTR;
