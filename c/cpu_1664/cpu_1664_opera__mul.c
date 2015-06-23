#include "cpu_1664.h"

void cpu_1664_opera__mul(struct cpu_1664 *cpu, n1 bait)
{
 cpu->opera_sicle=cpu_1664_sicle_opera_mul;
 
 #define sz_sinia sizeof(cpu_1664_sinia_t)
 #define masca_di ((((cpu_1664_sinia_t)(-1))>>((sz_sinia*4)-1))>>1)
 #define desloca_di ((sz_sinia*4)-1)
 
 n1 rd=bait&((1<<cpu_1664_bitio_rd)-1);
 n1 rf=bait>>cpu_1664_bitio_rd;
 
 cpu_1664_sinia_t A=cpu->sinia[rd];
 cpu_1664_sinia_t B=cpu->sinia[rf];

#ifdef ojeto_64
 cpu_1664_sinia_t m0=(A&masca_di)*(B&masca_di);
 cpu_1664_sinia_t m1=(A&masca_di)*((B>>desloca_di)>>1);
 cpu_1664_sinia_t m2=((A>>desloca_di)>>1)*(B&masca_di);
 cpu_1664_sinia_t m3=((A>>desloca_di)>>1)*((B>>desloca_di)>>1);
  
 cpu_1664_sinia_t masima = m3 + ((m1>>desloca_di)>>1) + ((m2>>desloca_di)>>1);
 cpu_1664_sinia_t minima = m0 + ((m1<<desloca_di)<<1);
 masima+=(minima<m0);
 minima+=((m2<<desloca_di)<<1);
 masima+=(minima<((m2<<desloca_di)<<1));
#endif

#ifdef ojeto_32
n8 produi=A*B;
cpu_1664_sinia_t masima = ((produi>>31)>>1);
cpu_1664_sinia_t minima = produi&0xffffffff;
#endif
 
#ifdef ojeto_16
n4 produi=A*B;
cpu_1664_sinia_t masima = (produi>>16);
cpu_1664_sinia_t minima = produi&0xffff;
#endif
 
#ifdef ojeto_8
n2 produi=A*B;
cpu_1664_sinia_t masima = (produi>>8);
cpu_1664_sinia_t minima = produi&0xff;
#endif
 
 {
 //?salva
 cpu->sinia[cpu_1664_sinia_masima]=masima;
 cpu->sinia[cpu_1664_sinia_minima]=minima;
 }
 
 cpu_1664_sinia_t desloca_masima;
 cpu_1664_sinia_t desloca_minima=0;
 cpu_1664_sinia_t masca;
 
 nN i;
 for(masca=-1, i=0;((masima&masca)!=0);i++)
 {
  masca<<=1;
 }
 desloca_masima=(sizeof(cpu_1664_sinia_t)*8)-i;
 
 if(desloca_masima==(sz_sinia*8))
 {
  
  for(masca=-1, i=0; ((minima&masca)!=0); i++)
  {
   masca<<=1;
  }
  desloca_minima=(sizeof(cpu_1664_sinia_t)*8)-i;
 
 }
 
#ifdef ojeto_32
 masima<<=desloca_masima;
 minima>>=(sz_sinia*8)-desloca_masima;
 minima<<=desloca_minima;
#endif

#ifdef ojeto_64 
 //x86-64
// nN i;
 for(i=desloca_masima;i>desloca_di;i-=desloca_di)
 {
  masima<<=desloca_di;
 }
 masima<<=i;
 for(i=(sz_sinia*8)-desloca_masima;i>desloca_di;i-=desloca_di)
 {
  minima>>=desloca_di;
 }
 minima>>=i;
 for(i=desloca_minima;i>desloca_di;i-=desloca_di)
 {
  minima<<=desloca_di;
 }
 minima<<=i;
#endif

 cpu->sinia[cpu_1664_sinia_desloca]+=desloca_masima+desloca_minima-sizeof(cpu_1664_sinia_t)*8;
 cpu->sinia[rd]=masima|minima; //x86-64
 
 if (cpu->depende[cpu_1664_depende_bitio_depende_influe]!=0)
 {
  cpu->depende[cpu_1664_depende_z] = (cpu->sinia[rd]==0);
  cpu->depende[cpu_1664_depende_n] = cpu->depende[cpu_1664_depende_z]==0;
 }
}