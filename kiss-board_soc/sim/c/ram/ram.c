
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <gtk/gtk.h>

static GtkWidget	*window;
static GtkWidget	*drawarea;

static GdkPixmap	*pixmap;
static GdkPixmap	*pixmap_log;

// window callback
gint delete_event(GtkWidget *widget,GdkEventExpose *event,gpointer data);
void destroy(GtkWidget *widget,gpointer data);
// drawarea callback
gint configure_event(GtkWidget *widget,GdkEventExpose *event);
gint expose_event(GtkWidget *widget,GdkEventExpose *event);
// stdin callback
gint input_event(gpointer data);

int main(int argc,char *argv[]){
	char		title[256];
	
	// init
	gtk_set_locale();
	gtk_init(&argc,&argv);
	pixmap     = NULL;
	pixmap_log = NULL;

	// window
	window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
	gtk_window_set_policy(GTK_WINDOW(window),FALSE,FALSE,TRUE);	
	if (argc>=2) strcpy(title,*(argv+1));
	else strcpy(title,"Display");
	gtk_window_set_title(GTK_WINDOW(window),title);
	gtk_signal_connect(GTK_OBJECT(window),"delete_event",GTK_SIGNAL_FUNC(delete_event),NULL);
	gtk_signal_connect(GTK_OBJECT(window),"destroy",GTK_SIGNAL_FUNC(destroy),NULL);

	// drawarea
	drawarea = gtk_drawing_area_new();
	gtk_drawing_area_size(GTK_DRAWING_AREA(drawarea),640,480+32);
	gtk_container_add(GTK_CONTAINER(window),drawarea);
	gtk_signal_connect(GTK_OBJECT(drawarea),"configure_event",GTK_SIGNAL_FUNC(configure_event),NULL);
	gtk_signal_connect(GTK_OBJECT(drawarea),"expose_event",GTK_SIGNAL_FUNC(expose_event),NULL);
	
	// show
	gtk_widget_show(drawarea);
	gtk_widget_show(window);

	// callback stdin
	gdk_input_add(
		0,					// 0:stdin
		GDK_INPUT_READ,				// condittion
		(GdkInputFunction)input_event,		// callback
		NULL					// not use
	);
	gtk_main();
	fprintf(stderr,"exit(gtk_main)\n");
	return 0;
}

// window
gint delete_event(GtkWidget *widget,GdkEventExpose *event,gpointer data){
	//fprintf(stderr,"delete_event(window)\n");
	return TRUE; // TRUE is KEEP-WINDOW
}
void destroy(GtkWidget *widget,gpointer data){
	fprintf(stderr,"destory(window)\n");
	gtk_main_quit();
}

