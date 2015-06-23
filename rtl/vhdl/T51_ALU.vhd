--
-- 8051 compatible microcontroller core
--
-- Version : 0300
--
-- Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
--           (c) 2004-2005 Andreas Voggeneder (andreas.voggeneder@fh-hagenberg.at)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--	http://www.opencores.org/cvsweb.shtml/t51/
--
-- Limitations :
--
-- File history :
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.T51_Pack.all;

entity T51_ALU is
  generic(
		tristate  : integer := 0
	);
	port(
		Clk			: in std_logic;
		Last		: in std_logic;
		OpCode		: in std_logic_vector(7 downto 0);
		ACC			: in std_logic_vector(7 downto 0);
		B			: in std_logic_vector(7 downto 0);
		IA			: in std_logic_vector(7 downto 0);
		IB			: in std_logic_vector(7 downto 0);
		Bit_Pattern	: in std_logic_vector(7 downto 0);
		CY_In		: in std_logic;
		AC_In		: in std_logic;
		ACC_Q		: out std_logic_vector(7 downto 0);
		B_Q			: out std_logic_vector(7 downto 0);
		IDCPBL_Q	: out std_logic_vector(7 downto 0);
		Div_Rdy		: out std_logic;
		CJNE		: out std_logic;
		DJNZ		: out std_logic;
		CY_Out		: out std_logic;
		AC_Out		: out std_logic;
		OV_Out		: out std_logic;
		CY_Wr		: out std_logic;
		AC_Wr		: out std_logic;
		OV_Wr		: out std_logic
	);
end T51_ALU;

architecture rtl of T51_ALU is

	signal	Do_A_Imm	: std_logic;
	signal	Do_A_Carry	: std_logic;
	signal	Do_A_RR		: std_logic;
	signal	Do_A_INC	: std_logic;
	signal	Do_A_RRC	: std_logic;
	signal	Do_A_DEC	: std_logic;
	signal	Do_A_RL		: std_logic;
	signal	Do_A_ADD	: std_logic;
	signal	Do_A_RLC	: std_logic;
	signal	Do_A_ORL	: std_logic;
	signal	Do_A_ANL	: std_logic;
	signal	Do_A_XRL	: std_logic;
	signal	Do_A_MOV	: std_logic;
	signal	Do_A_DIV	: std_logic;
	signal	Do_A_SUBB	: std_logic;
	signal	Do_A_MUL	: std_logic;
	signal	Do_A_CJNE 	: std_logic;
	signal	Do_A_SWAP	: std_logic;
	signal	Do_A_XCH	: std_logic;
	signal	Do_A_DA		: std_logic;
	signal	Do_A_XCHD	: std_logic;
	signal	Do_A_CLR	: std_logic;
	signal	Do_A_CPL	: std_logic;

	-- Accumulator ALU input mux
	signal	AOP2		: std_logic_vector(7 downto 0);

	-- AD intermediate signal
	signal	ADA			: std_logic_vector(8 downto 0);

	-- AddSub intermediate signals
	signal	AS_Carry7	: std_logic;
	signal	AS_AC		: std_logic;
	signal	AS_CY		: std_logic;
	signal	AS_Q		: std_logic_vector(7 downto 0);

	signal	Do_I_Imm	: std_logic;
	signal	Do_I_INC	: std_logic;
	signal	Do_I_DEC	: std_logic;
	signal	Do_I_ORL	: std_logic;
	signal	Do_I_ANL	: std_logic;
	signal	Do_I_XRL	: std_logic;
	signal	Do_I_MOV	: std_logic;
	signal	Do_I_MOVD	: std_logic;
	signal	Do_I_CJNE	: std_logic;

	-- Auxiliary ALU input mux
	signal	IOP			: std_logic_vector(7 downto 0);

	-- Auxiliary ALU delayed input
	signal	IA_d		: std_logic_vector(7 downto 0);

	-- AddSub intermediate signals
	signal	CJNE_CY_n	: std_logic;
	signal	CJNE_Q		: std_logic_vector(7 downto 0);
	signal  CJNE_Q_ZERO : std_logic;
	signal  CJNE_CY     : std_logic;

	-- MOV intermediate signals
	signal	MOV_Op		: std_logic_vector(3 downto 0);
	signal	MOV_Q		: std_logic_vector(7 downto 0);

	signal	Do_B_Inv	: std_logic;
	signal	Do_B_C_BA	: std_logic;
	signal	Do_B_C_Dir	: std_logic;
	signal	Do_B_BA_Dir	: std_logic;
	signal	Do_B_MOV	: std_logic;
	signal	Do_B_JBC	: std_logic;
	signal	Do_B_Op		: std_logic_vector(1 downto 0);

	-- Bit intermediate signals
	signal	Bit_Op1		: std_logic_vector(7 downto 0);
	signal	Bit_Op2		: std_logic_vector(7 downto 0);
	signal	Bit_IsOne	: std_logic;
	signal	Bit_Result	: std_logic_vector(7 downto 0);

	signal	Last_r		: std_logic;

	-- MulDiv intermediate signals
	signal	Mul_Q		: std_logic_vector(15 downto 0);
	signal	Mul_OV		: std_logic;
	signal	Div_Q		: std_logic_vector(15 downto 0);
	signal	Div_OV		: std_logic;

