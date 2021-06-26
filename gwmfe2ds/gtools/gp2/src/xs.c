#include	<stdlib.h>
#include	<stdio.h>
#include	<math.h>
#include	<float.h>
#include	"defs2.h"

#define		MARGIN		0.02
#define		EPSILON		1e-5

extern PAGETYPE *pg;
extern FRAMETYPE frm;

typedef struct{
	double x0,y0,z0,x1,y1,z1;
}FULLEDGE;

openxsect(pic,refwin,defer_draw,qxs)
PICTURESPEC *pic;
WINDOWSPEC *refwin;
int defer_draw,qxs;
{
	float *zp = *(zpp+pic->zindex),cose,sine;
	XSECTIONSPEC *xs = &pic->xspec[pic->zindex];
	WINDOWSPEC xywin;
	INTERVAL zrange,orange;
	FULLEDGE *fedge;
	DEVICEBOX adjust_vp();
	char *emalloc();
	int n = numofedges;

	zrange = frm.z[pic->zindex];
	xywin.center = refwin->center;
	if(xs->yslice){
		xywin.height = refwin->width*(1-EPSILON);
		xywin.width = refwin->height;
		cose= cos((refwin->tilt+90.0)*PI/180.0);
		sine= sin((refwin->tilt+90.0)*PI/180.0);
		xywin.tilt = refwin->tilt + 90.0;
	}else{
		xywin.height = refwin->height*(1-EPSILON);
		xywin.width = refwin->width;
		cose= cos(refwin->tilt *PI/180.0);
		sine= sin(refwin->tilt *PI/180.0);
		xywin.tilt = refwin->tilt;
	}
	fedge = (FULLEDGE *)emalloc(sizeof(FULLEDGE)*numofedges);
	if(pic->flags.dotgrid) linemod("dotted");
	if(must_clip(xywin))
		n = clip_edge_list(xywin,fedge,zp,&zrange);
	else
		copy_edge_list(fedge,zp);
	orange = zrange;
	if(defer_draw)
		adjust_zrange(xywin.height,xywin.center.x,xywin.center.y,cose,sine,fedge,n,xs->vshear,&zrange);
	set_view_transform(xywin,orange,zrange,xs->lshear,xs->vshear,adjust_vp(pg->viewport));
	if(pic->flags.grid || pic->flags.dotgrid)
		emit_grid(fedge,n);
	free(fedge);
	linemod("solid");
	if(!qxs)
		emit_sections(xywin,cose,sine,zp,xs->numofxs);
}


emit_sections(xywin,cose,sine,zp,n)
WINDOWSPEC xywin;
float cose,sine,*zp;
int n;
{
	int	instance,j;
	float	s0,s1,s2,c,xc1,d,dx,dy,x1,y1,xc,yc;
	REALTRIPLE u0,u1,v0,v1,v2;
	CELLTYPE *cp;

	d = (n > 1) ? xywin.height/(n-1) : 0.0;
	dx = -d*sine;
	dy = d*cose;
	x1 = xywin.center.x +d*(n-1)*sine/2.0;
	y1 = xywin.center.y -d*(n-1)*cose/2.0;
	xc1 = -sine*x1 + cose*y1;
	for(cp=cell0+1;cp<= cell0+numofcells;cp++){
	    c = xc1;
	    xc = x1;
	    yc = y1;
	    v0.x = (node0+cp->v0)->x;
	    v0.y = (node0+cp->v0)->y;
	    v0.z = *(zp+cp->v0);
	    v1.x = (node0+cp->v1)->x;
	    v1.y = (node0+cp->v1)->y;
	    v1.z = *(zp+cp->v1);
	    v2.x = (node0+cp->v2)->x;
	    v2.y = (node0+cp->v2)->y;
	    v2.z = *(zp+cp->v2);
	    s0 = -sine*v0.x + cose*v0.y;
	    s1 = -sine*v1.x + cose*v1.y;
	    s2 = -sine*v2.x + cose*v2.y;
	    for(j=0;j<n;j++,c=xc1+j*d,xc += dx,yc += dy){
		if((instance=getcase(s0,s1,s2,c)) == -1)
		    continue;
		else if(instance == 0)
		    intersect(s0,s1,s2,c,&v0,&v1,&v2,&u0,&u1);
		else if(instance == 1)
		    intersect(s1,s2,s0,c,&v1,&v2,&v0,&u0,&u1);
		else /* instance is 2 */
		    intersect(s2,s0,s1,c,&v2,&v0,&v1,&u0,&u1);
		if(visible(cose,sine,xywin.width,&u0,&u1,xc,yc))
			emit_line(&u0,&u1);
	    }
	}
}