// drawarea
gint configure_event(GtkWidget *widget,GdkEventExpose *event){
	//if (pixmap) gdk_pixmap_unref(pixmap);
	//pixmap = gdk_pixmap_new(drawarea->window,widget->allocation.width,widget->allocation.height,-1);
	//height = widget->allocation.height;
	//width  = widget->allocation.width;
	if (NULL==pixmap) {
		pixmap = gdk_pixmap_new(drawarea->window,640,480,-1);
		gdk_draw_rectangle(pixmap,
			GTK_WIDGET(drawarea)->style->black_gc,
			TRUE,
			0, 0,
			640,
			480
			);
	}
	if (NULL==pixmap_log) {
		pixmap_log = gdk_pixmap_new(drawarea->window,640,32,-1);
		gdk_draw_rectangle(pixmap_log,
			GTK_WIDGET(drawarea)->style->white_gc,
       			TRUE,
			0, 0,
			640,
			32
		);
	}
	//fprintf(stderr,"configure_event(drawarea:%d,%d)\n",widget->allocation.width,widget->allocation.height);
	return TRUE;
}
gint expose_event(GtkWidget *widget,GdkEventExpose *event){
	gdk_draw_pixmap(
		widget->window,
		widget->style->fg_gc[GTK_WIDGET_STATE(widget)],
		pixmap_log,
		0,0,	// src
		0,0,	// dist
		640,32	// size
	);
	gdk_draw_pixmap(
		widget->window,
		widget->style->fg_gc[GTK_WIDGET_STATE(widget)],
		pixmap,
		//event->area.x,event->area.y,
		//event->area.x,event->area.y,
		//event->area.width,
		//event->area.height
		0,0,
		0,32,
		640,480
	);
	//fprintf(stderr,"expose_event(drawarea:%d,%d)\n",event->area.width,event->area.height);
	return FALSE;
}
static GdkGC *gc;
static int xx;
static int yy;
static unsigned int pix[4];
void draw(void){
	GdkColor	color;
	{
		color.blue	= (pix[0] <<11) & 0xf800;
		color.green	= (pix[0] <<5 ) & 0xf800;
		color.red	= (pix[0]     ) & 0xf800;
		gdk_color_alloc(gdk_colormap_get_system(),&color);
		gdk_gc_set_foreground(gc,&color);
		//gdk_color_free(&color);
		gdk_draw_point(pixmap,gc,xx,yy);
	}
/*
	{
		color.blue	= pix[1] << 6; //6;
		color.green	= pix[1] << 6; //6;
		color.red	= pix[1] << 6; //6;
		gdk_color_alloc(gdk_colormap_get_system(),&color);
		gdk_gc_set_foreground(gc,&color);
		//gdk_color_free(&color);
		gdk_draw_point(pixmap,gc,(xx*4)+1,yy);
	}
	{
		color.blue	= pix[2] << 6; //6;
		color.green	= pix[2] << 6; //6;
		color.red	= pix[2] << 6; //6;
		gdk_color_alloc(gdk_colormap_get_system(),&color);
		gdk_gc_set_foreground(gc,&color);
		//gdk_color_free(&color);
		gdk_draw_point(pixmap,gc,(xx*4)+2,yy);
	}
	{
		color.blue	= pix[3] << 6; //6;
		color.green	= pix[3] << 6; //6;
		color.red	= pix[3] << 6; //6;
		gdk_color_alloc(gdk_colormap_get_system(),&color);
		gdk_gc_set_foreground(gc,&color);
		//gdk_color_free(&color);
		gdk_draw_point(pixmap,gc,(xx*4)+3,yy);
	}
*/
	return;
}
// stdin
gint input_event(gpointer data){
	char text[2048];
	char *p;
	int num;
	int err;
	unsigned long int add;
	
	if (NULL==fgets((char*)text,(int)2047,stdin)) {
		if (0!=feof(stdin))   fprintf(stderr,"pipe close(eof)\n");
		if (0!=ferror(stdin)) fprintf(stderr,"pipe close(error)\n");
		gtk_widget_destroy(window);
		return TRUE;
	}

	gdk_draw_rectangle(pixmap_log,
		GTK_WIDGET(drawarea)->style->white_gc,
		TRUE,
		0, 0,
		640,
		32
	);
	gdk_draw_string(
		pixmap_log,
		GTK_WIDGET(drawarea)->style->font,
		GTK_WIDGET(drawarea)->style->black_gc,
		0,
		16,
                text
	);

	if (NULL!=(p=strtok(text,":"))) {             } else { fprintf(stderr,"format error argv0\n"); return FALSE; }
	if (NULL!=(p=strtok(NULL,":"))) {             } else { fprintf(stderr,"format error argv1\n"); return FALSE; }
	if (NULL!=(p=strtok(NULL,":"))) {             } else { fprintf(stderr,"format error argv2\n"); return FALSE; }
	if (NULL!=(p=strtok(NULL,":"))) {             } else { fprintf(stderr,"format error argv3\n"); return FALSE; }

	// set pointer to separator(:) from CRorLF
	p--;
	p--;

	// gc
	gc = gdk_gc_new(drawarea->window);
	
	// pix[0]
	for (pix[0]=0,err=0,num=0;num<16;num++,p--) {
		if (':'==*p)                 { fprintf(stderr,"format error pix0\n"); err = 1; }
		else if ('0'!=*p && '1'!=*p) { /*fprintf(stderr,"unknow value pix0\n");*/ err = 1; }
		else if (0==err)             { pix[0] = pix[0] + ( (*p=='1') ? (1<<num): 0 );  }
	}
/*
 * 	// pix[1]
	for (pix[1]=0,err=0,num=0;num<12;num++,p--) {
		if (':'==*p)                 { fprintf(stderr,"format error pix1\n"); err = 1; }
		else if ('0'!=*p && '1'!=*p) { fprintf(stderr,"unknow value pix1\n"); err = 1; }
		else if (0==err)             { pix[1] = pix[1] + ( (*p=='1') ? (1<<num): 0 );  }
	}
	// pix[2]
	for (pix[2]=0,err=0,num=0;num<12;num++,p--) {
		if (':'==*p)                 { fprintf(stderr,"format error pix2\n"); err = 1; }
		else if ('0'!=*p && '1'!=*p) { fprintf(stderr,"unknow value pix2\n"); err = 1; }
		else if (0==err)             { pix[2] = pix[2] + ( (*p=='1') ? (1<<num): 0 );  }
	}
	// pix[3]
	for (pix[3]=0,err=0,num=0;num<12;num++,p--) {
		if (':'==*p)                 { fprintf(stderr,"format error pix3\n"); err = 1; }
		else if ('0'!=*p && '1'!=*p) { fprintf(stderr,"unknow value pix3\n"); err = 1; }
		else if (0==err)             { pix[3] = pix[3] + ( (*p=='1') ? (1<<num): 0 );  }
	}
*/
	// add
	for (add=0,err=0,num=0;num<32;num++,p--) {
		if (':'==*p)                 { fprintf(stderr,"format error add\n"); err = 1; }
		else if ('0'!=*p && '1'!=*p) { /*fprintf(stderr,"unknow value add\n");*/ err = 1; }
		else if (0==err)             { add = add + ( (*p=='1') ? (1<<num): 0 );       }
	}
	//fprintf(stderr,"debug: %08x %03x %03x %03x %03x\n",add,pix[3],pix[2],pix[1],pix[0]);
	//fprintf(stderr,"debug: %08x %04x\n",add,pix[0]);

	xx = (add % 1024);
	yy = (add - xx) / 1024;
	//fprintf(stderr,"debug: %d %d\n",xx,yy);

	draw();

	gdk_gc_destroy(gc);

	gtk_widget_draw(GTK_WIDGET(drawarea),NULL);

	//fprintf(stderr,"input_event(stdin)\n");
	return FALSE;
}
