-- Generation properties:
--   Format              : flat
--   Generic mappings    : exclude
--   Leaf-level entities : direct binding
--   Regular libraries   : use work
--   View name           : include
--   
library work;
configuration r65c02_tc_config of R65C02_TC is
   for struct
      for all : core
         use entity work.core(struct);
         for struct
            for all : regbank_axy
               use entity work.regbank_axy(struct);
               for struct
               end for;
            end for;
            for all : reg_pc
               use entity work.reg_pc(struct);
               for struct
               end for;
            end for;
            for all : reg_sp
               use entity work.reg_sp(struct);
               for struct
               end for;
            end for;
            for all : fsm_execution_unit
               use entity work.fsm_execution_unit(fsm);
            end for;
            for all : fsm_intnmi
               use entity work.fsm_intnmi(fsm);
            end for;
         end for;
      end for;
   end for;
end r65c02_tc_config;
