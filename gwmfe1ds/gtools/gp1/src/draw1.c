#include	"defs1.h"
#include	"init1.h"

#define		diamond(x,y,r)		{move((x)-(r),y);\
					cont(x,(y)+(r));\
					cont((x)+(r),y);\
					cont(x,(y)-(r));\
					cont((x)-(r),y);}

#define		square(x,y,r)		{move((x)-(r),(y)-(r));\
					cont((x)+(r),(y)-(r));\
					cont((x)+(r),(y)+(r));\
					cont((x)-(r),(y)+(r));\
					cont((x)-(r),(y)-(r));}

#define		triangle(x,y,r)		{int dx = (int)((r)*0.866);\
					move((x)-dx,(y)-(r)/2);\
					cont((x)+dx,(y)-(r)/2);\
					cont((x),(y)+(r));\
					cont((x)-dx,(y)-(r)/2);}

drawgraph(x,y,nline)
register float *x,*y;
int nline;
{
	register int i = 0;
	INTPAIR p;
	extern INTPAIR transform();

	while(i<nline){
		while(!clipxy(x+i,y+i,x+i+1,y+i+1) && (i<nline))
			++i;
		if(i<nline){
			p = transform(x[i],y[i]);
			move(p.x,p.y);
			++i;
			p = transform(x[i],y[i]);
			cont(p.x,p.y);
		}
		while(clipxy(x+i,y+i,x+i+1,y+i+1) && (i<nline)){
			++i;
			p = transform(x[i],y[i]);
			cont(p.x,p.y);
		}
	}
}


drawsymbol(x,y,n,w,type)
register float *x,*y;
int n,type;
WINDOWSPEC *w;
{
	INTPAIR ip;
	extern INTPAIR transform();
	extern int symsize;

	for(;n;n--,x++,y++)
		if(w->xl <= *x && w->xr >= *x && w->yb <= *y && w->yt >= *y){
			ip = transform(*x,*y);
			switch(type){
			case DVAL: diamond(ip.x,ip.y,symsize/2);break;
			case SVAL : square(ip.x,ip.y,symsize/2);break;
			case TVAL: triangle(ip.x,ip.y,symsize/2);break;
			}
		}
}


#define		NE	1
#define		SE	2
#define		SW	3
#define		NW	4

drawaxes(vp,win,labels_on)
DEVICEBOX *vp;
WINDOWSPEC *win;
int labels_on;
{
	float wbase,winc;
	char s[20],fx[10],fy[10];
	int vbase,vinc,i,lf = vp->lf_size;
	int ticksize = vp->ch_size/2;

	line(vp->ll.x,vp->ll.y,vp->ur.x,vp->ll.y);
	line(vp->ll.x,vp->ll.y,vp->ll.x,vp->ur.y);
	if(labels_on){
			format(fx,win->xr - win->xl,'f');
			format(fy,win->yt - win->yb,'f');
			wbase = win->xl; 
			winc = (win->xr - win->xl)/(11 - 1);
			vbase = vp->ll.x;
			vinc = (vp->ur.x - vp->ll.x)/(11 - 1);
			for(i=1;i<11;i++,wbase += winc,vbase += vinc){
				int t = (i == 6) ? 2.0*ticksize : ticksize;
				line(vbase,vp->ll.y - t,vbase,vp->ll.y + t);
				if(i == 1 || i == 6){
					sprintf(s,fx,wbase);
					elabel(vbase,vp->ll.y,s,lf,SE,vp->ch_size,vp->ch_size);
				}
			}
			line(vbase,vp->ll.y - ticksize,vbase,vp->ll.y + ticksize);
			sprintf(s,fx,wbase);
			elabel(vbase,vp->ll.y,s,lf,SW,vp->ch_size,vp->ch_size);

			wbase = win->yb; 
			winc = (win->yt - win->yb)/(11 - 1);
			vbase = vp->ll.y;
			vinc = (vp->ur.y - vp->ll.y)/(11 - 1);
			for(i=1;i<11;i++,wbase += winc,vbase += vinc){
				int t = (i == 6) ? 2.0*ticksize : ticksize;
				line(vp->ll.x - t,vbase,vp->ll.x + t,vbase);
				if(i == 1 || i == 6){
					sprintf(s,fy,wbase);
					elabel(vp->ll.x,vbase,s,lf,NE,vp->ch_size,vp->ch_size);
				}
			}
			line(vp->ll.x - ticksize,vbase,vp->ll.x + ticksize,vbase);
			sprintf(s,fy,wbase);
			elabel(vp->ll.x,vbase,s,lf,SE,vp->ch_size,vp->ch_size);
	}
}


/*
	Draw the current picture specifier. If expert mode (xpmode), use the 
	entire screen for graphics.
*/
drawscreen(pic,xpmode)
PICTURESPEC *pic;
int xpmode;
{
	short *fnum, *cnum,flist[MAXFRAMES],clist[MAXCOMP];
	DEVICEBOX currvp;
	float newx[MAXROWS],newy[MAXROWS];
	extern int setrans();
	extern PAGETYPE *pg;
	extern FRAMETYPE frame[];
	FRAMETYPE *f;
	REALPAIR shift,get_shift();
	int symbol_type,get_attribute();

	currvp = (xpmode) ? pg->screen : pg->viewport;
	setviewport(&currvp,xpmode);
	setwsize(pic);
	setrans(&pic->win,&currvp);
	drawaxes(&currvp,&pic->win,pic->flags.labels);
	expand_nlist(flist,pic->fseq);
	expand_nlist(clist,pic->cseq);
	for(fnum = flist;*fnum;fnum++)
		for(cnum = clist;*cnum;cnum++)
			if(frame[*fnum].ncol >= *cnum){
				symbol_type = get_attribute(pic->attr,*cnum);
				f = frame + *fnum;
				shift = get_shift(*fnum,*cnum);
				copy_and_shift(newx,f->head->val,f->nrow,shift.x);
				copy_and_shift(newy,(f->head + *cnum)->val,f->nrow,shift.y);
				if(pic->flags.nodes)
					drawsymbol(newx,newy,f->nrow,&pic->win,symbol_type);
				drawgraph(newx,newy,f->nrow - 1);
			}
	if(!xpmode)
		writealpha();
}
