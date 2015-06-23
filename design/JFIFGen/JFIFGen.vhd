-------------------------------------------------------------------------------
-- File Name :  JFIFGen.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : JFIFGen
--
-- Content   : JFIF Header Generator
--
-- Description :
--
-- Spec.     : 
--
-- Author    : Michal Krepa
--
-------------------------------------------------------------------------------
-- History :
-- 20090309: (MK): Initial Creation.
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

library work;
  use work.JPEG_PKG.all;
  
-------------------------------------------------------------------------------
-- user packages/libraries:
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ENTITY ------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
entity JFIFGen is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        -- CTRL
        start              : in  std_logic;
        ready              : out std_logic;
        eoi                : in  std_logic;
        
        -- ByteStuffer
        num_enc_bytes      : in  std_logic_vector(23 downto 0);
        
        -- HOST IF
        qwren              : in  std_logic;
        qwaddr             : in  std_logic_vector(6 downto 0);
        qwdata             : in  std_logic_vector(7 downto 0);
        image_size_reg     : in  std_logic_vector(31 downto 0);
        image_size_reg_wr  : in  std_logic;
        
        -- OUT RAM
        ram_byte           : out std_logic_vector(7 downto 0);
        ram_wren           : out std_logic;
        ram_wraddr         : out std_logic_vector(23 downto 0)
    );
