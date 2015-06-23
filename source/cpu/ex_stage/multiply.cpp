//multiply.cpp
#include "multiply.h"

void multiply::do_multiply()
{
  sc_lv<32> 	rs = id_ex_alu1.read();
  sc_lv<32> 	rt = id_ex_alu2.read();  
  sc_lv<6> 	func = id_ex_alu_function.read();
  sc_lv<6> 	opcode = id_ex_alu_opcode.read();
  
  if((func == FUNC_MULT) && (opcode == OP_RFORMAT))
  {
  
    sc_int<32> irs,irt;
    irs = rs;
    irt = rt;
    stage0.write(irs*irt);
  
  }
  else 
     if((func == FUNC_MULTU) && (opcode == OP_RFORMAT))
     { 
       sc_uint<32> irs,irt;
       irs = rs;
       irt = rt;
       stage0.write(irs*irt);
     }
     else
     {
        stage0.write(DOUBLE_ZERO);
     }    
}


#ifdef _MULT_PIPELINE_
void multiply::do_pipe()
{
   #if(DEPTH_MULT_PIPE == 1)
        if (reset.read()== true)
	   stage1.write(DOUBLE_ZERO);
	else
	   stage1.write(stage0);
   #else
      #if(DEPTH_MULT_PIPE == 2)
	if (reset.read()== true)
	{
	   stage1.write(DOUBLE_ZERO);
	   stage2.write(DOUBLE_ZERO);
	}
	else
	{
	   stage1.write(stage0);
	   stage2.write(stage1);
	}
      #else
         #if(DEPTH_MULT_PIPE == 3)
	    if (reset.read()== true)
	    {
	        stage1.write(DOUBLE_ZERO);
	        stage2.write(DOUBLE_ZERO);
		stage3.write(DOUBLE_ZERO);
	    }
	    else
	    {
	       stage1.write(stage0);
	       stage2.write(stage1);
	       stage3.write(stage2);
	    }
            #else
	        #if(DEPTH_MULT_PIPE == 4)
	           if (reset.read()== true)
	           {
	        	stage1.write(DOUBLE_ZERO);
	        	stage2.write(DOUBLE_ZERO);
			stage3.write(DOUBLE_ZERO);
			stage4.write(DOUBLE_ZERO);
	    	   }
	    	   else
	    	   {
	       		stage1.write(stage0);
	       		stage2.write(stage1);
	       		stage3.write(stage2);
			stage4.write(stage3);
	    	   }
            	#endif
	    #endif
	 #endif
      #endif
}
#endif
void multiply::split()
{
	sc_lv<64> temp;
     #ifndef _MULT_PIPELINE_
	temp = stage0;
     #else
        #if(DEPTH_MULT_PIPE == 1)
	  temp = stage1;
	#else
	  #if(DEPTH_MULT_PIPE == 2)
	     temp = stage2;
	  #else
	     #if(DEPTH_MULT_PIPE == 3)
	       temp = stage3;
	     #else
	       #if(DEPTH_MULT_PIPE == 4)
	          temp = stage4;
	       #endif
	     #endif
	  #endif
	#endif     
     #endif
	
	hi.write(temp.range(63,32));
	lo.write(temp.range(31,0));
}
