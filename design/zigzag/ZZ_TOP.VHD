-------------------------------------------------------------------------------
-- File Name :  ZZ_TOP.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : ZZ_TOP
--
-- Content   : ZigZag Top level
--
-- Description : Zig Zag scan
--
-- Spec.     : 
--
-- Author    : Michal Krepa
--
-------------------------------------------------------------------------------
-- History :
-- 20090301: (MK): Initial Creation.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- LIBRARY/PACKAGE ---------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- generic packages/libraries:
-------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- user packages/libraries:
-------------------------------------------------------------------------------
library work;
  use work.JPEG_PKG.all;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ENTITY ------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
entity ZZ_TOP is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        -- CTRL
        start_pb           : in  std_logic;
        ready_pb           : out std_logic;
        zig_sm_settings    : in  T_SM_SETTINGS;
        
        -- Quantizer
        qua_buf_sel        : in  std_logic;
        qua_rdaddr         : in  std_logic_vector(5 downto 0);
        qua_data           : out std_logic_vector(11 downto 0);
        
        -- FDCT
        fdct_buf_sel       : out std_logic;
        fdct_rd_addr       : out std_logic_vector(5 downto 0);
        fdct_data          : in  std_logic_vector(11 downto 0);
        fdct_rden          : out std_logic
    );
end entity ZZ_TOP;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of ZZ_TOP is

  signal dbuf_data      : std_logic_vector(11 downto 0);
  signal dbuf_q         : std_logic_vector(11 downto 0);
  signal dbuf_we        : std_logic;
  signal dbuf_waddr     : std_logic_vector(6 downto 0);
  signal dbuf_raddr     : std_logic_vector(6 downto 0);
  signal zigzag_di      : std_logic_vector(11 downto 0);
  signal zigzag_divalid : std_logic;
  signal zigzag_dout    : std_logic_vector(11 downto 0);
  signal zigzag_dovalid : std_logic;
  signal wr_cnt         : unsigned(5 downto 0);
  signal rd_cnt         : unsigned(5 downto 0);
  signal rd_en_d        : std_logic_vector(5 downto 0);
  signal rd_en          : std_logic;
  signal fdct_buf_sel_s : std_logic;
  signal zz_rd_addr     : std_logic_vector(5 downto 0);
  signal fifo_empty     : std_logic;
  signal fifo_rden      : std_logic;
  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin

  fdct_rd_addr <= std_logic_vector(zz_rd_addr);
  qua_data     <= dbuf_q;
  fdct_buf_sel <= fdct_buf_sel_s;
  fdct_rden    <= rd_en;

  -------------------------------------------------------------------
  -- ZigZag Core
  -------------------------------------------------------------------
  U_zigzag : entity work.zigzag
  generic map
    ( 
      RAMADDR_W     => 6,
      RAMDATA_W     => 12
    )
  port map
    (
      rst        => RST,
      clk        => CLK,
      di         => zigzag_di,
      divalid    => zigzag_divalid,
      rd_addr    => rd_cnt,
      fifo_rden  => fifo_rden,
      
      fifo_empty => fifo_empty,
      dout       => zigzag_dout,
      dovalid    => zigzag_dovalid,
      zz_rd_addr => zz_rd_addr
    );
  
  zigzag_di      <= fdct_data;
  zigzag_divalid <= rd_en_d(1);
  
  -------------------------------------------------------------------
  -- DBUF
  -------------------------------------------------------------------
  U_RAMZ : entity work.RAMZ
  generic map
  ( 
      RAMADDR_W     => 7,
      RAMDATA_W     => 12
  )
  port map
  (      
        d           => dbuf_data,
        waddr       => dbuf_waddr,
        raddr       => dbuf_raddr,
        we          => dbuf_we,
        clk         => CLK,
                    
        q           => dbuf_q
  ); 
  
  dbuf_data  <= zigzag_dout;
  dbuf_waddr <= (not qua_buf_sel) & std_logic_vector(wr_cnt);
  dbuf_we    <= zigzag_dovalid;
  dbuf_raddr <= qua_buf_sel & qua_rdaddr;
  
  -------------------------------------------------------------------
  -- FIFO Ctrl
  -------------------------------------------------------------------
  p_fifo_ctrl : process(CLK, RST)
  begin
    if RST = '1' then
      fifo_rden   <= '0';
    elsif CLK'event and CLK = '1' then
      if fifo_empty = '0' then
        fifo_rden <= '1';
      else
        fifo_rden <= '0';
      end if;      
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- Counter1
  -------------------------------------------------------------------
  p_counter1 : process(CLK, RST)
  begin
    if RST = '1' then
      rd_en        <= '0';
      rd_en_d      <= (others => '0');
      rd_cnt       <= (others => '0');
    elsif CLK'event and CLK = '1' then
      rd_en_d <= rd_en_d(rd_en_d'length-2 downto 0) & rd_en;
    
      if start_pb = '1' then
        rd_cnt <= (others => '0');
        rd_en <= '1';       
      end if;
      
      if rd_en = '1' then
        if rd_cnt = 64-1 then
          rd_cnt <= (others => '0');
          rd_en  <= '0';
        else
          rd_cnt <= rd_cnt + 1;
        end if;
      end if;
      
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- wr_cnt
  -------------------------------------------------------------------
  p_wr_cnt : process(CLK, RST)
  begin
    if RST = '1' then
      wr_cnt   <= (others => '0');
      ready_pb <= '0';
    elsif CLK'event and CLK = '1' then
      ready_pb <= '0';
    
      if start_pb = '1' then
        wr_cnt <= (others => '0');
      end if;
      
      if zigzag_dovalid = '1' then
        if wr_cnt = 64-1 then
          wr_cnt <= (others => '0');
        else
          wr_cnt <=wr_cnt + 1;
        end if;
        
        -- give ready ahead to save cycles!
        if wr_cnt = 64-1-3 then
          ready_pb <= '1';
        end if;
        
      end if;
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- fdct_buf_sel
  -------------------------------------------------------------------
  p_buf_sel : process(CLK, RST)
  begin
    if RST = '1' then
      fdct_buf_sel_s   <= '0'; 
    elsif CLK'event and CLK = '1' then
      if start_pb = '1' then
        fdct_buf_sel_s <= not fdct_buf_sel_s;
      end if;
    end if;
  end process;

end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------