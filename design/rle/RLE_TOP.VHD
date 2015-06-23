-------------------------------------------------------------------------------
-- File Name : RLE_TOP.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : RLE_TOP
--
-- Content   : Run Length Encoder top level
--
-- Description : 
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
entity RLE_TOP is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        -- CTRL
        start_pb           : in  std_logic;
        ready_pb           : out std_logic;
        rle_sm_settings    : in T_SM_SETTINGS;
        
        -- HUFFMAN
        huf_buf_sel        : in  std_logic;
        huf_rden           : in  std_logic;
        huf_runlength      : out std_logic_vector(3 downto 0);
        huf_size           : out std_logic_vector(3 downto 0);
        huf_amplitude      : out std_logic_vector(11 downto 0);
        huf_dval           : out std_logic;
        huf_fifo_empty     : out std_logic;
        
        -- Quantizer
        qua_buf_sel        : out std_logic;
        qua_rd_addr        : out std_logic_vector(5 downto 0);
        qua_data           : in  std_logic_vector(11 downto 0);
        
        -- HostIF
        sof                : in  std_logic
    );
end entity RLE_TOP;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of RLE_TOP is

  signal dbuf_data      : std_logic_vector(19 downto 0);
  signal dbuf_q         : std_logic_vector(19 downto 0);
  signal dbuf_we        : std_logic;

  signal rle_runlength  : std_logic_vector(3 downto 0);
  signal rle_size       : std_logic_vector(3 downto 0);
  signal rle_amplitude  : std_logic_vector(11 downto 0);
  signal rle_dovalid    : std_logic;
  signal rle_di         : std_logic_vector(11 downto 0);
  signal rle_divalid    : std_logic;
  
  signal qua_buf_sel_s  : std_logic;
  signal huf_dval_p0    : std_logic;
  
  signal wr_cnt         : unsigned(5 downto 0);
  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin

  huf_runlength <= dbuf_q(19 downto 16);
  huf_size      <= dbuf_q(15 downto 12);
  huf_amplitude <= dbuf_q(11 downto 0);
  qua_buf_sel   <= qua_buf_sel_s;

  -------------------------------------------------------------------
  -- RLE Core
  -------------------------------------------------------------------
  U_rle : entity work.rle
  generic map
    ( 
      RAMADDR_W  => 6,
      RAMDATA_W  => 12
    )
  port map
    (
      rst        => RST,
      clk        => CLK,
      di         => rle_di,
      start_pb   => start_pb,
      sof        => sof,
      rle_sm_settings => rle_sm_settings,

      runlength  => rle_runlength,
      size       => rle_size,
      amplitude  => rle_amplitude,
      dovalid    => rle_dovalid,
      rd_addr    => qua_rd_addr
    ); 
    
  rle_di      <= qua_data;
  
  -------------------------------------------------------------------
  -- Double Fifo
  -------------------------------------------------------------------
  U_RleDoubleFifo : entity work.RleDoubleFifo
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- RLE
        data_in            => dbuf_data,
        wren               => dbuf_we,
        -- HUFFMAN
        buf_sel            => huf_buf_sel,
        rd_req             => huf_rden,
        fifo_empty         => huf_fifo_empty,
        data_out           => dbuf_q
    );
  dbuf_data  <= rle_runlength & rle_size & rle_amplitude;
  dbuf_we    <= rle_dovalid;
  
  
  
  
  -------------------------------------------------------------------
  -- ready_pb
  -------------------------------------------------------------------
  p_ready_pb : process(CLK, RST)
  begin
    if RST = '1' then
      ready_pb <= '0';
      wr_cnt   <= (others => '0');
    elsif CLK'event and CLK = '1' then
      ready_pb <= '0';
      
      if start_pb = '1' then
        wr_cnt <= (others => '0');
      end if;
      
      -- detect EOB (0,0) - end of RLE block
      if rle_dovalid = '1' then
      
        -- ZERO EXTENSION
        if unsigned(rle_runlength) = 15 and unsigned(rle_size) = 0 then
          wr_cnt <= wr_cnt + 16;
        else
          wr_cnt <= wr_cnt + 1 + resize(unsigned(rle_runlength), wr_cnt'length);
        end if;
        
        -- EOB can only be on AC!
        if dbuf_data = (dbuf_data'range => '0') and wr_cnt /= 0 then
          ready_pb <= '1';
        else
          if wr_cnt + resize(unsigned(rle_runlength), wr_cnt'length) = 64-1 then
            ready_pb <= '1';
          end if;
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
      qua_buf_sel_s   <= '0'; 
    elsif CLK'event and CLK = '1' then
      if start_pb = '1' then
        qua_buf_sel_s <= not qua_buf_sel_s;
      end if;
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- output data valid
  -------------------------------------------------------------------
  p_dval : process(CLK, RST)
  begin
    if RST = '1' then
      huf_dval_p0 <= '0';
      --huf_dval    <= '0';
    elsif CLK'event and CLK = '1' then
      huf_dval_p0 <= huf_rden;
      --huf_dval    <= huf_rden;
    end if;
  end process;
  
  huf_dval    <= huf_rden;

end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------