#####################################################################################
# Copyright (C) 1991-2009 Altera Corporation
# Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
# support information,  device programming or simulation file,  and any other
# associated  documentation or information  provided by  Altera  or a partner
# under  Altera's   Megafunction   Partnership   Program  may  be  used  only
# to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
# other  use  of such  megafunction  design,  netlist,  support  information,
# device programming or simulation file,  or any other  related documentation
# or information  is prohibited  for  any  other purpose,  including, but not
# limited to  modification,  reverse engineering,  de-compiling, or use  with
# any other  silicon devices,  unless such use is  explicitly  licensed under
# a separate agreement with  Altera  or a megafunction partner.  Title to the
# intellectual property,  including patents,  copyrights,  trademarks,  trade
# secrets,  or maskworks,  embodied in any such megafunction design, netlist,
# support  information,  device programming or simulation file,  or any other
# related documentation or information provided by  Altera  or a megafunction
# partner, remains with Altera, the megafunction partner, or their respective
# licensors. No other licenses, including any licenses needed under any third
# party's intellectual property, are provided herein.
#####################################################################################

#####################################################################################
# Altera Triple-Speed Ethernet Megacore TCL constraint file
#
# Generated on Sat Nov 10 09:38:18 SGT 2012
#
#####################################################################################

# Generated TSE variation - Do not modify
# General Option
set IS_SOPC 0
set VARIATION_NAME "sgmii"
set DEVICE_FAMILY "CYCLONEIVGX"
set FROM_THE_VARIATION_NAME ""
set TO_THE_VARIATION_NAME ""

# MAC Option
set IS_MAC 0
set NUMBER_OF_CHANNEL 1
set IS_SMALLMAC 0
set IS_SMALLMAC_GIGE 0
set IS_FIFOLESS 0
set IS_HALFDUPLEX 0
set MII_INTERFACE "MII_GMII"

# PCS Option
set IS_PCS 1
set IS_SGMII 1

# PMA Option
set IS_PMA 1
set TRANSCEIVER_TYPE 0

# GXB Option
set IS_POWERDOWN 1





if { [ expr ( $IS_SOPC == 1 )] } {

    set FROM_THE_VARIATION_NAME "_from_the_$VARIATION_NAME"
    set TO_THE_VARIATION_NAME "_to_the_$VARIATION_NAME"

} else {

    set FROM_THE_VARIATION_NAME ""
    set TO_THE_VARIATION_NAME ""

}


