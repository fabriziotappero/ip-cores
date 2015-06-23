
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <vpi_user.h>
#include <veriuser.h>

void	pan_register();
int	pan_compiletf();
int	pan_calltf();
int	pan_cb_destory();
int	pan_cb_change();

typedef struct pan {
	FILE		*pp;
	vpiHandle	tri;
	vpiHandle	mon;
} PAN;
	
void pan_register(){
	s_vpi_systf_data tf_data;
      	tf_data.type      = vpiSysTask;
	tf_data.tfname    = "$pan";
	tf_data.calltf    = pan_calltf;
	tf_data.compiletf = pan_compiletf;
	tf_data.sizetf    = NULL;
	tf_data.user_data = NULL;
	vpi_register_systf(&tf_data);
	vpi_printf("pan_register() is done\n");
}
int pan_compiletf(char *user_data){
	vpiHandle systf_h,tfarg_itr,tfarg_h;
	int ret;
// task check
	systf_h = vpi_handle(vpiSysTfCall, NULL);
	if (systf_h == NULL) { tf_dofinish(); return 0; }
// when none argv
	tfarg_itr = vpi_iterate(vpiArgument, systf_h);
	if (tfarg_itr == NULL) { tf_dofinish(); return 0; }
// argv 1(vpiNet)
	tfarg_h = vpi_scan(tfarg_itr);
	ret = vpi_get(vpiType,tfarg_h);
	if (vpiNet!=ret){
		vpi_printf("ERROR(%d):argv[0] is not vpiNet\n",ret);
		tf_dofinish(); return 0;
	}
// argv 2(vpiNet)
 	tfarg_h = vpi_scan(tfarg_itr);
	ret = vpi_get(vpiType,tfarg_h);
	if (vpiNet!=ret){
 		vpi_printf("ERROR(%d):argv[1] is not vpiNet\n",ret);
 		tf_dofinish(); return 0;
 	}
// argv 3(vpiConstant or vpiParameter)
 	tfarg_h = vpi_scan(tfarg_itr);
	ret=vpi_get(vpiType,tfarg_h);
	if ( (vpiConstant!=ret) && (vpiParameter!=ret) ){
 		vpi_printf("ERROR(%d):argv[2] is not (vpiConstant or vpiParameter)\n",ret);
 		tf_dofinish(); return 0;
 	}
// too many argv
	if (vpi_scan(tfarg_itr)!=NULL) {
		tf_error("ERROR: too many argv\n");
		vpi_free_object(tfarg_itr);
		tf_dofinish(); return 0;
	}
// ok compiled
	vpi_printf("pan_compiletf() is done\n");
	return 0;
}
void pan_triger(PAN *pan,vpiHandle *tri){
	s_vpi_time	time;
	s_vpi_value	value;
	s_cb_data	cb;
	value.format	= vpiIntVal;
	time.type	= vpiScaledRealTime;
	cb.reason	= cbValueChange;
	cb.cb_rtn	= pan_cb_change;
	cb.time		= &time;
	cb.value	= &value;
	cb.obj		= *tri;
	cb.user_data	= (char *)pan;
	vpi_register_cb(&cb);
	return;
}
int pan_calltf(char *user_data){
	PAN *pan;
	// pan setup
	{
		vpiHandle systf_h,arg_itr,net1_h,net2_h,string_h;
		FILE		*pp;
		if (NULL==(systf_h  = vpi_handle(vpiSysTfCall,NULL)))     {vpi_printf("analyze1\n"); return 0; }
		if (NULL==(arg_itr  = vpi_iterate(vpiArgument,systf_h)))  {vpi_printf("analyze2\n"); return 0; }
		if (NULL==(net1_h   = vpi_scan(arg_itr)))                 {vpi_printf("analyze3\n"); return 0; }
		if (NULL==(net2_h   = vpi_scan(arg_itr)))                 {vpi_printf("analyze4\n"); return 0; }
		if (NULL==(string_h = vpi_scan(arg_itr)))                 {vpi_printf("analyze5\n"); return 0; }
		{
			void		*command;
			s_vpi_value	value;
			value.format = vpiStringVal;
			vpi_get_value(string_h,&value);
			command = malloc( strlen(value.value.str)+1 );
			strcpy(command,value.value.str);
#ifdef WIN32
			{
				char *p;
				for (p=(char *)command;'\0'!=*p;p++) if ('/'==*p) *p='\\';
			}
#endif
			pp=popen((char *)command,"w");
			vpi_printf("pan_calltf().popen(command:%s)\n",command);
			free(command);
			if (NULL==pp) {
				vpi_printf("pan_calltf().popen(error)\n");
				return 0;
			}
		}
		pan = malloc(sizeof(PAN));
		pan->pp  = pp;
		pan->tri = net1_h;
		pan->mon = net2_h;
		vpi_printf("pan_calltf().malloc(pan:%d)\n",pan);
		vpi_printf("pan_calltf().popen(pan->pp:%d)\n",pan->pp);
		vpi_printf("pan_calltf().popen(pan->tri:%d)\n",pan->tri);
		vpi_printf("pan_calltf().popen(pan->mon:%d)\n",pan->mon);
	}
// delete callback
	{
		s_vpi_time	time;
		s_vpi_value	value;
		s_cb_data	cb;
		value.format	= vpiIntVal;
		time.type	= vpiScaledRealTime;
		cb.reason	= cbStartOfReset;
		//cb.reason	= cbStartOfRestart;
		//cb.reason	= cbEndOfSave;
		cb.cb_rtn	= pan_cb_destory;
		cb.time		= NULL; // must be null ;//&time;
		cb.value	= NULL; // must be null ;//&value;
		cb.obj		= NULL;
		cb.user_data	= (char *)pan;
		vpi_register_cb(&cb);		
	}
// triger callback
 	{
		int	size;
		size = vpi_get(vpiSize,pan->tri);
		vpi_printf("pan_calltf().net_size:%d(%s)\n",size,vpi_get_str(vpiFullName,pan->tri));
		if (size==1){
			pan_triger(pan,&(pan->tri));	// private call
		}
		else {
			vpiHandle port_bit_itr;
			vpiHandle port_bit_h;
			port_bit_itr = vpi_iterate(vpiBit,pan->tri);
			while (NULL!=(port_bit_h=vpi_scan(port_bit_itr))) {
				pan_triger(pan,&port_bit_h); // private call
			}
		}
	}
	vpi_printf("pan_calltf() is done\n");
	return 0;
};
int pan_cb_destory(p_cb_data cb_data){
	PAN		*pan;
	pan = (PAN *)(cb_data->user_data);
	//
	pclose(pan->pp);
	vpi_printf("pan_cb_destroy().pclose(pan->pp:%d)\n",pan->pp);
	//
	/* release call back */
	//vpi_printf("pan_cb_destroy().release(pan->tri:%d)\n",pan->tri);
	//
	free(pan);
	vpi_printf("pan_cb_destory().free(pan:%d)\n",pan);
	//
	vpi_printf("pan_cb_destory() is done\n");
	return 0;
}
int pan_cb_change(p_cb_data cb_data){
       	s_vpi_value	triger;
	triger.format = vpiIntVal;
	vpi_get_value(cb_data->obj,&triger);
	if (1==triger.value.integer) {
		FILE		*fp;
       		s_vpi_value	data;
		data.format = vpiBinStrVal;
		vpi_get_value(((PAN *)(cb_data->user_data))->mon,&data);
		//vpi_printf("pan_cb_change().(pan->mon:%d)\n",((PAN *)(cb_data->user_data))->mon);
		fp = (0==ferror(((PAN *)(cb_data->user_data))->pp)) ? ((PAN *)(cb_data->user_data))->pp: stderr;
		fprintf(fp,":%32f:%32s:%s:\n",
       			cb_data->time->real,
			vpi_get_str(vpiFullName,cb_data->obj),
			data.value.str
		);
		fflush(fp);
	}
	return 0;
}
