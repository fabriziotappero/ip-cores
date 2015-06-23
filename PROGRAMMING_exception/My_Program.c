#define memstore(address,save) { \
unsigned int *ctrlstore = (unsigned int *) address; \
*ctrlstore = save;}

#define ADDR_IO       0x00009000
#define ADDR_STOP     0x7FFFFFFC
#define ADDR_QUICK    0x00003F00


void quicksort (int a[], int lo, int hi)
{
    int i=lo, j=hi, h;
    int x=a[(lo+hi)/2];

    //  partition
    do
    {    
        while (a[i]<x) i++; 
        while (a[j]>x) j--;
        if (i<=j)
        {
            h=a[i]; a[i]=a[j]; a[j]=h;
            i++; j--;
        }
    } while (i<=j);

    //  recursion
    if (lo<j) quicksort(a, lo, j);
    if (i<hi) quicksort(a, i, hi);
}


int main(void)
{
	int a[12];
	int b;
	int c = 23;
	int d = 24;
	int i;
	
	a[0]=13;
	a[1]=34;
	a[2]=86;
	a[3]=23;
	a[4]=52;
	a[5]=43;
	a[6]=45;
	a[7]=87;
	a[8]=12;
	a[9]=24;
	a[10]=35;
	a[11]=100;
	
	b = c*d;
	
	asm("nop");
	
	//quicksort(a,0,11);
	for(i = 0; i < 12; i++)
	   a[i] = c*i;
	
	memstore( 0x00001000 , a[0]  );
	memstore( 0x00001004 , a[1]  );
	memstore( 0x00001008 , a[2]  );
	memstore( 0x0000100C , a[3]  );
	memstore( 0x00001010 , a[4]  );
	memstore( 0x00001014 , a[5]  );
	memstore( 0x00001018 , a[6]  );
	memstore( 0x0000101C , a[7]  );
	memstore( 0x00001020 , a[8]  );
	memstore( 0x00001024 , a[9]  );
	memstore( 0x00001028 , a[10] );
	memstore( 0x0000102c , a[11] );
	memstore( 0x00001030 , b     );
	
	asm("nop");
	asm("nop");
	asm("nop");
	asm("nop");
	
	memstore(ADDR_STOP,0);
	
	return 0;
	
} 
