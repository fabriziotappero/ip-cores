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
	int a[7],b,c;
	
	a[0]=13;
	a[1]=34;
	a[2]=86;
	a[3]=23;
	a[4]=52;
	a[5]=45;
	a[6]=1;
	
	asm("nop");
	
	b = a[1] * a[5];
	c = a[4] * a[6];
	
	quicksort(a,0,11);
	
	asm("nop");
	
	memstore( 0x00001000 , a[0]  );
	memstore( 0x00001004 , a[1]  );
	memstore( 0x00001008 , a[2]  );
	memstore( 0x0000100c , a[3]  );
	memstore( 0x00001010 , a[4]  );
	memstore( 0x00001014 , a[5]  );
	memstore( 0x00001018 , a[6]  );
	memstore( 0x0000101c , b     );
	memstore( 0x00001020 , c     );
	
	asm("nop");
	
	memstore(ADDR_STOP,0);
	
	return 0;
	
} 
