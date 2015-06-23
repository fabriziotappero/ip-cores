-------------------------------------------------------------------------------
-- File Name : HostIF.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : HostIF
--
-- Content   : Host Interface (Xilinx OPB v2.1)
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

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity HostIF is
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
        
        -- Quantizer RAM
        qdata              : out std_logic_vector(7 downto 0);
        qaddr              : out std_logic_vector(6 downto 0);
        qwren              : out std_logic;
        
        -- CTRL
        jpeg_ready         : in  std_logic;
        jpeg_busy          : in  std_logic;
        
        -- ByteStuffer
        outram_base_addr   : out std_logic_vector(9 downto 0);
        num_enc_bytes      : in  std_logic_vector(23 downto 0);
        
        -- others
        img_size_x         : out std_logic_vector(15 downto 0);
        img_size_y         : out std_logic_vector(15 downto 0);
        img_size_wr        : out std_logic;
        sof                : out std_logic
        
    );
end entity HostIF;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of HostIF is

  constant C_ENC_START_REG        : std_logic_vector(31 downto 0) := X"0000_0000";
  constant C_IMAGE_SIZE_REG       : std_logic_vector(31 downto 0) := X"0000_0004";
  constant C_IMAGE_RAM_ACCESS_REG : std_logic_vector(31 downto 0) := X"0000_0008";
  constant C_ENC_STS_REG          : std_logic_vector(31 downto 0) := X"0000_000C";
  constant C_COD_DATA_ADDR_REG    : std_logic_vector(31 downto 0) := X"0000_0010";
  constant C_ENC_LENGTH_REG       : std_logic_vector(31 downto 0) := X"0000_0014";
  constant C_QUANTIZER_RAM_LUM    : std_logic_vector(31 downto 0) := 
                                      X"0000_01" & "------00";
  constant C_QUANTIZER_RAM_CHR    : std_logic_vector(31 downto 0) := 
                                      X"0000_02" & "------00";
  constant C_IMAGE_RAM            : std_logic_vector(31 downto 0) := 
                                      X"001" & "------------------00";
  
  constant C_IMAGE_RAM_BASE : unsigned(31 downto 0) := X"0010_0000";
  
  signal enc_start_reg            : std_logic_vector(31 downto 0); 
  signal image_size_reg           : std_logic_vector(31 downto 0);
  signal image_ram_access_reg     : std_logic_vector(31 downto 0);
  signal enc_sts_reg              : std_logic_vector(31 downto 0);
  signal cod_data_addr_reg        : std_logic_vector(31 downto 0);
  signal enc_length_reg           : std_logic_vector(31 downto 0);
  
  signal rd_dval                  : std_logic;
  signal data_read                : std_logic_vector(31 downto 0);
  signal write_done               : std_logic;
  signal OPB_select_d             : std_logic;
  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin
  
  OPB_retry    <= '0';
  OPB_toutSup  <= '0';
  OPB_errAck   <= '0';
  
  img_size_x <= image_size_reg(31 downto 16);
  img_size_y <= image_size_reg(15 downto 0);
  
  outram_base_addr <= cod_data_addr_reg(outram_base_addr'range);
  
  -------------------------------------------------------------------
  -- OPB read
  -------------------------------------------------------------------
  p_read : process(CLK, RST)
  begin
    if RST = '1' then
      OPB_DBus_out <= (others => '0');
      rd_dval      <= '0';
      data_read    <= (others => '0');
    elsif CLK'event and CLK = '1' then
      rd_dval <= '0';

      OPB_DBus_out <= data_read;
    
      if OPB_select = '1' and OPB_select_d = '0' then
        -- only double word transactions are be supported
        if OPB_RNW = '1' and OPB_BE = X"F" then
          case OPB_ABus is
            when C_ENC_START_REG =>
              data_read <= enc_start_reg;
              rd_dval <= '1';
              
            when C_IMAGE_SIZE_REG =>
              data_read <= image_size_reg;
              rd_dval <= '1';
            
            when C_IMAGE_RAM_ACCESS_REG =>
              data_read <= image_ram_access_reg;
              rd_dval <= '1';
              
            when C_ENC_STS_REG =>
              data_read <= enc_sts_reg;
              rd_dval <= '1';
            
            when C_COD_DATA_ADDR_REG =>
              data_read <= cod_data_addr_reg;
              rd_dval <= '1';
              
            when C_ENC_LENGTH_REG =>
              data_read <= enc_length_reg;
              rd_dval <= '1';
    
            when others =>
              data_read <= (others => '0');
          end case;
 
        end if;
      end if;       
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- OPB write
  -------------------------------------------------------------------
  p_write : process(CLK, RST)
  begin
    if RST = '1' then
      qwren                <= '0';
      write_done           <= '0';
      enc_start_reg        <= (others => '0'); 
      image_size_reg       <= (others => '0');
      image_ram_access_reg <= (others => '0');
      enc_sts_reg          <= (others => '0');
      cod_data_addr_reg    <= (others => '0');
      enc_length_reg       <= (others => '0');
      qdata                <= (others => '0');
      qaddr                <= (others => '0');
      OPB_select_d         <= '0';
      sof                  <= '0';
      img_size_wr          <= '0';
    elsif CLK'event and CLK = '1' then
      qwren        <= '0';
      write_done   <= '0';
      sof          <= '0';
      img_size_wr  <= '0';
      OPB_select_d <= OPB_select;
      
      if OPB_select = '1' and OPB_select_d = '0' then
        -- only double word transactions are be supported
        if OPB_RNW = '0' and OPB_BE = X"F" then
          case OPB_ABus is
            when C_ENC_START_REG =>
              enc_start_reg <= OPB_DBus_in;
              write_done <= '1';
              if OPB_DBus_in(0) = '1' then
                sof <= '1';
              end if;
              
            when C_IMAGE_SIZE_REG =>
              image_size_reg <= OPB_DBus_in;
              img_size_wr <= '1';
              write_done <= '1';
            
            when C_IMAGE_RAM_ACCESS_REG =>
              image_ram_access_reg <= OPB_DBus_in;
              write_done <= '1';
              
            when C_ENC_STS_REG =>
              enc_sts_reg <= (others => '0');
              write_done <= '1';
            
            when C_COD_DATA_ADDR_REG =>
              cod_data_addr_reg <= OPB_DBus_in;
              write_done <= '1';
              
            when C_ENC_LENGTH_REG =>
              --enc_length_reg <= OPB_DBus_in;
              write_done <= '1';
    
            when others =>
              null;
          end case;
          
          if std_match(OPB_ABus, C_QUANTIZER_RAM_LUM) then
            qdata      <= OPB_DBus_in(qdata'range);
            qaddr      <= '0' & OPB_ABus(qaddr'high+2-1 downto 2);
            qwren      <= '1';
            write_done <= '1';
          end if;
          
          if std_match(OPB_ABus, C_QUANTIZER_RAM_CHR) then
            qdata      <= OPB_DBus_in(qdata'range);
            qaddr      <= '1' & OPB_ABus(qaddr'high+2-1 downto 2);
            qwren      <= '1';
            write_done <= '1';
          end if;
          
        end if;
      end if;
      
      -- special handling of status reg
      if jpeg_ready = '1' then
        -- set jpeg done flag
        enc_sts_reg(1) <= '1';
      end if;
      enc_sts_reg(0) <= jpeg_busy;
      
      enc_length_reg <= (others => '0');
      enc_length_reg(num_enc_bytes'range) <= num_enc_bytes;
      
    end if;
  end process;
  
  -------------------------------------------------------------------
  -- transfer ACK
  -------------------------------------------------------------------
  p_ack : process(CLK, RST)
  begin
    if RST = '1' then
      OPB_XferAck <= '0';
    elsif CLK'event and CLK = '1' then
      OPB_XferAck <= rd_dval or write_done;
    end if;
  end process;
  

end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------