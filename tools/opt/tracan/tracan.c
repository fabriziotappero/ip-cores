// Included file has some constants
#include "tracan.h"

// Global vars
char buf[200];  // Contains one binary packet
char dir;       // Direction of the packet
int len;        // Packet size

// Useful function
long bitsToInt(int first_bit, int last_bit) {
  long value = 0;
  int pos;
  for(pos=0; pos<(first_bit-last_bit+1); pos++)
    if(buf[len-last_bit-pos-1]=='1')
      value += (1<<pos);
  return value;
}

// Main function
int main() {

  while(!feof(stdin)) {
    fscanf(stdin, "%s %c\n", buf, &dir);
    len = strlen(buf);
    if(len==LEN_REQ && dir==CHAR_REQ) {

      if(bitsToInt(PCX_VLD,PCX_VLD)==1) {

        // Write details of request packet
        printf("INFO: SPC2WBM: *** NEW REQUEST FROM SPARC CORE ***\n");
        printf("INFO: SPC2WBM: Valid bit is %d\n",bitsToInt(PCX_VLD,PCX_VLD));
        switch(bitsToInt(PCX_RQ_HI,PCX_RQ_LO)) {
          case LOAD_RQ: printf("INFO: SPC2WBM: Request of Type LOAD_RQ\n"); break;
          case IMISS_RQ: printf("INFO: SPC2WBM: Request of Type IMISS_RQ\n"); break;
          case STORE_RQ: printf("INFO: SPC2WBM: Request of Type STORE_RQ\n"); break;
          case CAS1_RQ: printf("INFO: SPC2WBM: Request of Type CAS1_RQ\n"); break;
          case CAS2_RQ: printf("INFO: SPC2WBM: Request of Type CAS2_RQ\n"); break;
          case SWAP_RQ: printf("INFO: SPC2WBM: Request of Type SWAP_RQ\n"); break;
          case STRLOAD_RQ: printf("INFO: SPC2WBM: Request of Type STRLOAD_RQ\n"); break;
          case STRST_RQ: printf("INFO: SPC2WBM: Request of Type STRST_RQ\n"); break;
          case STQ_RQ: printf("INFO: SPC2WBM: Request of Type STQ_RQ\n"); break;
          case INT_RQ: printf("INFO: SPC2WBM: Request of Type INT_RQ\n"); break;
          case FWD_RQ: printf("INFO: SPC2WBM: Request of Type FWD_RQ\n"); break;
          case FWD_RPY: printf("INFO: SPC2WBM: Request of Type FWD_RPY\n"); break;
          case RSVD_RQ: printf("INFO: SPC2WBM: Request of Type RSVD_RQ\n"); break;
          default: printf("INFO: SPC2WBM: Request of Type Unknown\n");
        }
        printf("INFO: SPC2WBM: Non-Cacheable bit is %d\n", bitsToInt(PCX_R,PCX_R));
        printf("INFO: SPC2WBM: CPU-ID is %0x\n", bitsToInt(PCX_CP_HI,PCX_CP_LO));
        printf("INFO: SPC2WBM: Thread is %0x\n", bitsToInt(PCX_TH_HI,PCX_TH_LO));
        printf("INFO: SPC2WBM: Invalidate All is %0x\n", bitsToInt(PCX_INVALL,PCX_INVALL));
        printf("INFO: SPC2WBM: Replaced L1 Way is %0x\n", bitsToInt(PCX_WY_HI,PCX_WY_LO));
        switch(bitsToInt(PCX_SZ_HI,PCX_SZ_LO)) {
          case PCX_SZ_1B: printf("INFO: SPC2WBM: Request size is 1 Byte\n"); break;
          case PCX_SZ_2B: printf("INFO: SPC2WBM: Request size is 2 Bytes\n"); break;
	  case PCX_SZ_4B: printf("INFO: SPC2WBM: Request size is 4 Bytes\n"); break;
	  case PCX_SZ_8B: printf("INFO: SPC2WBM: Request size is 8 Bytes\n"); break;
	  case PCX_SZ_16B: printf("INFO: SPC2WBM: Request size is 16 Bytes\n"); break;
          default: printf("INFO: SPC2WBM: Request size is Unknown\n");
        }
        printf("INFO: SPC2WBM: Address is %05x%05x\n", bitsToInt(PCX_AD_HI,PCX_AD_HI-19), bitsToInt(PCX_AD_HI-20,PCX_AD_LO));
        printf("INFO: SPC2WBM: Data is %08x%08x\n", bitsToInt(PCX_DA_HI,PCX_DA_HI-31), bitsToInt(PCX_DA_HI-32,PCX_DA_LO));
      }

    } else if(len==LEN_RET && dir==CHAR_RET) {

      if(bitsToInt(CPX_VLD,CPX_VLD)==1) {

        // Write details of return packet
        printf("INFO: WBM2SPC: *** RETURN PACKET TO SPARC CORE ***\n");
        printf("INFO: WBM2SPC: Valid bit is %d\n", bitsToInt(CPX_VLD,CPX_VLD));
        switch(bitsToInt(CPX_RQ_HI,CPX_RQ_LO)) {
          case IFILL_RET: printf("INFO: WBM2SPC: Return Packet of Type IFILL_RET\n"); break;
          case LOAD_RET: printf("INFO: WBM2SPC: Return Packet of Type LOAD_RET\n"); break;
          case ST_ACK: printf("INFO: WBM2SPC: Return Packet of Type ST_ACK\n"); break;
          default: printf("INFO: WBM2SPC: Return Packet of Type Unknown\n");
        }
        printf("INFO: WBM2SPC: L2 Miss is %0x\n", bitsToInt(CPX_ERR_HI,CPX_ERR_HI));
        printf("INFO: WBM2SPC: Error is %0x\n", bitsToInt(CPX_ERR_HI-1,CPX_ERR_LO));
        printf("INFO: WBM2SPC: Non-Cacheable bit is %d\n", bitsToInt(CPX_R,CPX_R));
        printf("INFO: WBM2SPC: Thread is %0x\n", bitsToInt(CPX_TH_HI,CPX_TH_LO));
        printf("INFO: WBM2SPC: Way Valid is %0x\n", bitsToInt(CPX_WYVLD,CPX_WYVLD));
        printf("INFO: WBM2SPC: Replaced L2 Way is %0x\n", bitsToInt(CPX_WY_HI,CPX_WY_LO));
        printf("INFO: WBM2SPC: Fetch for Boot is %0x\n", bitsToInt(CPX_IF4B,CPX_IF4B));
        printf("INFO: WBM2SPC: Atomic LD/ST or 2nd IFill Packet is %0x\n", bitsToInt(CPX_IF4B-1,CPX_IF4B-1));
        printf("INFO: WBM2SPC: PFL is %0x\n", bitsToInt(CPX_IF4B-2,CPX_IF4B-2));
        printf("INFO: WBM2SPC: Data is %08x%08x%08x%08x\n", bitsToInt(CPX_DA_HI,CPX_DA_HI-31), bitsToInt(CPX_DA_HI-32,CPX_DA_HI-63), bitsToInt(CPX_DA_HI-64,CPX_DA_HI-95), bitsToInt(CPX_DA_HI-96,CPX_DA_LO));
      }

    } else {
      printf("PACKET DIRECTION UNKNOWN!!!\n");
    }
  }

}

