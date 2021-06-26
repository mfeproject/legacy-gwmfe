/*	
	This file contains routines which handle the transformation between
	the object window and the screen. Note that the transformations for
	cross sections are handled in the file "xs.c".
*/
#include	<stdio.h>
#include	<math.h>
#include	"defs2.h"

static double 	c1,c2,c3,c4,	/* clipping parameters */
		a11,a12,a13,	/* window transform params */
		a21,a22,a23,	/* more window params */
		winwidth,winheight; 


/*
	Compute and save the parameters needed for clipping, translating, and
	rotating between the object window and the screen viewport.
*/
setransrot(w,vp)
WINDOWSPEC *w;
DEVICEBOX  *vp;
{
	double	scalex,scaley,sine,cose;
	INTPAIR vpcenter;

	winwidth= w->width;
	winheight= w->height;
	sine= sin(w->tilt *PI/180.0);
	cose= cos(w->tilt *PI/180.0);
	vpcenter.x= (vp->ll.x + vp->ur.x)/2;
	vpcenter.y= (vp->ll.y + vp->ur.y)/2;
	scalex= (vp->ur.x - vp->ll.x)/winwidth;
	scaley= (vp->ur.y - vp->ll.y)/winheight;
	c1= -sine;
	c2= cose;
	c3= w->center.x * sine - w->center.y * cose;
	c4= w->center.x * cose + w->center.y * sine;
	a11= scalex * cose;
	a12= scalex * sine;
	a13= vpcenter.x - scalex * c4;
	a21= -scaley * sine;
	a22= scaley * cose;
	a23= vpcenter.y + scaley * c3;
}


/*
	Given world or object coordinates x,y, compute the screen coordinates
	using the parameters stored previously by "setransrot()".
*/
INTPAIR
transrot(x,y)
double x,y;
{
	INTPAIR p;

	p.x= (int)(a11*x + a12*y + a13);
	p.y= (int)(a21*x + a22*y + a23);
	return(p);
}


/*
	This is the Liang-Barsky clipping algorithm for 2-D, modified to 
	handle a rotated object window.
*/
clipxy(x0,y0,x1,y1)
double *x0,*y0,*x1,*y1;
{
	int accept= FALSE;
	double	t0= 0.0,
		t1= 1.0,
		deltax= *x1 - *x0,
		deltay= *y1 - *y0,
		p= c1*deltay - c2*deltax,
		q= -c1* *y0 + c2* *x0 -c4 +winwidth/2.0;

	if(clipt(p,q,&t0,&t1))
	    if(clipt(-p,winwidth-q,&t0,&t1)){
		p= -c1*deltax -c2*deltay;
		q= c1* *x0 + c2* *y0 +c3 + winheight/2.0;
		if(clipt(p,q,&t0,&t1))
		    if(clipt(-p,winheight-q,&t0,&t1)){
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
double p,q,*t0,*t1;
{
	double r;
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