begin

	-- Simplify some of the conditions, not all must be exclusive !!!!

	process (Clk)
	begin
		if Clk'event and Clk = '1' then

			-- ACC Operations

			Do_A_Imm <= '0';
			Do_A_Carry <= '0';
			Do_A_RR <= '0';
			Do_A_INC <= '0';
			Do_A_RRC <= '0';
			Do_A_DEC <= '0';
			Do_A_RL <= '0';
			Do_A_ADD <= '0';
			Do_A_RLC <= '0';
			Do_A_ORL <= '0';
			Do_A_ANL <= '0';
			Do_A_XRL <= '0';
			Do_A_MOV <= '0';
			Do_A_DIV <= '0';
			Do_A_SUBB <= '0';
			Do_A_MUL <= '0';
			Do_A_CJNE <= '0';
			Do_A_SWAP <= '0';
			Do_A_XCH <= '0';
			Do_A_DA <= '0';
			Do_A_XCHD <= '0';
			Do_A_CLR <= '0';
			Do_A_CPL <= '0';
			Do_A_Imm <= '0';
			if OpCode(3 downto 0) = "0100" then
				Do_A_Imm <= '1';
			end if;
			if OpCode = "00000011" then
				-- 00000011 1 RR    A
				Do_A_RR <= '1';
			end if;
			if OpCode = "00000100" then
				-- 00000100 1 INC   A
				Do_A_INC <= '1';
			end if;
			if OpCode = "00010011" then
				-- 00010011 1 RRC   A
				Do_A_RRC <= '1';
			end if;
			if OpCode = "00010100" then
				-- 00010100 1 DEC   A
				Do_A_DEC <= '1';
			end if;
			if OpCode = "00100011" then
				-- 00100011 1 RL    A
				Do_A_RL <= '1';
			end if;
			if OpCode = "00100100" or
				OpCode = "00100101" or
				OpCode(7 downto 1) = "0010011" or
				OpCode(7 downto 3) = "00101" then
				-- 00100100 2 ADD   A,#data
				-- 00100101 2 ADD   A,data addr
				-- 0010011i 1 ADD   A,@Ri
				-- 00101rrr 1 ADD   A,Rn
				Do_A_ADD <= '1';
			end if;
			if OpCode = "00110011" then
				-- 00110011 1 RLC   A
				Do_A_RLC <= '1';
			end if;
			if OpCode = "00110100" or
				OpCode = "00110101" or
				OpCode(7 downto 1) = "0011011" or
				OpCode(7 downto 3) = "00111" then
				-- 00110100 2 ADDC  A,#data
				-- 00110101 2 ADDC  A,data addr
				-- 0011011i 1 ADDC  A,@Ri
				-- 00111rrr 1 ADDC  A,Rn
				Do_A_ADD <= '1';
				Do_A_Carry <= '1';
			end if;
			if OpCode = "01000100" or
				OpCode = "01000101" or
				OpCode(7 downto 1) = "0100011" or
				OpCode(7 downto 3) = "01001" then
				-- 01000100 2 ORL   A,#data
				-- 01000101 2 ORL   A,data addr
				-- 0100011i 1 ORL   A,@Ri
				-- 01001rrr 1 ORL   A,Rn
				Do_A_ORL <= '1';
			end if;
			if OpCode = "01010100" or
				OpCode = "01010101" or
				OpCode(7 downto 1) = "0101011" or
				OpCode(7 downto 3) = "01011" then
				-- 01010100 2 ANL   A,#data
				-- 01010101 2 ANL   A,data addr
				-- 0101011i 1 ANL   A,@Ri
				-- 01011rrr 1 ANL   A,Rn
				Do_A_ANL <= '1';
			end if;
			if OpCode = "01100100" or
				OpCode = "01100101" or
				OpCode(7 downto 1) = "0110011" or
				OpCode(7 downto 3) = "01101" then
				-- 01100100 2 XRL   A,#data
				-- 01100101 2 XRL   A,data addr
				-- 0110011i 1 XRL   A,@Ri
				-- 01101rrr 1 XRL   A,Rn
				Do_A_XRL <= '1';
			end if;
			if OpCode = "01110100" or
				OpCode = "11100101" or
				OpCode(7 downto 1) = "1110011" or
				OpCode(7 downto 3) = "11101" then
				-- 01110100 2 MOV   A,#data
				-- 10000011 1 MOVC  A,@A+PC		-- Not handled here
				-- 10010011 1 MOVC  A,@A+DPTR	-- Not handled here
				-- 11100000 1 MOVX  A,@DPTR
				-- 1110001i 1 MOVX  A,@Ri
				-- 11100101 2 MOV   A,data addr
				-- 1110011i 1 MOV   A,@Ri
				-- 11101rrr 1 MOV   A,Rn
				Do_A_MOV <= '1';
			end if;
			if OpCode = "10000100" then
				-- 10000100 1 DIV   AB
				Do_A_DIV <= '1';
			end if;
			if OpCode = "10010100" or
				OpCode = "10010101" or
				OpCode(7 downto 1) = "1001011" or
				OpCode(7 downto 3) = "10011" then
				-- 10010100 2 SUBB  A,#data
				-- 10010101 2 SUBB  A,data addr
				-- 1001011i 1 SUBB  A,@Ri
				-- 10011rrr 1 SUBB  A,Rn
				Do_A_SUBB <= '1';
				Do_A_Carry <= '1';
			end if;
			if OpCode = "10100100" then
				-- 10100100 1 MUL   AB
				Do_A_MUL <= '1';
			end if;
			if OpCode(7 downto 1) = "1011010" then
				-- 10110100 3 CJNE  A,#data,code addr
				-- 10110101 3 CJNE  A,data addr,code addr
				Do_A_SUBB <= '1';
				Do_A_CJNE <= '1';
			end if;
			if OpCode = "11000100" then
				-- 11000100 1 SWAP  A
				Do_A_SWAP <= '1';
			end if;
			if OpCode = "11000101" or
				OpCode(7 downto 1) = "1100011" or
				OpCode(7 downto 3) = "11001" then
				-- 11000101 2 XCH   A,data addr
				-- 1100011i 1 XCH   A,@Ri
				-- 11001rrr 1 XCH   A,Rn
				Do_A_XCH <= '1';
			end if;
			if OpCode = "11010100" then
				-- 11010100 1 DA    A
				Do_A_DA <= '1';
			end if;
			if OpCode(7 downto 1) = "1101011" then
				-- 1101011i 1 XCHD  A,@Ri
				Do_A_XCHD <= '1';
			end if;
			if OpCode = "11100100" then
				-- 11100100 1 CLR   A
				Do_A_CLR <= '1';
			end if;
			if OpCode = "11110100" then
				-- 11110100 1 CPL   A
				Do_A_CPL <= '1';
			end if;

			-- IDCPBL Operations

			Do_I_Imm <= '0';
			Do_I_INC <= '0';
			Do_I_DEC <= '0';
			Do_I_ORL <= '0';
			Do_I_ANL <= '0';
			Do_I_XRL <= '0';
			Do_I_MOV <= '0';
			Do_I_MOVD <= '0';
			Do_I_CJNE <= '0';
			IA_d <= IA;
			MOV_Op <= OpCode(7 downto 4);
			if OpCode(3 downto 0) = "0011" then
				Do_I_Imm <= '1';
			end if;
			if OpCode = "00000101" or
				OpCode(7 downto 1) = "0000011" or
				OpCode(7 downto 3) = "00001" then
				-- 00000101 2 INC   data addr
				-- 0000011i 1 INC   @Ri
				-- 00001rrr 1 INC   Rn
				Do_I_INC <= '1';
			end if;
			if OpCode = "00010101" or
				OpCode(7 downto 1) = "0001011" or
				OpCode(7 downto 3) = "00011" or
				OpCode(7 downto 3) = "11011" or
				OpCode = "11010101" then
				-- 00010101 2 DEC   data addr
				-- 0001011i 1 DEC   @Ri
				-- 00011rrr 1 DEC   Rn
				-- 11011rrr 2 DJNZ  Rn,code addr
				-- 11010101 3 DJNZ  data addr, code addr
				Do_I_DEC <= '1';
			end if;
			if OpCode(7 downto 1) = "0100001" then
				-- 01000010 2 ORL   data addr,A
				-- 01000011 3 ORL   data addr,#data
				Do_I_ORL <= '1';
			end if;
			if OpCode(7 downto 1) = "0101001" then
				-- 01010010 2 ANL   data addr,A
				-- 01010011 3 ANL   data addr,#data
				Do_I_ANL <= '1';
			end if;
			if OpCode(7 downto 1) = "0110001" then
				-- 01100010 2 XRL   data addr,A
				-- 01100011 3 XRL   data addr,#data
				Do_I_XRL <= '1';
			end if;
			if OpCode = "01110101" or
				OpCode(7 downto 1) = "0111011" or
				OpCode(7 downto 3) = "01111" or
				OpCode(7 downto 1) = "1000011" or
				OpCode(7 downto 3) = "10001" or
				OpCode = "10010000" or
				OpCode(7 downto 1) = "1010011" or
				OpCode(7 downto 3) = "10101" or
				OpCode = "11110000" or
				OpCode(7 downto 1) = "1111001" or
				OpCode = "11110101" or
				OpCode(7 downto 1) = "1111011" or
				OpCode(7 downto 3) = "11111" or
				(OpCode(7 downto 5) = "110" and OpCode(3 downto 0) = "0000") then
				-- 01110101 3 MOV   data addr,#data
				-- 0111011i 2 MOV   @Ri,#data
				-- 01111rrr 2 MOV   Rn,#data
				-- 1000011i 2 MOV   data addr,@Ri
				-- 10001rrr 2 MOV   data addr,Rn
				-- 10010000 3 MOV   DPTR,#data	-- Not handled here
				-- 1010011i 2 MOV   @Ri,data addr
				-- 10101rrr 2 MOV   Rn,data addr
				-- 11110000 1 MOVX  @DPTR,A
				-- 1111001i 1 MOVX  @Ri,A
				-- 11110101 2 MOV   data addr,A
				-- 1111011i 1 MOV   @Ri,A
				-- 11111rrr 1 MOV   Rn,A
				-- 11000000 2 PUSH  data addr		INC SP: MOV "@SP",<src>
				-- 11010000 2 POP   data addr		MOV <dest>,"@SP": DEC SP
				Do_I_MOV <= '1';
			end if;
			if OpCode = "10000101" then
				-- 10000101 3 MOV   data addr,data addr
				Do_I_MOVD <= '1';
			end if;
			if OpCode(7 downto 1) = "1011011" or
				OpCode(7 downto 3) = "10111" then
				-- 1011011i 3 CJNE  @Ri,#data,code addr
				-- 10111rrr 3 CJNE  Rn,#data,code addr
				Do_I_CJNE <= '1';
			end if;

			-- Bit Operations

			Do_B_Inv <= '0';
			Do_B_C_BA <= '0';
			Do_B_C_Dir <= '0';
			Do_B_BA_Dir <= '0';
			Do_B_MOV <= '0';
			Do_B_JBC <= '0';
			Do_B_Op <= OpCode(5 downto 4);
			if OpCode(1 downto 0) = "00" then
				Do_B_Inv <= '1';
			end if;
			if OpCode = "01110010" or
				OpCode = "10000010" or
				OpCode = "10100000" or
				OpCode = "10100010" or
				OpCode = "10110000" then
				-- 01110010 2 ORL   C, bit addr
				-- 10000010 2 ANL   C,bit addr
				-- 10100000 2 ORL   C,/bit addr
				-- 10100010 2 MOV   C,bit addr
				-- 10110000 2 ANL   C,/bit addr
				Do_B_C_BA <= '1';
			end if;
			if OpCode = "10110011" or
				OpCode = "11000011" or
				OpCode = "11010011" then
				-- 10110011 1 CPL   C
				-- 11000011 1 CLR   C
				-- 11010011 1 SETB  C
				Do_B_C_Dir <= '1';
			end if;
			if OpCode = "10110010" or
				OpCode = "11000010" or
				OpCode = "11010010" then
				-- 10110010 2 CPL   bit addr
				-- 11000010 2 CLR   bit addr
				-- 11010010 2 SETB  bit addr
				Do_B_BA_Dir <= '1';
			end if;
			if OpCode = "10010010" then
				-- 10010010 2 MOV   bit addr,C
				Do_B_MOV <= '1';
			end if;
			if OpCode = "00010000" then
				-- 00010000 3 JBC   bit addr, code addr
				Do_B_JBC <= '1';
			end if;

			Last_r <= Last;
		end if;
	end process;

	-- Accumulator ALU
	AddSub(ACC(3 downto 0), AOP2(3 downto 0), Do_A_SUBB, Do_A_SUBB xor (Do_A_Carry and CY_In), AS_Q(3 downto 0), AS_AC);
	AddSub(ACC(6 downto 4), AOP2(6 downto 4), Do_A_SUBB, AS_AC, AS_Q(6 downto 4), AS_Carry7);
	AddSub(ACC(7 downto 7), AOP2(7 downto 7), Do_A_SUBB, AS_Carry7, AS_Q(7 downto 7), AS_CY);
	
	-- Mul / Div

	md : T51_MD port map(Clk, ACC, B, Mul_Q, Mul_OV, Div_Q, Div_OV, Div_Rdy);
	
	AOP2 <= IB when Do_A_Imm = '1' else IA;

  tristate_mux: if tristate/=0 generate
  	ACC_Q <= "00000000" when Do_A_CLR = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= ACC(0) & ACC(7 downto 1) when Do_A_RR = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= CY_In & ACC(7 downto 1) when Do_A_RRC = '1' else "ZZZZZZZZ";	-- Sets CY
  	ACC_Q <= ACC(6 downto 0) & ACC(7) when Do_A_RL = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= ACC(6 downto 0) & CY_In when Do_A_RLC = '1' else "ZZZZZZZZ";	-- Sets CY
  	ACC_Q <= std_logic_vector(unsigned(ACC) + 1) when Do_A_INC = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= std_logic_vector(unsigned(ACC) - 1) when Do_A_DEC = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= not ACC when Do_A_CPL = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= ACC or AOP2 when Do_A_ORL = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= ACC and AOP2 when Do_A_ANL = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= ACC xor AOP2 when Do_A_XRL = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= ACC(3 downto 0) & ACC(7 downto 4) when Do_A_SWAP = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= IA when Do_A_XCH = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= ACC(7 downto 4) & IA(3 downto 0) when Do_A_XCHD = '1' else "ZZZZZZZZ";	-- No flags
  	ACC_Q <= AOP2 when Do_A_MOV = '1' else "ZZZZZZZZ";	-- No flags	
  	ACC_Q <= ADA(7 downto 0) when Do_A_DA = '1' else "ZZZZZZZZ";	-- Sets CY
  	ACC_Q <= AS_Q when Do_A_ADD = '1' or Do_A_SUBB = '1' else "ZZZZZZZZ";	-- Sets CY, (AC, OV)
    ACC_Q <= Mul_Q(7 downto 0) when Do_A_MUL = '1' else "ZZZZZZZZ";	-- Sets OV
    ACC_Q <= Div_Q(7 downto 0) when Do_A_DIV = '1' else "ZZZZZZZZ";	-- Sets OV 
    
    CY_Out <= CJNE_CY when Do_I_CJNE = '1' else 'Z';
  	CY_Out <= ADA(8) when Do_A_DA = '1' else 'Z';
  	CY_Out <= ACC(0) when Do_A_RRC = '1' else 'Z';
  	CY_Out <= ACC(7) when Do_A_RLC = '1' else 'Z';
    CY_Out <= AS_CY xor Do_A_SUBB when Do_A_ADD = '1' or Do_A_SUBB = '1' else 'Z';
    CY_Out <= '0' when Do_A_DIV = '1' or Do_A_MUL = '1' else 'Z';
    
    CY_Out <= not CY_In when Do_B_C_Dir = '1' and Do_B_Op = "11" else
  			'0' when Do_B_C_Dir = '1' and Do_B_Op = "00" else
  			'1' when Do_B_C_Dir = '1' and Do_B_Op = "01" else 'Z';
  
  	CY_Out <= CY_In or Bit_IsOne when Do_B_C_BA = '1' and Do_B_Op = "11" and Do_B_Inv = '0' else
  			CY_In and Bit_IsOne when Do_B_C_BA = '1' and Do_B_Op = "00" and Do_B_Inv = '0' else
  			CY_In or Bit_IsOne when Do_B_C_BA = '1' and Do_B_Op = "10" and Do_B_Inv = '1' else
  			Bit_IsOne when Do_B_C_BA = '1' and Do_B_Op = "10" and Do_B_Inv = '0' else
  			CY_In and Bit_IsOne when Do_B_C_BA = '1' and Do_B_Op = "11" and Do_B_Inv = '1' else 'Z';
    
  	
  	AC_Out <= AS_AC xor Do_A_SUBB when Do_A_ADD = '1' or Do_A_SUBB = '1' else 'Z';
  	
  	B_Q <= Mul_Q(15 downto 8) when Do_A_MUL = '1' else "ZZZZZZZZ";	-- Sets OV
  	B_Q <= Div_Q(15 downto 8) when Do_A_DIV = '1' else "ZZZZZZZZ";	-- Sets OV
  	
  	OV_Out <= AS_CY xor AS_Carry7 when Do_A_ADD = '1' or Do_A_SUBB = '1' else 'Z';  
  	OV_Out <= Div_OV when Do_A_DIV = '1' else 'Z';
    OV_Out <= Mul_OV when Do_A_MUL = '1' else 'Z';
  	
  	IDCPBL_Q <= std_logic_vector(unsigned(IA) + 1) when Do_I_INC = '1' else "ZZZZZZZZ";	-- No flags
  	IDCPBL_Q <= std_logic_vector(unsigned(IA) - 1) when Do_I_DEC = '1' else "ZZZZZZZZ";	-- No flags
  	IDCPBL_Q <= IOP or IA when Do_I_ORL = '1' else "ZZZZZZZZ";	-- No flags
  	IDCPBL_Q <= IOP and IA when Do_I_ANL = '1' else "ZZZZZZZZ";	-- No flags
  	IDCPBL_Q <= IOP xor IA when Do_I_XRL = '1' else "ZZZZZZZZ";	-- No flags
  	IDCPBL_Q <= ACC when Do_A_XCH = '1' else "ZZZZZZZZ";	-- No flags
  	IDCPBL_Q <= IA(7 downto 4) & ACC(3 downto 0) when Do_A_XCHD = '1' else "ZZZZZZZZ";	-- No flags
  	IDCPBL_Q <= Bit_Result when Do_B_JBC = '1' or Do_B_BA_Dir = '1' or Do_B_MOV = '1' else "ZZZZZZZZ";
  	IDCPBL_Q <= MOV_Q when Do_I_MOV = '1' else "ZZZZZZZZ";	-- No flags
  	IDCPBL_Q <= IA_d when Do_I_MOVD = '1' else "ZZZZZZZZ";	-- No flags
	end generate;
	
	std_mux: if tristate=0 generate
	  ACC_Q <= "00000000" when Do_A_CLR = '1' else 	-- No flags
  	         ACC(0) & ACC(7 downto 1) when Do_A_RR = '1' else 	-- No flags
  	         CY_In & ACC(7 downto 1) when Do_A_RRC = '1' else 	-- Sets CY
  	         ACC(6 downto 0) & ACC(7) when Do_A_RL = '1' else 	-- No flags
  	         ACC(6 downto 0) & CY_In when Do_A_RLC = '1' else 	-- Sets CY
  	         std_logic_vector(unsigned(ACC) + 1) when Do_A_INC = '1' else 	-- No flags
  	         std_logic_vector(unsigned(ACC) - 1) when Do_A_DEC = '1' else 	-- No flags
  	         not ACC when Do_A_CPL = '1' else 	-- No flags
  	         ACC or AOP2 when Do_A_ORL = '1' else 	-- No flags
  	         ACC and AOP2 when Do_A_ANL = '1' else 	-- No flags
  	         ACC xor AOP2 when Do_A_XRL = '1' else 	-- No flags
  	         ACC(3 downto 0) & ACC(7 downto 4) when Do_A_SWAP = '1' else 	-- No flags
  	         IA when Do_A_XCH = '1' else 	-- No flags
  	         ACC(7 downto 4) & IA(3 downto 0) when Do_A_XCHD = '1' else 	-- No flags
  	         AOP2 when Do_A_MOV = '1' else 	-- No flags	
  	         ADA(7 downto 0) when Do_A_DA = '1' else 	-- Sets CY
  	         AS_Q when Do_A_ADD = '1' or Do_A_SUBB = '1' else 	-- Sets CY, (AC, OV)
             Mul_Q(7 downto 0) when Do_A_MUL = '1' else 	-- Sets OV
             Div_Q(7 downto 0) when Do_A_DIV = '1' else 	-- Sets OV 
             (others =>'-');
             
    CY_Out <= CJNE_CY when Do_I_CJNE = '1' else 
  	          ADA(8) when Do_A_DA = '1' else 
  	          ACC(0) when Do_A_RRC = '1' else 
  	          ACC(7) when Do_A_RLC = '1' else 
              AS_CY xor Do_A_SUBB when Do_A_ADD = '1' or Do_A_SUBB = '1' else 
              '0' when Do_A_DIV = '1' or Do_A_MUL = '1' else 
              
              not CY_In when Do_B_C_Dir = '1' and Do_B_Op = "11" else
  			      '0' when Do_B_C_Dir = '1' and Do_B_Op = "00" else
  			      '1' when Do_B_C_Dir = '1' and Do_B_Op = "01" else 
  			      
              CY_In or Bit_IsOne when Do_B_C_BA = '1' and Do_B_Op = "11" and Do_B_Inv = '0' else
              CY_In and Bit_IsOne when Do_B_C_BA = '1' and Do_B_Op = "00" and Do_B_Inv = '0' else
              CY_In or Bit_IsOne when Do_B_C_BA = '1' and Do_B_Op = "10" and Do_B_Inv = '1' else
              Bit_IsOne when Do_B_C_BA = '1' and Do_B_Op = "10" and Do_B_Inv = '0' else
              CY_In and Bit_IsOne when Do_B_C_BA = '1' and Do_B_Op = "11" and Do_B_Inv = '1' else 
              '-';
              
     AC_Out <= AS_AC xor Do_A_SUBB when Do_A_ADD = '1' or Do_A_SUBB = '1' else 
               '-';
     
     B_Q <= Mul_Q(15 downto 8) when Do_A_MUL = '1' else 	-- Sets OV 
            Div_Q(15 downto 8) when Do_A_DIV = '1' else 	-- Sets OV 
            (others =>'-');
            
    OV_Out <= AS_CY xor AS_Carry7 when Do_A_ADD = '1' or Do_A_SUBB = '1' else   
  	          Div_OV when Do_A_DIV = '1' else 
              Mul_OV when Do_A_MUL = '1' else 
              '-';
              
    IDCPBL_Q <= std_logic_vector(unsigned(IA) + 1) when Do_I_INC = '1' else 	-- No flags
  	            std_logic_vector(unsigned(IA) - 1) when Do_I_DEC = '1' else 	-- No flags
  	            IOP or IA when Do_I_ORL = '1' else 	-- No flags
  	            IOP and IA when Do_I_ANL = '1' else 	-- No flags
  	            IOP xor IA when Do_I_XRL = '1' else 	-- No flags
  	            ACC when Do_A_XCH = '1' else 	-- No flags
  	            IA(7 downto 4) & ACC(3 downto 0) when Do_A_XCHD = '1' else 	-- No flags
  	            Bit_Result when Do_B_JBC = '1' or Do_B_BA_Dir = '1' or Do_B_MOV = '1' else 
  	            MOV_Q when Do_I_MOV = '1' else 	-- No flags
  	            IA_d when Do_I_MOVD = '1' else 	-- No flags
  	            (others =>'-');
              
	end generate;

  DJNZ <= '1' when std_logic_vector(unsigned(IA) - 1) /= "00000000" else '0';

	-- DAA Opcode
	DA : process (ACC, CY_In, AC_In)
		variable accu : unsigned(8 downto 0);
