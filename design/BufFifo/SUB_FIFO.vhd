
library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.STD_LOGIC_UNSIGNED.all;
library WORK;
  
entity SUB_FIFO is   
  generic (
        DATA_WIDTH         : INTEGER   := 12;
        ADDR_WIDTH         : INTEGER   := 2
       );
  port (        
        rst               : in  STD_LOGIC;
        clk               : in  STD_LOGIC;
        rinc              : in  STD_LOGIC;
        winc              : in  STD_LOGIC;
        
        fullo             : out STD_LOGIC;
        emptyo            : out STD_LOGIC;
        count             : out STD_LOGIC_VECTOR (ADDR_WIDTH downto 0);
        
        ramwaddr          : out STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
        ramenw            : out STD_LOGIC; 
        ramraddr          : out STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
        ramenr            : out STD_LOGIC
        );
end SUB_FIFO;

architecture RTL of SUB_FIFO is

  signal raddr_reg        : STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
  signal waddr_reg        : STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
  signal count_reg        : STD_LOGIC_VECTOR(ADDR_WIDTH downto 0);
  signal rd_en_reg        : STD_LOGIC;
  signal wr_en_reg        : STD_LOGIC;
  signal empty_reg        : STD_LOGIC;
  signal full_reg         : STD_LOGIC;

  constant ZEROS_C        : STD_LOGIC_VECTOR(ADDR_WIDTH downto 0) := (others => '0'); 
  constant ONES_C         : STD_LOGIC_VECTOR(ADDR_WIDTH downto 0) := (others => '1'); 

begin 
  
  ramwaddr                <= waddr_reg;
  ramenw                  <= wr_en_reg;
  ramraddr                <= raddr_reg;
  ramenr                  <= '1';      
  
  emptyo                  <= empty_reg;
  fullo                   <= full_reg;
  rd_en_reg               <= (rinc and not empty_reg);                      
  wr_en_reg               <= (winc and not full_reg); 
  
  count <= count_reg;    

  process(clk)
  begin 
    if clk = '1' and clk'event then
      if rst = '1' then
        empty_reg         <= '1';   
      else
        if count_reg = ZEROS_C or
          (count_reg = 1 and rd_en_reg = '1' and wr_en_reg = '0') then
          empty_reg       <= '1';
        else
          empty_reg       <= '0';
        end if;  
      end if;
    end if;
  end process;

  process(clk)
  begin 
    if clk = '1' and clk'event then
      if rst = '1' then
        full_reg          <= '0';   
      else
        if count_reg = 2**ADDR_WIDTH or
          (count_reg = 2**ADDR_WIDTH-1 and wr_en_reg = '1' and rd_en_reg = '0') then 
          full_reg        <= '1';
        else
          full_reg        <= '0';
        end if;  
      end if;
    end if;
  end process;

  process(clk)
  begin 
    if clk = '1' and clk'event then
      if rst = '1' then
        raddr_reg         <= (others => '0');   
      else
        if rd_en_reg = '1' then
          raddr_reg       <= raddr_reg + '1';
        end if; 
      end if;
    end if;
  end process;          

  process(clk)
  begin 
    if clk = '1' and clk'event then
      if rst = '1' then
        waddr_reg         <= (others => '0');  
      else        
        if wr_en_reg = '1' then
          waddr_reg       <= waddr_reg + '1';
        end if;
      end if;
    end if;
  end process;

  process(clk)
  begin 
    if clk = '1' and clk'event then
      if rst = '1' then
        count_reg         <= (others => '0');   
      else
        if (rd_en_reg = '1' and wr_en_reg = '0') or (rd_en_reg = '0' and wr_en_reg = '1') then
          if rd_en_reg = '1' then
            count_reg     <= count_reg - '1';
          else
            count_reg     <= count_reg + '1';
          end if;
        end if;
      end if;
    end if;
  end process;

end RTL;
