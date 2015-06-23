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
-- G729A ASIP top-level module
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

library WORK;
use work.G729A_ASIP_PKG.all;
use work.G729A_ASIP_CFG_PKG.all;

entity G729A_ASIP_TOP_2W is
  generic(
    -- synthesis translate_off
    ST_FILE : string := "NONE";
    WB_FILE : string := "NONE";
    -- synthesis translate_on
    USE_ROM_MIF : std_logic := '0';
    SIMULATION_ONLY : std_logic := '0'
  );
  port(
    CLK_i : in std_logic; -- clock
    RST_i : in std_logic; -- reset
    STRT_i : in std_logic; -- start
    SADR_i : in std_logic_vector(ALEN-1 downto 0);
    SRST_i : in std_logic; -- soft_reset
    DIWE_i : in std_logic; -- data-in write-enable
    DI_i : in std_logic_vector(SDLEN-1 downto 0); -- data-in
    DORE_i : in std_logic; -- data-out read-enable
    CHK_ENB_i : in std_logic; -- check-enable
    XDMAE_i : in std_logic; -- DMA enable
    XWE_i : in std_logic; -- DMA write-enable
    XADR_i : in std_logic_vector(ALEN-1 downto 0);
    XDI_i : in std_logic_vector(SDLEN-1 downto 0); -- DMA data-in

    BSY_o : out std_logic; -- busy
    DIV_o : out std_logic; --
    DOV_o : out std_logic; --
    DO_o : out std_logic_vector(SDLEN-1 downto 0); -- data-out
    XDO_o : out std_logic_vector(SDLEN-1 downto 0) -- DMA data-out
  );
end G729A_ASIP_TOP_2W;

