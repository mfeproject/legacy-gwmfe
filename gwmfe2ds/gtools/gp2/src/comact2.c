/*
	This file contains routines which implement the various command actions
	issued by the user.
*/
#include	<stdio.h>
#include	<math.h>
#include	<string.h>
#include	"defs2.h"

extern	FRAMETYPE frm;

/*
	Add the successive values between "left" and "right", using a stepsize
	of "step", to the frame sequence string "fseq".
*/
incfseq(left,right,step,fseq)
int left,right,step;
char *fseq;
{
	int i,j;
	char s[4];

	left= min(max(left,1),numoframes);
	right= min(max(right,1),numoframes);
	step= (left <= right) ? step: -step;
	j= left;
	for(i=0; i<=((right-left)/step);i++){
		sprintf(s," %d",j);
		strcat(fseq,s);
		j += step;
	}
	if((right-left)%step){
		sprintf(s," %d",right);
		strcat(fseq,s);
	}
}


/*
	Write out the current picture specifier and related information to 
	the plotting program.
*/
writepicspec(pic,fseq,plspec,defer_draw,qxs)
PICTURESPEC *pic;
char *fseq;
PLOTSPEC *plspec;
int defer_draw,qxs;
{
	XSECTIONSPEC *x= &pic->xspec[pic->zindex];
	WINDOWSPEC   *w= pic->currwin;
	CONTOURSPEC  *c= &pic->contour[pic->zindex];
	VECTORSPEC   *v= &pic->vspec;
	char *gettime(),*getdate(),*cp=fseq;
	extern unsigned flagcode();
	FILE *openplot();
	extern FILE *pfp;
	
	if(pfp == NULL)
		pfp = openplot();
	fprintf(pfp,"date: %s\n",getdate());
	fprintf(pfp,"time: %s\n", gettime());
	fprintf(pfp,"frames: %s\n",fseq);
	while(*cp) *cp++ = '\0'; /*clear fseq for next command */
	fprintf(pfp,"flags: %05o\n",flagcode(pic->flags));
	if(pic->flags.xsect || pic->flags.openxs)
		fprintf(pfp,"xs: %d %d %d\n",pic->zindex,x->numofxs,x->yslice);
	if(pic->flags.openxs)
		fprintf(pfp," %.2f %.2f %d %d\n",x->lshear,x->vshear,defer_draw,qxs);
	fprintf(pfp, "currwin: %g %g %.1f %g %g\n",
			w->center.x,w->center.y,w->tilt,w->width,w->height);
	if(pic->flags.window){
		++w;
		fprintf(pfp, "pendwin: %g %g %.1f %g %g\n",
			w->center.x,w->center.y,w->tilt,w->width,w->height);
	}
	if(pic->flags.contflag)
		fprintf(pfp,"cont: %d %g %g %d\n",
			pic->zindex,c->interval,c->offset,c->dotted);
	if(pic->flags.vect)
		fprintf(pfp,"vect: %d %d %d %d %g\n",
			v->comp1,v->comp2,v->gridsize,v->manscale,v->vlength);
	fprintf(pfp,"format: %d %.2f\n\n",plspec->format,plspec->size);
}


/*
	Initialize an instance of cross-sections.
*/
initxsect(index,numofxs,pic)
int index,numofxs;
PICTURESPEC *pic;
{
	int i;

	if(index != 0) /* index=0 implies "don't change current index" */
		pic->zindex= min(max(index-1,0),numofzvals-1);
	i= pic->zindex;
	if(numofxs != 0) /* numofxs=0 implies "don't change current numofxs */
		pic->xspec[i].numofxs= max(numofxs,1);
	pic->flags.xsect= !pic->flags.openxs;
}


/*
	Change the height of the current window "kid" relative to the height
	of its parent window "mom".
*/
changeheight(kid,newh)
WINDOWSPEC *kid;
float newh;
{
	WINDOWSPEC *mom= kid-1;
	float normh= max(newh,0.00001)/100.0;

	kid->height = normh*mom->height;
}


changewidth(kid,neww)
WINDOWSPEC *kid;
float neww;
{
	WINDOWSPEC *mom= kid-1;
	float normw= max(neww,0.00001)/100.0;

	kid->width = normw*mom->width;
}


/*
	Move the current window "kid" to the given absolute x,y position in its 
	parent window "mom".
*/
mabox(x,y,kid)
float x,y;
WINDOWSPEC *kid;
{
	WINDOWSPEC *mom= kid-1;
	float nx= min(max(x,0.0),100.0)/100.0;
	float ny= min(max(y,0.0),100.0)/100.0;

	kid->center.x = (nx-0.5)*mom->width + mom->center.x;
	kid->center.y = (ny-0.5)*mom->width + mom->center.y;
}


/*
	Move the current window "kid" relative to its current position in its
	parent window "mom" by the given amount x,y.
*/
mrbox(x,y,kid)
float x,y;
WINDOWSPEC *kid;
{
	WINDOWSPEC *mom= kid-1;
	float deltax,deltay,sine,cose;
	float left= mom->center.x - mom->width/2.0,
	      right= mom->center.x + mom->width/2.0,
	      bottom= mom->center.y - mom->height/2.0,
	      top= mom->center.y + mom->height/2.0;

	sine= sin((mom->tilt - kid->tilt)*PI/180.0);
	cose= cos((mom->tilt - kid->tilt)*PI/180.0);
	deltax= (x*cose - y*sine)/100.0;
	deltay= (x*sine + y*cose)/100.0;
	kid->center.x += deltax*mom->width;
	kid->center.y += deltay*mom->height;
	kid->center.x= min(max(kid->center.x,left),right);
	kid->center.y= min(max(kid->center.y,bottom),top);
}


