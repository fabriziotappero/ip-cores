This folder contains testbench for TSU module.

The PCAP files are read by the BFM to generate stimulus to the GMII interface.
The PCAP files can be filtered by "ptp.v2.messageid >= 0x00 && ptp.v2.messageid <= 0x07" and exported to TXT files as golden references.

The TX and RX TSU outputs are monitored and compared to the respective golden reference for the parser validation.
Any mismatch will be reported as Warning in the transcript.

When PCAP files are updated, the TXT files should be updated accordingly. 