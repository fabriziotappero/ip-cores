-------------------------------------------------------------------------------
-- File Name : HostBFM.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : HostBFM
--
-- Content   : Host BFM (Xilinx OPB v2.1)
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
  use IEEE.STD_LOGIC_TEXTIO.ALL;
  
library STD;
  use STD.TEXTIO.ALL;  
  
library work;
  use work.GPL_V2_Image_Pkg.ALL;
  use WORK.MDCT_PKG.all;
  use WORK.MDCTTB_PKG.all;
  use work.JPEG_PKG.all;  
  
entity HostBFM is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        -- OPB
        OPB_ABus           : out std_logic_vector(31 downto 0);
        OPB_BE             : out std_logic_vector(3 downto 0);
        OPB_DBus_in        : out std_logic_vector(31 downto 0);
        OPB_RNW            : out std_logic;
        OPB_select         : out std_logic;
        OPB_DBus_out       : in  std_logic_vector(31 downto 0);
        OPB_XferAck        : in  std_logic;
        OPB_retry          : in  std_logic;
        OPB_toutSup        : in  std_logic;
        OPB_errAck         : in  std_logic;
        
        -- HOST DATA
       iram_wdata          : out std_logic_vector(C_PIXEL_BITS-1 downto 0);
       iram_wren           : out std_logic;
       fifo_almost_full    : in  std_logic; 
        
        sim_done           : out std_logic
    );
