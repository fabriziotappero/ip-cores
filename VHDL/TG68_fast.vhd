------------------------------------------------------------------------------
------------------------------------------------------------------------------
--                                                                          --
-- This is the 68000 software compatible Kernal of TG68                     --
--                                                                          --
-- Copyright (c) 2007-2010 Tobias Gubener <tobiflex@opencores.org>          -- 
--                                                                          --
-- This source file is free software: you can redistribute it and/or modify --
-- it under the terms of the GNU Lesser General Public License as published --
-- by the Free Software Foundation, either version 3 of the License, or     --
-- (at your option) any later version.                                      --
--                                                                          --
-- This source file is distributed in the hope that it will be useful,      --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of           --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            --
-- GNU General Public License for more details.                             --
--                                                                          --
-- You should have received a copy of the GNU General Public License        --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.    --
--                                                                          --
------------------------------------------------------------------------------
------------------------------------------------------------------------------
--
-- Revision 1.08 2010/06/14
-- Bugfix Movem with regmask==xFFFF
-- Add missing Illegal $4AFC
--
-- Revision 1.07 2009/10/02
-- Bugfix Movem with regmask==x0000
--
-- Revision 1.06 2009/02/10
-- Bugfix shift and rotations opcodes when the bitcount and the data are in the same register:
-- Example lsr.l D2,D2
-- Thanks to Peter Graf for report
--
-- Revision 1.05 2009/01/26
-- Implement missing RTR
-- Thanks to Peter Graf for report
--
-- Revision 1.04 2007/12/29
-- size improvement
-- change signal "microaddr" to one hot state machine
--
-- Revision 1.03 2007/12/21
-- Thanks to Andreas Ehliar
-- Split regfile to use blockram for registers
-- insert "WHEN OTHERS => null;" on END CASE; 
--
-- Revision 1.02 2007/12/17
-- Bugfix jsr  nn.w
--
-- Revision 1.01 2007/11/28
-- add MOVEP
-- Bugfix Interrupt in MOVEQ
--
-- Revision 1.0 2007/11/05
-- Clean up code and first release
--
-- known bugs/todo:
-- Add CHK INSTRUCTION
-- full decode ILLEGAL INSTRUCTIONS
-- Add FC Output
-- add odd Address test
-- add TRACE


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity TG68_fast is
   port(clk               : in std_logic;
        reset             : in std_logic;			--low active
        clkena_in         : in std_logic:='1';
        data_in           : in std_logic_vector(15 downto 0);
		IPL				  : in std_logic_vector(2 downto 0):="111";
        test_IPL          : in std_logic:='0';		--only for debugging
        address           : out std_logic_vector(31 downto 0);
        data_write        : out std_logic_vector(15 downto 0);
        state_out         : out std_logic_vector(1 downto 0);
		LDS, UDS		  : out std_logic;		
        decodeOPC         : buffer std_logic;
		wr				  : out std_logic
		);
end TG68_fast;

architecture logic of TG68_fast is

   signal state        	  : std_logic_vector(1 downto 0);
   signal clkena	      : std_logic;
   signal TG68_PC         : std_logic_vector(31 downto 0);
   signal TG68_PC_add     : std_logic_vector(31 downto 0);
   signal memaddr         : std_logic_vector(31 downto 0);
   signal memaddr_in      : std_logic_vector(31 downto 0);
   signal ea_data         : std_logic_vector(31 downto 0);
   signal ea_data_OP1	  : std_logic;
   signal setaddrlong	  : std_logic;
   signal OP1out, OP2out  : std_logic_vector(31 downto 0);
   signal OP1outbrief     : std_logic_vector(15 downto 0);
   signal OP1in           : std_logic_vector(31 downto 0);
   signal data_write_tmp  : std_logic_vector(31 downto 0);
   signal Xtmp         	  : std_logic_vector(31 downto 0);
   signal PC_dataa, PC_datab, PC_result  : std_logic_vector(31 downto 0);
   signal setregstore	  : std_logic;
   signal datatype        : std_logic_vector(1 downto 0);
   signal longread	      : std_logic;
   signal longreaddirect  : std_logic;
   signal long_done	      : std_logic;
   signal nextpass	      : std_logic;
   signal setnextpass	  : std_logic;
   signal setdispbyte	  : std_logic;
   signal setdisp	      : std_logic;
   signal setdispbrief	  : std_logic;
   signal regdirectsource : std_logic;
   signal endOPC	      : std_logic;
   signal postadd	      : std_logic;
   signal presub	      : std_logic;
   signal addsub_a        : std_logic_vector(31 downto 0);
   signal addsub_b        : std_logic_vector(31 downto 0);
   signal addsub_q        : std_logic_vector(31 downto 0);
   signal briefext        : std_logic_vector(31 downto 0);
   signal setbriefext     : std_logic;
   signal addsub	      : std_logic;
   signal c_in	          : std_logic_vector(3 downto 0);
   signal c_out	          : std_logic_vector(2 downto 0);
   signal add_result      : std_logic_vector(33 downto 0);
   signal addsub_ofl      : std_logic_vector(2 downto 0);
   signal flag_z          : std_logic_vector(2 downto 0);

   signal last_data_read  : std_logic_vector(15 downto 0);
   signal data_read       : std_logic_vector(31 downto 0);

   signal registerin      : std_logic_vector(31 downto 0);
   signal reg_QA          : std_logic_vector(31 downto 0);
   signal reg_QB          : std_logic_vector(31 downto 0);
   signal Hwrena,Lwrena   : std_logic;
   signal Regwrena	      : std_logic;
   signal rf_dest_addr	  : std_logic_vector(6 downto 0);
   signal rf_source_addr  : std_logic_vector(6 downto 0);
   signal rf_dest_addr_tmp		: std_logic_vector(6 downto 0);
   signal rf_source_addr_tmp	: std_logic_vector(6 downto 0);
   signal opcode		  : std_logic_vector(15 downto 0);
   signal laststate		  : std_logic_vector(1 downto 0);
   signal setstate	      : std_logic_vector(1 downto 0);

   signal mem_address     : std_logic_vector(31 downto 0);
   signal memaddr_a       : std_logic_vector(31 downto 0);
   signal mem_data_read   : std_logic_vector(31 downto 0);
   signal mem_data_write  : std_logic_vector(31 downto 0);
	signal set_mem_rega   : std_logic;
   signal data_read_ram   : std_logic_vector(31 downto 0);
   signal data_read_uart  : std_logic_vector(7 downto 0);

   signal counter_reg     : std_logic_vector(31 downto 0);

	signal TG68_PC_br8    : std_logic;
	signal TG68_PC_brw    : std_logic;
	signal TG68_PC_nop    : std_logic;
	signal setgetbrief    : std_logic;
	signal getbrief       : std_logic;
	signal brief          : std_logic_vector(15 downto 0);
	signal dest_areg      : std_logic;
	signal source_areg    : std_logic;
	signal data_is_source : std_logic;
	signal set_store_in_tmp    : std_logic;
	signal store_in_tmp   : std_logic;
	signal write_back     : std_logic;
	signal setaddsub      : std_logic;
	signal setstackaddr   : std_logic;
	signal writePC        : std_logic;
	signal writePC_add    : std_logic;
	signal set_TG68_PC_dec: std_logic;	
	signal TG68_PC_dec    : std_logic_vector(1 downto 0);	
	signal directPC       : std_logic;
	signal set_directPC   : std_logic;
	signal execOPC        : std_logic;
	signal fetchOPC       : std_logic;
	signal Flags          : std_logic_vector(15 downto 0);	--T.S..III ...XNZVC
	signal set_Flags      : std_logic_vector(3 downto 0);	--NZVC
	signal exec_ADD       : std_logic;
	signal exec_OR        : std_logic;
	signal exec_AND       : std_logic;
	signal exec_EOR       : std_logic;
	signal exec_MOVE      : std_logic;
	signal exec_MOVEQ     : std_logic;
	signal exec_MOVESR    : std_logic;
	signal exec_DIRECT    : std_logic;
	signal exec_ADDQ      : std_logic;
	signal exec_CMP       : std_logic;
	signal exec_ROT       : std_logic;
	signal exec_exg       : std_logic;
	signal exec_swap      : std_logic;
	signal exec_write_back: std_logic;
	signal exec_tas       : std_logic;
	signal exec_EXT       : std_logic;
	signal exec_ABCD      : std_logic;
	signal exec_SBCD      : std_logic;
	signal exec_MULU      : std_logic;
	signal exec_DIVU      : std_logic;
    signal exec_Scc 	  : std_logic;
    signal exec_CPMAW	  : std_logic;
	signal set_exec_ADD   : std_logic;
	signal set_exec_OR    : std_logic;
	signal set_exec_AND   : std_logic;
	signal set_exec_EOR   : std_logic;
	signal set_exec_MOVE  : std_logic;
	signal set_exec_MOVEQ : std_logic;
	signal set_exec_MOVESR: std_logic;
	signal set_exec_ADDQ  : std_logic;
	signal set_exec_CMP   : std_logic;
	signal set_exec_ROT   : std_logic;
	signal set_exec_tas   : std_logic;
	signal set_exec_EXT   : std_logic;
	signal set_exec_ABCD  : std_logic;
	signal set_exec_SBCD  : std_logic;
	signal set_exec_MULU  : std_logic;
	signal set_exec_DIVU  : std_logic;
    signal set_exec_Scc   : std_logic;
    signal set_exec_CPMAW : std_logic;

	signal condition      : std_logic;
	signal OP2out_one     : std_logic;
	signal OP1out_zero    : std_logic;
	signal ea_to_pc       : std_logic;
	signal ea_build       : std_logic;
	signal ea_only        : std_logic;
	signal get_ea_now     : std_logic;
	signal source_lowbits : std_logic;
	signal dest_hbits     : std_logic;
	signal rot_rot        : std_logic;
	signal rot_lsb        : std_logic;
	signal rot_msb        : std_logic;
	signal rot_XC         : std_logic;
	signal set_rot_nop    : std_logic;
	signal rot_nop        : std_logic;
    signal rot_out        : std_logic_vector(31 downto 0);
    signal rot_bits       : std_logic_vector(1 downto 0);
    signal rot_cnt        : std_logic_vector(5 downto 0);
    signal set_rot_cnt    : std_logic_vector(5 downto 0);
	signal movem_busy     : std_logic;
	signal set_movem_busy : std_logic;
	signal movem_addr     : std_logic;
	signal movem_regaddr  : std_logic_vector(3 downto 0);
	signal movem_mask     : std_logic_vector(15 downto 0);
	signal set_get_movem_mask  : std_logic;
	signal get_movem_mask : std_logic;
	signal maskzero       : std_logic;
	signal test_maskzero  : std_logic;
	signal movem_muxa     : std_logic_vector(7 downto 0);
	signal movem_muxb     : std_logic_vector(3 downto 0);
	signal movem_muxc     : std_logic_vector(1 downto 0);
    signal movem_presub	  : std_logic;
    signal save_memaddr	  : std_logic;
    signal movem_bits     : std_logic_vector(4 downto 0);
    signal ea_calc_b      : std_logic_vector(31 downto 0);
    signal set_mem_addsub : std_logic;
    signal bit_bits       : std_logic_vector(1 downto 0);
    signal bit_number_reg : std_logic_vector(4 downto 0);
    signal bit_number     : std_logic_vector(4 downto 0);
    signal exec_Bits	  : std_logic;
    signal bits_out       : std_logic_vector(31 downto 0);
    signal one_bit_in	  : std_logic;
    signal one_bit_out	  : std_logic;
	signal set_get_bitnumber	: std_logic;
	signal get_bitnumber  : std_logic;
	signal mem_byte		  : std_logic;
	signal wait_mem_byte  : std_logic;
	signal movepl		  : std_logic;
	signal movepw		  : std_logic;
	signal set_movepl	  : std_logic;
	signal set_movepw	  : std_logic;
	signal set_direct_data: std_logic;
	signal use_direct_data: std_logic;
	signal direct_data	  : std_logic;
	signal set_get_extendedOPC	: std_logic;
	signal get_extendedOPC: std_logic;
    signal setstate_delay : std_logic_vector(1 downto 0);
    signal setstate_mux	  : std_logic_vector(1 downto 0);
    signal use_XZFlag	  : std_logic;
    signal use_XFlag	  : std_logic;

    signal dummy_a		  : std_logic_vector(8 downto 0);
    signal niba_l		  : std_logic_vector(5 downto 0);
    signal niba_h		  : std_logic_vector(5 downto 0);
    signal niba_lc		  : std_logic;
    signal niba_hc		  : std_logic;
    signal bcda_lc		  : std_logic;
    signal bcda_hc		  : std_logic;
    signal dummy_s		  : std_logic_vector(8 downto 0);
    signal nibs_l		  : std_logic_vector(5 downto 0);
    signal nibs_h		  : std_logic_vector(5 downto 0);
    signal nibs_lc		  : std_logic;
    signal nibs_hc		  : std_logic;
    signal dummy_mulu     : std_logic_vector(31 downto 0);
    signal dummy_div      : std_logic_vector(31 downto 0);
    signal dummy_div_sub  : std_logic_vector(16 downto 0);
    signal dummy_div_over : std_logic_vector(16 downto 0);
    signal set_V_Flag	  : std_logic;
    signal OP1sign		  : std_logic;
    signal set_sign	  	  : std_logic;
    signal sign			  : std_logic;
    signal sign2		  : std_logic;
    signal muls_msb		  : std_logic;
    signal mulu_reg       : std_logic_vector(31 downto 0);
    signal div_reg        : std_logic_vector(31 downto 0);
    signal div_sign		  : std_logic;
    signal div_quot       : std_logic_vector(31 downto 0);
    signal div_ovl	      : std_logic;
    signal pre_V_Flag	  : std_logic;
    signal set_vectoraddr : std_logic;
    signal writeSR	      : std_logic;
	signal trap_illegal   : std_logic;
	signal trap_priv      : std_logic;
	signal trap_1010      : std_logic;
	signal trap_1111      : std_logic;
	signal trap_trap      : std_logic;
	signal trap_trapv     : std_logic;
	signal trap_interrupt : std_logic;
	signal trapmake       : std_logic;
	signal trapd          : std_logic;
