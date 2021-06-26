/*
	The routines in this file are designed for use in the interactive
	graphics program.
*/
#include	"defs1.h"

writealpha()
{
	extern PLOTSPEC plspec;
	extern PAGETYPE *pg;
	extern PICTURESPEC *pic;
	extern FILE_TABLE_ENTRY file_name[];
	extern int numofiles;
	char *print_nlist(),*sp[20],xl[20],xr[20],yb[20],yt[20],fx[10],fy[10];
	int i;
	WINDOWSPEC *win;

	win = &pic->win;
	move(pg->screen.home.x,pg->screen.home.y);
	closepl();
	printf("  Files Used\n");
	for(i=0;i<numofiles;i++)
		printf("%s\n",file_name[i].name);
	printf("  Current Plot Data\n");
	printf("format: %d size: %.2g\n",plspec.format,plspec.size);
	printf("frms:%s\n",print_nlist(pic->fseq));
	printf("comp:%s\n",print_nlist(pic->cseq));
	printf("  Clipping Values\n");
	format(fx,win->xr - win->xl,'f');
	format(fy,win->yt - win->yb,'f');
	sprintf(xl,fx,win->xl);
	sprintf(xr,fx,win->xr);
	sprintf(yb,fy,win->yb);
	sprintf(yt,fy,win->yt);
	printf(pic->flags.autox ? "x: %s to %s*\n" : "x: %s to %s\n",xl,xr);
	printf(pic->flags.autoy ? "y: %s to %s*\n" : "y: %s to %s\n",yb,yt);
	printf("  Attributes\n");
	printf("labels: %s\n",(pic->flags.labels) ? "on" : "off");
	printf("nodes: %s\n",(pic->flags.nodes) ? "on" : "off");
	collect_attributes(pic,sp);
	for(i=0;sp[i];i++)
		printf("%s\n",sp[i]);
}