/*
	Open the next window in the window stack.
*/
initwindow(wp)
WINDOWSPEC *wp;
{
	*(wp+1) = *wp;
	(wp+1)->width *= 0.5;
	(wp+1)->height *= 0.5;
}


/*
	Initialize an instance of contours.
*/
initcont(index,pic,dotted)
int index,dotted;
PICTURESPEC *pic;
{
	if(index != 0) /* index=0 implies "don't change current index */
		pic->zindex= min(max(index-1,0),numofzvals-1);
	pic->flags.contflag= TRUE;
	pic->flags.openxs= FALSE;
	pic->contour[pic->zindex].dotted = dotted; /* turn on or off dotting flag */
}


/*
	Set the contour interval; make sure it is positive.
*/
setcontint(interval,pic)
float interval;
PICTURESPEC *pic;
{
	float zrange;
	int i= pic->zindex;

	zrange= frm.z[i].hi - frm.z[i].lo;
	if(zrange == 0.0)
		zrange = 1.0;
	pic->contour[i].interval= max(interval,0.0001*zrange);
}


#define		MINSIZE1	3.5
#define		MAXSIZE1	14.0
#define		MINSIZE2	5.25
#define		MAXSIZE2	21.0
#define		MINSIZE3	10.0
#define		MAXSIZE3	21.0
#define		MINSIZE4	3.5
#define		MAXSIZE4	7.0
#define		MINSIZE5	4.0
#define		MAXSIZE5	7.5
#define		DEFSIZE1	7.0
#define		DEFSIZE2	10.0
#define		DEFSIZE3	21.0
#define		DEFSIZE4	7.0
#define		DEFSIZE5	7.5


/*
	Set the plot size according to the current format and the input value.
*/
setplotsize(size,ps)
float size;
PLOTSPEC *ps;
{
	if(ps->format == 1)
		ps->size= (size == 0.0) ? DEFSIZE1 : min(max(size,MINSIZE1),MAXSIZE1);
	else if(ps->format == 2)
		ps->size= (size == 0.0) ? DEFSIZE2 : min(max(size,MINSIZE2),MAXSIZE2);
	else if(ps->format == 3)
		ps->size= (size == 0.0) ? DEFSIZE3 : min(max(size,MINSIZE3),MAXSIZE3);
	else if(ps->format == 4)
		ps->size= (size == 0.0) ? DEFSIZE4 : min(max(size,MINSIZE4),MAXSIZE4);
	else if(ps->format == 5)
		ps->size= (size == 0.0) ? DEFSIZE5 : min(max(size,MINSIZE5),MAXSIZE5);
	
}

/*
	Initialize an instance of vector fields.
*/
initvect(c1,c2,n,pic)
int c1,c2,n;
PICTURESPEC *pic;
{
	if(c1 != 0)
		pic->vspec.comp1= min(max(c1-1,0),numofzvals-1);
	if(c2 != 0)
		pic->vspec.comp2= min(max(c2-1,0),numofzvals-1);
	if(n != 0)
		pic->vspec.gridsize= min(max(n,3),MAXGRIDSIZE);
	pic->flags.vect= TRUE;
	pic->flags.openxs= FALSE;
}


setvectlength(l,pic)
float l;
PICTURESPEC *pic;
{
	if(l != 0.0){
		pic->vspec.manscale= TRUE;
		pic->vspec.vlength= min(max(l,0.001),1000.0);
	}else
		pic->vspec.manscale= FALSE;
}


/*	This prints the screen information requested by the "show times"
	command.
*/
showtable(mfp)
FILE *mfp;
{
	int i,numoflines,x,y;
	float times[50];
	char s[80],lastcol[40],midcol[40];
	extern PAGETYPE *pg;

	x = pg->screen.home.x;
	y = pg->screen.home.y;
	move(x,y);
	erase();
	sprintf(s,"frame    time        frame    time        frame    time");
	label(s);
	move(x,y -= pg->screen.lf_size);
	getframetimes(times,mfp);
	numoflines= (numoframes+2)/3;
	for(i=1;i<=numoflines;i++){
		sprintf(s," %2d   %10.3e      ", i,times[i]);
		if(i+numoflines <= numoframes){
			sprintf(midcol,"%2d   %10.3e      ",i+numoflines,times[i+numoflines]);
			strcat(s,midcol);
		}
		if(i+2*numoflines <= numoframes){
			sprintf(lastcol,"%2d   %10.3e",i+2*numoflines,times[i+2*numoflines]);
			strcat(s,lastcol);
		}
		label(s);
		move(x,y -= pg->screen.lf_size);
	}
}


getframetimes(t,fp)
float t[];
FILE *fp;
{
	int i;
	extern long indexadd;

	for(i=1;i<=numoframes;i++){
		fseek(fp,indexadd + (long)(sizeof(long)*(i-1)),0);
		fseek(fp,(long)getw(fp),0);
		fread(t+i,sizeof(float),1,fp);
	}
}