--   signal trap_PC        : std_logic_vector(31 downto 0);
    signal trap_SR        : std_logic_vector(15 downto 0);
	
    signal set_directSR	  : std_logic;
    signal directSR	      : std_logic;
    signal set_directCCR  : std_logic;
    signal directCCR	  : std_logic;
    signal set_stop	      : std_logic;
    signal stop	          : std_logic;
    signal trap_vector    : std_logic_vector(31 downto 0);
    signal to_USP	      : std_logic;
    signal from_USP	      : std_logic;
    signal to_SR	      : std_logic;
    signal from_SR	      : std_logic;
    signal illegal_write_mode   : std_logic;
    signal illegal_read_mode    : std_logic;
    signal illegal_byteaddr	    : std_logic;
    signal use_SP	      : std_logic;

    signal no_Flags	      : std_logic;
	signal IPL_nr		  : std_logic_vector(2 downto 0);
	signal rIPL_nr		  : std_logic_vector(2 downto 0);
    signal interrupt	  : std_logic;
    signal SVmode	      : std_logic;
	signal trap_chk	  : std_logic;
	signal test_delay	  : std_logic_vector(2 downto 0);
	signal set_PCmarker	  : std_logic;
	signal PCmarker	      : std_logic;
	signal set_Z_error 	  : std_logic;
	signal Z_error 	      : std_logic;

	type micro_states is (idle, nop, ld_nn, st_nn, ld_dAn1, ld_dAn2, ld_AnXn1, ld_AnXn2, ld_AnXn3, st_dAn1, st_dAn2,
						  st_AnXn1, st_AnXn2, st_AnXn3, bra1, bra2, bsr1, bsr2, dbcc1, dbcc2,
						  movem, andi, op_AxAy, cmpm, link, int1, int2, int3, int4, rte, trap1, trap2, trap3,
						  movep1, movep2, movep3, movep4, movep5, init1, init2,
						  mul1, mul2, mul3, mul4, mul5, mul6, mul7, mul8, mul9, mul10, mul11, mul12, mul13, mul14, mul15,
						  div1, div2, div3, div4, div5, div6, div7, div8, div9, div10, div11, div12, div13, div14, div15 );
	signal micro_state		: micro_states;
	signal next_micro_state		: micro_states;

	type regfile_t is array(0 to 16) of std_logic_vector(15 downto 0);
	signal regfile_low	  : regfile_t;
	signal regfile_high	  : regfile_t;
 	signal RWindex_A	  : integer range 0 to 16;
 	signal RWindex_B	  : integer range 0 to 16;


BEGIN  

-----------------------------------------------------------------------------
-- Registerfile
-----------------------------------------------------------------------------

	RWindex_A <= conv_integer(rf_dest_addr(4)&(rf_dest_addr(3 downto 0) XOR "1111"));
	RWindex_B <= conv_integer(rf_source_addr(4)&(rf_source_addr(3 downto 0) XOR "1111"));
	
	PROCESS (clk)
	BEGIN
		IF falling_edge(clk) THEN
		    IF clkena='1' THEN
				reg_QA <= regfile_high(RWindex_A) & regfile_low(RWindex_A);
				reg_QB <= regfile_high(RWindex_B) & regfile_low(RWindex_B); 
			END IF;
		END IF;
		IF rising_edge(clk) THEN
		    IF clkena='1' THEN
				IF Lwrena='1' THEN
					regfile_low(RWindex_A) <= registerin(15 downto 0);
				END IF;
				IF Hwrena='1' THEN
					regfile_high(RWindex_A) <= registerin(31 downto 16);
				END IF;
			END IF;
		END IF;
	END PROCESS;



	address <= TG68_PC when state="00" else X"ffffffff" when state="01" else memaddr;
	LDS <= '0' WHEN (datatype/="00" OR state="00" OR memaddr(0)='1') AND state/="01" ELSE '1';
	UDS <= '0' WHEN (datatype/="00" OR state="00" OR memaddr(0)='0') AND state/="01" ELSE '1';
	state_out <= state;
	wr <= '0' WHEN state="11" ELSE '1';
	IPL_nr <= NOT IPL;
	
	
-----------------------------------------------------------------------------
-- "ALU"
-----------------------------------------------------------------------------
PROCESS (addsub_a, addsub_b, addsub, add_result, c_in)
	BEGIN
		IF addsub='1' THEN		--ADD
			add_result <= (('0'&addsub_a&c_in(0))+('0'&addsub_b&c_in(0)));
		ELSE					--SUB
			add_result <= (('0'&addsub_a&'0')-('0'&addsub_b&c_in(0)));
		END IF;
		addsub_q <= add_result(32 downto 1); 
		c_in(1) <= add_result(9) XOR addsub_a(8) XOR addsub_b(8);
		c_in(2) <= add_result(17) XOR addsub_a(16) XOR addsub_b(16);
		c_in(3) <= add_result(33);
		addsub_ofl(0) <= (c_in(1) XOR add_result(8) XOR addsub_a(7) XOR addsub_b(7));	--V Byte
		addsub_ofl(1) <= (c_in(2) XOR add_result(16) XOR addsub_a(15) XOR addsub_b(15));	--V Word
		addsub_ofl(2) <= (c_in(3) XOR add_result(32) XOR addsub_a(31) XOR addsub_b(31));	--V Long
		c_out <= c_in(3 downto 1);
END PROCESS;
	
-----------------------------------------------------------------------------
-- MEM_IO 
-----------------------------------------------------------------------------
PROCESS (clk, reset, clkena_in, opcode, rIPL_nr, longread, get_extendedOPC, memaddr, memaddr_a, set_mem_addsub, movem_presub, 
         movem_busy, state, PCmarker, execOPC, datatype, setdisp, setdispbrief, briefext, setdispbyte, brief,
         set_mem_rega, reg_QA, setaddrlong, data_read, decodeOPC, TG68_PC, data_in, long_done, last_data_read, mem_byte,
         data_write_tmp, addsub_q, set_vectoraddr, trap_vector, interrupt)
	BEGIN
		clkena <= clkena_in AND NOT longread AND NOT get_extendedOPC;
		
		IF rising_edge(clk) THEN
			IF clkena='1' THEN
				trap_vector(31 downto 8) <= (others => '0');
		--		IF trap_addr_fault='1' THEN
		--			trap_vector(7 downto 0) <= X"08";
		--		END IF;	
		--		IF trap_addr_error='1' THEN
		--			trap_vector(7 downto 0) <= X"0C";
		--		END IF;	
				IF trap_illegal='1' THEN
					trap_vector(7 downto 0) <= X"10";
				END IF;	
				IF z_error='1' THEN
					trap_vector(7 downto 0) <= X"14";
				END IF;	
--				IF trap_chk='1' THEN
--					trap_vector(7 downto 0) <= X"18";
--				END IF;	
				IF trap_trapv='1' THEN
					trap_vector(7 downto 0) <= X"1C";
				END IF;	
				IF trap_priv='1' THEN
					trap_vector(7 downto 0) <= X"20";
				END IF;	
		--		IF trap_trace='1' THEN
		--			trap_vector(7 downto 0) <= X"24";
		--		END IF;	
				IF trap_1010='1' THEN
					trap_vector(7 downto 0) <= X"28";
				END IF;	
				IF trap_1111='1' THEN
					trap_vector(7 downto 0) <= X"2C";
				END IF;	
				IF trap_trap='1' THEN
					trap_vector(7 downto 2) <= "10"&opcode(3 downto 0);
				END IF;	
				IF interrupt='1' THEN
					trap_vector(7 downto 2) <= "011"&rIPL_nr;
				END IF;	
			END IF;
		END IF;

		memaddr_a(3 downto 0) <= "0000";
		memaddr_a(7 downto 4) <= (OTHERS=>memaddr_a(3));
		memaddr_a(15 downto 8) <= (OTHERS=>memaddr_a(7));
		memaddr_a(31 downto 16) <= (OTHERS=>memaddr_a(15));
		IF movem_presub='1' THEN
			IF movem_busy='1' OR longread='1' THEN
				memaddr_a(3 downto 0) <= "1110";
			END IF;
		ELSIF state(1)='1' OR (get_extendedOPC='1' AND PCmarker='1') THEN  
			memaddr_a(1) <= '1';
		ELSIF execOPC='1' THEN
			IF datatype="10" THEN
				memaddr_a(3 downto 0) <= "1100";
			ELSE
				memaddr_a(3 downto 0) <= "1110";
			END IF;	
		ELSIF setdisp='1' THEN
			IF setdispbrief='1' THEN
				memaddr_a <= briefext;
			ELSIF setdispbyte='1' THEN
				memaddr_a(7 downto 0) <= brief(7 downto 0);
			ELSE
				memaddr_a(15 downto 0) <= brief;
			END IF;	 
		END IF;	 
		
		memaddr_in <= memaddr+memaddr_a;
		IF longread='0' THEN 
			IF set_mem_addsub='1' THEN
				memaddr_in <= addsub_q;	
			ELSIF set_vectoraddr='1' THEN	
				memaddr_in <= trap_vector;
			ELSIF interrupt='1' THEN
				memaddr_in <= "1111111111111111111111111111"&rIPL_nr&'0';	
			ELSIF set_mem_rega='1' THEN
				memaddr_in <= reg_QA;
			ELSIF setaddrlong='1' AND longread='0' THEN
				memaddr_in <= data_read;
			ELSIF decodeOPC='1' THEN
				memaddr_in <= TG68_PC;
			END IF;
		END IF;
		
		data_read(15 downto 0) <= data_in;
		data_read(31 downto 16) <= (OTHERS=>data_in(15));
		IF long_done='1' THEN
			data_read(31 downto 16) <= last_data_read;
		END IF;	
		IF mem_byte='1' AND memaddr(0)='0' THEN
			data_read(7 downto 0) <= data_in(15 downto 8);
		END IF;	
		
		IF longread='1' THEN
			data_write <= data_write_tmp(31 downto 16);
		ELSE
			data_write(7 downto 0) <= data_write_tmp(7 downto 0);
			IF mem_byte='1' THEN
				data_write(15 downto 8) <= data_write_tmp(7 downto 0);
			ELSE
				data_write(15 downto 8) <= data_write_tmp(15 downto 8);
				IF datatype="00" THEN
					data_write(7 downto 0) <= data_write_tmp(15 downto 8);
				END IF;	
			END IF;
		END IF;	
		
		IF reset='0' THEN
			longread <= '0';
			long_done <= '0';
		ELSIF rising_edge(clk) THEN
        	IF clkena_in='1' THEN
				last_data_read <= data_in;
					long_done <= longread;
				IF get_extendedOPC='0' OR (get_extendedOPC='1' AND PCmarker='1') THEN
						memaddr <= memaddr_in;
				END IF;		
				IF get_extendedOPC='0' THEN
					
					IF ((setstate_mux(1)='1' AND datatype="10") OR longreaddirect='1') AND longread='0' AND interrupt='0' THEN
						longread <= '1';
					ELSE	
						longread <= '0';
					END IF;	
				END IF;
				
			END IF;
		END IF;
    END PROCESS;
-----------------------------------------------------------------------------
-- brief
-----------------------------------------------------------------------------
process (clk, brief, OP1out)
	begin
		IF brief(11)='1' THEN
			OP1outbrief <= OP1out(31 downto 16);
		ELSE
			OP1outbrief <= (OTHERS=>OP1out(15));
		END IF;
		IF rising_edge(clk) THEN
        	IF clkena='1' THEN
				briefext <= OP1outbrief&OP1out(15 downto 0);
--				CASE brief(10 downto 9) IS
--					WHEN "00" => briefext <= OP1outbrief&OP1out(15 downto 0);
--					WHEN "01" => briefext <= OP1outbrief(14 downto 0)&OP1out(15 downto 0)&'0';
--					WHEN "10" => briefext <= OP1outbrief(13 downto 0)&OP1out(15 downto 0)&"00";
--					WHEN "11" => briefext <= OP1outbrief(12 downto 0)&OP1out(15 downto 0)&"000";
--				END CASE;
        	end if;
      	end if;
   end process;

-----------------------------------------------------------------------------
-- PC Calc + fetch opcode
-----------------------------------------------------------------------------
process (clk, reset, opcode, TG68_PC, TG68_PC_dec, TG68_PC_br8, TG68_PC_brw, PC_dataa, PC_datab, execOPC, last_data_read, get_extendedOPC,
		 setstate_delay, setstate)
	begin
		PC_dataa <= TG68_PC;
		PC_datab(2 downto 0) <= "010";
		PC_datab(7 downto 3) <= (others => PC_datab(2));
		PC_datab(15 downto 8) <= (others => PC_datab(7));
		PC_datab(31 downto 16) <= (others => PC_datab(15));
		IF execOPC='0' THEN
			IF TG68_PC_br8='1' THEN
				PC_datab(7 downto 0) <= opcode(7 downto 0);
			END IF;
			IF TG68_PC_dec(1)='1' THEN
				PC_datab(2) <= '1';
			END IF;
			IF TG68_PC_brw = '1' THEN	
				PC_datab(15 downto 0) <= last_data_read(15 downto 0);
			END IF;
		END IF;
		TG68_PC_add <= PC_dataa+PC_datab;
		
		IF get_extendedOPC='1' THEN
			setstate_mux <= setstate_delay;	
		ELSE
			setstate_mux <= setstate;
		END IF;
		
		
      	IF reset = '0' THEN
			opcode(15 downto 12) <= X"7";		--moveq
			opcode(8 downto 6) <= "010";		--long
			TG68_PC <= (others =>'0');
			state <= "01";
  			decodeOPC <= '0';
			fetchOPC <= '0';
			endOPC <= '0';
			interrupt <= '0';
			trap_interrupt <= '1';
			execOPC <= '0';
 			getbrief <= '0';
			TG68_PC_dec <= "00";
			directPC <= '0';
			directSR <= '0';
			directCCR <= '0';
			stop <= '0';
			exec_ADD <= '0';
			exec_OR <= '0';
			exec_AND <= '0';
			exec_EOR <= '0';
			exec_MOVE <= '0';
			exec_MOVEQ <= '0';
			exec_MOVESR <= '0';
			exec_ADDQ <= '0';
			exec_CMP <= '0';
			exec_ROT <= '0';
			exec_EXT <= '0';
			exec_ABCD <= '0';
			exec_SBCD <= '0';
			exec_MULU <= '0';
			exec_DIVU <= '0';
			exec_Scc <= '0';
			exec_CPMAW <= '0';
			mem_byte <= '0';
			rot_cnt <="000001";
			rot_nop <= '0';
			get_extendedOPC <= '0';
			get_bitnumber <= '0';
			get_movem_mask <= '0';
			test_maskzero <= '0';
			movepl <= '0';
			movepw <= '0';
			test_delay <= "000";
			PCmarker <= '0';
	  	ELSIF rising_edge(clk) THEN
        	IF clkena_in='1' THEN
				get_extendedOPC <= set_get_extendedOPC;
				get_bitnumber <= set_get_bitnumber;
				get_movem_mask <= set_get_movem_mask;
				test_maskzero <= get_movem_mask;
				setstate_delay <= setstate;
				
				TG68_PC_dec <= TG68_PC_dec(0)&set_TG68_PC_dec;
				IF directPC='1' AND clkena='1' THEN
					TG68_PC <= data_read;
				ELSIF ea_to_pc='1' AND longread='0' THEN
					TG68_PC <= memaddr_in;					
				ELSIF (state ="00" AND TG68_PC_nop='0') OR TG68_PC_br8='1' OR TG68_PC_brw='1' OR TG68_PC_dec(1)='1' THEN				
					TG68_PC <= TG68_PC_add;
				END IF;	
			
				IF get_bitnumber='1' THEN
					bit_number_reg <= data_read(4 downto 0);
				END IF;

	        	IF clkena='1' OR get_extendedOPC='1' THEN
					IF set_get_extendedOPC='1' THEN
						state <= "00";
					ELSIF get_extendedOPC='1' THEN
						state <= setstate_mux;
					ELSIF fetchOPC='1' OR (state="10" AND write_back='1' AND setstate/="10") OR set_rot_cnt/="000001" OR stop='1' THEN
						state <= "01";		--decode cycle, execute cycle
					ELSE
						state <= setstate_mux;
					END IF;
					IF setstate_mux(1)='1' AND datatype="00" AND set_get_extendedOPC='0' AND wait_mem_byte='0' THEN
						mem_byte <= '1';
					ELSE
						mem_byte <= '0';
					END IF;
				
				END IF;	
			END IF;	
			
        	IF clkena='1' THEN
				exec_ADD <= '0';
				exec_OR <= '0';
				exec_AND <= '0';
				exec_EOR <= '0';
				exec_MOVE <= '0';
				exec_MOVEQ <= '0';
				exec_MOVESR <= '0';
				exec_ADDQ <= '0';
				exec_CMP <= '0';
				exec_ROT <= '0';
				exec_ABCD <= '0';
				exec_SBCD <= '0';
				fetchOPC <= '0';
				exec_CPMAW <= '0';
				endOPC <= '0';
				interrupt <= '0';
				execOPC <= '0';
				exec_EXT <= '0';
				exec_Scc <= '0';
				rot_nop <= '0';
				decodeOPC <= fetchOPC;
				directPC <= set_directPC;
				directSR <= set_directSR;
				directCCR <= set_directCCR;
				exec_MULU <= set_exec_MULU;
				exec_DIVU <= set_exec_DIVU;
				movepl <= '0';
				movepw <= '0';
				
				stop <= set_stop OR (stop AND NOT interrupt);
				IF	set_PCmarker='1' THEN
					PCmarker <= '1';
				ELSIF (state="10" AND longread='0') OR (ea_only='1' AND get_ea_now='1') THEN	
					PCmarker <= '0';
				END IF;
				IF (decodeOPC OR execOPC)='1' THEN
					rot_cnt <= set_rot_cnt;
				END IF;
				IF next_micro_state=idle AND setstate_mux="00" AND (setnextpass='0' OR ea_only='1') AND endOPC='0' AND movem_busy='0' AND set_movem_busy='0' AND set_get_bitnumber='0' THEN
					nextpass <= '0';
					IF (exec_write_back='0' OR state="11") AND set_rot_cnt="000001" THEN
						endOPC <= '1';
						IF Flags(10 downto 8)<IPL_nr OR IPL_nr="111" THEN
							interrupt <= '1';
							rIPL_nr <= IPL_nr;
						ELSE
							IF stop='0' THEN
								fetchOPC <= '1';
							END IF;
						END IF;	
					END IF;
					IF exec_write_back='0' OR state/="11" THEN
						IF stop='0' THEN
							execOPC <= '1';
						END IF;
						exec_ADD <= set_exec_ADD;
						exec_OR <= set_exec_OR;
						exec_AND <= set_exec_AND;
						exec_EOR <= set_exec_EOR;
						exec_MOVE <= set_exec_MOVE;
						exec_MOVEQ <= set_exec_MOVEQ;
						exec_MOVESR <= set_exec_MOVESR;
						exec_ADDQ <= set_exec_ADDQ;
						exec_CMP <= set_exec_CMP;
						exec_ROT <= set_exec_ROT;
						exec_tas <= set_exec_tas;
						exec_EXT <= set_exec_EXT;
						exec_ABCD <= set_exec_ABCD;
						exec_SBCD <= set_exec_SBCD;
						exec_Scc <= set_exec_Scc;
						exec_CPMAW <= set_exec_CPMAW;
						rot_nop <= set_rot_nop;

					END IF;
				ELSE
					IF endOPC='0' AND (setnextpass='1' OR (regdirectsource='1' AND decodeOPC='1')) THEN
						nextpass <= '1';	
					END IF;
				END IF;
				IF interrupt='1' THEN
					opcode(15 downto 12) <= X"7";		--moveq
					opcode(8 downto 6) <= "010";		--long