end entity JFIFGen;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of JFIFGen is

  constant C_SIZE_Y_H  : integer := 25;
  constant C_SIZE_Y_L  : integer := 26;
  constant C_SIZE_X_H  : integer := 27;
  constant C_SIZE_X_L  : integer := 28;  
  
  constant C_EOI       : std_logic_vector(15 downto 0) := X"FFD9";
  constant C_QLUM_BASE : integer := 44;
  constant C_QCHR_BASE : integer := 44+69;
  

  signal hr_data      : std_logic_vector(7 downto 0);
  signal hr_waddr     : std_logic_vector(9 downto 0);
  signal hr_raddr     : std_logic_vector(9 downto 0);
  signal hr_we        : std_logic;
  signal hr_q         : std_logic_vector(7 downto 0);
  signal size_wr_cnt  : unsigned(2 downto 0);
  signal size_wr      : std_logic;
  signal rd_cnt       : unsigned(9 downto 0);
  signal rd_en        : std_logic;
  signal rd_en_d1     : std_logic;
  signal rd_cnt_d1    : unsigned(rd_cnt'range);
  signal rd_cnt_d2    : unsigned(rd_cnt'range);
  signal eoi_cnt      : unsigned(1 downto 0);
  signal eoi_wr       : std_logic;
  signal eoi_wr_d1    : std_logic;
  
  component HeaderRam is
  port
  (
    d                 : in  STD_LOGIC_VECTOR(7 downto 0);
    waddr             : in  STD_LOGIC_VECTOR(9 downto 0);
    raddr             : in  STD_LOGIC_VECTOR(9 downto 0);
    we                : in  STD_LOGIC;
    clk               : in  STD_LOGIC;
    
    q                 : out STD_LOGIC_VECTOR(7 downto 0)
  );  
  end component;
  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin
  
  -------------------------------------------------------------------
  -- Header RAM
  -------------------------------------------------------------------
  U_Header_RAM : HeaderRam
  port map
  (      
        d           => hr_data,
        waddr       => hr_waddr,
        raddr       => hr_raddr,
        we          => hr_we,
        clk         => CLK,
                    
        q           => hr_q
  );
  
  hr_raddr <= std_logic_vector(rd_cnt);
  
  -------------------------------------------------------------------
  -- Host programming
  -------------------------------------------------------------------
  p_host_wr : process(CLK, RST)
  begin
    if RST = '1' then
      size_wr_cnt <= (others => '0');
      size_wr     <= '0';
      hr_we       <= '0';
      hr_data     <= (others => '0');
      hr_waddr    <= (others => '0');
    elsif CLK'event and CLK = '1' then
      hr_we <= '0';
    
      if image_size_reg_wr = '1' then
        size_wr_cnt <= (others => '0');
        size_wr     <= '1';
      end if;
      
      -- write image size
      if size_wr = '1' then
        if size_wr_cnt = 4 then
          size_wr_cnt <= (others => '0');
          size_wr     <= '0';
        else
          size_wr_cnt <= size_wr_cnt + 1;
          hr_we <= '1';
          case size_wr_cnt is
            -- height H byte
            when "000" =>
              hr_data  <= image_size_reg(15 downto 8);
              hr_waddr <= std_logic_vector(to_unsigned(C_SIZE_Y_H,hr_waddr'length));
            -- height L byte
            when "001" =>
              hr_data <= image_size_reg(7 downto 0);
              hr_waddr <= std_logic_vector(to_unsigned(C_SIZE_Y_L,hr_waddr'length));
            -- width H byte
            when "010" =>
              hr_data <= image_size_reg(31 downto 24);
              hr_waddr <= std_logic_vector(to_unsigned(C_SIZE_X_H,hr_waddr'length));
            -- width L byte
            when "011" =>
              hr_data <= image_size_reg(23 downto 16);
              hr_waddr <= std_logic_vector(to_unsigned(C_SIZE_X_L,hr_waddr'length));
            when others =>
              null;
          end case;
        end if;
      -- write Quantization table
      elsif qwren = '1' then
        -- luminance table select
        if qwaddr(6) = '0' then
          hr_waddr <= std_logic_vector
                        ( resize(unsigned(qwaddr(5 downto 0)),hr_waddr'length) + 
                          to_unsigned(C_QLUM_BASE,hr_waddr'length));
        else
          -- chrominance table select
          hr_waddr <= std_logic_vector
                        ( resize(unsigned(qwaddr(5 downto 0)),hr_waddr'length) + 
                          to_unsigned(C_QCHR_BASE,hr_waddr'length));
        end if;
        hr_we   <= '1';
        hr_data <= qwdata;
      end if;
        
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- CTRL
  -------------------------------------------------------------------
  p_ctrl : process(CLK, RST)
  begin
    if RST = '1' then
      ready      <= '0';
      rd_en      <= '0';
      rd_cnt     <= (others => '0');
      rd_cnt_d1  <= (others => '0');
      rd_cnt_d2  <= (others => '0');
      rd_cnt_d1  <= (others => '0');
      rd_en_d1   <= '0';
      eoi_wr_d1  <= '0';
      eoi_wr     <= '0';
      eoi_cnt    <= (others => '0');
      ram_wren   <= '0';
      ram_byte   <= (others => '0');
      ram_wraddr <= (others => '0');
    elsif CLK'event and CLK = '1' then
      ready     <= '0';
      rd_cnt_d1 <= rd_cnt;
      rd_cnt_d2 <= rd_cnt_d1;
      rd_en_d1  <= rd_en;
      eoi_wr_d1 <= eoi_wr;
      
      -- defaults: encoded data write
      ram_wren   <= rd_en_d1;
      ram_wraddr <= std_logic_vector(resize(rd_cnt_d1,ram_wraddr'length));
      ram_byte   <= hr_q;
    
      -- start JFIF
      if start = '1' and eoi = '0' then
        rd_cnt <= (others => '0');
        rd_en  <= '1';
      elsif start = '1' and eoi = '1' then
        eoi_wr  <= '1';
        eoi_cnt <= (others => '0'); 
      end if;
      
      -- read JFIF Header
      if rd_en = '1' then
        if rd_cnt = C_HDR_SIZE-1 then
          rd_en  <= '0';
          ready  <= '1';
        else
          rd_cnt <= rd_cnt + 1;
        end if;
      end if;
      
      -- EOI MARKER write
      if eoi_wr = '1' then
        if eoi_cnt = 2 then
          eoi_cnt  <= (others => '0');
          eoi_wr   <= '0';
          ready    <= '1';
        else
          eoi_cnt  <= eoi_cnt + 1;
          ram_wren <= '1';
          if eoi_cnt = 0 then
            ram_byte   <= C_EOI(15 downto 8);
            ram_wraddr <= num_enc_bytes;
          elsif eoi_cnt = 1 then
            ram_byte   <= C_EOI(7 downto 0);
            ram_wraddr <= std_logic_vector(unsigned(num_enc_bytes) + 
                                           to_unsigned(1,ram_wraddr'length));
          end if;
        end if;    
      end if;
    end if;
  end process;

end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------