# Fill MAC Address Learning Table
#
# Address       Hash        Single hit
# 007102240600  12D8  4824  Yes
# 007102240601  0340  0832  Yes
# 007102240602  0070  0112  Yes
# 007102240603  11E8  4584  Yes
# 007102240604  0610  1552  Yes
# 007102240605  1788  6024  Yes
# 007102240606  14B8  5304  Yes
# 007102240607  0520  1312  Yes
#
mem load    -filltype value -fillradix hex -filldata C0001001007102240600  /esoc_tb/esoc_tb/u6/u2/altsyncram_component/memory/m_mem_data_a(4824)
mem load    -filltype value -fillradix hex -filldata C0001001007102240600  /esoc_tb/esoc_tb/u6/u2/altsyncram_component/memory/m_mem_data_b(4824)
#
mem load    -filltype value -fillradix hex -filldata C0080001007102240607  /esoc_tb/esoc_tb/u6/u2/altsyncram_component/memory/m_mem_data_a(1312)
mem load    -filltype value -fillradix hex -filldata C0080001007102240607  /esoc_tb/esoc_tb/u6/u2/altsyncram_component/memory/m_mem_data_b(1312)
