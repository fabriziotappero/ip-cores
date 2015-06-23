-- Generation properties:
--   Format              : flat
--   Generic mappings    : exclude
--   Leaf-level entities : direct binding
--   Regular libraries   : use library name
--   View name           : include
--   
library common_da;
library dct;
configuration DCT_core_tb_config of DCT_core_tb is
   for struct
      for all : DCT_core
         use entity dct.DCT_core(struct);
         for struct
            for all : Column_to_elements
               use entity common_da.Column_to_elements(rtl);
            end for;
            for all : DCT1D_DA
               use entity dct.DCT1D_DA(struct);
               for struct
                  for all : Rom_dct_sub
                     use entity dct.Rom_dct_sub(rtl);
                  end for;
                  for all : Rom_dct_sum
                     use entity dct.Rom_dct_sum(rtl);
                  end for;
                  for g0
                     for all : Parallel2Serial
                        use entity common_da.Parallel2Serial(rtl);
                     end for;
                  end for;
                  for g1
                     for all : Serial_adder
                        use entity common_da.Serial_adder(rtl);
                     end for;
                  end for;
                  for g2
                     for all : Serial_subtractor
                        use entity common_da.Serial_subtractor(rtl);
                     end for;
                  end for;
                  for g3
                     for all : Serial_multiplier
                        use entity common_da.Serial_multiplier(rtl);
                     end for;
                  end for;
                  for g4
                     for all : Serial_multiplier
                        use entity common_da.Serial_multiplier(rtl);
                     end for;
                  end for;
               end for;
            end for;
            for all : DCT_control
               use entity dct.DCT_control(fsm);
            end for;
            for all : DPRAM
               use entity common_da.DPRAM(rtl);
            end for;
            for all : Elements_to_column
               use entity common_da.Elements_to_column(rtl);
            end for;
            for all : FlipFlop
               use entity common_da.FlipFlop(rtl);
            end for;
            for all : Mux2to1
               use entity common_da.Mux2to1(rtl);
            end for;
         end for;
      end for;
      for all : DCT_core_tester
         use entity dct.DCT_core_tester(beh);
      end for;
   end for;
end DCT_core_tb_config;
