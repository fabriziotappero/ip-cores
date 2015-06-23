-------------------------------------------------------------------------------
-- File Name : JpegEnc.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : JpegEnc
--
-- Content   : JPEG Encoder Top Level
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
entity JpegEnc is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        
        -- OPB
        OPB_ABus           : in  std_logic_vector(31 downto 0);
        OPB_BE             : in  std_logic_vector(3 downto 0);
        OPB_DBus_in        : in  std_logic_vector(31 downto 0);
        OPB_RNW            : in  std_logic;
        OPB_select         : in  std_logic;
        OPB_DBus_out       : out std_logic_vector(31 downto 0);
        OPB_XferAck        : out std_logic;
        OPB_retry          : out std_logic;
        OPB_toutSup        : out std_logic;
        OPB_errAck         : out std_logic;
        
        -- IMAGE RAM
        iram_wdata         : in  std_logic_vector(C_PIXEL_BITS-1 downto 0);
        iram_wren          : in  std_logic;
        iram_fifo_afull    : out std_logic; 
        
        -- OUT RAM
        ram_byte           : out std_logic_vector(7 downto 0);
        ram_wren           : out std_logic;
        ram_wraddr         : out std_logic_vector(23 downto 0);
        outif_almost_full  : in  std_logic        
   );
end entity JpegEnc;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of JpegEnc is

  signal qdata              : std_logic_vector(7 downto 0);
  signal qaddr              : std_logic_vector(6 downto 0);
  signal qwren              : std_logic;
  signal jpeg_ready         : std_logic;
  signal jpeg_busy          : std_logic;
  signal outram_base_addr   : std_logic_vector(9 downto 0);
  signal num_enc_bytes      : std_logic_vector(23 downto 0);
  signal img_size_x         : std_logic_vector(15 downto 0); 
  signal img_size_y         : std_logic_vector(15 downto 0);
  signal sof                : std_logic;
  signal jpg_iram_rden      : std_logic;
  signal jpg_iram_rdaddr    : std_logic_vector(31 downto 0);
  signal jpg_iram_rdata     : std_logic_vector(23 downto 0);
  signal fdct_start         : std_logic;
  signal fdct_ready         : std_logic;
  signal zig_start          : std_logic;
  signal zig_ready          : std_logic;
  signal qua_start          : std_logic;
  signal qua_ready          : std_logic;
  signal rle_start          : std_logic;
  signal rle_ready          : std_logic;
  signal huf_start          : std_logic;
  signal huf_ready          : std_logic;
  signal bs_start           : std_logic;
  signal bs_ready           : std_logic;
  signal zz_buf_sel         : std_logic;
  signal zz_rd_addr         : std_logic_vector(5 downto 0);
  signal zz_data            : std_logic_vector(11 downto 0);
  signal rle_buf_sel        : std_logic;                     
  signal rle_rdaddr         : std_logic_vector(5 downto 0);
  signal rle_data           : std_logic_vector(11 downto 0);
  signal qua_buf_sel        : std_logic;                     
  signal qua_rdaddr         : std_logic_vector(5 downto 0);
  signal qua_data           : std_logic_vector(11 downto 0);
  signal huf_buf_sel        : std_logic;
  signal huf_rdaddr         : std_logic_vector(5 downto 0);
  signal huf_rden           : std_logic;
  signal huf_runlength      : std_logic_vector(3 downto 0);
  signal huf_size           : std_logic_vector(3 downto 0);
  signal huf_amplitude      : std_logic_vector(11 downto 0);
  signal huf_dval           : std_logic;
  signal bs_buf_sel         : std_logic;
  signal bs_fifo_empty      : std_logic;
  signal bs_rd_req          : std_logic;
  signal bs_packed_byte     : std_logic_vector(7 downto 0);
  signal huf_fifo_empty     : std_logic;
  signal zz_rden            : std_logic;
  signal fdct_sm_settings   : T_SM_SETTINGS;
  signal zig_sm_settings    : T_SM_SETTINGS;
  signal qua_sm_settings    : T_SM_SETTINGS;
  signal rle_sm_settings    : T_SM_SETTINGS;
  signal huf_sm_settings    : T_SM_SETTINGS;
  signal bs_sm_settings     : T_SM_SETTINGS;
  signal image_size_reg     : std_logic_vector(31 downto 0);
  signal jfif_ram_byte      : std_logic_vector(7 downto 0);
  signal jfif_ram_wren      : std_logic;
  signal jfif_ram_wraddr    : std_logic_vector(23 downto 0);
  signal out_mux_ctrl       : std_logic;
  signal img_size_wr        : std_logic;
  signal jfif_start         : std_logic;
  signal jfif_ready         : std_logic;
  signal bs_ram_byte        : std_logic_vector(7 downto 0);
  signal bs_ram_wren        : std_logic;
  signal bs_ram_wraddr      : std_logic_vector(23 downto 0);
  signal jfif_eoi           : std_logic;
  signal fdct_fifo_rd       : std_logic;
  signal fdct_fifo_q        : std_logic_vector(23 downto 0);
  signal fdct_fifo_hf_full  : std_logic;
  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin

  -------------------------------------------------------------------
  -- Host Interface
  -------------------------------------------------------------------
  U_HostIF : entity work.HostIF
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- OPB
        OPB_ABus           => OPB_ABus,
        OPB_BE             => OPB_BE,
        OPB_DBus_in        => OPB_DBus_in,
        OPB_RNW            => OPB_RNW,
        OPB_select         => OPB_select,
        OPB_DBus_out       => OPB_DBus_out,
        OPB_XferAck        => OPB_XferAck,
        OPB_retry          => OPB_retry,
        OPB_toutSup        => OPB_toutSup,
        OPB_errAck         => OPB_errAck,
                           
        -- Quantizer RAM
        qdata              => qdata,
        qaddr              => qaddr,
        qwren              => qwren,
        
        -- CTRL
        jpeg_ready         => jpeg_ready,
        jpeg_busy          => jpeg_busy,
        
        -- ByteStuffer
        outram_base_addr   => outram_base_addr,
        num_enc_bytes      => num_enc_bytes,
        
        -- global
        img_size_x         => img_size_x,
        img_size_y         => img_size_y,
        img_size_wr        => img_size_wr,
        sof                => sof
    );
    
  -------------------------------------------------------------------
  -- BUF_FIFO
  -------------------------------------------------------------------
  U_BUF_FIFO : entity work.BUF_FIFO
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- HOST PROG
        img_size_x         => img_size_x,
        img_size_y         => img_size_y,
        sof                => sof,

        -- HOST DATA
        iram_wren          => iram_wren,
        iram_wdata         => iram_wdata,
        fifo_almost_full   => iram_fifo_afull,

        -- FDCT
        fdct_fifo_rd       => fdct_fifo_rd,
        fdct_fifo_q        => fdct_fifo_q,
        fdct_fifo_hf_full  => fdct_fifo_hf_full
    );
    
  -------------------------------------------------------------------
  -- Controller
  -------------------------------------------------------------------
  U_CtrlSM : entity work.CtrlSM
  port map
  (
        CLK                => CLK,
        RST                => RST,
        
        -- output IF
        outif_almost_full  => outif_almost_full,

        -- HOST IF
        sof                => sof,
        img_size_x         => img_size_x,
        img_size_y         => img_size_y,
        jpeg_ready         => jpeg_ready,
        jpeg_busy          => jpeg_busy,

        -- FDCT
        fdct_start         => fdct_start,
        fdct_ready         => fdct_ready,
        fdct_sm_settings   => fdct_sm_settings,

        -- ZIGZAG
        zig_start          => zig_start,
        zig_ready          => zig_ready,
        zig_sm_settings    => zig_sm_settings,
        
        -- Quantizer
        qua_start          => qua_start,
        qua_ready          => qua_ready,
        qua_sm_settings    => qua_sm_settings,

        -- RLE
        rle_start          => rle_start,
        rle_ready          => rle_ready,
        rle_sm_settings    => rle_sm_settings,

        -- Huffman
        huf_start          => huf_start,
        huf_ready          => huf_ready,
        huf_sm_settings    => huf_sm_settings,

        -- ByteStuffdr
        bs_start           => bs_start,
        bs_ready           => bs_ready,
        bs_sm_settings     => bs_sm_settings,
        
        -- JFIF GEN
        jfif_start         => jfif_start,
        jfif_ready         => jfif_ready,
        jfif_eoi           => jfif_eoi,
                           
        -- OUT MUX         
        out_mux_ctrl       => out_mux_ctrl
    );

  -------------------------------------------------------------------
  -- FDCT
  -------------------------------------------------------------------
  U_FDCT : entity work.FDCT
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- CTRL
        start_pb           => fdct_start,
        ready_pb           => fdct_ready,
        fdct_sm_settings   => fdct_sm_settings,

        -- BUF_FIFO
        bf_fifo_rd         => fdct_fifo_rd,   
        bf_fifo_q          => fdct_fifo_q,  
        bf_fifo_hf_full    => fdct_fifo_hf_full,

        -- ZIG ZAG
        zz_buf_sel         => zz_buf_sel,
        zz_rd_addr         => zz_rd_addr,
        zz_data            => zz_data,
        zz_rden            => zz_rden,

        -- HOST
        img_size_x         => img_size_x,
        img_size_y         => img_size_y,
        sof                => sof        
    );
    
  -------------------------------------------------------------------
  -- ZigZag top level
  -------------------------------------------------------------------
  U_ZZ_TOP : entity work.ZZ_TOP
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- CTRL
        start_pb           => zig_start,
        ready_pb           => zig_ready,
        zig_sm_settings    => zig_sm_settings,

        -- Quantizer
        qua_buf_sel        => qua_buf_sel,
        qua_rdaddr         => qua_rdaddr,
        qua_data           => qua_data,

        -- FDCT
        fdct_buf_sel       => zz_buf_sel,
        fdct_rd_addr       => zz_rd_addr,
        fdct_data          => zz_data,
        fdct_rden          => zz_rden
    );
   
  -------------------------------------------------------------------
  -- Quantizer top level
  -------------------------------------------------------------------
  U_QUANT_TOP : entity work.QUANT_TOP
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- CTRL
        start_pb           => qua_start,
        ready_pb           => qua_ready,
        qua_sm_settings    => qua_sm_settings,

        -- RLE
        rle_buf_sel        => rle_buf_sel,
        rle_rdaddr         => rle_rdaddr,
        rle_data           => rle_data,

        -- ZIGZAG
        zig_buf_sel        => qua_buf_sel,
        zig_rd_addr        => qua_rdaddr,
        zig_data           => qua_data,

        -- HOST
        qdata              => qdata,
        qaddr              => qaddr,
        qwren              => qwren
    );  
    
  -------------------------------------------------------------------
  -- RLE TOP
  -------------------------------------------------------------------
  U_RLE_TOP : entity work.RLE_TOP
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- CTRL
        start_pb           => rle_start,
        ready_pb           => rle_ready,
        rle_sm_settings    => rle_sm_settings,

        -- HUFFMAN
        huf_buf_sel        => huf_buf_sel,
        huf_rden           => huf_rden,
        huf_runlength      => huf_runlength,
        huf_size           => huf_size,
        huf_amplitude      => huf_amplitude,
        huf_dval           => huf_dval,
        huf_fifo_empty     => huf_fifo_empty,

        -- Quantizer
        qua_buf_sel        => rle_buf_sel,
        qua_rd_addr        => rle_rdaddr,
        qua_data           => rle_data,
        
        -- HostIF
        sof                => sof
    );
    
  -------------------------------------------------------------------
  -- Huffman Encoder
  -------------------------------------------------------------------
  U_Huffman : entity work.Huffman
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- CTRL
        start_pb           => huf_start,
        ready_pb           => huf_ready,
        huf_sm_settings    => huf_sm_settings,

        -- HOST IF
        sof                => sof,
        img_size_x         => img_size_x,
        img_size_y         => img_size_y,

        -- RLE
        rle_buf_sel        => huf_buf_sel,
        rd_en              => huf_rden,
        runlength          => huf_runlength,
        VLI_size           => huf_size,
        VLI                => huf_amplitude,
        d_val              => huf_dval,
        rle_fifo_empty     => huf_fifo_empty,
        
        -- Byte Stuffer
        bs_buf_sel         => bs_buf_sel,
        bs_fifo_empty      => bs_fifo_empty,
        bs_rd_req          => bs_rd_req,
        bs_packed_byte     => bs_packed_byte      
    );
    
  
  -------------------------------------------------------------------
  -- Byte Stuffer
  -------------------------------------------------------------------
  U_ByteStuffer : entity work.ByteStuffer
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- CTRL
        start_pb           => bs_start,
        ready_pb           => bs_ready,

        -- HOST IF
        sof                => sof,
        num_enc_bytes      => num_enc_bytes,
        outram_base_addr   => outram_base_addr,

        -- Huffman
        huf_buf_sel        => bs_buf_sel,
        huf_fifo_empty     => bs_fifo_empty,
        huf_rd_req         => bs_rd_req,
        huf_packed_byte    => bs_packed_byte,

        -- OUT RAM
        ram_byte           => bs_ram_byte,
        ram_wren           => bs_ram_wren,
        ram_wraddr         => bs_ram_wraddr
    );
    
  -------------------------------------------------------------------
  -- JFIF Generator
  -------------------------------------------------------------------
  U_JFIFGen : entity work.JFIFGen
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- CTRL
        start              => jfif_start,
        ready              => jfif_ready,
        eoi                => jfif_eoi,
        
        -- ByteStuffer
        num_enc_bytes         => num_enc_bytes,

        -- HOST IF
        qwren              => qwren,
        qwaddr             => qaddr,
        qwdata             => qdata,
        image_size_reg     => image_size_reg,
        image_size_reg_wr  => img_size_wr,

        -- OUT RAM
        ram_byte           => jfif_ram_byte,
        ram_wren           => jfif_ram_wren,
        ram_wraddr         => jfif_ram_wraddr
    );
    
  image_size_reg <= img_size_x & img_size_y;
  
  -------------------------------------------------------------------
  -- OutMux
  -------------------------------------------------------------------
  U_OutMux : entity work.OutMux
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- CTRL
        out_mux_ctrl       => out_mux_ctrl,

        -- ByteStuffer
        bs_ram_byte        => bs_ram_byte,
        bs_ram_wren        => bs_ram_wren,
        bs_ram_wraddr      => bs_ram_wraddr,
        -- ByteStuffer
        jfif_ram_byte      => jfif_ram_byte,
        jfif_ram_wren      => jfif_ram_wren,
        jfif_ram_wraddr    => jfif_ram_wraddr,

        -- OUT RAM
        ram_byte           => ram_byte,
        ram_wren           => ram_wren,
        ram_wraddr         => ram_wraddr
    );
    
    
end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------
