/*
        This file contains routines which handle the various drawing jobs.
*/
#include        <stdio.h>
#include        <math.h>
#include        "defs2.h"

extern FRAMETYPE frm;
extern INTPAIR transrot();
extern int currframe,intersect(),getcase(),cross(),symsize;

/* Draw a cross at x,y of radius r */
cross(x,y,r){
        line(x-r,y,x+r,y);
        line(x,y-r,x,y+r);
}

/*
        Draw an outline representation of the current pending window.
*/
drawindow(win)
WINDOWSPEC *win;
{
        double x0,y0,x1,y1,sine,cose,w,h;
        INTPAIR p;

        sine= sin(win->tilt*PI/180.0);
        cose= cos(win->tilt*PI/180.0);
        w= win->width;
        h= win->height;
        x0= win->center.x- w*cose/2.0 + h*sine/2.0 ;
        y0= win->center.y- w*sine/2.0 - h*cose/2.0 ;
        drawclipline(x0,y0,x1=x0+w*cose,y1=y0+w*sine);
        drawclipline(x1,y1,x0=x1-h*sine,y0=y1+h*cose);
        drawclipline(x0,y0,x1=x0-w*cose,y1=y0-w*sine);
        drawclipline(x1,y1,x0=x1+h*sine,y0=y1-h*cose);
        p= transrot(win->center.x,win->center.y);
        cross(p.x,p.y,symsize/2);
}


/*
        Draw an outline of the current pending window with cross sections
        super-imposed on the plan view.
*/
drawxsect(xs,win)
XSECTIONSPEC *xs;
WINDOWSPEC *win;
{
        int j,n;
        double x,y,sine,cose,w,h,d,dx,dy;

        n=xs->numofxs;
        if(xs->yslice){
                sine= sin((win->tilt+90.0)*PI/180.0);
                cose= cos((win->tilt+90.0)*PI/180.0);
                w= win->height;
                h= win->width;
        }else{
                sine= sin(win->tilt*PI/180.0);
                cose= cos(win->tilt*PI/180.0);
                w= win->width;
                h= win->height;
        }
        d= (n>1) ? h/(n-1) : 0.0;
        dx= -d*sine;
        dy=  d*cose;
        x= win->center.x -w*cose/2.0 + d*(n-1)*sine/2.0;
        y= win->center.y -w*sine/2.0 - d*(n-1)*cose/2.0;
        for(j=0;j<n;j++,x+=dx,y+=dy)
                drawclipline(x,y,x+w*cose,y+w*sine);
}


/*
        Sweep through the mfe edge list, drawing the mfe grid.
*/
drawgrid(pic)
PICTURESPEC *pic;
{
        REALPAIR *t,*h;
        EDGETYPE *ep;

        if(pic->flags.dotgrid)
                linemod("dotted");
        else if(pic->flags.grid)
                linemod("solid");
        for(ep=edge0+1;ep<=edge0+numofedges;ep++){
            t= node0+ep->tail;
            h= node0+ep->head;
            drawclipline(t->x,t->y,h->x,h->y);
        }
        linemod("solid");
}


