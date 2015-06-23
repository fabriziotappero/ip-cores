-------------------------------------------------------------------------
-- Components for H264 - VHDL
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package h264 is
	--
	component h264intra4x4 is
	port (
		CLK : in std_logic;					--pixel clock
		--
		-- in interface:
		NEWSLICE : in std_logic;			--indication this is the first in a slice
		NEWLINE : in std_logic;				--indication this is the first on a line
		STROBEI : in std_logic;				--data here
		DATAI : in std_logic_vector(31 downto 0);
		READYI : out std_logic := '0';
		--
		-- top interface:
		TOPI : in std_logic_vector(31 downto 0);	--top pixels (to predict against)
		TOPMI : in std_logic_vector(3 downto 0);	--top block's mode (for P/RMODEO)
		XXO : out std_logic_vector(1 downto 0) := b"00";		--which macroblock X
		XXINC : out std_logic := '0';				--when to increment XX macroblock
		--
		-- feedback interface:
		FEEDBI : in std_logic_vector(7 downto 0);	--feedback for pixcol
		FBSTROBE : in std_logic;					--feedback valid
		--
		-- out interface:
		STROBEO : out std_logic := '0';				--data here
		DATAO : out std_logic_vector(35 downto 0) := (others => '0');
		BASEO : out std_logic_vector(31 downto 0) := (others => '0');	--base for reconstruct
		READYO : in std_logic := '1';
		MSTROBEO : out std_logic := '0';			--modeo here
		MODEO : out std_logic_vector(3 downto 0) := (others => '0');	--0..8 prediction type
		PMODEO : out std_logic := '0';				--prev_i4x4_pred_mode_flag
		RMODEO : out std_logic_vector(2 downto 0) := (others => '0');	--rem_i4x4_pred_mode_flag
		--
		CHREADY :  out std_logic := '0'				--ready line to chroma
	);
	end component;
	--
	component h264intra8x8cc is
	port (
		CLK2 : in std_logic;				--2x clock
		--
		-- in interface:
		NEWSLICE : in std_logic;			--indication this is the first in a slice
		NEWLINE : in std_logic;				--indication this is the first on a line
		STROBEI : in std_logic;				--data here
		DATAI : in std_logic_vector(31 downto 0);
		READYI : out std_logic := '0';
		--
		-- top interface:
		TOPI : in std_logic_vector(31 downto 0);	--top pixels (to predict against)
		XXO : out std_logic_vector(1 downto 0) := b"00";		--which macroblock X
		XXC : out std_logic := '0';				--carry from XXO, to add to macroblock
		XXINC : out std_logic := '0';			--when to increment XX macroblock
		--
		-- feedback interface:
		FEEDBI : in std_logic_vector(7 downto 0);	--feedback for pixcol
		FBSTROBE : in std_logic;					--feedback valid
		--
		-- out interface:
		STROBEO : out std_logic := '0';				--data here
		DATAO : out std_logic_vector(35 downto 0) := (others => '0');
		BASEO : out std_logic_vector(31 downto 0) := (others => '0');	--base for reconstruct
		READYO : in std_logic := '1';
		DCSTROBEO : out std_logic := '0';			--dc data here
		DCDATAO : out std_logic_vector(15 downto 0) := (others => '0');
		CMODEO : out std_logic_vector(1 downto 0) := (others => '0')	--prediction type
	);
	end component h264intra8x8cc;
	--
	component h264interz is
	generic (
		MVB : integer := 2	--bits to encode MV
	);
	port (
		CLK : in std_logic;					--pixel clock
		--
		-- in interface:
		NEWSLICE : in std_logic;			--indication this is the first in a slice
		NEWLINE : in std_logic;				--indication this is the first on a line
		STROBEI : in std_logic;				--data here
		PREVI : in std_logic;				--1=previous frame, 0=new data to encode
		DATAI : in std_logic_vector(31 downto 0);
		READYI : out std_logic := '0';
		--
		-- top interface:
		TVECXI : in std_logic_vector(MVB-1 downto 0) := (others=>'0');	--top block's X vector
		TVECYI : in std_logic_vector(MVB-1 downto 0) := (others=>'0');	--top block's Y vector
		SVECXI : in std_logic_vector(MVB-1 downto 0) := (others=>'0');	--suggested X vector
		SVECYI : in std_logic_vector(MVB-1 downto 0) := (others=>'0');	--suggested Y vector
		XXINC : out std_logic := '0';				--when to increment XX macroblock
		--
		-- out interface:
		STROBEO : out std_logic := '0';				--data here
		DATAO : out std_logic_vector(35 downto 0) := (others => '0');
		READYO : in std_logic;
		VECXO : out std_logic_vector(MVB-1 downto 0) := (others => '0');--vector X, signed
		VECYO : out std_logic_vector(MVB-1 downto 0) := (others => '0')	--vector Y, signed
	);
	end component;
	--
	component h264coretransform is
	port (
		CLK : in std_logic;					--fast io clock
		READY : out std_logic := '0';		--set when ready for ENABLE
		ENABLE : in std_logic;				--values input only when this is 1
		XXIN : in std_logic_vector(35 downto 0);	--4 x 9bit, first px is lsbs
		VALID : out std_logic := '0';				--values output only when this is 1
		YNOUT : out std_logic_vector(13 downto 0)	--output (zigzag order)
	);
	end component;
	--
	component h264invtransform is
	port (
		CLK : in std_logic;					--fast io clock
		ENABLE : in std_logic;				--values input only when this is 1
		WIN : in std_logic_vector(15 downto 0);	--input (reverse zigzag order)
		VALID : out std_logic := '0';				--values output only when this is 1
		XOUT : out std_logic_vector(39 downto 0)	--4 x 10bit, first px is lsbs
	);
	end component;
	--
	component h264dctransform is
	generic (	
		TOGETHER : integer := 0				--1 if output kept together as one block
	);
	port (
		CLK2 : in std_logic;				--fast io clock
		RESET : in std_logic;				--reset when 1
		READYI : out std_logic := '0';		--set when ready for ENABLE
		ENABLE : in std_logic;				--values input only when this is 1
		XXIN : in std_logic_vector(15 downto 0);	--input
		VALID : out std_logic := '0';				--values output only when this is 1
		YYOUT : out std_logic_vector(15 downto 0);	--output
		READYO : in std_logic := '0'		--set when ready for ENABLE
	);
	end component;
	--
	component h264quantise is
	port (
		CLK : in std_logic;					--pixel clock
		ENABLE : in std_logic;				--values transfered only when this is 1
		QP : in std_logic_vector(5 downto 0);	--0..51 as specified in standard
		DCCI : in std_logic;					--2x2 DC chroma in
		YNIN : in std_logic_vector(15 downto 0);
		ZOUT : out std_logic_vector(11 downto 0) := (others=>'0');
		DCCO : out std_logic;					--2x2 DC chroma out
		VALID : out std_logic := '0'			-- enable delayed to same as YOUT timing
	);
	end component;
	--
	component h264dequantise is
	generic (
		LASTADVANCE : integer := 1
	);
	port (
		CLK : in std_logic;					--pixel clock
		ENABLE : in std_logic;				--values transfered only when this is 1
		QP : in std_logic_vector(5 downto 0);	--0..51 as specified in standard
		ZIN : in std_logic_vector(15 downto 0);
		DCCI : in std_logic;					--2x2 DC chroma in
		LAST : out std_logic := '0';			--set when last coeff about to be input
		WOUT : out std_logic_vector(15 downto 0) := (others=>'0');
		DCCO : out std_logic := '0';			--2x2 DC chroma out
		VALID : out std_logic := '0'			-- enable delayed to same as YOUT timing
	);
	end component;
	--
	component h264recon is
	port (
		CLK2 : in std_logic;				--x2 clock
		--
		-- in interface:
		NEWSLICE : in std_logic;			--reset
		STROBEI : in std_logic;				--data here
		DATAI : in std_logic_vector(39 downto 0);
		BSTROBEI : in std_logic;				--base data here
		BCHROMAI : in std_logic;				--chroma
		BASEI : in std_logic_vector(31 downto 0);
		--
		-- out interface:
		STROBEO : out std_logic := '0';				--data here (luma)
		CSTROBEO : out std_logic := '0';			--data here (chroma)
		DATAO : out std_logic_vector(31 downto 0) := (others => '0')
	);
	end component;
	--
	component h264buffer is
	port (
		CLK : in std_logic;					--clock
		NEWSLICE : in std_logic;			--reset: this is the first in a slice
		NEWLINE : in std_logic;				--this is the first in a line
		--
		VALIDI : in std_logic;				--luma/chroma data here (15/16/4 of these)
		ZIN : in std_logic_vector(11 downto 0);	--luma/chroma data
		READYI : out std_logic := '0';		--set when ready for next luma/chroma
		CCIN : out std_logic := '0';		--set when inputting chroma
		DONE : out std_logic := '0';		--set when all done and quiescent
		--
		VOUT : out std_logic_vector(11 downto 0) := (others=>'0');	--luma/chroma data
		VALIDO : out std_logic := '0';		--strobe for data out
		--
		NLOAD : out std_logic := '0';		--load for CAVLC NOUT
		NX : out std_logic_vector(2 downto 0);	--X value for NIN/NOUT
		NY : out std_logic_vector(2 downto 0);	--Y value for NIN/NOUT
		NV : out std_logic_vector(1 downto 0);	--valid flags for NIN/NOUT (1=left, 2=top, 3=avg)
		NXINC : out std_logic := '0';		--increment for X macroblock counter
		--
		READYO : in std_logic;				--from cavlc module
		TREADYO : in std_logic;				--from tobytes module: tells it to freeze
		HVALID : in std_logic				--when header module outputting
	);
	end component;
	--
	component h264cavlc is
	port (
		CLK : in std_logic;					--main clock / output clock
		CLK2 : in std_logic;				--input clock (typically twice CLK)
		ENABLE : in std_logic;				--values transfered only when this is 1
		READY : out std_logic;				--enable can fall when this 1
		VIN : in std_logic_vector(11 downto 0);	--12bits max (+/- 2048)
		NIN : in std_logic_vector(4 downto 0);	--N coeffs nearby mb
		SIN : in std_logic := '0';				--stream/strobe flag, copied to VS
		VS : out std_logic := '0';				--stream/strobe flag sync'd with VL/VE
		VE : out std_logic_vector(24 downto 0) := (others=>'0');
		VL : out std_logic_vector(4 downto 0) := (others=>'0');
		VALID : out std_logic := '0';			-- enable delayed to same as VE/VL
		XSTATE : out std_logic_vector(2 downto 0); 	--debug only
		NOUT : out std_logic_vector(4 downto 0) := b"00000"	--N coeffs for this mb
	);
	end component;
	--
	component h264header is
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
		PTYPE : in std_logic_vector(1 downto 0);	--0=P16x16, etc
		PSUBTYPE : in std_logic_vector(1 downto 0);	--only if PTYPE=b"11"
		MVDX : in std_logic_vector(11 downto 0);	--signed MVD X
		MVDY : in std_logic_vector(11 downto 0);	--signed MVD Y
		--out:
		VE : out std_logic_vector(19 downto 0) := (others=>'0');
		VL : out std_logic_vector(4 downto 0) := (others=>'0');
		VALID : out std_logic := '0'	-- VE/VL valid
	);
	end component;
	--
	component h264tobytes is
	port (
		CLK : in std_logic;					--pixel clock
		VALID : in std_logic;				--data ready to be read
		READY : out std_logic := '1';		--soft ready signal (can accept 16 more words when clear)
		VE : in std_logic_vector(24 downto 0) := (others=>'0');
		VL : in std_logic_vector(4 downto 0) := (others=>'0');
		BYTE : out std_logic_vector(7 downto 0) := (others=>'0');
		STROBE : out std_logic := '0';			--set when BYTE valid
		DONE : out std_logic := '0'				--set after aligned with DONE flag (end of NAL)
	);
	end component;
	--
end h264;
