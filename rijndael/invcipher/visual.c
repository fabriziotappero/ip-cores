#include <stdio.h>

#define st 4
#define nb 4
#define nR 10
main(int argc, char *argv[])
{
	int r,i,j,v,nr;
//	char state[st][4]= {"ad", "sb", "sr", "mx"};
	char state[st][20]= {"AddRoundKey", "SubBytes", "ShiftRows", "MixColumns"};

	nr = nR;
	if (argc > 1 ) sscanf(argv[1], "%d", &nr);

//	printf("%3s -- %3s -- %3s \n", "Seq", "Fwd", "Inv");

	r = 0; // initial round equal 0
	v = nr+1; // total there is nr+1 operation
	for ( j = 0; j < nr + 1; j ++) {
		for (i = 0; i < st; i++) { 
			if (i == 1) r++;
			if (i == 3) v--;
			if ( !((j == nr) && (i == 3))) 
				printf("%3d -- %3d(0x%x) -- %3d -- %11s -- %3d -- %3d(0x%x) -- %3d\n", j, r, r, i, state[i],   3-i, v, v, nr-j); 
			else 
				printf("%3d -- %3d(0x%x) -- %3d -- %11s -- %3d -- %3d(0x%x) -- %3d\n", j, r, r, i, state[i-3], 3-i, v, v, nr-j);
		}
	}
}
