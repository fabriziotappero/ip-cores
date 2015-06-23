// test INPUT/OUTPUT instrukci
volatile char gl = 5;

// definice portu
extern char PBLAZEPORT[];

void fun(char *a)
{
    char i;
    for(i = 0; i < *a; i++) {
        PBLAZEPORT[i] = gl;
    }
}

void main()
{
    char a = PBLAZEPORT[5];
	fun(&a);

}
