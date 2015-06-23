database -open waves -into waves.shm -default

probe -create tb_top.dut_I -depth all -tasks -functions -all -database waves
probe -create tb_top.dut_I.openhmc_instance.rx_link_I -all -database waves -memories
probe -create tb_top.dut_I.openhmc_instance.tx_link_I -all -database waves -memories

set assert_output_stop_level failed
set assert_report_incompletes 0

run