--					trap_PC <= TG68_PC;
					trap_interrupt <= '1';
				END IF;
				IF fetchOPC='1' THEN
					trap_interrupt <= '0';
					IF (test_IPL='1' AND (Flags(10 downto 8)<IPL_nr OR IPL_nr="111")) OR to_SR='1' THEN
--					IF (test_IPL='1' AND (Flags(10 downto 8)<IPL_nr OR IPL_nr="111")) OR to_SR='1' OR opcode(15 downto 6)="0100111011" THEN  --nur für Validator
						opcode <= X"60FE"; 
						IF to_SR='0' THEN
							test_delay <= "001";
						END IF;	
					ELSE
						opcode <= data_read(15 downto 0);
					END IF;	
					getbrief <= '0';
--					trap_PC <= TG68_PC;
				ELSE	
					test_delay <= test_delay(1 downto 0)&'0';
					getbrief <= setgetbrief;
					movepl <= set_movepl;
					movepw <= set_movepw;
				END IF;
				IF decodeOPC='1' OR interrupt='1' THEN
					trap_SR <= Flags;
				END IF;

				IF getbrief='1' THEN
					brief <= data_read(15 downto 0);
				END IF;	
        	end if;
      	end if;
   end process;

-----------------------------------------------------------------------------
-- handle EA_data, data_write_tmp
-----------------------------------------------------------------------------
PROCESS (clk, reset, opcode)
	BEGIN
      	IF reset = '0' THEN
			set_store_in_tmp <='0';
			exec_DIRECT <= '0';
			exec_write_back <= '0';
			direct_data <= '0';
			use_direct_data <= '0';
			Z_error <= '0';
	  	ELSIF rising_edge(clk) THEN
			IF clkena='1' THEN
				direct_data <= '0';
				IF endOPC='1' THEN
					set_store_in_tmp <='0';
					exec_DIRECT <= '0';
					exec_write_back <= '0';
					use_direct_data <= '0';
					Z_error <= '0';
				ELSE
					IF set_Z_error='1'  THEN
						Z_error <= '1';
					END IF;	
					exec_DIRECT <= set_exec_MOVE;
					IF setstate_mux="10" AND write_back='1' THEN
						exec_write_back <= '1';
					END IF;	
				END IF;
				IF set_direct_data='1' THEN
					direct_data <= '1';
					use_direct_data <= '1';
				END IF;	
				IF set_exec_MOVE='1' AND state="11" THEN
					use_direct_data <= '1';
				END IF;

				IF (exec_DIRECT='1' AND state="00" AND getbrief='0' AND endOPC='0') OR state="10" THEN
					set_store_in_tmp <= '1'; 
					ea_data <= data_read;
				END IF;	
				
				IF writePC_add='1' THEN
					data_write_tmp <= TG68_PC_add;
				ELSIF writePC='1' OR fetchOPC='1' OR interrupt='1' OR (trap_trap='1' AND decodeOPC='1') THEN		--fetchOPC für Trap
					data_write_tmp <= TG68_PC;
				ELSIF execOPC='1' OR (get_ea_now='1' AND ea_only='1') THEN		--get_ea_now='1' AND ea_only='1' ist für pea
					data_write_tmp <= registerin(31 downto 8)&(registerin(7)OR exec_tas)&registerin(6 downto 0);
				ELSIF (exec_DIRECT='1' AND state="10") OR direct_data='1' THEN
					data_write_tmp <= data_read;
					IF  movepl='1' THEN
						data_write_tmp(31 downto 8) <= data_write_tmp(23 downto 0);
					END IF;
				ELSIF (movem_busy='1' AND datatype="10" AND movem_presub='1') OR movepl='1' THEN
					data_write_tmp <= OP2out(15 downto 0)&OP2out(31 downto 16);
				ELSIF (NOT trapmake AND decodeOPC)='1' OR movem_busy='1' OR movepw='1' THEN
					data_write_tmp <= OP2out;
				ELSIF writeSR='1'THEN
					data_write_tmp(15 downto 0) <= trap_SR(15 downto 8)& Flags(7 downto 0);
				END IF;
			END IF;	
		END IF;	
	END PROCESS;
	
-----------------------------------------------------------------------------
-- set dest regaddr
-----------------------------------------------------------------------------
PROCESS (opcode, rf_dest_addr_tmp, to_USP, Flags, trapmake, movem_addr, movem_presub, movem_regaddr, setbriefext, brief, setstackaddr, dest_hbits, dest_areg, data_is_source)
	BEGIN
		rf_dest_addr <= rf_dest_addr_tmp;
		IF rf_dest_addr_tmp(3 downto 0)="1111" AND to_USP='0' THEN
			rf_dest_addr(4) <= Flags(13) OR trapmake; 
		END IF;
		IF movem_addr='1' THEN
			IF movem_presub='1' THEN
				rf_dest_addr_tmp <= "000"&(movem_regaddr XOR "1111");
			ELSE
				rf_dest_addr_tmp <= "000"&movem_regaddr;
			END IF; 
		ELSIF setbriefext='1' THEN
			rf_dest_addr_tmp <= ("000"&brief(15 downto 12));
		ELSIF setstackaddr='1' THEN	
			rf_dest_addr_tmp <= "0001111";
		ELSIF dest_hbits='1' THEN	
			rf_dest_addr_tmp <= "000"&dest_areg&opcode(11 downto 9);
		ELSE
			IF opcode(5 downto 3)="000" OR data_is_source='1' THEN 			
				rf_dest_addr_tmp <= "000"&dest_areg&opcode(2 downto 0);
			ELSE
				rf_dest_addr_tmp <= "0001"&opcode(2 downto 0);
			END IF;
		END IF;	
	END PROCESS;
	
-----------------------------------------------------------------------------
-- set OP1
-----------------------------------------------------------------------------
PROCESS (reg_QA, OP1out_zero, from_SR, Flags, ea_data_OP1, set_store_in_tmp, ea_data)
	BEGIN
		OP1out <= reg_QA;
		IF OP1out_zero='1' THEN
			OP1out <= (OTHERS => '0');	
		ELSIF from_SR='1' THEN
			OP1out(15 downto 0) <= Flags;
		ELSIF ea_data_OP1='1' AND set_store_in_tmp='1' THEN
			OP1out <= ea_data;
		END IF;
	END PROCESS;
	
-----------------------------------------------------------------------------
-- set source regaddr
-----------------------------------------------------------------------------
PROCESS (opcode, Flags, movem_addr, movem_presub, movem_regaddr, source_lowbits, source_areg, from_USP, rf_source_addr_tmp)
	BEGIN
		rf_source_addr <= rf_source_addr_tmp;
		IF rf_source_addr_tmp(3 downto 0)="1111" AND from_USP='0' THEN
			rf_source_addr(4) <= Flags(13); 
		END IF;
		IF movem_addr='1' THEN
			IF movem_presub='1' THEN
				rf_source_addr_tmp <= "000"&(movem_regaddr XOR "1111");
			ELSE
				rf_source_addr_tmp <= "000"&movem_regaddr;
			END IF; 
		ELSIF from_USP='1' THEN	
			rf_source_addr_tmp <= "0001111";
		ELSIF source_lowbits='1' THEN
			rf_source_addr_tmp <= "000"&source_areg&opcode(2 downto 0);
		ELSE
			rf_source_addr_tmp <= "000"&source_areg&opcode(11 downto 9);
		END IF;	
	END PROCESS;
	
-----------------------------------------------------------------------------
-- set OP2
-----------------------------------------------------------------------------
PROCESS (OP2out, reg_QB, opcode, datatype, OP2out_one, exec_EXT, exec_MOVEQ, EXEC_ADDQ, use_direct_data, data_write_tmp, 
	     ea_data_OP1, set_store_in_tmp, ea_data, movepl)
	BEGIN
		OP2out(15 downto 0) <= reg_QB(15 downto 0);
		OP2out(31 downto 16) <= (OTHERS => OP2out(15));
		IF OP2out_one='1' THEN
			OP2out(15 downto 0) <= "1111111111111111";
		ELSIF exec_EXT='1' THEN
			IF opcode(6)='0' THEN	--ext.w
				OP2out(15 downto 8) <= (OTHERS => OP2out(7));		
			END IF;	
		ELSIF use_direct_data='1' THEN	
			OP2out <= data_write_tmp;	
		ELSIF ea_data_OP1='0' AND set_store_in_tmp='1' THEN
			OP2out <= ea_data;	
		ELSIF exec_MOVEQ='1' THEN
			OP2out(7 downto 0) <= opcode(7 downto 0);
			OP2out(15 downto 8) <= (OTHERS => opcode(7));
		ELSIF exec_ADDQ='1' THEN
			OP2out(2 downto 0) <= opcode(11 downto 9);
			IF opcode(11 downto 9)="000" THEN
				OP2out(3) <='1';
			ELSE
				OP2out(3) <='0';
			END IF;
			OP2out(15 downto 4) <= (OTHERS => '0');
		ELSIF datatype="10" OR movepl='1' THEN
			OP2out(31 downto 16) <= reg_QB(31 downto 16);
		END IF;
	END PROCESS;
	
-----------------------------------------------------------------------------
-- addsub
-----------------------------------------------------------------------------
PROCESS (OP1out, OP2out, presub, postadd, execOPC, OP2out_one, datatype, use_SP, use_XZFlag, use_XFlag, Flags, setaddsub)
	BEGIN
		addsub_a <= OP1out;
		addsub_b <= OP2out;
		addsub <= NOT presub;
		c_in(0) <='0';
		IF execOPC='0' AND OP2out_one='0' THEN
			IF datatype="00" AND use_SP='0' THEN
				addsub_b <= "00000000000000000000000000000001";
			ELSIF datatype="10" AND (presub OR postadd)='1' THEN
				addsub_b <= "00000000000000000000000000000100";
			ELSE 
				addsub_b <= "00000000000000000000000000000010";
			END IF;
		ELSE	
			IF (use_XZFlag='1' OR use_XFlag='1') AND Flags(4)='1' THEN
				c_in(0) <= '1';
			END IF;
			addsub <= setaddsub;
		END IF;
    END PROCESS;

-----------------------------------------------------------------------------
-- Write Reg
-----------------------------------------------------------------------------
PROCESS (clkena, OP1in, datatype, presub, postadd, endOPC, regwrena, state, execOPC, last_data_read, movem_addr, rf_dest_addr, reg_QA, maskzero)
	BEGIN
		Lwrena <= '0';
		Hwrena <= '0';
		registerin <= OP1in;
		
		IF (presub='1' OR postadd='1') AND endOPC='0' THEN		-- -(An)+
			Hwrena <= '1';
			Lwrena <= '1';
		ELSIF Regwrena='1' AND maskzero='0' THEN		--read (mem)
			Lwrena <= '1';
			CASE datatype IS
				WHEN "00" =>		--BYTE
					registerin(15 downto 8) <= reg_QA(15 downto 8);
				WHEN "01" =>		--WORD
					IF rf_dest_addr(3)='1' OR movem_addr='1' THEN
						Hwrena <='1';
					END IF;
				WHEN OTHERS =>		--LONG
					Hwrena <= '1';
			END CASE;
		END IF;	
	END PROCESS;
	
------------------------------------------------------------------------------
--ALU
------------------------------------------------------------------------------		
PROCESS (opcode, OP1in, OP1out, OP2out, datatype, c_out, exec_ABCD, exec_SBCD, exec_CPMAW, exec_MOVESR, bits_out, Flags, flag_z, use_XZFlag, addsub_ofl, 
	dummy_s, dummy_a, niba_hc, niba_h, niba_l, niba_lc, nibs_hc, nibs_h, nibs_l, nibs_lc, addsub_q, movem_addr, data_read, exec_MULU, exec_DIVU, exec_OR,
	exec_AND, exec_Scc, exec_EOR, exec_MOVE, exec_exg, exec_ROT, execOPC, exec_swap, exec_Bits, rot_out, dummy_mulu, dummy_div, save_memaddr, memaddr,
	memaddr_in, ea_only, get_ea_now)
	BEGIN
	
