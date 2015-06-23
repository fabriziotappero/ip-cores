-------------------------------------------------------------------------------
-- File Name :  Huffman.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : Huffman
--
-- Content   : Huffman Encoder
--
-- Description : Huffman encoder core
--
-- Spec.     : 
--
-- Author    : Michal Krepa
--
-------------------------------------------------------------------------------
-- History :
-- 20090228: (MK): Initial Creation.
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
entity Huffman is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        -- CTRL
        start_pb           : in  std_logic;
        ready_pb           : out std_logic;
        huf_sm_settings    : in  T_SM_SETTINGS;
        
        -- HOST IF
        sof                : in  std_logic;
        img_size_x         : in  std_logic_vector(15 downto 0);
        img_size_y         : in  std_logic_vector(15 downto 0);
        
        -- RLE
        rle_buf_sel        : out std_logic;
        rd_en              : out std_logic;
        runlength          : in  std_logic_vector(3 downto 0);
        VLI_size           : in  std_logic_vector(3 downto 0);
        VLI                : in  std_logic_vector(11 downto 0);
        d_val              : in  std_logic;
        rle_fifo_empty     : in  std_logic;
     
        -- Byte Stuffer
        bs_buf_sel         : in  std_logic;
        bs_fifo_empty      : out std_logic;
        bs_rd_req          : in  std_logic;
        bs_packed_byte     : out std_logic_vector(7 downto 0)        
    );
