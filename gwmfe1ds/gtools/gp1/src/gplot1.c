#include	<signal.h>
#include        <string.h>
#include	"defs1.h"
#include	"init1.h"
#include	"pgs1.h"

FILE_TABLE_ENTRY file_name[MAXFILES];
FRAMETYPE	frame[MAXFRAMES];
int		numoframes,numofcols,numofiles;
PICTURESPEC	pspec;
PAGETYPE	page,*pg = &page;
PLOTSPEC	plspec;
FILE_TABLE_ENTRY file_name[MAXFILES];
char		pltfil_[30] = "plotXXXXXX";
double		xaxis_,yaxis_;
int		chrsiz_;
int		symsize = 35;
REALPAIR	fshift[MAXFRAMES],cshift[MAXCOMP];

int main(int argc, char **argv)
{
	FILE *np,*efopen();
	int c;

	signal(SIGINT,SIG_IGN); /* ignore interrupts */
	signal(SIGTERM,SIG_IGN); /* ignore termination signals */
	init_char_classes();
	np = efopen("/dev/null","w");
	initialize(numofiles = --argc,++argv,np);
	openplotfile(pltfil_);
	while((c = getchar()) != EOF){
		ungetc(c,stdin);
		read_specifier();
		make_plot();
	}
	closepl();
	return 0;
}


make_plot()
{
	switch(plspec.format){
	case 1:	page = vtec1page;break;
	case 2:	page = vtec2page;break;
	case 3:	page = vtec3page;break;
	case 4:	page = lw1page;break;
	case 5:	page = lw2page;break;
	}
	setpage(&page,plspec.size);
	drawscreen(&pspec,0);
	erase();
}


read_specifier()
{
	WINDOWSPEC *w= &pspec.win;
	short *fptr = pspec.fseq,*cptr = pspec.cseq;
	char c;
	int i,nattr;

	for(i=0;i<MAXFRAMES;i++) fshift[i].x = fshift[i].y = 0.0;
	for(i=0;i<MAXCOMP;i++) cshift[i].x = cshift[i].y = 0.0;
	for(i=0;i<MAXATTR;i++) pspec.attr[i].index = 0;
	while((c=getc(stdin)) != '\n'){
		ungetc(c,stdin);
		scanf("%hd",fptr++);
	}
	*fptr = (short)0;
	while((c=getc(stdin)) != '\n'){
		ungetc(c,stdin);
		scanf("%hd",cptr++);
	}
	*cptr = (short)0;
	scanf("%hd %hd %hd %hd",&pspec.flags.nodes,&pspec.flags.autox,&pspec.flags.autoy,&pspec.flags.labels);
	scanf("%f %f %f %f",&w->xl,&w->xr,&w->yb,&w->yt);
	scanf("%d",&nattr);
	for(i=0;i<nattr;i++)
		read_attr();
	scanf("%d %f\n",&plspec.format,&plspec.size);
}


setpage(pg,newsize)
PAGETYPE *pg;
float newsize;
{
	float stdsize,scalefactor;
	int xl,yb,xr,yt,landscape;

	stdsize= (pg->viewport.ur.x - pg->viewport.ll.x)/1000.0;
	scalefactor= newsize/stdsize;
	rescale(scalefactor,&pg->screen);
	rescale(scalefactor,&pg->viewport);
	rescale(scalefactor,&pg->title);
	rescale(scalefactor,&pg->params);
	rescale(scalefactor,&pg->command);
	xaxis_ = (pg->screen.ur.x - pg->screen.ll.x)/1000.0;
	yaxis_ = (pg->screen.ur.y - pg->screen.ll.y)/1000.0;
	chrsiz_ = pg->params.ch_size; /* constant for all boxes */
	xl = pg->screen.ll.x;
	xr = pg->screen.ur.x;
	yb = pg->screen.ll.y;
	yt = pg->screen.ur.y;
	landscape = (plspec.format == 5) ? 1 : 0;
	space(xl,yb,xr,yt,landscape);
}


