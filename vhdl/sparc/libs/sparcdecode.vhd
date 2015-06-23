library ieee;
use ieee.std_logic_1164.all;
use work.config.all;

-- PREFIX: sde_xxx
package spacedecode is

-------------------------------------------------------------------------------

type sde_decinsn is (
 sde_insn_ldsb, sde_insn_ldsh, sde_insn_ldst_ub, sde_insn_ldst_uh, 
 sde_insn_ldst, sde_insn_ldst_d, sde_insn_ldst_f, sde_insn_ldst_df,  
 sde_insn_ldst_fsr, sde_insn_stdfq, sde_insn_ldst_c, sde_insn_ldst_dc, 
 sde_insn_ldst_csr, sde_insn_stdcq, sde_insn_ldstb, sde_insn_swp,   
 sde_insn_sethi, sde_insn_nop, sde_insn_and, sde_insn_or, sde_insn_xor,
 sde_insn_sll, sde_insn_srl, sde_insn_sra, sde_insn_sadd, sde_insn_tsadd,   
 sde_insn_tsaddtv, sde_insn_mulscc, sde_insn_divscc, sde_insn_sv,
 sde_insn_rest, sde_insn_bra, sde_insn_fbra, sde_insn_cbra, sde_insn_jmp,
 sde_insn_jml, sde_insn_ret, sde_insn_trap,
 sde_insn_rd, sde_insn_rdp, sde_insn_rdw, sde_insn_rdt, sde_insn_wd, sde_insn_wdp, 
 sde_insn_wdw, sde_insn_wdt, sde_insn_stbar, sde_insn_unimp
);

function sde_decode_v8(
  insn : in std_logic_vector(31 downto 0)
) return sde_decinsn;
  
end spacedecode;

package body spacedecode is

function sde_decode_v8(
  insn : in std_logic_vector(31 downto 0)
) return sde_decinsn is
begin
case insn(31 downto 30) is  
when "00"=>
 case insn(24 downto 24) is  
 when "0"=>
  case insn(23 downto 23) is  
  when "0"=>
   case insn(22 downto 22) is  
   when "0"=>
    return sde_insn_unimp;
   when others =>
   end case;
  when "1"=>
   case insn(22 downto 22) is  
   when "0"=>
    return sde_insn_bra;
   when others =>
   end case;
  when others =>
  end case;
 when "1"=>
  case insn(23 downto 23) is  
  when "1"=>
   case insn(22 downto 22) is  
   when "1"=>
    return sde_insn_cbra;
   when "0"=>
    return sde_insn_fbra;
   when others =>
   end case;
  when "0"=>
   case insn(22 downto 22) is  
   when "0"=>
    case insn(29 downto 25) is  
    when "00000"=>
     return sde_insn_nop;
    when others =>
    end case;
    return sde_insn_sethi; --default
   when others =>
   end case;
  when others =>
  end case;
 when others =>
 end case;
when "10"=>
 case insn(24 downto 24) is  
 when "1"=>
  case insn(23 downto 23) is  
  when "0"=>
   case insn(22 downto 22) is  
   when "1"=>
    case insn(21 downto 21) is  
    when "0"=>
     case insn(20 downto 20) is  
     when "0"=>
      case insn(19 downto 19) is  
      when "0"=>
       case insn(29 downto 25) is  
       when "00000"=>
        case insn(18 downto 13) is  
        when "011110"=>
         return sde_insn_stbar;
        when others =>
        end case;
       when others =>
       end case;
       return sde_insn_rd; --default
      when "1"=>
       return sde_insn_rdp;
      when others =>
      end case;
     when "1"=>
      case insn(19 downto 19) is  
      when "1"=>
       return sde_insn_rdt;
      when "0"=>
       return sde_insn_rdw;
      when others =>
      end case;
     when others =>
     end case;
    when others =>
    end case;
   when "0"=>
    case insn(21 downto 21) is  
    when "0"=>
     case insn(20 downto 20) is  
     when "1"=>
      return sde_insn_tsaddtv;
     when "0"=>
      return sde_insn_tsadd;
     when others =>
     end case;
    when "1"=>
     case insn(20 downto 20) is  
     when "1"=>
      case insn(19 downto 19) is  
      when "1"=>
       return sde_insn_sra;
      when "0"=>
       return sde_insn_srl;
      when others =>
      end case;
     when "0"=>
      case insn(19 downto 19) is  
      when "1"=>
       return sde_insn_sll;
      when others =>
      end case;
     when others =>
     end case;
    when others =>
    end case;
   when others =>
   end case;
  when "1"=>
   case insn(22 downto 22) is  
   when "0"=>
    case insn(21 downto 21) is  
    when "0"=>
     case insn(20 downto 20) is  
     when "1"=>
      case insn(19 downto 19) is  
      when "1"=>
       return sde_insn_wdt;
      when "0"=>
       return sde_insn_wdw;
      when others =>
      end case;
     when "0"=>
      case insn(19 downto 19) is  
      when "1"=>
       return sde_insn_wdp;
      when "0"=>
       return sde_insn_wd;
      when others =>
      end case;
     when others =>
     end case;
    when others =>
    end case;
   when "1"=>
    case insn(21 downto 21) is  
    when "0"=>
     case insn(20 downto 20) is  
     when "1"=>
      case insn(19 downto 19) is  
      when "0"=>
       return sde_insn_trap;
      when others =>
      end case;
     when "0"=>
      case insn(19 downto 19) is  
      when "1"=>
       return sde_insn_ret;
      when "0"=>
       return sde_insn_jml;
      when others =>
      end case;
     when others =>
     end case;
    when "1"=>
     case insn(20 downto 20) is  
     when "0"=>
      case insn(19 downto 19) is  
      when "1"=>
       return sde_insn_rest;
      when "0"=>
       return sde_insn_sv;
      when others =>
      end case;
     when others =>
     end case;
    when others =>
    end case;
   when others =>
   end case;
  when others =>
  end case;
 when "0"=>
  case insn(20 downto 20) is  
  when "1"=>
   case insn(22 downto 22) is  
   when "1"=>
    case insn(21 downto 21) is  
    when "1"=>
     return sde_insn_divscc;
    when "0"=>
     return sde_insn_mulscc;
    when others =>
    end case;
   when "0"=>
    case insn(19 downto 19) is  
    when "1"=>
     return sde_insn_xor;
    when "0"=>
     return sde_insn_or;
    when others =>
    end case;
   when others =>
   end case;
  when "0"=>
   case insn(19 downto 19) is  
   when "0"=>
    return sde_insn_sadd;
   when "1"=>
    case insn(22 downto 22) is  
    when "0"=>
     return sde_insn_and;
    when others =>
    end case;
   when others =>
   end case;
  when others =>
  end case;
 when others =>
 end case;
