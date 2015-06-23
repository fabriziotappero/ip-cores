$Id: README_Rlink_V4.txt 614 2014-12-20 15:00:45Z mueller $

Summary of changes for rlink v3 to v4

Background
  The protocol was initially designed as debug interface used over serial 
  port connections. From the beginning the protocol had crc error checking
  and a simple error recovery mechanism.
  When the protocol was used in the IO emulation of the w11, features like
  block transfers, attentions, and command groups were added. Over time the
  original simple concept for error recovery became practically unusable.
  When the protocol was used on boards with a Cypress FX2 USB interface
  the number of round trips became the sole performance limiting factor.

Goals for rlink v4
  - 16 bit addresses (instead of 8 bit)
  - more robust encoding, support for error recovery at transport level
  - add features to reduce round trips
    - improved attention handling
    - new 'list abort' command

Changes in detail

  - encoding
    - framing (comma) char representation changed
      - now 2 byte sequence for comma char, with internal redundancy
      - optimized for robustness. Also more compact for larger rblk/wblk.

  - framing
    - unexpected EOP in sl_idle now silently ignored
      --> before: send NAK+EOP
      --> now allows to send EOP+NAK to start a retransmit
    - command aborts send now an error code, the abort sequence
        NAK <nakbyte> EOP
    - the nakbyte has the redundant format
        10<!nakcode><nakcode>
    - the abort sequence sequence is not protected by a crc, but has enough
      redundancy that transmission errors can be detected.
    - all unexpected commas after SOP will cause an abort. This adds robustness
      in case transmission error converts a data byte into a comma.

  - commands
    - 16 bit addresses
    - 16 bit rblk/wblk transfer size counts. Now cnt rather cnt-1 used.
    - rblk/wblk now return 'done count', number of successfully transfered words
      Note: rblk always transfers cnt words, rest is padded.
    - babo state flag added
      - babo is cleared when rblk/wblk is started, and set when they are aborted
      - babo is not changed by commands other then rblk and wblk
    - stat command removed (functionality not needed anymore)
    - labo command added
      - returns the babo flag
      - if babo set, all remaining commands in the list will be ignored
    - stat byte layout changed
      - cerr and derr flags removed (not needed anymore)
      - now 4 (instead of 3) external RB_STAT bit
    - 16 bit crc used (instead of 8 bit)
  - attn handling
    - a message with the current attn pattern is send, not only an attn comma.
      This give the attn handler a priori knowledge of LAM sources.
      An attn command must still be used to harvest the attn pattern.
    - attn poll always returns attn notify, usage of idle comma removed

  - general
    - reserve 0xff00-0xffff range for rlink system usage
    - implement 4 default registers (in rlink_core)
          ffff    cntl
          fffe    stat   (holds rtbuf size)
          fffc/d  sysid  (32 bit system identifier)
    - rlink initialization now via wreg, not with init anymore
    - has now retransmit buffer, size configurable (2,4,8,.. kB)
    - used for wblk dcrc validation in addition
    - a NAK outside a SOP/EOP frame will trigger a retransmit of last response
    - retransmit buffer cleared when first cmd processed
      -> an empty SOP-EOP does not reset the retransmit buffer
    - no internal/external init distinction, 'we' always 0 when init=1
