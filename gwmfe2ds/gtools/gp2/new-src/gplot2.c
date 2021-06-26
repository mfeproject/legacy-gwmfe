/*
	This file contains routines for 2-D versatec plotting.
*/
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<math.h>
#include	<ctype.h>
#include	<signal.h>
#include	"defs2.h"
#include	"pgs2.h"

extern long indexadd,rangeadd;
char	pltfil_[30] = "plotXXXXXX";
double	xaxis_,yaxis_;
int	chrsiz_;
int	symsize = 35;
PICTURESPEC pspec;
PAGETYPE page,*pg = &page;
PLOTSPEC plspec;
FILEALFA falfa;  /* data from mfe fixed header is in this structure */
char	today[12], mfefname[BOXLLENGTH],fseq[80],plottime[10];
int 	numofedges,numofcells,numofnodes,numoframes,numofzvals;
REALBOX domain;
REALPAIR *node0;
EDGETYPE *edge0;
CELLTYPE *cell0;
FRAMETYPE frm;
int currframe,qxs;
float	**zpp;

main(argc,argv)
int argc;
char *argv[];
{
	FILE *mfp,*efopen();
	int c;

	signal(SIGINT,SIG_IGN); /* ignore interrupts */
	signal(SIGTERM,SIG_IGN); /* ignore termination signals */
	mfp = efopen(*++argv,"r"); /* open the mfe data file */
	strcpy(mfefname,*argv);
	openplotfile(pltfil_);
	readgdata(mfp);
	while((c = getchar()) != EOF){
		ungetc(c,stdin);
		read_specifier(stdin);
		make_plot(mfp);
	}
	closepl();
	fclose(mfp);
	exit(0);
}


/*
	Read the next picture specifier and related information.
*/
read_specifier(fp)
FILE *fp;
{
	WINDOWSPEC *w= pspec.wspec+1; /* window 1 is currwin */
	unsigned flagword;
	char c,*fsp = fseq;

	fscanf(fp,"%*s %s",today);
	fscanf(fp,"%*s %s",plottime);
	fscanf(fp,"%*s"); /* skip the word 'frames' */
	while(!isdigit(c=getc(fp))) { /* skip blanks */ }
	*fsp++ = c;
	while((*fsp++ = getc(fp)) != '\n'){ /* get string of ascii framenumbers */}
	*--fsp = '\0'; /* replace newline with null */
	fscanf(fp,"%*s %o",&flagword);
	flagdecode(flagword,&pspec.flags);
	if(pspec.flags.xsect || pspec.flags.openxs){
		fscanf(fp,"%*s %hd",&pspec.zindex);
		fscanf(fp,"%hd",&pspec.xspec[pspec.zindex].numofxs);
		fscanf(fp,"%hd",&pspec.xspec[pspec.zindex].yslice);
		if(pspec.flags.openxs)
			fscanf(fp,"%f %f %d %d",&pspec.xspec[pspec.zindex].lshear,
			&pspec.xspec[pspec.zindex].vshear,&qxs);
	}
	fscanf(fp,"%*s %f %f %f %f %f",&w->center.x,&w->center.y,&w->tilt,&w->width,&w->height);
	if(pspec.flags.window){
		++w;
		fscanf(fp,"%*s %f %f %f %f %f",&w->center.x,&w->center.y,&w->tilt,&w->width,&w->height);
	}
	if(pspec.flags.contflag){
		fscanf(fp,"%*s %hd",&pspec.zindex);
		fscanf(fp,"%f %f %d",&pspec.contour[pspec.zindex].interval,&pspec.contour[pspec.zindex].offset,
		&pspec.contour[pspec.zindex].dotted);
	}
	if(pspec.flags.vect)
		fscanf(fp,"%*s %hd %hd %hd %hd %f",&pspec.vspec.comp1,&pspec.vspec.comp2,
		&pspec.vspec.gridsize,&pspec.vspec.manscale,&pspec.vspec.vlength);
	fscanf(fp,"%*s %d %f\n",&plspec.format,&plspec.size);
}


