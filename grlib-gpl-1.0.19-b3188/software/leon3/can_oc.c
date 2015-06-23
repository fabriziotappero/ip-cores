/* -------------------------------------------------------------------------- */
/* Gaisler Research AB, 2007                                                  */
/* -------------------------------------------------------------------------- */
/* Simple self reception test for OpenCore CAN_OC Controller, with DMA        */
/* -------------------------------------------------------------------------- */

//struct can_oc_basic {
//   volatile unsigned char control_register;            /* 0000 */
//   volatile unsigned char command_register;            /* 0001 */
//   volatile unsigned char status_register;             /* 0002 */
//   volatile unsigned char interrupt_register;          /* 0003 */
//   volatile unsigned char acceptance_code_register;    /* 0004 */
//   volatile unsigned char acceptance_mask_register;    /* 0005 */
//   volatile unsigned char bus_timing_0_register;       /* 0006 */
//   volatile unsigned char bus_timing_1_register;       /* 0007 */
//   volatile unsigned char output_control_register;     /* 0008 */
//   volatile unsigned char test_register;               /* 0009 */
//   volatile unsigned char tb_identifier_byte_0;        /* 000A */
//   volatile unsigned char tb_identifier_byte_1;        /* 000B */
//   volatile unsigned char tb_data_byte_1;              /* 000C */
//   volatile unsigned char tb_data_byte_2;              /* 000D */
//   volatile unsigned char tb_data_byte_3;              /* 000E */
//   volatile unsigned char tb_data_byte_4;              /* 000F */
//   volatile unsigned char tb_data_byte_5;              /* 0010 */
//   volatile unsigned char tb_data_byte_6;              /* 0011 */
//   volatile unsigned char tb_data_byte_7;              /* 0012 */
//   volatile unsigned char tb_data_byte_8;              /* 0013 */
//   volatile unsigned char rb_identifier_byte_0;        /* 0014 */
//   volatile unsigned char rb_identifier_byte_1;        /* 0015 */
//   volatile unsigned char rb_data_byte_1;              /* 0016 */
//   volatile unsigned char rb_data_byte_2;              /* 0017 */
//   volatile unsigned char rb_data_byte_3;              /* 0018 */
//   volatile unsigned char rb_data_byte_4;              /* 0019 */
//   volatile unsigned char rb_data_byte_5;              /* 001A */
//   volatile unsigned char rb_data_byte_6;              /* 001B */
//   volatile unsigned char rb_data_byte_7;              /* 001C */
//   volatile unsigned char rb_data_byte_8;              /* 001D */
//   volatile unsigned char extra_register;              /* 001E */
//   volatile unsigned char clock_divider_register;      /* 001F */
//};

struct can_oc_extended {
   volatile unsigned char control_register;            /* 0000 */
   volatile unsigned char command_register;            /* 0001 */
   volatile unsigned char status_register;             /* 0002 */
   volatile unsigned char interrupt_register;          /* 0003 */
   volatile unsigned char interrupt_enable_register;   /* 0004 */
   volatile unsigned char reserved_register;           /* 0005 */
   volatile unsigned char bus_timing_0_register;       /* 0006 */
   volatile unsigned char bus_timing_1_register;       /* 0007 */
   volatile unsigned char output_control_register;     /* 0008 */
   volatile unsigned char test_register;               /* 0009 */
   volatile unsigned char reserved_1_register;         /* 000A */
   volatile unsigned char arbitration_lost_capture;    /* 000B */
   volatile unsigned char error_code_capture;          /* 000C */
   volatile unsigned char error_warning_limit;         /* 000D */
   volatile unsigned char rx_error_counter;            /* 000E */
   volatile unsigned char tx_error_counter;            /* 000F */
   volatile unsigned char acceptance_code_0;           /* 0010 */
   volatile unsigned char acceptance_code_1;           /* 0011 */
   volatile unsigned char acceptance_code_2;           /* 0012 */
   volatile unsigned char acceptance_code_3;           /* 0013 */
   volatile unsigned char acceptance_mask_0;           /* 0014 */
   volatile unsigned char acceptance_mask_1;           /* 0015 */
   volatile unsigned char acceptance_mask_2;           /* 0016 */
   volatile unsigned char acceptance_mask_3;           /* 0017 */
   volatile unsigned char dummy0;                      /* 0018 */
   volatile unsigned char dummy1;                      /* 0019 */
   volatile unsigned char dummy2;                      /* 001A */
   volatile unsigned char dummy3;                      /* 001B */
   volatile unsigned char dummy4;                      /* 001C */
   volatile unsigned char rx_message_counter;          /* 001D */
   volatile unsigned char rx_buffer_start_address;     /* 001E */
   volatile unsigned char clock_divider_register;      /* 001F */
};