end entity HostBFM;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of HostBFM is

  signal num_comps   : integer;
  signal addr_inc    : integer := 0;
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin
  
  
  
  -------------------------------------------------------------------
  -- code
  -------------------------------------------------------------------
  p_code : process
  
    -----------------------------------------------------------------
    -- HOST WRITE
    -----------------------------------------------------------------
    procedure host_write
      (
        signal clk         : in    std_logic;
        constant C_ADDR    : in    unsigned(31 downto 0);
        constant C_WDATA   : in    unsigned(31 downto 0);
        
        signal OPB_ABus    : out   std_logic_vector(31 downto 0);
        signal OPB_BE      : out   std_logic_vector(3 downto 0);
        signal OPB_DBus_in : out   std_logic_vector(31 downto 0);
        signal OPB_RNW     : out   std_logic; 
        signal OPB_select  : out   std_logic;
        signal OPB_XferAck : in  std_logic
      ) is
    begin
      OPB_ABus    <= (others => '0');
      OPB_BE      <= (others => '0');
      OPB_DBus_in <= (others => '0');
      OPB_RNW     <= '0';
      OPB_select  <= '0';
      
      wait until rising_edge(clk);
      
      OPB_select  <= '1';
      OPB_ABus    <= std_logic_vector(C_ADDR);
      OPB_RNW     <= '0';
      OPB_BE      <= X"F";
      OPB_DBus_in <= std_logic_vector(C_WDATA);
      
      wait until rising_edge(clk);
      
      while OPB_XferAck /= '1' loop
        wait until rising_edge(clk);
      end loop;
      
      OPB_ABus    <= (others => '0');
      OPB_BE      <= (others => '0');
      OPB_DBus_in <= (others => '0');
      OPB_RNW     <= '0';
      OPB_select  <= '0';
      
      assert false
      report CR&"Host write access, address = " & HexImage(C_ADDR) & ",data written = " & HexImage(C_WDATA) &CR
      severity note;
      
      wait until rising_edge(clk);
        
    end procedure host_write;
    
    -----------------------------------------------------------------
    -- HOST READ
    -----------------------------------------------------------------
    procedure host_read
      (
        signal clk          : in    std_logic;
        constant C_ADDR     : in    unsigned(31 downto 0);
        variable RDATA      : out   unsigned(31 downto 0);
        
        signal OPB_ABus     : out   std_logic_vector(31 downto 0);
        signal OPB_BE       : out   std_logic_vector(3 downto 0);
        signal OPB_DBus_out : in    std_logic_vector(31 downto 0);
        signal OPB_RNW      : out   std_logic; 
        signal OPB_select   : out   std_logic;
        signal OPB_XferAck  : in  std_logic
      ) 
    is
      variable data_r : std_logic_vector(31 downto 0);
    begin
      OPB_ABus    <= (others => '0');
      OPB_BE      <= (others => '0');
      OPB_DBus_in <= (others => '0');
      OPB_RNW     <= '0';
      OPB_select  <= '0';
      
      wait until rising_edge(clk);
      
      OPB_select  <= '1';
      OPB_ABus    <= std_logic_vector(C_ADDR);
      OPB_RNW     <= '1';
      OPB_BE      <= X"F";
      
      wait until rising_edge(clk);
      
      while OPB_XferAck /= '1' loop
        wait until rising_edge(clk);
      end loop;
      
      RDATA := unsigned(OPB_DBus_out);
      data_r := OPB_DBus_out;
      
      OPB_ABus    <= (others => '0');
      OPB_BE      <= (others => '0');
      OPB_DBus_in <= (others => '0');
      OPB_RNW     <= '0';
      OPB_select  <= '0';
      
      assert false
      report CR&"Host read access, address = " & HexImage(C_ADDR) & ",data read = " & HexImage(data_r) &CR
      severity note;

      
      wait until rising_edge(clk);
        
    end procedure host_read;
    
    
    --------------------------------------
    -- read text image data
    --------------------------------------
    procedure read_image is
      file infile          : TEXT open read_mode is "test.txt";
      constant N           : integer := 8;
      constant MAX_COMPS   : integer := 3;
      variable inline      : LINE;
      variable tmp_int     : INTEGER := 0;
      variable y_size      : INTEGER := 0;
      variable x_size      : INTEGER := 0;
      variable matrix      : I_MATRIX_TYPE;
      variable x_blk_cnt   : INTEGER := 0;
      variable y_blk_cnt   : INTEGER := 0;
      variable n_lines_arr : N_LINES_TYPE;
      variable line_n      : INTEGER := 0;
      variable pix_n       : INTEGER := 0;
      variable x_n         : INTEGER := 0;
      variable y_n         : INTEGER := 0;
      variable data_word   : unsigned(31 downto 0);
      variable image_line  : STD_LOGIC_VECTOR(0 to MAX_COMPS*MAX_IMAGE_SIZE_X*IP_W-1);
      
      constant C_IMAGE_RAM_BASE : unsigned(31 downto 0) := X"0010_0000";
      
      variable x_cnt       : integer;
      variable data_word2  : unsigned(31 downto 0);
      variable num_comps_v : integer;
    begin
      READLINE(infile,inline);
      READ(inline,num_comps_v);
      READLINE(infile,inline);
      READ(inline,y_size);
      READLINE(infile,inline);
      READ(inline,x_size);
      
      num_comps <= num_comps_v;
 
      if y_size rem N > 0 then
        assert false
          report "ERROR: Image height dimension is not multiply of 8!"
          severity Failure;
      end if;
      if x_size rem N > 0 then
        assert false
          report "ERROR: Image width dimension is not multiply of 8!"
          severity Failure;
      end if;
      
      if x_size > C_MAX_LINE_WIDTH then
        assert false
          report "ERROR: Image width bigger than C_MAX_LINE_WIDTH in JPEG_PKG.VHD! " &
                 "Increase C_MAX_LINE_WIDTH accordingly"
          severity Failure;
      end if;
      
      addr_inc <= 0;
      
      -- image size
      host_write(CLK, X"0000_0004", to_unsigned(x_size,16) & to_unsigned(y_size,16), 
               OPB_ABus, OPB_BE, OPB_DBus_in, OPB_RNW, OPB_select, OPB_XferAck);
      
      iram_wren <= '0';
      for y_n in 0 to y_size-1 loop
        READLINE(infile,inline);
        HREAD(inline,image_line(0 to num_comps*x_size*IP_W-1));
        x_cnt := 0;
        for x_n in 0 to x_size-1 loop
          data_word := X"00" & UNSIGNED(image_line(x_cnt to x_cnt+num_comps*IP_W-1));
          if C_PIXEL_BITS = 24 then
            data_word2(7 downto 0)   := data_word(23 downto 16);
            data_word2(15 downto 8)  := data_word(15 downto 8);
            data_word2(23 downto 16) := data_word(7 downto 0);  
          else
            data_word2(4 downto 0)   := data_word(23 downto 19);
            data_word2(10 downto 5)  := data_word(15 downto 10);
            data_word2(15 downto 11) := data_word(7 downto 3);
          end if;

          iram_wren  <= '0';
          iram_wdata <= (others => 'X');
          while(fifo_almost_full = '1') loop
            wait until rising_edge(clk);
          end loop;
          
          --for i in 0 to 4 loop
          --  wait until rising_edge(clk);
          --end loop;
          
          iram_wren <= '1';
          iram_wdata <= std_logic_vector(data_word2(C_PIXEL_BITS-1 downto 0));
          wait until rising_edge(clk);
          
          x_cnt := x_cnt + num_comps*IP_W;
     
          addr_inc <= addr_inc + 1;
        end loop;      
      end loop;
      iram_wren <= '0';
  
    end read_image; 
    
    ------------------
    type ROMQ_TYPE is array (0 to 64-1) 
            of unsigned(7 downto 0);
  
  constant qrom_lum : ROMQ_TYPE := 
  (
  -- 100%
  --others => X"01"
  
  -- 85%
  X"05", X"03", X"04", X"04", 
  X"04", X"03", X"05", X"04", 
  X"04", X"04", X"05", X"05", 
  X"05", X"06", X"07", X"0C",
  X"08", X"07", X"07", X"07", 
  X"07", X"0F", X"0B", X"0B", 
  X"09", X"0C", X"11", X"0F", 
  X"12", X"12", X"11", X"0F",
  X"11", X"11", X"13", X"16", 
  X"1C", X"17", X"13", X"14", 
  X"1A", X"15", X"11", X"11", 
  X"18", X"21", X"18", X"1A",
  X"1D", X"1D", X"1F", X"1F", 
  X"1F", X"13", X"17", X"22", 
  X"24", X"22", X"1E", X"24", 
  X"1C", X"1E", X"1F", X"1E"
  
  -- 100%
  --others => X"01"
  
  -- 75%
   --X"08", X"06", X"06", X"07", X"06", X"05", X"08", X"07", X"07", X"07", X"09", X"09", X"08", X"0A", X"0C", X"14",
   --X"0D", X"0C", X"0B", X"0B", X"0C", X"19", X"12", X"13", X"0F", X"14", X"1D", X"1A", X"1F", X"1E", X"1D", X"1A",
   --X"1C", X"1C", X"20", X"24", X"2E", X"27", X"20", X"22", X"2C", X"23", X"1C", X"1C", X"28", X"37", X"29", X"2C",
   --X"30", X"31", X"34", X"34", X"34", X"1F", X"27", X"39", X"3D", X"38", X"32", X"3C", X"2E", X"33", X"34", X"32"
   
   -- 15 %
   --X"35", X"25", X"28", X"2F", 
   --X"28", X"21", X"35", X"2F", 
   --X"2B", X"2F", X"3C", X"39", 
   --X"35", X"3F", X"50", X"85", 
   --X"57", X"50", X"49", X"49", 
   --X"50", X"A3", X"75", X"7B", 
   --X"61", X"85", X"C1", X"AA", 
   --X"CB", X"C8", X"BE", X"AA", 
   --X"BA", X"B7", X"D5", X"F0", 
   --X"FF", X"FF", X"D5", X"E2", 
   --X"FF", X"E6", X"B7", X"BA", 
   --X"FF", X"FF", X"FF", X"FF", 
   --X"FF", X"FF", X"FF", X"FF", 
   --X"FF", X"CE", X"FF", X"FF", 
   --X"FF", X"FF", X"FF", X"FF", 
   --X"FF", X"FF", X"FF", X"FF"      
   
   -- 50%
   --X"10", X"0B", X"0C", X"0E", X"0C", X"0A", X"10", X"0E", 
   --X"0D", X"0E", X"12", X"11", X"10", X"13", X"18", X"28",
   --X"1A", X"18", X"16", X"16", X"18", X"31", X"23", X"25", 
   --X"1D", X"28", X"3A", X"33", X"3D", X"3C", X"39", X"33",
   --X"38", X"37", X"40", X"48", X"5C", X"4E", X"40", X"44", 
   --X"57", X"45", X"37", X"38", X"50", X"6D", X"51", X"57",
   --X"5F", X"62", X"67", X"68", X"67", X"3E", X"4D", X"71", 
   --X"79", X"70", X"64", X"78", X"5C", X"65", X"67", X"63"
  );
  
  constant qrom_chr : ROMQ_TYPE := 
  (
   -- 50% for chrominance
  X"11", X"12", X"12", X"18", X"15", X"18", X"2F", X"1A", 
  X"1A", X"2F", X"63", X"42", X"38", X"42", X"63", X"63",
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63", 
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63",
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63", 
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63",
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63", 
  X"63", X"63", X"63", X"63", X"63", X"63", X"63", X"63"
  
  -- 75% chrominance
  --X"09", X"09", X"09", X"0C", X"0B", X"0C", X"18", X"0D", 
  --X"0D", X"18", X"32", X"21", X"1C", X"21", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32", 
  --X"32", X"32", X"32", X"32", X"32", X"32", X"32", X"32"
  
  --X"08", X"06", X"06", X"07", X"06", X"05", X"08", X"07", X"07", X"07", X"09", X"09", X"08", X"0A", X"0C", X"14",
  --X"0D", X"0C", X"0B", X"0B", X"0C", X"19", X"12", X"13", X"0F", X"14", X"1D", X"1A", X"1F", X"1E", X"1D", X"1A",
  --X"1C", X"1C", X"20", X"24", X"2E", X"27", X"20", X"22", X"2C", X"23", X"1C", X"1C", X"28", X"37", X"29", X"2C",
  --X"30", X"31", X"34", X"34", X"34", X"1F", X"27", X"39", X"3D", X"38", X"32", X"3C", X"2E", X"33", X"34", X"32"
   
  --others => X"01"
  );
  
    variable data_read  : unsigned(31 downto 0);
    variable data_write : unsigned(31 downto 0);
    variable addr       : unsigned(31 downto 0);
    

  ------------------------------------------------------------------------------
  -- BEGIN
  ------------------------------------------------------------------------------
  begin
    sim_done <= '0';
    iram_wren <= '0';
  
    while RST /= '0' loop
      wait until rising_edge(clk);
    end loop;
    
    for i in 0 to 100 loop
      wait until rising_edge(clk);
    end loop;
    
    
    
    host_read(CLK, X"0000_0000", data_read, 
               OPB_ABus, OPB_BE, OPB_DBus_out, OPB_RNW, OPB_select, OPB_XferAck);
               
               
    host_read(CLK, X"0000_0004", data_read, 
               OPB_ABus, OPB_BE, OPB_DBus_out, OPB_RNW, OPB_select, OPB_XferAck);
    
    -- write luminance quantization table 
    for i in 0 to 64-1 loop
      data_write := X"0000_00" & qrom_lum(i);
      addr := X"0000_0100" + to_unsigned(4*i,32);
      host_write(CLK, addr, data_write, 
               OPB_ABus, OPB_BE, OPB_DBus_in, OPB_RNW, OPB_select, OPB_XferAck);
  
    end loop;
     
    -- write chrominance quantization table 
    for i in 0 to 64-1 loop
      data_write := X"0000_00" & qrom_chr(i);
      addr := X"0000_0200" + to_unsigned(4*i,32);
      host_write(CLK, addr, data_write, 
               OPB_ABus, OPB_BE, OPB_DBus_in, OPB_RNW, OPB_select, OPB_XferAck);
  
    end loop;
   
     
    
    data_write := to_unsigned(1,32) + shift_left(to_unsigned(3,32),1);
    
    -- SOF & num_comps
    host_write(CLK, X"0000_0000", data_write, 
               OPB_ABus, OPB_BE, OPB_DBus_in, OPB_RNW, OPB_select, OPB_XferAck);

    -- write BUF_FIFO with bitmap
    read_image;          
    
    -- wait until JPEG encoding is done
    host_read(CLK, X"0000_000C", data_read, 
               OPB_ABus, OPB_BE, OPB_DBus_out, OPB_RNW, OPB_select, OPB_XferAck);       
    while data_read /= 2 loop
     host_read(CLK, X"0000_000C", data_read, 
               OPB_ABus, OPB_BE, OPB_DBus_out, OPB_RNW, OPB_select, OPB_XferAck);
    end loop;
    
    sim_done <= '1';
    
    wait;
    
  end process;
  

end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------