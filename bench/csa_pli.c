/*
 * =====================================================================================
 *
 *       Filename:  read_ikey.c
 *
 *    Description:  this is a pli module to read the input key 
 *
 *        Version:  1.0
 *        Created:  07/10/2008 09:18:10 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  mengxipeng@gmail.com
 *        Company:  mengxipeng
 *
 * =====================================================================================
 */

#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <vpi_user.h>


char  data[120*8*8];


static int read_data_compile(char* used_data)
{
        vpiHandle systf_h;
        vpiHandle trarg_itr; // argument iterator
        vpiHandle trarg_h;   // argument handle;
        PLI_INT32 trarg_type; // argument type
        PLI_INT32 reg_size; // argument type

        systf_h=vpi_handle(vpiSysTfCall,NULL);
        if(!systf_h)
        {
                vpi_printf("ERROR: could not obtain the handle to systf call\n");
                //tf_dofinish();
                return 0;
        }

        trarg_itr=vpi_iterate(vpiArgument, systf_h);
        if(!trarg_itr)
        {
                vpi_printf("ERROR: could not obtain the iterate to argument\n");
                //tf_dofinish();
                return 0;
        }

        // get the first argument
        trarg_h=vpi_scan(trarg_itr);
        if(vpi_get(vpiType,trarg_h)!=vpiConstant)
        {
                if(vpi_get(vpiConstType,trarg_h)!=vpiStringConst)
                {
                        vpi_printf("the first argument type is incorrect (not a string constant)\n");
                        //tf_dofinish();
                        return 0;
                }
        }

        // get the next argumnent
        trarg_h=vpi_scan(trarg_itr);
        trarg_type=vpi_get(vpiType,trarg_h);
        if(trarg_type==vpiConstant || trarg_type == vpiIntegerVar)
        // offset ?
        {
                if(trarg_type==vpiConstant
                        && vpi_get(vpiConstType,trarg_h)!=vpiDecConst
                        && vpi_get(vpiConstType,trarg_h)!=vpiBinaryConst      // iverilog have this bug
                        )
                {
                        vpi_printf("[%d]the offset must be dec constant [%d] \n",__LINE__,vpi_get(vpiConstType,trarg_h));
                        //tf_dofinish();
                        return 0;
                }
                trarg_h=vpi_scan(trarg_itr);
                trarg_type=vpi_get(vpiType,trarg_h);
        }

        if(trarg_type!=vpiReg)
        {
                vpi_printf("[%d]error:the current argument's type must be reg [%d]\n",__LINE__,trarg_type);
                //tf_dofinish();
                return 0;
        }

        reg_size=vpi_get(vpiSize,trarg_h);

        trarg_h=vpi_scan(trarg_itr);
        if(trarg_h)
        // size argument
        {
                s_vpi_value  value_s;
                trarg_type=vpi_get(vpiType,trarg_h);
                if(trarg_type!=vpiConstant || vpi_get(vpiConstType,trarg_h)!=vpiBinaryConst)
                {
                        vpi_printf("error:size type must be a binary constant");
                        //tf_dofinish();
                        return 0;
                }
                value_s.format=vpiIntVal;
                vpi_get_value(trarg_h,&value_s);
                if(value_s.value.integer*8>reg_size)
                {
                        vpi_printf("warning:size is beyond the length of the register");
                }
        }

        return 0;
}

