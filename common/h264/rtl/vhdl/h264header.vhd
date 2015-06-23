-------------------------------------------------------------------------
-- H264 convert bits to bytes - VHDL
-- 
-- Written by Andy Henson
-- Copyright (c) 2008 Zexia Access Ltd
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of the Zexia Access Ltd nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY ZEXIA ACCESS LTD ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL ZEXIA ACCESS LTD OR ANDY HENSON BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------

-- Input: various flags
-- Output: VALID/VE/VL
-- Output is a "wide bits" VE/VL stream

-- Only generates headers as per rest of modules, rather a limited subset
-- Doesn't generate PPset or SPset NALs
-- Suggested:
-- SPS: 00 00 00 01 ; 67 42 00 28 da 05 82 59 	-- contains size of image 352x288
-- PPS: 00 00 00 01 ; 68 ce 38 80				-- default zero params
-- Doesn't frame the NALs in any way
-- Assumes all I-frames are IDRs

-- Fields in NAL header: a byte of x21 or x25
-- forbidden_zero_bit - f(1) - always 0
-- nal_ref_idc - u(2) - always 1
-- nal_unit_type - u(5) - 5 for IDR, 1 for non-idr frame

-- Fields in slice_header (unused parts removed):
-- first_mb_in_slice - ue(v) - typically 0 - /1/
-- slice_type - ue(v) - 0 for P, 2 for I - /1/ or /011/
-- pic_parameter_set_id - ue(v) - typically 0 - /1/
-- frame_num - u(4) - /0000/ for I, otherwise /nnnn/
-- if( nal_unit_type == 5 )
--    idr_pic_id - ue(v) - usually 0, sometimes 1 if two IDRs back to back - /1/ or /010/
-- if( slice_type = = P | | slice_type = = SP | | slice_type = = B ) {
--    num_ref_idx_active_override_flag - u(1) - assume 0 - /0/
-- if( slice_type != I && slice_type != SI )	#ref_pic_list_reordering
--    ref_pic_list_reordering_flag_l0 - u(1) - always 0 - /0/
-- if( nal_unit_type == 5 ) {     #dec_ref_pic_marking
--     no_output_of_prior_pics_flag - u(1) - always 0 - /00/
--     long_term_reference_flag - u(1) - always 0
-- } else
--     adaptive_ref_pic_marking_mode_flag - u(1) - always 0 - /0/
-- slice_qp_delta - se(v) - per slice qp adjust - /1/

-- Summary: IDR I-frame headers are:
--   1011100001001 (13 bits) or
--   101110000010001 (15 bits)
-- Summary: P-frame headers are:
--   11111nnnn01 (11 bits)

-- Then series of maccroblocks (this description includes mb_skip_run
-- which is described in slice_data in the standard):
-- if( slice_type != I && slice_type != SI )
--    mb_skip_run - ue(v) - always 0 unless skipping - /1/
-- mb_type - ue(v) - see below - /1/ for I
-- mb_pred or sum_mb_pred (see below)
-- coded_block_pattern - me(v) - /1/ for I
-- mb_qp_delta - se(v) - usually 0 - /1/
-- residuals

-- mb_type for I slices: 0=I_4x4 - /1/
-- mb_type for P slices:
--   0=P_16x16 - /1/
--   1=P_16x8
--   2=P_8x16
--   3=P_8x8 (uses mb_sub_pred, not mb_pred)
--   5=I_4x4 - /00110/

-- mb_pred for I slices:
-- for( luma4x4BlkIdx=0; luma4x4BlkIdx<16; luma4x4BlkIdx++ ) {
--   prev_intra4x4_pred_mode_flag[ luma4x4BlkIdx ] - u(1)
--   if( !prev_intra4x4_pred_mode_flag[ luma4x4BlkIdx ] )
--      rem_intra4x4_pred_mode[ luma4x4BlkIdx ] - u(3)
-- }
-- intra_chroma_pred_mode - ue(v)

-- mb_pred for P slices:
-- for( mbPartIdx = 0; mbPartIdx < NumMbPart( mb_type ); mbPartIdx++) {
--    mvdx [ mbPartIdx ] - se(v)
--    mvdy [ mbPartIdx ] - se(v)
-- }

-- codedblockpattern:
-- for I-frames, code 47 (all) as 0
-- for P-frames, code 47 (all) as 12 (ie, b"0001101").

-- TO BE DONE: QP, MV, PTYPE/SUBTYPE.

-- XST: 159Mhz; 115 slices; XPower: 2mW

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity h264header is
	port (
		CLK : in std_logic;					--clock
		--slice:
		NEWSLICE : in std_logic;			--reset: this is the first in a slice
		LASTSLICE : in std_logic := '1';	--this is last slice in frame
		SINTRA : in std_logic;				--slice I flag
		--macroblock:
		MINTRA : in std_logic;				--macroblock I flag
		LSTROBE : in std_logic;				--luma data here (16 of these)
		CSTROBE : in std_logic;				--chroma data (first latches CMODE)
		QP : in std_logic_vector(5 downto 0);	--0..51 as specified in standard	
		--for intra:
		PMODE : in std_logic;				--luma prev_intra4x4_pred_mode_flag
		RMODE : in std_logic_vector(2 downto 0);	--luma rem_intra4x4_pred_mode_flag
		CMODE : in std_logic_vector(1 downto 0);	--intra_chroma_pred_mode
		--for inter:
		PTYPE : in std_logic_vector(1 downto 0);	--0=P16x16,1=P16x8,2=P8x16,3=subtypes
		PSUBTYPE : in std_logic_vector(1 downto 0) := b"00";	--only if PTYPE=b"11"
		MVDX : in std_logic_vector(11 downto 0);	--signed MVD X (qtr pixel)
		MVDY : in std_logic_vector(11 downto 0);	--signed MVD Y (qtr pixel)
		--out:
		VE : out std_logic_vector(19 downto 0) := (others=>'0');
		VL : out std_logic_vector(4 downto 0) := (others=>'0');
		VALID : out std_logic := '0'	-- VE/VL valid
	);
end h264header;
	
architecture hw of h264header is
	--
	signal slicehead1 : std_logic := '0';	-- if we need to emit slice header, part1
	signal slicehead2 : std_logic := '0';	-- if we need to emit slice header, part2
	signal mbhead : std_logic := '0';		-- if we need to emit mb header
	signal idrtwice : std_logic := '0';		-- if 2 IDRs with no P's in middle
	signal lbuf : std_logic_vector(15 downto 0) := (others=>'0');	--accumulator for PMODE/RMODE
	signal lbufc : std_logic_vector(4 downto 0) := (others=>'0');	--count for PMODE/RMODE
	signal cmodei : std_logic_vector(1 downto 0) := (others=>'0');
	signal lcount : std_logic_vector(3 downto 0) := (others=>'0');
	signal ccount : std_logic := '0';
	signal fcount : std_logic_vector(3 downto 0) := (others=>'0');
	signal lstrobed : std_logic := '0';
	signal emit : std_logic_vector(3 downto 0) := x"0";
	signal ix : std_logic_vector(3 downto 0) := x"1";
	signal tailf : std_logic := '0';			-- set if to emit tail
	signal pushf : std_logic := '0';			-- set to push to abuf
	signal sev : std_logic_vector(15 downto 0);
	signal sevf : std_logic := '0';			-- set if to emit sev
	signal uevp1 : std_logic_vector(15 downto 0);	--uev+1
	signal uevf : std_logic := '0';			-- set if to emit uevp1
	--
	type Tabuf is array(15 downto 0) of std_logic_vector(15 downto 0);
	type Tabufc is array(15 downto 0) of std_logic_vector(4 downto 0);
	signal abuf : Tabuf;
	signal abufc : Tabufc;
	--
	constant ZERO :	std_logic_vector(4 downto 0) := (others=>'0');
	--
begin
	--
process(CLK)
	
begin
	if rising_edge(CLK) then
		if NEWSLICE='1' or (emit=ix-1 and emit/=0) then
			slicehead1 <= NEWSLICE;
			slicehead2 <= NEWSLICE;
			mbhead <= '1';
			mbhead <= '1';
			lcount <= (others=>'0');
			ccount <= '0';
			lbufc <= (others=>'0');
			ix <= x"1";
			emit <= x"0";
		elsif emit/=0 then
			emit <= emit+1;
		elsif slicehead1='1' then
			--NAL header byte: IDR or normal:
			if SINTRA='1' then
				lbuf <= x"5525";		--0x25 (8bits)
			else
				lbuf <= x"5521";		--0x21 (8bits)
			end if;
			lbufc <= ZERO+8;
			pushf <= '1';
			slicehead1 <= '0';
		elsif slicehead2='1' and pushf='0' then
			-- Summary: IDR I-frame headers are:
			--   1010100001001 (13 bits) or
			--   101010000010001 (15 bits)
			-- Summary: P-frame headers are:
			--   11111nnnn01 (11 bits)
			if SINTRA='1' and idrtwice='0' then
				--here if I / IDR and previous wasn't IDR
				lbuf <= b"0010101110000100";	--101110000100 (12 bits)
				lbufc <= ZERO+12;
				idrtwice <= '1';
				fcount <= b"000"&LASTSLICE;		--next frame is 1
			elsif SINTRA='1' then
				--here if I / IDR and previous was IDR (different tag)
				lbuf <= b"0010111000001000";	--10111000001000 (14 bits)
				lbufc <= ZERO+14;
				idrtwice <= '0';
				fcount <= b"000"&LASTSLICE;		--next frame is 1
			else
				--here if P
				lbuf <= b"00101011111" & fcount & b"0";	--11111nnnn0 (10 bits)
				lbufc <= ZERO+10;
				idrtwice <= '0';
				assert PTYPE=0;	--only this supported at present
				if LASTSLICE='1' then
					fcount <= fcount+1;		--next frame
				end if;
			end if;
			sev <= sxt(qp-26,16);
			sevf <= '1';
			slicehead2 <= '0';
			pushf <= '1';
		end if;
		if CSTROBE='1' and ccount='0' and NEWSLICE='0' then	--chroma
			ccount <= '1';
			cmodei <= CMODE;
		end if;
		if LSTROBE='0' then
			lstrobed <= LSTROBE;
		end if;
		if LSTROBE='1' and lstrobed='0' and NEWSLICE='0' then	--luma
			if mbhead='1' and pushf='0' then
				--head: mb_skip_run (if SINTRA) and mb_type
				if SINTRA='1' and MINTRA='1' then	--macroblock header
					--mbtype=I4x4 /1/
					lbuf(5 downto 0) <= b"000111";
					lbufc <= ZERO+1;
				elsif SINTRA='0' and MINTRA='1' then
					--mbskiprun=0, mbtype=I4x4 in Pslice /100110/
					lbuf(5 downto 0) <= b"100110";
					lbufc <= ZERO+7;
				else
					--mbskiprun=0, mbtype=P16x16 /11/
					lbuf(5 downto 0) <= b"000111";
					lbufc <= ZERO+2;
				end if;
				mbhead <= '0';
			elsif pushf='0' then
				--normal processing
				lcount <= lcount+1;
				lstrobed <= LSTROBE;
				if MINTRA='1' then
					if PMODE='1' then
						lbuf <= lbuf(14 downto 0) & PMODE;
						lbufc <= lbufc+1;
					else
						lbuf <= lbuf(11 downto 0) & PMODE & RMODE;
						lbufc <= lbufc+4;
					end if;
				else -- P macroblocks
					if lcount=1 or lcount=2 then	--mvx=0 and mvy=0
						assert MVDX=0 and MVDY=0;
						lbuf <= lbuf(14 downto 0) & '1';
						lbufc <= lbufc+1;
					end if;
				end if;
				if lcount=15 then
					tailf <= '1';
					pushf <= '1';
				end if;
			end if;
		end if;
		--
		if sevf='1' then
			--convert 16bit sev to 16bit uev, then add 1
			--these equations have been optimised rather a lot
			if sev(15)='0' and sev/=0 then
				uevp1 <= (sev(14 downto 0))&'0';
			else
				uevp1 <= (ext(b"0",15)-sev(14 downto 0))&'1';
			end if;
			uevf <= sevf;
			sevf <= '0';
		end if;
		if uevf='1' then
			lbuf <= uevp1;
			if uevp1(15 downto 1)=0 then
				lbufc <= ZERO+1;
			elsif uevp1(15 downto 2)=0 then
				lbufc <= ZERO+3;
			elsif uevp1(15 downto 3)=0 then
				lbufc <= ZERO+5;
			elsif uevp1(15 downto 4)=0 then
				lbufc <= ZERO+7;
			elsif uevp1(15 downto 5)=0 then
				lbufc <= ZERO+9;
			elsif uevp1(15 downto 6)=0 then
				lbufc <= ZERO+11;
			elsif uevp1(15 downto 7)=0 then
				lbufc <= ZERO+13;
			elsif uevp1(15 downto 8)=0 then
				lbufc <= ZERO+15;
			elsif uevp1(15 downto 9)=0 then
				lbufc <= ZERO+17;
			elsif uevp1(15 downto 10)=0 then
				lbufc <= ZERO+19;
			elsif uevp1(15 downto 11)=0 then
				lbufc <= ZERO+21;
			elsif uevp1(15 downto 12)=0 then
				lbufc <= ZERO+23;
			elsif uevp1(15 downto 13)=0 then
				lbufc <= ZERO+25;
			elsif uevp1(15 downto 14)=0 then
				lbufc <= ZERO+27;
			elsif uevp1(15)='0' then
				lbufc <= ZERO+29;
			else
				lbufc <= ZERO+31;
			end if;
			uevf <= sevf;
			pushf <= '1';
		end if;
		--
		if pushf='1' and NEWSLICE='0' then
			--emit to buffer
			if lbufc/=0 then
				abuf(conv_integer(ix)) <= lbuf;
				abufc(conv_integer(ix)) <= lbufc;
				lbufc <= ZERO;
				ix <= ix+1;
			end if;
			pushf <= '0';
		elsif lbufc>12 then
			pushf <= '1';
		end if;
		if tailf='1' and pushf='0' and NEWSLICE='0' and emit/=ix then
			--tail: chromatype if I
			--tail: codedblockpattern /1/ or /0001101/; and slice_qp_delta /1/
			if MINTRA='1' then
				if cmodei=0 then
					lbuf <= b"0000000000001111";	--111
					lbufc <= ZERO+3;
				else
					lbuf <= b"000000000010" & (cmodei+1) & b"11";	--0tt11
					lbufc <= ZERO+5;
				end if;
			else	--P
				lbuf <= b"0000000000011011";	--00011011
				lbufc <= ZERO+8;
			end if;
			pushf <= '1';
			tailf <= '0';
			emit <= emit+1;
		end if;
		--
		if emit /= 0 then
			VALID <= '1';
			VE <= x"0" & abuf(conv_integer(emit));
			VL <= abufc(conv_integer(emit));
		else
			VALID <= '0';
		end if;
	end if;
end process;
	--
end hw;