--		variable lc  : std_logic;
		variable add : unsigned(7 downto 0);
--		variable do_add_lsb : boolean;
	begin
		accu := unsigned("0" & ACC);
		add  := (others =>'0');
--		do_add_lsb := false;
		if AC_In = '1' or accu(3 downto 0) > 9 then
--			accu(3 downto 0) := accu(3 downto 0) + 6;
      add(3 downto 0) := "0110";  --6
--      do_add_lsb := true;
		end if;
--		lc := accu(8);
		if CY_In = '1' or accu(7 downto 4) > 9 or
		   (accu(7 downto 4) = 9 and accu(3 downto 0) > 9) then
--			accu := accu + 96;
      add(7 downto 4) := "0110";  --6
		end if;
		accu := accu + add;
--		accu(8) := accu(8) or lc or CY_In;
		ADA <= std_logic_vector(accu);
		ADA(8) <= accu(8) or CY_In;  -- calculate Carry Out
	end process;
	



	-- Auxiliary ALU

	IOP <= IB when Do_I_Imm = '1' else ACC;

	MOV : process (MOV_Op, IB, ACC, IA_d)
	begin
		case MOV_Op is
		when "0111" =>
			-- 01110101 3 MOV   data addr,#data
			-- 0111011i 2 MOV   @Ri,#data
			-- 01111rrr 2 MOV   Rn,#data
			MOV_Q <= IB;
		when "1000" =>
			-- 10000101 3 MOV   data addr,data addr
			-- 1000011i 2 MOV   data addr,@Ri
			-- 10001rrr 2 MOV   data addr,Rn
			MOV_Q <= IA_d;
		when "1010" =>
			-- 1010011i 2 MOV   @Ri,data addr
			-- 10101rrr 2 MOV   Rn,data addr
			MOV_Q <= IA_d;
		when "1111" =>
			-- 11110000 1 MOVX  @DPTR,A
			-- 1111001i 1 MOVX  @Ri,A
			-- 11110101 2 MOV   data addr,A
			-- 1111011i 1 MOV   @Ri,A
			-- 11111rrr 1 MOV   Rn,A
			MOV_Q <= ACC;
		when "1100"|"1101"=>
			-- 11000000 2 PUSH  data addr		INC SP: MOV "@SP",<src>
			-- 11010000 2 POP   data addr		MOV <dest>,"@SP": DEC SP
			MOV_Q <= IA_d;
		when others =>
			MOV_Q <= "--------";
		end case;
	end process;


	AddSub(IA, IB, '1', '1', CJNE_Q, CJNE_CY_n);
	CJNE_CY <= not CJNE_CY_n;
