/*globals*/
unsigned long int seed;

void srand(unsigned long int s){
    seed = s;
}

unsigned long rand(){
    const unsigned long a = 1103515245ul;
    const unsigned long c = 12345ul;
    seed = (a*seed+c);
    return seed;
}

void main(){
    unsigned i;
    for (i=0; i<4096; i++){
        file_write(rand(), "x");
        file_write(rand(), "y");
        file_write(rand(), "z");
    }
}