end entity Huffman;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of Huffman is

  type T_STATE is (IDLE, RUN_VLC, RUN_VLI, PAD);
  
  constant C_M             : integer := 23;
  constant BLK_SIZE        : integer := 64;

  signal state             : T_STATE;
  signal rle_buf_sel_s     : std_logic;
  signal first_rle_word    : std_logic;
  signal word_reg          : unsigned(C_M-1 downto 0);
  signal bit_ptr           : unsigned(4 downto 0);
  signal num_fifo_wrs      : unsigned(1 downto 0);
  signal VLI_ext           : unsigned(15 downto 0);
  signal VLI_ext_size      : unsigned(4 downto 0);
  signal ready_HFW         : std_logic;
  signal fifo_wbyte        : std_logic_vector(7 downto 0);
  signal fifo_wrt_cnt      : unsigned(1 downto 0);
  signal fifo_wren         : std_logic;
  signal last_block        : std_logic;
  signal image_area_size   : unsigned(31 downto 0);
  signal block_cnt         : unsigned(27 downto 0);
  signal VLC_size          : unsigned(4 downto 0);
  signal VLC               : unsigned(15 downto 0);
  signal VLC_DC_size       : std_logic_vector(3 downto 0);
  signal VLC_DC            : unsigned(8 downto 0);
  signal VLC_AC_size       : unsigned(4 downto 0);
  signal VLC_AC            : unsigned(15 downto 0);
  signal vlc_vld           : std_logic;    
  signal d_val_d1          : std_logic;    
  signal d_val_d2          : std_logic;
  signal d_val_d3          : std_logic;
  signal d_val_d4          : std_logic;
  signal VLI_size_d        : std_logic_vector(3 downto 0);
  signal VLI_d             : std_logic_vector(11 downto 0);
  signal VLI_size_d1       : std_logic_vector(3 downto 0);
  signal VLI_d1            : std_logic_vector(11 downto 0);
  signal HFW_running       : std_logic;
  signal runlength_r       : std_logic_vector(3 downto 0);
  signal VLI_size_r        : std_logic_vector(3 downto 0);
  signal VLI_r             : std_logic_vector(11 downto 0);
  signal rd_en_s           : std_logic;
  signal pad_byte          : std_logic_vector(7 downto 0);
  signal pad_reg           : std_logic;
  signal VLC_CR_DC_size    : std_logic_vector(3 downto 0);
  signal VLC_CR_DC         : unsigned(10 downto 0);
  signal VLC_CR_AC_size    : unsigned(4 downto 0);
  signal VLC_CR_AC         : unsigned(15 downto 0);
  signal start_pb_d1       : std_logic;
  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin

  rle_buf_sel <= rle_buf_sel_s;
  
  rd_en   <= rd_en_s;
  vlc_vld <= rd_en_s;
  
  -------------------------------------------------------------------
  -- latch FIFO Q
  -------------------------------------------------------------------
  p_latch_fifo : process(CLK, RST)
  begin
    if RST = '1' then
      VLI_size_r  <= (others => '0');
      VLI_r       <= (others => '0');
    elsif CLK'event and CLK = '1' then
      if d_val = '1' then
        VLI_size_r  <= VLI_size; 
        VLI_r       <= VLI;            
      end if;
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- DC_ROM Luminance
  -------------------------------------------------------------------
  U_DC_ROM : entity work.DC_ROM
  port map
  (
        CLK                => CLK,
        RST                => RST,
        VLI_size           => VLI_size,
                           
        VLC_DC_size        => VLC_DC_size,
        VLC_DC             => VLC_DC
  );
    
  -------------------------------------------------------------------
  -- AC_ROM Luminance
  -------------------------------------------------------------------
  U_AC_ROM : entity work.AC_ROM
  port map
  (
        CLK                => CLK,
        RST                => RST,
        runlength          => runlength,
        VLI_size           => VLI_size,
                           
        VLC_AC_size        => VLC_AC_size,
        VLC_AC             => VLC_AC
    );
    
  -------------------------------------------------------------------
  -- DC_ROM Chrominance
  -------------------------------------------------------------------
  U_DC_CR_ROM : entity work.DC_CR_ROM
  port map
  (
        CLK                => CLK,
        RST                => RST,
        VLI_size           => VLI_size,
                           
        VLC_DC_size        => VLC_CR_DC_size,
        VLC_DC             => VLC_CR_DC
  );
    
  -------------------------------------------------------------------
  -- AC_ROM Chrominance
  -------------------------------------------------------------------
  U_AC_CR_ROM : entity work.AC_CR_ROM
  port map
  (
        CLK                => CLK,
        RST                => RST,
        runlength          => runlength,
        VLI_size           => VLI_size,
                           
        VLC_AC_size        => VLC_CR_AC_size,
        VLC_AC             => VLC_CR_AC
    );
   
  -------------------------------------------------------------------
  -- Double Fifo
  -------------------------------------------------------------------
  U_DoubleFifo : entity work.DoubleFifo
  port map
  (
        CLK                => CLK,
        RST                => RST,
        -- HUFFMAN
        data_in            => fifo_wbyte,
        wren               => fifo_wren,
        -- BYTE STUFFER
        buf_sel            => bs_buf_sel,
        rd_req             => bs_rd_req,
        fifo_empty         => bs_fifo_empty,
        data_out           => bs_packed_byte
    );
  
  -------------------------------------------------------------------
  -- RLE buf_sel
  -------------------------------------------------------------------
  p_rle_buf_sel : process(CLK, RST)
  begin
    if RST = '1' then
      rle_buf_sel_s   <= '0'; 
    elsif CLK'event and CLK = '1' then
      if start_pb = '1' then
        rle_buf_sel_s <= not rle_buf_sel_s;
      end if;
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- mux for DC/AC ROM Luminance/Chrominance
  -------------------------------------------------------------------
  p_mux : process(CLK, RST)
  begin
    if RST = '1' then
      VLC_size <= (others => '0');
      VLC      <= (others => '0');
    elsif CLK'event and CLK = '1' then
      -- DC
      if first_rle_word = '1' then
        -- luminance
        if huf_sm_settings.cmp_idx < 2 then
          VLC_size <= unsigned('0' & VLC_DC_size);
          VLC      <= resize(VLC_DC, VLC'length);
        -- chrominance
        else
          VLC_size <= unsigned('0' & VLC_CR_DC_size);
          VLC      <= resize(VLC_CR_DC, VLC'length);
        end if;
      -- AC
      else
        -- luminance
        if huf_sm_settings.cmp_idx < 2 then
          VLC_size <= VLC_AC_size;
          VLC      <= VLC_AC;
        -- chrominance
        else
          VLC_size <= VLC_CR_AC_size;
          VLC      <= VLC_CR_AC;
        end if;
      end if;
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- Block Counter / Last Block detector
  -------------------------------------------------------------------
  p_blk_cnt : process(CLK, RST)
  begin
    if RST = '1' then
      image_area_size <= (others => '0');
      last_block      <= '0';
    elsif CLK'event and CLK = '1' then
      image_area_size <= unsigned(img_size_x)*unsigned(img_size_y);
      
      if sof = '1' then
        block_cnt <= (others => '0');
      elsif start_pb = '1' then
        block_cnt <= block_cnt + 1;
      end if;
      
      if block_cnt = image_area_size(31 downto 5) then
        last_block <= '1';
      else
        last_block <= '0';
      end if;
      
    end if;
  end process;
  
  VLI_ext      <= unsigned("0000" & VLI_d1);
  VLI_ext_size <= unsigned('0' & VLI_size_d1);
  
  -------------------------------------------------------------------
  -- delay line
  -------------------------------------------------------------------
  p_vli_dly : process(CLK, RST)
  begin
    if RST = '1' then
      VLI_d       <= (others => '0');
      VLI_size_d  <= (others => '0');
      VLI_d1      <= (others => '0');
      VLI_size_d1 <= (others => '0');
      d_val_d1    <= '0';
      d_val_d2    <= '0';
      d_val_d3    <= '0';
      d_val_d4    <= '0';
    elsif CLK'event and CLK = '1' then
      VLI_d1      <= VLI_r;
      VLI_size_d1 <= VLI_size_r;
      
      VLI_d       <= VLI_d1;
      VLI_size_d  <= VLI_size_d1;
      
      d_val_d1   <= d_val;
      d_val_d2   <= d_val_d1;
      d_val_d3   <= d_val_d2;
      d_val_d4   <= d_val_d3;
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- HandleFifoWrites
  -------------------------------------------------------------------
  p_HandleFifoWrites : process(CLK, RST)
  begin
    if RST = '1' then
      ready_HFW    <= '0';
      fifo_wrt_cnt <= (others => '0');
      fifo_wren    <= '0';
      fifo_wbyte   <= (others => '0');
      rd_en_s      <= '0';
      start_pb_d1  <= '0';
    elsif CLK'event and CLK = '1' then
      fifo_wren <= '0';
      ready_HFW <= '0';
      rd_en_s   <= '0';
      start_pb_d1 <= start_pb;
      
      if start_pb_d1 = '1' then
        rd_en_s     <= '1' and not rle_fifo_empty;
      end if;
    
      if HFW_running = '1' and ready_HFW = '0' then
        -- there is no at least one integer byte to write this time
        if num_fifo_wrs = 0 then
          ready_HFW    <= '1';
          if state = RUN_VLI then
            rd_en_s      <= '1' and not rle_fifo_empty;
          end if;
        -- single byte write to FIFO
        else
          fifo_wrt_cnt <= fifo_wrt_cnt + 1;
          fifo_wren    <= '1';
          -- last byte write
          if fifo_wrt_cnt + 1 = num_fifo_wrs then
            ready_HFW    <= '1';
            if state = RUN_VLI then
              rd_en_s      <= '1' and not rle_fifo_empty;
            end if;
            fifo_wrt_cnt <= (others => '0');
          end if;
        end if;
      end if;
      
      case fifo_wrt_cnt is 
        when "00" =>
          fifo_wbyte <= std_logic_vector(word_reg(C_M-1 downto C_M-8));
        when "01" =>
          fifo_wbyte <= std_logic_vector(word_reg(C_M-8-1 downto C_M-16));            
        when others =>
          fifo_wbyte <= (others => '0');
      end case;
      if pad_reg = '1' then
        fifo_wbyte <= pad_byte;
      end if;

          
    end if;
  end process;
  
  -- divide by 8
  num_fifo_wrs <= bit_ptr(4 downto 3);
  
  -------------------------------------------------------------------
  -- Variable Length Processor FSM
  -------------------------------------------------------------------
  p_vlp : process(CLK, RST)
  begin
    if RST = '1' then
      ready_pb     <= '0';
      first_rle_word <= '0';
      state        <= IDLE;
      word_reg     <= (others => '0');
      bit_ptr      <= (others => '0');
      HFW_running  <= '0';
      pad_reg      <= '0';
      pad_byte     <= (others => '0');
    elsif CLK'event and CLK = '1' then
      ready_pb  <= '0';
    
      case state is
      
        when IDLE =>
          if start_pb = '1' then
            first_rle_word <= '1';
            state       <= RUN_VLC;
          end if;
        
        when RUN_VLC =>
          -- data valid DC or data valid AC
          if (d_val_d1 = '1' and first_rle_word = '1') or 
             (d_val = '1' and first_rle_word = '0') then
            for i in 0 to C_M-1 loop
              if i < to_integer(VLC_size) then
                word_reg(C_M-1-to_integer(bit_ptr)-i) <= VLC(to_integer(VLC_size)-1-i);
              end if;
            end loop;
            bit_ptr <= bit_ptr + resize(VLC_size,bit_ptr'length);
            
            -- HandleFifoWrites
            HFW_running  <= '1';
          -- HandleFifoWrites completed
          elsif HFW_running = '1' and 
                (num_fifo_wrs = 0 or fifo_wrt_cnt + 1 = num_fifo_wrs) then
            -- shift word reg left to skip bytes already written to FIFO
            word_reg <= shift_left(word_reg, to_integer(num_fifo_wrs & "000"));
            -- adjust bit pointer after some bytes were written to FIFO
            -- modulo 8 operation
            bit_ptr <= bit_ptr - (num_fifo_wrs & "000"); 
            HFW_running     <= '0';
            first_rle_word  <= '0';
            state           <= RUN_VLI;
          end if;
        
        when RUN_VLI =>
          if HFW_running = '0' then
            
            for i in 0 to C_M-1 loop
              if i < to_integer(VLI_ext_size) then
                word_reg(C_M-1-to_integer(bit_ptr)-i)
                  <= VLI_ext(to_integer(VLI_ext_size)-1-i);
              end if;
            end loop;
              
            bit_ptr <= bit_ptr + resize(VLI_ext_size,bit_ptr'length);
            
            -- HandleFifoWrites
            HFW_running <= '1';
          -- HandleFifoWrites completed
          elsif HFW_running = '1' and 
                (num_fifo_wrs = 0 or fifo_wrt_cnt + 1 = num_fifo_wrs) then
            -- shift word reg left to skip bytes already written to FIFO
            word_reg <= shift_left(word_reg, to_integer(num_fifo_wrs & "000"));
            -- adjust bit pointer after some bytes were written to FIFO
            -- modulo 8 operation
            bit_ptr <= bit_ptr - (num_fifo_wrs & "000"); 
            HFW_running <= '0';
            
            -- end of block
            if rle_fifo_empty = '1' then
              -- end of segment
              if bit_ptr - (num_fifo_wrs & "000") /= 0 and last_block = '1' then
                state <= PAD;  
              else
                ready_pb <= '1';
                state    <= IDLE;
              end if;
            else
              state          <= RUN_VLC;
            end if;
          end if;
          
        -- end of segment which requires bit padding
        when PAD =>
          if HFW_running = '0' then
            -- 1's bit padding to integer number of bytes
            for i in 0 to 7 loop
              if i < bit_ptr then
                pad_byte(7-i) <= word_reg(C_M-1-i);
              else
                pad_byte(7-i) <= '1';
              end if;
            end loop;
            pad_reg <= '1';
            
            bit_ptr <= to_unsigned(8, bit_ptr'length);         

            -- HandleFifoWrites
            HFW_running <= '1';
         elsif HFW_running = '1' and 
                (num_fifo_wrs = 0 or fifo_wrt_cnt + 1 = num_fifo_wrs) then
           bit_ptr      <= (others => '0');
           HFW_running  <= '0';
           pad_reg      <= '0';

           ready_pb <= '1';
           state <= IDLE;
         end if;
        
        when others =>
        
      end case;
      
      if sof = '1' then
        bit_ptr <= (others => '0');
      end if;
      
    end if;
  end process;


end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------