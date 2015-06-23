--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006                                --
--                                                                            --
--------------------------------------------------------------------------------
--
-- Title       : DCT2D
-- Design      : MDCT Core
-- Author      : Michal Krepa
--
--------------------------------------------------------------------------------
--
-- File        : DCT2D.VHD
-- Created     : Sat Mar 28 22:32 2006
--
--------------------------------------------------------------------------------
--
--  Description : 1D Discrete Cosine Transform (second stage)
--
--------------------------------------------------------------------------------


library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all; 

library WORK;
  use WORK.MDCT_PKG.all;

entity DCT2D is	 
	port(	  
      clk          : in STD_LOGIC;  
      rst          : in std_logic;
      romedatao    : in T_ROM2DATAO;
      romodatao    : in T_ROM2DATAO;
      ramdatao     : in STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
      dataready    : in STD_LOGIC;
 
      odv          : out STD_LOGIC;
      dcto         : out std_logic_vector(OP_W-1 downto 0);
      romeaddro    : out T_ROM2ADDRO;
      romoaddro    : out T_ROM2ADDRO;
      ramraddro    : out STD_LOGIC_VECTOR(RAMADRR_W-1 downto 0);
      rmemsel      : out STD_LOGIC;
      datareadyack : out STD_LOGIC
		
		);
end DCT2D;

architecture RTL of DCT2D is   
  
  type input_data2 is array (N-1 downto 0) of SIGNED(RAMDATA_W downto 0);
  
  signal databuf_reg     : input_data2;
  signal latchbuf_reg    : input_data2;
  signal col_reg         : UNSIGNED(RAMADRR_W/2-1 downto 0);
  signal row_reg         : UNSIGNED(RAMADRR_W/2-1 downto 0);
  signal colram_reg      : UNSIGNED(RAMADRR_W/2-1 downto 0);
  signal rowram_reg      : UNSIGNED(RAMADRR_W/2-1 downto 0);
  signal colr_reg        : UNSIGNED(RAMADRR_W/2-1 downto 0);
  signal rowr_reg        : UNSIGNED(RAMADRR_W/2-1 downto 0);
  signal rmemsel_reg     : STD_LOGIC;
  signal stage1_reg      : STD_LOGIC; 
  signal stage2_reg      : STD_LOGIC; 
  signal stage2_cnt_reg  : UNSIGNED(RAMADRR_W-1 downto 0);
  signal dataready_2_reg : STD_LOGIC;  
  signal even_not_odd    : std_logic;
  signal even_not_odd_d1 : std_logic;
  signal even_not_odd_d2 : std_logic;
  signal even_not_odd_d3 : std_logic;
  signal even_not_odd_d4 : std_logic;
  signal odv_d0          : std_logic;
  signal odv_d1          : std_logic;
  signal odv_d2          : std_logic;
  signal odv_d3          : std_logic;
  signal odv_d4          : std_logic;
  signal odv_d5          : std_logic;
  signal dcto_1          : std_logic_vector(DA2_W-1 downto 0);
  signal dcto_2          : std_logic_vector(DA2_W-1 downto 0);
  signal dcto_3          : std_logic_vector(DA2_W-1 downto 0);
  signal dcto_4          : std_logic_vector(DA2_W-1 downto 0);
  signal dcto_5          : std_logic_vector(DA2_W-1 downto 0);
  signal romedatao_d1    : T_ROM2DATAO;
  signal romodatao_d1    : T_ROM2DATAO;
  signal romedatao_d2    : T_ROM2DATAO;
  signal romodatao_d2    : T_ROM2DATAO;
  signal romedatao_d3    : T_ROM2DATAO;
  signal romodatao_d3    : T_ROM2DATAO;
  signal romedatao_d4    : T_ROM2DATAO;
  signal romodatao_d4    : T_ROM2DATAO;
