$TURBO8051_PROJ/verif/tb/tb_top.v
########################
# Ethernet Related TB
########################
+incdir+$TURBO8051_PROJ/verif/agents/ethernet
$TURBO8051_PROJ/verif/agents/ethernet/tb_eth_top.v 
$TURBO8051_PROJ/verif/agents/ethernet/tb_mii.v 
$TURBO8051_PROJ/verif/agents/ethernet/tb_rmii.v

##########################
# Uart Related TB
##########################
$TURBO8051_PROJ/verif/agents/uart/uart_agent.v

##########################
# SPI Related TB
##########################
+incdir+$TURBO8051_PROJ/verif/agents/spi
+incdir+$TURBO8051_PROJ/verif/agents/spi/st_m25p20a
$TURBO8051_PROJ/verif/agents/spi/atmel/AT45DBXXX_v2.0.3.v
$TURBO8051_PROJ/verif/agents/spi/st_m25p20a/acdc_check.v
$TURBO8051_PROJ/verif/agents/spi/st_m25p20a/internal_logic.v
$TURBO8051_PROJ/verif/agents/spi/st_m25p20a/memory_access.v
$TURBO8051_PROJ/verif/agents/spi/st_m25p20a/M25P20.v

##########################
# RAM/ROM Models
##########################
$TURBO8051_PROJ/verif/model/oc8051_xram.v
$TURBO8051_PROJ/verif/model/oc8051_xrom.v

