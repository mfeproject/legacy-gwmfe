/*
	This file contains general utility routines used in several of the
	other files.
*/
#include	<stdio.h> 
#include	<stdlib.h>
#include	<strings.h>
#include	"defs2.h"

extern int 	currframe;
extern FRAMETYPE frm;
long   indexadd,rangeadd;

/*
	Read global mfe data into several variables and structures.
*/
readgdata(fp)
FILE *fp;
{
	int j;

	fseek(fp,(long)sizeof(int),0);
	fread(&numofnodes,sizeof(int),1,fp);
	fread(&numofedges,sizeof(int),1,fp);
	fread(&numofcells,sizeof(int),1,fp);
	fread(&numofzvals,sizeof(int),1,fp);
	fread(&numoframes,sizeof(int),1,fp);
	fread(&indexadd,sizeof(long),1,fp);
	fread(&rangeadd,sizeof(long),1,fp);
	getstring(falfa.title,BOXLLENGTH,fp);
	getstring(falfa.date,BOXLLENGTH,fp);
	getstring(falfa.vercpu,BOXLLENGTH,fp);
	getstring(falfa.op,BOXLLENGTH,fp);
	for(j=0;j<numofzvals;j++)
		getstring(falfa.z[j],BOXLLENGTH,fp);
	allocmem();
	fread(edge0 +1,sizeof(EDGETYPE),numofedges,fp);
	fread(cell0 +1,sizeof(CELLTYPE),numofcells,fp);
	fseek(fp,rangeadd,0);
	fread(&domain.ll.x,sizeof(float),1,fp);
	fread(&domain.ur.x,sizeof(float),1,fp);
	fread(&domain.ll.y,sizeof(float),1,fp);
	fread(&domain.ur.y,sizeof(float),1,fp);
}


/*
	Read at most "n" bytes from the file "fp" into the string "s", stopping
	if a newline is encountered. If n bytes are read first, advance the 
	file pointer until the next newline character, throwing away the 
	intervening characters.
*/
getstring(s,n,fp)
char *s;
int n;
FILE *fp;
{
	int c;

	while((c= getc(fp)) == '\n' || c == ' ' || c == '\t')
		;
	ungetc(c,fp);
	while((c= getc(fp)) != '\n' && c != EOF && n>0){
		*s++ = c;
		n--;
	}
	*s = '\0';
	while(n == 0 && c != '\n' && c != EOF)
		c= getc(fp);
}


/*
	Read a single frame numbered "fnum" from the mfe data file "fp".
*/
readframe(fp,fnum)
FILE *fp;
int fnum;
{
	int i;
	long zadd,frameadd;

	currframe= fnum;
	fseek(fp,(long)(indexadd + sizeof(long)*(fnum-1)),0);
	fread(&frameadd,sizeof(long),1,fp);
	fseek(fp,frameadd,0);
	fread(&frm.t,sizeof(float),1,fp);
	getstring(frm.lastep,BOXLLENGTH,fp);
	getstring(frm.maxstep,BOXLLENGTH,fp);
	getstring(frm.cputime,BOXLLENGTH,fp);
	getstring(frm.isteps,BOXLLENGTH,fp);
	fread(node0+1,sizeof(REALPAIR),numofnodes,fp);
	for(i=0;i<numofzvals;i++)
		fread(*(zpp + i)+1,sizeof(float),numofnodes,fp);
	zadd = rangeadd+sizeof(REALBOX)+(fnum-1)*numofzvals*sizeof(INTERVAL); 
	fseek(fp,zadd,0);
	fread(frm.z,sizeof(INTERVAL),numofzvals,fp);
}


/*	Find the "even" contour interval nearest the approximate interval.
*/
double
getcontint(appxint)
double appxint;
{

#define nearest(a,b,x)  (abs(x-a) < abs(b-x)) ? a:b

	double	cint=1.0;

	if(appxint == 0.0)
		return 1.0;
	for(;;)
		if(cint >= appxint)
			if((cint *= 0.5) >= appxint)
				if((cint *= 0.5) >= appxint)
					cint *= 0.4;
				else
					return nearest(cint,cint*2.0,appxint);
			else
				return nearest(cint,cint*2.0,appxint);
		else if((cint *= 2.5) <= appxint)
			if((cint *= 2.0) <= appxint)
				cint *= 2.0;
			else
				return nearest(cint*0.5,cint,appxint);
		     else
			return nearest(cint*0.4,cint,appxint);
}


#define		VLDV	2.0

getvectlength(v)
VECTORSPEC *v;
{
	v->vlength= VLDV;
}


/*
	Allocate memory, checking for errors.
*/
void *
emalloc(n)
unsigned n;
{
	void *p;

	if((p= malloc(n)) == NULL){
		fprintf(stderr,"out of memory, %d bytes requested\n",n);
		exit(1);
	}
	return(p);
}


/*
	Allocate memory for the edge list, cell list, node list, and z-value
	list.
*/
allocmem()
{
	int i;

	edge0 = (EDGETYPE *)emalloc((unsigned)(numofedges*sizeof(EDGETYPE)+1));
	cell0 = (CELLTYPE *)emalloc((unsigned)(numofcells*sizeof(CELLTYPE)+1));
	node0 = (REALPAIR *)emalloc((unsigned)(numofnodes*sizeof(REALPAIR)+1));
	zpp = (float **)emalloc((unsigned)(numofzvals*sizeof(float *)));
	for(i=0;i<numofzvals;i++)
		*(zpp+i) = (float *)emalloc((unsigned)(numofnodes*sizeof(float)+1));
}


deallocmem()
{
	int i;

	if(node0 != NULL){
		for(i=0;i<numofzvals;i++)
			free((char *)(*(zpp+i)));
		free((char *)zpp);
		free((char *)node0);
		free((char *)cell0);
		free((char *)edge0);
	}
}


/*
	Pack the picture flags into a single unsigned integer.
*/
unsigned
flagcode(f)
PICFLAGS f;
{
	unsigned i=0;

	i+=f.vect;
	i<<=1;
	i+=f.grid;
	i<<=1;
	i+=f.dotgrid;
	i<<=1;
	i+=f.contflag;
	i<<=1;
	i+=f.window;
	i<<=1;
	i+=f.xsect;
	i<<=1;
	i+=f.openxs;
	return(i);
}


int
emktemp(name)
char *name;
{
	static char x = 'a';
	char *p = name;

	while(*p != '?')
		++p;
	*p = x++;
	return mkstemp(name);
}
