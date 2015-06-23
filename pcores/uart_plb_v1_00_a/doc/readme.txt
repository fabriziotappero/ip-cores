1. use xilinx coregen to generate a FIFO, 
2. put the fifo_generator_v8_1_8x16.ngc file in netlist folder,
3. put the fifo_generator_v8_1_8x16.vhd file in hdl/vhdl folder.


 Offset   Register
   00     Recv Data
   04     Send Data
   08     Control Register
              BIT3            BIT4                    BIT5            BIT6                 BIT7
              rx_timeout      rx_fifo_almost_empty    rx_fifo_empty   rx_fifo_almost_full  rx_fifo_full
              BIT11           BIT12                   BIT13           BIT14                BIT15
              tx_xmt_empty    tx_fifo_almost_empty    tx_fifo_empty   tx_fifo_almost_full  tx_fifo_full
              BIT27           BIT30                   BIT31
              Interupt Enable Rx FIFO reset           Tx FIFO reset
   0C      Status
              same as Control Register
   10      DLW
   14      StratchPad
   18      StratchPad
   1C      StratchPad


Note: Control Register bit0 to bit27 are interrupt control bits
                       bit30,  bit31 are FIFO control bits

      Clear FIFO: 1. write '1' to Control Register bit30/bit31
                  2. write '0' to Control Register bit30/bit31
