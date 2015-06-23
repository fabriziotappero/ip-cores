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

------------------------------------------------------------
-- synchronous write, synchronous-read 1 read/write port RAM
-- with separated input and output data buses 
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.G729A_ASIP_PKG.all;

entity G729_ASIP_RAM_1RW is
  generic(
    -- I/O data bus width
    DWIDTH : integer := 16;
    -- word count
    WCOUNT : integer := 256
  );
  port(
    CLK_i : in std_logic;
    A_i : in unsigned(log2(WCOUNT)-1 downto 0);
    D_i : in std_logic_vector(DWIDTH-1 downto 0);
    WE_i : in std_logic;

    Q_o : out std_logic_vector(DWIDTH-1 downto 0)
  );
end G729_ASIP_RAM_1RW;

architecture ARC of G729_ASIP_RAM_1RW is

  type MEM_TYPE is array (WCOUNT-1 downto 0) of std_logic_vector(DWIDTH-1 downto 0);
  signal RAM_DATA : MEM_TYPE;

begin

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event)then
      if WE_i = '1' then
        RAM_DATA(to_integer(A_i)) <= D_i;
      end if;
      Q_o <= RAM_DATA(to_integer(A_i));
    end if;
  end process;

end ARC;

------------------------------------------------------------
-- synchronous write, synchronous-read 1 read/write port,
-- plus 1 read-only port, RAM, with separated input and
-- output data buses 
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.G729A_ASIP_PKG.all;

entity G729_ASIP_RAM_1RW1R is
  generic(
    -- I/O data bus width
    DWIDTH : integer := 16;
    -- word count
    WCOUNT : integer := 256
  );
  port(
    CLK_i : in std_logic;
    A_i : in unsigned(log2(WCOUNT)-1 downto 0);
    DPRA_i : in unsigned(log2(WCOUNT)-1 downto 0);
    D_i : in std_logic_vector(DWIDTH-1 downto 0);
    WE_i : in std_logic;

    Q_o : out std_logic_vector(DWIDTH-1 downto 0);
    DPQ_o : out std_logic_vector(DWIDTH-1 downto 0)
  );
end G729_ASIP_RAM_1RW1R;

architecture ARC of G729_ASIP_RAM_1RW1R is

  type MEM_TYPE is array (WCOUNT-1 downto 0) of std_logic_vector(DWIDTH-1 downto 0);
  signal RAM_DATA : MEM_TYPE;

begin

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event)then
      if WE_i = '1' then
        RAM_DATA(to_integer(A_i)) <= D_i;
      end if;
      Q_o <= RAM_DATA(to_integer(A_i));
      DPQ_o <= RAM_DATA(to_integer(DPRA_i));
    end if;
  end process;

end ARC;