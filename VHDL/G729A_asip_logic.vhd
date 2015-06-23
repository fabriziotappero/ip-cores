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
-- G.729A ASIP logic (boolean) unit
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
use WORK.G729A_ASIP_BASIC_PKG.all;
use WORK.G729A_ASIP_ARITH_PKG.all;

--use WORK.G729A_TYPES_PKG.all;
--use WORK.G729A_BASIC_PKG.all;
--use WORK.G729A_ARITH_PKG.all;
--use WORK.G729A_CODER_PKG.all;

entity G729A_ASIP_LOGIC is
  port(
    --STRT_i : in std_logic;
    CTRL_i : in LOG_CTRL;
    OPA_i : in LDWORD_T;
    OPB_i : in LDWORD_T;

    RES_o : out LDWORD_T
  );
end G729A_ASIP_LOGIC;

architecture ARC of G729A_ASIP_LOGIC is

begin

  process(CTRL_i,OPA_i,OPB_i)
    variable OPA_LO,OPB_LO : signed(SDLEN-1 downto 0);
  begin
    OPA_LO := OPA_i(SDLEN-1 downto 0);
    OPB_LO := OPB_i(SDLEN-1 downto 0);
    case CTRL_i is
      when LC_AND =>
        RES_o(SDLEN-1 downto 0) <= (OPA_LO and OPB_LO); 
      when others => --LC_OR
        RES_o(SDLEN-1 downto 0) <= (OPA_LO or OPB_LO); 
    end case;
  end process;

  RES_o(LDLEN-1 downto SDLEN) <= (others => '0');

end ARC;
