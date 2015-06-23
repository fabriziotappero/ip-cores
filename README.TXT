++++++++++++++++++++++++++
RS Decoder (31,19,6) v1.1
++++++++++++++++++++++++++

This project consists of 8 verilog files including a testbench file.
The files are:
- RSDecoder.v : contains description of top module of the decoder. It combines
                5 modules of typical RS Decoder building blocks.
- scblock.v   : contains description of the SC (Syndrome Computation) block and its
                submodules.
- kesblock.v  : KES (Key Equation Solver) block and its submodules.
- cseeblock.v : CSEE (Chien Search and Error Evaluator) block  and parallel 
                invers multiplier module. CSEE is the only block in the decoder
                that use invers multiplier to compute error magnitude using Fourney
                Formula.
- controller.v	: describes controller module. It consists of 2 FSMs and 2 counters.
- fifo_register.v : a FIFO register consists of 31 registers to store received word and
                    a register to synchronize outputted data with CSEE block.
- common_modules.v: this file contains basic modules that used by other higher modules.
                    It behaves like a library for the project.
- testbench.v : the testbench contains 3 different received word vectors. First
                received word contains no error symbol. Second word contains 6 error
                symbols and the last word contains 8 error symbols.

Limitations in this version:
Despite its high data rates, the decoder has some limitations that must be considered.
- It flags decoding failure at the end of outputted word. So, other block outside the
  decoder cannot differentiate between uncorrected word and corrected word until it
  receive decoding failure flag at the end of the word.
- Decoding failure is detected when degree of error location polynomial and 
  number of its roots is not equal. It means the error location polynomial doesn't
  have roots in the underlying GF(2^5). To determine the roots, decoder must activate 
  CSEE block first. Hence, decoding failure is detected after all elements in 
  GF(2^5) have been evaluated.
- Uncorrectable word still have to be summed with wrong error values. Because decoding
  failure is detected at the end of word, there is no other mechanism to solve 
  the problem, unless decoder start to output the word after all GF(2^5) elements 
  has been evaluated.
Hopefully, in next version, limitations above can be solved.


Rudy Dwi Putra
rudy.dp@gmail.com