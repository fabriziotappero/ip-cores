#define READ_DATA(a,n)            \
  do{                             \
    memset(a    ,0,sizeof     a); \
    fread(a,1,n,stdin);           \
  }while(0)

#define WRITE_DATA(a,n)           \
    fwrite(a,1,n,stdout)

#define DEBUG_OUTPUT(fmt,args... )     \
    fprintf(stderr,"%d:" fmt "\n",__LINE__,##args)

#define DEBUG_OUTPUT_ARR( a , n )           \
  do                                        \
  {                                         \
    int i;                                  \
    fprintf(stderr,"%d:%s:\n",__LINE__,#a); \
    for(i=n-1;i>=0;i--)                     \
    {                                       \
      fprintf(stderr,"%02x ",(a)[i]);       \
    }                                       \
    fprintf(stderr,"\n");                   \
  }while(0)

#define DEBUG_OUTPUT_VAL( a )               \
  DEBUG_OUTPUT(#a"=%02x",a )

