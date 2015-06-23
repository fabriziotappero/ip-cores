--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- Title       : ZIGZAG                                                       --
-- Design      : MDCT CORE                                                    --
-- Author      : Michal Krepa                                                 --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- File        : ZIGZAG.VHD                                                   --
-- Created     : Sun Sep 3 2006                                               --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
--  Description : Zig-Zag scan                                                --
--                                                                            --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.All;
  use IEEE.NUMERIC_STD.all;
  
entity zigzag is
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
      divalid    : in  STD_LOGIC;
      rd_addr    : in  unsigned(5 downto 0);
      fifo_rden  : in  std_logic;
      
      fifo_empty : out std_logic;
      dout       : out STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
      dovalid    : out std_logic;
      zz_rd_addr : out STD_LOGIC_VECTOR(5 downto 0)
    );
end zigzag;

architecture rtl of zigzag is
  
  type ZIGZAG_TYPE is   array (0 to 2**RAMADDR_W-1) of INTEGER range 0 to 2**RAMADDR_W-1;
  constant ZIGZAG_ARRAY : ZIGZAG_TYPE := 
                      (
                       0,1,8,16,9,2,3,10, 
                       17,24,32,25,18,11,4,5,
                       12,19,26,33,40,48,41,34,
                       27,20,13,6,7,14,21,28,
                       35,42,49,56,57,50,43,36,
                       29,22,15,23,30,37,44,51,
                       58,59,52,45,38,31,39,46,
                       53,60,61,54,47,55,62,63
                      ); 
  
  signal fifo_wr      : std_logic;
  signal fifo_q       : std_logic_vector(11 downto 0);
  signal fifo_full    : std_logic;
  signal fifo_count   : std_logic_vector(6 downto 0);
  signal fifo_data_in : std_logic_vector(11 downto 0);
  signal fifo_empty_s : std_logic;
  
  
begin

  dout <= fifo_q;
  fifo_empty <= fifo_empty_s;

  -------------------------------------------------------------------
  -- FIFO (show ahead)
  -------------------------------------------------------------------
  U_FIFO : entity work.FIFO   
  generic map
  (
        DATA_WIDTH        => 12,
        ADDR_WIDTH        => 6
  )
  port map 
  (        
        rst               => RST,
        clk               => CLK,
        rinc              => fifo_rden,
        winc              => fifo_wr,
        datai             => fifo_data_in,

        datao             => fifo_q,
        fullo             => fifo_full,
        emptyo            => fifo_empty_s,
        count             => fifo_count
  );

  fifo_wr      <= divalid;
  fifo_data_in <= di;
  
  
  process(clk)
  begin
    if clk = '1' and clk'event then
      if rst = '1' then
        zz_rd_addr <= (others => '0');
        dovalid    <= '0';
      else
        zz_rd_addr <= std_logic_vector(
                      to_unsigned((ZIGZAG_ARRAY(to_integer(rd_addr))),6));
                      
        dovalid    <= fifo_rden and not fifo_empty_s;
      end if;
    end if;
  end process;    
  
   
end rtl;  
--------------------------------------------------------------------------------