--BCD_ARITH-------------------------------------------------------------------
		--ADC
			dummy_a <= niba_hc&(niba_h(4 downto 1)+('0',niba_hc,niba_hc,'0'))&(niba_l(4 downto 1)+('0',niba_lc,niba_lc,'0'));
			niba_l <= ('0'&OP1out(3 downto 0)&'1') + ('0'&OP2out(3 downto 0)&Flags(4));
			niba_lc <= niba_l(5) OR (niba_l(4) AND niba_l(3)) OR (niba_l(4) AND niba_l(2));

			niba_h <= ('0'&OP1out(7 downto 4)&'1') + ('0'&OP2out(7 downto 4)&niba_lc);
			niba_hc <= niba_h(5) OR (niba_h(4) AND niba_h(3)) OR (niba_h(4) AND niba_h(2));
		--SBC			
			dummy_s <= nibs_hc&(nibs_h(4 downto 1)-('0',nibs_hc,nibs_hc,'0'))&(nibs_l(4 downto 1)-('0',nibs_lc,nibs_lc,'0'));
			nibs_l <= ('0'&OP1out(3 downto 0)&'0') - ('0'&OP2out(3 downto 0)&Flags(4));
			nibs_lc <= nibs_l(5);

			nibs_h <= ('0'&OP1out(7 downto 4)&'0') - ('0'&OP2out(7 downto 4)&nibs_lc);
			nibs_hc <= nibs_h(5);
------------------------------------------------------------------------------		
					
			flag_z <= "000";

			OP1in <= addsub_q;
			IF movem_addr='1' THEN
				OP1in <= data_read;
			ELSIF exec_ABCD='1' THEN	
				OP1in(7 downto 0) <= dummy_a(7 downto 0);
			ELSIF exec_SBCD='1' THEN	
				OP1in(7 downto 0) <= dummy_s(7 downto 0);
			ELSIF exec_MULU='1' THEN
				OP1in <= dummy_mulu;	
			ELSIF exec_DIVU='1' AND execOPC='1' THEN
				OP1in <= dummy_div;	
			ELSIF exec_OR='1' THEN
				OP1in <= OP2out OR OP1out;
			ELSIF exec_AND='1' OR exec_Scc='1' THEN
				OP1in <= OP2out AND OP1out;
			ELSIF exec_EOR='1' THEN
				OP1in <= OP2out XOR OP1out;
			ELSIF exec_MOVE='1' OR exec_exg='1' THEN
				OP1in <= OP2out;
			ELSIF exec_ROT='1' THEN
				OP1in <= rot_out;
			ELSIF save_memaddr='1' THEN
				OP1in <= memaddr;	
			ELSIF get_ea_now='1' AND ea_only='1' THEN
				OP1in <= memaddr_in;	
			ELSIF exec_swap='1' THEN	
				OP1in <= OP1out(15 downto 0)& OP1out(31 downto 16);
			ELSIF exec_bits='1' THEN
				OP1in <= bits_out;	
			ELSIF exec_MOVESR='1' THEN
				OP1in(15 downto 0) <= Flags;
			END IF;
			
			IF use_XZFlag='1' AND flags(2)='0' THEN
				flag_z <= "000";
			ELSIF OP1in(7 downto 0)="00000000" THEN
				flag_z(0) <= '1';
				IF OP1in(15 downto 8)="00000000" THEN
					flag_z(1) <= '1';
					IF OP1in(31 downto 16)="0000000000000000" THEN
						flag_z(2) <= '1';	
					END IF;
				END IF;
			END IF;
			
--					--Flags NZVC
			IF datatype="00" THEN 						--Byte
				set_flags <= OP1IN(7)&flag_z(0)&addsub_ofl(0)&c_out(0);
				IF exec_ABCD='1' THEN	
					set_flags(0) <= dummy_a(8);
				ELSIF exec_SBCD='1' THEN	
					set_flags(0) <= dummy_s(8);
				END IF;
			ELSIF datatype="10" OR exec_CPMAW='1' THEN 						--Long
				set_flags <= OP1IN(31)&flag_z(2)&addsub_ofl(2)&c_out(2);
			ELSE 						--Word
				set_flags <= OP1IN(15)&flag_z(1)&addsub_ofl(1)&c_out(1);
			END IF;
	END PROCESS;
			
------------------------------------------------------------------------------
--Flags
------------------------------------------------------------------------------		
PROCESS (clk, reset, opcode)
	BEGIN
		IF reset='0' THEN
			Flags(13) <= '1';
			SVmode <= '1';
			Flags(10 downto 8) <= "111";
		ELSIF rising_edge(clk) THEN		
		
	        IF clkena = '1' THEN
				IF directSR='1' THEN
					Flags <= data_read(15 downto 0);
				END IF;	
				IF directCCR='1' THEN
					Flags(7 downto 0) <= data_read(7 downto 0);
				END IF;	
				IF interrupt='1' THEN
					Flags(10 downto 8) <=rIPL_nr;
					SVmode <= '1';
				END IF;	
				IF writeSR='1' OR interrupt='1' THEN
					Flags(13) <='1';
				END IF;	
				IF endOPC='1' AND to_SR='0' THEN
					SVmode <= Flags(13);
				END IF;
				IF execOPC='1' AND to_SR='1' THEN
					Flags(7 downto 0) <= OP1in(7 downto 0);			--CCR
					IF datatype="01" AND (opcode(14)='0' OR opcode(9)='1') THEN		--move to CCR wird als word gespeichert
						Flags(15 downto 8) <= OP1in(15 downto 8);	--SR
						SVmode <= OP1in(13);
					END IF;	
				ELSIF Z_error='1' THEN
					IF opcode(8)='0' THEN
						Flags(3 downto 0) <= "1000";
					ELSE
						Flags(3 downto 0) <= "0100";
					END IF;		
				ELSIF no_Flags='0' AND trapmake='0' THEN
					IF exec_ADD='1' THEN
						Flags(4) <= set_flags(0);
					ELSIF exec_ROT='1' AND rot_bits/="11" AND rot_nop='0' THEN
						Flags(4) <= rot_XC; 	
					END IF;
					
					IF (exec_ADD OR exec_CMP)='1' THEN
						Flags(3 downto 0) <= set_flags;
					ELSIF decodeOPC='1' and set_exec_ROT='1' THEN
						Flags(1) <= '0';
					ELSIF exec_DIVU='1' THEN
						IF set_V_Flag='1' THEN	
							Flags(3 downto 0) <= "1010";
						ELSE
							Flags(3 downto 0) <= OP1IN(15)&flag_z(1)&"00";
						END IF;
					ELSIF exec_OR='1' OR exec_AND='1' OR exec_EOR='1' OR exec_MOVE='1' OR exec_swap='1' OR exec_MULU='1' THEN
						Flags(3 downto 0) <= set_flags(3 downto 2)&"00";
					ELSIF exec_ROT='1' THEN
						Flags(3 downto 2) <= set_flags(3 downto 2);
						Flags(0) <= rot_XC;
						IF rot_bits="00" THEN		--ASL/ASR
							Flags(1) <= ((set_flags(3) XOR rot_rot) OR Flags(1));	
						END IF;	
					ELSIF exec_bits='1' THEN
						Flags(2) <= NOT one_bit_in;				 	
					END IF;
				END IF;	
			END IF;	
		END IF;	
	END PROCESS;
	
-----------------------------------------------------------------------------
-- execute opcode
-----------------------------------------------------------------------------
PROCESS (clk, reset, OP2out, opcode, fetchOPC, decodeOPC, execOPC, endOPC, nextpass, condition, set_V_flag, trapmake, trapd, interrupt, trap_interrupt, rot_nop,
	     Z_error, c_in, rot_cnt, one_bit_in, bit_number_reg, bit_number, ea_only, get_ea_now, ea_build, datatype, exec_write_back, get_extendedOPC,
	     Flags, SVmode, movem_addr, movem_busy, getbrief, set_exec_AND, set_exec_OR, set_exec_EOR, TG68_PC_dec, c_out, OP1out, micro_state)
	BEGIN
		TG68_PC_br8 <= '0';	
		TG68_PC_brw <= '0';	
		TG68_PC_nop <= '0';	
		setstate <= "00";
		Regwrena <= '0';
		postadd <= '0';
		presub <= '0';
		movem_presub <= '0';
		setaddsub <= '1';
		setaddrlong <= '0';
		setnextpass <= '0';
		regdirectsource <= '0';
		setdisp <= '0';
		setdispbyte <= '0';
		setdispbrief <= '0';
		setbriefext <= '0';
		setgetbrief <= '0';
		longreaddirect <= '0';
		dest_areg <= '0';
		source_areg <= '0';
		data_is_source <= '0';
		write_back <= '0';
		setstackaddr <= '0';
		writePC <= '0';
		writePC_add <= '0';
		set_TG68_PC_dec <= '0';
		set_directPC <= '0';
		set_exec_ADD <= '0';
		set_exec_OR <= '0';
		set_exec_AND <= '0';
		set_exec_EOR <= '0';
		set_exec_MOVE <= '0';
		set_exec_MOVEQ <= '0';
		set_exec_MOVESR <= '0';
		set_exec_ADDQ <= '0';
		set_exec_CMP <= '0';
		set_exec_ROT <= '0';
		set_exec_EXT <= '0';
		set_exec_CPMAW <= '0';
		OP2out_one <= '0';
		ea_to_pc <= '0';
		ea_build <= '0';
		get_ea_now <= '0';
		rot_bits <= "XX";
		set_rot_nop <= '0';
		set_rot_cnt <= "000001";
		set_movem_busy <= '0';
		set_get_movem_mask <= '0';
		save_memaddr <= '0';
		set_mem_addsub <= '0';
		exec_exg <= '0';
		exec_swap <= '0';
		exec_Bits <= '0';
		set_get_bitnumber <= '0';
		dest_hbits <= '0';
		source_lowbits <= '0';
		set_mem_rega <= '0';
   		ea_data_OP1 <= '0';
		ea_only <= '0';
		set_direct_data <= '0';
		set_get_extendedOPC <= '0';
		set_exec_tas <= '0';
		OP1out_zero <= '0';
		use_XZFlag <= '0';
		use_XFlag <= '0';
		set_exec_ABCD <= '0';
		set_exec_SBCD <= '0';
		set_exec_MULU <= '0';
		set_exec_DIVU <= '0';
		set_exec_Scc <= '0';
		trap_illegal <='0';
		trap_priv <='0';
		trap_1010 <='0';
		trap_1111 <='0';
		trap_trap <='0';
		trap_trapv <= '0';
		trapmake <='0';
		set_vectoraddr <='0';
		writeSR <= '0';
		set_directSR <= '0';
		set_directCCR <= '0';
		set_stop <= '0';
		from_SR <= '0';
		to_SR <= '0';
		from_USP <= '0';
		to_USP <= '0';
		illegal_write_mode <= '0';
		illegal_read_mode <= '0';
		illegal_byteaddr <= '0';
		no_Flags <= '0';
		set_PCmarker <= '0';
		use_SP <= '0';
		set_Z_error <= '0';
		wait_mem_byte <= '0';
		set_movepl <= '0';
		set_movepw <= '0';

		trap_chk <= '0';
		next_micro_state <= idle;

------------------------------------------------------------------------------
--Sourcepass
------------------------------------------------------------------------------		
		IF ea_only='0' AND get_ea_now='1' THEN
			setstate <= "10";
		END IF;
		
		IF ea_build='1' THEN
			CASE opcode(5 downto 3) IS		--source
				WHEN "010"|"011"|"100" =>						-- -(An)+
					get_ea_now <='1';
					setnextpass <= '1';
					IF opcode(4)='1' THEN
						set_mem_rega <= '1';
					ELSE
						set_mem_addsub <= '1';
					END IF;
					IF opcode(3)='1' THEN	--(An)+
						postadd <= '1';
						IF opcode(2 downto 0)="111" THEN
							use_SP <= '1';
						END IF;
					END IF;	 	
					IF opcode(5)='1' THEN	-- -(An)
						presub <= '1'; 					
						IF opcode(2 downto 0)="111" THEN
							use_SP <= '1';
						END IF;
					END IF;	 	
					IF opcode(4 downto 3)/="10" THEN
						regwrena <= '1';
					END IF; 	
				WHEN "101" =>				--(d16,An)
					next_micro_state <= ld_dAn1;
					setgetbrief <='1';
					set_mem_regA <= '1';
				WHEN "110" =>				--(d8,An,Xn)
					next_micro_state <= ld_AnXn1;
					setgetbrief <='1';
					set_mem_regA <= '1';
				WHEN "111" =>
					CASE opcode(2 downto 0) IS
						WHEN "000" =>				--(xxxx).w
							next_micro_state <= ld_nn;
						WHEN "001" =>				--(xxxx).l
							longreaddirect <= '1';
							next_micro_state <= ld_nn;
						WHEN "010" =>				--(d16,PC)
							next_micro_state <= ld_dAn1;
							setgetbrief <= '1';
							set_PCmarker <= '1';
						WHEN "011" =>				--(d8,PC,Xn)
							next_micro_state <= ld_AnXn1;
							setgetbrief <= '1';
							set_PCmarker <= '1';
						WHEN "100" =>				--#data
							setnextpass <= '1';
							set_direct_data <= '1';
							IF datatype="10" THEN
								longreaddirect <= '1';
							END IF;
						WHEN OTHERS => 
					END CASE;
				WHEN OTHERS => 
			END CASE;
		END IF;
------------------------------------------------------------------------------
--prepere opcode
------------------------------------------------------------------------------		
		CASE opcode(7 downto 6) IS
			WHEN "00" => datatype <= "00";		--Byte
			WHEN "01" => datatype <= "01";		--Word
			WHEN OTHERS => datatype <= "10";	--Long
		END CASE;
		
		IF execOPC='1' AND endOPC='0' AND exec_write_back='1' THEN
			setstate <="11";
		END IF;		
		
------------------------------------------------------------------------------
--test illegal mode
------------------------------------------------------------------------------	
		IF (opcode(5 downto 3)="111" AND opcode(2 downto 1)/="00") OR (opcode(5 downto 3)="001" AND datatype="00") THEN
			illegal_write_mode <= '1';
		END IF;
		IF (opcode(5 downto 2)="1111" AND opcode(1 downto 0)/="00") OR (opcode(5 downto 3)="001" AND datatype="00") THEN
			illegal_read_mode <= '1';
		END IF;
		IF opcode(5 downto 3)="001" AND datatype="00" THEN
			illegal_byteaddr <= '1';
		END IF;

	
		CASE opcode(15 downto 12) IS
-- 0000 ----------------------------------------------------------------------------		
			WHEN "0000" => 
			IF opcode(8)='1' AND opcode(5 downto 3)="001" THEN --movep
				datatype <= "00";				--Byte
				use_SP <= '1';
				no_Flags <='1';
				IF opcode(7)='0' THEN
					set_exec_move <= '1';
					set_movepl <= '1';
				END IF;
				IF decodeOPC='1' THEN
					IF opcode(7)='0' THEN
						set_direct_data <= '1';
					END IF;
					next_micro_state <= movep1;
					setgetbrief <='1';
					set_mem_regA <= '1';
				END IF;
				IF opcode(7)='0' AND endOPC='1' THEN
					IF opcode(6)='1' THEN
						datatype <= "10";		--Long
					ELSE
						datatype <= "01";		--Word
					END IF;
					dest_hbits <='1';
					regwrena <= '1';
				END IF;
			ELSE
				IF opcode(8)='1' OR opcode(11 downto 8)="1000" THEN 				--Bits
					IF execOPC='1' AND get_extendedOPC='0' THEN
						IF opcode(7 downto 6)/="00" AND endOPC='1' THEN
							regwrena <= '1';
						END IF;
						exec_Bits <= '1';
						ea_data_OP1 <= '1';
					END IF;	
