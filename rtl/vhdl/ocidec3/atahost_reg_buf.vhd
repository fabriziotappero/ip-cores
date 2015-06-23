---------------------------------------------------------------------
----                                                             ----
----  OpenCores IDE Controller                                   ----
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

--  CVS Log
--
--  $Id: atahost_reg_buf.vhd,v 1.1 2002-02-18 14:32:12 rherveille Exp $
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

entity atahost_reg_buf is
	generic (
		WIDTH : natural := 8
	);
	port(
		clk    : in std_logic;
		nReset : in std_logic;
		rst    : in std_logic;

		D      : in std_logic_vector(WIDTH -1 downto 0);
		Q      : out std_logic_vector(WIDTH -1 downto 0);
		rd     : in std_logic;
		wr     : in std_logic;
		valid  : buffer std_logic
	);
end entity atahost_reg_buf;

architecture structural of atahost_reg_buf is
begin
	process(clk, nReset)
	begin
		if (nReset = '0') then
			Q <= (others => '0');
			valid <= '0';
		elsif (clk'event and clk = '1') then
			if (rst = '1') then
				Q <= (others => '0');
				valid <= '0';
			else
				if (wr = '1') then
					Q <= D;
				end if;
				valid <= wr or (valid and not rd);
			end if;
		end if;
	end process;
end architecture structural;