architecture ARC of G729A_ASIP_TOP_2W is

  --constant CMEM_LIMIT : natural := 1024*3;
  constant IO_INTF_PRESENT : std_logic := '0';
  constant MEM_LIMIT : natural := 1024*64-1;
  constant IOMEM_SIZE : natural := 128;
  constant IOMEM_LIMIT : natural := MEM_LIMIT - IOMEM_SIZE;

  component G729A_ASIP_CPU_2W is
    generic(
      -- synthesis translate_off
      ST_FILENAME : string := "NONE";
      WB_FILENAME : string := "NONE";
      -- synthesis translate_on
      SIMULATION_ONLY : std_logic := '1'
    );
    port(
      CLK_i : in std_logic;
      RST_i : in std_logic;
      STRT_i : in std_logic;
      SADR_i : in unsigned(ALEN-1 downto 0);
      -- instruction memory interface
      INSTR_i : in std_logic_vector(ILEN*2-1 downto 0);
      -- data memory interface
      DDAT0_i : in std_logic_vector(SDLEN-1 downto 0);
      DDAT1_i : in std_logic_vector(SDLEN-1 downto 0);
      CHK_ENB_i : in std_logic;
    
      BSY_o : out std_logic;
      -- instruction memory interface
      IADR_o : out unsigned(ALEN-2 downto 0);
      -- data memory interface
      DRE_o : out std_logic_vector(2-1 downto 0);
      DWE0_o : out std_logic;
      DADR0_o : out unsigned(ALEN-1 downto 0);
      DADR1_o : out unsigned(ALEN-1 downto 0);
      DDAT0_o : out std_logic_vector(SDLEN-1 downto 0)
    );
  end component;

  component G729A_ASIP_ROM_MIF is
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
  end component;

  component G729A_ASIP_ROMI is
    generic(
      WCOUNT : natural := 256;
      DATA_WIDTH : natural := 8;
      ADDR_WIDTH : natural := 8
    );
    port(
      CLK_i : in std_logic;
      A_i : in unsigned(ADDR_WIDTH-1 downto 0);

      Q_o : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;

  component G729A_ASIP_ROM_MIF_2R is
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
  end component;

  component G729A_ASIP_ROMD is
    generic(
      WCOUNT : natural := 256;
      DATA_WIDTH : natural := 8;
      ADDR_WIDTH : natural := 8
    );
    port(
      CLK_i : in std_logic;
      A0_i : in unsigned(ADDR_WIDTH-1 downto 0);
      A1_i : in unsigned(ADDR_WIDTH-1 downto 0);

      Q0_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
      Q1_o : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;

  component G729_ASIP_RAM_1RW1R is
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
  end component;

  component G729A_ASIP_IO_INTF is
    generic(
      MEM_LIMIT : natural := 0
    );
    port(
      CLK_i : in std_logic;
      RST_i : in std_logic;
      CPU_ADR_i : in unsigned(ALEN-1 downto 0);
      CPU_RE_i : in std_logic;
      CPU_WE_i : in std_logic;
      EXT_RE_i : in std_logic;
      EXT_WE_i : in std_logic;
      CPU_DI_i : in std_logic_vector(SDLEN-1 downto 0);
      EXT_DI_i : in std_logic_vector(SDLEN-1 downto 0);

      DIV_o : out std_logic;
      DOV_o : out std_logic;
      CPU_DO_o : out std_logic_vector(SDLEN-1 downto 0);
      EXT_DO_o : out std_logic_vector(SDLEN-1 downto 0)
    );
  end component;

  -- convert std_logic_vector type to signed type
  function to_signed(V : std_logic_vector) return signed is
    variable S : signed(V'HIGH downto V'LOW);
  begin
    for i in V'HIGH downto V'LOW loop
      S(i) := V(i);
    end loop;
    return(S);
  end function;

  -- sign-extend
  function EXTS(V : std_logic_vector; L : natural) return std_logic_vector is
    variable XV : std_logic_vector(L-1 downto 0);
  begin
    XV(V'HIGH downto 0) := V;
    XV(L-1 downto V'HIGH+1) := (others => V(V'HIGH));
    return(XV);
  end function;

  function get_dadr_ram(DADR : unsigned(ALEN-1 downto 0)) return unsigned is
    variable DADR_RAM : unsigned(12-1 downto 0);
  begin
    --if(DADR(11 downto 10) /= "11") then
    --  DADR_RAM(11 downto 10) := DADR(11 downto 10);
    --else
    --  DADR_RAM(11 downto 10) := "00";
    --end if;
    --DADR_RAM(9 downto 0) := DADR(9 downto 0);
    DADR_RAM(11 downto 0) := DADR(11 downto 0);
    return(DADR_RAM);
  end function;

  function get_dadr_rom(DADR : unsigned(ALEN-1 downto 0)) return unsigned is
    variable DADR_ROM : unsigned(12-1 downto 0);
  begin
    case DADR(12 downto 10) is
      when "100" => DADR_ROM(11 downto 10) := "01";
      when "101" => DADR_ROM(11 downto 10) := "10";
      when others => DADR_ROM(11 downto 10) := "00";
    end case;
    DADR_ROM(9 downto 0) := DADR(9 downto 0);
    return(DADR_ROM);
  end function;

  function sel_data(
    DI_ROM,DI_IO,DI_RAM : std_logic_vector(SDLEN-1 downto 0);
    ROM_SEL,IO_SEL : std_logic) return std_logic_vector is
  begin
    if(ROM_SEL = '1') then
      return(DI_ROM);
    elsif(IO_SEL = '1') then
      return(DI_IO);
    else
      return(DI_RAM);
    end if;
  end function;

  signal STRT_q : std_logic;
  signal SADR_q : unsigned(ALEN-1 downto 0);
  signal INSTR : std_logic_vector(ILEN*2-1 downto 0);
  signal DDATI0 : std_logic_vector(SDLEN-1 downto 0);
  signal DDATI1 : std_logic_vector(SDLEN-1 downto 0);
  signal BSY : std_logic;
  signal IADR : unsigned(ALEN-2 downto 0);
  signal DWE0 : std_logic;
  signal DRE : std_logic_vector(2-1 downto 0);
  signal DADR0 : unsigned(ALEN-1 downto 0);
  signal DADR1 : unsigned(ALEN-1 downto 0);
  signal DDATO : std_logic_vector(SDLEN-1 downto 0);

  signal DROM0_SEL,DROM1_SEL : std_logic;
  signal DROM0_SEL_q,DROM1_SEL_q : std_logic;
  signal DWE0_RAM : std_logic;
  --signal DADR0_RAM : unsigned(log2(CMEM_LIMIT)-1 downto 0);
  --signal DADR1_RAM : unsigned(log2(CMEM_LIMIT)-1 downto 0);
  --signal DADR0_ROM : unsigned(log2(DMEM_SIZE-CMEM_LIMIT)-1 downto 0);
  --signal DADR1_ROM : unsigned(log2(DMEM_SIZE-CMEM_LIMIT)-1 downto 0);
  signal DADR0_ROM : unsigned(log2(CMEM_LIMIT)-1 downto 0);
  signal DADR1_ROM : unsigned(log2(CMEM_LIMIT)-1 downto 0);
  signal DADR0_RAM : unsigned(log2(DMEM_SIZE-CMEM_LIMIT)-1 downto 0);
  signal DADR1_RAM : unsigned(log2(DMEM_SIZE-CMEM_LIMIT)-1 downto 0);
  signal DDATI0_RAM : std_logic_vector(SDLEN-1 downto 0);
  signal DDATI1_RAM : std_logic_vector(SDLEN-1 downto 0);
  signal DDATI0_ROM : std_logic_vector(SDLEN-1 downto 0);
  signal DDATI1_ROM : std_logic_vector(SDLEN-1 downto 0);

  signal IOMEM0_SEL,IOMEM1_SEL : std_logic;
  signal IOMEM0_SEL_q,IOMEM1_SEL_q : std_logic;
  signal DI_q,DO_q : std_logic_vector(SDLEN-1 downto 0);
  signal DIV_q,DOV_q : std_logic;
  signal DDATI_IO : std_logic_vector(SDLEN-1 downto 0);
  signal DDATI_IO_q : std_logic_vector(SDLEN-1 downto 0);

  signal DDI_RAM : std_logic_vector(SDLEN-1 downto 0);

begin

  ---------------------------------------------------
  -- ASIP Core
  ---------------------------------------------------

  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      if(RST_i = '1') then
        STRT_q <= '0';
      else
        STRT_q <= STRT_i;
      end if;
      SADR_q <= to_unsigned(SADR_i);
    end if;
  end process;

  U_ASIP : G729A_ASIP_CPU_2W
    generic map(
      -- synthesis translate_off
      ST_FILENAME => ST_FILE,
      WB_FILENAME => WB_FILE,
      -- synthesis translate_on
      SIMULATION_ONLY => SIMULATION_ONLY
    )
    port map(
      CLK_i => CLK_i,
      RST_i => RST_i, 
      STRT_i => STRT_q, 
      SADR_i => SADR_q, 
      INSTR_i => INSTR, 
      DDAT0_i => DDATI0,
      DDAT1_i => DDATI1, 
      CHK_ENB_i => CHK_ENB_i, 
    
      BSY_o => BSY, 
      IADR_o => IADR, 
      DRE_o => DRE, 
      DWE0_o => DWE0, 
      DADR0_o => DADR0, 
      DADR1_o => DADR1, 
      DDAT0_o => DDATO 
    );

  BSY_o <= BSY;

  ---------------------------------------------------
  -- Data memory selections signals
  ---------------------------------------------------

  G0_T : if(IO_INTF_PRESENT = '1') generate

  DROM0_SEL <= '1' when
    (DADR0 >= CMEM_LIMIT and DADR0 < IOMEM_LIMIT) else '0';

  DROM1_SEL <= '1' when
    (DADR1 >= CMEM_LIMIT and DADR1 < IOMEM_LIMIT) else '0';

  end generate;

  G0_F : if(IO_INTF_PRESENT = '0') generate

  DROM0_SEL <= '1' when
    (DADR0 >= CMEM_LIMIT) else '0';

  DROM1_SEL <= '1' when
    (DADR1 >= CMEM_LIMIT) else '0';

  end generate;

  -- registered DROM_SEL (needed to select ASIP data-in)
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      DROM0_SEL_q <= DROM0_SEL;
      DROM1_SEL_q <= DROM1_SEL;
    end if;
  end process;

  G1_T : if(IO_INTF_PRESENT = '1') generate

  IOMEM0_SEL <= '1' when (DADR0 >= IOMEM_LIMIT) else '0';
  IOMEM1_SEL <= '1' when (DADR1 >= IOMEM_LIMIT) else '0';

  end generate;

  G1_F : if(IO_INTF_PRESENT = '0') generate

  IOMEM0_SEL <= '0';
  IOMEM1_SEL <= '0';

  end generate;

  -- registered IOMEM_SEL (needed to select ASIP data-in)
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then
      IOMEM0_SEL_q <= IOMEM0_SEL;
      IOMEM1_SEL_q <= IOMEM1_SEL;
    end if;
  end process;

  -- data RAM addresses

  DADR0_RAM <= get_dadr_ram(DADR0) when (XDMAE_i = '0') else 
    get_dadr_ram(to_unsigned(XADR_i));

  DADR1_RAM <= get_dadr_ram(DADR1);
 
  -- data RAM write-enable

  DWE0_RAM <= DWE0 when (XDMAE_i = '0') else XWE_i;

  DDI_RAM <= DDATO when XDMAE_i = '0' else XDI_i; 

  -- ASIP core data-in (pay attention not to read I/O memory in parallel!)

  DDATI0 <= sel_data(DDATI0_ROM,DDATI_IO_q,DDATI0_RAM,DROM0_SEL_q,IOMEM0_SEL_q);
  DDATI1 <= sel_data(DDATI1_ROM,DDATI_IO_q,DDATI1_RAM,DROM1_SEL_q,'0');
  
  -- data ROM address

  DADR0_ROM <= get_dadr_rom(DADR0);
  DADR1_ROM <= get_dadr_rom(DADR1);

  ---------------------------------------------------
  -- Instruction ROM
  ---------------------------------------------------

  -- instruction ROM is a single-port ROM with double
  -- word length (two instructions can be fetched with
  -- a single read)

  G_ROMI_1 : if (USE_ROM_MIF = '1') generate

  -- Data content for this ROM is assigned through a MIF file.
  -- This type of ROM is ok for synthesis with Altera tools.

  U_ROMI : G729A_ASIP_ROM_MIF
    generic map(
      WCOUNT => IMEM_SIZE/2,
      DATA_WIDTH => ILEN*2,
      ADDR_WIDTH => log2(IMEM_SIZE/2),
      ROM_INIT_FILE => "G729A_asip_romi.mif" --ROMI_INIT_FILE
    )
    port map(
      CLK_i => CLK_i,
      A_i => IADR(log2(IMEM_SIZE)-2 downto 0),

      Q_o => INSTR
    );

  end generate;

  G_ROMI_0 : if (USE_ROM_MIF = '0') generate

  -- Data content for this ROM is explicitly assigned in VHDL code.
  -- This type of ROM is ok for simulation and for synthesis with
  -- Xilinx tools.

  U_ROMI : G729A_ASIP_ROMI
    generic map(
      WCOUNT => IMEM_SIZE/2,
      DATA_WIDTH => ILEN*2,
      ADDR_WIDTH => log2(IMEM_SIZE/2)
    )
    port map(
      CLK_i => CLK_i,
      A_i => IADR(log2(IMEM_SIZE)-2 downto 0),

      Q_o => INSTR
    );

  end generate;

  ---------------------------------------------------
  -- Data ROM
  ---------------------------------------------------

  -- data ROM is a dual-port ROM with single word length
  -- (two reads can be performed in parallel).

  G_ROMD_1 : if (USE_ROM_MIF = '1') generate

  -- Data content for this ROM is assigned through a MIF file.
  -- This type of ROM is ok for synthesis with Altera tools.

  U_ROMD : G729A_ASIP_ROM_MIF_2R
    generic map(
      WCOUNT => CMEM_LIMIT,
      DATA_WIDTH => SDLEN,
      ADDR_WIDTH => log2(CMEM_LIMIT),
      ROM_INIT_FILE => "G729A_asip_romd.mif" --ROMD_INIT_FILE
    )
    port map(
      CLK_i => CLK_i,
      A0_i => DADR0_ROM,
      A1_i => DADR1_ROM,

      Q0_o => DDATI0_ROM,
      Q1_o => DDATI1_ROM
    );

  end generate;

  G_ROMD_0 : if (USE_ROM_MIF = '0') generate

  -- Data content for this ROM is explicitly assigned in VHDL code.
  -- This type of ROM is ok for simulation and for synthesis with
  -- Xilinx tools.

  U_ROMD : G729A_ASIP_ROMD
    generic map(
      WCOUNT => CMEM_LIMIT,
      DATA_WIDTH => SDLEN,
      ADDR_WIDTH => log2(CMEM_LIMIT)
    )
    port map(
      CLK_i => CLK_i,
      A0_i => DADR0_ROM,
      A1_i => DADR1_ROM,

      Q0_o => DDATI0_ROM,
      Q1_o => DDATI1_ROM
    );

  end generate;

  ---------------------------------------------------
  -- Data RAM
  ---------------------------------------------------

  -- data RAM is dual-port RAM with 1 read/write port and
  -- 1 read-only port (two reads, or one read and one write
  -- can be performed in parallel).

  U_RAMD : G729_ASIP_RAM_1RW1R
    generic map(
      DWIDTH => SDLEN,
      --WCOUNT => DMEM_SIZE-CMEM_LIMIT
      WCOUNT => 4096
    )
    port map(
      CLK_i => CLK_i,
      A_i => DADR0_RAM,
      DPRA_i => DADR1_RAM,
      D_i => DDI_RAM, --DDATO,
      WE_i => DWE0_RAM,

      Q_o => DDATI0_RAM,
      DPQ_o => DDATI1_RAM
    );

  XDO_o <= DDATI0_RAM(SDLEN-1 downto 0);

  ---------------------------------------------------
  -- Checker
  ---------------------------------------------------

  G_CHK0 : if(SIMULATION_ONLY = '1') generate

     assert not(IADR >= IMEM_SIZE and CLK_i = '1' and CLK_i'event) 
     report "invalid instruction address!"
     severity ERROR;

     assert not(DADR0 >= DMEM_SIZE and DRE(0) = '1' and CLK_i = '1'
       and CLK_i'event) 
     report "invalid read data address!"
     severity ERROR;

     assert not(DADR1 >= DMEM_SIZE and DRE(1) = '1' and CLK_i = '1'
       and CLK_i'event) 
     report "invalid read data address!"
     severity ERROR;

     assert not(DADR0_RAM >= DMEM_SIZE and DWE0_RAM = '1' and CLK_i = '1' and CLK_i'event) 
     report "invalid write data address!"
     severity ERROR;

     assert not(DWE0 = '1' and DADR0 > CMEM_LIMIT and CLK_i = '1'
       and CLK_i'event) 
     report "Data ROM write attempt!"
     severity ERROR;

  end generate;

  ---------------------------------------------------
  -- I/O interface
  ---------------------------------------------------

  G2_T : if(IO_INTF_PRESENT = '1') generate

  U_IO : G729A_ASIP_IO_INTF
    generic map(
      MEM_LIMIT => MEM_LIMIT
    )
    port map(
      CLK_i => CLK_i,
      RST_i => RST_i,
      CPU_ADR_i => DADR0,
      CPU_RE_i => DRE(0),
      CPU_WE_i => DWE0,
      EXT_RE_i => DORE_i,
      EXT_WE_i => DIWE_i,
      CPU_DI_i => DDATO,
      EXT_DI_i => DI_i,

      DIV_o => DIV_o,
      DOV_o => DOV_o,
      CPU_DO_o => DDATI_IO,
      EXT_DO_o => DO_o
    );

  end generate;

  G2_F : if(IO_INTF_PRESENT = '0') generate

      DIV_o <= '0';
      DOV_o <= '0';
      DDATI_IO <= (others => '0');
      DO_o <= (others => '0');

  end generate;

  -- pipeline register (needed to match sync. RAM delay) 
  process(CLK_i)
  begin
    if(CLK_i = '1' and CLK_i'event) then 
      DDATI_IO_q <= DDATI_IO;
    end if;
  end process;

end ARC;
