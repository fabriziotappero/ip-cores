---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
----  synchronous single clock fifo, uses LFSR pointers          ----
----                                                             ----
----  Author: Richard Herveille                                  ----
----          richard@asics.ws                                   ----
----          www.asics.ws                                       ----
----                                                             ----
---------------------------------------------------------------------
----                                                             ----
---- Copyright (C) 2001, 2002 Richard Herveille                  ----
----                          richard@asics.ws                   ----
----                                                             ----
---- This source file may be used and distributed without        ----
---- restriction provided that this copyright statement is not   ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer.----
----                                                             ----
----     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ----
---- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ----
---- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ----
---- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ----
---- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ----
---- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ----
---- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ----
---- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ----
---- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ----
---- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ----
---- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ----
---- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ----
---- POSSIBILITY OF SUCH DAMAGE.                                 ----
----                                                             ----
---------------------------------------------------------------------

-- rev.: 1.0 march 12th, 2001. Initial release
--
--  CVS Log
--
--  $Id: atahost_fifo.vhd,v 1.1 2002-02-18 14:32:12 rherveille Exp $
--
--  $Date: 2002-02-18 14:32:12 $
--  $Revision: 1.1 $
--  $Author: rherveille $
--  $Locker:  $
--  $State: Exp $
--
-- Change History:
--               $Log: not supported by cvs2svn $
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity atahost_fifo is
	generic(
		DEPTH : natural := 31;                      -- fifo depth, this must be a number according to the following range
                                                 -- 3, 7, 15, 31, 63 ... 65535
		SIZE : natural := 32                        -- data width
	);
	port(
		clk : in std_logic;                         -- master clock in
		nReset : in std_logic := '1';               -- asynchronous active low reset
		rst : in std_logic := '0';                  -- synchronous active high reset

		rreq : in std_logic;                        -- read request
		wreq : in std_logic;                        -- write request

		empty : out std_logic;                      -- fifo empty
		full : out std_logic;                       -- fifo full

		D : in std_logic_vector(SIZE -1 downto 0);  -- data input
		Q : out std_logic_vector(SIZE -1 downto 0)  -- data output
	);
end entity atahost_fifo;

architecture structural of atahost_fifo is
	--
	-- function declarations
	--
	function bitsize(n : in natural) return natural is
		variable tmp : unsigned(32 downto 1);
		variable cnt : integer;
	begin
		tmp := conv_unsigned(n, 32);
		cnt := 32;

		while ( (tmp(cnt) = '0') and (cnt > 0) ) loop
			cnt := cnt -1;
		end loop;

		return natural(cnt);
	end function bitsize;

	--
	-- component declarations
	--
	component atahost_lfsr is
	generic(
		TAPS : positive range 16 downto 3 :=8;
		OFFSET : natural := 0
	);
	port(
		clk : in std_logic;                 -- clock input
		ena : in std_logic;                 -- count enable
		nReset : in std_logic;              -- asynchronous active low reset
		rst : in std_logic;                 -- synchronous active high reset
		
		Q : out unsigned(TAPS downto 1);    -- count value
		Qprev : out unsigned(TAPS downto 1) -- previous count value
	);
	end component atahost_lfsr;

	constant ADEPTH : natural := bitsize(DEPTH);

	-- memory block
	type memory is array (DEPTH -1 downto 0) of std_logic_vector(SIZE -1 downto 0);
--	shared variable mem : memory; -- VHDL'93 PREFERED
	signal mem : memory; -- VHDL'87

	-- address pointers
	signal wr_ptr, rd_ptr, dwr_ptr, drd_ptr : unsigned(ADEPTH -1 downto 0);

begin
	-- generate write address; hookup write_pointer counter
	wr_ptr_lfsr: atahost_lfsr
		generic map(
			TAPS => ADEPTH,
			OFFSET => 0
		)
		port map(
			clk => clk,
			ena => wreq,
			nReset => nReset,
			rst => rst,
			Q => wr_ptr,
			Qprev => dwr_ptr
		);

	-- generate read address; hookup read_pointer counter
	rd_ptr_lfsr: atahost_lfsr 
		generic map(
			TAPS => ADEPTH,
			OFFSET => 0
		)
		port map(
			clk => clk,
			ena => rreq,
			nReset => nReset,
			rst => rst,
			Q => rd_ptr,
			Qprev => drd_ptr
		);

	-- generate full/empty signal
	full  <= '1' when (wr_ptr = drd_ptr) else '0';
	empty <= '1' when (rd_ptr = wr_ptr) else '0';
	
	-- generate memory structure
	gen_mem: process(clk)
	begin
		if (clk'event and clk = '1') then
			if (wreq = '1') then
				mem(conv_integer(wr_ptr)) <= D;
			end if;
		end if;
	end process gen_mem;
	Q <= mem(conv_integer(rd_ptr));
end architecture structural;
