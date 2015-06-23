#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

int main(int argc, char *argv[]) {

	FILE *output;
	int k;
	int bits = 14;
	int N;
	int temp1, temp2;
	double pi = 3.1415926535897932384626433832795;
	char buf_string[32];

	// open output file
	output = fopen("sincos_lut.asm", "w+");
	if(output == NULL){
  		printf("Output file error!");
		exit(1);
	}

	// get number of sample
	printf("Enter number of FFT points (power of 2): ");
	scanf("%d", &N);

	for(k=0; k<N/2; k++){
		temp1 = int(cos((2*pi*k)/N)*(1<<bits));
		temp2 = int(sin((2*pi*k)/N)*(1<<bits));
		temp1 = temp1 & ((1<<16)-1); // truncate to 16 bit
		temp2 = temp2 & ((1<<16)-1); // truncate to 16 bit
	//	printf(".dw #%d -- %04X\n", temp1, temp1);
	//	printf(".dw #%d -- %04X\n", temp2, temp2);
		sprintf(buf_string, ".dw #%d\n.dw #%d\n", temp1, temp2);
		fputs(buf_string, output);
	}

  	fclose(output);
	return 0;
}
