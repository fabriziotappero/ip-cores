-------------------------------------------------------------------------------
-- File Name :  ByteStuffer.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : ByteStuffer
--
-- Content   : ByteStuffer
--
-- Description : ByteStuffer core
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
entity ByteStuffer is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        -- CTRL
        start_pb           : in  std_logic;
        ready_pb           : out std_logic;
        
        -- HOST IF
        sof                : in  std_logic;
        num_enc_bytes      : out std_logic_vector(23 downto 0);
        outram_base_addr   : in  std_logic_vector(9 downto 0);
                
        -- Huffman
        huf_buf_sel        : out std_logic;
        huf_fifo_empty     : in  std_logic;
        huf_rd_req         : out std_logic;
        huf_packed_byte    : in  std_logic_vector(7 downto 0);
        
        -- OUT RAM
        ram_byte           : out std_logic_vector(7 downto 0);
        ram_wren           : out std_logic;
        ram_wraddr         : out std_logic_vector(23 downto 0)
    );
end entity ByteStuffer;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of ByteStuffer is

  signal huf_data_val   : std_logic_vector(3 downto 0);
  signal wdata_reg      : std_logic_vector(15 downto 0);
  signal wraddr         : unsigned(23 downto 0);
  signal wr_n_cnt       : unsigned(1 downto 0);
  signal huf_buf_sel_s  : std_logic;
  signal rd_en          : std_logic;
  signal rd_en_d1       : std_logic;
  signal huf_rd_req_s   : std_logic;
  signal latch_byte     : std_logic_vector(7 downto 0);
  signal data_valid     : std_logic;
  signal wait_for_ndata : std_logic;
  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin

  huf_buf_sel <= huf_buf_sel_s;
  huf_rd_req  <= huf_rd_req_s;

  -------------------------------------------------------------------
  -- CTRL_SM
  -------------------------------------------------------------------
  p_ctrl_sm : process(CLK, RST)
  begin
    if RST = '1' then
      wr_n_cnt     <= (others => '0');
      ready_pb     <= '0';
      huf_rd_req_s <= '0';
      huf_data_val <= (others => '0');
      rd_en        <= '0';
      rd_en_d1     <= '0';
      wdata_reg    <= (others => '0');
      ram_wren     <= '0';
      wraddr       <= (others => '0');
      ram_wraddr   <= (others => '0');
      ram_byte     <= (others => '0');
      latch_byte   <= (others => '0');
      wait_for_ndata <= '0';
      data_valid     <= '0';
    elsif CLK'event and CLK = '1' then
      huf_rd_req_s <= '0';
      ready_pb     <= '0';
      huf_data_val <= huf_data_val(huf_data_val'length-2 downto 0) & huf_rd_req_s;
      rd_en_d1     <= rd_en;
      ram_wren     <= '0';
      data_valid   <= '0';
      
      if start_pb = '1' then
        rd_en <= '1';
      end if;
      
      -- read FIFO until it becomes empty. wait until last byte read is
      -- serviced
      if rd_en_d1 = '1' and wait_for_ndata = '0' then
        -- FIFO empty
        if huf_fifo_empty = '1' then
          rd_en      <= '0';
          rd_en_d1   <= '0';
          ready_pb   <= '1';
        else
          huf_rd_req_s <= '1';
          wait_for_ndata <= '1';
        end if;
      end if;
      
      -- show ahead FIFO, capture data early
      if huf_rd_req_s = '1' then
        latch_byte <= huf_packed_byte;
        data_valid <= '1';
      end if;
      
      if huf_data_val(1) = '1' then
        wait_for_ndata <= '0';
      end if;
        
      -- data from FIFO is valid
      if data_valid = '1' then
        -- stuffing necessary
        if latch_byte = X"FF" then
          -- two writes are necessary for byte stuffing
          wr_n_cnt  <= "10";
          wdata_reg <= X"FF00";
        -- no stuffing
        else
          wr_n_cnt  <= "01";
          wdata_reg <= X"00" & latch_byte;
        end if;
      end if;
      
      if wr_n_cnt > 0 then
        wr_n_cnt <= wr_n_cnt - 1;
        ram_wren <= '1';
        wraddr   <= wraddr + 1;
      end if;
      -- delayed to make address post-increment
      ram_wraddr <= std_logic_vector(wraddr);
      
      -- stuffing
      if wr_n_cnt = 2 then
        ram_byte <= wdata_reg(15 downto 8);
      elsif wr_n_cnt = 1 then
        ram_byte <= wdata_reg(7 downto 0);
      end if;
      
      if sof = '1' then
        wraddr <= to_unsigned(C_HDR_SIZE,wraddr'length);
      end if;
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- HUFFMAN buf_sel
  -------------------------------------------------------------------
  p_huf_buf_sel : process(CLK, RST)
  begin
    if RST = '1' then
      huf_buf_sel_s   <= '0'; 
    elsif CLK'event and CLK = '1' then
      if start_pb = '1' then
        huf_buf_sel_s <= not huf_buf_sel_s;
      end if;
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- num_enc_bytes
  -------------------------------------------------------------------
  p_num_enc_bytes : process(CLK, RST)
  begin
    if RST = '1' then
      num_enc_bytes   <= (others => '0'); 
    elsif CLK'event and CLK = '1' then
      -- plus 2 for EOI marker last bytes
      num_enc_bytes   <= std_logic_vector(wraddr + 2);
    end if;
  end process;


end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------