rescale(factor,box)
float factor;
DEVICEBOX *box;
{
	box->ch_size = (int)((float)(box->ch_size)*factor);
	box->lf_size = (int)((float)(box->lf_size)*factor);
	box->ll.x = (int)((float)(box->ll.x)*factor);
	box->ll.y = (int)((float)(box->ll.y)*factor);
	box->ur.x = (int)((float)(box->ur.x)*factor);
	box->ur.y = (int)((float)(box->ur.y)*factor);
	box->home.x = (int)((float)(box->home.x)*factor);
	box->home.y = (int)((float)(box->home.y)*factor);
}


openplotfile(pf)
char *pf;
{
	char *mktemp();

	mktemp(pf);
	strcat(pf,".pf");
	openpl();
}


read_attr()
{
	char s1[5],s2[20];
	int i;

	scanf("%s %s",s1,s2);
	i = atoi(s1+1);
	if(strcmp("shift",s2) == 0)
		if(s1[0] == 'f')
			scanf("%f %f",&fshift[i].x,&fshift[i].y);
		else
			scanf("%f %f",&cshift[i].x,&cshift[i].y);
	else if(strcmp("squares",s2) == 0)
		set_attribute(pspec.attr,i,SVAL);
	else if(strcmp("triangles",s2) == 0)
		set_attribute(pspec.attr,i,TVAL);
}


writealpha()
{
	wrparams(&pspec,&page.params);
	wrtitle(&plspec,&page.title);
	write_file_list(&page.command);
}


/*
	Write out the alpha information in the "title" box.
*/
wrtitle(plspec,b)
PLOTSPEC *plspec;
DEVICEBOX *b;
{
	int lf;
	char s[50],*getdate(),*gettime(),*getenv();
	INTPAIR p;

	lf = b->lf_size;
	p = b->home;
	move(p.x,p.y);
	sprintf(s,"Date: %s",getdate());
	label(s);
	move(p.x,p.y -= lf);
	sprintf(s,"Time: %s",gettime());
	label(s);
	move(p.x,p.y -= lf);
	sprintf(s,"User: %s",getenv("USER"));
	label(s);
	move(p.x,p.y -= lf);
	sprintf(s,"Current Plot Data");
	label(s);
	move(p.x,p.y -= lf);
	sprintf(s,"format: %d size: %.2g",plspec->format,plspec->size);
	label(s);
	boxdraw(b);
}


/*
	Write out the alpha information for the "params" box.
*/
wrparams(pic,b)
PICTURESPEC *pic;
DEVICEBOX *b;
{
	char s[50],*print_nlist(),*sp[20];
	INTPAIR p;
	int lf,i;
	char xl[20],xr[20],yb[20],yt[20],fx[10],fy[10];
	WINDOWSPEC *win;

	win = &pic->win;
	lf = b->lf_size;
	p= b->home;
	move(p.x,p.y);
	sprintf(s,"frames: %-13s",print_nlist(pic->fseq));
	label(s);
	move(p.x,p.y -= lf);
	sprintf(s,"comp: %-13s",print_nlist(pic->cseq));
	label(s);
	move(p.x,p.y -= lf);
	sprintf(s,"  Clipping Values");
	label(s);
	move(p.x,p.y -= lf);
	format(fx,win->xr - win->xl,'f');
	format(fy,win->yt - win->yb,'f');
	sprintf(xl,fx,win->xl);
	sprintf(xr,fx,win->xr);
	sprintf(yb,fy,win->yb);
	sprintf(yt,fy,win->yt);
	sprintf(s,pic->flags.autox ? "x: %s to %s*" : "x: %s to %s",xl,xr);
	label(s);
	move(p.x,p.y -= lf);
	sprintf(s,pic->flags.autoy ? "y: %s to %s*" : "y: %s to %s",yb,yt);
	label(s);
	move(p.x,p.y -= lf);
	collect_attributes(pic,sp);
	for(i=0;sp[i];i++){
		label(sp[i]);
		move(p.x,p.y -= lf);
	}
	boxdraw(b);
}


write_file_list(b)
DEVICEBOX *b;
{
	char s[50];
	int lf,i;
	INTPAIR p;

	lf = b->lf_size;
	p = b->home;
	move(p.x,p.y);
	sprintf(s,"Files used:");
	label(s);
	move(p.x,p.y -= lf);
	for(i=0;i<numofiles;i++){
		label(file_name[i].name);
		move(p.x,p.y -= lf);
	}
	boxdraw(b);
}
