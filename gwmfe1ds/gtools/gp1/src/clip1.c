#include	"defs1.h"
#include	"init1.h"

static float 	xleft,xright,ybottom,ytop,
		a11,a13,
		a22,a23;

/*
	Compute the parameters needed in the clipping routine and in the linear
	transformation from the object window to the screen viewport.
*/
setrans(w,vp)
WINDOWSPEC *w;
DEVICEBOX  *vp;
{
	float	width = vp->ur.x - vp->ll.x,
		height= vp->ur.y - vp->ll.y;

	xleft= w->xl;
	xright= w->xr;
	ybottom= w->yb;
	ytop= w->yt;
	a11= width/(xright - xleft);
	a13= vp->ll.x - xleft*a11;
	a22= height/(ytop-ybottom);
	a23= vp->ll.y - ybottom*a22;
}


/*
	Given window coordinates x,y, compute viewport (integer) coordinates.
*/
INTPAIR transform(x,y)
register float x,y;
{
	INTPAIR p;

	p.x = (int)(a11*x + a13);
	p.y = (int)(a22*y + a23);
	return(p);
}


/*
	This is the Liang-Barsky clipping algorithm.
*/
clipxy(x0,y0,x1,y1)
register float *x0,*y0,*x1,*y1;
{
	int accept= FALSE;
	float	t0= 0.0, t1= 1.0, deltax= *x1 - *x0, deltay;

	if(clipt(-deltax,*x0-xleft,&t0,&t1))
	    if(clipt(deltax,xright- *x0,&t0,&t1)){
		deltay= *y1- *y0;
		if(clipt(-deltay,*y0- ybottom,&t0,&t1))
		    if(clipt(deltay,ytop- *y0,&t0,&t1)){
			if(t1<1.0){
			    *x1= *x0 + t1*deltax;
			    *y1= *y0 + t1*deltay;
			}
			if(t0>0.0){
			    *x0= *x0 + t0*deltax;
			    *y0= *y0 + t0*deltay;
			}
			accept= TRUE;
		    }
	    }
	return(accept);
}


clipt(p,q,t0,t1)
register float p,q,*t0,*t1;
{
	register float r;
	int accept= TRUE;

	if(p<0.0){
		r=q/p;
		if(r> *t1)
			accept= FALSE;
		else if(r> *t0)
			*t0= r;
	}else if(p>0.0){
		r=q/p;
		if(r< *t0)
			accept= FALSE;
		else if(r< *t1)
			*t1= r;
	}else if(q<0.0)
		accept= FALSE;
	return(accept);
}


/*
	Compute window size by finding the x-range and y-range for the given
	set of frames and components.
*/
setwsize(pic)
PICTURESPEC *pic;
{
	register short *fp,*cp;
	short flist[MAXFRAMES],clist[MAXCOMP];
	float def_val,s,t,xmin,xmax,ymin,ymax;
	extern FRAMETYPE frame[];
	extern REALPAIR fshift[],cshift[];

	expand_nlist(flist,pic->fseq);
	expand_nlist(clist,pic->cseq);
	if(pic->flags.autox){
		xmin = 1e30; xmax = -1e30;
		for(fp = flist;*fp;fp++)
			for(cp = clist;*cp;cp++)
				if(frame[*fp].ncol >= *cp){
					s = fshift[*fp].x + cshift[*cp].x;
					t = frame[*fp].head->range.lo + s;
					if(t < xmin) xmin = t;
					t = frame[*fp].head->range.hi + s;
					if(t > xmax) xmax = t;
				}
		def_val = (xmin == xmax) ? 0.5 : 0.0;
		pic->win.xl = xmin - def_val;
		pic->win.xr = xmax + def_val;
	}
	if(pic->flags.autoy){
		ymin = 1e30; ymax = -1e30;
		for(fp = flist;*fp;fp++)
			for(cp = clist;*cp;cp++)
				if(frame[*fp].ncol >= *cp){
					s = fshift[*fp].y + cshift[*cp].y;
					t = (frame[*fp].head + *cp)->range.lo + s;
					if(t < ymin) ymin = t;
					t = (frame[*fp].head + *cp)->range.hi + s;
					if(t > ymax) ymax = t;
				}
		def_val = (ymin == ymax) ? 0.5 : 0.0;
		pic->win.yb = ymin - def_val;
		pic->win.yt = ymax + def_val;
	}
}
