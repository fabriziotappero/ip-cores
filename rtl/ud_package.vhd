-------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscompatible_package.all;
-------------------------------------------------------------------------------------------------------------------
package ud_package is
    ---------------------------------------------
    function SRLg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function SRL_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function SLLg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function SLL_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function SRAg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function SRA_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function SLAg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function SLA_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
	 
    function RRLg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function RRL_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function RLLg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function RLL_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function RRAg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function RRA_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function RLAg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
    function RLA_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord;
	 
    function SRLCg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function SRLC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function SLLCg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function SLLC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function SRACg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function SRAC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function SLACg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function SLAC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;

    function RRLCg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function RRLC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function RLLCg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function RLLC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function RRACg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function RRAC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function RLACg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    function RLAC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry;
    ---------------------------------------------
end package;
package body ud_package is
    --
    -- Estas funcoes necessitam uma validacao. 
    -- Alguns casos nao estao completamente claros no texto original.
    --
    -- C - Carry
    -- S - Signal (bit 31)
    -- bn - bit n
    -- |bm -> bn| - bit m to bit n shift to right
    -- |bm <- bn| - bit m to bit n shift to left
    ---------------------------------------------
    -- Shift Right Logical
    -- 0-> |b31 -> b0|
    --
    -- Generic
    function SRLg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        VSource1((TRiscoWord'high-to_integer(unsigned(FT2))) downto 0):=Source1(TRiscoWord'high downto to_integer(unsigned(FT2)));
        VSource1(TRiscoWord'high downto (TRiscoWord'high-to_integer(unsigned(FT2))+1)):=(others =>'0');
        return VSource1;
    end function SRLg_F;
    --
    -- Original (only 1,2,4,8,16)
    function SRL_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        case to_integer(unsigned(FT2)) is
            when 1 =>
                VSource1(TRiscoWord'high-1 downto 0):=Source1(TRiscoWord'high downto 1);
                VSource1(TRiscoWord'high):='0';
            when 2 =>
                VSource1(TRiscoWord'high-2 downto 0):=Source1(TRiscoWord'high downto 2);
                VSource1(TRiscoWord'high downto TRiscoWord'high-1):=(others =>'0');
            when 4 =>
                VSource1(TRiscoWord'high-4 downto 0):=Source1(TRiscoWord'high downto 4);
                VSource1(TRiscoWord'high downto TRiscoWord'high-3):=(others =>'0');
            when 8 =>
                VSource1(TRiscoWord'high-8 downto 0):=Source1(TRiscoWord'high downto 8);
                VSource1(TRiscoWord'high downto TRiscoWord'high-7):=(others =>'0');
           when others => --16
                VSource1(TRiscoWord'high-16 downto 0):=Source1(TRiscoWord'high downto 16);
                VSource1(TRiscoWord'high downto TRiscoWord'high-15):=(others =>'0');
        end case;
        return VSource1;
    end function SRL_F;
    ---------------------------------------------
    -- Shift Left Logical
    -- |b31 <- b0| <-0
    --
    -- Generic
    function SLLg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        VSource1(TRiscoWord'high downto to_integer(unsigned(FT2))):=Source1(TRiscoWord'high-to_integer(unsigned(FT2)) downto 0);
        VSource1(to_integer(unsigned(FT2))-1 downto 0):=(others =>'0');
        return VSource1;
    end function SLLg_F;
    --
    -- Original (only 1,2,4,8,6)
    function SLL_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        case to_integer(unsigned(FT2)) is
            when 1 =>
                VSource1(TRiscoWord'high downto 1):=Source1(TRiscoWord'high-1 downto 0);
                VSource1(0):='0';            
            when 2 =>
                VSource1(TRiscoWord'high downto 2):=Source1(TRiscoWord'high-2 downto 0);
                VSource1(1 downto 0):=(others =>'0');            
            when 4 =>
                VSource1(TRiscoWord'high downto 4):=Source1(TRiscoWord'high-4 downto 0);
                VSource1(3 downto 0):=(others =>'0');            
            when 8=>
                VSource1(TRiscoWord'high downto 8):=Source1(TRiscoWord'high-8 downto 0);
                VSource1(7 downto 0):=(others =>'0');            
            when others => -- 16
                VSource1(TRiscoWord'high downto 16):=Source1(TRiscoWord'high-16 downto 0);
                VSource1(15 downto 0):=(others =>'0');            
        end case;
        return VSource1;
    end function SLL_F;
    ---------------------------------------------
    -- Shift Right Arithmetic
    -- S-> |b30 -> b0|
    --
    -- Generic
    function SRAg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        VSource1(TRiscoWord'high-to_integer(unsigned(FT2)) downto 0):=Source1(TRiscoWord'high downto to_integer(unsigned(FT2)));
        VSource1(TRiscoWord'high downto TRiscoWord'high-to_integer(unsigned(FT2))+1):=(others => Source1(Source1'high));
        return VSource1;
    end function SRAg_F;
    --
    -- Original (only 1,2,4,8,16)
    function SRA_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        case to_integer(unsigned(FT2)) is
            when 1 =>       
                VSource1(TRiscoWord'high-1 downto 0):=Source1(TRiscoWord'high downto 1);
                VSource1(TRiscoWord'high):=Source1(Source1'high);
            when 2 =>           
                VSource1(TRiscoWord'high-2 downto 0):=Source1(TRiscoWord'high downto 2);
                VSource1(TRiscoWord'high downto TRiscoWord'high-1):=(others =>Source1(Source1'high));
            when 4 =>
                VSource1(TRiscoWord'high-4 downto 0):=Source1(TRiscoWord'high downto 4);
                VSource1(TRiscoWord'high downto TRiscoWord'high-3):=(others =>Source1(Source1'high));
            when 8=>
                VSource1(TRiscoWord'high-8 downto 0):=Source1(TRiscoWord'high downto 8);
                VSource1(TRiscoWord'high downto TRiscoWord'high-7):=(others =>Source1(Source1'high));
            when others => -- 16 
                VSource1(TRiscoWord'high-16 downto 0):=Source1(TRiscoWord'high downto 16);
                VSource1(TRiscoWord'high downto TRiscoWord'high-15):=(others =>Source1(Source1'high));
        end case;
        return VSource1;
    end function SRA_F;
    ---------------------------------------------
    -- Shift Left Arithmetic
    -- S |b30 <- b0|
    --
    -- Generic
    function SLAg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        VSource1(TRiscoWord'high):=Source1(TRiscoWord'high);
        VSource1(TRiscoWord'high-1 downto to_integer(unsigned(FT2))):=Source1(TRiscoWord'high-to_integer(unsigned(FT2))-1 downto 0);
        VSource1(to_integer(unsigned(FT2))-1 downto 0):=(others =>'0');
        return VSource1;
    end function SLAg_F;
    --
    -- Original (only 1,2,4,8,6)
    function SLA_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        VSource1(TRiscoWord'high):=Source1(TRiscoWord'high);
        case to_integer(unsigned(FT2)) is
            when 1 =>       
                VSource1(TRiscoWord'high-1 downto 1):=Source1(TRiscoWord'high-2 downto 0);
                VSource1(0):='0';
            when 2 =>           
                VSource1(TRiscoWord'high-1 downto 2):=Source1(TRiscoWord'high-3 downto 0);
                VSource1(1 downto 0):=(others =>'0');
            when 4 =>
                VSource1(TRiscoWord'high-1 downto 4):=Source1(TRiscoWord'high-5 downto 0);
                VSource1(3 downto 0):=(others =>'0');
            when 8=>
                VSource1(TRiscoWord'high-1 downto 8):=Source1(TRiscoWord'high-9 downto 0);
                VSource1(7 downto 0):=(others =>'0');
            when others => -- 16 
                VSource1(TRiscoWord'high-1 downto 16):=Source1(TRiscoWord'high-17 downto 0);
                VSource1(15 downto 0):=(others =>'0');
        end case;
        return VSource1;
    end function SLA_F;
    ---------------------------------------------
    -- Rotate Right Logical
    -- b0-> |b31 -> b0|
    --
    -- Generic
    function RRLg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        VSource1(TRiscoWord'high-to_integer(unsigned(FT2)) downto 0):=Source1(TRiscoWord'high downto to_integer(unsigned(FT2)));
        VSource1(TRiscoWord'high downto TRiscoWord'high-to_integer(unsigned(FT2))+1):=Source1(to_integer(unsigned(FT2))-1 downto 0);
        return VSource1;
    end function RRLg_F;
    --
    -- Original (only 1,2,4,8,6)    
    function RRL_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        case to_integer(unsigned(FT2)) is
            when 1 =>       
                VSource1(TRiscoWord'high-1 downto 0):=Source1(TRiscoWord'high downto 1);
                VSource1(TRiscoWord'high):=Source1(0);
            when 2 =>           
                VSource1(TRiscoWord'high-2 downto 0):=Source1(TRiscoWord'high downto 2);
                VSource1(TRiscoWord'high downto TRiscoWord'high-1):=Source1(1 downto 0);
            when 4 =>
                VSource1(TRiscoWord'high-4 downto 0):=Source1(TRiscoWord'high downto 4);
                VSource1(TRiscoWord'high downto TRiscoWord'high-3):=Source1(3 downto 0);
            when 8=>
                VSource1(TRiscoWord'high-8 downto 0):=Source1(TRiscoWord'high downto 8);
                VSource1(TRiscoWord'high downto TRiscoWord'high-7):=Source1(7 downto 0);
            when others => -- 16 
                VSource1(TRiscoWord'high-16 downto 0):=Source1(TRiscoWord'high downto 16);
                VSource1(TRiscoWord'high downto TRiscoWord'high-15):=Source1(15 downto 0);
        end case;
        return VSource1;
    end function RRL_F;
    ---------------------------------------------
    -- Rotate Left Logical
    -- |b31 <- b0| <-b31
    --
    -- Generic
    function RLLg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        VSource1(TRiscoWord'high downto to_integer(unsigned(FT2))):=Source1(TRiscoWord'high-to_integer(unsigned(FT2)) downto 0);
        VSource1(to_integer(unsigned(FT2))-1 downto 0):=Source1(TRiscoWord'high downto TRiscoWord'high-to_integer(unsigned(FT2))+1);
        return VSource1;
    end function RLLg_F;
    --
    -- Original (only 1,2,4,8,6)
    function RLL_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        case to_integer(unsigned(FT2)) is
            when 1 =>      
                VSource1(TRiscoWord'high downto 1):=Source1(TRiscoWord'high-1 downto 0);
                VSource1(0):=Source1(TRiscoWord'high);            
            when 2 =>           
                VSource1(TRiscoWord'high downto 2):=Source1(TRiscoWord'high-2 downto 0);
                VSource1(1 downto 0):=Source1(TRiscoWord'high downto TRiscoWord'high-1);            
            when 4 =>
                VSource1(TRiscoWord'high downto 4):=Source1(TRiscoWord'high-4 downto 0);
                VSource1(3 downto 0):=Source1(TRiscoWord'high downto TRiscoWord'high-3);            
            when 8 =>
                VSource1(TRiscoWord'high downto 8):=Source1(TRiscoWord'high-8 downto 0);
                VSource1(7 downto 0):=Source1(TRiscoWord'high downto TRiscoWord'high-7);            
            when others => -- 16 
                VSource1(TRiscoWord'high downto 16):=Source1(TRiscoWord'high-16 downto 0);
                VSource1(15 downto 0):=Source1(TRiscoWord'high downto TRiscoWord'high-15);            
        end case;
        return VSource1;
    end function RLL_F;
    ---------------------------------------------
    -- Rotate Right Arithmetical
    -- b0-> |b30 -> b0|
    --
    -- Generic
    function RRAg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        VSource1(TRiscoWord'high-to_integer(unsigned(FT2))-1 downto 0):=Source1(TRiscoWord'high-1 downto to_integer(unsigned(FT2)));
        VSource1(TRiscoWord'high-1 downto TRiscoWord'high-to_integer(unsigned(FT2))):=Source1(to_integer(unsigned(FT2))-1 downto 0);
        VSource1(TRiscoWord'high):=Source1(TRiscoWord'high);
        return VSource1;
    end function RRAg_F;
    --
    -- Original (only 1,2,4,8,6)    
    function RRA_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        VSource1(TRiscoWord'high):=Source1(TRiscoWord'high);
        case to_integer(unsigned(FT2)) is
            when 1 =>       
                VSource1(TRiscoWord'high-2 downto 0):=Source1(TRiscoWord'high-1 downto 1);
                VSource1(TRiscoWord'high-1):=Source1(0);
            when 2 =>           
                VSource1(TRiscoWord'high-3 downto 0):=Source1(TRiscoWord'high-1 downto 2);
                VSource1(TRiscoWord'high-1 downto TRiscoWord'high-2):=Source1(1 downto 0);
            when 4 =>
                VSource1(TRiscoWord'high-5 downto 0):=Source1(TRiscoWord'high-1 downto 4);
                VSource1(TRiscoWord'high-1 downto TRiscoWord'high-4):=Source1(3 downto 0);
            when 8=>
                VSource1(TRiscoWord'high-9 downto 0):=Source1(TRiscoWord'high-1 downto 8);
                VSource1(TRiscoWord'high-1 downto TRiscoWord'high-8):=Source1(7 downto 0);            
            when others => -- 16 
                VSource1(TRiscoWord'high-17 downto 0):=Source1(TRiscoWord'high-1 downto 16);
                VSource1(TRiscoWord'high-1 downto TRiscoWord'high-16):=Source1(15 downto 0);            
        end case;
        return VSource1;
    end function RRA_F;
    ---------------------------------------------
    -- Rotate Left Arithmetical
    -- |b31 <- b0| <-b31
    --
    -- Generic
    function RLAg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        VSource1(TRiscoWord'high-1 downto to_integer(unsigned(FT2))):=Source1(TRiscoWord'high-to_integer(unsigned(FT2))-1 downto 0);
        VSource1(to_integer(unsigned(FT2))-1 downto 0):=Source1(TRiscoWord'high-1 downto TRiscoWord'high-to_integer(unsigned(FT2)));
        VSource1(TRiscoWord'high):=Source1(TRiscoWord'high);
        return VSource1;
    end function RLAg_F;
    --
    -- Original (only 1,2,4,8,6)
    function RLA_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0)) return TRiscoWord is
        variable VSource1 : TRiscoWord;
    begin
        VSource1(TRiscoWord'high):=Source1(TRiscoWord'high);
        case to_integer(unsigned(FT2)) is
            when 1 =>      
                VSource1(TRiscoWord'high-1 downto 1):=Source1(TRiscoWord'high-2 downto 0);
                VSource1(0):=Source1(TRiscoWord'high-1);         
            when 2 =>           
                VSource1(TRiscoWord'high-1 downto 2):=Source1(TRiscoWord'high-3 downto 0);
                VSource1(1 downto 0):=Source1(TRiscoWord'high-1 downto TRiscoWord'high-2);         
            when 4 =>
                VSource1(TRiscoWord'high-1 downto 4):=Source1(TRiscoWord'high-5 downto 0);
                VSource1(3 downto 0):=Source1(TRiscoWord'high-1 downto TRiscoWord'high-4);         
            when 8=>
                VSource1(TRiscoWord'high-1 downto 8):=Source1(TRiscoWord'high-9 downto 0);
                VSource1(7 downto 0):=Source1(TRiscoWord'high-1 downto TRiscoWord'high-8);         
            when others => -- 16 
                VSource1(TRiscoWord'high-1 downto 16):=Source1(TRiscoWord'high-17 downto 0);
                VSource1(15 downto 0):=Source1(TRiscoWord'high-1 downto TRiscoWord'high-16);         
        end case;
        return VSource1;
    end function RLA_F;
    
    ---------------------------------------------
    -- Shift Right Logical Carry
    -- 0-> C-> |b31 -> b0| 
    -- Diss. Risco, 3.4.1 d) O carry comporta-se como bit 32
    -- Generic
    function SRLCg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Cy;
        VSource1(VSource1'high-1 downto 0):=Source1;
        VSource2((VSource2'high-to_integer(unsigned(FT2))) downto 0):=VSource1(VSource1'high downto to_integer(unsigned(FT2)));
        VSource2(VSource2'high downto (VSource2'high-to_integer(unsigned(FT2))+1)):=(others => '0');
        return VSource2;
    end function SRLCg_F;
    --
    -- Original (only 1,2,4,8,16)
    function SRLC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Cy;
        VSource1(VSource1'high-1 downto 0):=Source1;    
        case to_integer(unsigned(FT2)) is
            when 1 =>
                VSource2(VSource2'high-1 downto 0):=VSource1(VSource1'high downto 1);
                VSource2(VSource2'high):='0';
            when 2 =>
                VSource2(VSource2'high-2 downto 0):=VSource1(VSource1'high downto 2);
                VSource2(VSource2'high downto VSource2'high-1):=(others => '0');
            when 4 =>
                VSource2(VSource2'high-4 downto 0):=VSource1(VSource1'high downto 4);
                VSource2(VSource2'high downto VSource2'high-3):=(others => '0');
            when 8 =>
                VSource2(VSource2'high-8 downto 0):=VSource1(VSource1'high downto 8);
                VSource2(VSource2'high downto VSource2'high-7):=(others => '0');
            when others => --16
                VSource2(VSource2'high-16 downto 0):=VSource1(VSource1'high downto 16);
                VSource2(VSource2'high downto VSource2'high-15):=(others => '0');
        end case;
        return VSource2;
    end function SRLC_F;
    ---------------------------------------------
    -- Shift Left Logical Carry
    -- C <-|b31 <- b0| <-0
    -- Diss. Risco, 3.4.1 d) O carry comporta-se como bit 32
    -- Generic
    function SLLCg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Cy;
        VSource1(VSource1'high-1 downto 0):=Source1;
        VSource2((VSource2'high) downto to_integer(unsigned(FT2))):=VSource1(VSource1'high-to_integer(unsigned(FT2)) downto 0);
        VSource2((to_integer(unsigned(FT2))-1) downto 0):=(others => '0');
        return VSource2;
    end function SLLCg_F;
    --
    -- Original (only 1,2,4,8,16)
    function SLLC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Cy;
        VSource1(VSource1'high-1 downto 0):=Source1;    
        case to_integer(unsigned(FT2)) is
            when 1 =>
                VSource2(VSource2'high downto 1):=VSource1(VSource1'high-1 downto 0);
                VSource2(0):='0';
            when 2 =>
                VSource2(VSource2'high downto 2):=VSource1(VSource1'high-2 downto 0);
                VSource2(1 downto 0):=(others => '0');
            when 4 =>
                VSource2(VSource2'high downto 4):=VSource1(VSource1'high-4 downto 0);
                VSource2(3 downto 0):=(others => '0');
            when 8 =>
                VSource2(VSource2'high downto 8):=VSource1(VSource1'high-8 downto 0);
                VSource2(7 downto 0):=(others => '0');
            when others => --16
                VSource2(VSource2'high downto 16):=VSource1(VSource1'high-16 downto 0);
                VSource2(15 downto 0):=(others => '0');
        end case;
        return VSource2;
    end function SLLC_F;    
    ---------------------------------------------
    -- Shift Right Arithmetical Carry
    -- 0-> C-> |b31 -> b0| 
    -- Diss. Risco, 3.4.1 d) O carry comporta-se como bit 32
    -- Generic
    function SRACg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSourceR : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Source1(Source1'high);
        VSource1(VSource1'high-1):=Cy;
        VSource1(VSource1'high-2 downto 0):=Source1(Source1'high-1 downto 0);
        
        VSource2(VSource2'high-to_integer(unsigned(FT2))-1 downto 0):=VSource1(VSource1'high-1 downto to_integer(unsigned(FT2)));
        VSource2(VSource2'high-1 downto VSource2'high-to_integer(unsigned(FT2))):=(others => VSource1(VSource1'high));       
        VSource2(VSource2'high):=VSource1(VSource1'high);

        VSourceR:=VSource2(VSource2'high-1)&VSource2(VSource2'high)&VSource2(VSource2'high-2 downto 0);
        return VSourceR;        
    end function SRACg_F;
    --
    -- Original (only 1,2,4,8,16)
    function SRAC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSourceR : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Source1(Source1'high);
        VSource1(VSource1'high-1):=Cy;
        VSource1(VSource1'high-2 downto 0):=Source1(Source1'high-1 downto 0);
        case to_integer(unsigned(FT2)) is
            when 1 =>     
                VSource2(VSource2'high-2 downto 0):=VSource1(VSource1'high-1 downto 1);
                VSource2(VSource2'high-1):=VSource1(VSource1'high);
                VSource2(VSource2'high):=VSource1(VSource1'high);
            when 2 =>
                VSource2(VSource2'high-3 downto 0):=VSource1(VSource1'high-1 downto 2);
                VSource2(VSource2'high-1 downto VSource2'high-2):=(others => VSource1(VSource1'high));       
                VSource2(VSource2'high):=VSource1(VSource1'high);
            when 4 =>
                VSource2(VSource2'high-5 downto 0):=VSource1(VSource1'high-1 downto 4);
                VSource2(VSource2'high-1 downto VSource2'high-4):=(others => VSource1(VSource1'high));       
                VSource2(VSource2'high):=VSource1(VSource1'high);
            when 8 =>
                VSource2(VSource2'high-9 downto 0):=VSource1(VSource1'high-1 downto 8);
                VSource2(VSource2'high-1 downto VSource2'high-8):=(others => VSource1(VSource1'high));       
                VSource2(VSource2'high):=VSource1(VSource1'high);
            when others => --16
                VSource2(VSource2'high-17 downto 0):=VSource1(VSource1'high-1 downto 16);
                VSource2(VSource2'high-1 downto VSource2'high-16):=(others => VSource1(VSource1'high));       
                VSource2(VSource2'high):=VSource1(VSource1'high);
        end case;
        VSourceR:=VSource2(VSource2'high-1)&VSource2(VSource2'high)&VSource2(VSource2'high-2 downto 0);
        return VSourceR;        
    end function SRAC_F;
    ---------------------------------------------
    -- Shift Left Arithmetical Carry
    -- C <-|b31 <- b0| <-0
    -- Diss. Risco, 3.4.1 d) O carry comporta-se como bit 32
    -- Generic
    function SLACg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSourceR : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Source1(Source1'high);
        VSource1(VSource1'high-1):=Cy;
        VSource1(VSource1'high-2 downto 0):=Source1(Source1'high-1 downto 0);
        
        VSource2(VSource2'high-1 downto to_integer(unsigned(FT2))):=VSource1(VSource1'high-1-to_integer(unsigned(FT2)) downto 0);
        VSource2(to_integer(unsigned(FT2))-1 downto 0):=(others => '0');
        VSource2(VSource2'high):=VSource1(VSource1'high);
        
        VSourceR:=VSource2(VSource2'high-1)&VSource2(VSource2'high)&VSource2(VSource2'high-2 downto 0);
        return VSourceR;
    end function SLACg_F;
    --
    -- Original (only 1,2,4,8,16)
    function SLAC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSourceR : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Source1(Source1'high);
        VSource1(VSource1'high-1):=Cy;
        VSource1(VSource1'high-2 downto 0):=Source1(Source1'high-1 downto 0);   
        case to_integer(unsigned(FT2)) is
            when 1 =>
                VSource2(VSource2'high-1 downto 1):=VSource1(VSource1'high-2 downto 0);
                VSource2(0):='0';
                VSource2(VSource2'high):=VSource1(VSource1'high);
            when 2 =>
                VSource2(VSource2'high-1 downto 2):=VSource1(VSource1'high-3 downto 0);
                VSource2(1 downto 0):=(others => '0');
                VSource2(VSource2'high):=VSource1(VSource1'high);
            when 4 =>
                VSource2(VSource2'high-1 downto 4):=VSource1(VSource1'high-5 downto 0);
                VSource2(3 downto 0):=(others => '0');
                VSource2(VSource2'high):=VSource1(VSource1'high);
            when 8 =>
                VSource2(VSource2'high-1 downto 8):=VSource1(VSource1'high-9 downto 0);
                VSource2(7 downto 0):=(others => '0');
                VSource2(VSource2'high):=VSource1(VSource1'high);
            when others => --16
                VSource2(VSource2'high-1 downto 16):=VSource1(VSource1'high-17 downto 0);
                VSource2(15 downto 0):=(others => '0');
                VSource2(VSource2'high):=VSource1(VSource1'high);
        end case;
        VSourceR:=VSource2(VSource2'high-1)&VSource2(VSource2'high)&VSource2(VSource2'high-2 downto 0);
        return VSourceR;
    end function SLAC_F;    
    ---------------------------------------------
    -- Rotate Right Logical through carry
    -- C-> |b31 -> b0| -> C
    --
    -- Generic
    function RRLCg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Cy;
        VSource1(VSource1'high-1 downto 0):=Source1;       
        VSource2(VSource2'high-to_integer(unsigned(FT2)) downto 0):=VSource1(VSource1'high downto to_integer(unsigned(FT2)));
        VSource2(VSource2'high downto VSource2'high-to_integer(unsigned(FT2))+1):=VSource1(to_integer(unsigned(FT2))-1 downto 0);
        return VSource2;
    end function RRLCg_F;
    --
    -- Original (only 1,2,4,8,6)
    function RRLC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Cy;
        VSource1(VSource1'high-1 downto 0):=Source1;
        case to_integer(unsigned(FT2)) is
            when 1 =>       
                VSource2(VSource2'high-1 downto 0):=VSource1(VSource1'high downto 1);
                VSource2(VSource2'high):=VSource1(0);
            when 2 =>           
                VSource2(VSource2'high-2 downto 0):=VSource1(VSource1'high downto 2);
                VSource2(VSource2'high downto VSource2'high-1):=VSource1(1 downto 0);
            when 4 =>
                VSource2(VSource2'high-4 downto 0):=VSource1(VSource1'high downto 4);
                VSource2(VSource2'high downto VSource2'high-3):=VSource1(3 downto 0);
            when 8=>
                VSource2(VSource2'high-8 downto 0):=VSource1(VSource1'high downto 8);
                VSource2(VSource2'high downto VSource2'high-7):=VSource1(7 downto 0);
            when others => -- 16 
                VSource2(VSource2'high-16 downto 0):=VSource1(VSource1'high downto 16);
                VSource2(VSource2'high downto VSource2'high-15):=VSource1(15 downto 0);
        end case;        
        return VSource2;
    end function RRLC_F;
    ---------------------------------------------
    -- Rotate Left Logical through carry
    -- C <-|b31 <- b0| <-C
    -- 
    -- Generic
    function RLLCg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Cy;
        VSource1(VSource1'high-1 downto 0):=Source1;
        VSource2(VSource2'high downto to_integer(unsigned(FT2))):=Source1(VSource1'high-to_integer(unsigned(FT2)) downto 0);
        VSource2(to_integer(unsigned(FT2))-1 downto 0):=VSource1(VSource1'high downto VSource1'high-to_integer(unsigned(FT2))+1);
        return VSource2;
    end function RLLCg_F;
    --
    -- Original (only 1,2,4,8,6)
    function RLLC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(VSource1'high):=Cy;
        VSource1(VSource1'high-1 downto 0):=Source1;
        case to_integer(unsigned(FT2)) is
            when 1 =>       
                VSource2(VSource2'high downto 1):=Source1(VSource1'high-1 downto 0);
                VSource2(0):=VSource1(VSource1'high);
            when 2 =>           
                VSource2(VSource2'high downto 2):=Source1(VSource1'high-2 downto 0);
                VSource2(1 downto 0):=VSource1(VSource2'high downto VSource1'high-1);
            when 4 =>
                VSource2(VSource2'high downto 4):=Source1(VSource1'high-4 downto 0);
                VSource2(3 downto 0):=VSource1(VSource2'high downto VSource1'high-3);
            when 8=>
                VSource2(VSource2'high downto 8):=Source1(VSource1'high-8 downto 0);
                VSource2(7 downto 0):=VSource1(VSource2'high downto VSource1'high-7);
            when others => -- 16 
                VSource2(VSource2'high downto 16):=Source1(VSource1'high-16 downto 0);
                VSource2(15 downto 0):=VSource1(VSource2'high downto VSource1'high-15);
        end case;        
        return VSource2;
    end function RLLC_F;    
    ---------------------------------------------
    -- Rotate Right Arithmetical through carry
    -- C-> |b30 -> b0| -> C
    --
    -- Generic
    function RRACg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSourceR : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(0):=Cy;
        VSource1(VSource1'high downto 1):=Source1;
        
        VSource2(VSource2'high-to_integer(unsigned(FT2))-1 downto 0):=VSource1(VSource1'high-1 downto to_integer(unsigned(FT2)));
        VSource2(VSource2'high-1 downto VSource2'high-to_integer(unsigned(FT2))):=VSource1(to_integer(unsigned(FT2))-1 downto 0);
        VSource2(VSource2'high):=VSource1(VSource1'high);
        VSourceR:=VSource2(0) & VSource2(VSource2'high downto 1);       
        return VSourceR;
    end function RRACg_F;
    --
    -- Original (only 1,2,4,8,6)
    function RRAC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSourceR : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(0):=Cy;
        VSource1(VSource1'high downto 1):=Source1;
        VSource2(VSource2'high):=VSource1(VSource1'high);
        case to_integer(unsigned(FT2)) is
            when 1 =>       
                VSource2(VSource2'high-2 downto 0):=VSource1(VSource1'high-1 downto 1);
                VSource2(VSource2'high-1):=VSource1(0);
            when 2 =>           
                VSource2(VSource2'high-3 downto 0):=VSource1(VSource1'high-1 downto 2);
                VSource2(VSource2'high-1 downto VSource2'high-2):=VSource1(1 downto 0);
            when 4 =>
                VSource2(VSource2'high-5 downto 0):=VSource1(VSource1'high-1 downto 4);
                VSource2(VSource2'high-1 downto VSource2'high-4):=VSource1(3 downto 0);
            when 8=>
                VSource2(VSource2'high-9 downto 0):=VSource1(VSource1'high-1 downto 8);
                VSource2(VSource2'high-1 downto VSource2'high-8):=VSource1(7 downto 0);
            when others => -- 16 
                VSource2(VSource2'high-17 downto 0):=VSource1(VSource1'high-1 downto 16);
                VSource2(VSource2'high-1 downto VSource2'high-16):=VSource1(15 downto 0);
            end case;        
        VSourceR:=VSource2(0) & VSource2(VSource2'high downto 1);       
        return VSourceR;
    end function RRAC_F;
    ---------------------------------------------
    -- Rotate Left Arithmetical through carry
    -- C <-|b30 <- b0| <-C
    -- 
    -- Generic
    function RLACg_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSourceR : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(0):=Cy;
        VSource1(VSource1'high downto 1):=Source1;
        
        VSource2(VSource2'high-1 downto to_integer(unsigned(FT2))):=VSource1(VSource1'high-1-to_integer(unsigned(FT2)) downto 0);
        VSource2(to_integer(unsigned(FT2))-1 downto 0):=VSource1(VSource2'high-1 downto VSource1'high-to_integer(unsigned(FT2)));
        VSource2(VSource2'high):=VSource1(VSource1'high);
        VSourceR:=VSource2(0) & VSource2(VSource2'high downto 1);       
        return VSourceR;
    end function RLACg_F;
    --
    -- Original (only 1,2,4,8,6)
    function RLAC_F(Source1 : TRiscoWord ; FT2 : std_logic_vector(4 downto 0) ; Cy : std_logic) return TRiscoWordPlusCarry is
        variable VSource1 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSource2 : std_logic_vector(TRiscoWord'high+1 downto 0);
        variable VSourceR : std_logic_vector(TRiscoWord'high+1 downto 0);
    begin
        VSource1(0):=Cy;
        VSource1(VSource1'high downto 1):=Source1;
        VSource2(VSource2'high):=VSource1(VSource1'high);
        case to_integer(unsigned(FT2)) is
            when 1 =>       
                VSource2(VSource2'high-1 downto 1):=VSource1(VSource1'high-2 downto 0);
                VSource2(0):=VSource1(VSource2'high-1);
            when 2 =>           
                VSource2(VSource2'high-1 downto 2):=VSource1(VSource1'high-3 downto 0);
                VSource2(1 downto 0):=VSource1(VSource2'high-1 downto VSource2'high-2);
            when 4 =>
                VSource2(VSource2'high-1 downto 4):=VSource1(VSource1'high-5 downto 0);
                VSource2(3 downto 0):=VSource1(VSource2'high-1 downto VSource2'high-4);
            when 8=>
                VSource2(VSource2'high-1 downto 8):=VSource1(VSource1'high-9 downto 0);
                VSource2(7 downto 0):=VSource1(VSource2'high-1 downto VSource2'high-8);
            when others => -- 16 
                VSource2(VSource2'high-1 downto 16):=VSource1(VSource1'high-17 downto 0);
                VSource2(15 downto 0):=VSource1(VSource2'high-1 downto VSource2'high-16);
        end case;        
        VSourceR:=VSource2(0) & VSource2(VSource2'high downto 1);       
        return VSourceR;
    end function RLAC_F;    
end ud_package;
