This is MCAPI transport layer for HIBI_PE_DMA filedriver.

IMPORTANT NOTES

- MCAPI node mapping entity is PE(CPU,ACC...) connected to HIBI network
- Only one node per PE is currently supported
- Define your device and filenames in hibi_mappings.h
- Table indices in hibi_mappings.h are the same as node_ids in MCAPI
- Node defines the component's base address and port_id the offset
	- eg. endpoint<1,8> => 0x03000008 (Based on default hibiAddress table in hibi_mappings.h) 
- Only statically created endpoints are supported.