clip_edge_list(xywin,fedge,zp,zrp)
WINDOWSPEC xywin;
float *zp;
FULLEDGE *fedge;
INTERVAL *zrp;
{
	FULLEDGE *fep = fedge;
	EDGETYPE *ep;

	setzclip(&xywin);
	zrp->lo = FLT_MAX; zrp->hi = -FLT_MAX;
	for(ep = edge0 + 1;ep <= edge0 + numofedges;ep++){
		fep->x0 = (node0 + ep->tail)->x;
		fep->y0 = (node0 + ep->tail)->y;
		fep->z0 = *(zp + ep->tail);
		fep->x1 = (node0 + ep->head)->x;
		fep->y1 = (node0 + ep->head)->y;
		fep->z1 = *(zp + ep->head);
		if(clipxyz(&fep->x0,&fep->y0,&fep->z0,&fep->x1,&fep->y1,&fep->z1)){
			if(min(fep->z0,fep->z1) < zrp->lo)
				zrp->lo = min(fep->z0,fep->z1);
			if(max(fep->z0,fep->z1) > zrp->hi)
				zrp->hi = max(fep->z0,fep->z1);
			++fep;
		}
	}
	return fep - fedge;
}


copy_edge_list(fep,zp)
FULLEDGE *fep;
float *zp;
{
	EDGETYPE *ep;

	for(ep = edge0 + 1;ep <= edge0 + numofedges;ep++,fep++){
		fep->x0 = (node0 + ep->tail)->x;
		fep->y0 = (node0 + ep->tail)->y;
		fep->z0 = *(zp + ep->tail);
		fep->x1 = (node0 + ep->head)->x;
		fep->y1 = (node0 + ep->head)->y;
		fep->z1 = *(zp + ep->head);
	}
}


adjust_zrange(h,a,b,cose,sine,fep,n,shear,zrp)
float h,a,b,cose,sine,shear;
FULLEDGE *fep;
int n;
INTERVAL *zrp;
{
	float y,z,beta,r,m;
	INTERVAL sz;

	sz.lo = FLT_MAX;sz.hi = -FLT_MAX;
	beta = shear*(zrp->hi - zrp->lo)/(100.0*h);
	for(;n;n--,fep++){
		y = cose*(fep->y0 - b) - sine*(fep->x0 - a);
		z = fep->z0 + beta*y;
		if(z < sz.lo)
			sz.lo = z;
		if(z > sz.hi)
			sz.hi = z;
		y = cose*(fep->y1 - b) - sine*(fep->x1 - a);
		z = fep->z1 + beta*y;
		if(z < sz.lo)
			sz.lo = z;
		if(z > sz.hi)
			sz.hi = z;
	}
	r = max((sz.hi - sz.lo)/(1 + abs(shear/100.0)),0.0001);
	m = (sz.hi + sz.lo)*0.5;
	zrp->lo = m - r/2;
	zrp->hi = m + r/2;
}


static double A[4][4]; /* the world to viewport transform matrix */

set_view_transform(xywin,orange,zrange,hs,vs,viewport)
WINDOWSPEC xywin;
INTERVAL zrange,orange;
float hs,vs;
DEVICEBOX viewport;
{
	double a,b,c,d,alpha,beta,e,f,g,h;

	makeident(A);
	a = xywin.center.x;
	b = xywin.center.y;
	c = 0.5*(zrange.lo + zrange.hi);
	d = (zrange.lo == zrange.hi) ? 1.0 : zrange.hi - zrange.lo;
	alpha = hs*xywin.width/(100.0*xywin.height);
	beta = vs*(orange.hi - orange.lo)/(100.0*xywin.height);
	e = 0.5*(viewport.ll.x + viewport.ur.x);
	f = 0.5*(viewport.ll.y + viewport.ur.y);
	g = (viewport.ur.x - viewport.ll.x)/(xywin.width*(1.0 + abs(hs)/100.0));
	h = (viewport.ur.y - viewport.ll.y)/(d*(1.0 + abs(vs)/100.0));
	translate(A,'x',-a);
	translate(A,'y',-b);
	translate(A,'z',-c);
	rotate(A,'z',-xywin.tilt);
	rotate(A,'x',90.0);
	rescale(A,'y',-1.0);
	shear(A,'z',alpha,beta);
	rescale(A,'x',g);
	rescale(A,'y',h);
	translate(A,'x',e);
	translate(A,'y',f);
}


