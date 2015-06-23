-- Generation properties:
--   Format              : flat
--   Generic mappings    : exclude
--   Leaf-level entities : direct binding
--   Regular libraries   : use library name
--   View name           : include
--   
library common_da;
library dct;
library dctQidct;
library idct;
library quantizer;
configuration dctQidct_core_tb_config of dctQidct_core_tb is
   for struct
      for all : dctQidct_core
         use entity dctQidct.dctQidct_core(struct);
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
            for all : IDCT_core
               use entity idct.IDCT_core(struct);
               for struct
                  for all : Column_to_elements
                     use entity common_da.Column_to_elements(rtl);
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
                  for all : IDCT1D_DA
                     use entity idct.IDCT1D_DA(struct);
                     for struct
                        for all : IDCT_post_sum
                           use entity idct.IDCT_post_sum(rtl);
                        end for;
                        for all : Rom_idct_even
                           use entity idct.Rom_idct_even(rtl);
                        end for;
                        for all : Rom_idct_odd
                           use entity idct.Rom_idct_odd(rtl);
                        end for;
                        for g1
                           for all : Parallel2Serial
                              use entity common_da.Parallel2Serial(rtl);
                           end for;
                        end for;
                        for g4
                           for all : Serial_multiplier4idct
                              use entity common_da.Serial_multiplier4idct(rtl);
                           end for;
                        end for;
                        for g5
                           for all : Serial_multiplier4idct
                              use entity common_da.Serial_multiplier4idct(rtl);
                           end for;
                        end for;
                     end for;
                  end for;
                  for all : IDCT_control
                     use entity idct.IDCT_control(fsm);
                  end for;
                  for all : Mux2to1
                     use entity common_da.Mux2to1(rtl);
                  end for;
               end for;
            end for;
            for all : IDCT_fifo
               use entity dctQidct.IDCT_fifo(rtl);
            end for;
            for all : IQuant
               use entity quantizer.IQuant(rtl);
            end for;
         end for;
      end for;
      for all : dctQidct_core_tester
         use entity dctQidct.dctQidct_core_tester(beh);
      end for;
   end for;
end dctQidct_core_tb_config;
