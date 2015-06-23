--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2009                                --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- Title       : RLE                                                          --
-- Design      : MDCT CORE                                                    --
-- Author      : Michal Krepa                                                 --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- File        : RLE.VHD                                                      --
-- Created     : Wed Mar 04 2009                                              --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
--  Description : Run Length Encoder                                          --
--                Baseline Entropy Coding                                     --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.All;
  use IEEE.NUMERIC_STD.all;
  
library work;
  use work.JPEG_PKG.all;
  
entity rle is
  generic 
    ( 
      RAMADDR_W     : INTEGER := 6;
      RAMDATA_W     : INTEGER := 12
    ); 
  port
    (
      rst        : in  STD_LOGIC;
      clk        : in  STD_LOGIC;
      di         : in  STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
      start_pb   : in  std_logic;
      sof        : in  std_logic;
      rle_sm_settings : in T_SM_SETTINGS;
      
      runlength  : out STD_LOGIC_VECTOR(3 downto 0);
      size       : out STD_LOGIC_VECTOR(3 downto 0);
      amplitude  : out STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
      dovalid    : out STD_LOGIC;
      rd_addr    : out STD_LOGIC_VECTOR(5 downto 0)
    );
end rle;

architecture rtl of rle is
  

  
  constant SIZE_REG_C      : INTEGER := 4;
  constant ZEROS_32_C      : UNSIGNED(31 downto 0) := (others => '0');
  
  signal prev_dc_reg_0   : SIGNED(RAMDATA_W-1 downto 0);
  signal prev_dc_reg_1   : SIGNED(RAMDATA_W-1 downto 0);
  signal prev_dc_reg_2   : SIGNED(RAMDATA_W-1 downto 0);
  signal prev_dc_reg_3   : SIGNED(RAMDATA_W-1 downto 0);
  signal acc_reg         : SIGNED(RAMDATA_W downto 0);
  signal size_reg        : UNSIGNED(SIZE_REG_C-1 downto 0); 
  signal ampli_vli_reg   : SIGNED(RAMDATA_W downto 0);
  signal runlength_reg   : UNSIGNED(3 downto 0);   
  signal dovalid_reg     : STD_LOGIC;
  signal zero_cnt        : unsigned(5 downto 0);
  signal wr_cnt_d1       : unsigned(5 downto 0);
  signal wr_cnt          : unsigned(5 downto 0);
  
  signal rd_cnt         : unsigned(5 downto 0);
  signal rd_en          : std_logic;
  
  signal divalid        : STD_LOGIC;
  signal divalid_en     : std_logic;
  signal zrl_proc       : std_logic;
  signal zrl_di         : STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