--	CY_Out <= not CJNE_CY_n when Do_I_CJNE = '1' else 'Z';
	
	
	CJNE_Q_ZERO <= '1' when CJNE_Q = "00000000" else
	               '0';
	
--	CJNE <= '1' when Do_I_CJNE = '1' and CJNE_Q /= "00000000" else
	CJNE <= '1' when Do_I_CJNE = '1' and CJNE_Q_ZERO='0' else
			'0' when Do_I_CJNE = '1' else
			'1' when AS_Q /= "00000000" else '0';	-- Sets CY

	-- Bit operations

	Bit_Op1 <= IA and not Bit_Pattern;
	Bit_Op2 <= Bit_Pattern and not IA when Do_B_Inv = '1' else Bit_Pattern and IA;
	Bit_IsOne <= '0' when Bit_Op2 = "00000000" else '1';



	Bit_Result <= IA xor Bit_Pattern when Do_B_BA_Dir = '1' and Do_B_Op = "11" else
				Bit_Op1 when (Do_B_BA_Dir = '1' and Do_B_Op = "00") or Do_B_JBC = '1' else
				IA or Bit_Pattern when Do_B_BA_Dir = '1' and Do_B_Op = "01" else
				Bit_Op1 or (Bit_Pattern and CY_In & CY_In & CY_In & CY_In & CY_In & CY_In & CY_In & CY_In) when Do_B_MOV = '1' else "--------";



	-- Flags

	AC_Wr <= Last_r when (Do_A_ADD = '1' or Do_A_SUBB = '1') and Do_A_CJNE = '0' else '0';

	OV_Wr <= Last_r when ((Do_A_ADD = '1' or Do_A_SUBB = '1') and Do_A_CJNE = '0') or
					Do_A_DIV = '1' or Do_A_MUL = '1' else '0';

	CY_Wr <= Last_r when Do_A_ADD = '1' or Do_A_SUBB = '1' or
					Do_A_RRC = '1' or Do_A_RLC = '1' or
					Do_I_CJNE = '1' or Do_A_DA = '1' or
					Do_B_C_BA = '1' or Do_B_C_Dir = '1' or
					Do_A_DIV = '1' or Do_A_MUL = '1' else '0';

end;
