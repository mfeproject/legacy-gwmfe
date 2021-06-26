
/*	This file contains routines which write out alphabetic information
	in the boxes at the side of the viewport.
*/
#include	<stdio.h>
#include	<strings.h>
#include	"defs2.h"

extern	PAGETYPE *pg;
extern  FRAMETYPE frm;

/*
	Entry point for writing alpha information in side boxes.
*/
writealpha(pic)
PICTURESPEC *pic;
{
	wrparams(pic);
	wrprofile(pic);
	wrtitle();
	wracct();
}



/*	Write the information in the title box.
*/
wrtitle()
{
	extern  int currframe;
	int i,j;
	char s[BOXLLENGTH+20];
	DEVICEBOX *b = &pg->title;
	INTPAIR p;

	p = b->home;
	move(p.x,p.y);
	for(i=0;falfa.title[BOXLLENGTH-2-i] == ' ';i++)
		; /* count blanks at the end of the title */
	for(j=0;j<i/2;j++)
		s[j]= ' '; /* put 1/2 that many blanks at head of s */
	for(j=i/2;j<=BOXLLENGTH-2-i+i/2;j++)
		s[j]= falfa.title[j-i/2]; /* move the title into s */
	s[j]= '\0';
	label(s);
	move(p.x,p.y -= b->lf_size);
	sprintf(s,"frm:%2d  t=%.4g",currframe,frm.t);
	label(s);
	move(p.x,p.y -= b->lf_size);
	sprintf(s,"date:%-6s  %-6s",today,falfa.op);
	label(s);
	boxdraw(b);
}


/*	Write the information in the acct box.
*/
wracct()
{
	char s[40];
	DEVICEBOX *b= &pg->acct;
	INTPAIR p;
	int lf= b->lf_size;
	extern char mfefname[];

	p= b->home;
	move(p.x,p.y);
	sprintf(s,"file:%-14s",mfefname);
	label(s);
	move(p.x,p.y -= lf);
	sprintf(s,"%-20s",falfa.date);
	label(s);
	move(p.x,p.y -= lf);
	sprintf(s,"%-20s",falfa.vercpu);
	label(s);
	boxdraw(b);
}


/*	Write the information in the profile box.
*/
wrprofile(pic)
PICTURESPEC *pic;
{
	char s[40];
	DEVICEBOX *b= &pg->profile,squarebox;
	INTPAIR p;
	int lf= b->lf_size,getsquarebox();

	if(pic->flags.openxs || pic->currwin>pic->wspec){
		getsquarebox(b,&squarebox);
		setransrot(pic->wspec,&squarebox);
		boxdraw(&squarebox);
		if(!(pic->flags.xsect || pic->flags.openxs))
			drawindow(pic->currwin);
		else
			drawxsect(&pic->xspec[pic->zindex],pic->flags.window ? pic->currwin+1 : pic->currwin);
	}else{
		p= b->home;
		move(p.x,p.y);
		sprintf(s,"%s",frm.lastep);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"%s",frm.maxstep);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"%s",frm.cputime);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"%s",frm.isteps);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"xmin:%.4g",domain.ll.x);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"xmax:%.4g",domain.ur.x);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"ymin:%.4g",domain.ll.y);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"ymax:%.4g",domain.ur.y);
		label(s);
	}
	boxdraw(b);
}


/*	Write the information in the params box.
*/
wrparams(pic)
PICTURESPEC *pic;
{
	char s[40];
	DEVICEBOX *b= &pg->params;
	INTPAIR p;
	int lf= b->lf_size,box_used = FALSE;

	p= b->home;
	move(p.x,p.y);
	if((pic->flags.window || pic->currwin>pic->wspec) && !(pic->flags.xsect || pic->flags.openxs)){
		WINDOWSPEC *w=pic->flags.window ? pic->currwin+1 : pic->currwin;
		box_used = TRUE;
		sprintf(s,"   Window Data");
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"xc=%.3g yc=%.3g",w->center.x, w->center.y);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"w=%.3g h=%.3g a=%.0f",w->width,w->height,w->tilt);
		label(s);
		move(p.x,p.y -= lf);
	}
	if(pic->flags.contflag && !pic->flags.openxs){
		CONTOURSPEC *c= &pic->contour[pic->zindex];
		box_used= TRUE;
		sprintf(s,"   Contour Data");
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"var=%d (%-.12s)",pic->zindex+1,falfa.z[pic->zindex]);
		label(s);
		move(p.x,p.y -= lf);
		if(c->offset)
			sprintf(s,"int=%.3g off=%.3g",c->interval,c->offset);
		else
			sprintf(s,"int=%.3g",c->interval);
		label(s);
		move(p.x,p.y -= lf);
	}
	if(pic->flags.vect && !pic->flags.openxs){
		VECTORSPEC *v= &pic->vspec;
		box_used= TRUE;
		sprintf(s,"   Vector Data");
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"u= z%d v= z%d l= %.3g",v->comp1+1,v->comp2+1,v->vlength);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"gridsize: %d",v->gridsize);
		label(s);
		move(p.x,p.y -= lf);
	}
	if(pic->flags.xsect || pic->flags.openxs){
		XSECTIONSPEC *xs= &pic->xspec[pic->zindex];
		WINDOWSPEC *w=pic->flags.window ? pic->currwin+1 : pic->currwin;
		box_used= TRUE;
		sprintf(s," Cross Section Data");
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"var=%d (%-.12s)",pic->zindex+1,falfa.z[pic->zindex]);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"xc=%.3g yc=%.3g",w->center.x, w->center.y);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s,"w=%.3g h=%.3g a=%.0f",w->width,w->height,w->tilt);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s, "zrange %.3g : %.3g",xs->zrange.lo, xs->zrange.hi);
		label(s);
		move(p.x,p.y -= lf);
		sprintf(s, "shear %.1f%%h : %.1f%%v", xs->lshear, xs->vshear);
		label(s);
		move(p.x,p.y -= lf);
	}
	boxdraw(b);
	return box_used;
}


/*	Draw the given box.
*/
boxdraw(box)
DEVICEBOX *box;
{
	move(box->ll.x, box->ll.y);
	cont(box->ur.x, box->ll.y);
	cont(box->ur.x, box->ur.y);
	cont(box->ll.x, box->ur.y);
	cont(box->ll.x, box->ll.y);
}


/*	Find the largest square within a given rectangle.
*/
getsquarebox(rect,target)
DEVICEBOX *rect,*target;
{
	int side;

	side= min(rect->ur.y - rect->ll.y, rect->ur.x - rect->ll.x);
	target->ll= rect->ll;
	target->ur.x= side+target->ll.x;
	target->ur.y= side+target->ll.y;
}