begin

  ramraddro_sg:
  ramraddro  <= STD_LOGIC_VECTOR(rowr_reg & colr_reg);
  
  rmemsel_sg:
  rmemsel    <= rmemsel_reg;
  
  process(clk,rst)
  begin
    if rst = '1' then
      stage2_cnt_reg       <= (others => '1');
      rmemsel_reg          <= '0';
      stage1_reg           <= '0';
      stage2_reg           <= '0';
      colram_reg           <= (others => '0');
      rowram_reg           <= (others => '0');
      col_reg              <= (others => '0');
      row_reg              <= (others => '0');
      latchbuf_reg         <= (others => (others => '0')); 
      databuf_reg          <= (others => (others => '0'));
      odv_d0               <= '0';
      colr_reg             <= (others => '0');
      rowr_reg             <= (others => '0'); 
      dataready_2_reg      <= '0';
    elsif clk='1' and clk'event then
      stage2_reg    <= '0';
      odv_d0        <= '0';
      datareadyack  <= '0';
      dataready_2_reg <= dataready;
      
      ----------------------------------
      -- read DCT 1D to barrel shifer
      ----------------------------------
      if stage1_reg = '1' then

        -- right shift input data
        latchbuf_reg(N-2 downto 0) <= latchbuf_reg(N-1 downto 1);
        latchbuf_reg(N-1)          <= RESIZE(SIGNED(ramdatao),RAMDATA_W+1);       
         
        colram_reg  <= colram_reg + 1;
        colr_reg    <= colr_reg + 1;
          
        if colram_reg = N-2 then
          rowr_reg <= rowr_reg + 1;
        end if;
               
        if colram_reg = N-1 then
          rowram_reg <= rowram_reg + 1; 
          if rowram_reg = N-1 then
            stage1_reg    <= '0';
            colr_reg      <= (others => '0');
            -- release memory
            rmemsel_reg    <= not rmemsel_reg;
          end if;
          
          -- after this sum databuf_reg is in range of -256 to 254 (min to max) 
          databuf_reg(0)  <= latchbuf_reg(1)+RESIZE(SIGNED(ramdatao),RAMDATA_W+1);
          databuf_reg(1)  <= latchbuf_reg(2)+latchbuf_reg(7);
          databuf_reg(2)  <= latchbuf_reg(3)+latchbuf_reg(6);
          databuf_reg(3)  <= latchbuf_reg(4)+latchbuf_reg(5);
          databuf_reg(4)  <= latchbuf_reg(1)-RESIZE(SIGNED(ramdatao),RAMDATA_W+1);
          databuf_reg(5)  <= latchbuf_reg(2)-latchbuf_reg(7);
          databuf_reg(6)  <= latchbuf_reg(3)-latchbuf_reg(6);
          databuf_reg(7)  <= latchbuf_reg(4)-latchbuf_reg(5);
          
          -- 8 point input latched
          stage2_reg      <= '1';
        end if;     
      end if;
        
      --------------------------------
      -- 2nd stage
      --------------------------------
      if stage2_cnt_reg < N then
        stage2_cnt_reg <= stage2_cnt_reg + 1;
        
        -- output data valid
        odv_d0    <= '1';
  
        -- increment column counter
        col_reg   <= col_reg + 1;
        
        -- finished processing one input row
        if col_reg = N - 1 then
          row_reg         <= row_reg + 1;
        end if;  
      end if;
        
      if stage2_reg = '1' then
        stage2_cnt_reg <= (others => '0');
        col_reg        <= (0=>'1',others => '0');
      end if;
      --------------------------------
      
      ----------------------------------
      -- wait for new data
      ----------------------------------
      -- one of ram buffers has new data, process it
      if dataready = '1' and dataready_2_reg = '0'  then
        stage1_reg    <= '1';
        -- to account for 1T RAM delay, increment RAM address counter
        colram_reg    <= (others => '0');
        colr_reg      <= (0=>'1',others => '0');
        datareadyack  <= '1';
      end if;
      ----------------------------------
      
      
    end if;
  end process;
  
  p_data_pipe : process(CLK, RST)
  begin
    if RST = '1' then
      even_not_odd         <= '0';
      even_not_odd_d1      <= '0';
      even_not_odd_d2      <= '0';
      even_not_odd_d3      <= '0';
      even_not_odd_d4      <= '0';
      odv_d1               <= '0';
      odv_d2               <= '0';
      odv_d3               <= '0';
      odv_d4               <= '0';
      odv_d5               <= '0';
      dcto_1               <= (others => '0');
      dcto_2               <= (others => '0');
      dcto_3               <= (others => '0');
      dcto_4               <= (others => '0');
      dcto_5               <= (others => '0');
    elsif CLK'event and CLK = '1' then
      even_not_odd    <= stage2_cnt_reg(0);
      even_not_odd_d1 <= even_not_odd;
      even_not_odd_d2 <= even_not_odd_d1;
      even_not_odd_d3 <= even_not_odd_d2;
      even_not_odd_d4 <= even_not_odd_d3;
      odv_d1          <= odv_d0;
      odv_d2          <= odv_d1;
      odv_d3          <= odv_d2;
      odv_d4          <= odv_d3;
      odv_d5          <= odv_d4;
      
      if even_not_odd = '0' then
        dcto_1 <= STD_LOGIC_VECTOR(RESIZE
          (RESIZE(SIGNED(romedatao(0)),DA2_W) + 
          (RESIZE(SIGNED(romedatao(1)),DA2_W-1) & '0') +
          (RESIZE(SIGNED(romedatao(2)),DA2_W-2) & "00"),
          DA2_W));
      else
        dcto_1 <= STD_LOGIC_VECTOR(RESIZE
          (RESIZE(SIGNED(romodatao(0)),DA2_W) + 
          (RESIZE(SIGNED(romodatao(1)),DA2_W-1) & '0') +
          (RESIZE(SIGNED(romodatao(2)),DA2_W-2) & "00"),
          DA2_W));
      end if;
      
      if even_not_odd_d1 = '0' then
        dcto_2 <= STD_LOGIC_VECTOR(RESIZE
          (signed(dcto_1) + 
          (RESIZE(SIGNED(romedatao_d1(3)),DA2_W-3) & "000") +
          (RESIZE(SIGNED(romedatao_d1(4)),DA2_W-4) & "0000"),
          DA2_W));
      else
        dcto_2 <= STD_LOGIC_VECTOR(RESIZE
          (signed(dcto_1) + 
          (RESIZE(SIGNED(romodatao_d1(3)),DA2_W-3) & "000") +
          (RESIZE(SIGNED(romodatao_d1(4)),DA2_W-4) & "0000"),
          DA2_W)); 
      end if;
      
      if even_not_odd_d2 = '0' then
        dcto_3 <= STD_LOGIC_VECTOR(RESIZE
          (signed(dcto_2) + 
          (RESIZE(SIGNED(romedatao_d2(5)),DA2_W-5) & "00000") +
          (RESIZE(SIGNED(romedatao_d2(6)),DA2_W-6) & "000000"),
          DA2_W));
      else
        dcto_3 <= STD_LOGIC_VECTOR(RESIZE
          (signed(dcto_2) + 
          (RESIZE(SIGNED(romodatao_d2(5)),DA2_W-5) & "00000") +
          (RESIZE(SIGNED(romodatao_d2(6)),DA2_W-6) & "000000"),
          DA2_W)); 
      end if;
      
      if even_not_odd_d3 = '0' then
        dcto_4 <= STD_LOGIC_VECTOR(RESIZE
          (signed(dcto_3) +
          (RESIZE(SIGNED(romedatao_d3(7)),DA2_W-7) & "0000000") +
          (RESIZE(SIGNED(romedatao_d3(8)),DA2_W-8) & "00000000"),
          DA2_W));
      else
        dcto_4 <= STD_LOGIC_VECTOR(RESIZE
          (signed(dcto_3) + 
          (RESIZE(SIGNED(romodatao_d3(7)),DA2_W-7) & "0000000") +
          (RESIZE(SIGNED(romodatao_d3(8)),DA2_W-8) & "00000000"),
          DA2_W)); 
      end if;
      
      if even_not_odd_d4 = '0' then
        dcto_5 <= STD_LOGIC_VECTOR(RESIZE
          (signed(dcto_4) +
          (RESIZE(SIGNED(romedatao_d4(9)),DA2_W-9) & "000000000") -
          (RESIZE(SIGNED(romedatao_d4(10)),DA2_W-10) & "0000000000"),
          DA2_W));
      else
        dcto_5 <= STD_LOGIC_VECTOR(RESIZE
          (signed(dcto_4) + 
          (RESIZE(SIGNED(romodatao_d4(9)),DA2_W-9) & "000000000") -
          (RESIZE(SIGNED(romodatao_d4(10)),DA2_W-10) & "0000000000"),
          DA2_W)); 
      end if;
    end if;
  end process;
  
  dcto <= dcto_5(DA2_W-1 downto 12);
  odv  <= odv_d5;
  
  p_romaddr : process(CLK, RST)
  begin
    if RST = '1' then
      romeaddro   <= (others => (others => '0')); 
      romoaddro   <= (others => (others => '0')); 
    elsif CLK'event and CLK = '1' then
      for i in 0 to 10 loop
        -- read precomputed MAC results from LUT
        romeaddro(i) <= STD_LOGIC_VECTOR(col_reg(RAMADRR_W/2-1 downto 1)) & 
                 databuf_reg(0)(i) & 
                 databuf_reg(1)(i) &
                 databuf_reg(2)(i) &
                 databuf_reg(3)(i);
        -- odd
        romoaddro(i) <= STD_LOGIC_VECTOR(col_reg(RAMADRR_W/2-1 downto 1)) & 
                 databuf_reg(4)(i) & 
                 databuf_reg(5)(i) &
                 databuf_reg(6)(i) &
                 databuf_reg(7)(i);
      end loop;
    end if;
  end process;

  p_romdatao_dly : process(CLK, RST)
  begin
    if RST = '1' then
      romedatao_d1    <= (others => (others => '0'));       
      romodatao_d1    <= (others => (others => '0'));
      romedatao_d2    <= (others => (others => '0'));       
      romodatao_d2    <= (others => (others => '0'));
      romedatao_d3    <= (others => (others => '0'));       
      romodatao_d3    <= (others => (others => '0'));
      romedatao_d4    <= (others => (others => '0'));       
      romodatao_d4    <= (others => (others => '0'));
    elsif CLK'event and CLK = '1' then
      romedatao_d1   <= romedatao;
      romodatao_d1   <= romodatao;
      romedatao_d2   <= romedatao_d1;
      romodatao_d2   <= romodatao_d1;
      romedatao_d3   <= romedatao_d2;
      romodatao_d3   <= romodatao_d2;
      romedatao_d4   <= romedatao_d3;
      romodatao_d4   <= romodatao_d3;
    end if;
  end process;
	
end RTL;
--------------------------------------------------------------------------------