--					IF get_extendedOPC='1' THEN
--						datatype <= "01";			--Word
--					ELS
					IF opcode(5 downto 4)="00" THEN
						datatype <= "10";			--Long
					ELSE	
						datatype <= "00";			--Byte
						IF opcode(7 downto 6)/="00" THEN
							write_back <= '1';
						END IF;
					END IF;
					IF decodeOPC='1' THEN
						ea_build <= '1';
						IF opcode(8)='0' THEN
							IF opcode(5 downto 4)/="00" THEN	--Dn, An
								set_get_extendedOPC <= '1';
							END IF;
							set_get_bitnumber <= '1';
						END IF;
					END IF;
				ELSE								--andi, ...xxxi	
					IF opcode(11 downto 8)="0000" THEN	--ORI
						set_exec_OR <= '1';
					END IF;
					IF opcode(11 downto 8)="0010" THEN	--ANDI
						set_exec_AND <= '1';
					END IF;
					IF opcode(11 downto 8)="0100" OR opcode(11 downto 8)="0110" THEN	--SUBI, ADDI
						set_exec_ADD <= '1';
					END IF;
					IF opcode(11 downto 8)="1010" THEN	--EORI
						set_exec_EOR <= '1';
					END IF;
					IF opcode(11 downto 8)="1100" THEN	--CMPI
						set_exec_CMP <= '1';
					ELSIF trapmake='0' THEN	
						write_back <= '1';
					END IF;
					IF opcode(7)='0' AND opcode(5 downto 0)="111100" AND (set_exec_AND OR set_exec_OR OR set_exec_EOR)='1' THEN		--SR
--					IF opcode(7)='0' AND opcode(5 downto 0)="111100" AND (opcode(11 downto 8)="0010" OR opcode(11 downto 8)="0000" OR opcode(11 downto 8)="1010") THEN		--SR
						IF SVmode='0' AND opcode(6)='1' THEN  --SR
							trap_priv <= '1';
							trapmake <= '1';
						ELSE
							from_SR <= '1';
							to_SR <= '1';
							IF decodeOPC='1' THEN
								setnextpass <= '1';
								set_direct_data <= '1';
							END IF;
						END IF;
					ELSE
						IF decodeOPC='1' THEN
							IF opcode(11 downto 8)="0010" OR opcode(11 downto 8)="0000" OR opcode(11 downto 8)="0100"  	--ANDI, ORI, SUBI
							   OR opcode(11 downto 8)="0110" OR opcode(11 downto 8)="1010" OR opcode(11 downto 8)="1100" THEN	--ADDI, EORI, CMPI
	--						IF (set_exec_AND OR set_exec_OR OR set_exec_ADD  	--ANDI, ORI, SUBI
	--						   OR set_exec_EOR OR set_exec_CMP)='1' THEN	--ADDI, EORI, CMPI
								
								next_micro_state <= andi;
								set_direct_data <= '1';
								IF datatype="10" THEN
									longreaddirect <= '1';
								END IF;
							END IF;
						END IF;						
							
						IF execOPC='1' THEN
							ea_data_OP1 <= '1';
							IF opcode(11 downto 8)/="1100" THEN	--CMPI 
								IF endOPC='1' THEN
									Regwrena <= '1';
								END IF;
							END IF;
							IF opcode(11 downto 8)="1100"  OR opcode(11 downto 8)="0100" THEN	--CMPI, SUBI
								setaddsub <= '0';
							END IF;
						END IF;		
					END IF;		
				END IF;		
			END IF;		
				
-- 0001, 0010, 0011 -----------------------------------------------------------------		
			WHEN "0001"|"0010"|"0011" =>				--move.b, move.l, move.w
				set_exec_MOVE <= '1';
				IF opcode(8 downto 6)="001" THEN	
					no_Flags <= '1';
				END IF;
				IF opcode(5 downto 4)="00" THEN	--Dn, An
					regdirectsource <= '1';
				END IF;
				CASE opcode(13 downto 12) IS
					WHEN "01" => datatype <= "00";		--Byte
					WHEN "10" => datatype <= "10";		--Long
					WHEN OTHERS => datatype <= "01";	--Word
				END CASE;
				source_lowbits <= '1';					-- Dn=>  An=>
				IF opcode(3)='1' THEN
					source_areg <= '1';
				END IF;
				IF getbrief='1' AND nextpass='1' THEN	-- =>(d16,An)  =>(d8,An,Xn)
					set_mem_rega <= '1';
				END IF;	
				
				IF execOPC='1' AND opcode(8 downto 7)="00" THEN
					Regwrena <= '1';
				END IF;	
				
				IF nextpass='1' OR execOPC='1' OR opcode(5 downto 4)="00" THEN	
					dest_hbits <= '1';
					IF opcode(8 downto 6)/="000" THEN
						dest_areg <= '1';
					END IF;
				END IF;

				IF decodeOPC='1' THEN 
					ea_build <= '1';
				END IF;
				
				IF micro_state=idle AND (nextpass='1' OR (opcode(5 downto 4)="00" AND decodeOPC='1')) THEN	
					CASE opcode(8 downto 6) IS		--destination
--						WHEN "000" =>						--Dn
--						WHEN "001" =>						--An
						WHEN "010"|"011"|"100" =>					--destination -(an)+
							IF opcode(7)='1' THEN
								set_mem_rega <= '1';
							ELSE
								set_mem_addsub <= '1';
							END IF;
							IF opcode(6)='1' THEN	--(An)+
								postadd <= '1';
								IF opcode(11 downto 9)="111" THEN
									use_SP <= '1';
								END IF;
							END IF;	 	
							IF opcode(8)='1' THEN	-- -(An)
								presub <= '1'; 					
								IF opcode(11 downto 9)="111" THEN
									use_SP <= '1';
								END IF;
							END IF;	
							IF opcode(7 downto 6)/="10" THEN
								regwrena <= '1';
							END IF; 
							setstate <= "11";
							next_micro_state <= nop;
						WHEN "101" =>				--(d16,An)
							next_micro_state <= st_dAn1;
							set_mem_regA <= '1';
							setgetbrief <= '1';
						WHEN "110" =>				--(d8,An,Xn)
							next_micro_state <= st_AnXn1;
							set_mem_regA <= '1';
							setgetbrief <= '1';
						WHEN "111" =>
							CASE opcode(11 downto 9) IS
								WHEN "000" =>				--(xxxx).w
									next_micro_state <= st_nn;
								WHEN "001" =>				--(xxxx).l
									longreaddirect <= '1';
									next_micro_state <= st_nn;
								WHEN OTHERS => 
							END CASE;
						WHEN OTHERS => 
					END CASE;
				END IF;	
-- 0100 ----------------------------------------------------------------------------		
			WHEN "0100" =>				--rts_group
				IF opcode(8)='1' THEN		--lea
					IF opcode(6)='1' THEN		--lea
						IF opcode(7)='1' THEN		
							ea_only <= '1';
							IF opcode(5 downto 3)="010" THEN  	--lea (Am),An
								set_exec_move <='1';
								no_Flags <='1';
								dest_areg <= '1';
								dest_hbits <= '1';
								source_lowbits <= '1';
								source_areg <= '1';
								IF execOPC='1' THEN
									Regwrena <= '1';
								END IF;	
							ELSE
								IF decodeOPC='1' THEN
									ea_build <= '1';
								END IF;	
							END IF;	
							IF get_ea_now='1' THEN
								dest_areg <= '1';
								dest_hbits <= '1';
								regwrena <= '1';					
							END IF;
						ELSE
							trap_illegal <= '1';
							trapmake <= '1';
						END IF;
					ELSE								--chk
						IF opcode(7)='1' THEN
							set_exec_ADD <= '1';
							IF decodeOPC='1' THEN
								ea_build <= '1';
							END IF;		
							datatype <= "01";	--Word
							IF execOPC='1' THEN
								setaddsub <= '0';
--first alternative
								ea_data_OP1 <= '1';
								IF c_out(1)='1' OR OP1out(15)='1' OR OP2out(15)='1' THEN
					--				trap_chk <= '1';	--first I must change the Trap System
					--				trapmake <= '1';
								END IF;
--second alternative									
--								IF (c_out(1)='0' AND flag_z(1)='0') OR OP1out(15)='1' OR OP2out(15)='1' THEN
--					--				trap_chk <= '1';	--first I must change the Trap System
--					--				trapmake <= '1';
--								END IF;
--								dest_hbits <= '1';
--								source_lowbits <='1';
							END IF;	
						ELSE
							trap_illegal <= '1';		-- chk long for 68020
							trapmake <= '1';
						END IF;
					END IF;
				ELSE
					CASE opcode(11 downto 9) IS
						WHEN "000"=>
							IF decodeOPC='1' THEN
								ea_build <= '1';
							END IF;
							IF opcode(7 downto 6)="11" THEN					--move from SR
								set_exec_MOVESR <= '1';
								datatype <= "01";
								write_back <='1';							-- im 68000 wird auch erst gelesen
								IF execOPC='1' THEN
									IF endOPC='1' THEN
										Regwrena <= '1';
									END IF;
								END IF;
							ELSE											--negx
								use_XFlag <= '1';
								write_back <='1';
								set_exec_ADD <= '1';
								setaddsub <='0';
								IF execOPC='1' THEN
									source_lowbits <= '1';
									OP1out_zero <= '1';
									IF endOPC='1' THEN
										Regwrena <= '1';
									END IF;
								END IF;
							END IF;
						WHEN "001"=>
							IF opcode(7 downto 6)="11" THEN					--move from CCR 68010
								trap_illegal <= '1';
								trapmake <= '1';
							ELSE											--clr
								IF decodeOPC='1' THEN
									ea_build <= '1';
								END IF;
								write_back <='1';
								set_exec_AND <= '1';
								IF execOPC='1' THEN
									OP1out_zero <= '1';
									IF endOPC='1' THEN
										Regwrena <= '1';
									END IF;
								END IF;
							END IF;
						WHEN "010"=>
							IF decodeOPC='1' THEN
								ea_build <= '1';
							END IF;
							IF opcode(7 downto 6)="11" THEN					--move to CCR
								set_exec_MOVE <= '1';
								datatype <= "01";
								IF execOPC='1' THEN
									source_lowbits <= '1';
									to_SR <= '1';
								END IF;
							ELSE											--neg
								write_back <='1';
								set_exec_ADD <= '1';
								setaddsub <='0';
								IF execOPC='1' THEN
									source_lowbits <= '1';
									OP1out_zero <= '1';
									IF endOPC='1' THEN
										Regwrena <= '1';
									END IF;
								END IF;
							END IF;
						WHEN "011"=>										--not, move toSR
							IF opcode(7 downto 6)="11" THEN					--move to SR
								IF SVmode='1' THEN
									IF decodeOPC='1' THEN
										ea_build <= '1';
									END IF;
									set_exec_MOVE <= '1';
									datatype <= "01";
									IF execOPC='1' THEN
										source_lowbits <= '1';
										to_SR <= '1';
									END IF;
								ELSE
									trap_priv <= '1';
									trapmake <= '1';
								END IF;
							ELSE											--not
								IF decodeOPC='1' THEN
									ea_build <= '1';
								END IF;
								write_back <='1';
								set_exec_EOR <= '1';
								IF execOPC='1' THEN
									OP2out_one <= '1';
									ea_data_OP1 <= '1';
									IF endOPC='1' THEN
										Regwrena <= '1';
									END IF;
								END IF;
							END IF;
						WHEN "100"|"110"=>
							IF opcode(7)='1' THEN			--movem, ext
								IF opcode(5 downto 3)="000" AND opcode(10)='0' THEN		--ext
									source_lowbits <= '1';
									IF decodeOPC='1' THEN
										set_exec_EXT <= '1';
										set_exec_move <= '1';
									END IF;
									IF opcode(6)='0' THEN
										datatype <= "01";		--WORD
									END IF;
									IF execOPC='1' THEN
										regwrena <= '1';	
									END IF;
								ELSE													--movem
--								IF opcode(11 downto 7)="10001" OR opcode(11 downto 7)="11001" THEN	--MOVEM
									ea_only <= '1';
									IF decodeOPC='1' THEN
										datatype <= "01";		--Word
										set_get_movem_mask <='1';
										set_get_extendedOPC <='1';
										
										IF opcode(5 downto 3)="010" OR opcode(5 downto 3)="011" OR opcode(5 downto 3)="100" THEN
											set_mem_rega <= '1';
											setstate <= "01";
											IF opcode(10)='0' THEN
												set_movem_busy <='1';
											ELSE	
												next_micro_state <= movem;
											END IF;
										ELSE	
											ea_build <= '1';
										END IF;
										
									ELSE	
										IF opcode(6)='0' THEN
											datatype <= "01";		--Word
										END IF;
									END IF;
									IF execOPC='1' THEN
										IF opcode(5 downto 3)="100" OR opcode(5 downto 3)="011" THEN
											regwrena <= '1';
											save_memaddr <= '1';
										END IF;
									END IF;	
									IF get_ea_now='1' THEN
										set_movem_busy <= '1';
										IF opcode(10)='0' THEN
											setstate <="01";
										ELSE
											setstate <="10";
										END IF;
									END IF;
										IF opcode(5 downto 3)="100" THEN
											movem_presub <= '1';
										END IF;
										IF movem_addr='1' THEN
											IF opcode(10)='1' THEN
												regwrena <= '1';	
											END IF;
										END IF;	
										IF movem_busy='1' THEN
											IF opcode(10)='0' THEN
												setstate <="11";
											ELSE
												setstate <="10";
											END IF;
										END IF;	
								END IF;	
							ELSE
								IF opcode(10)='1' THEN						--MUL, DIV 68020
									trap_illegal <= '1';
									trapmake <= '1';
								ELSE							--pea, swap
									IF opcode(6)='1' THEN
										datatype <= "10";
										IF opcode(5 downto 3)="000" THEN 		--swap
											IF execOPC='1' THEN
												exec_swap <= '1';
												regwrena <= '1';	
											END IF;	
										ELSIF opcode(5 downto 3)="001" THEN 		--bkpt
										
										ELSE									--pea
											ea_only <= '1';
											IF decodeOPC='1' THEN
												ea_build <= '1';
											END IF;
											IF nextpass='1' AND micro_state=idle THEN
												presub <= '1';
												setstackaddr <='1';
												set_mem_addsub <= '1';
												setstate <="11";
												next_micro_state <= nop;
											END IF;
											IF get_ea_now='1' THEN
												setstate <="01";
											END IF;
										END IF;	
									ELSE								--nbcd	
										IF decodeOPC='1' THEN		--nbcd
											ea_build <= '1';
										END IF;
										use_XFlag <= '1';
										write_back <='1';
										set_exec_ADD <= '1';
										set_exec_SBCD <= '1';
										IF execOPC='1' THEN 
											source_lowbits <= '1';
											OP1out_zero <= '1';
											IF endOPC='1' THEN
												Regwrena <= '1';
											END IF;
										END IF;
									END IF;
								END IF;
							END IF;
							
						WHEN "101"=>						--tst, tas
							IF opcode(7 downto 2)="111111" THEN   --4AFC illegal
								trap_illegal <= '1';
								trapmake <= '1';
							ELSE
								IF decodeOPC='1' THEN
									ea_build <= '1';
								END IF;
								IF execOPC='1' THEN
									dest_hbits <= '1';				--for Flags
									source_lowbits <= '1';
			--						IF opcode(3)='1' THEN			--MC68020...
			--							source_areg <= '1';
			--						END IF;
								END IF;
								set_exec_MOVE <= '1';
								IF opcode(7 downto 6)="11" THEN		--tas
									set_exec_tas <= '1';
									write_back <= '1';
									datatype <= "00";				--Byte
									IF execOPC='1' AND endOPC='1' THEN
										regwrena <= '1';
									END IF;
								END IF;
							END IF;