emit_grid(fep,n)
FULLEDGE *fep;
int n;
{
	int x0,y0,x1,y1;

	for(;n;--n,++fep){
		x0 = (int)(0.5 + fep->x0*A[0][0] + fep->y0*A[1][0] + fep->z0*A[2][0] + A[3][0]);
		y0 = (int)(0.5 + fep->x0*A[0][1] + fep->y0*A[1][1] + fep->z0*A[2][1] + A[3][1]);
		x1 = (int)(0.5 + fep->x1*A[0][0] + fep->y1*A[1][0] + fep->z1*A[2][0] + A[3][0]);
		y1 = (int)(0.5 + fep->x1*A[0][1] + fep->y1*A[1][1] + fep->z1*A[2][1] + A[3][1]);
		line(x0,y0,x1,y1);
	}
}


emit_line(u0,u1)
REALTRIPLE *u0,*u1;
{
	int x0,y0,x1,y1;

	x0 = (int)(0.5 + u0->x*A[0][0] + u0->y*A[1][0] + u0->z*A[2][0] + A[3][0]);
	y0 = (int)(0.5 + u0->x*A[0][1] + u0->y*A[1][1] + u0->z*A[2][1] + A[3][1]);
	x1 = (int)(0.5 + u1->x*A[0][0] + u1->y*A[1][0] + u1->z*A[2][0] + A[3][0]);
	y1 = (int)(0.5 + u1->x*A[0][1] + u1->y*A[1][1] + u1->z*A[2][1] + A[3][1]);
	line(x0,y0,x1,y1);
	
}


must_clip(xywin)
WINDOWSPEC xywin;
{
	double M[4][4],x,y,w,h,a,b;

	w = xywin.width + 2*EPSILON;
	h = xywin.height + 2*EPSILON;
	a = xywin.center.x;
	b = xywin.center.y;
	makeident(M);
	translate(M,'x',-a);
	translate(M,'y',-b);
	rotate(M,'z',-xywin.tilt);
	x = domain.ll.x*M[0][0] + domain.ll.y*M[1][0] + M[3][0];
	y = domain.ll.x*M[0][1] + domain.ll.y*M[1][1] + M[3][1];
	if(x > w/2 || x < -w/2 || y > h/2 || y < -h/2)
		return TRUE; /* clipping is required */
	x = domain.ur.x*M[0][0] + domain.ll.y*M[1][0] + M[3][0];
	y = domain.ur.x*M[0][1] + domain.ll.y*M[1][1] + M[3][1];
	if(x > w/2 || x < -w/2 || y > h/2 || y < -h/2)
		return TRUE; /* clipping is required */
	x = domain.ur.x*M[0][0] + domain.ur.y*M[1][0] + M[3][0];
	y = domain.ur.x*M[0][1] + domain.ur.y*M[1][1] + M[3][1];
	if(x > w/2 || x < -w/2 || y > h/2 || y < -h/2)
		return TRUE; /* clipping is required */
	x = domain.ll.x*M[0][0] + domain.ur.y*M[1][0] + M[3][0];
	y = domain.ll.x*M[0][1] + domain.ur.y*M[1][1] + M[3][1];
	if(x > w/2 || x < -w/2 || y > h/2 || y < -h/2)
		return TRUE; /* clipping is required */
	return FALSE; /* clipping is not required */
}


getcase(s0,s1,s2,c)
double s0,s1,s2,c;
{
	int instance;

	if(s0<c)
		if(s1<c)
			if(s2<c)
				instance= -1;
			else
				instance= 2;
		else if(s1==c)
			if(s2<c)
				instance= 1;
			else
				instance= 0;
		else
			if(s2<c)
				instance= 1;
			else
				instance= 0;
	else if(s0==c)
		if(s1<c)
			if(s2<c)
				instance= 0;
			else
				instance= 1;
		else if(s1==c)
			if(s2==c)
				instance= -1;
			else
				instance= 2;
		else
			if(s2>c)
				instance= 0;
			else
				instance= 1;
	else
		if(s1<c)
			if(s2<c)
				instance= 0;
			else
				instance= 1;
		else if(s1==c)
			if(s2>c)
				instance= 1;
			else
				instance= 0;
		else
			if(s2>c)
				instance= -1;
			else
				instance= 2;
	return(instance);
}