if { [ expr ( $IS_FIFOLESS == 0 )] } {

#  macPcs=
   if { [ expr ($IS_MAC == 1) && ($IS_PCS == 1) && ($IS_PMA == 0)] } {
      #Optimize I/O timing for TBI interface
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to tbi_rx_d${TO_THE_VARIATION_NAME}
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to tbi_tx_d${FROM_THE_VARIATION_NAME}
   } 

# pcs=
   if { [ expr ($IS_MAC == 0) && ($IS_PCS == 1) && ($IS_PMA == 0)] } {
      #Optimize I/O timing for MII interface
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_tx_d
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_tx_en
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_tx_err
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_rx_col
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_rx_crs
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_rx_d
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_rx_en
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_rx_err

      #Optimize I/O timing for GMII interface
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_tx_d
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_tx_en
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_tx_err
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_rx_d
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_rx_dv
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_rx_err

      #Optimize I/O timing for TBI interface
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to tbi_rx_d
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to tbi_tx_d
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to tbi_rx_d
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to tbi_tx_d
      }

# pcsPma=
   if { [ expr ($IS_MAC == 0) && ($IS_PCS == 1) && ($IS_PMA == 1)] } {
      #Optimize I/O timing for MII interface
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_tx_d
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_tx_en
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_tx_err
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_rx_col
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_rx_crs
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_rx_d
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_rx_en
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_rx_err

      #Optimize I/O timing for GMII interface
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_tx_d
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_tx_en
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_tx_err
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_rx_d
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_rx_dv
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_rx_err
   }


# pmaTransceiver=

   if { [ expr ($IS_PCS == 1) && ($IS_PMA == 1)] } {
      if { [ expr ($TRANSCEIVER_TYPE == 0)] } {
         if { [string match $DEVICE_FAMILY "STRATIXIV"]} {
            #Optimize I/O timing for serdes interface
            set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to txp
            set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to rxp
         } else {

            # pmaTransceiverStratixIV=
            #Optimize I/O timing for serdes interface
            set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to txp
            set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rxp
         }
      } 

      if { [ expr ($TRANSCEIVER_TYPE == 1)] } {
         # pmaLvds=
   
         #Constrain MAC PCS reference clock
         set_instance_assignment -name GLOBAL_SIGNAL ON -to ref_clk

         #Optimize I/O timing for serdes interface
         set_instance_assignment -name IO_STANDARD LVDS -to ref_clk
         set_instance_assignment -name IO_STANDARD LVDS -to txp
         set_instance_assignment -name IO_STANDARD LVDS -to rxp
      }
   }


# gmii=
   if { [ expr ($IS_MAC == 1) && ($IS_PCS == 0) && ($IS_PMA == 0) && ([string match $MII_INTERFACE "MII_GMII"]) ] } {
      #Optimize I/O timing for GMII network-side interface
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_rx_d
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_rx_dv
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_rx_err
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_tx_d
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_tx_en
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_tx_err
	  
	  #Optimize I/O timing for MII network-side interface
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_rx_col
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_rx_crs
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_rx_d
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_rx_en
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_rx_err
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_tx_d
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_tx_en
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_tx_err
   }



# rgmii=
   if { [ expr ($IS_MAC == 1) && ($IS_PCS == 0) && ($IS_PMA == 0) && ([string match $MII_INTERFACE "RGMII"])] } {
      #Optimize I/O timing for RGMII network-side interface
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to rx_control
      set_instance_assignment -name FAST_INPUT_REGISTER ON -to rgmii_in
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to tx_control
      set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to rgmii_out
   }

} else {

   if { [ expr ($IS_FIFOLESS == 1) && ($IS_MAC == 1) && ($IS_PCS == 0) && ($IS_PMA == 0) ] } {
   
		set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to clk${TO_THE_VARIATION_NAME}
                set_instance_assignment -name GLOBAL_SIGNAL ON -to reset${TO_THE_VARIATION_NAME}

      for {set x 0} {$x < $NUMBER_OF_CHANNEL} {incr x} {


		if { [ expr [string match $MII_INTERFACE "MII_GMII"] ] } {

			#Optimize I/O timing for MII network-side interface
			if { [ expr $IS_HALFDUPLEX != 0 ] } {
				set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_rx_col_${x}${TO_THE_VARIATION_NAME}
				set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_rx_crs_${x}${TO_THE_VARIATION_NAME}
			}
			set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_rx_d_${x}${TO_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_rx_en_${x}${TO_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_INPUT_REGISTER ON -to m_rx_err_${x}${TO_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_tx_d_${x}${FROM_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_tx_en_${x}${FROM_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to m_tx_err_${x}${FROM_THE_VARIATION_NAME}

			#Optimize I/O timing for GMII network-side interface
			set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_rx_d_${x}${TO_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_rx_dv_${x}${TO_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_INPUT_REGISTER ON -to gm_rx_err_${x}${TO_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_tx_d_${x}${FROM_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_tx_en_${x}${FROM_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to gm_tx_err_${x}${FROM_THE_VARIATION_NAME}
			
			set_instance_assignment -name GLOBAL_SIGNAL "REGIONAL CLOCK" -to rx_clk_${x}${TO_THE_VARIATION_NAME}
			set_instance_assignment -name GLOBAL_SIGNAL "REGIONAL CLOCK" -to tx_clk_${x}${TO_THE_VARIATION_NAME}
			
		} 

		if { [ expr [string match $MII_INTERFACE "RGMII"] ] } {

			#Optimize I/O timing for RGMII network-side interface
			set_instance_assignment -name FAST_INPUT_REGISTER ON -to rx_control_${x}${TO_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_INPUT_REGISTER ON -to rgmii_in_${x}${TO_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to tx_control_${x}${FROM_THE_VARIATION_NAME}
			set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to rgmii_out_${x}${FROM_THE_VARIATION_NAME}
			set_instance_assignment -name GLOBAL_SIGNAL "REGIONAL CLOCK" -to rx_clk_${x}${TO_THE_VARIATION_NAME}
			#set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to tx_clk_${x}${TO_THE_VARIATION_NAME}
			
			
		}

	}
}

   if { [ expr ($IS_FIFOLESS == 1) && ($IS_MAC == 1) && ($IS_PCS == 1) && ($IS_PMA == 0) ] } {
		set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to clk${TO_THE_VARIATION_NAME}
                set_instance_assignment -name GLOBAL_SIGNAL ON -to reset${TO_THE_VARIATION_NAME}
		set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to ref_clk${TO_THE_VARIATION_NAME}

       for {set x 0} {$x < $NUMBER_OF_CHANNEL} {incr x} {
	   #Optimize I/O timing for TBI interface
	   set_instance_assignment -name FAST_INPUT_REGISTER ON -to tbi_rx_d_${x}${TO_THE_VARIATION_NAME}
	   set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to tbi_tx_d_${x}${FROM_THE_VARIATION_NAME}
	   set_instance_assignment -name GLOBAL_SIGNAL "REGIONAL CLOCK" -to tbi_rx_clk_${x}${FROM_THE_VARIATION_NAME}
	}
   }


   if { [ expr ($IS_FIFOLESS == 1) && ($IS_MAC == 1) && ($IS_PCS == 1) && ($IS_PMA == 1) ] } {
		set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to clk${TO_THE_VARIATION_NAME}
                set_instance_assignment -name GLOBAL_SIGNAL ON -to reset${TO_THE_VARIATION_NAME}
		set_instance_assignment -name GLOBAL_SIGNAL "GLOBAL CLOCK" -to ref_clk${TO_THE_VARIATION_NAME}
   }


   if { [ expr ($IS_FIFOLESS == 1) && ($IS_MAC == 1) && ($IS_PCS == 1) && ($IS_PMA == 1) && ($TRANSCEIVER_TYPE == 0) ] } {
      for {set x 0} {$x < $NUMBER_OF_CHANNEL} {incr x} {
	  if { [string match $DEVICE_FAMILY "STRATIXIV"]} {
            #Optimize I/O timing for serdes interface
            set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to txp_${x}${FROM_THE_VARIATION_NAME}
			set_instance_assignment -name IO_STANDARD "1.4-V PCML" -to rxp_${x}${TO_THE_VARIATION_NAME}
         } else {
            #Optimize I/O timing for serdes interface
            set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to txp_${x}${FROM_THE_VARIATION_NAME}
			set_instance_assignment -name IO_STANDARD "1.5-V PCML" -to rxp_${x}${TO_THE_VARIATION_NAME}
         }
	
      }
   }


   if { [ expr ($IS_FIFOLESS == 1) && ($IS_MAC == 1) && ($IS_PCS == 1) && ($IS_PMA == 1) && ($TRANSCEIVER_TYPE == 1) ] } {
        
        set_instance_assignment -name IO_STANDARD LVDS -to ref_clk${TO_THE_VARIATION_NAME}
  
        for {set x 0} {$x < $NUMBER_OF_CHANNEL} {incr x} {
		set_instance_assignment -name IO_STANDARD LVDS -to txp_${x}${FROM_THE_VARIATION_NAME}
		set_instance_assignment -name IO_STANDARD LVDS -to rxp_${x}${TO_THE_VARIATION_NAME}
	}
   }

}

 if { [ expr [string match $DEVICE_FAMILY "ARRIAV"] ] } {
        set_instance_assignment -name GLOBAL_SIGNAL OFF -to *reset_ff_wr
        set_instance_assignment -name GLOBAL_SIGNAL OFF -to *reset_ff_rd

        if { [ expr !(($IS_PCS == 1) && ($IS_PMA == 1) &&  ($TRANSCEIVER_TYPE == 1))] } {
                set_instance_assignment -name GLOBAL_SIGNAL OFF -to *reset_sync_*|altera_tse_reset_synchronizer_chain[0]
        }
   }

export_assignments

