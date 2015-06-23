
** SYSTEM LEVEL TESTBENCHES **

Refer to doc/building_test_system.pptx for building the necessary SOPC
and NIOS II projects to simulate these tests.


** BLOCK LEVEL TESTBENCHES **

Run setup*.do files in modelsim to create work lib, compile files and
setup some waves for you.

gen_ram_init.sh:  to create ram_init.dat needed by some of the testbenches

tb_n2h2_rx: halts on fourth rx on purpose, modify .dat files to change
behaviour.

Configuration file formats: (only used in tb_n2h2_rx)

tbrx_conf_hibisend.dat : dest_agent_n, delay, amount
tbrx_conf_rx.dat       : mem_addr, sender, irq_amount (=words to receive)
tbrx_data_file.dat     : mem_addr, sender, irq_amount (=words to receive)