--						WHEN "110"=>
						WHEN "111"=>					--4EXX
							IF opcode(7)='1' THEN		--jsr, jmp
								datatype <= "10";
								ea_only <= '1';
								IF nextpass='1' AND micro_state=idle THEN
									presub <= '1';
									setstackaddr <='1';
									set_mem_addsub <= '1';
									setstate <="11";
									next_micro_state <= nop;
								END IF;
								IF decodeOPC='1' THEN
									ea_build <= '1';
								END IF;
								IF get_ea_now='1' THEN					--jsr
									IF opcode(6)='0' THEN
										setstate <="01";
									END IF;	
									ea_to_pc <= '1';
									IF opcode(5 downto 1)="11100" THEN
										writePC_add <= '1';
									ELSE
										writePC <= '1';
									END IF;
								END IF;
							ELSE						--
								CASE opcode(6 downto 0) IS
									WHEN "1000000"|"1000001"|"1000010"|"1000011"|"1000100"|"1000101"|"1000110"|"1000111"|		--trap
									     "1001000"|"1001001"|"1001010"|"1001011"|"1001100"|"1001101"|"1001110"|"1001111" =>		--trap
											trap_trap <='1';
											trapmake <= '1';
									WHEN "1010000"|"1010001"|"1010010"|"1010011"|"1010100"|"1010101"|"1010110"|"1010111" =>		--link
										datatype <= "10";
										IF decodeOPC='1' THEN
											next_micro_state <= link;
											set_exec_MOVE <= '1';						--für displacement
											presub <= '1';
											setstackaddr <='1';
											set_mem_addsub <= '1';
											source_lowbits <= '1';
											source_areg <= '1';
										END IF;
										IF execOPC='1' THEN
											setstackaddr <='1';
											regwrena <= '1';
										END IF;
									
									WHEN "1011000"|"1011001"|"1011010"|"1011011"|"1011100"|"1011101"|"1011110"|"1011111" =>		--unlink
										datatype <= "10";
										IF decodeOPC='1' THEN
											setstate <= "10";
											set_mem_rega <= '1';
										ELSIF execOPC='1' THEN
											regwrena <= '1';
											exec_exg <= '1';
										ELSE	
											setstackaddr <='1';
											regwrena <= '1';
											get_ea_now <= '1';
											ea_only <= '1';
										END IF;
									
									WHEN "1100000"|"1100001"|"1100010"|"1100011"|"1100100"|"1100101"|"1100110"|"1100111" =>		--move An,USP
										IF SVmode='1' THEN
											no_Flags <= '1';
											to_USP <= '1';
											setstackaddr <= '1';
											source_lowbits <= '1';
											source_areg <= '1';
											set_exec_MOVE <= '1';
											datatype <= "10";
											IF execOPC='1' THEN
												regwrena <= '1';
											END IF;
										ELSE
											trap_priv <= '1';
											trapmake <= '1';
										END IF;
									WHEN "1101000"|"1101001"|"1101010"|"1101011"|"1101100"|"1101101"|"1101110"|"1101111" =>		--move USP,An
										IF SVmode='1' THEN
											no_Flags <= '1';
											from_USP <= '1';
											set_exec_MOVE <= '1';
											datatype <= "10";
											IF execOPC='1' THEN
												regwrena <= '1';
											END IF;
										ELSE
											trap_priv <= '1';
											trapmake <= '1';
										END IF;
									
									WHEN "1110000" =>					--reset
										IF SVmode='0' THEN
											trap_priv <= '1';
											trapmake <= '1';
										END IF;
										
									WHEN "1110001" =>					--nop
									
									WHEN "1110010" =>					--stop
										IF SVmode='0' THEN
											trap_priv <= '1';
											trapmake <= '1';
										ELSE
											IF decodeOPC='1' THEN
												setnextpass <= '1';
												set_directSR <= '1';
												set_stop <= '1';	
											END IF;
										END IF;
									
									WHEN "1110011" =>  									--rte
										IF SVmode='1' THEN
											IF decodeOPC='1' THEN
												datatype <= "01";
												setstate <= "10";
												postadd <= '1';
												setstackaddr <= '1';
												set_mem_rega <= '1';
												set_directSR <= '1';	
												next_micro_state <= rte;
											END IF;
										ELSE
											trap_priv <= '1';
											trapmake <= '1';
										END IF;
										
									WHEN "1110101" =>  									--rts
										IF decodeOPC='1' THEN
											datatype <= "10";
											setstate <= "10";
											postadd <= '1';
											setstackaddr <= '1';
											set_mem_rega <= '1';
											set_directPC <= '1';	
											next_micro_state <= nop;
										END IF;
										
									WHEN "1110110" =>  									--trapv
										IF Flags(1)='1' THEN
											trap_trapv <= '1';
											trapmake <= '1';
										END IF;
										
									WHEN "1110111" =>  									--rtr
										IF decodeOPC='1' THEN
											datatype <= "01";
											setstate <= "10";
											postadd <= '1';
											setstackaddr <= '1';
											set_mem_rega <= '1';
											set_directCCR <= '1';	
											next_micro_state <= rte;
										END IF;
									
									
									WHEN OTHERS =>	
										trap_illegal <= '1';
										trapmake <= '1';
								END CASE;	
							END IF;
						WHEN OTHERS => null;
					END CASE;
				END IF;	
					
-- 0101 ----------------------------------------------------------------------------		
			WHEN "0101" => 								--subq, addq	
				
					IF opcode(7 downto 6)="11" THEN --dbcc
						IF opcode(5 downto 3)="001" THEN --dbcc
							datatype <= "01";			--Word
							IF decodeOPC='1' THEN
								next_micro_state <= nop;
								OP2out_one <= '1';
								IF condition='0' THEN
									Regwrena <= '1';
									IF c_in(2)='1' THEN
										next_micro_state <= dbcc1;
									END IF;	
								END IF;
								data_is_source <= '1';
							END IF;
						ELSE				--Scc
							datatype <= "00";			--Byte
							write_back <= '1';
							IF decodeOPC='1' THEN
								ea_build <= '1';
							END IF;
							IF condition='0' THEN
								set_exec_Scc <= '1';
							END IF;
							IF execOPC='1' THEN
								IF condition='1' THEN
									OP2out_one <= '1';
									exec_EXG <= '1';
								ELSE
									OP1out_zero <= '1';
								END IF;
								IF endOPC='1' THEN
									Regwrena <= '1';
								END IF;
							END IF;
						END IF;
					ELSE					--addq, subq
						IF decodeOPC='1' THEN
							ea_build <= '1';
						END IF;		
						IF opcode(5 downto 3)="001" THEN	
							no_Flags <= '1';
						END IF;
						write_back <= '1';
						set_exec_ADDQ <= '1';
						set_exec_ADD <= '1';
						IF execOPC='1' THEN
							ea_data_OP1 <= '1';
							IF endOPC='1' THEN
								Regwrena <= '1';
							END IF;
							IF opcode(8)='1' THEN
								setaddsub <= '0';
							END IF;
						END IF;	
					END IF;	
				
-- 0110 ----------------------------------------------------------------------------		
			WHEN "0110" =>				--bra,bsr,bcc
				datatype <= "10";
				
				IF micro_state=idle THEN
					IF opcode(11 downto 8)="0001" THEN		--bsr
						IF opcode(7 downto 0)="00000000" THEN
							next_micro_state <= bsr1;
						ELSE	
							next_micro_state <= bsr2;
							setstate <= "01";
						END IF;
						presub <= '1';
						setstackaddr <='1';
						set_mem_addsub <= '1';
					ELSE									--bra
						IF opcode(7 downto 0)="00000000" THEN
							next_micro_state <= bra1;
						END IF;
						IF condition='1' THEN
							TG68_PC_br8 <= '1';
						END IF;
					END IF;
				END IF;	
				
-- 0111 ----------------------------------------------------------------------------		
			WHEN "0111" =>				--moveq
				IF opcode(8)='0' THEN
					IF trap_interrupt='0' THEN
						datatype <= "10";		--Long
						Regwrena <= '1';
						set_exec_MOVEQ <= '1';
						set_exec_MOVE <= '1';
						dest_hbits <= '1';
					END IF;	
				ELSE
					trap_illegal <= '1';
					trapmake <= '1';
				END IF;
				
-- 1000 ----------------------------------------------------------------------------		
			WHEN "1000" => 								--or	
				IF opcode(7 downto 6)="11" THEN	--divu, divs
					IF opcode(5 downto 4)="00" THEN	--Dn, An
						regdirectsource <= '1';
					END IF;
					IF (micro_state=idle AND nextpass='1') OR (opcode(5 downto 4)="00" AND decodeOPC='1') THEN	
						set_exec_DIVU <= '1';
						setstate <="01";
						next_micro_state <= div1;
					END IF;
					IF decodeOPC='1' THEN
						ea_build <= '1';
					END IF;
					IF execOPC='1' AND z_error='0' AND set_V_Flag='0' THEN
						regwrena <= '1';
					END IF;
					IF (micro_state/=idle AND nextpass='1') OR execOPC='1' THEN
						dest_hbits <= '1';
						source_lowbits <='1';
					ELSE									
						datatype <= "01";
					END IF;
					
			
				ELSIF opcode(8)='1' AND opcode(5 downto 4)="00" THEN	--sbcd, pack , unpack
					IF opcode(7 downto 6)="00" THEN	--sbcd
						use_XZFlag <= '1';
						set_exec_ADD <= '1';
						set_exec_SBCD <= '1';
						IF opcode(3)='1' THEN
							write_back <= '1';
							IF decodeOPC='1' THEN
								set_direct_data <= '1';
								setstate <= "10";
								set_mem_addsub <= '1';
								presub <= '1';
								next_micro_state <= op_AxAy;
							END IF;
						END IF;
						IF execOPC='1' THEN
							ea_data_OP1 <= '1';
							dest_hbits <= '1';
							source_lowbits <='1';
							IF endOPC='1' THEN
								Regwrena <= '1';
							END IF;
						END IF;
					ELSE									--pack, unpack
						trap_illegal <= '1';
						trapmake <= '1';
					END IF;
				ELSE									--or
					set_exec_OR <= '1';
					IF opcode(8)='1' THEN
						 write_back <= '1';
					END IF;
					IF decodeOPC='1' THEN
						ea_build <= '1';
					END IF;	
					IF execOPC='1' THEN
						IF endOPC='1' THEN
							Regwrena <= '1';
						END IF;
						IF opcode(8)='1' THEN
							ea_data_OP1 <= '1';
						ELSE	
							dest_hbits <= '1';
							source_lowbits <='1';
							IF opcode(3)='1' THEN
								source_areg <= '1';
							END IF;
						END IF;
					END IF;		
				END IF;
				
-- 1001, 1101 -----------------------------------------------------------------------		
			WHEN "1001"|"1101" => 						--sub, add	
				set_exec_ADD <= '1';
				IF decodeOPC='1' THEN
					ea_build <= '1';
				END IF;		
				IF opcode(8 downto 6)="011" THEN	--adda.w, suba.w
					datatype <= "01";	--Word
				END IF;
				IF execOPC='1' THEN
					IF endOPC='1' THEN
						Regwrena <= '1';
					END IF;
					IF opcode(14)='0' THEN
						setaddsub <= '0';
					END IF;
				END IF;
				IF opcode(8)='1' AND opcode(5 downto 4)="00" AND opcode(7 downto 6)/="11" THEN		--addx, subx
					use_XZFlag <= '1';
					IF opcode(3)='1' THEN
						write_back <= '1';
						IF decodeOPC='1' THEN
							set_direct_data <= '1';
							setstate <= "10";
							set_mem_addsub <= '1';
							presub <= '1';
							next_micro_state <= op_AxAy;
						END IF;
					END IF;
					IF execOPC='1' THEN
						ea_data_OP1 <= '1';
						dest_hbits <= '1';
						source_lowbits <='1';
					END IF;
				ELSE													--sub, add
					IF opcode(8)='1' AND opcode(7 downto 6)/="11" THEN
						 write_back <= '1';
					END IF;
					IF execOPC='1' THEN
						IF	opcode(7 downto 6)="11" THEN	--adda, suba
							no_Flags <= '1';
							dest_areg <='1';
							dest_hbits <= '1';
							source_lowbits <='1';
							IF opcode(3)='1' THEN
								source_areg <= '1';
							END IF;
						ELSE	
							IF opcode(8)='1' THEN
								ea_data_OP1 <= '1';
							ELSE	
								dest_hbits <= '1';
								source_lowbits <='1';
								IF opcode(3)='1' THEN
									source_areg <= '1';
								END IF;
							END IF;
						END IF;
					END IF;	
				END IF;		
				
-- 1010 ----------------------------------------------------------------------------		
			WHEN "1010" => 							--Trap 1010
				trap_1010 <= '1';
				trapmake <= '1';
-- 1011 ----------------------------------------------------------------------------		
			WHEN "1011" => 							--eor, cmp
				IF decodeOPC='1' THEN
					ea_build <= '1';
				END IF;		
				IF opcode(8 downto 6)="011" THEN	--cmpa.w
					datatype <= "01";	--Word
					set_exec_CPMAW <= '1';
				END IF;
				IF opcode(8)='1' AND opcode(5 downto 3)="001" AND opcode(7 downto 6)/="11" THEN		--cmpm
					set_exec_CMP <= '1';
					IF decodeOPC='1' THEN
						set_direct_data <= '1';
						setstate <= "10";
						set_mem_rega <= '1';
						postadd <= '1';
						next_micro_state <= cmpm;
					END IF;
					IF execOPC='1' THEN
						ea_data_OP1 <= '1';
						setaddsub <= '0';
					END IF;
				ELSE													--sub, add
					IF opcode(8)='1' AND opcode(7 downto 6)/="11" THEN	--eor
						set_exec_EOR <= '1';
						 write_back <= '1';
					ELSE					--cmp
						set_exec_CMP <= '1';
					END IF;	
					
					IF execOPC='1' THEN
						IF opcode(8)='1' AND opcode(7 downto 6)/="11" THEN	--eor
							ea_data_OP1 <= '1';		
							IF endOPC='1' THEN
								Regwrena <= '1';
							END IF;
						ELSE									--cmp
							source_lowbits <='1';
							IF opcode(3)='1' THEN
								source_areg <= '1';
							END IF;
							IF	opcode(7 downto 6)="11" THEN	--cmpa
								dest_areg <='1';
							END IF;
							dest_hbits <= '1';
							setaddsub <= '0';
						END IF;	
					END IF;	
				END IF;	
				