static int read_data(char *fn)
{
        vpiHandle    systf_handle;
        vpiHandle    arg_itr;
        vpiHandle    arg_handle;
        vpiHandle    arg_handle_reg;
        PLI_INT32    arg_type;
        PLI_INT32    arg_size;
        PLI_INT32    read_size;
        s_vpi_value  value_s;

        FILE        *fp;

        systf_handle = vpi_handle(vpiSysTfCall, NULL);
        arg_itr = vpi_iterate(vpiArgument, systf_handle);
        if (arg_itr == NULL) 
        {
                vpi_printf("ERROR: failed to obtain systf arg handles\n");
                //tf_dofinish();
                return(0);
        }

        /* read file name */
        arg_handle = vpi_scan(arg_itr);
        value_s.format = vpiStringVal;
        vpi_get_value(arg_handle, &value_s);
        fp=fopen(value_s.value.str,"rb");
        if(!fp)
        {
                vpi_printf("ERROR: failed to open the file [%s]\n",value_s.value.str);
                //tf_dofinish();
                return 0;
        }

        arg_handle = vpi_scan(arg_itr);
        arg_type=vpi_get(vpiType,arg_handle);
        arg_handle_reg=arg_handle;
        if(arg_type==vpiConstant || arg_type == vpiIntegerVar)
        // offset ?
        {
                value_s.format = vpiIntVal;
                vpi_get_value(arg_handle, &value_s);
                if(0<fseek(fp,value_s.value.integer,SEEK_SET))
                {
                        vpi_printf("warning: failed to seek the offset\n");
                }

                arg_handle_reg = vpi_scan(arg_itr);
        }


        // calute the size
        read_size=vpi_get(vpiSize,arg_handle_reg);
        arg_handle = vpi_scan(arg_itr);
        if(arg_handle)
        {

                vpi_printf("[%d] go here\n",__LINE__);
                value_s.format = vpiIntVal;
                vpi_get_value(arg_handle, &value_s);
                if(value_s.value.integer<read_size*8)
                        read_size=value_s.value.integer*8;
        }

        // read the value to vector
        {
                unsigned int dword;
                int i;
                int read;
                value_s.format = vpiVectorVal;
                vpi_get_value(arg_handle_reg, &value_s);
                for(i=0;i+32<=read_size;i+=32)
                {
                        read=fread(&dword,4,1,fp);
                        if(1!=read)
                        {
                                vpi_printf("warning read fail [%d] \n",read);
                                break;
                        }
                        value_s.value.vector[i/32].bval=0x00;
                        value_s.value.vector[i/32].aval=dword;
                }
                if(i<read_size)
                {
                        PLI_INT32 reduant=read_size-i;
                        PLI_INT32 reduant_mask;
                        int n;
                        reduant_mask=0;
                        for(n=0;n<reduant;n++)
                        {
                                reduant_mask |= (1<<n);
                        }
                        read=fread(&dword,reduant/8,1,fp);
                        if(1!=read)
                        {
                                vpi_printf("warning fail \n");
                        }
                        value_s.value.vector[i/32].bval&=~reduant_mask;
                        value_s.value.vector[i/32].aval&=~reduant_mask;
                        value_s.value.vector[i/32].aval|=reduant_mask&dword;
                }
                vpi_put_value(arg_handle_reg, &value_s,NULL, vpiNoDelay);
        }
        fclose(fp);
        return 0;
}


// thia vpi funciton read_data is used to read a binary to a verilog register;
//    usage: read_data ( file name,   [ offset ] ,  register name ,[size ]);
//              note offset and size argument's unit is byte

static void read_data_register()
{
        s_vpi_systf_data tf_data;
        tf_data.type      = vpiSysTask;
        tf_data.tfname    = "$read_data";
        tf_data.calltf    = read_data;
        tf_data.compiletf = read_data_compile;
        tf_data.sizetf    = 0;
        vpi_register_systf(&tf_data);
}

// write system call
// usage $write_data( file name , [ flags ,] reg)

static int write_data_compile(char* used_data)
{
        vpiHandle systf_h;
        vpiHandle trarg_itr; // argument iterator
        vpiHandle trarg_h;   // argument handle;
        PLI_INT32 trarg_type; // argument type
        s_vpi_value  value_s;
        

        systf_h=vpi_handle(vpiSysTfCall,NULL);
        if(!systf_h)
        {
                vpi_printf("ERROR: could not obtain the handle to systf call\n");
                //tf_dofinish();
                return 0;
        }

        trarg_itr=vpi_iterate(vpiArgument, systf_h);
        if(!trarg_itr)
        {
                vpi_printf("ERROR: could not obtain the iterate to argument\n");
                //tf_dofinish();
                return 0;
        }


        // get the first argument
        trarg_h=vpi_scan(trarg_itr);
        if(vpi_get(vpiType,trarg_h)!=vpiConstant&&vpi_get(vpiConstType,trarg_h)!=vpiStringConst)
        {
                vpi_printf("the first argument type is incorrect (not a string constant)\n");
                //tf_dofinish();
                return 0;
        }

        // get flag
        trarg_h=vpi_scan(trarg_itr);
        trarg_type=vpi_get(vpiType,trarg_h);
        if(trarg_type==vpiConstant&&vpi_get(vpiConstType,trarg_h)==vpiStringConst)
        // flag
        {
                value_s.format=vpiStringVal;
                vpi_get_value(trarg_h,&value_s);

                if(
                           strcasecmp(value_s.value.str,"A")
                           )
                {
                        vpi_printf("error, not only support addpend A flag[%s]\n",value_s.value.str);
                        //tf_dofinish();
                        return 0;
                }

                trarg_h=vpi_scan(trarg_itr);
                trarg_type=vpi_get(vpiType,trarg_h);
        }

        if(
                trarg_type!=vpiConstant
                &&trarg_type!=vpiReg
                &&trarg_type!=vpiPartSelect
                //&&trarg_type!=vpiRegBit
                &&trarg_type!=vpiNet
                )
        {
                vpi_printf("[%d]error, the last argument is not a valid val [%d]\n",__LINE__,trarg_type);
                //tf_dofinish();
                return 0; 
        }
        if(trarg_type==vpiConstant)
        {
                if(0!=vpi_get(vpiConstType,trarg_h))
                {
                        vpi_printf("error, the last argument is not a sub 0 type constant val \n");
                        //tf_dofinish();
                        return 0; 
                }
        }

        return 0;
}

