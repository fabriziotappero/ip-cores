-----------------------------------------------------------------
--                                                             --
-----------------------------------------------------------------
--                                                             --
-- Copyright (C) 2013 Stefano Tonello                          --
--                                                             --
-- This source file may be used and distributed without        --
-- restriction provided that this copyright statement is not   --
-- removed from the file and that any derivative work contains --
-- the original copyright notice and the associated disclaimer.--
--                                                             --
-- THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY         --
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   --
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   --
-- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      --
-- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         --
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    --
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   --
-- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        --
-- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  --
-- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  --
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  --
-- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         --
-- POSSIBILITY OF SUCH DAMAGE.                                 --
--                                                             --
-----------------------------------------------------------------

---------------------------------------------------------------
-- G.729a Codec self-test module test-bench
---------------------------------------------------------------

---------------------------------------------------------------
-- Notes:
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

library work;
--use work.G729A_ASIP_PKG.all;
--use WORK.G729A_ASIP_BASIC_PKG.all;
--use WORK.G729A_ASIP_ARITH_PKG.all;
--use WORK.G729A_ASIP_OP_PKG.all;
--use work.G729A_ASIP_CFG_PKG.all;
--use work.G729A_STRING_PKG.all;
--use work.G729A_CODEC_INTF_PKG.all;
--use work.G729A_CODEC_TEST_PKG.all;
--use work.G729A_SITE_PKG.all;

entity G729A_CODEC_SELFTEST_TB is
end G729A_CODEC_SELFTEST_TB;

architecture ARC of G729A_CODEC_SELFTEST_TB is

  component G729A_CODEC_SELFTEST is
    port(
      CLK_i : in std_logic; -- clock
      RST_i : in std_logic; -- reset

      DONE_o : out std_logic; -- test complete
      PASS_o : out std_logic -- test pass
    );
  end component;

  signal CLK : std_logic := '0';
  signal RST : std_logic := '1';

  signal DONE : std_logic;
  signal PASS : std_logic;

begin

  ---------------------------------------------------
  -- Clock & Reset signals
  ---------------------------------------------------

  CLK <= not(CLK) after 10 ns;

  RST <= '0' after 20 ns;

  ---------------------------------------------------
  -- Self-test module instance
  ---------------------------------------------------

  U_DUT : G729A_CODEC_SELFTEST
    port map(
      CLK_i => CLK,
      RST_i => RST,

      DONE_o => DONE,
      PASS_o => PASS
    );

end ARC;