begin

  size      <= STD_LOGIC_VECTOR(size_reg);
  amplitude <= STD_LOGIC_VECTOR(ampli_vli_reg(11 downto 0));
  
  rd_addr <= STD_LOGIC_VECTOR(rd_cnt);
  
  -------------------------------------------
  -- MAIN PROCESSING
  -------------------------------------------
  process(clk,rst)
  begin
    if rst = '1' then
      wr_cnt_d1       <= (others => '0');
      prev_dc_reg_0   <= (others => '0');
      prev_dc_reg_1   <= (others => '0');
      prev_dc_reg_2   <= (others => '0');
      prev_dc_reg_3   <= (others => '0');
      dovalid_reg     <= '0';
      acc_reg         <= (others => '0');
      runlength_reg   <= (others => '0');
      runlength       <= (others => '0');
      dovalid         <= '0';
      zero_cnt        <= (others => '0');
      zrl_proc        <= '0';
      rd_en           <= '0';
      rd_cnt          <= (others => '0');
      divalid_en      <= '0';
    elsif clk = '1' and clk'event then
      dovalid_reg     <= '0';
      runlength_reg   <= (others => '0');
      wr_cnt_d1       <= wr_cnt;
      runlength       <= std_logic_vector(runlength_reg);
      dovalid         <= dovalid_reg;
      divalid         <= rd_en;
      
      if start_pb = '1' then
        rd_cnt     <= (others => '0');
        rd_en      <= '1';    
        divalid_en <= '1';
      end if;
      
      if divalid = '1' and wr_cnt = 63 then
        divalid_en <= '0';
      end if;
      
      -- input read enable
      if rd_en = '1' then
        if rd_cnt = 64-1 then
          rd_cnt <= (others => '0');
          rd_en  <= '0';
        else
          rd_cnt <= rd_cnt + 1;
        end if;
      end if;

      -- input data valid
      if divalid = '1' then
        wr_cnt <= wr_cnt + 1;
      
        -- first DCT coefficient received, DC data
        if wr_cnt = 0 then
          -- differental coding of DC data per component
          case rle_sm_settings.cmp_idx is
            when "000" | "001" =>
              acc_reg <= RESIZE(SIGNED(di),RAMDATA_W+1) - RESIZE(prev_dc_reg_0,RAMDATA_W+1);
              prev_dc_reg_0 <= SIGNED(di);
            when "010" =>
              acc_reg <= RESIZE(SIGNED(di),RAMDATA_W+1) - RESIZE(prev_dc_reg_1,RAMDATA_W+1);
              prev_dc_reg_1 <= SIGNED(di);
            when "011" =>
              acc_reg <= RESIZE(SIGNED(di),RAMDATA_W+1) - RESIZE(prev_dc_reg_2,RAMDATA_W+1);
              prev_dc_reg_2 <= SIGNED(di);
            when others =>
              null;
          end case;
          runlength_reg    <= (others => '0');
          dovalid_reg      <= '1';
        -- AC coefficient
        else
          -- zero AC
          if signed(di) = 0 then
            -- EOB
            if wr_cnt = 63 then
              acc_reg          <= (others => '0');
              runlength_reg    <= (others => '0');
              dovalid_reg      <= '1';
            -- no EOB
            else
              zero_cnt <= zero_cnt + 1;
            end if;
          -- non-zero AC
          else
            -- normal RLE case
            if zero_cnt <= 15 then
              acc_reg        <= RESIZE(SIGNED(di),RAMDATA_W+1);
              runlength_reg  <= zero_cnt(3 downto 0);
              zero_cnt       <= (others => '0');
              dovalid_reg    <= '1';
            -- zero_cnt > 15
            else
              -- generate ZRL
              acc_reg        <= (others => '0');
              runlength_reg  <= X"F";
              zero_cnt       <= zero_cnt - 16;
              dovalid_reg    <= '1';
              -- stall input until ZRL is handled
              zrl_proc       <= '1';
              zrl_di         <= di;
              divalid <= '0';
              rd_cnt  <= rd_cnt;
            end if;
          end if;
        end if;
      end if;
      
      -- ZRL processing
      if zrl_proc = '1' then
        if zero_cnt <= 15 then
          acc_reg        <= RESIZE(SIGNED(zrl_di),RAMDATA_W+1);
          runlength_reg  <= zero_cnt(3 downto 0);
          if signed(zrl_di) = 0 then
            zero_cnt     <= to_unsigned(1,zero_cnt'length);
          else
            zero_cnt     <= (others => '0');
          end if;
          dovalid_reg    <= '1';
          divalid <= divalid_en;
          -- continue input handling
          zrl_proc <= '0';
        -- zero_cnt > 15
        else
          -- generate ZRL
          acc_reg        <= (others => '0');
          runlength_reg  <= X"F";
          zero_cnt       <= zero_cnt - 16;
          dovalid_reg    <= '1';
          divalid <= '0';
          rd_cnt <= rd_cnt;
        end if;     
      end if;
      
      -- start of 8x8 block processing
      if start_pb = '1' then
        zero_cnt <= (others => '0');
        wr_cnt   <= (others => '0');
      end if;
      
      if sof = '1' then
        prev_dc_reg_0 <= (others => '0');
        prev_dc_reg_1 <= (others => '0');
        prev_dc_reg_2 <= (others => '0');
        prev_dc_reg_3 <= (others => '0');
      end if;

    end if;
  end process;   
  
  -------------------------------------------------------------------
  -- Entropy Coder
  -------------------------------------------------------------------
  p_entropy_coder : process(CLK, RST)
  begin
    if RST = '1' then
      ampli_vli_reg <= (others => '0');
      size_reg      <= (others => '0');
    elsif CLK'event and CLK = '1' then
      -- perform VLI (variable length integer) encoding for Symbol-2 (Amplitude)
      -- positive input
      if acc_reg >= 0 then
        ampli_vli_reg <= acc_reg;
      else
        ampli_vli_reg <= acc_reg - TO_SIGNED(1,RAMDATA_W+1);
      end if;
      
      -- compute Symbol-1 Size
      if acc_reg = TO_SIGNED(-1,RAMDATA_W+1) then
        size_reg <= TO_UNSIGNED(1,SIZE_REG_C);
      elsif (acc_reg < TO_SIGNED(-1,RAMDATA_W+1) and acc_reg > TO_SIGNED(-4,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(2,SIZE_REG_C);
      elsif (acc_reg < TO_SIGNED(-3,RAMDATA_W+1) and acc_reg > TO_SIGNED(-8,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(3,SIZE_REG_C);
      elsif (acc_reg < TO_SIGNED(-7,RAMDATA_W+1) and acc_reg > TO_SIGNED(-16,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(4,SIZE_REG_C); 
      elsif (acc_reg < TO_SIGNED(-15,RAMDATA_W+1) and acc_reg > TO_SIGNED(-32,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(5,SIZE_REG_C);  
      elsif (acc_reg < TO_SIGNED(-31,RAMDATA_W+1) and acc_reg > TO_SIGNED(-64,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(6,SIZE_REG_C);
      elsif (acc_reg < TO_SIGNED(-63,RAMDATA_W+1) and acc_reg > TO_SIGNED(-128,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(7,SIZE_REG_C); 
      elsif (acc_reg < TO_SIGNED(-127,RAMDATA_W+1) and acc_reg > TO_SIGNED(-256,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(8,SIZE_REG_C); 
      elsif (acc_reg < TO_SIGNED(-255,RAMDATA_W+1) and acc_reg > TO_SIGNED(-512,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(9,SIZE_REG_C);  
      elsif (acc_reg < TO_SIGNED(-511,RAMDATA_W+1) and acc_reg > TO_SIGNED(-1024,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(10,SIZE_REG_C);  
      elsif (acc_reg < TO_SIGNED(-1023,RAMDATA_W+1) and acc_reg > TO_SIGNED(-2048,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(11,SIZE_REG_C);
      end if;  

      -- compute Symbol-1 Size
      -- positive input
      if acc_reg = TO_SIGNED(1,RAMDATA_W+1) then
        size_reg <= TO_UNSIGNED(1,SIZE_REG_C);
      elsif (acc_reg > TO_SIGNED(1,RAMDATA_W+1) and acc_reg < TO_SIGNED(4,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(2,SIZE_REG_C);
      elsif (acc_reg > TO_SIGNED(3,RAMDATA_W+1) and acc_reg < TO_SIGNED(8,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(3,SIZE_REG_C);
      elsif (acc_reg > TO_SIGNED(7,RAMDATA_W+1) and acc_reg < TO_SIGNED(16,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(4,SIZE_REG_C); 
      elsif (acc_reg > TO_SIGNED(15,RAMDATA_W+1) and acc_reg < TO_SIGNED(32,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(5,SIZE_REG_C);    
      elsif (acc_reg > TO_SIGNED(31,RAMDATA_W+1) and acc_reg < TO_SIGNED(64,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(6,SIZE_REG_C);  
      elsif (acc_reg > TO_SIGNED(63,RAMDATA_W+1) and acc_reg < TO_SIGNED(128,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(7,SIZE_REG_C);  
      elsif (acc_reg > TO_SIGNED(127,RAMDATA_W+1) and acc_reg < TO_SIGNED(256,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(8,SIZE_REG_C);  
      elsif (acc_reg > TO_SIGNED(255,RAMDATA_W+1) and acc_reg < TO_SIGNED(512,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(9,SIZE_REG_C);  
      elsif (acc_reg > TO_SIGNED(511,RAMDATA_W+1) and acc_reg < TO_SIGNED(1024,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(10,SIZE_REG_C);   
      elsif (acc_reg > TO_SIGNED(1023,RAMDATA_W+1) and acc_reg < TO_SIGNED(2048,RAMDATA_W+1)) then
        size_reg <= TO_UNSIGNED(11,SIZE_REG_C);  
      end if; 
      
      -- DC coefficient amplitude=0 case OR EOB
      if acc_reg = 0 then
         size_reg <= TO_UNSIGNED(0,SIZE_REG_C);
      end if;
    end if;
  end process;      
  
end rtl;  
--------------------------------------------------------------------------------