//struct can_oc_extended_rx_sff {
//   volatile unsigned char rx_frame_information_sff;    /* 0010 */
//   volatile unsigned char rx_identifier_1_sff;         /* 0011 */
//   volatile unsigned char rx_identifier_2_sff;         /* 0012 */
//   volatile unsigned char rx_data_1_sff;               /* 0013 */
//   volatile unsigned char rx_data_2_sff;               /* 0014 */
//   volatile unsigned char rx_data_3_sff;               /* 0015 */
//   volatile unsigned char rx_data_4_sff;               /* 0016 */
//   volatile unsigned char rx_data_5_sff;               /* 0017 */
//   volatile unsigned char rx_data_6_sff;               /* 0018 */
//   volatile unsigned char rx_data_7_sff;               /* 0019 */
//   volatile unsigned char rx_data_8_sff;               /* 001A */
//};
//
//struct can_oc_extended_rx_eff {
//   volatile unsigned char rx_frame_information_eff;    /* 0010 */
//   volatile unsigned char rx_identifier_1_eff;         /* 0011 */
//   volatile unsigned char rx_identifier_2_eff;         /* 0012 */
//   volatile unsigned char rx_identifier_3_eff;         /* 0013 */
//   volatile unsigned char rx_identifier_4_eff;         /* 0014 */
//   volatile unsigned char rx_data_1_eff;               /* 0015 */
//   volatile unsigned char rx_data_2_eff;               /* 0016 */
//   volatile unsigned char rx_data_3_eff;               /* 0017 */
//   volatile unsigned char rx_data_4_eff;               /* 0018 */
//   volatile unsigned char rx_data_5_eff;               /* 0019 */
//   volatile unsigned char rx_data_6_eff;               /* 001A */
//   volatile unsigned char rx_data_7_eff;               /* 001B */
//   volatile unsigned char rx_data_8_eff;               /* 001C */
//};

//struct can_oc_extended_tx_sff {
//   volatile unsigned char tx_frame_information_sff;    /* 0010 */
//   volatile unsigned char tx_identifier_1_sff;         /* 0011 */
//   volatile unsigned char tx_identifier_2_sff;         /* 0012 */
//   volatile unsigned char tx_data_1_sff;               /* 0013 */
//   volatile unsigned char tx_data_2_sff;               /* 0014 */
//   volatile unsigned char tx_data_3_sff;               /* 0015 */
//   volatile unsigned char tx_data_4_sff;               /* 0016 */
//   volatile unsigned char tx_data_5_sff;               /* 0017 */
//   volatile unsigned char tx_data_6_sff;               /* 0018 */
//   volatile unsigned char tx_data_7_sff;               /* 0019 */
//   volatile unsigned char tx_data_8_sff;               /* 001A */
//};
//
//struct can_oc_extended_tx_eff {
//   volatile unsigned char tx_frame_information_eff;    /* 0010 */
//   volatile unsigned char tx_identifier_1_eff;         /* 0011 */
//   volatile unsigned char tx_identifier_2_eff;         /* 0012 */
//   volatile unsigned char tx_identifier_3_eff;         /* 0013 */
//   volatile unsigned char tx_identifier_4_eff;         /* 0014 */
//   volatile unsigned char tx_data_1_eff;               /* 0015 */
//   volatile unsigned char tx_data_2_eff;               /* 0016 */
//   volatile unsigned char tx_data_3_eff;               /* 0017 */
//   volatile unsigned char tx_data_4_eff;               /* 0018 */
//   volatile unsigned char tx_data_5_eff;               /* 0019 */
//   volatile unsigned char tx_data_6_eff;               /* 001A */
//   volatile unsigned char tx_data_7_eff;               /* 001B */
//   volatile unsigned char tx_data_8_eff;               /* 001C */
//};

#define reset_mode_on 0x01
#define reset_mode_off 0xFE
//#define enable_all_int 0x1E
//#define tx_request 0x01
//#define basic_mode 0x7F
#define extended_mode 0x80
#define release_buffer 0x04

#define self_test_mode 0x04
#define self_reception 0x10
//#define enable_all_int_eff 0xFF

int can_oc_test(int addr)
{
   struct can_oc_extended *ce = (struct can_oc_extended *) addr;

   volatile unsigned char *buf = (volatile unsigned char *) (addr + 0x0010);

   int tmp, i;

   report_device(0x01019000);

   // switch on reset mode
   ce->control_register = reset_mode_on;

   // switch to extended mode
   ce->clock_divider_register = extended_mode;
   ce->interrupt_enable_register = 0;

   // set bus timing
   ce->bus_timing_0_register = 0x80;
   ce->bus_timing_1_register = 0x00;

   // set acceptance and mask register
   buf[0] = 0x05;
   buf[1] = 0x06;
   buf[2] = 0x07;
   buf[3] = 0x08;
   buf[4] = 0x70;
   buf[5] = 0xe0;
   buf[6] = 0xf0;
   buf[7] = 0xc0;

   // Setting the self test mode
   ce->control_register = reset_mode_on | self_test_mode;

   // Switch-off reset mode
   ce->control_register = self_test_mode;

   // ---------- transmit and check frame data ----------

   // send first frame
//   report_subtest(0);
   buf[0] = 0x88;
   for (tmp=1; tmp < 13; tmp++)
      buf[tmp] = (unsigned char) ((tmp+4 + 16*tmp*0) & 0xFF);
   ce->command_register = self_reception;

   while (!ce->rx_message_counter);

   for (i=1; i < 5; i++) {
      // send frame
//      report_subtest(i);
      buf[0] = 0x88;
      for (tmp=1; tmp < 13; tmp++)
         buf[tmp] = (unsigned char) ((tmp+4 + 16*tmp*i) & 0xFF);
      ce->command_register = self_reception;

      // check frame
//      report_subtest(10+i-1);
      if (buf[0] != 0x88) fail(0);
      for (tmp=1; tmp < 13; tmp++)
         if (buf[tmp] != (unsigned char) ((tmp+4 + 16*tmp*(i-1)) & 0xFF))  fail (tmp);
      ce->command_register = release_buffer;

      while (!ce->rx_message_counter);
   }

   // check last frame
//   report_subtest(10+4);
   if (buf[0] != 0x88) fail(0);
   for (tmp=1; tmp < 13; tmp++)
      if (buf[tmp] != (unsigned char) ((tmp+4 + 16*tmp*(4)) & 0xFF))  fail (tmp);
   ce->command_register = release_buffer;

   ce->control_register = reset_mode_on;
}
