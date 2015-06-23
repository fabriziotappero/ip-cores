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
-- G.729a Codec interface package
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

package G729A_CODEC_INTF_PKG is

  -- codec status (output from codec)
  constant STS_IDLE : std_logic_vector(3-1 downto 0) := "000";
  constant STS_COD_DIN : std_logic_vector(3-1 downto 0) := "001";
  constant STS_COD_DOUT : std_logic_vector(3-1 downto 0) := "010";
  constant STS_DEC_DIN : std_logic_vector(3-1 downto 0) := "011";
  constant STS_DEC_DOUT : std_logic_vector(3-1 downto 0) := "100";
  constant STS_STT_DIN : std_logic_vector(3-1 downto 0) := "101";
  constant STS_STT_DOUT : std_logic_vector(3-1 downto 0) := "110";
  constant STS_PRUN : std_logic_vector(3-1 downto 0) := "111";

  -- operation selector (input to codec)
  constant RUNF : std_logic_vector(3-1 downto 0) := "000";
  constant INIT : std_logic_vector(3-1 downto 0) := "001";
  constant RSTS : std_logic_vector(3-1 downto 0) := "010";
  constant RUNC : std_logic_vector(3-1 downto 0) := "011";
  constant RUND : std_logic_vector(3-1 downto 0) := "100";
  constant SAVS : std_logic_vector(3-1 downto 0) := "101";
  constant NOP : std_logic_vector(3-1 downto 0) := "111";

end G729A_CODEC_INTF_PKG;

package body G729A_CODEC_INTF_PKG is
end G729A_CODEC_INTF_PKG;