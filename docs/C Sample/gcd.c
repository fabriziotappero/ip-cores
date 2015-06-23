# include <stdio.h>
# include <stdlib.h>


int main(void){


int n,m,value;
int values[3];
int u=rand();
int v=rand();
int modulo;
values[0]=u;
values[1]=v;
int ComputeGcd(int n, int m);
void ComputeGcdRandom(int u, int v, int values[]);
int  Modulo(int u, int v);
int Division (int n, int m);


//printf("Can you please write the first number for the gcd computation: \n");
//scanf("%i" , &n);

//printf("Can you please write the second number for the gcd computation: \n");
//scanf("%i" , &m);


//value = ComputeGcd (n,m);
//printf("The GCD of %i and %i is: %i\n",n,m,value);

//ComputeGcdRandom (u,v,values);
//printf("The GCD of the random values %i and %i is: %i\n",values[0],values[1],values[2]);

//modulo=Modulo(u, v);
//printf("The modulo operation of %i and %i is: %i\n",u,v,modulo);


printf("Can you please write the first number for the Division Operation: \n");
scanf("%i" , &n);

printf("Can you please write the second number for the Division Operation: \n");
scanf("%i" , &m);


value = Division(n,m);
printf("The GCD of %i and %i is: %i\n",n,m,value);


return 0;

}

//Compute GCD Function 
int ComputeGcd(int n, int m){

int temp;

while(m!=0){

temp=Modulo(n,m);
n=m;
m=temp;
}

return n;
}


//Compute GCD Function for Random Numbers
void ComputeGcdRandom(int u, int v , int values []){

int temp;

while(v!=0){

temp=Modulo(u,v);
u=v;
v=temp;
}
values[2]=u;

}

//Compute Modulo Function
int  Modulo(int u, int v){

int temp;

if(u<v){
temp=u;
u=v;
v=temp;
}

while(u>0){
u=u-v;
}

if(u<0){
u=u+v;
}

return u;
}


//Compute Division Function
int Division (int n, int m){
int answer=0;
int temp;

if(n<m){
temp=n;
n=m;
m=temp;
}

temp= Modulo(n, m);

n=n-temp;


while(n>0){
n=n-m;
answer++;
}

if(n<0){
answer--;
}


return answer;
}


