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
-- 'Fast' adder (carry-select style)
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
use WORK.G729A_ASIP_BASIC_PKG.all;
use WORK.G729A_ASIP_ARITH_PKG.all;

entity G729A_ASIP_ADDER_F is
  generic(
    LEN1 : integer := 16;
    LEN2 : integer := 16
  );
  port(
    OPA_i : in signed(LEN1+LEN2-1 downto 0);
    OPB_i : in signed(LEN1+LEN2-1 downto 0);
    CI_i : in std_logic;

    SUM_o : out signed(LEN1+LEN2-1 downto 0)
  );
end G729A_ASIP_ADDER_F;


architecture ARC of G729A_ASIP_ADDER_F is

begin

  process(OPA_i,OPB_i,CI_i)
    variable A_LO,B_LO : signed(LEN1-1 downto 0);
    variable A_HI,B_HI : signed(LEN2-1 downto 0);
    variable SUM_LO : signed(LEN1+1 downto 0);
    variable SUM_HI0,SUM_HI1 : signed(LEN2 downto 0);
  begin

    A_LO := OPA_i(LEN1-1 downto 0); 
    A_HI := OPA_i(LEN2+LEN1-1 downto LEN1); 

    B_LO := OPB_i(LEN1-1 downto 0); 
    B_HI := OPB_i(LEN2+LEN1-1 downto LEN1); 

    -- low parts sum
    SUM_LO := ('0' & A_LO & '1') + ('0' & B_LO & CI_i);

    -- high parts sum (assuming carry-out is zero)
    SUM_HI0 := (A_HI & '0') + (B_HI & '0');

    -- high parts sum (assuming carry-out is one)
    SUM_HI1 := (A_HI & '1') + (B_HI & '1');

    -- SUM_o low part is low parts sum
    SUM_o(LEN1-1 downto 0) <= SUM_LO(LEN1 downto 1);

    -- select SUM_o high part according to low parts sum carry-out
    if(SUM_LO(LEN1+1) = '1') then
      SUM_o(LEN2+LEN1-1 downto LEN1) <= SUM_HI1(LEN2 downto 1);
    else
      SUM_o(LEN2+LEN1-1 downto LEN1) <= SUM_HI0(LEN2 downto 1);
    end if;

  end process;

end ARC;
