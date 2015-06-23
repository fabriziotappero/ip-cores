
emacs -batch verilog/sync_clk_wb.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/sync_clk_xgmii_tx.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/sync_clk_core.v -l ../custom.el -f verilog-auto -f save-buffer

emacs -batch verilog/wishbone_if.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/fault_sm.v -l ../custom.el -f verilog-auto -f save-buffer

emacs -batch verilog/tx_stats_fifo.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/rx_stats_fifo.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/stats_sm.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/stats.v -l ../custom.el -f verilog-auto -f save-buffer

emacs -batch verilog/rx_dequeue.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/rx_enqueue.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/rx_data_fifo.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/rx_hold_fifo.v -l ../custom.el -f verilog-auto -f save-buffer

emacs -batch verilog/tx_dequeue.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/tx_enqueue.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/tx_data_fifo.v -l ../custom.el -f verilog-auto -f save-buffer
emacs -batch verilog/tx_hold_fifo.v -l ../custom.el -f verilog-auto -f save-buffer

emacs -batch verilog/xge_mac.v -l ../custom.el -f verilog-auto -f save-buffer

emacs -batch examples/test_chip.v -l ../custom.el -f verilog-auto -f save-buffer

emacs -batch ../tbench/verilog/tb_xge_mac.v -l ../../rtl/custom.el -f verilog-auto -f save-buffer
