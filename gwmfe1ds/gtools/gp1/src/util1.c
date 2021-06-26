#include        <stdlib.h>
#include	<sys/file.h>
#include        <string.h>
#include	"defs1.h"
#include	"init1.h"
/*#include	<unistd.h>*/


/*
	Allocate n bytes of memory. Check for and exit upon error.
*/
void *emalloc(n)
unsigned n;
{
	char *p;

	if((p= malloc(n)) == NULL){
		fprintf(stderr,"out of memory, %d bytes requested\n",n);
		exit(1);
	}
	return(p);
}


copy_and_shift(tar,sou,n,offset)
register int n;
register float *tar,*sou,offset;
{
	if(offset == 0.0)
		while(n--)
			*tar++ = *sou++;
	else
		while(n--)
			*tar++ = *sou++ + offset;
}


/*
	Make a copy of an array
*/
arrcpy(target,source)
short *target,*source;
{
	while(*target++ = *source++)
		;
}


/*
	Draw the outline of the given box.
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


/*
	Given an x,y coordinate pair, a label 's', a linefeed size,
	a quadrant code (1-4), and a character width and height,
	compute the location of a string label.
*/
#define		NE	1
#define		SE	2
#define		SW	3
#define		NW	4
elabel(x,y,s,line_feed,quadrant,char_width,char_height)
int x,y,line_feed,quadrant,char_width,char_height;
char *s;
{
	INTPAIR p;
	int xshift = 0,yshift = 0,char_space = line_feed - char_height;

	switch(quadrant){
	case NE		:xshift = char_width*0.6;
			 yshift = char_space/2;
			 break;
	case SE		:xshift = char_width*0.6;
			 yshift = -char_space - char_height;
			 break;
	case SW		:xshift = -strlen(s)*char_width;
			 yshift = -char_space - char_height;
			 break;
	case NW		:xshift = -strlen(s)*char_width ;
			 yshift = char_space/2;
			 break;
	default		:break;
	}
	p.x = x + xshift;
	p.y = y + yshift;
	move(p.x,p.y);
	label(s);
}


/*
	Check the given list of files for proper number and read accessibility.
*/
check_access(argc,argv)
int argc;
char *argv[];
{
	int errstat = 0;

	if(argc == 0){
		errstat = 1;
		fprintf(stderr,"usage: gp1 file1 ...\n");
	}else if(argc > MAXFILES){
		errstat = 1;
		fprintf(stderr,"too many file names in argument list\n");
	}
	while(argc--)
		if(can_access(*argv++,R_OK)){
			errstat = 1;
			fprintf(stderr,"can't open %s for reading\n",argv[-1]);
		}
	return errstat;
}


set_attribute(alist,index,ntype)
ATTRIBUTE *alist;
int index,ntype;
{
	int i;

	for(i=0;i<MAXATTR;i++){
		if(alist[i].index == 0)
			alist[i].index = index;
		if(alist[i].index == index){
			if((alist[i].nodetype = ntype) == DVAL) /* default */
				alist[i].index = 0;
			break;
		}
	}
}


get_attribute(alist,index)
ATTRIBUTE *alist;
int index;
{
	int i;

	for(i=0;i<MAXATTR;i++)
		if(alist[i].index == index)
			return alist[i].nodetype;
	return DVAL; /* default */
}


REALPAIR
get_shift(f,c)
int f,c;
{
	REALPAIR r;
	extern REALPAIR fshift[],cshift[];

	r.x = fshift[f].x + cshift[c].x;
	r.y = fshift[f].y + cshift[c].y;
	return r;
}


expand_nlist(expanded_list,nlp)
short *expanded_list,*nlp;
{
	short left,right,step;

	while(*nlp)
		if(*nlp > ITEM_OFFSET) /* solitary entry */
			*expanded_list++ = *nlp++ - ITEM_OFFSET;
		else{ /* entry is left end of a range of values */
			left = *nlp++;
			right = *nlp++;
			step = *nlp++;
			for(;left<right;left += step)
				*expanded_list++ = left;
			*expanded_list++ = right;
		}
	*expanded_list = (short)0;
}


char *
print_nlist(nlp)
short *nlp;
{
	static char s[80],s1[10];

	*s = '\0';
	while(*nlp)
		if(*nlp > ITEM_OFFSET){
			sprintf(s1," %d",*nlp++ - ITEM_OFFSET);
			strcat(s,s1);
		}else{
			sprintf(s1," %d-%d",*nlp,nlp[1]);
			nlp += 2;
			strcat(s,s1);
			if(*nlp++ != 1){
				sprintf(s1,"(%d)",nlp[-1]);
				strcat(s,s1);
			}
		}
	return s;
}

collect_attributes(pic,bp)
PICTURESPEC *pic;
char *bp[];
{
	int a,i = 0;
	extern REALPAIR fshift[],cshift[];
	static char buf[200];
	short clist[MAXCOMP],*cp,flist[MAXFRAMES],*fp;

	bp[0] = buf;
	expand_nlist(clist,pic->cseq);
	expand_nlist(flist,pic->fseq);
	for(fp = flist;*fp;fp++)
		if(fshift[*fp].x != 0.0 || fshift[*fp].y != 0.0){
			sprintf(bp[i++],"f%d shift %.2g %.2g",*fp,fshift[*fp].x,fshift[*fp].y);
			bp[i] = bp[i-1] + strlen(bp[i-1]) + 1;
		}
	for(cp = clist;*cp;cp++){
		if((a = get_attribute(pic->attr,*cp)) != DVAL){
			sprintf(bp[i++],"c%d: %s",*cp,a == SVAL ? "squares" : "triangles");
			bp[i] = bp[i-1] + strlen(bp[i-1]) + 1;
		}
		if(cshift[*cp].x != 0.0 || cshift[*cp].y != 0.0){
			sprintf(bp[i++],"c%d shift %.2g %.2g",*cp,cshift[*cp].x,cshift[*cp].y);
			bp[i] = bp[i-1] + strlen(bp[i-1]) + 1;
		}
	}
	bp[i] = NULL;
	return i;
}


deallocmem(fp,n)
FRAMETYPE *fp;
int n;
{
	for(;n;n--,fp++){
		free((char *)fp->head->val);
		free((char *)fp->head);
	}
}


int emktemp(name)
char *name;
{
	static char x = 'a';
	char *p = name;

	while(*p != '?')
		++p;
	*p = x++;
	return mkstemp(name);
}


setviewport(vp,xp)
DEVICEBOX *vp;
int xp;
{
	vp->ll.y += 4*vp->ch_size;
	if(xp){ /* decrease viewport size just a little bit */
		vp->ll.x += vp->ch_size;
		vp->ur.x -= vp->ch_size;
		vp->ur.y -= vp->ch_size;
	}
}


save_argv(av,af)
char *av[],*af;
{
	while(*av){
		strcat(af,*av++);
		if(*av)
			strcat(af," ");
	}
}


format(s,d,t)
char *s,t;
double d;
{
	int i;

	i = (int)floor(log10(d));
	i = (i > 0) ? 1 : -i + 2;
	sprintf(s,"%%.%d%c",i,t);
}