static int write_data(char *xx)
{
        vpiHandle    systf_handle;
        vpiHandle    arg_itr;
        vpiHandle    arg_handle_fn;
        vpiHandle    arg_handle;
        s_vpi_value  value_s;

        FILE        *fp;

        systf_handle = vpi_handle(vpiSysTfCall, NULL);
        if(systf_handle== NULL)
        {
                vpi_printf("ERROR: failed to obtain systf call handles\n");
                //tf_dofinish();
                return(0);
        }
        arg_itr = vpi_iterate(vpiArgument, systf_handle);
        if (arg_itr == NULL) 
        {
                vpi_printf("ERROR: failed to obtain systf arg handles\n");
                //tf_dofinish();
                return(0);
        }

        /* read file name */
        arg_handle = vpi_scan(arg_itr);
        value_s.format = vpiStringVal;
        vpi_get_value(arg_handle, &value_s);

        arg_handle = vpi_scan(arg_itr);
        if(vpi_get(vpiType,arg_handle)==vpiConstant&&vpi_get(vpiConstType,arg_handle)==vpiStringConst)
        // flags
        {
                fp=fopen(value_s.value.str,"ab");// if have flag, then open the file with append mode
                arg_handle = vpi_scan(arg_itr);
        }
        else
        {
                fp=fopen(value_s.value.str,"wb");
        }
        if(!fp)
        {
                vpi_printf("can not open file to write\n");
                //tf_dofinish();
                return 0;
        }

        // write data
        {
                unsigned int word;
                int b;
                int i;
                int vector_size;
                value_s.format = vpiVectorVal;
                vector_size = vpi_get(vpiSize, arg_handle);
                vpi_get_value(arg_handle, &value_s);
                for(i=0;i+32<=vector_size;i+=32)
                {
                        if(1!=fwrite(&value_s.value.vector[i/32].aval,4,1,fp))
                        {
                                vpi_printf("[%d]warning:write fail \n",__LINE__);
                        }
                }
                if(i<vector_size)
                {
                        int n;
                        unsigned char b;
                        unsigned int  last=value_s.value.vector[i/32].aval;
                        unsigned int  mask=0xff;
                        PLI_INT32 reduant=vector_size-i;
                        for(n=0;n<reduant;n+=8)
                        {
                                b=(last&(mask<<n))>>n;
                                if(1!=fwrite(&b,1,1,fp))
                                {
                                        vpi_printf("[%d]warning:write fail \n",__LINE__);
                                }
                        }
                }
                //fwrite(&value_s.value.vector[i].aval,(vector_size%32)/8,1,fp);
                fclose(fp);
        }
        
        return 0;
}

static void write_data_register()
{
        s_vpi_systf_data tf_data;
        tf_data.type      = vpiSysTask;
        tf_data.tfname    = "$write_data";
        tf_data.calltf    = write_data;
        tf_data.compiletf = write_data_compile;
        tf_data.sizetf    = 0;
        vpi_register_systf(&tf_data);
}

void (*vlog_startup_routines[])() = {
        read_data_register,
        write_data_register,
        0
};

