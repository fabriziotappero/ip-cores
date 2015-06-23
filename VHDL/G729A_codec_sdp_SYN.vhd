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
-- G.729a codec synthesis test-bench
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use STD.textio.all;

library work;
use work.G729A_ASIP_PKG.all;
--use WORK.G729A_ASIP_BASIC_PKG.all;
--use WORK.G729A_ASIP_ARITH_PKG.all;
--use WORK.G729A_ASIP_OP_PKG.all;

entity G729A_CODEC_SDP_SYN is
  port(
    CLK_i : in std_logic; -- clock
    RST_i : in std_logic; -- reset
    STRT_i : in std_logic; -- start
    OPS_i : in std_logic_vector(3-1 downto 0);
    RE_i : in std_logic; -- state read-enable
    WE_i : in std_logic; -- state write-enable
    DI_i : in std_logic_vector(SDLEN-1 downto 0); -- data-in

    BSY_o : out std_logic; -- busy
    DMAE_o : out std_logic; -- DMA enable
    STS_o : out std_logic_vector(3-1 downto 0); -- status
    DV_o : out std_logic; -- data-out valid
    DO_o : out std_logic_vector(SDLEN-1 downto 0) -- data-out
  );
end G729A_CODEC_SDP_SYN;

architecture ARC of G729A_CODEC_SDP_SYN is

  constant USE_ROM_MIF : std_logic := '0';

  component G729A_CODEC_SDP is
    generic(
      -- synthesis translate_off
      ST_FILE : string; 
      WB_FILE : string;
      -- synthesis translate_on
      REGISTER_INPUTS : std_logic := '0';
      REGISTER_OUTPUTS : std_logic := '0';
      USE_ROM_MIF : std_logic := '0';
      SIMULATION_ONLY : std_logic := '1'
    );
    port(
      CLK_i : in std_logic; -- clock
      RST_i : in std_logic; -- reset
      STRT_i : in std_logic; -- start
      OPS_i : in std_logic_vector(3-1 downto 0);
      RE_i : in std_logic; -- state read-enable
      WE_i : in std_logic; -- state write-enable
      DI_i : in std_logic_vector(SDLEN-1 downto 0); -- data-in

      BSY_o : out std_logic; -- busy
      DMAE_o : out std_logic; -- DMA enable
      STS_o : out std_logic_vector(3-1 downto 0); -- status
      DV_o : out std_logic; -- data-out valid
      DO_o : out std_logic_vector(SDLEN-1 downto 0) -- data-out
    );
  end component;

  signal RST_q : std_logic; -- reset
  signal STRT_q : std_logic; -- start
  signal OPS_q : std_logic_vector(3-1 downto 0);
  signal RE_q : std_logic; -- state read-enable
  signal WE_q : std_logic; -- state write-enable
  signal DI_q : std_logic_vector(SDLEN-1 downto 0); -- data-in

  signal BSY : std_logic; -- busy
  signal DMAE : std_logic; -- DMA enable
  signal STS : std_logic_vector(3-1 downto 0); -- status
  signal DV : std_logic; -- data-out valid
  signal DO : std_logic_vector(SDLEN-1 downto 0); -- data-out

  signal BSY_q : std_logic; -- busy
  signal DMAE_q : std_logic; -- DMA enable
  signal STS_q : std_logic_vector(3-1 downto 0); -- status
  signal DV_q : std_logic; -- data-out valid
  signal DO_q : std_logic_vector(SDLEN-1 downto 0); -- data-out

begin

  -- This synthesis test-bench is used to:
  -- verify codec module is synthesizable,
  -- get Fmax realistic estimate and
  -- provide an instantiation template.

  -- Every input/output signal (except CLK_i and RST_i) is given
  -- a register, in order to make all timing paths of register-register
  -- type, thus simplify timing constraints.

  process(CLK_i)
  begin
    if(CLK_i'event and CLK_i = '1') then
      RST_q <= RST_i;
      STRT_q <= STRT_i;
      OPS_q <= OPS_i;
      RE_q <= RE_i;
      WE_q <= WE_i;
      DI_q <= DI_i;

      BSY_q <= BSY;
      DMAE_q <= DMAE;
      STS_q <= STS;
      DV_q <= DV;
      DO_q <= DO;
    end if;
  end process;

  -- Codec instance

  U_DUT : G729A_CODEC_SDP
    generic map(
      -- synthesis translate_off
      ST_FILE => "NONE", 
      WB_FILE => "NONE", 
      -- synthesis translate_on
      REGISTER_INPUTS => '0', -- not needed in this TB
      REGISTER_OUTPUTS => '0', -- not needed in this TB
      USE_ROM_MIF => USE_ROM_MIF,
      SIMULATION_ONLY => '0' -- do not modify this!
    )
    port map(
      CLK_i => CLK_i,
      RST_i => RST_q,
      STRT_i => STRT_q,
      OPS_i => OPS_q,
      RE_i => RE_q,
      WE_i => WE_q,
      DI_i => DI_q,

      BSY_o => BSY,
      DMAE_o => DMAE,
      STS_o => STS,
      DV_o => DV,
      DO_o => DO
    );

  -- Outputs

  BSY_o <= BSY_q;
  DMAE_o <= DMAE_q;
  STS_o <= STS_q;
  DV_o <= DV_q;
  DO_o <= DO_q;

end ARC;