/*
        Draw contours on the mfe grid of component having index 'i'.
*/
drawcont(cspec,i)
CONTOURSPEC *cspec;
int i; /* z-index */
{
        int     instance,m_th_cont,phase;
        float   z,zmin,zmax,*zp= *(zpp+i);
        REALTRIPLE v0,v1,v2;
        REALTRIPLE u0,u1;
        CELLTYPE *cp;

        m_th_cont= 5;
        cspec->dotted ? linemod("dotted") : linemod("solid");
        for(cp=cell0+1;cp<=cell0+numofcells;cp++){
            v0.x= (node0+cp->v0)->x;
            v0.y= (node0+cp->v0)->y;
            v0.z=  *(zp+cp->v0);
            v1.x= (node0+cp->v1)->x;
            v1.y= (node0+cp->v1)->y;
            v1.z=  *(zp+cp->v1);
            v2.x= (node0+cp->v2)->x;
            v2.y= (node0+cp->v2)->y;
            v2.z=  *(zp+cp->v2);
            if(cansee(v0.x,v0.y,v1.x,v1.y,v2.x,v2.y)){
                    zmin= min3(v0.z,v1.z,v2.z);
                    zmax= max3(v0.z,v1.z,v2.z);
                    z= nextup(zmin,cspec->interval,cspec->offset);
                    phase= nint(remainder(z-cspec->offset, m_th_cont*cspec->interval)/cspec->interval)%m_th_cont;
                    while(z < zmax){
                        if((instance=getcase(v0.z,v1.z,v2.z,z)) == 0)
                                intersect(v0.z,v1.z,v2.z,z,&v0,&v1,&v2,&u0,&u1);
                        else if(instance == 1)
                                intersect(v1.z,v2.z,v0.z,z,&v1,&v2,&v0,&u0,&u1);
                        else /* instance is 2 */
                                intersect(v2.z,v0.z,v1.z,z,&v2,&v0,&v1,&u0,&u1);
                        if(phase == 0 && cspec->dotted){
                                linemod("solid");
                                drawclipline(u0.x,u0.y,u1.x,u1.y);
                                linemod("dotted");
                        }else
                                drawclipline(u0.x,u0.y,u1.x,u1.y);
                        phase= ++phase%m_th_cont;
                        z += cspec->interval;
                    }
            }
        }
        linemod("solid");
}


/*
        Check to see if the given cell (triangle) is visible inside the current
        window.
*/
cansee(x0,y0,x1,y1,x2,y2)
double x0,y0,x1,y1,x2,y2;
{
        if(clipxy(&x0,&y0,&x1,&y1) || clipxy(&x1,&y1,&x2,&y2) || clipxy(&x0,&y0,&x2,&y2))
                return TRUE;
        else
                return FALSE;
}


/*
        Clip the given line to the current window and draw it.
*/
drawclipline(x0,y0,x1,y1)
double x0,y0,x1,y1;
{
        INTPAIR p,q;

        if(clipxy(&x0,&y0,&x1,&y1)){
                p=transrot(x0,y0);
                q=transrot(x1,y1);
                line(p.x,p.y,q.x,q.y);
        }
}


/*
        Draw a vector field from the given vector specification.
*/
drawvect(vspec)
VECTORSPEC *vspec;
{
#define         EPSILON         1.0e-05
        VECTPOINT v0,v1,v2,u,u0,u1;
        CELLTYPE *cp;
        float *up= *(zpp+vspec->comp1), *vp= *(zpp+vspec->comp2);
        double hx,hy,maxval,scalefactor,ymin,ymax,xmin,xmax,offx,offy;
        int instance;
        INTPAIR p;

        hx= (domain.ur.x-domain.ll.x-2.0*EPSILON)/(vspec->gridsize-1);
        hy= (domain.ur.y-domain.ll.y-2.0*EPSILON)/(nint((domain.ur.y-domain.ll.y)/hx));
        offx= domain.ll.x + EPSILON;
        offy= domain.ll.y + EPSILON;
        xmax= max(abs(frm.z[vspec->comp1].lo),abs(frm.z[vspec->comp1].hi));
        ymax= max(abs(frm.z[vspec->comp2].lo),abs(frm.z[vspec->comp2].hi));
        maxval= max(xmax,ymax);
        scalefactor= hx*vspec->vlength/maxval;
        for(cp= cell0+1;cp<= cell0+numofcells;cp++){ /* sweep cell list */
                v0.x= (node0+cp->v0)->x;
                v0.y= (node0+cp->v0)->y;
                v1.x= (node0+cp->v1)->x;
                v1.y= (node0+cp->v1)->y;
                v2.x= (node0+cp->v2)->x;
                v2.y= (node0+cp->v2)->y;
                if(cansee(v0.x,v0.y,v1.x,v1.y,v2.x,v2.y)){
                        v0.u= *(up+cp->v0);
                        v0.v= *(vp+cp->v0);
                        v1.u= *(up+cp->v1);
                        v1.v= *(vp+cp->v1);
                        v2.u= *(up+cp->v2);
                        v2.v= *(vp+cp->v2);
                        ymin= min3(v0.y,v1.y,v2.y);
                        ymax= max3(v0.y,v1.y,v2.y);
                        for(u.y= nextup(ymin,hy,offy);u.y<=ymax;u.y += hy){
                                if((instance=getcase(v0.y,v1.y,v2.y,u.y)) == 0)
                                        compu(v0.y,v1.y,v2.y,u.y,&v0,&v1,&v2,&u0,&u1);
                                else if(instance == 1)
                                        compu(v1.y,v2.y,v0.y,u.y,&v1,&v2,&v0,&u0,&u1);
                                else /* instance is 2 */
                                        compu(v2.y,v0.y,v1.y,u.y,&v2,&v0,&v1,&u0,&u1);
                                xmin= min(u0.x,u1.x);
                                xmax= max(u0.x,u1.x);
                                for(u.x= nextup(xmin,hx,offx);u.x<=xmax;u.x += hx){
					double x = u.x, y = u.y;
					compz(&u,&u0,&u1);
					drawclipline(u.x,u.y,u.x+scalefactor*u.u,u.y+scalefactor*u.v);
					if(clipxy(&x,&y,&x,&y)){
						p = transrot(u.x,u.y);
						cross(p.x,p.y,symsize/2);
					}
                                }
                        }
                }
        }
}


