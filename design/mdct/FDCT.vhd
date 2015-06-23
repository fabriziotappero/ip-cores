-------------------------------------------------------------------------------
-- File Name :  FDCT.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : FDCT
--
-- Content   : FDCT
--
-- Description : 2D Discrete Cosine Transform
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
entity FDCT is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        -- CTRL
        start_pb           : in  std_logic;
        ready_pb           : out std_logic;
        fdct_sm_settings   : in  T_SM_SETTINGS;
        
        -- BUF_FIFO
        bf_fifo_rd         : out std_logic;
        bf_fifo_q          : in  std_logic_vector(23 downto 0);
        bf_fifo_hf_full    : in  std_logic;
        
        -- ZIG ZAG
        zz_buf_sel         : in  std_logic;
        zz_rd_addr         : in  std_logic_vector(5 downto 0);
        zz_data            : out std_logic_vector(11 downto 0);
        zz_rden            : in  std_logic;
        
        -- HOST
        img_size_x         : in  std_logic_vector(15 downto 0);
        img_size_y         : in  std_logic_vector(15 downto 0);
        sof                : in  std_logic        
    );
end entity FDCT;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of FDCT is
  
  constant C_Y_1       : signed(14 downto 0) := to_signed(4899,  15);
  constant C_Y_2       : signed(14 downto 0) := to_signed(9617,  15);
  constant C_Y_3       : signed(14 downto 0) := to_signed(1868,  15);
  constant C_Cb_1      : signed(14 downto 0) := to_signed(-2764, 15);
  constant C_Cb_2      : signed(14 downto 0) := to_signed(-5428, 15);
  constant C_Cb_3      : signed(14 downto 0) := to_signed(8192,  15);
  constant C_Cr_1      : signed(14 downto 0) := to_signed(8192,  15);
  constant C_Cr_2      : signed(14 downto 0) := to_signed(-6860, 15);
  constant C_Cr_3      : signed(14 downto 0) := to_signed(-1332, 15);
  

  signal mdct_data_in      : std_logic_vector(7 downto 0);
  signal mdct_idval        : std_logic;
  signal mdct_odval        : std_logic;
  signal mdct_data_out     : std_logic_vector(11 downto 0);
  signal odv1              : std_logic;
  signal dcto1             : std_logic_vector(11 downto 0);
  signal x_pixel_cnt       : unsigned(15 downto 0);
  signal y_line_cnt        : unsigned(15 downto 0);
  signal rd_addr           : std_logic_vector(31 downto 0);
  signal input_rd_cnt      : unsigned(6 downto 0);
  signal rd_en             : std_logic;
  signal rd_en_d1          : std_logic;
  signal rdaddr            : unsigned(31 downto 0);
  signal bf_dval           : std_logic;
  signal bf_dval_m1        : std_logic;
  signal bf_dval_m2        : std_logic;
  signal bf_dval_m3        : std_logic;
  signal wr_cnt            : unsigned(5 downto 0);
  signal dbuf_data         : std_logic_vector(11 downto 0);
  signal dbuf_q            : std_logic_vector(11 downto 0);
  signal dbuf_we           : std_logic;
  signal dbuf_waddr        : std_logic_vector(6 downto 0);
  signal dbuf_raddr        : std_logic_vector(6 downto 0);
  signal xw_cnt            : unsigned(2 downto 0);
  signal yw_cnt            : unsigned(2 downto 0);
                           
  signal dbuf_q_z1         : std_logic_vector(11 downto 0);
  constant C_SIMA_ASZ      : integer := 9;
  signal sim_rd_addr       : unsigned(C_SIMA_ASZ-1 downto 0);
  signal Y_reg_1           : signed(23 downto 0);
  signal Y_reg_2           : signed(23 downto 0);
  signal Y_reg_3           : signed(23 downto 0);
  signal Cb_reg_1          : signed(23 downto 0);
  signal Cb_reg_2          : signed(23 downto 0);
  signal Cb_reg_3          : signed(23 downto 0);
  signal Cr_reg_1          : signed(23 downto 0);
  signal Cr_reg_2          : signed(23 downto 0);
  signal Cr_reg_3          : signed(23 downto 0);
  signal Y_reg             : signed(23 downto 0);
  signal Cb_reg            : signed(23 downto 0);
  signal Cr_reg            : signed(23 downto 0);
  signal R_s               : signed(8 downto 0);
  signal G_s               : signed(8 downto 0);
  signal B_s               : signed(8 downto 0);
  signal Y_8bit            : unsigned(7 downto 0);
  signal Cb_8bit           : unsigned(7 downto 0);
  signal Cr_8bit           : unsigned(7 downto 0);
  signal cmp_idx           : unsigned(2 downto 0);
  signal cur_cmp_idx       : unsigned(2 downto 0);
  signal cur_cmp_idx_d1    : unsigned(2 downto 0);
  signal cur_cmp_idx_d2    : unsigned(2 downto 0);
  signal cur_cmp_idx_d3    : unsigned(2 downto 0);
  signal cur_cmp_idx_d4    : unsigned(2 downto 0);
  signal cur_cmp_idx_d5    : unsigned(2 downto 0);
  signal cur_cmp_idx_d6    : unsigned(2 downto 0);
  signal cur_cmp_idx_d7    : unsigned(2 downto 0);
  signal cur_cmp_idx_d8    : unsigned(2 downto 0);
  signal cur_cmp_idx_d9    : unsigned(2 downto 0);
  signal fifo1_rd          : std_logic;
  signal fifo1_wr          : std_logic;
  signal fifo1_q           : std_logic_vector(11 downto 0);
  signal fifo1_full        : std_logic;
  signal fifo1_empty       : std_logic;
  signal fifo1_count       : std_logic_vector(9 downto 0);
  signal fifo1_rd_cnt      : unsigned(5 downto 0);
  signal fifo1_q_dval      : std_logic;
  signal fifo_data_in      : std_logic_vector(11 downto 0);
  signal fifo_rd_arm       : std_logic;
  
  signal eoi_fdct          : std_logic;
  signal bf_fifo_rd_s      : std_logic;
  signal start_int         : std_logic;
  signal start_int_d       : std_logic_vector(4 downto 0);
  
  signal fram1_data        : std_logic_vector(23 downto 0);
  signal fram1_q           : std_logic_vector(23 downto 0);
  signal fram1_we          : std_logic;
  signal fram1_waddr       : std_logic_vector(6 downto 0);
  signal fram1_raddr       : std_logic_vector(6 downto 0);
  signal fram1_rd_d        : std_logic_vector(8 downto 0);
  signal fram1_rd          : std_logic;  
  signal rd_started        : std_logic;
  signal writing_en        : std_logic;
  signal fram1_q_vld       : std_logic;
  
  signal fram1_line_cnt    : unsigned(2 downto 0);
  signal fram1_pix_cnt     : unsigned(2 downto 0);
  
  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin

  zz_data      <= dbuf_q;
  
  bf_fifo_rd   <= bf_fifo_rd_s;
  
  -------------------------------------------------------------------
  -- FRAM1
  -------------------------------------------------------------------
  U_FRAM1 : entity work.RAMZ
  generic map
  ( 
      RAMADDR_W     => 7,
      RAMDATA_W     => 24
  )
  port map
  (      
        d           => fram1_data,
        waddr       => fram1_waddr,
        raddr       => fram1_raddr,
        we          => fram1_we,
        clk         => CLK,
                    
        q           => fram1_q
  );
  
  fram1_we   <= bf_dval;
  fram1_data <= bf_fifo_q;
  
  fram1_q_vld <= fram1_rd_d(5);
  
  -------------------------------------------------------------------
  -- FRAM1 process
  -------------------------------------------------------------------
  p_fram1_acc : process(CLK, RST)
  begin
    if RST = '1' then
      fram1_waddr <= (others => '0');
    elsif CLK'event and CLK = '1' then
      if fram1_we = '1' then
        fram1_waddr <= std_logic_vector(unsigned(fram1_waddr) + 1);
      end if;
    end if;
  end process;

  -------------------------------------------------------------------
  -- IRAM read process 
  -------------------------------------------------------------------
  p_counter1 : process(CLK, RST)
  begin
    if RST = '1' then
      rd_en           <= '0';
      rd_en_d1        <= '0';
      x_pixel_cnt     <= (others => '0');
      y_line_cnt     <= (others => '0');
      input_rd_cnt    <= (others => '0');
      cmp_idx         <= (others => '0');
      cur_cmp_idx     <= (others => '0');
      cur_cmp_idx_d1  <= (others => '0');
      cur_cmp_idx_d2  <= (others => '0');
      cur_cmp_idx_d3  <= (others => '0');
      cur_cmp_idx_d4  <= (others => '0');
      cur_cmp_idx_d5  <= (others => '0');
      cur_cmp_idx_d6  <= (others => '0');
      cur_cmp_idx_d7  <= (others => '0');
      cur_cmp_idx_d8  <= (others => '0');
      cur_cmp_idx_d9  <= (others => '0');
      eoi_fdct        <= '0';
      start_int       <= '0';
      bf_fifo_rd_s    <= '0';
      bf_dval         <= '0';
      bf_dval_m1      <= '0';
      bf_dval_m2      <= '0';
      fram1_rd        <= '0';
      fram1_rd_d      <= (others => '0');
      start_int_d     <= (others => '0');
      fram1_raddr     <= (others => '0');
      fram1_line_cnt  <= (others => '0');
      fram1_pix_cnt   <= (others => '0');
    elsif CLK'event and CLK = '1' then
      rd_en_d1 <= rd_en;
      cur_cmp_idx_d1 <= cur_cmp_idx;
      cur_cmp_idx_d2 <= cur_cmp_idx_d1;
      cur_cmp_idx_d3 <= cur_cmp_idx_d2;
      cur_cmp_idx_d4 <= cur_cmp_idx_d3;
      cur_cmp_idx_d5 <= cur_cmp_idx_d4;
      cur_cmp_idx_d6 <= cur_cmp_idx_d5;
      cur_cmp_idx_d7 <= cur_cmp_idx_d6;
      cur_cmp_idx_d8 <= cur_cmp_idx_d7;
      cur_cmp_idx_d9 <= cur_cmp_idx_d8;
      start_int      <= '0';
      
      bf_dval_m3     <= bf_fifo_rd_s;
      bf_dval_m2     <= bf_dval_m3;
      bf_dval_m1     <= bf_dval_m2;
      bf_dval        <= bf_dval_m1;
      
      fram1_rd_d     <= fram1_rd_d(fram1_rd_d'length-2 downto 0) & fram1_rd;
      start_int_d    <= start_int_d(start_int_d'length-2 downto 0) & start_int;
    
      -- SOF or internal self-start
      if (sof = '1' or start_int = '1') then
        input_rd_cnt <= (others => '0');
        -- enable BUF_FIFO/FRAM1 reading
        rd_started      <= '1'; 
        
        -- component index
        if cmp_idx = 4-1 then
          cmp_idx <= (others => '0');
          -- horizontal block counter
          if x_pixel_cnt = unsigned(img_size_x)-16 then
            x_pixel_cnt <= (others => '0');
            -- vertical block counter
            if y_line_cnt = unsigned(img_size_y)-8 then
              y_line_cnt <= (others => '0');
              -- set end of image flag
              eoi_fdct <= '1';    
            else
              y_line_cnt <= y_line_cnt + 8;
            end if;
          else
            x_pixel_cnt <= x_pixel_cnt + 16;
          end if;
        else
          cmp_idx <=cmp_idx + 1;
        end if;
        
        cur_cmp_idx     <= cmp_idx;
        
      end if;
      
      -- wait until FIFO becomes half full but only for component 0
      -- as we read buf FIFO only during component 0
      if rd_started = '1' and (bf_fifo_hf_full = '1' or cur_cmp_idx > 1) then
        rd_en      <= '1';
        rd_started <= '0';
      end if;
      
      bf_fifo_rd_s   <= '0';
      fram1_rd       <= '0';
      -- stall reading from input FIFO and writing to output FIFO 
      -- when output FIFO is almost full
      if rd_en = '1' and unsigned(fifo1_count) < 512-64 and 
         (bf_fifo_hf_full = '1' or cur_cmp_idx > 1) then
        -- read request goes to BUF_FIFO only for component 0. 
        if cur_cmp_idx < 2 then 
          bf_fifo_rd_s <= '1';
        end if;
        
        -- count number of samples read from input in one run
        if input_rd_cnt = 64-1 then
          rd_en        <= '0';
          -- internal restart
          start_int    <= '1' and not eoi_fdct;
          eoi_fdct     <= '0';
        else
          input_rd_cnt <= input_rd_cnt + 1;
        end if;
        -- FRAM read enable
        fram1_rd <= '1';
      end if;

      -- increment FRAM1 read address according to subsampling
      -- idea is to extract 8x8 from 16x8 block
      -- there are two luminance blocks left and right
      -- there is 2:1 subsampled Cb block
      -- there is 2:1 subsampled Cr block
      -- subsampling done as simple decimation by 2 wo/ averaging
      if sof = '1' then
        fram1_raddr     <= (others => '0');
        fram1_line_cnt  <= (others => '0');
        fram1_pix_cnt   <= (others => '0');
      elsif start_int_d(4) = '1' then
        fram1_line_cnt  <= (others => '0');
        fram1_pix_cnt   <= (others => '0');
        case cur_cmp_idx_d4 is
          -- Y1, Cr, Cb
          when "000" | "010" | "011" => 
            fram1_raddr <= (others => '0');
          -- Y2
          when "001" => 
            fram1_raddr <= std_logic_vector(to_unsigned(64, fram1_raddr'length));
          when others =>
            null;
        end case;
      elsif fram1_rd_d(4) = '1' then 
      
        if fram1_pix_cnt = 8-1 then
          fram1_pix_cnt <= (others => '0');
          if fram1_line_cnt = 8-1 then
            fram1_line_cnt <= (others => '0');
          else
            fram1_line_cnt <= fram1_line_cnt + 1;
          end if;
        else
          fram1_pix_cnt <= fram1_pix_cnt + 1;
        end if;
        
        case cur_cmp_idx_d6 is
          when "000" | "001" => 
            fram1_raddr <= std_logic_vector(unsigned(fram1_raddr) + 1);
          when "010" | "011" => 
            if fram1_pix_cnt = 4-1 then
              fram1_raddr <= std_logic_vector('1' & fram1_line_cnt & "000");
            elsif fram1_pix_cnt = 8-1 then
              if fram1_line_cnt = 8-1 then
                fram1_raddr <= '0' & "000" & "000";
              else
                fram1_raddr <= std_logic_vector('0' & (fram1_line_cnt+1) & "000");
              end if;
            else
              fram1_raddr <= std_logic_vector(unsigned(fram1_raddr) + 2);
            end if;
          when others =>
            null;
        end case;
      
      end if;
      
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- FDCT with input level shift
  -------------------------------------------------------------------
  U_MDCT : entity work.MDCT
	port map
  (	  
		clk          => CLK,
		rst          => RST,
    dcti         => mdct_data_in,
    idv          => mdct_idval,
    odv          => mdct_odval,
    dcto         => mdct_data_out,
    odv1         => odv1,
    dcto1        => dcto1
	); 
  
  mdct_idval   <= fram1_rd_d(8);
  
  R_s <= signed('0' & fram1_q(7 downto 0));
  G_s <= signed('0' & fram1_q(15 downto 8));
  B_s <= signed('0' & fram1_q(23 downto 16));
  
  -------------------------------------------------------------------
  -- Mux1
  -------------------------------------------------------------------
  p_mux1 : process(CLK, RST)
  begin
    if RST = '1' then
      mdct_data_in <= (others => '0');
    elsif CLK'event and CLK = '1' then
      case cur_cmp_idx_d9 is
        when "000" | "001" => 
          mdct_data_in <= std_logic_vector(Y_8bit);
        when "010" => 
          mdct_data_in <= std_logic_vector(Cb_8bit);
        when "011" => 
          mdct_data_in <= std_logic_vector(Cr_8bit);
        when others =>
          null;
      end case;
    end if;
  end process;

  
  -------------------------------------------------------------------
  -- FIFO1
  -------------------------------------------------------------------
  U_FIFO1 : entity work.FIFO   
  generic map
  (
        DATA_WIDTH        => 12,
        ADDR_WIDTH        => 9
  )
  port map 
  (        
        rst               => RST,
        clk               => CLK,
        rinc              => fifo1_rd,
        winc              => fifo1_wr,
        datai             => fifo_data_in,

        datao             => fifo1_q,
        fullo             => fifo1_full,
        emptyo            => fifo1_empty,
        count             => fifo1_count
  );
  
  fifo1_wr     <= mdct_odval;
  fifo_data_in <= mdct_data_out;
  
  
  
  -------------------------------------------------------------------
  -- FIFO1 rd controller
  -------------------------------------------------------------------
  p_fifo_rd_ctrl : process(CLK, RST)
  begin
    if RST = '1' then
      fifo1_rd     <= '0';
      fifo_rd_arm  <= '0';
      fifo1_rd_cnt <= (others => '0');
      fifo1_q_dval <= '0';
    elsif CLK'event and CLK = '1' then
      fifo1_rd     <= '0';
      
      fifo1_q_dval <= fifo1_rd;
    
      if start_pb = '1' then
        fifo_rd_arm  <= '1';
        fifo1_rd_cnt <= (others => '0');
      end if;
      
      if fifo_rd_arm = '1' then
      
        if fifo1_rd_cnt = 64-1 then
          fifo_rd_arm  <= '0';
          fifo1_rd     <= '1';
        elsif fifo1_empty = '0' then
          fifo1_rd     <= '1';
          fifo1_rd_cnt <= fifo1_rd_cnt + 1;
        end if;
      
      end if;
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- write counter
  -------------------------------------------------------------------
  p_wr_cnt : process(CLK, RST)
  begin
    if RST = '1' then
      wr_cnt   <= (others => '0');
      ready_pb <= '0';
      xw_cnt   <= (others => '0');
      yw_cnt   <= (others => '0');
      writing_en <= '0';
    elsif CLK'event and CLK = '1' then
      ready_pb <= '0';
    
      if start_pb = '1' then
        wr_cnt <= (others => '0');
        xw_cnt <= (others => '0');
        yw_cnt <= (others => '0');
        writing_en  <= '1';
      end if;
      
      if writing_en = '1' then
        if fifo1_q_dval = '1' then
          if wr_cnt = 64-1 then
            wr_cnt <= (others => '0');
            ready_pb <= '1';
            writing_en <= '0';
          else
            wr_cnt <= wr_cnt + 1;
          end if;
          
          if yw_cnt = 8-1 then
            yw_cnt <= (others => '0');
            xw_cnt <= xw_cnt+1;
          else
            yw_cnt <= yw_cnt+1;
          end if;
        end if;
      end if;
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- RGB to YCbCr conversion
  -------------------------------------------------------------------
  p_rgb2ycbcr : process(CLK, RST)
  begin
    if RST = '1' then
      Y_Reg_1  <= (others => '0');
      Y_Reg_2  <= (others => '0');
      Y_Reg_3  <= (others => '0');
      Cb_Reg_1 <= (others => '0');
      Cb_Reg_2 <= (others => '0');
      Cb_Reg_3 <= (others => '0');
      Cr_Reg_1 <= (others => '0');
      Cr_Reg_2 <= (others => '0');
      Cr_Reg_3 <= (others => '0');
      Y_Reg    <= (others => '0');
      Cb_Reg   <= (others => '0');
      Cr_Reg   <= (others => '0');
    elsif CLK'event and CLK = '1' then
      -- RGB input
      if C_YUV_INPUT = '0' then
        Y_Reg_1  <= R_s*C_Y_1;
        Y_Reg_2  <= G_s*C_Y_2;
        Y_Reg_3  <= B_s*C_Y_3;
        
        Cb_Reg_1 <= R_s*C_Cb_1;
        Cb_Reg_2 <= G_s*C_Cb_2;
        Cb_Reg_3 <= B_s*C_Cb_3;
        
        Cr_Reg_1 <= R_s*C_Cr_1;
        Cr_Reg_2 <= G_s*C_Cr_2;
        Cr_Reg_3 <= B_s*C_Cr_3;
        
        Y_Reg  <= Y_Reg_1 + Y_Reg_2 + Y_Reg_3;
        Cb_Reg <= Cb_Reg_1 + Cb_Reg_2 + Cb_Reg_3 + to_signed(128*16384,Cb_Reg'length);
        Cr_Reg <= Cr_Reg_1 + Cr_Reg_2 + Cr_Reg_3 + to_signed(128*16384,Cr_Reg'length);
      -- YCbCr input
      -- R-G-B misused as Y-Cb-Cr
      else
        Y_Reg_1  <= '0' & R_s & "00000000000000";
        Cb_Reg_1 <= '0' & G_s & "00000000000000";
        Cr_Reg_1 <= '0' & B_s & "00000000000000";
        
        Y_Reg  <= Y_Reg_1; 
        Cb_Reg <= Cb_Reg_1;
        Cr_Reg <= Cr_Reg_1;
      end if;
    end if;
  end process;
  
  Y_8bit  <= unsigned(Y_Reg(21 downto 14));
  Cb_8bit <= unsigned(Cb_Reg(21 downto 14));
  Cr_8bit <= unsigned(Cr_Reg(21 downto 14));
  
  
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
  
  dbuf_data  <= fifo1_q;
  dbuf_we    <= fifo1_q_dval;
  dbuf_waddr <= (not zz_buf_sel) & std_logic_vector(yw_cnt & xw_cnt);
  dbuf_raddr <= zz_buf_sel & zz_rd_addr;

end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------