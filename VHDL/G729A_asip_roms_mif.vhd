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
-- G729A ASIP ROM memories with MIF init. file
---------------------------------------------------------------

---------------------------------------------------------------
-- Single-port ROM
---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity G729A_ASIP_ROM_MIF is
  generic(
    WCOUNT : natural := 256;
    DATA_WIDTH : natural := 8;
    ADDR_WIDTH : natural := 8;
    ROM_INIT_FILE : string := "NONE"
  );
  port(
    CLK_i : in std_logic;
    A_i : in unsigned(ADDR_WIDTH-1 downto 0);
    Q_o : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end G729A_ASIP_ROM_MIF;

architecture ARC of G729A_ASIP_ROM_MIF is

  subtype WORD is std_logic_vector(DATA_WIDTH-1 downto 0);
  type MEM_TYPE is array (0 to WCOUNT-1) of WORD;

  signal ROM_MEM : MEM_TYPE;
  attribute ram_init_file : string;
  attribute ram_init_file of ROM_MEM : signal is ROM_INIT_FILE;

begin

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      Q_o <= ROM_MEM(to_integer(A_i));
    end if;
  end process;

end ARC;

---------------------------------------------------------------
-- Dual-port ROM
---------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity G729A_ASIP_ROM_MIF_2R is
  generic(
    WCOUNT : natural := 256;
    DATA_WIDTH : natural := 8;
    ADDR_WIDTH : natural := 8;
    ROM_INIT_FILE : string := "NONE"
  );
  port(
    CLK_i : in std_logic;
    A0_i : in unsigned(ADDR_WIDTH-1 downto 0);
    A1_i : in unsigned(ADDR_WIDTH-1 downto 0);

    Q0_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
    Q1_o : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end G729A_ASIP_ROM_MIF_2R;

architecture ARC of G729A_ASIP_ROM_MIF_2R is

  subtype WORD is std_logic_vector(DATA_WIDTH-1 downto 0);
  type MEM_TYPE is array (0 to WCOUNT-1) of WORD;

  signal ROM_MEM : MEM_TYPE;
  attribute ram_init_file : string;
  attribute ram_init_file of ROM_MEM : signal is ROM_INIT_FILE;

begin

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      Q0_o <= ROM_MEM(to_integer(A0_i));
      Q1_o <= ROM_MEM(to_integer(A1_i));
    end if;
  end process;

end ARC;