compu(s0,s1,s2,c,v0,v1,v2,u0,u1)
double s0,s1,s2,c;
VECTPOINT *v0,*v1,*v2;
VECTPOINT *u0,*u1;
{
        double t;

        t= (s0-c)/(s0-s1);
        u0->x= v0->x + (v1->x - v0->x)*t;
        u0->y= c;
        u0->u= v0->u + (v1->u - v0->u)*t;
        u0->v= v0->v + (v1->v - v0->v)*t;
        t= (s0-c)/(s0-s2);
        u1->x= v0->x + (v2->x - v0->x)*t;
        u1->y= c;
        u1->u= v0->u + (v2->u - v0->u)*t;
        u1->v= v0->v + (v2->v - v0->v)*t;
}


compz(u,u0,u1)
VECTPOINT *u,*u0,*u1;
{       
        double d;

        if((d= u1->x- u0->x) == 0.0){
                u->u= u0->u;
                u->v= u0->v;
        }else{
                u->u= u0->u + (u->x- u0->x)*(u1->u - u0->u)/d;
                u->v= u0->v + (u->x- u0->x)*(u1->v - u0->v)/d;
        }
}


/*
        Draw the current picture specifier on the terminal.
*/
drawscreen(pic,mfp,defer_draw,qxs)
PICTURESPEC *pic;
FILE *mfp;
int defer_draw,qxs;
{
        int i= pic->zindex;
        CONTOURSPEC *cspec= &pic->contour[i];
        extern PAGETYPE *pg;
        extern int currframe;
        extern double getcontint();

        if(currframe != pic->framenumber)
                readframe(mfp,pic->framenumber);
        boxdraw(&pg->viewport);
        if(pic->flags.openxs){
                if(pic->flags.window)
                        openxsect(pic,pic->currwin+1,defer_draw,qxs);
                else
                        openxsect(pic,pic->currwin,defer_draw,qxs);
                writealpha(pic);
                return;
        }
        setransrot(pic->currwin,&pg->viewport);
        if(pic->flags.xsect)
                if(pic->flags.window)
                        drawxsect(&pic->xspec[i],pic->currwin+1);
                else
                        drawxsect(&pic->xspec[i],pic->currwin);
        else if(pic->flags.window)
                drawindow(pic->currwin+1);
        if(cspec->interval == 0.0)
            cspec->interval= getcontint((frm.z[i].hi-frm.z[i].lo)/CONTDENSITY);
        if(!pic->vspec.manscale)
                getvectlength(&pic->vspec);
        if(pic->flags.contflag)
                drawcont(&pic->contour[pic->zindex],pic->zindex);
        if(pic->flags.vect)
                drawvect(&pic->vspec);
        if(pic->flags.grid || pic->flags.dotgrid)
                drawgrid(pic);
        writealpha(pic);
        setransrot(pic->currwin,&pg->viewport);
}
