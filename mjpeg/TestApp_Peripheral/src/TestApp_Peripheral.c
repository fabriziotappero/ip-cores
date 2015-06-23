#include "xparameters.h"
#include "stdio.h"
#include "xio.h"


int main (void) {
	int i,go=0;
	
   //Xuint32 * lena = (Xuint32*)XPAR_DDR_512MB_64MX64_RANK2_ROW13_COL10_CL2_5_MEM0_BASEADDR;
	//		fflush(stdout);
	
	
	printf("Feedback - start\r\n");
	
	XIo_Out32(0x50000004, 0x00000002);
	
	while (go!=100){
		printf("Stop PPC: .... 100\n");
		printf("Go: ............ 1\n");
		printf("No Go: ......... 2\n");
		printf("Burst: ......... 3\n");
		printf("No Burst: ...... 4\n");
		printf("Reset: ......... 5\n");
		printf("Switch 0 On: ... 6\n");
		printf("Switch 0 Off: .. 7\n");
		printf("Switch 1 On: ... 8\n");
		printf("Switch 1 Off: .. 9\n");
		printf("Switch 2 On: .. 10\n");
		printf("Switch 2 Off: . 11\n");
		printf("Switch 3 On: .. 12\n");
		printf("Switch 3 Off: . 13\n");
		printf("Pause On: ..... 14\n");
		printf("Pause Off: .... 15\n");
		printf("Next Frame: ... 16\n");
		printf("Faster: ....... 17\n");
		printf("Slower: ....... 18\n");
		
		scanf("%d",&go);
		
		if(go==1)  XIo_Out32(0x50000004, 0x00000001);
		if(go==2)  XIo_Out32(0x50000004, 0x00000002);
		if(go==3)  XIo_Out32(0x50000004, 0x00000003);
		if(go==4)  XIo_Out32(0x50000004, 0x00000004);
		if(go==5)  XIo_Out32(0x50000004, 0x00000005);
		if(go==6)  XIo_Out32(0x50000004, 0x00000006);
		if(go==7)  XIo_Out32(0x50000004, 0x00000007);
		if(go==8)  XIo_Out32(0x50000004, 0x00000008);
		if(go==9)  XIo_Out32(0x50000004, 0x00000009);
		if(go==10) XIo_Out32(0x50000004, 0x0000000A);
		if(go==11) XIo_Out32(0x50000004, 0x0000000B);
		if(go==12) XIo_Out32(0x50000004, 0x0000000C);
		if(go==13) XIo_Out32(0x50000004, 0x0000000D);
		if(go==14) XIo_Out32(0x50000004, 0x0000000E);
		if(go==15) XIo_Out32(0x50000004, 0x0000000F);
		if(go==16) XIo_Out32(0x50000004, 0x00000010);
		if(go==17) XIo_Out32(0x50000004, 0x00000011);
		if(go==18) XIo_Out32(0x50000004, 0x00000012);
		printf("Feedback - go: %X\r\n",go);
	}
		
	//printf("Feedback - running\r\n");
	
	//while (1) {
	
		// Free the OPB-Bus
		//XIo_Out32(0x50000004, 0x00000002);
		//sleep(1);
		
		// give Feedback
		//i=XIo_In32(0x50000008);
		//printf("Feedback -  i: %X bzw. %d\r\n",i,i);
		
		// Take back Bus
		//XIo_Out32(0x50000004, 0x00000001);
		//sleep(1); 
		
		// stop (go -> '0')
		//if(i==2) {
		//	XIo_Out32(0x50000004, 0x00000002);
		//}
		
   //}
	
	return 0;
}
