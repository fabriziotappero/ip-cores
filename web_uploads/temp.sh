#!/bin/bash
# AUTOMATICALLY GENERATED SCRIPT
# Scans the cores directory, excludes the projects and subdirectories
# listed below, and generates a script which checks in all of the 
# remaining files to the SVN repository
# This should be run and the output piped to a new file something like:
# ./oc_cvs_checkin.sh > checkin_script.sh
# and then probably the execute permission enabled on checkin_script.sh
# Encapsulate the checkins inside this loop we can 
# break out of in the event of a problem checking
# one of them in

# Function to check the return value of each SVN checkin
function check_svn_return_value { if [ $? -gt 1 ]; then echo "Error during checkins - aborting script."; exit 1; fi
}
ALL_DONE="0"
while [ $ALL_DONE = 0 ]; do
    pushd "100baset"
    popd
    pushd "1394ohci"
    popd
    pushd "2dcoprocessor"
    popd
    pushd "395_vgs"
    popd
    pushd "3des_vhdl"
    popd
    pushd "4bitprocesor"
    popd
    pushd "6502vhdl"
    popd
    pushd "68hc05"
    popd
    pushd "68hc08"
    popd
    pushd "8051_serial"
    popd
    pushd "8051_to_ahb_interface"
    popd
    pushd "8b10b_encdec"
    svn import -m "Import from OC" "8b10b_encdec_v1d0.pdf" "http://192.168.100.145/ocsvn/8b10b_encdec/8b10b_encdec_v1d0.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "8b10_dec.vhd" "http://192.168.100.145/ocsvn/8b10b_encdec/8b10_dec.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "8b10_enc.vhd" "http://192.168.100.145/ocsvn/8b10b_encdec/8b10_enc.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "enc_8b10b_TB.vhd" "http://192.168.100.145/ocsvn/8b10b_encdec/enc_8b10b_TB.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "encdec_8b10b_TB.vhd" "http://192.168.100.145/ocsvn/8b10b_encdec/encdec_8b10b_TB.vhd"
    check_svn_return_value
    popd
    pushd "8bituartvhdl"
    popd
    pushd "aacencode"
    popd
    pushd "acxbrd"
    svn import -m "Import from OC" "jopcore.pdf" "http://192.168.100.145/ocsvn/acxbrd/jopcore.pdf"
    check_svn_return_value
    popd
    pushd "adaptivefilter"
    popd
    pushd "adaptive_lms_equalizer"
    popd
    pushd "adaptiveprocessor"
    popd
    pushd "adat_optical_feed_forward_receiver"
    svn import -m "Import from OC" "ADAT_receiver.vhd" "http://192.168.100.145/ocsvn/adat_optical_feed_forward_receiver/ADAT_receiver.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "Adat_testbench.vhd" "http://192.168.100.145/ocsvn/adat_optical_feed_forward_receiver/Adat_testbench.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_waves1.jpg" "http://192.168.100.145/ocsvn/adat_optical_feed_forward_receiver/thumb_waves1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_waves2.jpg" "http://192.168.100.145/ocsvn/adat_optical_feed_forward_receiver/thumb_waves2.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "waves1.jpg" "http://192.168.100.145/ocsvn/adat_optical_feed_forward_receiver/waves1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "waves2.jpg" "http://192.168.100.145/ocsvn/adat_optical_feed_forward_receiver/waves2.jpg"
    check_svn_return_value
    popd
    pushd "adder"
    svn import -m "Import from OC" "high-speed-adder-128bits-opencore.v" "http://192.168.100.145/ocsvn/adder/high-speed-adder-128bits-opencore.v"
    check_svn_return_value
    popd
    pushd "ae18"
    popd
    pushd "aemb"
    popd
    pushd "aes"
    popd
    pushd "aes128"
    popd
    pushd "aes_128_192_256"
    svn import -m "Import from OC" "aes_dec.vhdl" "http://192.168.100.145/ocsvn/aes_128_192_256/aes_dec.vhdl"
    check_svn_return_value
    svn import -m "Import from OC" "aes_enc.vhdl" "http://192.168.100.145/ocsvn/aes_128_192_256/aes_enc.vhdl"
    check_svn_return_value
    svn import -m "Import from OC" "aes_pkg.vhdl" "http://192.168.100.145/ocsvn/aes_128_192_256/aes_pkg.vhdl"
    check_svn_return_value
    svn import -m "Import from OC" "aes_top.pdf" "http://192.168.100.145/ocsvn/aes_128_192_256/aes_top.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "key_expansion.vhdl" "http://192.168.100.145/ocsvn/aes_128_192_256/key_expansion.vhdl"
    check_svn_return_value
    popd
    pushd "aes_core"
    popd
    pushd "aes_crypto_core"
    popd
    pushd "aes_fekete256"
    svn import -m "Import from OC" "AES.ZIP" "http://192.168.100.145/ocsvn/aes_fekete256/AES.ZIP"
    check_svn_return_value
    popd
    pushd "ahb2wishbone"
    popd
    pushd "ahbahb"
    popd
    pushd "ahb_arbiter"
    popd
    pushd "ahb_system_generator"
    popd
    pushd "all_digital_fm_receiver"
    svn import -m "Import from OC" "architecture.png" "http://192.168.100.145/ocsvn/all_digital_fm_receiver/architecture.png"
    check_svn_return_value
    svn import -m "Import from OC" "fmsquare.jpg" "http://192.168.100.145/ocsvn/all_digital_fm_receiver/fmsquare.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "fmtriangular.jpg" "http://192.168.100.145/ocsvn/all_digital_fm_receiver/fmtriangular.jpg"
    check_svn_return_value
    popd
    pushd "alternascope"
    svn import -m "Import from OC" "Alternascope_Sept15_2005.rar" "http://192.168.100.145/ocsvn/alternascope/Alternascope_Sept15_2005.rar"
    check_svn_return_value
    svn import -m "Import from OC" "BlockDiagram_small.GIF" "http://192.168.100.145/ocsvn/alternascope/BlockDiagram_small.GIF"
    check_svn_return_value
    svn import -m "Import from OC" "OpenCores.JPG" "http://192.168.100.145/ocsvn/alternascope/OpenCores.JPG"
    check_svn_return_value
    popd
    pushd "alu_with_selectable_inputs_and_outputs"
    popd
    pushd "amba_compliant_fifo_core"
    popd
    pushd "ambasdram"
    popd
    pushd "aquarius"
    svn import -m "Import from OC" "aquarius.files" "http://192.168.100.145/ocsvn/aquarius/aquarius.files"
    check_svn_return_value
    svn import -m "Import from OC" "aquarius.html" "http://192.168.100.145/ocsvn/aquarius/aquarius.html"
    check_svn_return_value
    svn import -m "Import from OC" "cpublock.gif" "http://192.168.100.145/ocsvn/aquarius/cpublock.gif"
    check_svn_return_value
    svn import -m "Import from OC" "fpgaboard.gif" "http://192.168.100.145/ocsvn/aquarius/fpgaboard.gif"
    check_svn_return_value
    svn import -m "Import from OC" "rtl.gif" "http://192.168.100.145/ocsvn/aquarius/rtl.gif"
    check_svn_return_value
    popd
    pushd "aspida"
    svn import -m "Import from OC" "aspida_dlx_core.tar.gz" "http://192.168.100.145/ocsvn/aspida/aspida_dlx_core.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "aspida.gif" "http://192.168.100.145/ocsvn/aspida/aspida.gif"
    check_svn_return_value
    svn import -m "Import from OC" "faq.tar.gz" "http://192.168.100.145/ocsvn/aspida/faq.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_aspida.gif" "http://192.168.100.145/ocsvn/aspida/thumb_aspida.gif"
    check_svn_return_value
    popd
    pushd "asynchronous_clocks"
    popd
    pushd "ata"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/ata/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "preliminary_ata_core.pdf" "http://192.168.100.145/ocsvn/ata/preliminary_ata_core.pdf"
    check_svn_return_value
    popd
    pushd "auto_baud"
    svn import -m "Import from OC" "auto_baud.v" "http://192.168.100.145/ocsvn/auto_baud/auto_baud.v"
    check_svn_return_value
    svn import -m "Import from OC" "auto_baud_with_tracking.v" "http://192.168.100.145/ocsvn/auto_baud/auto_baud_with_tracking.v"
    check_svn_return_value
    svn import -m "Import from OC" "b13_safe_09_17_02.zip" "http://192.168.100.145/ocsvn/auto_baud/b13_safe_09_17_02.zip"
    check_svn_return_value
    popd
    pushd "a_vhd_16550_uart"
    svn import -m "Import from OC" "gh_uart_16550_072108.zip" "http://192.168.100.145/ocsvn/a_vhd_16550_uart/gh_uart_16550_072108.zip"
    check_svn_return_value
    svn import -m "Import from OC" "gh_uart_16550_101307.zip" "http://192.168.100.145/ocsvn/a_vhd_16550_uart/gh_uart_16550_101307.zip"
    check_svn_return_value
    svn import -m "Import from OC" "vhdl_16550_uart_2_2.pdf" "http://192.168.100.145/ocsvn/a_vhd_16550_uart/vhdl_16550_uart_2_2.pdf"
    check_svn_return_value
    popd
    pushd "a_vhdl_8253_timer"
    svn import -m "Import from OC" "gh_timer_8254_081608.zip" "http://192.168.100.145/ocsvn/a_vhdl_8253_timer/gh_timer_8254_081608.zip"
    check_svn_return_value
    svn import -m "Import from OC" "gh_timer_8254_1_1.pdf" "http://192.168.100.145/ocsvn/a_vhdl_8253_timer/gh_timer_8254_1_1.pdf"
    check_svn_return_value
    popd
    pushd "a_vhdl_can_controller"
    svn import -m "Import from OC" "can_parts.zip" "http://192.168.100.145/ocsvn/a_vhdl_can_controller/can_parts.zip"
    check_svn_return_value
    popd
    pushd "avr_core"
    svn import -m "Import from OC" "AVR_Core8F.tar.gz" "http://192.168.100.145/ocsvn/avr_core/AVR_Core8F.tar.gz"
    check_svn_return_value
    popd
    pushd "avrtinyx61core"
    svn import -m "Import from OC" "AVRtinyX61core_2008-09-21.zip" "http://192.168.100.145/ocsvn/avrtinyx61core/AVRtinyX61core_2008-09-21.zip"
    check_svn_return_value
    svn import -m "Import from OC" "AVRtinyX61core_2008-10-08.zip" "http://192.168.100.145/ocsvn/avrtinyx61core/AVRtinyX61core_2008-10-08.zip"
    check_svn_return_value
    popd
    pushd "ax8"
    popd
    pushd "basicdes"
    popd
    pushd "basicrsa"
    popd
    pushd "baudgen"
    svn import -m "Import from OC" "am_baud_rate_gen.vhd" "http://192.168.100.145/ocsvn/baudgen/am_baud_rate_gen.vhd"
    check_svn_return_value
    popd
    pushd "baud_select_uart"
    popd
    pushd "bc6502"
    popd
    pushd "big_counter"
    popd
    pushd "binary_to_bcd"
    svn import -m "Import from OC" "b17_test_environment.zip" "http://192.168.100.145/ocsvn/binary_to_bcd/b17_test_environment.zip"
    check_svn_return_value
    svn import -m "Import from OC" "bcd_to_binary.v" "http://192.168.100.145/ocsvn/binary_to_bcd/bcd_to_binary.v"
    check_svn_return_value
    svn import -m "Import from OC" "binary_to_bcd.v" "http://192.168.100.145/ocsvn/binary_to_bcd/binary_to_bcd.v"
    check_svn_return_value
    popd
    pushd "bips"
    popd
    pushd "biquad"
    svn import -m "Import from OC" "biquad.pdf" "http://192.168.100.145/ocsvn/biquad/biquad.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "biquad.v" "http://192.168.100.145/ocsvn/biquad/biquad.v"
    check_svn_return_value
    svn import -m "Import from OC" "bqmain.v" "http://192.168.100.145/ocsvn/biquad/bqmain.v"
    check_svn_return_value
    svn import -m "Import from OC" "bquad_blk.gif" "http://192.168.100.145/ocsvn/biquad/bquad_blk.gif"
    check_svn_return_value
    svn import -m "Import from OC" "coefio.v" "http://192.168.100.145/ocsvn/biquad/coefio.v"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/biquad/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "multa.v" "http://192.168.100.145/ocsvn/biquad/multa.v"
    check_svn_return_value
    svn import -m "Import from OC" "multb.v" "http://192.168.100.145/ocsvn/biquad/multb.v"
    check_svn_return_value
    svn import -m "Import from OC" "vsource.html" "http://192.168.100.145/ocsvn/biquad/vsource.html"
    check_svn_return_value
    popd
    pushd "bluespec-80211atransmitter"
    popd
    pushd "bluespec-bsp"
    popd
    pushd "bluespec-convolutional-codec"
    popd
    pushd "bluespec-fft"
    popd
    pushd "bluespec-galoisfield"
    popd
    pushd "bluespec-h264"
    svn import -m "Import from OC" "h264.pdf" "http://192.168.100.145/ocsvn/bluespec-h264/h264.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "memo497.pdf" "http://192.168.100.145/ocsvn/bluespec-h264/memo497.pdf"
    check_svn_return_value
    popd
    pushd "bluespec_md6"
    popd
    pushd "bluespec-ofdm"
    popd
    pushd "bluespec-reedsolomon"
    popd
    pushd "bluetooth"
    svn import -m "Import from OC" "BBspec.shtml" "http://192.168.100.145/ocsvn/bluetooth/BBspec.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "Bluetooth_01b.zip" "http://192.168.100.145/ocsvn/bluetooth/Bluetooth_01b.zip"
    check_svn_return_value
    svn import -m "Import from OC" "Bluetooth_02b.zip" "http://192.168.100.145/ocsvn/bluetooth/Bluetooth_02b.zip"
    check_svn_return_value
    svn import -m "Import from OC" "Bluetooth.zip" "http://192.168.100.145/ocsvn/bluetooth/Bluetooth.zip"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/bluetooth/index.shtml"
    check_svn_return_value
    popd
    pushd "bluetooth_ver"
    popd
    pushd "board"
    svn import -m "Import from OC" "blockdiagram.jpg" "http://192.168.100.145/ocsvn/board/blockdiagram.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "boardflow.jpg" "http://192.168.100.145/ocsvn/board/boardflow.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "board.shtml" "http://192.168.100.145/ocsvn/board/board.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "coreflow.jpg" "http://192.168.100.145/ocsvn/board/coreflow.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/board/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "led.jpg" "http://192.168.100.145/ocsvn/board/led.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "matrics.gif" "http://192.168.100.145/ocsvn/board/matrics.gif"
    check_svn_return_value
    svn import -m "Import from OC" "power_led.gif" "http://192.168.100.145/ocsvn/board/power_led.gif"
    check_svn_return_value
    svn import -m "Import from OC" "XC95108-PC84.sym" "http://192.168.100.145/ocsvn/board/XC95108-PC84.sym"
    check_svn_return_value
    popd
    pushd "boundaries"
    popd
    pushd "brisc"
    popd
    pushd "butterfly"
    popd
    pushd "c16"
    popd
    pushd "c8051"
    popd
    pushd "cable"
    popd
    pushd "cachemodel"
    popd
    pushd "cam"
    popd
    pushd "camellia"
    svn import -m "Import from OC" "camellia_core_tb.vhd" "http://192.168.100.145/ocsvn/camellia/camellia_core_tb.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "CAMELLIA_CORE.vhd" "http://192.168.100.145/ocsvn/camellia/CAMELLIA_CORE.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "Camellia_doc.pdf" "http://192.168.100.145/ocsvn/camellia/Camellia_doc.pdf"
    check_svn_return_value
    popd
    pushd "camellia-vhdl"
    popd
    pushd "can"
    svn import -m "Import from OC" "CAN.gif" "http://192.168.100.145/ocsvn/can/CAN.gif"
    check_svn_return_value
    popd
    pushd "cas"
    popd
    pushd "ccir656_vidcapif"
    popd
    pushd "cdma"
    popd
    pushd "cereon"
    svn import -m "Import from OC" "AssemblerReference.pdf" "http://192.168.100.145/ocsvn/cereon/AssemblerReference.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "CereonArchitectureReferenceManual_Version1.pdf" "http://192.168.100.145/ocsvn/cereon/CereonArchitectureReferenceManual_Version1.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "LibrarianReference.pdf" "http://192.168.100.145/ocsvn/cereon/LibrarianReference.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "LinkerReference.pdf" "http://192.168.100.145/ocsvn/cereon/LinkerReference.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "NgoffSupplement.pdf" "http://192.168.100.145/ocsvn/cereon/NgoffSupplement.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "ProcedureCallingStandards.pdf" "http://192.168.100.145/ocsvn/cereon/ProcedureCallingStandards.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "ProcessorIdentificationScheme.pdf" "http://192.168.100.145/ocsvn/cereon/ProcessorIdentificationScheme.pdf"
    check_svn_return_value
    popd
    pushd "cf_cordic"
    svn import -m "Import from OC" "cf_cordic.tgz" "http://192.168.100.145/ocsvn/cf_cordic/cf_cordic.tgz"
    check_svn_return_value
    popd
    pushd "cf_fft"
    svn import -m "Import from OC" "cf_fft_test_large.tgz" "http://192.168.100.145/ocsvn/cf_fft/cf_fft_test_large.tgz"
    check_svn_return_value
    svn import -m "Import from OC" "cf_fft_test.tgz" "http://192.168.100.145/ocsvn/cf_fft/cf_fft_test.tgz"
    check_svn_return_value
    svn import -m "Import from OC" "cf_fft.tgz" "http://192.168.100.145/ocsvn/cf_fft/cf_fft.tgz"
    check_svn_return_value
    popd
    pushd "cf_fir"
    svn import -m "Import from OC" "cf_fir.tgz" "http://192.168.100.145/ocsvn/cf_fir/cf_fir.tgz"
    check_svn_return_value
    popd
    pushd "cf_fp_mul"
    svn import -m "Import from OC" "cf_fp_mul.tgz" "http://192.168.100.145/ocsvn/cf_fp_mul/cf_fp_mul.tgz"
    check_svn_return_value
    popd
    pushd "cfft"
    popd
    pushd "cfinterface"
    popd
    pushd "cf_interleaver"
    svn import -m "Import from OC" "cf_interleaver.tgz" "http://192.168.100.145/ocsvn/cf_interleaver/cf_interleaver.tgz"
    check_svn_return_value
    popd
    pushd "cf_ldpc"
    svn import -m "Import from OC" "cf_ldpc.tgz" "http://192.168.100.145/ocsvn/cf_ldpc/cf_ldpc.tgz"
    check_svn_return_value
    popd
    pushd "cf_rca"
    svn import -m "Import from OC" "cf_rca.tgz" "http://192.168.100.145/ocsvn/cf_rca/cf_rca.tgz"
    check_svn_return_value
    svn import -m "Import from OC" "rca_tile.png" "http://192.168.100.145/ocsvn/cf_rca/rca_tile.png"
    check_svn_return_value
    popd
    pushd "cf_ssp"
    svn import -m "Import from OC" "cf_ssp.tgz" "http://192.168.100.145/ocsvn/cf_ssp/cf_ssp.tgz"
    check_svn_return_value
    svn import -m "Import from OC" "ssp_cordic.c" "http://192.168.100.145/ocsvn/cf_ssp/ssp_cordic.c"
    check_svn_return_value
    svn import -m "Import from OC" "ssp_first_order.c" "http://192.168.100.145/ocsvn/cf_ssp/ssp_first_order.c"
    check_svn_return_value
    popd
    pushd "cia"
    popd
    pushd "claw"
    popd
    pushd "clocklessalu"
    popd
    pushd "cmpct"
    popd
    pushd "c-nit_soc"
    popd
    pushd "color_converter"
    popd
    pushd "constellation_vga"
    popd
    pushd "const_encoder"
    svn import -m "Import from OC" "Const_enc_oc.doc" "http://192.168.100.145/ocsvn/const_encoder/Const_enc_oc.doc"
    check_svn_return_value
    svn import -m "Import from OC" "const_enc.vhd" "http://192.168.100.145/ocsvn/const_encoder/const_enc.vhd"
    check_svn_return_value
    popd
    pushd "cordic"
    svn import -m "Import from OC" "cordic.pdf" "http://192.168.100.145/ocsvn/cordic/cordic.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/cordic/index.shtml"
    check_svn_return_value
    popd
    pushd "core_arm"
    popd
    pushd "cowgirl"
    popd
    pushd "cpu6502_true_cycle"
    popd
    pushd "cpu65c02_true_cycle"
    popd
    pushd "cpu68k"
    popd
    pushd "cpu8080"
    popd
    pushd "cpugen"
    svn import -m "Import from OC" "cpugen.jpg" "http://192.168.100.145/ocsvn/cpugen/cpugen.jpg"
    check_svn_return_value
    popd
    pushd "cryptopan_core"
    popd
    pushd "cryptosorter"
    svn import -m "Import from OC" "cryptosorter.pdf" "http://192.168.100.145/ocsvn/cryptosorter/cryptosorter.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "MITCrypto-Sorter.ppt" "http://192.168.100.145/ocsvn/cryptosorter/MITCrypto-Sorter.ppt"
    check_svn_return_value
    popd
    pushd "csa"
    popd
    pushd "dab_receivers"
    popd
    pushd "dallas_one-wire"
    popd
    pushd "dct"
    svn import -m "Import from OC" "dct.shtml" "http://192.168.100.145/ocsvn/dct/dct.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "dct.zip" "http://192.168.100.145/ocsvn/dct/dct.zip"
    check_svn_return_value
    svn import -m "Import from OC" "htmlbook.shtml" "http://192.168.100.145/ocsvn/dct/htmlbook.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "modexp.shtml" "http://192.168.100.145/ocsvn/dct/modexp.shtml"
    check_svn_return_value
    popd
    pushd "ddr_sdr"
    svn import -m "Import from OC" "ddr_sdr_V1_0.zip" "http://192.168.100.145/ocsvn/ddr_sdr/ddr_sdr_V1_0.zip"
    check_svn_return_value
    svn import -m "Import from OC" "ddr_sdr_V1_1.zip" "http://192.168.100.145/ocsvn/ddr_sdr/ddr_sdr_V1_1.zip"
    check_svn_return_value
    svn import -m "Import from OC" "doc" "http://192.168.100.145/ocsvn/ddr_sdr/doc"
    check_svn_return_value
    svn import -m "Import from OC" "LICENSE.dat" "http://192.168.100.145/ocsvn/ddr_sdr/LICENSE.dat"
    check_svn_return_value
    svn import -m "Import from OC" "vhdl" "http://192.168.100.145/ocsvn/ddr_sdr/vhdl"
    check_svn_return_value
    popd
    pushd "ddsgen"
    popd
    pushd "dds_ip_debuged"
    popd
    pushd "decoder"
    svn import -m "Import from OC" "mp3_decoder.zip" "http://192.168.100.145/ocsvn/decoder/mp3_decoder.zip"
    check_svn_return_value
    popd
    pushd "deflatecore"
    popd
    pushd "des"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/des/index.shtml"
    check_svn_return_value
    popd
    pushd "design_dsp320tmsc10_with_vhdl"
    popd
    pushd "dfp"
    svn import -m "Import from OC" "dfp.gif" "http://192.168.100.145/ocsvn/dfp/dfp.gif"
    check_svn_return_value
    svn import -m "Import from OC" "DFPV10.zip" "http://192.168.100.145/ocsvn/dfp/DFPV10.zip"
    check_svn_return_value
    svn import -m "Import from OC" "V3.zip" "http://192.168.100.145/ocsvn/dfp/V3.zip"
    check_svn_return_value
    popd
    pushd "digifilter"
    popd
    pushd "diogenes"
    svn import -m "Import from OC" "diogenes.tar.bz2" "http://192.168.100.145/ocsvn/diogenes/diogenes.tar.bz2"
    check_svn_return_value
    popd
    pushd "dirac"
    popd
    pushd "djpeg"
    popd
    pushd "dmacontroller"
    popd
    pushd "dmt_tx"
    popd
    pushd "dram"
    svn import -m "Import from OC" "dram.html" "http://192.168.100.145/ocsvn/dram/dram.html"
    check_svn_return_value
    svn import -m "Import from OC" "dram.shtml" "http://192.168.100.145/ocsvn/dram/dram.shtml"
    check_svn_return_value
    popd
    pushd "dualspartainc6713cpci"
    svn import -m "Import from OC" "6713_CPU.pdf" "http://192.168.100.145/ocsvn/dualspartainc6713cpci/6713_CPU.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "BotLayer.jpg" "http://192.168.100.145/ocsvn/dualspartainc6713cpci/BotLayer.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "DSP_Front.jpg" "http://192.168.100.145/ocsvn/dualspartainc6713cpci/DSP_Front.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "DSP_near_done_tiny.jpg" "http://192.168.100.145/ocsvn/dualspartainc6713cpci/DSP_near_done_tiny.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "Mid1Layer.jpg" "http://192.168.100.145/ocsvn/dualspartainc6713cpci/Mid1Layer.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "Mid2Layer.jpg" "http://192.168.100.145/ocsvn/dualspartainc6713cpci/Mid2Layer.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "SystemDiagram.jpg" "http://192.168.100.145/ocsvn/dualspartainc6713cpci/SystemDiagram.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "TopLayer.jpg" "http://192.168.100.145/ocsvn/dualspartainc6713cpci/TopLayer.jpg"
    check_svn_return_value
    popd
    pushd "dwt2d"
    svn import -m "Import from OC" "DIPC1.zip" "http://192.168.100.145/ocsvn/dwt2d/DIPC1.zip"
    check_svn_return_value
    popd
    pushd "e123mux"
    svn import -m "Import from OC" "Block_Diagram.jpg" "http://192.168.100.145/ocsvn/e123mux/Block_Diagram.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "E123MUX_Core.pdf" "http://192.168.100.145/ocsvn/e123mux/E123MUX_Core.pdf"
    check_svn_return_value
    popd
    pushd "e1framer"
    popd
    pushd "e1framerdeframer"
    svn import -m "Import from OC" "e1_framer.zip" "http://192.168.100.145/ocsvn/e1framerdeframer/e1_framer.zip"
    check_svn_return_value
    svn import -m "Import from OC" "fas_insert.vhd" "http://192.168.100.145/ocsvn/e1framerdeframer/fas_insert.vhd"
    check_svn_return_value
    popd
    pushd "edatools"
    popd
    pushd "elevator"
    popd
    pushd "elphel_353"
    popd
    pushd "embedded_risc"
    svn import -m "Import from OC" "Block_Diagram" "http://192.168.100.145/ocsvn/embedded_risc/Block_Diagram"
    check_svn_return_value
    popd
    pushd "embed_z8"
    popd
    pushd "epp"
    svn import -m "Import from OC" "epp.jpg" "http://192.168.100.145/ocsvn/epp/epp.jpg"
    check_svn_return_value
    popd
    pushd "epp-interface-v"
    popd
    pushd "epp-to-wishbone"
    popd
    pushd "erp"
    svn import -m "Import from OC" "ERPTechnicalReport4.pdf" "http://192.168.100.145/ocsvn/erp/ERPTechnicalReport4.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "ERPTechnicalReport5.pdf" "http://192.168.100.145/ocsvn/erp/ERPTechnicalReport5.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "ERPverilogcore.txt" "http://192.168.100.145/ocsvn/erp/ERPverilogcore.txt"
    check_svn_return_value
    popd
    pushd "ethdev"
    popd
    pushd "ethernet_tri_mode"
    svn import -m "Import from OC" "ethernet_tri_mode.rel-1-0.tar.gz" "http://192.168.100.145/ocsvn/ethernet_tri_mode/ethernet_tri_mode.rel-1-0.tar.gz"
    check_svn_return_value
    popd
    pushd "ethmac10g"
    popd
    pushd "ethmacvhdl"
    popd
    pushd "ethswitch"
    popd
    pushd "eus100lx"
    svn import -m "Import from OC" "180px-EUS_B_N.jpg" "http://192.168.100.145/ocsvn/eus100lx/180px-EUS_B_N.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "180px-EUS_T_N.jpg" "http://192.168.100.145/ocsvn/eus100lx/180px-EUS_T_N.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "EUS100LX_BD.gif" "http://192.168.100.145/ocsvn/eus100lx/EUS100LX_BD.gif"
    check_svn_return_value
    popd
    pushd "eusfs"
    svn import -m "Import from OC" "eusfs-bd.jpg" "http://192.168.100.145/ocsvn/eusfs/eusfs-bd.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "EUSIIa_bottom_tn.jpg" "http://192.168.100.145/ocsvn/eusfs/EUSIIa_bottom_tn.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "EUS_II_topa_tn.jpg" "http://192.168.100.145/ocsvn/eusfs/EUS_II_topa_tn.jpg"
    check_svn_return_value
    popd
    pushd "eventcpu"
    popd
    pushd "evision"
    popd
    pushd "extension_pack"
    popd
    pushd "fab1"
    popd
    pushd "fac2222m"
    svn import -m "Import from OC" "ADC-DAC-AMP.png" "http://192.168.100.145/ocsvn/fac2222m/ADC-DAC-AMP.png"
    check_svn_return_value
    svn import -m "Import from OC" "fac2222m.png" "http://192.168.100.145/ocsvn/fac2222m/fac2222m.png"
    check_svn_return_value
    popd
    pushd "fast-crc"
    svn import -m "Import from OC" "CRC-generator.tgz" "http://192.168.100.145/ocsvn/fast-crc/CRC-generator.tgz"
    check_svn_return_value
    svn import -m "Import from OC" "CRC_ie3_contest.pdf" "http://192.168.100.145/ocsvn/fast-crc/CRC_ie3_contest.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "CRC.tgz" "http://192.168.100.145/ocsvn/fast-crc/CRC.tgz"
    check_svn_return_value
    svn import -m "Import from OC" "Readme" "http://192.168.100.145/ocsvn/fast-crc/Readme"
    check_svn_return_value
    popd
    pushd "fbas_encoder"
    svn import -m "Import from OC" "chroma_gen.png" "http://192.168.100.145/ocsvn/fbas_encoder/chroma_gen.png"
    check_svn_return_value
    svn import -m "Import from OC" "connect.png" "http://192.168.100.145/ocsvn/fbas_encoder/connect.png"
    check_svn_return_value
    svn import -m "Import from OC" "fbas_encoder-0.21.tar.gz" "http://192.168.100.145/ocsvn/fbas_encoder/fbas_encoder-0.21.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "fbas-encoder_0.31.tar.gz" "http://192.168.100.145/ocsvn/fbas_encoder/fbas-encoder_0.31.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "fbas-enc_scrs1.jpg" "http://192.168.100.145/ocsvn/fbas_encoder/fbas-enc_scrs1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "luma_gen.png" "http://192.168.100.145/ocsvn/fbas_encoder/luma_gen.png"
    check_svn_return_value
    svn import -m "Import from OC" "main.png" "http://192.168.100.145/ocsvn/fbas_encoder/main.png"
    check_svn_return_value
    popd
    pushd "fcpu"
    svn import -m "Import from OC" "*" "http://192.168.100.145/ocsvn/fcpu/*"
    check_svn_return_value
    popd
    pushd "ffr16"
    svn import -m "Import from OC" "FFR16.jpg" "http://192.168.100.145/ocsvn/ffr16/FFR16.jpg"
    check_svn_return_value
    popd
    pushd "fft_32"
    popd
    pushd "fftprocessor"
    popd
    pushd "fht"
    svn import -m "Import from OC" "fht_tb.v" "http://192.168.100.145/ocsvn/fht/fht_tb.v"
    check_svn_return_value
    svn import -m "Import from OC" "fht.v" "http://192.168.100.145/ocsvn/fht/fht.v"
    check_svn_return_value
    popd
    pushd "fifouart"
    svn import -m "Import from OC" "UART_datasheet.pdf" "http://192.168.100.145/ocsvn/fifouart/UART_datasheet.pdf"
    check_svn_return_value
    popd
    pushd "filter"
    svn import -m "Import from OC" "*" "http://192.168.100.145/ocsvn/filter/*"
    check_svn_return_value
    popd
    pushd "firewire"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/firewire/index.shtml"
    check_svn_return_value
    popd
    pushd "fir_filter_generator"
    svn import -m "Import from OC" "design-of-high-speed.pdf" "http://192.168.100.145/ocsvn/fir_filter_generator/design-of-high-speed.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "FirGen_V1.0.zip" "http://192.168.100.145/ocsvn/fir_filter_generator/FirGen_V1.0.zip"
    check_svn_return_value
    svn import -m "Import from OC" "FirGen_V1.1.zip" "http://192.168.100.145/ocsvn/fir_filter_generator/FirGen_V1.1.zip"
    check_svn_return_value
    popd
    pushd "firgen"
    svn import -m "Import from OC" "RedFIR_package.tar" "http://192.168.100.145/ocsvn/firgen/RedFIR_package.tar"
    check_svn_return_value
    popd
    pushd "fir-gen"
    popd
    pushd "flha"
    popd
    pushd "floatingcore"
    popd
    pushd "floating_point_adder_subtractor"
    svn import -m "Import from OC" "addsub.vhd" "http://192.168.100.145/ocsvn/floating_point_adder_subtractor/addsub.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "normalize.vhd" "http://192.168.100.145/ocsvn/floating_point_adder_subtractor/normalize.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "shift.vhd" "http://192.168.100.145/ocsvn/floating_point_adder_subtractor/shift.vhd"
    check_svn_return_value
    popd
    pushd "floppyif"
    popd
    pushd "fmtransmitter"
    popd
    pushd "fpga"
    svn import -m "Import from OC" "docs.jar" "http://192.168.100.145/ocsvn/fpga/docs.jar"
    check_svn_return_value
    svn import -m "Import from OC" "examples.jar" "http://192.168.100.145/ocsvn/fpga/examples.jar"
    check_svn_return_value
    svn import -m "Import from OC" "Fpga.pdf" "http://192.168.100.145/ocsvn/fpga/Fpga.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "fpga_sw.pdf" "http://192.168.100.145/ocsvn/fpga/fpga_sw.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "gpl.txt" "http://192.168.100.145/ocsvn/fpga/gpl.txt"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/fpga/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "KRPAN.jar" "http://192.168.100.145/ocsvn/fpga/KRPAN.jar"
    check_svn_return_value
    svn import -m "Import from OC" "KRPAN.zip" "http://192.168.100.145/ocsvn/fpga/KRPAN.zip"
    check_svn_return_value
    svn import -m "Import from OC" "opencores.cer" "http://192.168.100.145/ocsvn/fpga/opencores.cer"
    check_svn_return_value
    svn import -m "Import from OC" "pwm12_8s.v" "http://192.168.100.145/ocsvn/fpga/pwm12_8s.v"
    check_svn_return_value
    svn import -m "Import from OC" "sources.jar" "http://192.168.100.145/ocsvn/fpga/sources.jar"
    check_svn_return_value
    svn import -m "Import from OC" "sshot1.gif" "http://192.168.100.145/ocsvn/fpga/sshot1.gif"
    check_svn_return_value
    popd
    pushd "fpgabsp"
    popd
    pushd "fpgaconfig"
    svn import -m "Import from OC" "altera_config.png" "http://192.168.100.145/ocsvn/fpgaconfig/altera_config.png"
    check_svn_return_value
    svn import -m "Import from OC" "fpgaConfig_system_block_diag.gif" "http://192.168.100.145/ocsvn/fpgaconfig/fpgaConfig_system_block_diag.gif"
    check_svn_return_value
    svn import -m "Import from OC" "fpgaConfig.zip" "http://192.168.100.145/ocsvn/fpgaconfig/fpgaConfig.zip"
    check_svn_return_value
    popd
    pushd "fpgaproto"
    popd
    pushd "fpipelines"
    popd
    pushd "fpu"
    svn import -m "Import from OC" "DEADJOE" "http://192.168.100.145/ocsvn/fpu/DEADJOE"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/fpu/index.shtml"
    check_svn_return_value
    popd
    pushd "fpu100"
    svn import -m "Import from OC" "bug_report_260407.txt" "http://192.168.100.145/ocsvn/fpu100/bug_report_260407.txt"
    check_svn_return_value
    svn import -m "Import from OC" "fpu_doc.pdf" "http://192.168.100.145/ocsvn/fpu100/fpu_doc.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "fpu_v18.zip" "http://192.168.100.145/ocsvn/fpu100/fpu_v18.zip"
    check_svn_return_value
    svn import -m "Import from OC" "fpu_v19.zip" "http://192.168.100.145/ocsvn/fpu100/fpu_v19.zip"
    check_svn_return_value
    popd
    pushd "fpu32bit"
    popd
    pushd "fpuvhdl"
    popd
    pushd "freetools"
    svn import -m "Import from OC" "*" "http://192.168.100.145/ocsvn/freetools/*"
    check_svn_return_value
    popd
    pushd "froop"
    popd
    pushd "fsl2serial"
    popd
    pushd "gamepads"
    svn import -m "Import from OC" "gcpad.png" "http://192.168.100.145/ocsvn/gamepads/gcpad.png"
    check_svn_return_value
    svn import -m "Import from OC" "snespad.png" "http://192.168.100.145/ocsvn/gamepads/snespad.png"
    check_svn_return_value
    svn import -m "Import from OC" "snespad_wire.jpg" "http://192.168.100.145/ocsvn/gamepads/snespad_wire.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_gcpad.png" "http://192.168.100.145/ocsvn/gamepads/thumb_gcpad.png"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_snespad.png" "http://192.168.100.145/ocsvn/gamepads/thumb_snespad.png"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_snespad_wire.jpg" "http://192.168.100.145/ocsvn/gamepads/thumb_snespad_wire.jpg"
    check_svn_return_value
    popd
    pushd "gcpu"
    popd
    pushd "gecko3"
    svn import -m "Import from OC" "blockdiagramm.png" "http://192.168.100.145/ocsvn/gecko3/blockdiagramm.png"
    check_svn_return_value
    svn import -m "Import from OC" "GECKO3main_back_parts.jpg" "http://192.168.100.145/ocsvn/gecko3/GECKO3main_back_parts.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "GECKO3main_front_parts.jpg" "http://192.168.100.145/ocsvn/gecko3/GECKO3main_front_parts.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "GECKO3main-Schematic.pdf" "http://192.168.100.145/ocsvn/gecko3/GECKO3main-Schematic.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_blockdiagramm.png" "http://192.168.100.145/ocsvn/gecko3/thumb_blockdiagramm.png"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_GECKO3main_back_parts.jpg" "http://192.168.100.145/ocsvn/gecko3/thumb_GECKO3main_back_parts.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_GECKO3main_front_parts.jpg" "http://192.168.100.145/ocsvn/gecko3/thumb_GECKO3main_front_parts.jpg"
    check_svn_return_value
    popd
    pushd "generic_fifos"
    popd
    pushd "generic_fifovhd"
    popd
    pushd "gh_vhdl_library"
    svn import -m "Import from OC" "gh_vhdl_lib_3_42.pdf" "http://192.168.100.145/ocsvn/gh_vhdl_library/gh_vhdl_lib_3_42.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "gh_vhdl_lib_3_43.pdf" "http://192.168.100.145/ocsvn/gh_vhdl_library/gh_vhdl_lib_3_43.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "gh_vhdl_lib_v3_42a.zip" "http://192.168.100.145/ocsvn/gh_vhdl_library/gh_vhdl_lib_v3_42a.zip"
    check_svn_return_value
    svn import -m "Import from OC" "gh_vhdl_lib_v3_43.zip" "http://192.168.100.145/ocsvn/gh_vhdl_library/gh_vhdl_lib_v3_43.zip"
    check_svn_return_value
    popd
    pushd "gig_ethernet_mac_core"
    popd
    pushd "gix96"
    popd
    pushd "gpio"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/gpio/index.shtml"
    check_svn_return_value
    popd
    pushd "graphicallcd"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/graphicallcd/index.shtml"
    check_svn_return_value
    popd
    pushd "graphiti"
    svn import -m "Import from OC" "blockschaltbild.png" "http://192.168.100.145/ocsvn/graphiti/blockschaltbild.png"
    check_svn_return_value
    svn import -m "Import from OC" "flowers.jpg" "http://192.168.100.145/ocsvn/graphiti/flowers.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "graphitib.jpg" "http://192.168.100.145/ocsvn/graphiti/graphitib.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "graphiti.jpg" "http://192.168.100.145/ocsvn/graphiti/graphiti.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "testbild.jpg" "http://192.168.100.145/ocsvn/graphiti/testbild.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "tflowers.jpg" "http://192.168.100.145/ocsvn/graphiti/tflowers.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_flowers.jpg" "http://192.168.100.145/ocsvn/graphiti/thumb_flowers.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_graphitib.jpg" "http://192.168.100.145/ocsvn/graphiti/thumb_graphitib.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_graphiti.jpg" "http://192.168.100.145/ocsvn/graphiti/thumb_graphiti.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_testbild.jpg" "http://192.168.100.145/ocsvn/graphiti/thumb_testbild.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_tflowers.jpg" "http://192.168.100.145/ocsvn/graphiti/thumb_tflowers.jpg"
    check_svn_return_value
    popd
    pushd "gsc"
    svn import -m "Import from OC" "btyacc.tar.gz" "http://192.168.100.145/ocsvn/gsc/btyacc.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "graphviz-2.8.tar.gz" "http://192.168.100.145/ocsvn/gsc/graphviz-2.8.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "gsc-0.1.1.tar.gz" "http://192.168.100.145/ocsvn/gsc/gsc-0.1.1.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "gsc.pdf" "http://192.168.100.145/ocsvn/gsc/gsc.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "keystone.tar.gz" "http://192.168.100.145/ocsvn/gsc/keystone.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "treecc-0.3.8.tar.gz" "http://192.168.100.145/ocsvn/gsc/treecc-0.3.8.tar.gz"
    check_svn_return_value
    popd
    pushd "gup"
    svn import -m "Import from OC" "gator_ucomputer_v1.0.zip" "http://192.168.100.145/ocsvn/gup/gator_ucomputer_v1.0.zip"
    check_svn_return_value
    svn import -m "Import from OC" "gup_logo_thumb.jpg" "http://192.168.100.145/ocsvn/gup/gup_logo_thumb.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_gup_logo_thumb.jpg" "http://192.168.100.145/ocsvn/gup/thumb_gup_logo_thumb.jpg"
    check_svn_return_value
    popd
    pushd "gzip"
    popd
    pushd "hamming"
    popd
    pushd "hamming_gen"
    svn import -m "Import from OC" "hamming.zip" "http://192.168.100.145/ocsvn/hamming_gen/hamming.zip"
    check_svn_return_value
    popd
    pushd "hangyu"
    popd
    pushd "hasm"
    popd
    pushd "hdb3"
    popd
    pushd "hdbn"
    popd
    pushd "hdlc"
    svn import -m "Import from OC" "HDLC_cont.jpg" "http://192.168.100.145/ocsvn/hdlc/HDLC_cont.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDLC_cont.ps" "http://192.168.100.145/ocsvn/hdlc/HDLC_cont.ps"
    check_svn_return_value
    svn import -m "Import from OC" "hdlc_fifo.jpg" "http://192.168.100.145/ocsvn/hdlc/hdlc_fifo.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "hdlc_fifo.ps" "http://192.168.100.145/ocsvn/hdlc/hdlc_fifo.ps"
    check_svn_return_value
    svn import -m "Import from OC" "hdlc_project.html" "http://192.168.100.145/ocsvn/hdlc/hdlc_project.html"
    check_svn_return_value
    svn import -m "Import from OC" "hdlc_project.pdf" "http://192.168.100.145/ocsvn/hdlc/hdlc_project.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "hdlc_project.ps" "http://192.168.100.145/ocsvn/hdlc/hdlc_project.ps"
    check_svn_return_value
    svn import -m "Import from OC" "HDLC_top.jpg" "http://192.168.100.145/ocsvn/hdlc/HDLC_top.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDLC_top.ps" "http://192.168.100.145/ocsvn/hdlc/HDLC_top.ps"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/hdlc/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "wishlogo.ps" "http://192.168.100.145/ocsvn/hdlc/wishlogo.ps"
    check_svn_return_value
    popd
    pushd "help"
    svn import -m "Import from OC" "exp1pf.gif" "http://192.168.100.145/ocsvn/help/exp1pf.gif"
    check_svn_return_value
    svn import -m "Import from OC" "search.shtml" "http://192.168.100.145/ocsvn/help/search.shtml"
    check_svn_return_value
    popd
    pushd "hicovec"
    svn import -m "Import from OC" "hicovec.png" "http://192.168.100.145/ocsvn/hicovec/hicovec.png"
    check_svn_return_value
    svn import -m "Import from OC" "scalarunit.png" "http://192.168.100.145/ocsvn/hicovec/scalarunit.png"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_hicovec.png" "http://192.168.100.145/ocsvn/hicovec/thumb_hicovec.png"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_scalarunit.png" "http://192.168.100.145/ocsvn/hicovec/thumb_scalarunit.png"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_vectorunit.png" "http://192.168.100.145/ocsvn/hicovec/thumb_vectorunit.png"
    check_svn_return_value
    svn import -m "Import from OC" "vectorunit.png" "http://192.168.100.145/ocsvn/hicovec/vectorunit.png"
    check_svn_return_value
    popd
    pushd "hierarch_unit"
    popd
    pushd "hmta"
    popd
    pushd "houmway"
    popd
    pushd "hpc-16"
    popd
    pushd "hpcmemory"
    popd
    pushd "hpdmc"
    popd
    pushd "hssdrc"
    popd
    pushd "ht_tunnel"
    popd
    pushd "hwlu"
    popd
    pushd "i2c"
    svn import -m "Import from OC" "Block.gif" "http://192.168.100.145/ocsvn/i2c/Block.gif"
    check_svn_return_value
    svn import -m "Import from OC" "i2c_rev03.pdf" "http://192.168.100.145/ocsvn/i2c/i2c_rev03.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "index_orig.shtml" "http://192.168.100.145/ocsvn/i2c/index_orig.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/i2c/index.shtml"
    check_svn_return_value
    popd
    pushd "i2clog"
    svn import -m "Import from OC" "Documentation" "http://192.168.100.145/ocsvn/i2clog/Documentation"
    check_svn_return_value
    svn import -m "Import from OC" "front" "http://192.168.100.145/ocsvn/i2clog/front"
    check_svn_return_value
    svn import -m "Import from OC" "I2C_TrafficLogger.v" "http://192.168.100.145/ocsvn/i2clog/I2C_TrafficLogger.v"
    check_svn_return_value
    popd
    pushd "i2c_master_slave_core"
    popd
    pushd "i2c_slave"
    svn import -m "Import from OC" "iic_slave_3.v" "http://192.168.100.145/ocsvn/i2c_slave/iic_slave_3.v"
    check_svn_return_value
    popd
    pushd "i2c_vhdl"
    popd
    pushd "i2s"
    svn import -m "Import from OC" "dff.vhd" "http://192.168.100.145/ocsvn/i2s/dff.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "ebu_2_i2s.vhd" "http://192.168.100.145/ocsvn/i2s/ebu_2_i2s.vhd"
    check_svn_return_value
    popd
    pushd "i2s_interface"
    svn import -m "Import from OC" "i2s_interface.zip" "http://192.168.100.145/ocsvn/i2s_interface/i2s_interface.zip"
    check_svn_return_value
    popd
    pushd "i2sparalell"
    popd
    pushd "ic6821"
    svn import -m "Import from OC" "VHDL6821.vhd" "http://192.168.100.145/ocsvn/ic6821/VHDL6821.vhd"
    check_svn_return_value
    popd
    pushd "icu"
    popd
    pushd "ide"
    popd
    pushd "idea"
    svn import -m "Import from OC" "block_opmode.tar.gz" "http://192.168.100.145/ocsvn/idea/block_opmode.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "control.tar.gz" "http://192.168.100.145/ocsvn/idea/control.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "IDEA core block.GIF" "http://192.168.100.145/ocsvn/idea/IDEA core block.GIF"
    check_svn_return_value
    svn import -m "Import from OC" "idea_machine.tar.gz" "http://192.168.100.145/ocsvn/idea/idea_machine.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "IDEA mechine block.GIF" "http://192.168.100.145/ocsvn/idea/IDEA mechine block.GIF"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/idea/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "keys_generate.tar.gz" "http://192.168.100.145/ocsvn/idea/keys_generate.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "Paper_IES2001_sby.PDF" "http://192.168.100.145/ocsvn/idea/Paper_IES2001_sby.PDF"
    check_svn_return_value
    svn import -m "Import from OC" "port_inout.tar.gz" "http://192.168.100.145/ocsvn/idea/port_inout.tar.gz"
    check_svn_return_value
    popd
    pushd "iiepci"
    svn import -m "Import from OC" "iie_pci_back.jpg" "http://192.168.100.145/ocsvn/iiepci/iie_pci_back.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "iie_pci_diagram.jpg" "http://192.168.100.145/ocsvn/iiepci/iie_pci_diagram.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "iie_pci_front.jpg" "http://192.168.100.145/ocsvn/iiepci/iie_pci_front.jpg"
    check_svn_return_value
    popd
    pushd "ima-adpcm"
    popd
    pushd "interface_vga80x40"
    svn import -m "Import from OC" "FPGA_VGA_Electrical_Interface.png" "http://192.168.100.145/ocsvn/interface_vga80x40/FPGA_VGA_Electrical_Interface.png"
    check_svn_return_value
    svn import -m "Import from OC" "if_vga80x40.zip" "http://192.168.100.145/ocsvn/interface_vga80x40/if_vga80x40.zip"
    check_svn_return_value
    svn import -m "Import from OC" "VGA80x40_documentation.pdf" "http://192.168.100.145/ocsvn/interface_vga80x40/VGA80x40_documentation.pdf"
    check_svn_return_value
    popd
    pushd "ipchip"
    popd
    pushd "irda"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/irda/index.shtml"
    check_svn_return_value
    popd
    pushd "iso7816-3"
    svn import -m "Import from OC" "iso7816-3.tgz" "http://192.168.100.145/ocsvn/iso7816-3/iso7816-3.tgz"
    check_svn_return_value
    popd
    pushd "isp"
    popd
    pushd "jop"
    popd
    pushd "jpeg"
    svn import -m "Import from OC" "DiagramaCompJPGen.png" "http://192.168.100.145/ocsvn/jpeg/DiagramaCompJPGen.png"
    check_svn_return_value
    svn import -m "Import from OC" "floresconsubsamp211.jpg" "http://192.168.100.145/ocsvn/jpeg/floresconsubsamp211.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "floressinsubsamp.jpg" "http://192.168.100.145/ocsvn/jpeg/floressinsubsamp.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "imagenfrutasQ05PSP.JPG" "http://192.168.100.145/ocsvn/jpeg/imagenfrutasQ05PSP.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "imagenfrutasQ15.jpg" "http://192.168.100.145/ocsvn/jpeg/imagenfrutasQ15.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "imagenfrutasQ31.jpg" "http://192.168.100.145/ocsvn/jpeg/imagenfrutasQ31.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "imagenfrutasQ50.jpg" "http://192.168.100.145/ocsvn/jpeg/imagenfrutasQ50.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "imagenglobosPSPQ15.jpg" "http://192.168.100.145/ocsvn/jpeg/imagenglobosPSPQ15.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "imagenglobosQ15.jpg" "http://192.168.100.145/ocsvn/jpeg/imagenglobosQ15.jpg"
    check_svn_return_value
    popd
    pushd "jpegcompression"
    svn import -m "Import from OC" "*" "http://192.168.100.145/ocsvn/jpegcompression/*"
    check_svn_return_value
    popd
    pushd "jtag"
    svn import -m "Import from OC" "Boundary-Scan Architecture.pdf" "http://192.168.100.145/ocsvn/jtag/Boundary-Scan Architecture.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/jtag/index.shtml"
    check_svn_return_value
    popd
    pushd "k68"
    popd
    pushd "k7_viterbi_decoder"
    popd
    pushd "kad"
    popd
    pushd "kcpsm3_interrupt_handling"
    popd
    pushd "keyboardcontroller"
    popd
    pushd "keypad_scanner"
    svn import -m "Import from OC" "keypad_scanner.v" "http://192.168.100.145/ocsvn/keypad_scanner/keypad_scanner.v"
    check_svn_return_value
    popd
    pushd "kiss-board"
    popd
    pushd "kotku"
    popd
    pushd "ksystem"
    popd
    pushd "l8051"
    svn import -m "Import from OC" "L8051.tar" "http://192.168.100.145/ocsvn/l8051/L8051.tar"
    check_svn_return_value
    popd
    pushd "lcd"
    svn import -m "Import from OC" "alliance.shtml" "http://192.168.100.145/ocsvn/lcd/alliance.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "counterc.shtml" "http://192.168.100.145/ocsvn/lcd/counterc.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "counter.shtml" "http://192.168.100.145/ocsvn/lcd/counter.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "counterv.shtml" "http://192.168.100.145/ocsvn/lcd/counterv.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "decoderc.shtml" "http://192.168.100.145/ocsvn/lcd/decoderc.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "decoderv.shtml" "http://192.168.100.145/ocsvn/lcd/decoderv.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "dffresc.shtml" "http://192.168.100.145/ocsvn/lcd/dffresc.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "dffresv.shtml" "http://192.168.100.145/ocsvn/lcd/dffresv.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "dflipflop.shtml" "http://192.168.100.145/ocsvn/lcd/dflipflop.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/lcd/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml.old" "http://192.168.100.145/ocsvn/lcd/index.shtml.old"
    check_svn_return_value
    svn import -m "Import from OC" "LCD.ht1.gif" "http://192.168.100.145/ocsvn/lcd/LCD.ht1.gif"
    check_svn_return_value
    svn import -m "Import from OC" "lcd.zip" "http://192.168.100.145/ocsvn/lcd/lcd.zip"
    check_svn_return_value
    svn import -m "Import from OC" "mcc.shtml" "http://192.168.100.145/ocsvn/lcd/mcc.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "mcv.shtml" "http://192.168.100.145/ocsvn/lcd/mcv.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "ramc.shtml" "http://192.168.100.145/ocsvn/lcd/ramc.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "ramv.shtml" "http://192.168.100.145/ocsvn/lcd/ramv.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "struct.shtml" "http://192.168.100.145/ocsvn/lcd/struct.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "test.shtml" "http://192.168.100.145/ocsvn/lcd/test.shtml"
    check_svn_return_value
    popd
    pushd "lcd1"
    popd
    pushd "lcd_controller"
    svn import -m "Import from OC" "AP.zip" "http://192.168.100.145/ocsvn/lcd_controller/AP.zip"
    check_svn_return_value
    svn import -m "Import from OC" "CM920TUserGuide.pdf" "http://192.168.100.145/ocsvn/lcd_controller/CM920TUserGuide.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "ColorTFT-LCDController.ppt" "http://192.168.100.145/ocsvn/lcd_controller/ColorTFT-LCDController.ppt"
    check_svn_return_value
    svn import -m "Import from OC" "DUI0146C_LM600.pdf" "http://192.168.100.145/ocsvn/lcd_controller/DUI0146C_LM600.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "tx18d16vm1caa.pdf" "http://192.168.100.145/ocsvn/lcd_controller/tx18d16vm1caa.pdf"
    check_svn_return_value
    popd
    pushd "ldpc_decoder_802_3an"
    svn import -m "Import from OC" "ldpc_decoder_802_3an.tar.gz" "http://192.168.100.145/ocsvn/ldpc_decoder_802_3an/ldpc_decoder_802_3an.tar.gz"
    check_svn_return_value
    popd
    pushd "ldpc_encoder_802_3an"
    svn import -m "Import from OC" "ldpc_encoder_802_3an.v.gz" "http://192.168.100.145/ocsvn/ldpc_encoder_802_3an/ldpc_encoder_802_3an.v.gz"
    check_svn_return_value
    popd
    pushd "lem1_9min"
    svn import -m "Import from OC" "d3_lem1_9min_hw.ucf" "http://192.168.100.145/ocsvn/lem1_9min/d3_lem1_9min_hw.ucf"
    check_svn_return_value
    svn import -m "Import from OC" "Form1.cs" "http://192.168.100.145/ocsvn/lem1_9min/Form1.cs"
    check_svn_return_value
    svn import -m "Import from OC" "lem1_9min_asm.csproj" "http://192.168.100.145/ocsvn/lem1_9min/lem1_9min_asm.csproj"
    check_svn_return_value
    svn import -m "Import from OC" "lem1_9min_defs.vhd" "http://192.168.100.145/ocsvn/lem1_9min/lem1_9min_defs.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "lem1_9min_hw.vhd" "http://192.168.100.145/ocsvn/lem1_9min/lem1_9min_hw.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "lem1_9min.vhd" "http://192.168.100.145/ocsvn/lem1_9min/lem1_9min.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "trinity_talk_041205.pdf" "http://192.168.100.145/ocsvn/lem1_9min/trinity_talk_041205.pdf"
    check_svn_return_value
    popd
    pushd "light8080"
    popd
    pushd "lin-a"
    popd
    pushd "line_codes"
    popd
    pushd "linuxvcap"
    popd
    pushd "llc1394"
    popd
    pushd "log_anal"
    popd
    pushd "lowpowerfir"
    svn import -m "Import from OC" "FIRLowPowerConsiderations.doc" "http://192.168.100.145/ocsvn/lowpowerfir/FIRLowPowerConsiderations.doc"
    check_svn_return_value
    svn import -m "Import from OC" "fir.zip" "http://192.168.100.145/ocsvn/lowpowerfir/fir.zip"
    check_svn_return_value
    popd
    pushd "lpc"
    popd
    pushd "lpu"
    svn import -m "Import from OC" "lpu.zip" "http://192.168.100.145/ocsvn/lpu/lpu.zip"
    check_svn_return_value
    svn import -m "Import from OC" "Mem Driven Processor.doc" "http://192.168.100.145/ocsvn/lpu/Mem Driven Processor.doc"
    check_svn_return_value
    popd
    pushd "lq057q3dc02"
    popd
    pushd "lwmips"
    popd
    pushd "lwrisc"
    svn import -m "Import from OC" "200735153855.bmp" "http://192.168.100.145/ocsvn/lwrisc/200735153855.bmp"
    check_svn_return_value
    svn import -m "Import from OC" "200735153855.JPG" "http://192.168.100.145/ocsvn/lwrisc/200735153855.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "clairisc.JPG" "http://192.168.100.145/ocsvn/lwrisc/clairisc.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_200735153855.JPG" "http://192.168.100.145/ocsvn/lwrisc/thumb_200735153855.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_clairisc.JPG" "http://192.168.100.145/ocsvn/lwrisc/thumb_clairisc.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_we.GIF" "http://192.168.100.145/ocsvn/lwrisc/thumb_we.GIF"
    check_svn_return_value
    svn import -m "Import from OC" "we.GIF" "http://192.168.100.145/ocsvn/lwrisc/we.GIF"
    check_svn_return_value
    popd
    pushd "m1_core"
    popd
    pushd "mac"
    popd
    pushd "macroblock_motion_detection"
    popd
    pushd "maf"
    popd
    pushd "mafa-pc-board"
    popd
    pushd "man2uart"
    svn import -m "Import from OC" "Man2uartopencores.txt" "http://192.168.100.145/ocsvn/man2uart/Man2uartopencores.txt"
    check_svn_return_value
    popd
    pushd "manchesterencoderdecoder"
    svn import -m "Import from OC" "ME2.vhd" "http://192.168.100.145/ocsvn/manchesterencoderdecoder/ME2.vhd"
    check_svn_return_value
    popd
    pushd "marca"
    popd
    pushd "matrix3x3"
    popd
    pushd "maxii-evalboard"
    svn import -m "Import from OC" "MAXII-Evalboard-V1.00-Designpackage.zip" "http://192.168.100.145/ocsvn/maxii-evalboard/MAXII-Evalboard-V1.00-Designpackage.zip"
    check_svn_return_value
    svn import -m "Import from OC" "MAXII-Evalboard_V1.0_a.jpg" "http://192.168.100.145/ocsvn/maxii-evalboard/MAXII-Evalboard_V1.0_a.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "MAXII-Evalboard_V1.0_b.jpg" "http://192.168.100.145/ocsvn/maxii-evalboard/MAXII-Evalboard_V1.0_b.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "MAXII-Evalboard_V1.0_BOM.xls" "http://192.168.100.145/ocsvn/maxii-evalboard/MAXII-Evalboard_V1.0_BOM.xls"
    check_svn_return_value
    svn import -m "Import from OC" "MAXII-Evalboard_V1.0_Gerber&CAM.zip" "http://192.168.100.145/ocsvn/maxii-evalboard/MAXII-Evalboard_V1.0_Gerber&CAM.zip"
    check_svn_return_value
    svn import -m "Import from OC" "MAXII-Evalboard_V1.0.jpg" "http://192.168.100.145/ocsvn/maxii-evalboard/MAXII-Evalboard_V1.0.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "MAXII-Evalboard_V1.0_PCB-Errata.txt" "http://192.168.100.145/ocsvn/maxii-evalboard/MAXII-Evalboard_V1.0_PCB-Errata.txt"
    check_svn_return_value
    svn import -m "Import from OC" "MAXII-Evalboard_V1.0_PCB.pdf" "http://192.168.100.145/ocsvn/maxii-evalboard/MAXII-Evalboard_V1.0_PCB.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "MAXII-Evalboard_V1.0_Placement.pdf" "http://192.168.100.145/ocsvn/maxii-evalboard/MAXII-Evalboard_V1.0_Placement.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "MAXII-Evalboard_V1.0_Protel.zip" "http://192.168.100.145/ocsvn/maxii-evalboard/MAXII-Evalboard_V1.0_Protel.zip"
    check_svn_return_value
    svn import -m "Import from OC" "MAXII-Evalboard_V1.0_Schem.pdf" "http://192.168.100.145/ocsvn/maxii-evalboard/MAXII-Evalboard_V1.0_Schem.pdf"
    check_svn_return_value
    popd
    pushd "mb-jpeg"
    svn import -m "Import from OC" "mb-jpeg_STEP2_1b.tar.bz2" "http://192.168.100.145/ocsvn/mb-jpeg/mb-jpeg_STEP2_1b.tar.bz2"
    check_svn_return_value
    svn import -m "Import from OC" "mb-jpeg_STEP2_2b.tar.bz2" "http://192.168.100.145/ocsvn/mb-jpeg/mb-jpeg_STEP2_2b.tar.bz2"
    check_svn_return_value
    svn import -m "Import from OC" "mb-jpeg_STEP7_2.tar.bz2" "http://192.168.100.145/ocsvn/mb-jpeg/mb-jpeg_STEP7_2.tar.bz2"
    check_svn_return_value
    popd
    pushd "mcbsp"
    popd
    pushd "mcpu"
    svn import -m "Import from OC" "mcpu_1.06b.zip" "http://192.168.100.145/ocsvn/mcpu/mcpu_1.06b.zip"
    check_svn_return_value
    svn import -m "Import from OC" "mcpu-doc.pdf" "http://192.168.100.145/ocsvn/mcpu/mcpu-doc.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "mcpu.pdf" "http://192.168.100.145/ocsvn/mcpu/mcpu.pdf"
    check_svn_return_value
    popd
    pushd "mcu8"
    popd
    pushd "md5"
    popd
    pushd "mdct"
    svn import -m "Import from OC" "block_diagram.jpg" "http://192.168.100.145/ocsvn/mdct/block_diagram.jpg"
    check_svn_return_value
    popd
    pushd "membist"
    popd
    pushd "mem_ctrl"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/mem_ctrl/index.shtml"
    check_svn_return_value
    popd
    pushd "memorycontroller"
    popd
    pushd "memory_cores"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/memory_cores/index.shtml"
    check_svn_return_value
    popd
    pushd "memory_sizer"
    svn import -m "Import from OC" "b10_safe_12_18_01_dual_path.zip" "http://192.168.100.145/ocsvn/memory_sizer/b10_safe_12_18_01_dual_path.zip"
    check_svn_return_value
    svn import -m "Import from OC" "b10_safe_12_18_01_single_path.zip" "http://192.168.100.145/ocsvn/memory_sizer/b10_safe_12_18_01_single_path.zip"
    check_svn_return_value
    svn import -m "Import from OC" "documentation.shtml" "http://192.168.100.145/ocsvn/memory_sizer/documentation.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "download.shtml" "http://192.168.100.145/ocsvn/memory_sizer/download.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/memory_sizer/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "memory_sizer_dual_path.v" "http://192.168.100.145/ocsvn/memory_sizer/memory_sizer_dual_path.v"
    check_svn_return_value
    svn import -m "Import from OC" "memory_sizer.v" "http://192.168.100.145/ocsvn/memory_sizer/memory_sizer.v"
    check_svn_return_value
    svn import -m "Import from OC" "people.shtml" "http://192.168.100.145/ocsvn/memory_sizer/people.shtml"
    check_svn_return_value
    popd
    pushd "mfpga"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/mfpga/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "mfpga_block.gif" "http://192.168.100.145/ocsvn/mfpga/mfpga_block.gif"
    check_svn_return_value
    svn import -m "Import from OC" "mfpga_block_new.gif" "http://192.168.100.145/ocsvn/mfpga/mfpga_block_new.gif"
    check_svn_return_value
    svn import -m "Import from OC" "micro_orcad.sch" "http://192.168.100.145/ocsvn/mfpga/micro_orcad.sch"
    check_svn_return_value
    svn import -m "Import from OC" "micro_protelbinary.lib" "http://192.168.100.145/ocsvn/mfpga/micro_protelbinary.lib"
    check_svn_return_value
    svn import -m "Import from OC" "micro_protelbinary.sch" "http://192.168.100.145/ocsvn/mfpga/micro_protelbinary.sch"
    check_svn_return_value
    svn import -m "Import from OC" "micro_sch.pdf" "http://192.168.100.145/ocsvn/mfpga/micro_sch.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "xcv50.jpg" "http://192.168.100.145/ocsvn/mfpga/xcv50.jpg"
    check_svn_return_value
    popd
    pushd "micore"
    popd
    pushd "microprocessor"
    popd
    pushd "milsa"
    popd
    pushd "milstd1553bbusprotocol"
    popd
    pushd "mini-acex1k"
    popd
    pushd "mini_aes"
    popd
    pushd "minimips"
    svn import -m "Import from OC" "miniMIPS.zip" "http://192.168.100.145/ocsvn/minimips/miniMIPS.zip"
    check_svn_return_value
    popd
    pushd "minirisc"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/minirisc/index.shtml"
    check_svn_return_value
    popd
    pushd "mips789"
    svn import -m "Import from OC" "cal_PI_2.GIF" "http://192.168.100.145/ocsvn/mips789/cal_PI_2.GIF"
    check_svn_return_value
    svn import -m "Import from OC" "MIPS789.bmp" "http://192.168.100.145/ocsvn/mips789/MIPS789.bmp"
    check_svn_return_value
    svn import -m "Import from OC" "pi_2200.GIF" "http://192.168.100.145/ocsvn/mips789/pi_2200.GIF"
    check_svn_return_value
    svn import -m "Import from OC" "topview.GIF" "http://192.168.100.145/ocsvn/mips789/topview.GIF"
    check_svn_return_value
    popd
    pushd "mipss"
    svn import -m "Import from OC" "s70_32bit_to_9bit.vhd" "http://192.168.100.145/ocsvn/mipss/s70_32bit_to_9bit.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "s70_ALU.vhd" "http://192.168.100.145/ocsvn/mipss/s70_ALU.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "s70_ctrl_unit.vhd" "http://192.168.100.145/ocsvn/mipss/s70_ctrl_unit.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "s70_data_mem_comp.vhd" "http://192.168.100.145/ocsvn/mipss/s70_data_mem_comp.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "s70_data_mem.vhd" "http://192.168.100.145/ocsvn/mipss/s70_data_mem.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "s70_datapath.vhd" "http://192.168.100.145/ocsvn/mipss/s70_datapath.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "s70_Ext_S_Z.vhd" "http://192.168.100.145/ocsvn/mipss/s70_Ext_S_Z.vhd"
    check_svn_return_value
    svn import -m "Import from OC" "s70_inc.vhd" "http://192.168.100.145/ocsvn/mipss/s70_inc.vhd"
    check_svn_return_value
    popd
    pushd "mmcfpgaconfig"
    popd
    pushd "moonshadow"
    popd
    pushd "most"
    svn import -m "Import from OC" "MOST_Core_Compliance_Test_Specification.pdf" "http://192.168.100.145/ocsvn/most/MOST_Core_Compliance_Test_Specification.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "MOSTSpecification.pdf" "http://192.168.100.145/ocsvn/most/MOSTSpecification.pdf"
    check_svn_return_value
    popd
    pushd "most_core"
    popd
    pushd "motion_controller"
    popd
    pushd "motionestimator"
    popd
    pushd "motor"
    popd
    pushd "mp3decoder"
    popd
    pushd "mpdma"
    svn import -m "Import from OC" "BlazeCluster_v0.14.tar.bz2" "http://192.168.100.145/ocsvn/mpdma/BlazeCluster_v0.14.tar.bz2"
    check_svn_return_value
    svn import -m "Import from OC" "BlazeCluster_v0.15.tar.bz2" "http://192.168.100.145/ocsvn/mpdma/BlazeCluster_v0.15.tar.bz2"
    check_svn_return_value
    svn import -m "Import from OC" "BlazeClusterv0.17.zip" "http://192.168.100.145/ocsvn/mpdma/BlazeClusterv0.17.zip"
    check_svn_return_value
    svn import -m "Import from OC" "BlazeClusterv0.1.zip" "http://192.168.100.145/ocsvn/mpdma/BlazeClusterv0.1.zip"
    check_svn_return_value
    svn import -m "Import from OC" "koblenz8_20070902.zip" "http://192.168.100.145/ocsvn/mpdma/koblenz8_20070902.zip"
    check_svn_return_value
    svn import -m "Import from OC" "mpdma20061020.tar.bz2" "http://192.168.100.145/ocsvn/mpdma/mpdma20061020.tar.bz2"
    check_svn_return_value
    svn import -m "Import from OC" "mpdma20061023b.tar.bz2" "http://192.168.100.145/ocsvn/mpdma/mpdma20061023b.tar.bz2"
    check_svn_return_value
    svn import -m "Import from OC" "mpdma20061023c.tar.bz2" "http://192.168.100.145/ocsvn/mpdma/mpdma20061023c.tar.bz2"
    check_svn_return_value
    svn import -m "Import from OC" "mpdma20061023.tar.bz2" "http://192.168.100.145/ocsvn/mpdma/mpdma20061023.tar.bz2"
    check_svn_return_value
    svn import -m "Import from OC" "SoftwareMultiprocessoronFPGA20070608.pdf" "http://192.168.100.145/ocsvn/mpdma/SoftwareMultiprocessoronFPGA20070608.pdf"
    check_svn_return_value
    popd
    pushd "mpeg2decoder"
    popd
    pushd "mpeg4_video_coding"
    popd
    pushd "mpegencoderdecoder"
    popd
    pushd "mup"
    popd
    pushd "ncore"
    svn import -m "Import from OC" "CASM.C" "http://192.168.100.145/ocsvn/ncore/CASM.C"
    check_svn_return_value
    svn import -m "Import from OC" "NCORE2.V" "http://192.168.100.145/ocsvn/ncore/NCORE2.V"
    check_svn_return_value
    svn import -m "Import from OC" "NCORE3.V" "http://192.168.100.145/ocsvn/ncore/NCORE3.V"
    check_svn_return_value
    svn import -m "Import from OC" "nCore_doc.pdf" "http://192.168.100.145/ocsvn/ncore/nCore_doc.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "NCORE.tar.bz2" "http://192.168.100.145/ocsvn/ncore/NCORE.tar.bz2"
    check_svn_return_value
    svn import -m "Import from OC" "nCore.v" "http://192.168.100.145/ocsvn/ncore/nCore.v"
    check_svn_return_value
    svn import -m "Import from OC" "SIM.C" "http://192.168.100.145/ocsvn/ncore/SIM.C"
    check_svn_return_value
    popd
    pushd "nemo_emotion"
    popd
    pushd "neot"
    popd
    pushd "neptune-core"
    svn import -m "Import from OC" "triton-block.png" "http://192.168.100.145/ocsvn/neptune-core/triton-block.png"
    check_svn_return_value
    popd
    pushd "nnARM"
    svn import -m "Import from OC" "Arch118.pdf" "http://192.168.100.145/ocsvn/nnARM/Arch118.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "Architecture111.pdf" "http://192.168.100.145/ocsvn/nnARM/Architecture111.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "Architecture111.pdf.old" "http://192.168.100.145/ocsvn/nnARM/Architecture111.pdf.old"
    check_svn_return_value
    svn import -m "Import from OC" "Architecture_jc.pdf" "http://192.168.100.145/ocsvn/nnARM/Architecture_jc.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "BS.shtml" "http://192.168.100.145/ocsvn/nnARM/BS.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "default.htm" "http://192.168.100.145/ocsvn/nnARM/default.htm"
    check_svn_return_value
    svn import -m "Import from OC" "Documentation.shtml" "http://192.168.100.145/ocsvn/nnARM/Documentation.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "Download.shtml" "http://192.168.100.145/ocsvn/nnARM/Download.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "GT.shtml" "http://192.168.100.145/ocsvn/nnARM/GT.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index1.shtml" "http://192.168.100.145/ocsvn/nnARM/index1.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml1" "http://192.168.100.145/ocsvn/nnARM/index.shtml1"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml.old" "http://192.168.100.145/ocsvn/nnARM/index.shtml.old"
    check_svn_return_value
    svn import -m "Import from OC" "Introduction.shtml" "http://192.168.100.145/ocsvn/nnARM/Introduction.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "News.htm" "http://192.168.100.145/ocsvn/nnARM/News.htm"
    check_svn_return_value
    svn import -m "Import from OC" "News.shtml" "http://192.168.100.145/ocsvn/nnARM/News.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "nnARM.prog" "http://192.168.100.145/ocsvn/nnARM/nnARM.prog"
    check_svn_return_value
    svn import -m "Import from OC" "nnARM_tb01_07_10_1.zip" "http://192.168.100.145/ocsvn/nnARM/nnARM_tb01_07_10_1.zip"
    check_svn_return_value
    svn import -m "Import from OC" "nnARM_tb01_07_19.zip" "http://192.168.100.145/ocsvn/nnARM/nnARM_tb01_07_19.zip"
    check_svn_return_value
    svn import -m "Import from OC" "nnARM_tb01_07_20.zip" "http://192.168.100.145/ocsvn/nnARM/nnARM_tb01_07_20.zip"
    check_svn_return_value
    svn import -m "Import from OC" "nnARM_tb01_09_02.zip" "http://192.168.100.145/ocsvn/nnARM/nnARM_tb01_09_02.zip"
    check_svn_return_value
    svn import -m "Import from OC" "People.htm" "http://192.168.100.145/ocsvn/nnARM/People.htm"
    check_svn_return_value
    svn import -m "Import from OC" "People.shtml" "http://192.168.100.145/ocsvn/nnARM/People.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "PR.shtml" "http://192.168.100.145/ocsvn/nnARM/PR.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "put.JPG" "http://192.168.100.145/ocsvn/nnARM/put.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "sARM01_06_08_1.zip" "http://192.168.100.145/ocsvn/nnARM/sARM01_06_08_1.zip"
    check_svn_return_value
    svn import -m "Import from OC" "sARM01_06_12_2.zip" "http://192.168.100.145/ocsvn/nnARM/sARM01_06_12_2.zip"
    check_svn_return_value
    svn import -m "Import from OC" "sARM01_06_15_2.zip" "http://192.168.100.145/ocsvn/nnARM/sARM01_06_15_2.zip"
    check_svn_return_value
    svn import -m "Import from OC" "sARM01_07_12_2.zip" "http://192.168.100.145/ocsvn/nnARM/sARM01_07_12_2.zip"
    check_svn_return_value
    svn import -m "Import from OC" "sARM01_07_19_4.zip" "http://192.168.100.145/ocsvn/nnARM/sARM01_07_19_4.zip"
    check_svn_return_value
    svn import -m "Import from OC" "sARM01_07_20_2.zip" "http://192.168.100.145/ocsvn/nnARM/sARM01_07_20_2.zip"
    check_svn_return_value
    svn import -m "Import from OC" "sARM01_07_30_4.zip" "http://192.168.100.145/ocsvn/nnARM/sARM01_07_30_4.zip"
    check_svn_return_value
    svn import -m "Import from OC" "sARM01_08_30_3.zip" "http://192.168.100.145/ocsvn/nnARM/sARM01_08_30_3.zip"
    check_svn_return_value
    svn import -m "Import from OC" "sARM01_09_02_1.zip" "http://192.168.100.145/ocsvn/nnARM/sARM01_09_02_1.zip"
    check_svn_return_value
    svn import -m "Import from OC" "sARM01_09_05_2.zip" "http://192.168.100.145/ocsvn/nnARM/sARM01_09_05_2.zip"
    check_svn_return_value
    svn import -m "Import from OC" "sARM01_11_1_3.zip.zip" "http://192.168.100.145/ocsvn/nnARM/sARM01_11_1_3.zip.zip"
    check_svn_return_value
    svn import -m "Import from OC" "sARM_tb.zip" "http://192.168.100.145/ocsvn/nnARM/sARM_tb.zip"
    check_svn_return_value
    svn import -m "Import from OC" "tag3.bmp" "http://192.168.100.145/ocsvn/nnARM/tag3.bmp"
    check_svn_return_value
    svn import -m "Import from OC" "Testbench" "http://192.168.100.145/ocsvn/nnARM/Testbench"
    check_svn_return_value
    svn import -m "Import from OC" "topFrame.htm" "http://192.168.100.145/ocsvn/nnARM/topFrame.htm"
    check_svn_return_value
    svn import -m "Import from OC" "wishlogo.jpg" "http://192.168.100.145/ocsvn/nnARM/wishlogo.jpg"
    check_svn_return_value
    popd
    pushd "nocem"
    popd
    pushd "noise_reduction"
    popd
    pushd "nonrestoringsquareroot"
    popd
    pushd "nova"
    popd
    pushd "npigrctrl"
    svn import -m "Import from OC" "demo.png" "http://192.168.100.145/ocsvn/npigrctrl/demo.png"
    check_svn_return_value
    svn import -m "Import from OC" "mpmc4.rar" "http://192.168.100.145/ocsvn/npigrctrl/mpmc4.rar"
    check_svn_return_value
    svn import -m "Import from OC" "npi_eng.vhd" "http://192.168.100.145/ocsvn/npigrctrl/npi_eng.vhd"
    check_svn_return_value
    popd
    pushd "oab1"
    svn import -m "Import from OC" "index.htm" "http://192.168.100.145/ocsvn/oab1/index.htm"
    check_svn_return_value
    svn import -m "Import from OC" "title_logo.gif" "http://192.168.100.145/ocsvn/oab1/title_logo.gif"
    check_svn_return_value
    svn import -m "Import from OC" "ver01.JPG" "http://192.168.100.145/ocsvn/oab1/ver01.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "ver02.jpg" "http://192.168.100.145/ocsvn/oab1/ver02.jpg"
    check_svn_return_value
    popd
    pushd "oberon"
    popd
    pushd "ocmips"
    svn import -m "Import from OC" "fpga.gif" "http://192.168.100.145/ocsvn/ocmips/fpga.gif"
    check_svn_return_value
    svn import -m "Import from OC" "opencores.gif" "http://192.168.100.145/ocsvn/ocmips/opencores.gif"
    check_svn_return_value
    svn import -m "Import from OC" "sim.GIF" "http://192.168.100.145/ocsvn/ocmips/sim.GIF"
    check_svn_return_value
    popd
    pushd "ocp_wb_wrapper"
    popd
    pushd "ocrp-1"
    svn import -m "Import from OC" "block.gif" "http://192.168.100.145/ocsvn/ocrp-1/block.gif"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/ocrp-1/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "ocrp-1_bill_of_materials.txt" "http://192.168.100.145/ocsvn/ocrp-1/ocrp-1_bill_of_materials.txt"
    check_svn_return_value
    svn import -m "Import from OC" "ocrp-1_gerber.tar.gz" "http://192.168.100.145/ocsvn/ocrp-1/ocrp-1_gerber.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "ocrp1.jpg" "http://192.168.100.145/ocsvn/ocrp-1/ocrp1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "ocrp1ord.pdf" "http://192.168.100.145/ocsvn/ocrp-1/ocrp1ord.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "ocrp-1_sch.pdf" "http://192.168.100.145/ocsvn/ocrp-1/ocrp-1_sch.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "PCB1-72dpi.jpg" "http://192.168.100.145/ocsvn/ocrp-1/PCB1-72dpi.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "PCB2-72dpi.jpg" "http://192.168.100.145/ocsvn/ocrp-1/PCB2-72dpi.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "pic1.jpg" "http://192.168.100.145/ocsvn/ocrp-1/pic1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "pic2.jpg" "http://192.168.100.145/ocsvn/ocrp-1/pic2.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "pic3.jpg" "http://192.168.100.145/ocsvn/ocrp-1/pic3.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "pic4.jpg" "http://192.168.100.145/ocsvn/ocrp-1/pic4.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "pic7.jpg" "http://192.168.100.145/ocsvn/ocrp-1/pic7.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "xc95288xl_tq144.bsd" "http://192.168.100.145/ocsvn/ocrp-1/xc95288xl_tq144.bsd"
    check_svn_return_value
    svn import -m "Import from OC" "xcv100_tq144.bsd" "http://192.168.100.145/ocsvn/ocrp-1/xcv100_tq144.bsd"
    check_svn_return_value
    svn import -m "Import from OC" "xcv50_tq144.bsd" "http://192.168.100.145/ocsvn/ocrp-1/xcv50_tq144.bsd"
    check_svn_return_value
    popd
    pushd "ofdm"
    popd
    pushd "ofdm-baseband-receiver"
    popd
    pushd "ofdm_modulator"
    popd
    pushd "oks8"
    popd
    pushd "omega"
    popd
    pushd "omrpv2"
    svn import -m "Import from OC" "OMRPv2_board_datasheet.pdf" "http://192.168.100.145/ocsvn/omrpv2/OMRPv2_board_datasheet.pdf"
    check_svn_return_value
    popd
    pushd "opb_i2c"
    popd
    pushd "opb_isa"
    popd
    pushd "opb_onewire"
    popd
    pushd "opb_ps2_keyboard_controller"
    popd
    pushd "opb_psram_controller"
    popd
    pushd "opb_udp_transceiver"
    popd
    pushd "opb_vga_char_display_nodac"
    popd
    pushd "opb_wb_wrapper"
    popd
    pushd "open_1394_intellectual_property"
    popd
    pushd "open8_urisc"
    popd
    pushd "openarm"
    popd
    pushd "opencores"
    svn import -m "Import from OC" "27dec03_IrishTimes.pdf" "http://192.168.100.145/ocsvn/opencores/27dec03_IrishTimes.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "bottom.jpg" "http://192.168.100.145/ocsvn/opencores/bottom.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "dr_logo_b.gif" "http://192.168.100.145/ocsvn/opencores/dr_logo_b.gif"
    check_svn_return_value
    svn import -m "Import from OC" "logos" "http://192.168.100.145/ocsvn/opencores/logos"
    check_svn_return_value
    svn import -m "Import from OC" "mdl_logo.jpg" "http://192.168.100.145/ocsvn/opencores/mdl_logo.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "ORSoC_logo.jpg" "http://192.168.100.145/ocsvn/opencores/ORSoC_logo.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "press" "http://192.168.100.145/ocsvn/opencores/press"
    check_svn_return_value
    svn import -m "Import from OC" "regionalbreakdown.png" "http://192.168.100.145/ocsvn/opencores/regionalbreakdown.png"
    check_svn_return_value
    svn import -m "Import from OC" "siteranking.png" "http://192.168.100.145/ocsvn/opencores/siteranking.png"
    check_svn_return_value
    svn import -m "Import from OC" "sponsors" "http://192.168.100.145/ocsvn/opencores/sponsors"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_dr_logo_b.gif" "http://192.168.100.145/ocsvn/opencores/thumb_dr_logo_b.gif"
    check_svn_return_value
    svn import -m "Import from OC" "Ultimodule_Logo_Blue.JPG" "http://192.168.100.145/ocsvn/opencores/Ultimodule_Logo_Blue.JPG"
    check_svn_return_value
    popd
    pushd "opencpu678085"
    popd
    pushd "openfire"
    popd
    pushd "openfire2"
    svn import -m "Import from OC" "freertos.zip" "http://192.168.100.145/ocsvn/openfire2/freertos.zip"
    check_svn_return_value
    svn import -m "Import from OC" "targetselection.itb" "http://192.168.100.145/ocsvn/openfire2/targetselection.itb"
    check_svn_return_value
    popd
    pushd "openfire_core"
    popd
    pushd "openh263"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/openh263/index.shtml"
    check_svn_return_value
    popd
    pushd "openriscdevboard"
    svn import -m "Import from OC" "altera_dev_brd.zip" "http://192.168.100.145/ocsvn/openriscdevboard/altera_dev_brd.zip"
    check_svn_return_value
    svn import -m "Import from OC" "fpgaConfigEval_V1_2.zip" "http://192.168.100.145/ocsvn/openriscdevboard/fpgaConfigEval_V1_2.zip"
    check_svn_return_value
    svn import -m "Import from OC" "usbPlusUart.zip" "http://192.168.100.145/ocsvn/openriscdevboard/usbPlusUart.zip"
    check_svn_return_value
    popd
    pushd "open_tcpip"
    popd
    pushd "opentech"
    svn import -m "Import from OC" "changes_1_4_0.txt" "http://192.168.100.145/ocsvn/opentech/changes_1_4_0.txt"
    check_svn_return_value
    svn import -m "Import from OC" "changes_1_4_1.txt" "http://192.168.100.145/ocsvn/opentech/changes_1_4_1.txt"
    check_svn_return_value
    svn import -m "Import from OC" "changes_1_5_0.txt" "http://192.168.100.145/ocsvn/opentech/changes_1_5_0.txt"
    check_svn_return_value
    svn import -m "Import from OC" "changes_1_5_1.txt" "http://192.168.100.145/ocsvn/opentech/changes_1_5_1.txt"
    check_svn_return_value
    svn import -m "Import from OC" "changes_1_6_0.txt" "http://192.168.100.145/ocsvn/opentech/changes_1_6_0.txt"
    check_svn_return_value
    svn import -m "Import from OC" "changes_1_6_1.txt" "http://192.168.100.145/ocsvn/opentech/changes_1_6_1.txt"
    check_svn_return_value
    svn import -m "Import from OC" "contents_1_4_0.txt" "http://192.168.100.145/ocsvn/opentech/contents_1_4_0.txt"
    check_svn_return_value
    svn import -m "Import from OC" "contents_1_4_1.txt" "http://192.168.100.145/ocsvn/opentech/contents_1_4_1.txt"
    check_svn_return_value
    svn import -m "Import from OC" "contents_1_5_0.txt" "http://192.168.100.145/ocsvn/opentech/contents_1_5_0.txt"
    check_svn_return_value
    svn import -m "Import from OC" "contents_1_5_1.txt" "http://192.168.100.145/ocsvn/opentech/contents_1_5_1.txt"
    check_svn_return_value
    svn import -m "Import from OC" "contents_1_6_0.txt" "http://192.168.100.145/ocsvn/opentech/contents_1_6_0.txt"
    check_svn_return_value
    svn import -m "Import from OC" "contents_1_6_1.txt" "http://192.168.100.145/ocsvn/opentech/contents_1_6_1.txt"
    check_svn_return_value
    svn import -m "Import from OC" "content.txt" "http://192.168.100.145/ocsvn/opentech/content.txt"
    check_svn_return_value
    svn import -m "Import from OC" "covers.zip" "http://192.168.100.145/ocsvn/opentech/covers.zip"
    check_svn_return_value
    svn import -m "Import from OC" "icon.gif" "http://192.168.100.145/ocsvn/opentech/icon.gif"
    check_svn_return_value
    svn import -m "Import from OC" "icon.jpg" "http://192.168.100.145/ocsvn/opentech/icon.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "icon.png" "http://192.168.100.145/ocsvn/opentech/icon.png"
    check_svn_return_value
    svn import -m "Import from OC" "logo_full.jpg" "http://192.168.100.145/ocsvn/opentech/logo_full.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "OpenTech_Info.xls" "http://192.168.100.145/ocsvn/opentech/OpenTech_Info.xls"
    check_svn_return_value
    svn import -m "Import from OC" "OpenTechnologies_small.gif" "http://192.168.100.145/ocsvn/opentech/OpenTechnologies_small.gif"
    check_svn_return_value
    svn import -m "Import from OC" "OT_Contents.zip" "http://192.168.100.145/ocsvn/opentech/OT_Contents.zip"
    check_svn_return_value
    popd
    pushd "openverifla"
    svn import -m "Import from OC" "verifla_keyboard_protocol_verification_50procent.jpg" "http://192.168.100.145/ocsvn/openverifla/verifla_keyboard_protocol_verification_50procent.jpg"
    check_svn_return_value
    popd
    pushd "or-1200-ft"
    popd
    pushd "or1200gct"
    popd
    pushd "or1k-cf"
    popd
    pushd "or1k-new"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/or1k-new/index.shtml"
    check_svn_return_value
    popd
    pushd "ovcodec"
    svn import -m "Import from OC" "ogg_files.zip" "http://192.168.100.145/ocsvn/ovcodec/ogg_files.zip"
    check_svn_return_value
    popd
    pushd "pap"
    popd
    pushd "pavr"
    svn import -m "Import from OC" "pavr032.chm.zip" "http://192.168.100.145/ocsvn/pavr/pavr032.chm.zip"
    check_svn_return_value
    svn import -m "Import from OC" "pavr032-devel.zip" "http://192.168.100.145/ocsvn/pavr/pavr032-devel.zip"
    check_svn_return_value
    svn import -m "Import from OC" "pavr032.html.zip" "http://192.168.100.145/ocsvn/pavr/pavr032.html.zip"
    check_svn_return_value
    svn import -m "Import from OC" "pavr0351-devel.zip" "http://192.168.100.145/ocsvn/pavr/pavr0351-devel.zip"
    check_svn_return_value
    svn import -m "Import from OC" "pavr0351-release-chm.zip" "http://192.168.100.145/ocsvn/pavr/pavr0351-release-chm.zip"
    check_svn_return_value
    svn import -m "Import from OC" "pavr0351-release-html.zip" "http://192.168.100.145/ocsvn/pavr/pavr0351-release-html.zip"
    check_svn_return_value
    svn import -m "Import from OC" "todo.html" "http://192.168.100.145/ocsvn/pavr/todo.html"
    check_svn_return_value
    popd
    pushd "pci"
    svn import -m "Import from OC" "charact.shtml" "http://192.168.100.145/ocsvn/pci/charact.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "contacts.shtml" "http://192.168.100.145/ocsvn/pci/contacts.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "current_stat.shtml" "http://192.168.100.145/ocsvn/pci/current_stat.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "documentation.shtml" "http://192.168.100.145/ocsvn/pci/documentation.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "download.shtml" "http://192.168.100.145/ocsvn/pci/download.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/pci/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "links.shtml" "http://192.168.100.145/ocsvn/pci/links.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "PCI_HOST_architecture.jpg" "http://192.168.100.145/ocsvn/pci/PCI_HOST_architecture.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "pci_parity.html" "http://192.168.100.145/ocsvn/pci/pci_parity.html"
    check_svn_return_value
    svn import -m "Import from OC" "pci_prototype.shtml" "http://192.168.100.145/ocsvn/pci/pci_prototype.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "PCIsim.shtml" "http://192.168.100.145/ocsvn/pci/PCIsim.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "pci_snapshots.shtml" "http://192.168.100.145/ocsvn/pci/pci_snapshots.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "PCI_VGA_conn.jpg" "http://192.168.100.145/ocsvn/pci/PCI_VGA_conn.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "PCI_VGA_cristal.jpg" "http://192.168.100.145/ocsvn/pci/PCI_VGA_cristal.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "PCI_VGA_sch.gif" "http://192.168.100.145/ocsvn/pci/PCI_VGA_sch.gif"
    check_svn_return_value
    svn import -m "Import from OC" "PCI_VGA_sch.jpg" "http://192.168.100.145/ocsvn/pci/PCI_VGA_sch.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "PCI_VGA_test_brd.gif" "http://192.168.100.145/ocsvn/pci/PCI_VGA_test_brd.gif"
    check_svn_return_value
    svn import -m "Import from OC" "pcixwin.jpg" "http://192.168.100.145/ocsvn/pci/pcixwin.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "Pic00022.jpg" "http://192.168.100.145/ocsvn/pci/Pic00022.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "Pic00026.jpg" "http://192.168.100.145/ocsvn/pci/Pic00026.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "Pic00027.jpg" "http://192.168.100.145/ocsvn/pci/Pic00027.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "Pic00028.jpg" "http://192.168.100.145/ocsvn/pci/Pic00028.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "Pic00037.jpg" "http://192.168.100.145/ocsvn/pci/Pic00037.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "pics" "http://192.168.100.145/ocsvn/pci/pics"
    check_svn_return_value
    svn import -m "Import from OC" "references.shtml" "http://192.168.100.145/ocsvn/pci/references.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "test_app.shtml" "http://192.168.100.145/ocsvn/pci/test_app.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "testbench.shtml" "http://192.168.100.145/ocsvn/pci/testbench.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "test_board.shtml" "http://192.168.100.145/ocsvn/pci/test_board.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "test_driver.shtml" "http://192.168.100.145/ocsvn/pci/test_driver.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "test_snapshots.shtml" "http://192.168.100.145/ocsvn/pci/test_snapshots.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_pcixwin.jpg" "http://192.168.100.145/ocsvn/pci/thumb_pcixwin.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_Pic00022.jpg" "http://192.168.100.145/ocsvn/pci/thumb_Pic00022.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_Pic00026.jpg" "http://192.168.100.145/ocsvn/pci/thumb_Pic00026.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_Pic00027.jpg" "http://192.168.100.145/ocsvn/pci/thumb_Pic00027.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_Pic00028.jpg" "http://192.168.100.145/ocsvn/pci/thumb_Pic00028.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_Pic00037.jpg" "http://192.168.100.145/ocsvn/pci/thumb_Pic00037.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "todo_list.shtml" "http://192.168.100.145/ocsvn/pci/todo_list.shtml"
    check_svn_return_value
    popd
    pushd "pci32tlite_oc"
    svn import -m "Import from OC" "pci32tlite_oc_R03.zip" "http://192.168.100.145/ocsvn/pci32tlite_oc/pci32tlite_oc_R03.zip"
    check_svn_return_value
    popd
    pushd "pci-board"
    svn import -m "Import from OC" "PCI-Board.jpeg" "http://192.168.100.145/ocsvn/pci-board/PCI-Board.jpeg"
    check_svn_return_value
    svn import -m "Import from OC" "PCI-Board.jpg" "http://192.168.100.145/ocsvn/pci-board/PCI-Board.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "PCI-CARD-SCH-v1.0.pdf" "http://192.168.100.145/ocsvn/pci-board/PCI-CARD-SCH-v1.0.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "PCI-Card-v1.0.pdf" "http://192.168.100.145/ocsvn/pci-board/PCI-Card-v1.0.pdf"
    check_svn_return_value
    popd
    pushd "pci_controller"
    svn import -m "Import from OC" "*" "http://192.168.100.145/ocsvn/pci_controller/*"
    check_svn_return_value
    popd
    pushd "pcie_vera_tb"
    popd
    pushd "pci_express"
    popd
    pushd "pci_express_crc"
    popd
    pushd "pci_ide_controller"
    popd
    pushd "pci_mini"
    svn import -m "Import from OC" "PCI_Mini_IP_core_Datasheet2.0_oc.pdf" "http://192.168.100.145/ocsvn/pci_mini/PCI_Mini_IP_core_Datasheet2.0_oc.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "PCI_mini.zip" "http://192.168.100.145/ocsvn/pci_mini/PCI_mini.zip"
    check_svn_return_value
    popd
    pushd "pcix"
    popd
    pushd "pcmcia"
    popd
    pushd "performance_counter"
    svn import -m "Import from OC" "PeformanceCounterforMicroblazev0.1.zip" "http://192.168.100.145/ocsvn/performance_counter/PeformanceCounterforMicroblazev0.1.zip"
    check_svn_return_value
    popd
    pushd "perlilog"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/perlilog/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "old-index.shtml" "http://192.168.100.145/ocsvn/perlilog/old-index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "Perlilog-0.2.tar.gz" "http://192.168.100.145/ocsvn/perlilog/Perlilog-0.2.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "Perlilog-0.3.tar.gz" "http://192.168.100.145/ocsvn/perlilog/Perlilog-0.3.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "perlilog-guide-0.2.pdf" "http://192.168.100.145/ocsvn/perlilog/perlilog-guide-0.2.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "perlilog-guide-0.3.pdf" "http://192.168.100.145/ocsvn/perlilog/perlilog-guide-0.3.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "perlilog-guide.pdf" "http://192.168.100.145/ocsvn/perlilog/perlilog-guide.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "perlilog.tar.gz" "http://192.168.100.145/ocsvn/perlilog/perlilog.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "perlilog.zip" "http://192.168.100.145/ocsvn/perlilog/perlilog.zip"
    check_svn_return_value
    popd
    pushd "phoenix_controller"
    popd
    pushd "pic8259"
    popd
    pushd "picoblaze_interrupt_controller"
    svn import -m "Import from OC" "Pblaze_IntController-061221.zip" "http://192.168.100.145/ocsvn/picoblaze_interrupt_controller/Pblaze_IntController-061221.zip"
    check_svn_return_value
    popd
    pushd "pif2wb"
    popd
    pushd "pipelined_aes"
    popd
    pushd "pipelined_dct"
    popd
    pushd "piranha"
    svn import -m "Import from OC" "*" "http://192.168.100.145/ocsvn/piranha/*"
    check_svn_return_value
    popd
    pushd "plbv46_to_wb_bridge"
    svn import -m "Import from OC" "plbv46_2_wb_v1_10_a.zip" "http://192.168.100.145/ocsvn/plbv46_to_wb_bridge/plbv46_2_wb_v1_10_a.zip"
    check_svn_return_value
    popd
    pushd "power_inverter"
    popd
    pushd "ppcnorthbridge"
    popd
    pushd "ppx16"
    popd
    pushd "processor"
    svn import -m "Import from OC" "Atlast.v" "http://192.168.100.145/ocsvn/processor/Atlast.v"
    check_svn_return_value
    popd
    pushd "product_code_iterative_decoder"
    popd
    pushd "profibus_dp"
    svn import -m "Import from OC" "vhdl_source_files.zip" "http://192.168.100.145/ocsvn/profibus_dp/vhdl_source_files.zip"
    check_svn_return_value
    popd
    pushd "programmabledct"
    popd
    pushd "project"
    svn import -m "Import from OC" "datapath.pdf" "http://192.168.100.145/ocsvn/project/datapath.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "Informations.doc" "http://192.168.100.145/ocsvn/project/Informations.doc"
    check_svn_return_value
    svn import -m "Import from OC" "memories_core_jenerator_implementations.rar" "http://192.168.100.145/ocsvn/project/memories_core_jenerator_implementations.rar"
    check_svn_return_value
    svn import -m "Import from OC" "Readme-Instructions.doc" "http://192.168.100.145/ocsvn/project/Readme-Instructions.doc"
    check_svn_return_value
    svn import -m "Import from OC" "RegFile_SystemC_implementation.rar" "http://192.168.100.145/ocsvn/project/RegFile_SystemC_implementation.rar"
    check_svn_return_value
    svn import -m "Import from OC" "systemC_Implementation.rar" "http://192.168.100.145/ocsvn/project/systemC_Implementation.rar"
    check_svn_return_value
    svn import -m "Import from OC" "Xilinx_project_from_files_from_SystemC_implementation.rar" "http://192.168.100.145/ocsvn/project/Xilinx_project_from_files_from_SystemC_implementation.rar"
    check_svn_return_value
    popd
    pushd "ps2"
    svn import -m "Import from OC" "documentation.shtml" "http://192.168.100.145/ocsvn/ps2/documentation.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "download.shtml" "http://192.168.100.145/ocsvn/ps2/download.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/ps2/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "people.shtml" "http://192.168.100.145/ocsvn/ps2/people.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "ps2_keyboard.v" "http://192.168.100.145/ocsvn/ps2/ps2_keyboard.v"
    check_svn_return_value
    svn import -m "Import from OC" "ps2_mouse.v" "http://192.168.100.145/ocsvn/ps2/ps2_mouse.v"
    check_svn_return_value
    svn import -m "Import from OC" "ps2_soc1.zip" "http://192.168.100.145/ocsvn/ps2/ps2_soc1.zip"
    check_svn_return_value
    svn import -m "Import from OC" "ps2_soc2.zip" "http://192.168.100.145/ocsvn/ps2/ps2_soc2.zip"
    check_svn_return_value
    popd
    pushd "ps2core"
    popd
    pushd "ptc"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/ptc/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "ptc_spec.pdf" "http://192.168.100.145/ocsvn/ptc/ptc_spec.pdf"
    check_svn_return_value
    popd
    pushd "pyramid_unit"
    popd
    pushd "quadraturecount"
    popd
    pushd "r2000"
    popd
    pushd "radixrsa"
    svn import -m "Import from OC" "core.shtml" "http://192.168.100.145/ocsvn/radixrsa/core.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "doc.shtml" "http://192.168.100.145/ocsvn/radixrsa/doc.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "dotty.gif" "http://192.168.100.145/ocsvn/radixrsa/dotty.gif"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/radixrsa/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "montgo.jpg" "http://192.168.100.145/ocsvn/radixrsa/montgo.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "RSAAlgorithm.pdf" "http://192.168.100.145/ocsvn/radixrsa/RSAAlgorithm.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "title_logo.gif" "http://192.168.100.145/ocsvn/radixrsa/title_logo.gif"
    check_svn_return_value
    popd
    pushd "raggedstone"
    svn import -m "Import from OC" "README" "http://192.168.100.145/ocsvn/raggedstone/README"
    check_svn_return_value
    popd
    pushd "rc5-72"
    popd
    pushd "rc5_decoder"
    popd
    pushd "redfir"
    popd
    pushd "rfid"
    svn import -m "Import from OC" "7Prog.pdf" "http://192.168.100.145/ocsvn/rfid/7Prog.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "TheMultiTagTesterFinal.exe" "http://192.168.100.145/ocsvn/rfid/TheMultiTagTesterFinal.exe"
    check_svn_return_value
    popd
    pushd "rijndael"
    svn import -m "Import from OC" "dekrip_files" "http://192.168.100.145/ocsvn/rijndael/dekrip_files"
    check_svn_return_value
    svn import -m "Import from OC" "dekrip.htm" "http://192.168.100.145/ocsvn/rijndael/dekrip.htm"
    check_svn_return_value
    svn import -m "Import from OC" "enkrip_files" "http://192.168.100.145/ocsvn/rijndael/enkrip_files"
    check_svn_return_value
    svn import -m "Import from OC" "enkrip.htm" "http://192.168.100.145/ocsvn/rijndael/enkrip.htm"
    check_svn_return_value
    svn import -m "Import from OC" "enkrip.pdf" "http://192.168.100.145/ocsvn/rijndael/enkrip.pdf"
    check_svn_return_value
    popd
    pushd "rijndael_aes"
    popd
    pushd "risc16f84"
    svn import -m "Import from OC" "b13c_environment.zip" "http://192.168.100.145/ocsvn/risc16f84/b13c_environment.zip"
    check_svn_return_value
    svn import -m "Import from OC" "documentation.shtml" "http://192.168.100.145/ocsvn/risc16f84/documentation.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "download.shtml" "http://192.168.100.145/ocsvn/risc16f84/download.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/risc16f84/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "people.shtml" "http://192.168.100.145/ocsvn/risc16f84/people.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "risc16f84_clk2x.v" "http://192.168.100.145/ocsvn/risc16f84/risc16f84_clk2x.v"
    check_svn_return_value
    svn import -m "Import from OC" "risc16f84_lite.v" "http://192.168.100.145/ocsvn/risc16f84/risc16f84_lite.v"
    check_svn_return_value
    svn import -m "Import from OC" "risc16f84_small.v" "http://192.168.100.145/ocsvn/risc16f84/risc16f84_small.v"
    check_svn_return_value
    svn import -m "Import from OC" "risc16f84.v" "http://192.168.100.145/ocsvn/risc16f84/risc16f84.v"
    check_svn_return_value
    svn import -m "Import from OC" "srec_to_rs232.pl" "http://192.168.100.145/ocsvn/risc16f84/srec_to_rs232.pl"
    check_svn_return_value
    popd
    pushd "risc36"
    popd
    pushd "risc5x"
    svn import -m "Import from OC" "hex_conv.zip" "http://192.168.100.145/ocsvn/risc5x/hex_conv.zip"
    check_svn_return_value
    svn import -m "Import from OC" "risc5x_rel1.0.zip" "http://192.168.100.145/ocsvn/risc5x/risc5x_rel1.0.zip"
    check_svn_return_value
    svn import -m "Import from OC" "risc5x_rel1.1.zip" "http://192.168.100.145/ocsvn/risc5x/risc5x_rel1.1.zip"
    check_svn_return_value
    popd
    pushd "risc_core_i"
    svn import -m "Import from OC" "risc_core_I.zip" "http://192.168.100.145/ocsvn/risc_core_i/risc_core_I.zip"
    check_svn_return_value
    svn import -m "Import from OC" "RISCCore.pdf" "http://192.168.100.145/ocsvn/risc_core_i/RISCCore.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "vhdl files.zip" "http://192.168.100.145/ocsvn/risc_core_i/vhdl files.zip"
    check_svn_return_value
    svn import -m "Import from OC" "Zusammenfassung.pdf" "http://192.168.100.145/ocsvn/risc_core_i/Zusammenfassung.pdf"
    check_svn_return_value
    popd
    pushd "riscmcu"
    svn import -m "Import from OC" "BlockDiagram.gif" "http://192.168.100.145/ocsvn/riscmcu/BlockDiagram.gif"
    check_svn_return_value
    popd
    pushd "risc_processor_with_os"
    popd
    pushd "rise"
    popd
    pushd "rng_lib"
    svn import -m "Import from OC" "rng_lib_v10.zip" "http://192.168.100.145/ocsvn/rng_lib/rng_lib_v10.zip"
    check_svn_return_value
    popd
    pushd "robot_control_library"
    svn import -m "Import from OC" "documentation.zip" "http://192.168.100.145/ocsvn/robot_control_library/documentation.zip"
    check_svn_return_value
    svn import -m "Import from OC" "drivers.zip" "http://192.168.100.145/ocsvn/robot_control_library/drivers.zip"
    check_svn_return_value
    svn import -m "Import from OC" "OPB_PID_v1_00_a.zip" "http://192.168.100.145/ocsvn/robot_control_library/OPB_PID_v1_00_a.zip"
    check_svn_return_value
    svn import -m "Import from OC" "OPB_PS2_Joypad_v1_00_a.zip" "http://192.168.100.145/ocsvn/robot_control_library/OPB_PS2_Joypad_v1_00_a.zip"
    check_svn_return_value
    svn import -m "Import from OC" "OPB_PWM_v1_00_a.zip" "http://192.168.100.145/ocsvn/robot_control_library/OPB_PWM_v1_00_a.zip"
    check_svn_return_value
    svn import -m "Import from OC" "Quadrature_Encoder_v1_00_a.zip" "http://192.168.100.145/ocsvn/robot_control_library/Quadrature_Encoder_v1_00_a.zip"
    check_svn_return_value
    svn import -m "Import from OC" "Stepper_Control_v1_00_a.zip" "http://192.168.100.145/ocsvn/robot_control_library/Stepper_Control_v1_00_a.zip"
    check_svn_return_value
    popd
    pushd "rosetta"
    popd
    pushd "rs232_syscon"
    svn import -m "Import from OC" "b10_safe_12_18_01_dual_path.zip" "http://192.168.100.145/ocsvn/rs232_syscon/b10_safe_12_18_01_dual_path.zip"
    check_svn_return_value
    svn import -m "Import from OC" "b11_risc16f84_05_03_02.zip" "http://192.168.100.145/ocsvn/rs232_syscon/b11_risc16f84_05_03_02.zip"
    check_svn_return_value
    svn import -m "Import from OC" "b13_safe_09_17_02.zip" "http://192.168.100.145/ocsvn/rs232_syscon/b13_safe_09_17_02.zip"
    check_svn_return_value
    svn import -m "Import from OC" "documentation.shtml" "http://192.168.100.145/ocsvn/rs232_syscon/documentation.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "download.shtml" "http://192.168.100.145/ocsvn/rs232_syscon/download.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "Image4.gif" "http://192.168.100.145/ocsvn/rs232_syscon/Image4.gif"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/rs232_syscon/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "people.shtml" "http://192.168.100.145/ocsvn/rs232_syscon/people.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "rs232_syscon_1_00_source.zip" "http://192.168.100.145/ocsvn/rs232_syscon/rs232_syscon_1_00_source.zip"
    check_svn_return_value
    svn import -m "Import from OC" "rs232_syscon_1_01_xsoc.zip" "http://192.168.100.145/ocsvn/rs232_syscon/rs232_syscon_1_01_xsoc.zip"
    check_svn_return_value
    svn import -m "Import from OC" "rs232_syscon1.doc" "http://192.168.100.145/ocsvn/rs232_syscon/rs232_syscon1.doc"
    check_svn_return_value
    svn import -m "Import from OC" "rs232_syscon_autobaud.zip" "http://192.168.100.145/ocsvn/rs232_syscon/rs232_syscon_autobaud.zip"
    check_svn_return_value
    svn import -m "Import from OC" "rs232_syscon.htm" "http://192.168.100.145/ocsvn/rs232_syscon/rs232_syscon.htm"
    check_svn_return_value
    svn import -m "Import from OC" "rs232_syscon.pdf" "http://192.168.100.145/ocsvn/rs232_syscon/rs232_syscon.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "rs232_syscon_soc1.zip" "http://192.168.100.145/ocsvn/rs232_syscon/rs232_syscon_soc1.zip"
    check_svn_return_value
    svn import -m "Import from OC" "rs232_syscon_soc2.zip" "http://192.168.100.145/ocsvn/rs232_syscon/rs232_syscon_soc2.zip"
    check_svn_return_value
    svn import -m "Import from OC" "rs232_syscon_soc3.zip" "http://192.168.100.145/ocsvn/rs232_syscon/rs232_syscon_soc3.zip"
    check_svn_return_value
    svn import -m "Import from OC" "srec_to_rs232.pl" "http://192.168.100.145/ocsvn/rs232_syscon/srec_to_rs232.pl"
    check_svn_return_value
    popd
    pushd "rs_5_3_gf256"
    svn import -m "Import from OC" "ReedSolomon(5,3)Codec.ppt" "http://192.168.100.145/ocsvn/rs_5_3_gf256/ReedSolomon(5,3)Codec.ppt"
    check_svn_return_value
    popd
    pushd "rsa"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/rsa/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "rsa" "http://192.168.100.145/ocsvn/rsa/rsa"
    check_svn_return_value
    svn import -m "Import from OC" "RSA.htm" "http://192.168.100.145/ocsvn/rsa/RSA.htm"
    check_svn_return_value
    svn import -m "Import from OC" "RSA.shtml" "http://192.168.100.145/ocsvn/rsa/RSA.shtml"
    check_svn_return_value
    popd
    pushd "rs_decoder_31_19_6"
    popd
    pushd "rsencoder"
    svn import -m "Import from OC" "readme.txt" "http://192.168.100.145/ocsvn/rsencoder/readme.txt"
    check_svn_return_value
    svn import -m "Import from OC" "reed_solomon.v" "http://192.168.100.145/ocsvn/rsencoder/reed_solomon.v"
    check_svn_return_value
    svn import -m "Import from OC" "rs_testbench.v" "http://192.168.100.145/ocsvn/rsencoder/rs_testbench.v"
    check_svn_return_value
    popd
    pushd "s1_core"
    popd
    pushd "sardmips"
    popd
    pushd "sasc"
    popd
    pushd "sata1a"
    popd
    pushd "sayeh_processor"
    svn import -m "Import from OC" "SAYEH-U1-V.rar" "http://192.168.100.145/ocsvn/sayeh_processor/SAYEH-U1-V.rar"
    check_svn_return_value
    popd
    pushd "sbd_sqrt_fp"
    popd
    pushd "sc2v"
    popd
    pushd "scalable_arbiter"
    popd
    pushd "scarm"
    svn import -m "Import from OC" "arm1.JPG" "http://192.168.100.145/ocsvn/scarm/arm1.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "chinese" "http://192.168.100.145/ocsvn/scarm/chinese"
    check_svn_return_value
    svn import -m "Import from OC" "english" "http://192.168.100.145/ocsvn/scarm/english"
    check_svn_return_value
    svn import -m "Import from OC" "images" "http://192.168.100.145/ocsvn/scarm/images"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/scarm/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "main.shtml" "http://192.168.100.145/ocsvn/scarm/main.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "src.zip" "http://192.168.100.145/ocsvn/scarm/src.zip"
    check_svn_return_value
    svn import -m "Import from OC" "test" "http://192.168.100.145/ocsvn/scarm/test"
    check_svn_return_value
    svn import -m "Import from OC" "test.zip" "http://192.168.100.145/ocsvn/scarm/test.zip"
    check_svn_return_value
    popd
    pushd "scsi_chip"
    svn import -m "Import from OC" "Address_translate.v" "http://192.168.100.145/ocsvn/scsi_chip/Address_translate.v"
    check_svn_return_value
    svn import -m "Import from OC" "Data_buffer.v" "http://192.168.100.145/ocsvn/scsi_chip/Data_buffer.v"
    check_svn_return_value
    svn import -m "Import from OC" "registers_complex.v" "http://192.168.100.145/ocsvn/scsi_chip/registers_complex.v"
    check_svn_return_value
    svn import -m "Import from OC" "SRAM_controler.v" "http://192.168.100.145/ocsvn/scsi_chip/SRAM_controler.v"
    check_svn_return_value
    popd
    pushd "scsi_interface"
    popd
    pushd "sdram"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/sdram/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml2" "http://192.168.100.145/ocsvn/sdram/index.shtml2"
    check_svn_return_value
    svn import -m "Import from OC" "intefacing block diagram.gif" "http://192.168.100.145/ocsvn/sdram/intefacing block diagram.gif"
    check_svn_return_value
    svn import -m "Import from OC" "interfacing_block_diagram.gif" "http://192.168.100.145/ocsvn/sdram/interfacing_block_diagram.gif"
    check_svn_return_value
    svn import -m "Import from OC" "sdram_doc.pdf" "http://192.168.100.145/ocsvn/sdram/sdram_doc.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "sdram.html" "http://192.168.100.145/ocsvn/sdram/sdram.html"
    check_svn_return_value
    svn import -m "Import from OC" "sdram_ip_doc_preliminary.pdf" "http://192.168.100.145/ocsvn/sdram/sdram_ip_doc_preliminary.pdf"
    check_svn_return_value
    popd
    pushd "sdram_core"
    popd
    pushd "sdram_ctrl"
    popd
    pushd "sdr_sdram_ctrl"
    popd
    pushd "serial_div_uu"
    svn import -m "Import from OC" "pwm_reader.v" "http://192.168.100.145/ocsvn/serial_div_uu/pwm_reader.v"
    check_svn_return_value
    svn import -m "Import from OC" "serial_divide_uu.v" "http://192.168.100.145/ocsvn/serial_div_uu/serial_divide_uu.v"
    check_svn_return_value
    popd
    pushd "serpent_core"
    popd
    pushd "sfpga"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/sfpga/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "ocrp-2_protel_sch.zip" "http://192.168.100.145/ocsvn/sfpga/ocrp-2_protel_sch.zip"
    check_svn_return_value
    svn import -m "Import from OC" "OCRP-2_sch_preliminary.pdf" "http://192.168.100.145/ocsvn/sfpga/OCRP-2_sch_preliminary.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "sfpga_block.gif" "http://192.168.100.145/ocsvn/sfpga/sfpga_block.gif"
    check_svn_return_value
    popd
    pushd "sha1"
    svn import -m "Import from OC" "sha1_readme_v01.txt" "http://192.168.100.145/ocsvn/sha1/sha1_readme_v01.txt"
    check_svn_return_value
    svn import -m "Import from OC" "sha1_v01.zip" "http://192.168.100.145/ocsvn/sha1/sha1_v01.zip"
    check_svn_return_value
    popd
    pushd "sha_core"
    popd
    pushd "simpcon"
    popd
    pushd "simplearm"
    popd
    pushd "simple-cpu"
    popd
    pushd "simple_fm_receiver"
    popd
    pushd "simple_gpio"
    popd
    pushd "simple_pic"
    popd
    pushd "simple_spi"
    popd
    pushd "simple_uart"
    svn import -m "Import from OC" "simpleUart.zip" "http://192.168.100.145/ocsvn/simple_uart/simpleUart.zip"
    check_svn_return_value
    popd
    pushd "single_clock_divider"
    popd
    pushd "single_port"
    svn import -m "Import from OC" "single_port.tar.gz" "http://192.168.100.145/ocsvn/single_port/single_port.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "single_port.zip" "http://192.168.100.145/ocsvn/single_port/single_port.zip"
    check_svn_return_value
    popd
    pushd "slave_vme_bridge"
    popd
    pushd "smallarm"
    popd
    pushd "smbus_if"
    svn import -m "Import from OC" "smbus_if.doc" "http://192.168.100.145/ocsvn/smbus_if/smbus_if.doc"
    check_svn_return_value
    popd
    pushd "socbuilder"
    popd
    pushd "soft_core_risc_microprocessor_design_enabling_the_port_of_an_os"
    popd
    pushd "sonet"
    svn import -m "Import from OC" "blockdia.doc" "http://192.168.100.145/ocsvn/sonet/blockdia.doc"
    check_svn_return_value
    svn import -m "Import from OC" "overview.doc" "http://192.168.100.145/ocsvn/sonet/overview.doc"
    check_svn_return_value
    popd
    pushd "spacewire"
    svn import -m "Import from OC" "Router.JPG" "http://192.168.100.145/ocsvn/spacewire/Router.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "SpWinterfacewithCODEC.JPG" "http://192.168.100.145/ocsvn/spacewire/SpWinterfacewithCODEC.JPG"
    check_svn_return_value
    popd
    pushd "spacewire_if"
    popd
    pushd "spates"
    popd
    pushd "spdif_interface"
    popd
    pushd "spi"
    popd
    pushd "spi_boot"
    popd
    pushd "spicc"
    popd
    pushd "spiflashcontroller"
    popd
    pushd "spimaster"
    popd
    pushd "spi_slave"
    popd
    pushd "spi-slave"
    svn import -m "Import from OC" "*" "http://192.168.100.145/ocsvn/spi-slave/*"
    check_svn_return_value
    popd
    pushd "srl_fifo"
    popd
    pushd "srtdivision"
    popd
    pushd "ss_pcm"
    popd
    pushd "ssram"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/ssram/index.shtml"
    check_svn_return_value
    popd
    pushd "steppermotordrive"
    popd
    pushd "stone"
    popd
    pushd "sts1"
    svn import -m "Import from OC" "spe.vhd" "http://192.168.100.145/ocsvn/sts1/spe.vhd"
    check_svn_return_value
    popd
    pushd "svmac"
    popd
    pushd "sxp"
    svn import -m "Import from OC" "sxp_block.gif" "http://192.168.100.145/ocsvn/sxp/sxp_block.gif"
    check_svn_return_value
    popd
    pushd "system05"
    popd
    pushd "system09"
    svn import -m "Import from OC" "index.html" "http://192.168.100.145/ocsvn/system09/index.html"
    check_svn_return_value
    svn import -m "Import from OC" "System09-oc-6sep03.zip" "http://192.168.100.145/ocsvn/system09/System09-oc-6sep03.zip"
    check_svn_return_value
    svn import -m "Import from OC" "xbasic.s19" "http://192.168.100.145/ocsvn/system09/xbasic.s19"
    check_svn_return_value
    popd
    pushd "system11"
    svn import -m "Import from OC" "Sys11_X300_5sep03.zip" "http://192.168.100.145/ocsvn/system11/Sys11_X300_5sep03.zip"
    check_svn_return_value
    popd
    pushd "system68"
    svn import -m "Import from OC" "Sys68-X300-17jan04.zip" "http://192.168.100.145/ocsvn/system68/Sys68-X300-17jan04.zip"
    check_svn_return_value
    popd
    pushd "system6801"
    svn import -m "Import from OC" "System6801.zip" "http://192.168.100.145/ocsvn/system6801/System6801.zip"
    check_svn_return_value
    svn import -m "Import from OC" "utilities.zip" "http://192.168.100.145/ocsvn/system6801/utilities.zip"
    check_svn_return_value
    popd
    pushd "systemcaes"
    popd
    pushd "systemc_cordic"
    popd
    pushd "systemcdes"
    popd
    pushd "systemcmd5"
    popd
    pushd "systemc_rng"
    popd
    pushd "t400"
    popd
    pushd "t48"
    popd
    pushd "t51"
    popd
    pushd "t65"
    popd
    pushd "t80"
    popd
    pushd "t8000"
    popd
    pushd "tdm"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/tdm/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_core.jpg" "http://192.168.100.145/ocsvn/tdm/tdm_core.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_core.ps" "http://192.168.100.145/ocsvn/tdm/tdm_core.ps"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_ISDN_top.jpg" "http://192.168.100.145/ocsvn/tdm/tdm_ISDN_top.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_ISDN_top.ps" "http://192.168.100.145/ocsvn/tdm/tdm_ISDN_top.ps"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_project.html" "http://192.168.100.145/ocsvn/tdm/tdm_project.html"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_project.pdf" "http://192.168.100.145/ocsvn/tdm/tdm_project.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_project.ps" "http://192.168.100.145/ocsvn/tdm/tdm_project.ps"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_top.jpg" "http://192.168.100.145/ocsvn/tdm/tdm_top.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_top.ps" "http://192.168.100.145/ocsvn/tdm/tdm_top.ps"
    check_svn_return_value
    svn import -m "Import from OC" "wishlogo.ps" "http://192.168.100.145/ocsvn/tdm/wishlogo.ps"
    check_svn_return_value
    popd
    pushd "tdm_switch"
    svn import -m "Import from OC" "map.dat" "http://192.168.100.145/ocsvn/tdm_switch/map.dat"
    check_svn_return_value
    svn import -m "Import from OC" "ModelSim_Edition.exe" "http://192.168.100.145/ocsvn/tdm_switch/ModelSim_Edition.exe"
    check_svn_return_value
    svn import -m "Import from OC" "stream_0.dat" "http://192.168.100.145/ocsvn/tdm_switch/stream_0.dat"
    check_svn_return_value
    svn import -m "Import from OC" "stream_1.dat" "http://192.168.100.145/ocsvn/tdm_switch/stream_1.dat"
    check_svn_return_value
    svn import -m "Import from OC" "stream_2.dat" "http://192.168.100.145/ocsvn/tdm_switch/stream_2.dat"
    check_svn_return_value
    svn import -m "Import from OC" "stream_3.dat" "http://192.168.100.145/ocsvn/tdm_switch/stream_3.dat"
    check_svn_return_value
    svn import -m "Import from OC" "stream_4.dat" "http://192.168.100.145/ocsvn/tdm_switch/stream_4.dat"
    check_svn_return_value
    svn import -m "Import from OC" "stream_5.dat" "http://192.168.100.145/ocsvn/tdm_switch/stream_5.dat"
    check_svn_return_value
    svn import -m "Import from OC" "stream_6.dat" "http://192.168.100.145/ocsvn/tdm_switch/stream_6.dat"
    check_svn_return_value
    svn import -m "Import from OC" "stream_7.dat" "http://192.168.100.145/ocsvn/tdm_switch/stream_7.dat"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_switch_b.v" "http://192.168.100.145/ocsvn/tdm_switch/tdm_switch_b.v"
    check_svn_return_value
    svn import -m "Import from OC" "TDM_Switch_DS.pdf" "http://192.168.100.145/ocsvn/tdm_switch/TDM_Switch_DS.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_switch_top_timesim.sdf" "http://192.168.100.145/ocsvn/tdm_switch/tdm_switch_top_timesim.sdf"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_switch_top_timesim.v" "http://192.168.100.145/ocsvn/tdm_switch/tdm_switch_top_timesim.v"
    check_svn_return_value
    svn import -m "Import from OC" "tdm_switch_top.v" "http://192.168.100.145/ocsvn/tdm_switch/tdm_switch_top.v"
    check_svn_return_value
    svn import -m "Import from OC" "testbench_top.v" "http://192.168.100.145/ocsvn/tdm_switch/testbench_top.v"
    check_svn_return_value
    popd
    pushd "template"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/template/index.shtml"
    check_svn_return_value
    popd
    pushd "test"
    svn import -m "Import from OC" "apple.gif" "http://192.168.100.145/ocsvn/test/apple.gif"
    check_svn_return_value
    svn import -m "Import from OC" "FLEX_w_CMYK_R_LG.jpg" "http://192.168.100.145/ocsvn/test/FLEX_w_CMYK_R_LG.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "include1.ssi" "http://192.168.100.145/ocsvn/test/include1.ssi"
    check_svn_return_value
    svn import -m "Import from OC" "include2.ssi" "http://192.168.100.145/ocsvn/test/include2.ssi"
    check_svn_return_value
    popd
    pushd "test1"
    svn import -m "Import from OC" "arrow_ltr.gif" "http://192.168.100.145/ocsvn/test1/arrow_ltr.gif"
    check_svn_return_value
    svn import -m "Import from OC" "sed_awk.pdf" "http://192.168.100.145/ocsvn/test1/sed_awk.pdf"
    check_svn_return_value
    popd
    pushd "test2"
    svn import -m "Import from OC" "*" "http://192.168.100.145/ocsvn/test2/*"
    check_svn_return_value
    popd
    pushd "test3"
    popd
    pushd "test_project"
    popd
    pushd "test-project"
    svn import -m "Import from OC" "vl.bmp" "http://192.168.100.145/ocsvn/test-project/vl.bmp"
    check_svn_return_value
    popd
    pushd "tg68"
    popd
    pushd "tiny64"
    popd
    pushd "tiny8"
    popd
    pushd "tlc2"
    popd
    pushd "toe"
    popd
    pushd "tone_generator"
    popd
    pushd "totalcpu"
    popd
    pushd "trinitor"
    popd
    pushd "truescalar"
    popd
    pushd "ts7300_opencore"
    svn import -m "Import from OC" "7300stclwp.jpg" "http://192.168.100.145/ocsvn/ts7300_opencore/7300stclwp.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "ts7300_opencore.zip" "http://192.168.100.145/ocsvn/ts7300_opencore/ts7300_opencore.zip"
    check_svn_return_value
    popd
    pushd "turbocodes"
    svn import -m "Import from OC" "turbo.tar.gz" "http://192.168.100.145/ocsvn/turbocodes/turbo.tar.gz"
    check_svn_return_value
    popd
    pushd "tv80"
    svn import -m "Import from OC" "tv80_rel1.0.zip" "http://192.168.100.145/ocsvn/tv80/tv80_rel1.0.zip"
    check_svn_return_value
    popd
    pushd "twofish"
    popd
    pushd "twofish_team"
    svn import -m "Import from OC" "ciphertext.jpg" "http://192.168.100.145/ocsvn/twofish_team/ciphertext.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "cleartext.jpg" "http://192.168.100.145/ocsvn/twofish_team/cleartext.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "key-mod.jpg" "http://192.168.100.145/ocsvn/twofish_team/key-mod.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "modifiedF.jpg" "http://192.168.100.145/ocsvn/twofish_team/modifiedF.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "peracangan" "http://192.168.100.145/ocsvn/twofish_team/peracangan"
    check_svn_return_value
    svn import -m "Import from OC" "qper.jpg" "http://192.168.100.145/ocsvn/twofish_team/qper.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "s-boxes.jpg" "http://192.168.100.145/ocsvn/twofish_team/s-boxes.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "twofish.jpg" "http://192.168.100.145/ocsvn/twofish_team/twofish.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "twofish.zip" "http://192.168.100.145/ocsvn/twofish_team/twofish.zip"
    check_svn_return_value
    popd
    pushd "ualpha"
    popd
    pushd "uart16550"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/uart16550/index.shtml"
    check_svn_return_value
    popd
    pushd "uart8bit"
    popd
    pushd "uart_fifo"
    popd
    pushd "uart_serial"
    popd
    pushd "ucore"
    svn import -m "Import from OC" "ucsys-0.0.1.rar" "http://192.168.100.145/ocsvn/ucore/ucsys-0.0.1.rar"
    check_svn_return_value
    popd
    pushd "ultimate_crc"
    svn import -m "Import from OC" "ultimate_crc_1_0.zip" "http://192.168.100.145/ocsvn/ultimate_crc/ultimate_crc_1_0.zip"
    check_svn_return_value
    popd
    pushd "ultramegasquirt"
    popd
    pushd "ultravec"
    popd
    pushd "upcable"
    svn import -m "Import from OC" "odd_vhdl.zip" "http://192.168.100.145/ocsvn/upcable/odd_vhdl.zip"
    check_svn_return_value
    svn import -m "Import from OC" "OneDollarDongle.pdf" "http://192.168.100.145/ocsvn/upcable/OneDollarDongle.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "ver1_xc9536xl_vq44_single_side.zip" "http://192.168.100.145/ocsvn/upcable/ver1_xc9536xl_vq44_single_side.zip"
    check_svn_return_value
    popd
    pushd "usb11"
    popd
    pushd "usb1_funct"
    popd
    pushd "usb_dongle_fpga"
    svn import -m "Import from OC" "block_diagram.png" "http://192.168.100.145/ocsvn/usb_dongle_fpga/block_diagram.png"
    check_svn_return_value
    svn import -m "Import from OC" "dongle_block.png" "http://192.168.100.145/ocsvn/usb_dongle_fpga/dongle_block.png"
    check_svn_return_value
    svn import -m "Import from OC" "mini_LR_DSC_0016.jpg" "http://192.168.100.145/ocsvn/usb_dongle_fpga/mini_LR_DSC_0016.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "small_LR_DSC_0016.jpg" "http://192.168.100.145/ocsvn/usb_dongle_fpga/small_LR_DSC_0016.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "usb_dongle.jpg" "http://192.168.100.145/ocsvn/usb_dongle_fpga/usb_dongle.jpg"
    check_svn_return_value
    popd
    pushd "usbhost"
    svn import -m "Import from OC" "alliance.shtml" "http://192.168.100.145/ocsvn/usbhost/alliance.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "HDL" "http://192.168.100.145/ocsvn/usbhost/HDL"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh10.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh10.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh11.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh11.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh12.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh12.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh13.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh13.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh14.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh14.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh15.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh15.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh16.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh16.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh17.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh17.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh18.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh18.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh19.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh19.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh1.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh20.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh20.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh21.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh21.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.sh22.jpg" "http://192.168.100.145/ocsvn/usbhost/HDL.sh22.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "HDL.shtml" "http://192.168.100.145/ocsvn/usbhost/HDL.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index.1.gif" "http://192.168.100.145/ocsvn/usbhost/index.1.gif"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/usbhost/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "README" "http://192.168.100.145/ocsvn/usbhost/README"
    check_svn_return_value
    popd
    pushd "usbhostslave"
    svn import -m "Import from OC" "ALDEC_logo.jpg" "http://192.168.100.145/ocsvn/usbhostslave/ALDEC_logo.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "dual_Fairchild_USB_PHY_daughter_card_12001-00Rev-01.zip" "http://192.168.100.145/ocsvn/usbhostslave/dual_Fairchild_USB_PHY_daughter_card_12001-00Rev-01.zip"
    check_svn_return_value
    svn import -m "Import from OC" "ohs900.zip" "http://192.168.100.145/ocsvn/usbhostslave/ohs900.zip"
    check_svn_return_value
    popd
    pushd "usb_phy"
    popd
    pushd "usucc"
    svn import -m "Import from OC" "*" "http://192.168.100.145/ocsvn/usucc/*"
    check_svn_return_value
    popd
    pushd "utop_lvl_1"
    popd
    pushd "verilator"
    popd
    pushd "verilog_cordic_core"
    svn import -m "Import from OC" "cordic.v" "http://192.168.100.145/ocsvn/verilog_cordic_core/cordic.v"
    check_svn_return_value
    svn import -m "Import from OC" "manual.pdf" "http://192.168.100.145/ocsvn/verilog_cordic_core/manual.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "tb_cordic.v" "http://192.168.100.145/ocsvn/verilog_cordic_core/tb_cordic.v"
    check_svn_return_value
    popd
    pushd "veristruct"
    popd
    pushd "vgafb"
    popd
    pushd "vga_lcd"
    svn import -m "Import from OC" "block_diagram.gif" "http://192.168.100.145/ocsvn/vga_lcd/block_diagram.gif"
    check_svn_return_value
    svn import -m "Import from OC" "block_diagram.jpg" "http://192.168.100.145/ocsvn/vga_lcd/block_diagram.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/vga_lcd/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "vga_core.pdf" "http://192.168.100.145/ocsvn/vga_lcd/vga_core.pdf"
    check_svn_return_value
    popd
    pushd "vhcg"
    svn import -m "Import from OC" "morpheus1.1release.rar" "http://192.168.100.145/ocsvn/vhcg/morpheus1.1release.rar"
    check_svn_return_value
    svn import -m "Import from OC" "morpheus.tar.gz" "http://192.168.100.145/ocsvn/vhcg/morpheus.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "Specification.pdf" "http://192.168.100.145/ocsvn/vhcg/Specification.pdf"
    check_svn_return_value
    popd
    pushd "vhdl_cpu_emulator"
    svn import -m "Import from OC" "vhdl_cpu_emulator_Beta.7z" "http://192.168.100.145/ocsvn/vhdl_cpu_emulator/vhdl_cpu_emulator_Beta.7z"
    check_svn_return_value
    popd
    pushd "vhdlmd5"
    popd
    pushd "vhdl_wavefiles"
    popd
    pushd "vhld_tb"
    popd
    pushd "video_starter_kit"
    svn import -m "Import from OC" "main_designoverview0.0.2.pdf" "http://192.168.100.145/ocsvn/video_starter_kit/main_designoverview0.0.2.pdf"
    check_svn_return_value
    popd
    pushd "vip_regs"
    popd
    pushd "viterbi_decoder"
    popd
    pushd "viterbi_decoder_k_7_r_1_2"
    popd
    pushd "vmebus"
    popd
    pushd "vmm"
    popd
    pushd "warp"
    popd
    pushd "waveform_gen"
    svn import -m "Import from OC" "spectrum_1_7MHz.png" "http://192.168.100.145/ocsvn/waveform_gen/spectrum_1_7MHz.png"
    check_svn_return_value
    svn import -m "Import from OC" "waveform_block_diag.png" "http://192.168.100.145/ocsvn/waveform_gen/waveform_block_diag.png"
    check_svn_return_value
    popd
    pushd "wb2hpi"
    svn import -m "Import from OC" "BlockTransfer1.jpg" "http://192.168.100.145/ocsvn/wb2hpi/BlockTransfer1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "BlockTransfer2.jpg" "http://192.168.100.145/ocsvn/wb2hpi/BlockTransfer2.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "DspFill1.jpg" "http://192.168.100.145/ocsvn/wb2hpi/DspFill1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "DspMemory1.jpg" "http://192.168.100.145/ocsvn/wb2hpi/DspMemory1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "DspMemory2.jpg" "http://192.168.100.145/ocsvn/wb2hpi/DspMemory2.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "DSPMove1.jpg" "http://192.168.100.145/ocsvn/wb2hpi/DSPMove1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "Registers.jpg" "http://192.168.100.145/ocsvn/wb2hpi/Registers.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "SistemMemoryFill1.jpg" "http://192.168.100.145/ocsvn/wb2hpi/SistemMemoryFill1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "SistemMemoryMove1.jpg" "http://192.168.100.145/ocsvn/wb2hpi/SistemMemoryMove1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "SystemMemory1.jpg" "http://192.168.100.145/ocsvn/wb2hpi/SystemMemory1.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "TestBench051.jpg" "http://192.168.100.145/ocsvn/wb2hpi/TestBench051.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "wb2hpi_hw2.jpg" "http://192.168.100.145/ocsvn/wb2hpi/wb2hpi_hw2.jpg"
    check_svn_return_value
    popd
    pushd "wb2npi"
    popd
    pushd "wb_builder"
    svn import -m "Import from OC" "users_manual.pdf" "http://192.168.100.145/ocsvn/wb_builder/users_manual.pdf"
    check_svn_return_value
    popd
    pushd "wb_conbus"
    popd
    pushd "wb_conmax"
    svn import -m "Import from OC" "conmax.jpg" "http://192.168.100.145/ocsvn/wb_conmax/conmax.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/wb_conmax/index.shtml"
    check_svn_return_value
    popd
    pushd "wbc_parallel_master"
    svn import -m "Import from OC" "wbc_parallel_master-spec_doc-r01.pdf" "http://192.168.100.145/ocsvn/wbc_parallel_master/wbc_parallel_master-spec_doc-r01.pdf"
    check_svn_return_value
    popd
    pushd "wb_ddr"
    popd
    pushd "wb_dma"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/wb_dma/index.shtml"
    check_svn_return_value
    popd
    pushd "wb_flash"
    popd
    pushd "wbif_68k"
    popd
    pushd "wb_lpc"
    popd
    pushd "wb_mcs51"
    popd
    pushd "wb_rtc"
    svn import -m "Import from OC" "ports.jpg" "http://192.168.100.145/ocsvn/wb_rtc/ports.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "structure.jpg" "http://192.168.100.145/ocsvn/wb_rtc/structure.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "wb_rtc.zip" "http://192.168.100.145/ocsvn/wb_rtc/wb_rtc.zip"
    check_svn_return_value
    popd
    pushd "wb_sdhci"
    popd
    pushd "wb_tk"
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/wb_tk/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "wb_arbiter.shtml" "http://192.168.100.145/ocsvn/wb_tk/wb_arbiter.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "wb_async_master.shtml" "http://192.168.100.145/ocsvn/wb_tk/wb_async_master.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "wb_async_slave.shtml" "http://192.168.100.145/ocsvn/wb_tk/wb_async_slave.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "wb_bus_resizer.shtml" "http://192.168.100.145/ocsvn/wb_tk/wb_bus_resizer.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "wb_extensions.shtml" "http://192.168.100.145/ocsvn/wb_tk/wb_extensions.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "wb_out_reg.shtml" "http://192.168.100.145/ocsvn/wb_tk/wb_out_reg.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "wb_ram.shtml" "http://192.168.100.145/ocsvn/wb_tk/wb_ram.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "wb_test.shtml" "http://192.168.100.145/ocsvn/wb_tk/wb_test.shtml"
    check_svn_return_value
    popd
    pushd "wb_vga"
    svn import -m "Import from OC" "accel.shtml" "http://192.168.100.145/ocsvn/wb_vga/accel.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "index.shtml" "http://192.168.100.145/ocsvn/wb_vga/index.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "mouse.shtml" "http://192.168.100.145/ocsvn/wb_vga/mouse.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "palette.shtml" "http://192.168.100.145/ocsvn/wb_vga/palette.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "vga_chip.shtml" "http://192.168.100.145/ocsvn/wb_vga/vga_chip.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "vga_core.shtml" "http://192.168.100.145/ocsvn/wb_vga/vga_core.shtml"
    check_svn_return_value
    svn import -m "Import from OC" "vga_core_v2.shtml" "http://192.168.100.145/ocsvn/wb_vga/vga_core_v2.shtml"
    check_svn_return_value
    popd
    pushd "wb_z80"
    popd
    pushd "wb_zbt"
    popd
    pushd "wisbone_2_ahb"
    popd
    pushd "wishbone"
    svn import -m "Import from OC" "appnote_01.pdf" "http://192.168.100.145/ocsvn/wishbone/appnote_01.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "flex.pdf" "http://192.168.100.145/ocsvn/wishbone/flex.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "press_release_12_08_2002.pdf" "http://192.168.100.145/ocsvn/wishbone/press_release_12_08_2002.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "soc_bus_comparison.pdf" "http://192.168.100.145/ocsvn/wishbone/soc_bus_comparison.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "wbspec_b1.pdf" "http://192.168.100.145/ocsvn/wishbone/wbspec_b1.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "wbspec_b2.pdf" "http://192.168.100.145/ocsvn/wishbone/wbspec_b2.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "wbspec_b3.pdf" "http://192.168.100.145/ocsvn/wishbone/wbspec_b3.pdf"
    check_svn_return_value
    popd
    pushd "wishbone2ahb"
    popd
    pushd "wishbone_bfm"
    popd
    pushd "wishbone_checker"
    popd
    pushd "wishbone_out_port"
    popd
    pushd "wishbone_to_ahb"
    popd
    pushd "wlanmac"
    popd
    pushd "wlan_modem"
    popd
    pushd "wpf"
    popd
    pushd "x25_protocol_interface_project"
    popd
    pushd "x86soc"
    popd
    pushd "xge_mac"
    popd
    pushd "xmatchpro"
    svn import -m "Import from OC" "open_xmw2.zip" "http://192.168.100.145/ocsvn/xmatchpro/open_xmw2.zip"
    check_svn_return_value
    popd
    pushd "xtea"
    popd
    pushd "yacc"
    popd
    pushd "yadmc"
    popd
    pushd "yellowstar"
    svn import -m "Import from OC" "appendix.pdf" "http://192.168.100.145/ocsvn/yellowstar/appendix.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "processor.v" "http://192.168.100.145/ocsvn/yellowstar/processor.v"
    check_svn_return_value
    svn import -m "Import from OC" "report.pdf" "http://192.168.100.145/ocsvn/yellowstar/report.pdf"
    check_svn_return_value
    svn import -m "Import from OC" "yellowstar_schematics.tar.gz" "http://192.168.100.145/ocsvn/yellowstar/yellowstar_schematics.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "yellowstar_symbols.tar.gz" "http://192.168.100.145/ocsvn/yellowstar/yellowstar_symbols.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "yellow_star.tar.gz" "http://192.168.100.145/ocsvn/yellowstar/yellow_star.tar.gz"
    check_svn_return_value
    svn import -m "Import from OC" "ys_logo.jpg" "http://192.168.100.145/ocsvn/yellowstar/ys_logo.jpg"
    check_svn_return_value
    popd
    pushd "yoda"
    svn import -m "Import from OC" "*" "http://192.168.100.145/ocsvn/yoda/*"
    check_svn_return_value
    popd
    pushd "z80soc"
    svn import -m "Import from OC" "mP5170003.JPG" "http://192.168.100.145/ocsvn/z80soc/mP5170003.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "mP5180007.JPG" "http://192.168.100.145/ocsvn/z80soc/mP5180007.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_mP5170003.JPG" "http://192.168.100.145/ocsvn/z80soc/thumb_mP5170003.JPG"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_mP5180007.JPG" "http://192.168.100.145/ocsvn/z80soc/thumb_mP5180007.JPG"
    check_svn_return_value
    popd
    pushd "zbt_sram_controller"
    svn import -m "Import from OC" "ZBTSRAM61NLP_NVP25636A_51218A.pdf" "http://192.168.100.145/ocsvn/zbt_sram_controller/ZBTSRAM61NLP_NVP25636A_51218A.pdf"
    check_svn_return_value
    popd
    pushd "zet86"
    svn import -m "Import from OC" "bios.jpg" "http://192.168.100.145/ocsvn/zet86/bios.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "img_3926.jpg" "http://192.168.100.145/ocsvn/zet86/img_3926.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_bios.jpg" "http://192.168.100.145/ocsvn/zet86/thumb_bios.jpg"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_img_3926.jpg" "http://192.168.100.145/ocsvn/zet86/thumb_img_3926.jpg"
    check_svn_return_value
    popd
    pushd "zpu"
    svn import -m "Import from OC" "compile.PNG" "http://192.168.100.145/ocsvn/zpu/compile.PNG"
    check_svn_return_value
    svn import -m "Import from OC" "simulator2.PNG" "http://192.168.100.145/ocsvn/zpu/simulator2.PNG"
    check_svn_return_value
    svn import -m "Import from OC" "simulator3.PNG" "http://192.168.100.145/ocsvn/zpu/simulator3.PNG"
    check_svn_return_value
    svn import -m "Import from OC" "simulator.PNG" "http://192.168.100.145/ocsvn/zpu/simulator.PNG"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_compile.PNG" "http://192.168.100.145/ocsvn/zpu/thumb_compile.PNG"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_simulator2.PNG" "http://192.168.100.145/ocsvn/zpu/thumb_simulator2.PNG"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_simulator3.PNG" "http://192.168.100.145/ocsvn/zpu/thumb_simulator3.PNG"
    check_svn_return_value
    svn import -m "Import from OC" "thumb_simulator.PNG" "http://192.168.100.145/ocsvn/zpu/thumb_simulator.PNG"
    check_svn_return_value
    popd
    ALL_DONE="1"
    echo "All checkins done"
done
