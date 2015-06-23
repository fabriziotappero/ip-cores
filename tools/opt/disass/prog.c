int main() {

  // Fetch from ROM
  asm("nop \n nop \n nop \n nop \n");

  // PA fff0000020
  asm(".long 0x03000000");  // offset 0
  asm(".long 0x05000100");  // offset 4
  asm(".long 0x82106000");  // offset 8
  asm(".long 0x8410a0c0");  // offset c

  // PA fff0000030
  asm(".long 0x83287020");
  asm(".long 0x84108001");
  asm(".long 0x81c08000");
  asm(".long 0x01000000");

  // Fetch from RAM
  asm("nop \n nop \n nop \n nop \n");

  // PA 00000400c0
  asm(".long 0xb5802005");
  asm(".long 0xa2102000");
  asm(".long 0x821020a9");
  asm(".long 0x83287020");

  // PA 00000400d0
  asm(".long 0xe2706000");
  asm(".long 0xe2706040");
  asm(".long 0xe2706080");
  asm(".long 0xe27060c0");

  // PA 00000400e0
  asm(".long 0xa2102000");
  asm(".long 0x82102010");
  asm(".long 0xe2f04840");
  asm(".long 0xa2102003");

  // PA 00000400f0
  asm(".long 0xe2f008a0");
  asm(".long 0xa3480000");
  asm(".long 0x819c6820");
  asm(".long 0x87802025");

  // PA 0000040100
  asm(".long 0xc0f023c0");
  asm(".long 0xc0f023c8");
  asm(".long 0xc0f023d0");
  asm(".long 0xc0f023d8");

  // PA 0000040110
  asm(".long 0xc0f023e0");
  asm(".long 0xc0f023e8");
  asm(".long 0xc0f023f0");
  asm(".long 0xc0f023f8");

  // PA 0000040120
  asm(".long 0x8f902000");
  asm(".long 0xa1902000");
  asm(".long 0x8d802000");
  asm(".long 0x85802000");

  // PA 0000040130
  asm(".long 0x87802000");
  asm(".long 0x84102000");
  asm(".long 0x89908000");
  asm(".long 0x84102000");

  // PA 0000040140
  asm(".long 0xb1808000");
  asm(".long 0x84102001");
  asm(".long 0x8528b03f");
  asm(".long 0xaf808000");

  // PA 0000040150
  asm(".long 0xb3808000");
  asm(".long 0xbf988000");
  asm(".long 0x81800000");
  asm(".long 0x9190200f");

  // PA 0000040160
  asm(".long 0x93902000");
  asm(".long 0x95902006");
  asm(".long 0x97902000");
  asm(".long 0x9b902000");

  // PA 0000040170
  asm(".long 0x99902007");
  asm(".long 0x9d902007");
  asm(".long 0x82102018");
  asm(".long 0xc0f00a01");

  // PA 0000040180
  asm(".long 0xc0f00b01");
  asm(".long 0xa2102003");
  asm(".long 0xe2f00960");
  asm(".long 0xa2102003");

  // PA 0000040190
  asm(".long 0x821020aa");
  asm(".long 0x83287020");
  asm(".long 0xe2706000");
  asm(".long 0xe2706040");

  // PA 00000401a0
  asm(".long 0xe2706080");
  asm(".long 0xe27060c0");
  asm(".long 0xa3468000");
  asm(".long 0x03000007");

  // PA 00000401b0
  asm(".long 0x82106300");
  asm(".long 0xa20c4001");
  asm(".long 0xa3347008");
  asm(".long 0x03000000");

  // PA 00000401c0
  asm(".long 0x05000130");
  asm(".long 0x82106000");
  asm(".long 0x8410a000");
  asm(".long 0x83287020");

  // PA 00000401d0
  asm(".long 0x84108001");
  asm(".long 0xa32c7003");
  asm(".long 0xc4588011");
  asm(".long 0x82102080");

  // PA 00000401e0
  asm(".long 0xc4f04b00");
  asm(".long 0x2f000200");
  asm(".long 0x8b9dc000");
  asm(".long 0x21000000");

  // PA 00000401f0
  asm(".long 0x03000130");
  asm(".long 0xa0142000");
  asm(".long 0x82106140");
  asm(".long 0xa12c3020");

  // PA 0000040200
  asm(".long 0x82104010");
  asm(".long 0x8528b007");
  asm(".long 0x82004002");
  asm(".long 0xe2584000");

  // PA 0000040210
  asm(".long 0xe2f006e0");
  asm(".long 0xe2586008");
  asm(".long 0xe2f007e0");
  asm(".long 0xe2586010");

  // PA 0000040220
  asm(".long 0xe2f006a0");
  asm(".long 0xe2586020");
  asm(".long 0xe2f006c0");
  asm(".long 0xe2586018");

  // PA 0000040230
  asm(".long 0xe2f007a0");
  asm(".long 0xe2586028");
  asm(".long 0xe2f007c0");
  asm(".long 0xe2586040");

  // PA 0000040240
  asm(".long 0xe2f00660");
  asm(".long 0xe2586048");
  asm(".long 0xe2f00760");
  asm(".long 0xe2586050");

  // PA 0000040250
  asm(".long 0xe2f00620");
  asm(".long 0xe2586060");
  asm(".long 0xe2f00640");
  asm(".long 0xe2586058");

  // PA 0000040260
  asm(".long 0xe2f00720");
  asm(".long 0xe2586068");
  asm(".long 0xe2f00740");
  asm(".long 0x94102080");

  // PA 0000040270
  asm(".long 0xc0f28ae0");
  asm(".long 0xc0f28be0");
  asm(".long 0xa2102008");
  asm(".long 0xc0f44420");

  // PA 0000040280
  asm(".long 0xa2102010");
  asm(".long 0xc0f44420");
  asm(".long 0xa210200f");
  asm(".long 0xe2f008a0");

  // PA 0000040290
  asm(".long 0x03000000");
  asm(".long 0x05000510");
  asm(".long 0x82106000");
  asm(".long 0x8410a000");

  // PA 00000402a0
  asm(".long 0x83287020");
  asm(".long 0x84108001");
  asm(".long 0x87480000");
  asm(".long 0x8f902001");

  // PA 00000402b0
  asm(".long 0x88102000");
  asm(".long 0x83990000");
  asm(".long 0x8f902000");
  asm(".long 0x90102000");

  // PA 00000402c0
  asm(".long 0x81c08000");
  asm(".long 0x81982800");
  asm(".long 0x01000000");
  asm(".long 0x01000000");

  // PA 00000402d0
  asm(".long 0x8210200f");
  asm(".long 0xc2f008a0");
  asm(".long 0xc0f00860");
  asm(".long 0x83480000");

  // End
  asm("nop \n nop \n nop \n nop \n");
  return 0;

}