-- 1100 ----------------------------------------------------------------------------		
			WHEN "1100" => 								--and, exg
				IF opcode(7 downto 6)="11" THEN	--mulu, muls
					IF opcode(5 downto 4)="00" THEN	--Dn, An
						regdirectsource <= '1';
					END IF;
					IF (micro_state=idle AND nextpass='1') OR (opcode(5 downto 4)="00" AND decodeOPC='1') THEN	
						set_exec_MULU <= '1';
						setstate <="01";
						next_micro_state <= mul1;
					END IF;
					IF decodeOPC='1' THEN
						ea_build <= '1';
					END IF;
					IF	execOPC='1' THEN
						regwrena <= '1';
					END IF;
					IF (micro_state/=idle AND nextpass='1') OR execOPC='1' THEN
						dest_hbits <= '1';
						source_lowbits <='1';
					ELSE									
						datatype <= "01";
					END IF;
			
				ELSIF opcode(8)='1' AND opcode(5 downto 4)="00" THEN	--exg, abcd
					IF opcode(7 downto 6)="00" THEN	--abcd
						use_XZFlag <= '1';
--						datatype <= "00";		--ist schon default
						set_exec_ADD <= '1';
						set_exec_ABCD <= '1';
						IF opcode(3)='1' THEN
							write_back <= '1';
							IF decodeOPC='1' THEN
								set_direct_data <= '1';
								setstate <= "10";
								set_mem_addsub <= '1';
								presub <= '1';
								next_micro_state <= op_AxAy;
							END IF;
						END IF;
						IF execOPC='1' THEN
							ea_data_OP1 <= '1';
							dest_hbits <= '1';
							source_lowbits <='1';
							IF endOPC='1' THEN
								Regwrena <= '1';
							END IF;
						END IF;
					ELSE									--exg
						datatype <= "10";
						regwrena <= '1';
						IF opcode(6)='1' AND opcode(3)='1' THEN
							dest_areg <= '1';
							source_areg <= '1';
						END IF;	
						IF decodeOPC='1' THEN
							set_mem_rega <= '1';
							exec_exg <= '1';
						ELSE
							save_memaddr <= '1';
							dest_hbits <= '1';
						END IF;
					END IF;
				ELSE									--and
					set_exec_AND <= '1';
					IF opcode(8)='1' THEN
						 write_back <= '1';
					END IF;
					IF decodeOPC='1' THEN
						ea_build <= '1';
					END IF;	
					
					IF execOPC='1' THEN
						IF endOPC='1' THEN
							Regwrena <= '1';
						END IF;
						IF opcode(8)='1' THEN
							ea_data_OP1 <= '1';
						ELSE	
							dest_hbits <= '1';
							source_lowbits <='1';
							IF opcode(3)='1' THEN
								source_areg <= '1';
							END IF;
						END IF;
					END IF;		
				END IF;	
				
-- 1110 ----------------------------------------------------------------------------		
			WHEN "1110" => 								--rotation	
				set_exec_ROT <= '1';
				IF opcode(7 downto 6)="11" THEN
					datatype <= "01";
					rot_bits <= opcode(10 downto 9);
					ea_data_OP1 <= '1';
					write_back <= '1';
				ELSE	
					rot_bits <= opcode(4 downto 3);
					data_is_source <= '1';
				END IF;	
				
				IF decodeOPC='1' THEN
					IF opcode(7 downto 6)="11" THEN
						ea_build <= '1';
					ELSE
						IF opcode(5)='1' THEN
							IF OP2out(5 downto 0)/="000000" THEN
								set_rot_cnt <= OP2out(5 downto 0);
							ELSE
								set_rot_nop <= '1';
							END IF;
						ELSE
							set_rot_cnt(2 downto 0) <= opcode(11 downto 9);
							IF opcode(11 downto 9)="000" THEN
								set_rot_cnt(3) <='1';
							ELSE
								set_rot_cnt(3) <='0';
							END IF;
						END IF;
					END IF;	
				END IF;	
				IF opcode(7 downto 6)/="11" THEN
					IF execOPC='1' AND rot_nop='0' THEN
						Regwrena <= '1';
						set_rot_cnt <= rot_cnt-1;
					END IF;	
				END IF;	
							
--      ----------------------------------------------------------------------------		
			WHEN OTHERS =>	
				trap_1111 <= '1';
				trapmake <= '1';

		END CASE;		
		
--	END PROCESS;
	
-----------------------------------------------------------------------------
-- execute microcode
-----------------------------------------------------------------------------
--PROCESS (micro_state)
--	BEGIN
		IF Z_error='1'  THEN		-- divu by zero
			trapmake <= '1';			--wichtig für USP
			IF trapd='0' THEN
				writePC <= '1';
			END IF;			
		END IF;	
		
		IF trapmake='1' AND trapd='0' THEN
			next_micro_state <= trap1;
			presub <= '1';
			setstackaddr <='1';
			set_mem_addsub <= '1';
			setstate <= "11";
			datatype <= "10";
		END IF;	
		
		IF interrupt='1' THEN
			next_micro_state <= int1;
			setstate <= "10";
--			datatype <= "01";		--wirkt sich auf Flags aus
		END IF;	

		IF reset='0' THEN
			micro_state <= init1;
		ELSIF rising_edge(clk) THEN
	        IF clkena='1' THEN
				trapd <= trapmake;
				IF fetchOPC='1' THEN
					micro_state <= idle;
				ELSE
					micro_state <= next_micro_state;
				END IF;	
			END IF;
		END IF;
			CASE micro_state IS
				WHEN ld_nn =>		-- (nnnn).w/l=>
					get_ea_now <='1';
					setnextpass <= '1';
					setaddrlong <= '1';
					
				WHEN st_nn =>		-- =>(nnnn).w/l
					setstate <= "11";
					setaddrlong <= '1';
					next_micro_state <= nop;
					
				WHEN ld_dAn1 =>		-- d(An)=>, --d(PC)=>
					setstate <= "01";
					next_micro_state <= ld_dAn2;
				WHEN ld_dAn2 =>		-- d(An)=>, --d(PC)=>
					get_ea_now <='1';
					setdisp <= '1';		--word
					setnextpass <= '1';
					
				WHEN ld_AnXn1 =>		-- d(An,Xn)=>, --d(PC,Xn)=>
					setstate <= "01";
					next_micro_state <= ld_AnXn2;
				WHEN ld_AnXn2 =>		-- d(An,Xn)=>, --d(PC,Xn)=>
					setdisp <= '1';		--byte	
					setdispbyte <= '1';
					setstate <= "01";
					setbriefext <= '1';
					next_micro_state <= ld_AnXn3;
				WHEN ld_AnXn3 =>
					get_ea_now <='1';
					setdisp <= '1';		--brief
					setdispbrief <= '1';
					setnextpass <= '1';
					
				WHEN st_dAn1 =>		-- =>d(An)
					setstate <= "01";
					next_micro_state <= st_dAn2;
				WHEN st_dAn2 =>		-- =>d(An)
					setstate <= "11";
					setdisp <= '1';		--word
					next_micro_state <= nop;
					
				WHEN st_AnXn1 =>		-- =>d(An,Xn)
					setstate <= "01";
					next_micro_state <= st_AnXn2;
				WHEN st_AnXn2 =>		-- =>d(An,Xn)
					setdisp <= '1';		--byte
					setdispbyte <= '1';
					setstate <= "01";
					setbriefext <= '1';
					next_micro_state <= st_AnXn3;
				WHEN st_AnXn3 =>
					setstate <= "11";
					setdisp <= '1';		--brief	
					setdispbrief <= '1';
					next_micro_state <= nop;
					
				WHEN bra1 =>		--bra
					IF condition='1' THEN
						TG68_PC_br8 <= '1';	--pc+0000
						setstate <= "01";
						next_micro_state <= bra2;
					END IF;
				WHEN bra2 =>		--bra
					TG68_PC_brw <= '1';	
					
				WHEN bsr1 =>		--bsr
					set_TG68_PC_dec <= '1';		--in 2 Takten -2
					setstate <= "01";
					next_micro_state <= bsr2;
				WHEN bsr2 =>		--bsr
					IF TG68_PC_dec(0)='1' THEN
						TG68_PC_brw <= '1';	
					ELSE
						TG68_PC_br8 <= '1';	
					END IF;	
					writePC <= '1';
					setstate <= "11";
					next_micro_state <= nop;

				WHEN dbcc1 =>		--dbcc
					TG68_PC_nop <= '1';	
					setstate <= "01";
					next_micro_state <= dbcc2;
				WHEN dbcc2 =>		--dbcc
					TG68_PC_brw <= '1';	
				
				WHEN movem =>		--movem
					set_movem_busy <='1';
					setstate <= "10";

				WHEN andi =>		--andi
					IF opcode(5 downto 4)/="00" THEN
						ea_build <= '1';
						setnextpass <= '1';
					END IF;

				WHEN op_AxAy =>		-- op -(Ax),-(Ay)
					presub <= '1';
					dest_hbits <= '1'; 
					dest_areg <= '1';
					set_mem_addsub <= '1';
					setstate <= "10";

				WHEN cmpm =>		-- cmpm (Ay)+,(Ax)+
					postadd <= '1';
					dest_hbits <= '1'; 
					dest_areg <= '1';
					set_mem_rega <= '1';
					setstate <= "10";
					
				WHEN link =>		-- link
					setstate <="11";
					save_memaddr <= '1';
					regwrena <= '1';
					
				WHEN int1 =>		-- interrupt
					presub <= '1';
					setstackaddr <='1';
					set_mem_addsub <= '1';
					setstate <= "11";
					datatype <= "10";
					next_micro_state <= int2;
				WHEN int2 =>		-- interrupt
					presub <= '1';
					setstackaddr <='1';
					set_mem_addsub <= '1';
					setstate <= "11";
					datatype <= "01";
					writeSR <= '1';
					next_micro_state <= int3;
				WHEN int3 =>		-- interrupt
					set_vectoraddr <= '1';
					datatype <= "10";
					set_directPC <= '1';	
					setstate <= "10";
					next_micro_state <= int4;
				WHEN int4 =>		-- interrupt
					datatype <= "10";

				WHEN rte =>		-- RTE
					datatype <= "10";
					setstate <= "10";
					postadd <= '1';
					setstackaddr <= '1';
					set_mem_rega <= '1';
					set_directPC <= '1';	
					next_micro_state <= nop;

				WHEN trap1 =>		-- TRAP
					presub <= '1';
					setstackaddr <='1';
					set_mem_addsub <= '1';
					setstate <= "11";
					datatype <= "01";
					writeSR <= '1';
					next_micro_state <= trap2;
				WHEN trap2 =>		-- TRAP
					set_vectoraddr <= '1';
					datatype <= "10";
					set_directPC <= '1';	
--					longreaddirect <= '1';
					setstate <= "10";
					next_micro_state <= trap3;
				WHEN trap3 =>		-- TRAP
					datatype <= "10";
					
				WHEN movep1 =>		-- MOVEP d(An)
					setstate <= "01";
					IF opcode(6)='1' THEN
						set_movepl <= '1';
					END IF;
					next_micro_state <= movep2;
				WHEN movep2 =>		
					setdisp <= '1';		
					IF opcode(7)='0' THEN
						setstate <= "10";
					ELSE
						setstate <= "11";
						wait_mem_byte <= '1';
					END IF;
					next_micro_state <= movep3;
				WHEN movep3 =>		
					IF opcode(6)='1' THEN
						set_movepw <= '1';
						next_micro_state <= movep4;
					END IF;
					IF opcode(7)='0' THEN
						setstate <= "10";
					ELSE
						setstate <= "11";
					END IF;
				WHEN movep4 =>		
					IF opcode(7)='0' THEN
						setstate <= "10";
					ELSE
						wait_mem_byte <= '1';
						setstate <= "11";
					END IF;
					next_micro_state <= movep5;
				WHEN movep5 =>		
					IF opcode(7)='0' THEN
						setstate <= "10";
					ELSE
						setstate <= "11";
					END IF;
					
				WHEN init1 =>		-- init SP
					longreaddirect <= '1';
					next_micro_state <= init2;
				WHEN init2 =>		-- init PC
					get_ea_now <='1';	--\
					ea_only <= '1';		---  OP1in <= memaddr_in
					setaddrlong <= '1';	--   memaddr_in <= data_read
					regwrena <= '1';
					setstackaddr <='1';	--   dest_addr <= SP
					set_directPC <= '1';	
					longreaddirect <= '1';
					next_micro_state <= nop;

				WHEN mul1	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul2;
				WHEN mul2	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul3;
				WHEN mul3	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul4;
				WHEN mul4	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul5;
				WHEN mul5	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul6;
				WHEN mul6	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul7;
				WHEN mul7	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul8;
				WHEN mul8	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul9;
				WHEN mul9	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul10;
				WHEN mul10	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul11;
				WHEN mul11	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul12;
				WHEN mul12	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul13;
				WHEN mul13	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul14;
				WHEN mul14	=>		-- mulu
					set_exec_MULU <= '1';
					setstate <="01";
					next_micro_state <= mul15;
				WHEN mul15	=>		-- mulu
					set_exec_MULU <= '1';

				WHEN div1 =>		-- divu
					IF OP2out(15 downto 0)=x"0000" THEN		--div zero
						set_Z_error <= '1';
					ELSE
						set_exec_DIVU <= '1';
						next_micro_state <= div2;
					END IF;
					setstate <="01";
				WHEN div2	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div3;
				WHEN div3	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div4;
				WHEN div4	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div5;
				WHEN div5	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div6;
				WHEN div6	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div7;
				WHEN div7	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div8;
				WHEN div8	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div9;
				WHEN div9	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div10;
				WHEN div10	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div11;
				WHEN div11	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div12;
				WHEN div12	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div13;
				WHEN div13	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div14;
				WHEN div14	=>		-- divu
					set_exec_DIVU <= '1';
					setstate <="01";
					next_micro_state <= div15;
				WHEN div15	=>		-- divu
					set_exec_DIVU <= '1';

				WHEN OTHERS => null;
			END CASE;
	END PROCESS;

-----------------------------------------------------------------------------
-- Conditions
-----------------------------------------------------------------------------
PROCESS (opcode, Flags)
	BEGIN
		CASE opcode(11 downto 8) IS
			WHEN X"0" => condition <= '1';
			WHEN X"1" => condition <= '0';
			WHEN X"2" => condition <=  NOT Flags(0) AND NOT Flags(2);
			WHEN X"3" => condition <= Flags(0) OR Flags(2);
			WHEN X"4" => condition <= NOT Flags(0);
			WHEN X"5" => condition <= Flags(0);
			WHEN X"6" => condition <= NOT Flags(2);
			WHEN X"7" => condition <= Flags(2);
			WHEN X"8" => condition <= NOT Flags(1);
			WHEN X"9" => condition <= Flags(1);
			WHEN X"a" => condition <= NOT Flags(3);
			WHEN X"b" => condition <= Flags(3);
			WHEN X"c" => condition <= (Flags(3) AND Flags(1)) OR (NOT Flags(3) AND NOT Flags(1));
			WHEN X"d" => condition <= (Flags(3) AND NOT Flags(1)) OR (NOT Flags(3) AND Flags(1));
			WHEN X"e" => condition <= (Flags(3) AND Flags(1) AND NOT Flags(2)) OR (NOT Flags(3) AND NOT Flags(1) AND NOT Flags(2));
			WHEN X"f" => condition <= (Flags(3) AND NOT Flags(1)) OR (NOT Flags(3) AND Flags(1)) OR Flags(2);
			WHEN OTHERS => null;
		END CASE;
	END PROCESS;

