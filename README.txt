This is the initial release of the code. 

sw_pe_affine.v is the module of the 'processing elements' that 
make up the systolic array. 

sw_gen_affine.v is the 'top level' file that instantiates an 
array of PEs. It is fairly easily configurable to make the array
shorter or longer (by modifying the LENGTH and LOGLENGTH local params).

sw_gen_testbench.v is a small testbench which instantiates a 4-PE 
array and compares two 4 x 4 DNA sequences.

sw_gen_affine should be instantiated by the toplevel block of your design,
along with the custom interface glue necessary to connect them. 

To operate the block, a query value (a packed array containing encoded 2-bit
nucleotides) and length (in nucleotides) should be set as inputs. Then, a reset
pulse should be sent down the array. Then, the i_vld (valid) signal should be 
held high as the comparison string is clocked in, two bits at a time, until 
the string is completed and the i_vld signal is lowered. When the o_vld signal
goes low, the array is done processing and the result is ready. If the "local" 
bit is high, the result will be on the "o_high" output of the last element. If
the "local" bit is low (global alignment mode), the valid result will be the 
higher of the two "o_right_*" outputs of the last element.

Happy Sequencing!