when "01"=>
 return sde_insn_jmp;
when "11"=>
 case insn(24 downto 24) is  
 when "0"=>
  case insn(22 downto 22) is  
  when "1"=>
   case insn(21 downto 21) is  
   when "1"=>
    case insn(20 downto 20) is  
    when "1"=>
     case insn(19 downto 19) is  
     when "1"=>
      return sde_insn_swp;
     when others =>
     end case;
    when "0"=>
     case insn(19 downto 19) is  
     when "1"=>
      return sde_insn_ldstb;
     when others =>
     end case;
    when others =>
    end case;
   when "0"=>
    case insn(20 downto 20) is  
    when "1"=>
     case insn(19 downto 19) is  
     when "0"=>
      return sde_insn_ldsh;
     when others =>
     end case;
    when "0"=>
     case insn(19 downto 19) is  
     when "1"=>
      return sde_insn_ldsb;
     when others =>
     end case;
    when others =>
    end case;
   when others =>
   end case;
  when "0"=>
   case insn(20 downto 20) is  
   when "1"=>
    case insn(19 downto 19) is  
    when "1"=>
     return sde_insn_ldst_d;
    when "0"=>
     return sde_insn_ldst_uh;
    when others =>
    end case;
   when "0"=>
    case insn(19 downto 19) is  
    when "0"=>
     return sde_insn_ldst;
    when "1"=>
     return sde_insn_ldst_ub;
    when others =>
    end case;
   when others =>
   end case;
  when others =>
  end case;
 when "1"=>
  case insn(23 downto 23) is  
  when "1"=>
   case insn(22 downto 22) is  
   when "0"=>
    case insn(20 downto 20) is  
    when "1"=>
     case insn(19 downto 19) is  
     when "1"=>
      case insn(21 downto 21) is  
      when "1"=>
       return sde_insn_stdcq;
      when others =>
      end case;
      return sde_insn_ldst_dc; --default
     when others =>
     end case;
    when "0"=>
     case insn(19 downto 19) is  
     when "1"=>
      return sde_insn_ldst_csr;
     when "0"=>
      return sde_insn_ldst_c;
     when others =>
     end case;
    when others =>
    end case;
   when others =>
   end case;
  when "0"=>
   case insn(22 downto 22) is  
   when "0"=>
    case insn(20 downto 20) is  
    when "1"=>
     case insn(19 downto 19) is  
     when "0"=>
      case insn(21 downto 21) is  
      when "1"=>
       return sde_insn_stdfq;
      when others =>
      end case;
     when "1"=>
      return sde_insn_ldst_df;
     when others =>
     end case;
    when "0"=>
     case insn(19 downto 19) is  
     when "1"=>
      return sde_insn_ldst_fsr;
     when "0"=>
      return sde_insn_ldst_f;
     when others =>
     end case;
    when others =>
    end case;
   when others =>
   end case;
  when others =>
  end case;
 when others =>
 end case;
when others =>
end case;
    return sde_insn_unimp;
end;

  
end spacedecode;