intersect(s0,s1,s2,c,v0,v1,v2,u0,u1)
float s0,s1,s2,c;
REALTRIPLE *v0,*v1,*v2;
REALTRIPLE *u0,*u1;
{
	float t;

	t= (s0-c)/(s0-s1);
	u0->x= v0->x + (v1->x - v0->x)*t;
	u0->y= v0->y + (v1->y - v0->y)*t;
	u0->z= v0->z + (v1->z - v0->z)*t;
	t= (s0-c)/(s0-s2);
	u1->x= v0->x + (v2->x - v0->x)*t;
	u1->y= v0->y + (v2->y - v0->y)*t;
	u1->z= v0->z + (v2->z - v0->z)*t;
}


visible(cose,sine,width,u0,u1,xcent,ycent)
float cose,sine,xcent,ycent,width;
REALTRIPLE *u0,*u1;
{
	float hw,d0,d1,delta;
	REALTRIPLE tmp;

	if(abs(cose) > 0.707){
		hw= abs(width *cose/2.0);
		d0= u0->x - xcent;
		d1= u1->x - xcent;
	}else{
		hw= abs(width *sine/2.0);
		d0= u0->y - ycent;
		d1= u1->y - ycent;
	}
	delta= d1-d0;
	if(d0>hw)
		if(d1>hw)
			return FALSE;
		else if(d1< -hw){
			tmp= *u0;
			movepoint(u0,u1,(hw-d0)/delta);
			movepoint(u1,&tmp,(-hw-d1)/-delta);
		}else /* u1 is visible */
			movepoint(u0,u1,(hw-d0)/delta);
	else if(d0 < -hw)
		if(d1 < -hw)
			return FALSE;
		else if(d1 > hw){
			tmp= *u0;
			movepoint(u0,u1,(-hw-d0)/delta);
			movepoint(u1,&tmp,(hw-d1)/-delta);
		}else /* u1 is visible */
			movepoint(u0,u1,(-hw-d0)/delta);
	else /* u0 is visible */
		if(d1 > hw)
			movepoint(u1,u0,(hw-d1)/-delta);
		else if(d1 < -hw)
			movepoint(u1,u0,(-hw-d1)/-delta);
	return TRUE;
}


movepoint(u0,u1,t)
REALTRIPLE *u0,*u1;
float t;
{
	u0->x += t*(u1->x - u0->x);
	u0->y += t*(u1->y - u0->y);
	u0->z += t*(u1->z - u0->z);
}


DEVICEBOX
adjust_vp(old)
DEVICEBOX old;
{
	int deltax = (int)((old.ur.x - old.ll.x)*MARGIN);
	int deltay = (int)((old.ur.y - old.ll.y)*MARGIN);
	DEVICEBOX new;

	new.ll.x = old.ll.x + deltax;
	new.ll.y = old.ll.y + deltay;
	new.ur.x = old.ur.x - deltax;
	new.ur.y = old.ur.y - deltay;
	return new;
}

static double 	xc1,xc2,xc3,xc4,xwinwidth,xwinheight;	/* clipping parameters */ 

setzclip(w)
WINDOWSPEC *w;
{
	double	sine,cose;

	xwinwidth = w->width;
	xwinheight = w->height;
	sine = sin(w->tilt *PI/180.0);
	cose = cos(w->tilt *PI/180.0);
	xc1 = -sine;
	xc2 = cose;
	xc3 = w->center.x * sine - w->center.y * cose;
	xc4 = w->center.x * cose + w->center.y * sine;
}


clipxyz(x0,y0,z0,x1,y1,z1)
double *x0,*y0,*z0,*x1,*y1,*z1;
{
	int accept = FALSE;
	double	t0= 0.0,
		t1= 1.0,
		deltax= *x1 - *x0,
		deltay= *y1 - *y0,
		deltaz= *z1 - *z0,
		p= xc1*deltay - xc2*deltax,
		q= -xc1* *y0 + xc2* *x0 -xc4 +xwinwidth/2.0;

	if(clipt(p,q,&t0,&t1))
	    if(clipt(-p,xwinwidth-q,&t0,&t1)){
		p= -xc1*deltax -xc2*deltay;
		q= xc1* *x0 + xc2* *y0 +xc3 + xwinheight/2.0;
		if(clipt(p,q,&t0,&t1))
		    if(clipt(-p,xwinheight-q,&t0,&t1)){
			if(t1<1.0){
			    *x1= *x0 + t1*deltax;
			    *y1= *y0 + t1*deltay;
			    *z1= *z0 + t1*deltaz;
			}
			if(t0>0.0){
			    *x0= *x0 + t0*deltax;
			    *y0= *y0 + t0*deltay;
			    *z0= *z0 + t0*deltaz;
			}
			accept= TRUE;
		    }
	    }
	return(accept);
}