-----------------------------------------------------------------------------
-- Bits
-----------------------------------------------------------------------------
PROCESS (opcode, OP1out, OP2out, one_bit_in, one_bit_out, bit_Number, bit_number_reg)
	BEGIN
		CASE opcode(7 downto 6) IS
			WHEN "00" =>					--btst
						one_bit_out <= one_bit_in;
			WHEN "01" =>					--bchg
						one_bit_out <= NOT one_bit_in;
			WHEN "10" =>					--bclr
						one_bit_out <= '0';
			WHEN "11" =>					--bset
						one_bit_out <= '1';
			WHEN OTHERS => null;			
		END CASE;
		
		IF opcode(8)='0' THEN
			IF opcode(5 downto 4)="00" THEN
				bit_number <= bit_number_reg(4 downto 0);
			ELSE
				bit_number <= "00"&bit_number_reg(2 downto 0);
			END IF;
		ELSE
			IF opcode(5 downto 4)="00" THEN
				bit_number <= OP2out(4 downto 0);
			ELSE
				bit_number <= "00"&OP2out(2 downto 0);
			END IF;
		END IF;
						
		bits_out <= OP1out;
		CASE bit_Number IS
			WHEN "00000" => one_bit_in <= OP1out(0);
							bits_out(0) <= one_bit_out;
			WHEN "00001" => one_bit_in <= OP1out(1);
							bits_out(1) <= one_bit_out;
			WHEN "00010" => one_bit_in <= OP1out(2);
							bits_out(2) <= one_bit_out;
			WHEN "00011" => one_bit_in <= OP1out(3);
							bits_out(3) <= one_bit_out;
			WHEN "00100" => one_bit_in <= OP1out(4);
							bits_out(4) <= one_bit_out;
			WHEN "00101" => one_bit_in <= OP1out(5);
							bits_out(5) <= one_bit_out;
			WHEN "00110" => one_bit_in <= OP1out(6);
							bits_out(6) <= one_bit_out;
			WHEN "00111" => one_bit_in <= OP1out(7);
							bits_out(7) <= one_bit_out;
			WHEN "01000" => one_bit_in <= OP1out(8);
							bits_out(8) <= one_bit_out;
			WHEN "01001" => one_bit_in <= OP1out(9);
							bits_out(9) <= one_bit_out;
			WHEN "01010" => one_bit_in <= OP1out(10);
							bits_out(10) <= one_bit_out;
			WHEN "01011" => one_bit_in <= OP1out(11);
							bits_out(11) <= one_bit_out;
			WHEN "01100" => one_bit_in <= OP1out(12);
							bits_out(12) <= one_bit_out;
			WHEN "01101" => one_bit_in <= OP1out(13);
							bits_out(13) <= one_bit_out;
			WHEN "01110" => one_bit_in <= OP1out(14);
							bits_out(14) <= one_bit_out;
			WHEN "01111" => one_bit_in <= OP1out(15);
							bits_out(15) <= one_bit_out;
			WHEN "10000" => one_bit_in <= OP1out(16);
							bits_out(16) <= one_bit_out;
			WHEN "10001" => one_bit_in <= OP1out(17);
							bits_out(17) <= one_bit_out;
			WHEN "10010" => one_bit_in <= OP1out(18);
							bits_out(18) <= one_bit_out;
			WHEN "10011" => one_bit_in <= OP1out(19);
							bits_out(19) <= one_bit_out;
			WHEN "10100" => one_bit_in <= OP1out(20);
							bits_out(20) <= one_bit_out;
			WHEN "10101" => one_bit_in <= OP1out(21);
							bits_out(21) <= one_bit_out;
			WHEN "10110" => one_bit_in <= OP1out(22);
							bits_out(22) <= one_bit_out;
			WHEN "10111" => one_bit_in <= OP1out(23);
							bits_out(23) <= one_bit_out;
			WHEN "11000" => one_bit_in <= OP1out(24);
							bits_out(24) <= one_bit_out;
			WHEN "11001" => one_bit_in <= OP1out(25);
							bits_out(25) <= one_bit_out;
			WHEN "11010" => one_bit_in <= OP1out(26);
							bits_out(26) <= one_bit_out;
			WHEN "11011" => one_bit_in <= OP1out(27);
							bits_out(27) <= one_bit_out;
			WHEN "11100" => one_bit_in <= OP1out(28);
							bits_out(28) <= one_bit_out;
			WHEN "11101" => one_bit_in <= OP1out(29);
							bits_out(29) <= one_bit_out;
			WHEN "11110" => one_bit_in <= OP1out(30);
							bits_out(30) <= one_bit_out;
			WHEN "11111" => one_bit_in <= OP1out(31);
							bits_out(31) <= one_bit_out;
			WHEN OTHERS =>	null;			
		END CASE;
	END PROCESS;

-----------------------------------------------------------------------------
-- Rotation
-----------------------------------------------------------------------------
PROCESS (opcode, OP1out, Flags, rot_bits, rot_msb, rot_lsb, rot_rot, rot_nop)
	BEGIN
		CASE opcode(7 downto 6) IS
			WHEN "00" =>					--Byte
						rot_rot <= OP1out(7);
			WHEN "01"|"11" =>				--Word
						rot_rot <= OP1out(15);
			WHEN "10" =>					--Long
						rot_rot <= OP1out(31);
			WHEN OTHERS => null;
		END CASE;
	
		CASE rot_bits IS
			WHEN "00" =>					--ASL, ASR
						rot_lsb <= '0';
						rot_msb <= rot_rot;
			WHEN "01" =>					--LSL, LSR
						rot_lsb <= '0';
						rot_msb <= '0';
			WHEN "10" =>					--ROXL, ROXR
						rot_lsb <= Flags(4);
						rot_msb <= Flags(4);
			WHEN "11" =>					--ROL, ROR
						rot_lsb <= rot_rot;
						rot_msb <= OP1out(0);
			WHEN OTHERS => null;
		END CASE;
	
		IF rot_nop='1' THEN
			rot_out <= OP1out;
			rot_XC <= Flags(0);
		ELSE
			IF opcode(8)='1' THEN		--left
				rot_out <= OP1out(30 downto 0)&rot_lsb;
				rot_XC <= rot_rot;
			ELSE						--right
				rot_XC <= OP1out(0);
				rot_out <= rot_msb&OP1out(31 downto 1);
				CASE opcode(7 downto 6) IS
					WHEN "00" =>					--Byte
						rot_out(7) <= rot_msb;
					WHEN "01"|"11" =>				--Word
						rot_out(15) <= rot_msb;
					WHEN OTHERS =>	
				END CASE;
			END IF;
		END IF;
	END PROCESS;
		
-----------------------------------------------------------------------------
-- MULU/MULS
-----------------------------------------------------------------------------
PROCESS (clk, opcode, OP2out, muls_msb, mulu_reg, OP1sign, sign2)
	BEGIN
		IF rising_edge(clk) THEN
			IF clkena='1' THEN
				IF decodeOPC='1' THEN
					IF opcode(8)='1' AND reg_QB(15)='1' THEN				--MULS Neg faktor
						OP1sign <= '1';
						mulu_reg <= "0000000000000000"&(0-reg_QB(15 downto 0));
					ELSE
						OP1sign <= '0';
						mulu_reg <= "0000000000000000"&reg_QB(15 downto 0);
					END IF;	
				ELSIF exec_MULU='1' THEN
					mulu_reg <= dummy_mulu;	
				END IF;
			END IF;
		END IF;
		
		IF (opcode(8)='1' AND OP2out(15)='1') OR OP1sign='1' THEN
			muls_msb <= mulu_reg(31);
		ELSE
			muls_msb <= '0';
		END IF;	
		
		IF opcode(8)='1' AND OP2out(15)='1' THEN
			sign2 <= '1';
		ELSE
			sign2 <= '0';
		END IF;	
		
		IF mulu_reg(0)='1' THEN
			IF OP1sign='1' THEN
				dummy_mulu <= (muls_msb&mulu_reg(31 downto 16))-(sign2&OP2out(15 downto 0))& mulu_reg(15 downto 1);	
			ELSE
				dummy_mulu <= (muls_msb&mulu_reg(31 downto 16))+(sign2&OP2out(15 downto 0))& mulu_reg(15 downto 1);	
			END IF;
		ELSE
			dummy_mulu <= muls_msb&mulu_reg(31 downto 1);	
		END IF;	
	END PROCESS;
	
-----------------------------------------------------------------------------
-- DIVU
-----------------------------------------------------------------------------
PROCESS (clk, execOPC, opcode, OP1out, OP2out, div_reg, dummy_div_sub, div_quot, div_sign, dummy_div_over, dummy_div)
	BEGIN
		set_V_Flag <= '0';
		
		IF rising_edge(clk) THEN
			IF clkena='1' THEN
				IF decodeOPC='1' THEN
					IF opcode(8)='1' AND reg_QB(31)='1' THEN				-- Neg divisor
						div_sign <= '1';
						div_reg <= 0-reg_QB;
					ELSE
						div_sign <= '0';
						div_reg <= reg_QB;
					END IF;	
				ELSIF exec_DIVU='1' THEN
					div_reg <= div_quot;	
				END IF;
			END IF;
		END IF;
		
		dummy_div_over <= ('0'&OP1out(31 downto 16))-('0'&OP2out(15 downto 0));
		
		IF opcode(8)='1' AND OP2out(15) ='1' THEN
			dummy_div_sub <= (div_reg(31 downto 15))+('1'&OP2out(15 downto 0));
		ELSE
			dummy_div_sub <= (div_reg(31 downto 15))-('0'&OP2out(15 downto 0));
		END IF;	
		
		IF (dummy_div_sub(16))='1' THEN
			div_quot(31 downto 16) <= div_reg(30 downto 15);	
		ELSE
			div_quot(31 downto 16) <= dummy_div_sub(15 downto 0);	
		END IF;	
		
		div_quot(15 downto 0) <= div_reg(14 downto 0)&NOT dummy_div_sub(16);
		
		IF execOPC='1' AND opcode(8)='1' AND (OP2out(15) XOR div_sign)='1' THEN
			dummy_div(15 downto 0) <= 0-div_quot(15 downto 0);
		ELSE
			dummy_div(15 downto 0) <= div_quot(15 downto 0);
		END IF;	
		
		IF div_sign='1' THEN
			dummy_div(31 downto 16) <= 0-div_quot(31 downto 16);
		ELSE
			dummy_div(31 downto 16) <= div_quot(31 downto 16);
		END IF;	
		
		IF (opcode(8)='1' AND (OP2out(15) XOR div_sign XOR dummy_div(15))='1' AND dummy_div(15 downto 0)/=X"0000")	--Overflow DIVS
			OR (opcode(8)='0' AND dummy_div_over(16)='0') THEN	--Overflow DIVU
			set_V_Flag <= '1';
		END IF;
	END PROCESS;
		
-----------------------------------------------------------------------------
-- Movem
-----------------------------------------------------------------------------
PROCESS (reset, clk, movem_mask, movem_muxa ,movem_muxb, movem_muxc)
	BEGIN
		IF movem_mask(7 downto 0)="00000000" THEN
			movem_muxa <= movem_mask(15 downto 8);
			movem_regaddr(3) <= '1';
		ELSE		
			movem_muxa <= movem_mask(7 downto 0);
			movem_regaddr(3) <= '0';
		END  IF;
		IF movem_muxa(3 downto 0)="0000" THEN
			movem_muxb <= movem_muxa(7 downto 4);
			movem_regaddr(2) <= '1';
		ELSE		
			movem_muxb <= movem_muxa(3 downto 0);
			movem_regaddr(2) <= '0';
		END  IF;
		IF movem_muxb(1 downto 0)="00" THEN
			movem_muxc <= movem_muxb(3 downto 2);
			movem_regaddr(1) <= '1';
		ELSE		
			movem_muxc <= movem_muxb(1 downto 0);
			movem_regaddr(1) <= '0';
		END  IF;
		IF movem_muxc(0)='0' THEN
			movem_regaddr(0) <= '1';
		ELSE		
			movem_regaddr(0) <= '0';
		END  IF;

		movem_bits <= ("0000"&movem_mask(0))+("0000"&movem_mask(1))+("0000"&movem_mask(2))+("0000"&movem_mask(3))+
						("0000"&movem_mask(4))+("0000"&movem_mask(5))+("0000"&movem_mask(6))+("0000"&movem_mask(7))+
						("0000"&movem_mask(8))+("0000"&movem_mask(9))+("0000"&movem_mask(10))+("0000"&movem_mask(11))+
						("0000"&movem_mask(12))+("0000"&movem_mask(13))+("0000"&movem_mask(14))+("0000"&movem_mask(15));
						
      	IF reset = '0' THEN
			movem_busy <= '0';
			movem_addr <= '0';
			maskzero <= '0';
	  	ELSIF rising_edge(clk) THEN
	 		IF clkena_in='1' AND get_movem_mask='1' THEN
				movem_mask <= data_read(15 downto 0);
			END IF;	
	 		IF clkena_in='1' AND test_maskzero='1' THEN
				IF movem_mask=X"0000" THEN
					maskzero <= '1';
				END IF;	
			END IF;	
	 		IF clkena_in='1' AND endOPC='1' THEN
				maskzero <= '0';
			END IF;	
	       	IF clkena='1' THEN
				IF set_movem_busy='1' THEN
					IF movem_bits(4 downto 1) /= "0000" OR opcode(10)='0' THEN	
						movem_busy <= '1';
					END IF;
					movem_addr <= '1';
				END IF;	
				IF movem_addr='1' THEN
					CASE movem_regaddr IS
						WHEN "0000" => movem_mask(0)  <= '0';
						WHEN "0001" => movem_mask(1)  <= '0';
						WHEN "0010" => movem_mask(2)  <= '0';
						WHEN "0011" => movem_mask(3)  <= '0';
						WHEN "0100" => movem_mask(4)  <= '0';
						WHEN "0101" => movem_mask(5)  <= '0';
						WHEN "0110" => movem_mask(6)  <= '0';
						WHEN "0111" => movem_mask(7)  <= '0';
						WHEN "1000" => movem_mask(8)  <= '0';
						WHEN "1001" => movem_mask(9)  <= '0';
						WHEN "1010" => movem_mask(10) <= '0';
						WHEN "1011" => movem_mask(11) <= '0';
						WHEN "1100" => movem_mask(12) <= '0';
						WHEN "1101" => movem_mask(13) <= '0';
						WHEN "1110" => movem_mask(14) <= '0';
						WHEN "1111" => movem_mask(15) <= '0';
						WHEN OTHERS => null;
					END CASE;
					IF opcode(10)='1' THEN
						IF movem_bits="00010" OR movem_bits="00001" OR movem_bits="00000" THEN
							movem_busy <= '0';
						END IF;	
					END IF;				
					IF movem_bits="00001" OR movem_bits="00000" THEN
						movem_busy <= '0';
						movem_addr <= '0';
					END IF;				
				END IF;
			END IF;				
		END IF;
	END PROCESS;
END;	
