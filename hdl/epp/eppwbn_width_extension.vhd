-------------------------------------------------------------------------------------------------100
--| Modular Oscilloscope
--| UNSL - Argentine
--|
--| Version: 0.01
--| Tested in: Actel APA300
--| Tested in: Actel A3PE1500
--|   Board: RVI Prototype Board + LP Data Conversion Daughter Board
--|-------------------------------------------------------------------------------------------------
--| Description:
--| 	EPP - Wishbone bridge. 
--|	  Convert 8 to 16 bits width data bus
--|-------------------------------------------------------------------------------------------------
--| File history:
--|   0.01  | mar-2009 | First release
----------------------------------------------------------------------------------------------------
--| Copyright © 2008, Facundo Aguilera.
--|
--| This VHDL design file is an open design; you can redistribute it and/or
--| modify it and/or implement it after contacting the author.

--| Wishbone Rev. B.3 compatible
----------------------------------------------------------------------------------------------------




-- COMO USAR:
-- Puente entre un bus de datos de 8 bit (esclavo) y otro de 16 bit (maestro). cada dos acciones del
-- lado de 8 bit realiza una en en lado de 16. Posee un timer configurable con el que vuelve al 
-- estado inicial luego de sierto tiempo (ningun byte leido). También vuelve al estado inicial al 
-- hacer un cambio de dirección, por lo que puede realizarse una sincronización inicial haciendo un
-- cambio de dirección de escritura.


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.eppwbn_pkg.all;

entity eppwbn_width_extension is 
  generic (
    TIME_OUT_VALUE: integer  := 512;
    TIME_OUT_WIDTH: integer  := 9
  );
  port(
    -- Slave signals
    DAT_I_sl: in  std_logic_vector (7 downto 0);
    DAT_O_sl: out std_logic_vector (7 downto 0);
    ADR_I_sl: in  std_logic_vector (7 downto 0);
    CYC_I_sl: in  std_logic;  
    STB_I_sl: in  std_logic;  
    ACK_O_sl: out std_logic ;
    WE_I_sl:  in  std_logic;
    
            
    --  Master signals
    DAT_I_ma: in  std_logic_vector (15 downto 0);
    DAT_O_ma: out std_logic_vector (15 downto 0);
    ADR_O_ma: out std_logic_vector (7 downto 0);
    CYC_O_ma: out std_logic;  
    STB_O_ma: out std_logic;  
    ACK_I_ma: in  std_logic ;
    WE_O_ma:  out std_logic;
    
    -- Common signals
    RST_I: in std_logic;  
    CLK_I: in std_logic
  );
end entity eppwbn_width_extension;


architecture arch_0 of eppwbn_width_extension is
  type StateType is (
          st_low,  
          st_high
          );
	signal next_state, present_state: StateType;
	
  signal dat_reg, adr_reg: std_logic_vector (7 downto 0);  -- Almacena temporalmente las entradas
  signal timer, time_out_ref: std_logic_vector (TIME_OUT_WIDTH - 1 downto 0);

begin

  ADR_O_ma <= ADR_I_sl;
  time_out_ref <= conv_std_logic_vector(TIME_OUT_VALUE, TIME_OUT_WIDTH);
  
  P_state_comb: process(DAT_I_sl,CYC_I_sl,STB_I_sl,WE_I_sl,ACK_I_ma,present_state,ADR_I_sl,
                        DAT_I_ma,dat_reg,adr_reg,timer,time_out_ref)
  begin
   
    case present_state is
      
      -- Escritura: Señales de hadshake provistas por el módulo. Se guarda byte bajo.
      -- Lectura: Señales de hadshake provistas por fuente. Se guarda byte alto.
      when st_low => 
        WE_O_ma <= '0';
        DAT_O_ma <= (others => '0');
        DAT_O_sl <= DAT_I_ma(7 downto 0);
        if WE_I_sl = '1' then
          CYC_O_ma <= '0'; -- Esperar hasta recibir el proximo byte
          STB_O_ma <= '0';
          ACK_O_sl <= CYC_I_sl and STB_I_sl; -- Genera autorespuesta
        else 
          CYC_O_ma <= CYC_I_sl; 
          STB_O_ma <= STB_I_sl;
          ACK_O_sl <= ACK_I_ma;
        end if;

        
      
        if (CYC_I_sl = '1' and STB_I_sl = '1') and (WE_I_sl = '1' or ACK_I_ma = '1') then
          next_state <= st_high;
        else
          next_state <= st_low;
        end if;
      
      -- Escritura: Señales de hadshake provistas por fuentepor el módulo. 
      -- Lectura: Señales de hadshake provistas por el módulo. 
      when others => 
        WE_O_ma <= WE_I_sl;
        DAT_O_ma <= DAT_I_sl & dat_reg;
        DAT_O_sl <= dat_reg;
        if adr_reg = ADR_I_sl then
          if WE_I_sl = '1' then
            CYC_O_ma <= CYC_I_sl; -- Usa señales de la fuente
            STB_O_ma <= STB_I_sl; 
            ACK_O_sl <= ACK_I_ma; 
          else
            CYC_O_ma <= '0'; 
            STB_O_ma <= '0';
            ACK_O_sl <= CYC_I_sl and STB_I_sl; -- Genera autorespuesta
          end if;
        else
          CYC_O_ma <= '0';
          STB_O_ma <= '0'; 
          ACK_O_sl <= '0'; 
        end if;

        if  ( (CYC_I_sl = '1' and STB_I_sl = '1' ) and (WE_I_sl /= '1' or ACK_I_ma = '1' ) )
        or ( (CYC_I_sl = '1' and STB_I_sl = '1' ) and (ADR_I_sl /= adr_reg) )
        or (timer >= time_out_ref) then
          next_state <= st_low;
        else
          next_state <= st_high;
        end if;
    end case;
    
  end process;


  P_state_clocked: process(RST_I,CLK_I,next_state,timer)
  begin
    if RST_I = '1' then
      present_state <= st_low;
     
      timer <= (others => '0');
      dat_reg <= (others => '0');
      adr_reg <= (others => '0');
    elsif CLK_I'event and CLK_I = '1' then
      -- Resgistrar los valores si va a cambir al estado st_high
      if next_state = st_high and present_state = st_low then 
        adr_reg <= ADR_I_sl;
        if WE_I_sl = '1' then
          dat_reg <= DAT_I_sl; -- Guarda byte bajo
        else 
          dat_reg <= DAT_I_ma(15 downto 8);
        end if;
      end if;
      
      -- Configuración del timer
      if present_state = st_high then 
        timer <= timer + 1;
      else 
        timer <= (others => '0');
      end if;
      
      -- Cambio de estado
      present_state <= next_state;
    end if;
  end process;

end architecture arch_0;