/*
	Make one or more plots from the current picture specifier.
*/
make_plot(mfp)
FILE *mfp;
{
	char *cp;

	setcurrwin(); /* set the object window */
	switch(plspec.format){
		case 5:	page = lw2page;break;
		case 4:	page = lw1page;break;
		case 3:	page = vtec3page;break;
		case 2: page = vtec2page;break;
		default:page = vtec1page;break;
	}
	setpage(&page,plspec.size); /* scale the page to the given size */
	cp = fseq;
	while(*cp){ /* draw the successive frames in "fseq". */
		pspec.framenumber = atoi(cp);
		drawscreen(&pspec,mfp,qxs);
		erase();
		while(isdigit(*cp)) ++cp;
		while(*cp == ' ') ++cp;
	}
}


/*
	Re-scale the page as necessary.
*/
setpage(pg,newsize)
PAGETYPE *pg;
float newsize;
{
	float stdsize,scalefactor;
	int xl,yb,xr,yt,landscape;

	stdsize= (pg->viewport.ur.x - pg->viewport.ll.x)/1000.0;
	scalefactor= newsize/stdsize;
	rescale_box(scalefactor,&pg->screen);
	rescale_box(scalefactor,&pg->viewport);
	rescale_box(scalefactor,&pg->title);
	rescale_box(scalefactor,&pg->acct);
	rescale_box(scalefactor,&pg->profile);
	rescale_box(scalefactor,&pg->params);
	xaxis_ = (pg->screen.ur.x - pg->screen.ll.x)/1000.0;
	yaxis_ = (pg->screen.ur.y - pg->screen.ll.y)/1000.0;
	chrsiz_ = pg->profile.ch_size; /* constant for all boxes */
	xl = pg->screen.ll.x;
	xr = pg->screen.ur.x;
	yb = pg->screen.ll.y;
	yt = pg->screen.ur.y;
	landscape = (plspec.format == 5) ? 1 : 0;
	space(xl,yb,xr,yt,landscape);
}


rescale_box(factor,box)
float factor;
DEVICEBOX *box;
{
	box->ch_size = (int)((float)(box->ch_size)*factor);
	box->lf_size = (int)((float)(box->lf_size)*factor);
	box->home.x = (int)((float)(box->home.x)*factor);
	box->home.y = (int)((float)(box->home.y)*factor);
	box->ll.x = (int)((float)(box->ll.x)*factor);
	box->ll.y = (int)((float)(box->ll.y)*factor);
	box->ur.x = (int)((float)(box->ur.x)*factor);
	box->ur.y = (int)((float)(box->ur.y)*factor);
}


flagdecode(w,f)
unsigned w;
PICFLAGS *f;
{
	f->openxs= w & 01;
	w >>= 1;
	f->xsect= w & 01;
	w >>= 1;
	f->window= w & 01;
	w >>= 1;
	f->contflag= w & 01;
	w >>= 1;
	f->dotgrid= w & 01;
	w >>= 1;
	f->grid= w & 01;
	w >>= 1;
	f->vect= w & 01;
}

setcurrwin()
{
	WINDOWSPEC *w = pspec.wspec,*nw = w+1;

	w->center.x=(domain.ll.x+domain.ur.x)/2.0;
	w->center.y=(domain.ll.y+domain.ur.y)/2.0;
	w->width=w->height= max(domain.ur.x- domain.ll.x,domain.ur.y-domain.ll.y);
	if((nw->center.x != w->center.x) || (nw->center.y != w->center.y) || 
	(nw->tilt != w->tilt) || (nw->width != w->width) || (nw->height != w->height))
		pspec.currwin = pspec.topwin = w+1;
	else{
		*(w+1) = *(w+2); /* shift window down */
		pspec.currwin = pspec.topwin= w;
	}
}


openplotfile(pf)
char *pf;
{
	mkstemp(pf);
	strcat(pf,".pf");
	openpl();
}
