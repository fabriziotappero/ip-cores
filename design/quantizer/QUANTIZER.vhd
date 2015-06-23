--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006-2009                           --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- Title       : DIVIDER                                                      --
-- Design      : DCT QUANTIZER                                                --
-- Author      : Michal Krepa                                                 --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
-- File        : QUANTIZER.VHD                                                --
-- Created     : Sun Aug 27 2006                                              --
--                                                                            --
--------------------------------------------------------------------------------
--                                                                            --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

library IEEE;
  use IEEE.STD_LOGIC_1164.All;
  use IEEE.NUMERIC_STD.all;
  
entity quantizer is
  generic 
    ( 
      SIZE_C        : INTEGER := 12;
      RAMQADDR_W    : INTEGER := 7;
      RAMQDATA_W    : INTEGER := 8
    );
  port
    (
      rst        : in  STD_LOGIC;
      clk        : in  STD_LOGIC;
      di         : in  STD_LOGIC_VECTOR(SIZE_C-1 downto 0);
      divalid    : in  STD_LOGIC;
      qdata      : in  std_logic_vector(7 downto 0);
      qwaddr     : in  std_logic_vector(6 downto 0);
      qwren      : in  std_logic;
      cmp_idx    : in  unsigned(2 downto 0);
                 
      do         : out STD_LOGIC_VECTOR(SIZE_C-1 downto 0);
      dovalid    : out STD_LOGIC
    );
end quantizer;

architecture rtl of quantizer is
  
  constant INTERN_PIPE_C : INTEGER := 3;
  
  signal romaddr_s     : UNSIGNED(RAMQADDR_W-2 downto 0);
  signal slv_romaddr_s : STD_LOGIC_VECTOR(RAMQADDR_W-1 downto 0);
  signal romdatao_s    : STD_LOGIC_VECTOR(RAMQDATA_W-1 downto 0);
  signal divisor_s     : STD_LOGIC_VECTOR(SIZE_C-1 downto 0);
  signal remainder_s   : STD_LOGIC_VECTOR(SIZE_C-1 downto 0);
  signal do_s          : STD_LOGIC_VECTOR(SIZE_C-1 downto 0);
  signal round_s       : STD_LOGIC;
  signal di_d1         : std_logic_vector(SIZE_C-1 downto 0);
  
  signal pipeline_reg  : STD_LOGIC_VECTOR(4 downto 0);
  signal sign_bit_pipe : std_logic_vector(SIZE_C+INTERN_PIPE_C+1-1 downto 0);  
  signal do_rdiv       : STD_LOGIC_VECTOR(SIZE_C-1 downto 0);
  signal table_select  : std_logic;
  
begin
  
  ----------------------------
  -- RAMQ
  ----------------------------
  U_RAMQ : entity work.RAMZ
    generic map
    (
      RAMADDR_W    => RAMQADDR_W,
      RAMDATA_W    => RAMQDATA_W
    )
    port map
    (
      d           => qdata,
      waddr       => qwaddr,
      raddr       => slv_romaddr_s,
      we          => qwren,
      clk         => CLK,
                  
      q           => romdatao_s
    );
  

  
  divisor_s(RAMQDATA_W-1 downto 0)      <= romdatao_s;
  divisor_s(SIZE_C-1 downto RAMQDATA_W) <= (others => '0');
  
  r_divider : entity work.r_divider
  port map
  (
       rst   => rst,
       clk   => clk,
       a     => di_d1,     
       d     => romdatao_s,    
             
       q     => do_s
  ) ;
  do <= do_s;
  slv_romaddr_s <= table_select & STD_LOGIC_VECTOR(romaddr_s);
  
  ------------------------------
  -- Quantization sub table select
  ------------------------------
  process(clk)
  begin
    if clk = '1' and clk'event then
      if rst = '1' then
        table_select <= '0';
      else
        -- luminance table select
        if cmp_idx < 2 then
          table_select <= '0';
        -- chrominance table select
        else
          table_select <= '1';
        end if;
      end if; 
    end if;
  end process;
  
  ----------------------------
  -- address incrementer
  ----------------------------
  process(clk)
  begin
    if clk = '1' and clk'event then
      if rst = '1' then
        romaddr_s     <= (others => '0'); 
        pipeline_reg  <= (OTHERS => '0'); 
        di_d1         <= (OTHERS => '0');
        sign_bit_pipe <= (others => '0');
      else
        if divalid = '1' then
          romaddr_s <= romaddr_s + TO_UNSIGNED(1,romaddr_s'length);
        end if;
        
        pipeline_reg <= pipeline_reg(pipeline_reg'length-2 downto 0) & divalid;
        
        di_d1 <= di;
        
        sign_bit_pipe <= sign_bit_pipe(sign_bit_pipe'length-2 downto 0) & di(SIZE_C-1);
      end if; 
    end if;
  end process;
  
  dovalid <= pipeline_reg(pipeline_reg'high);
   
end rtl;  
--------------------------------------------------------------------------------