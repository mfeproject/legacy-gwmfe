#include	"switches.h"
#include	"defs1.h"
#include	"init1.h"

/*
	Write out the current picture specifier and associated information.
*/
writepicspec(pic,plspec)
PICTURESPEC *pic;
PLOTSPEC *plspec;
{
	WINDOWSPEC   *w= &pic->win;
	short *fptr,*cptr;
	int i,n;
	char *sp[20];
	FILE *openplot();
	extern FILE *pfp;
	
	if(pfp == NULL)
		pfp = openplot();
	for(fptr=pic->fseq;*fptr;++fptr)
		fprintf(pfp," %d",(int)*fptr);
	fprintf(pfp,"\n");
	for(cptr=pic->cseq;*cptr;++cptr)
		fprintf(pfp," %d",(int)*cptr);
	fprintf(pfp,"\n");
	fprintf(pfp,"%hd %hd %hd %hd\n",pic->flags.nodes,pic->flags.autox,pic->flags.autoy,pic->flags.labels);
	fprintf(pfp,"%g %g %g %g\n",w->xl,w->xr,w->yb,w->yt);
	i = collect_attributes(pic,sp);
	fprintf(pfp,"%d\n",i);
	for(n=0;n<i;n++)
		fprintf(pfp,"%s\n",sp[n]);
	fprintf(pfp,"%d %.2f\n",plspec->format,plspec->size);
}


#define		MINSIZE1	3.5
#define		MAXSIZE1	14.0
#define		MINSIZE2	5.25
#define		MAXSIZE2	21.0
#define		MINSIZE3	10.0
#define		MAXSIZE3	21.0
#define		MINSIZE4	3.5
#define		MAXSIZE4	7.0
#define		MINSIZE5	3.5
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
#ifndef NOPLOT
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
	
#else
	fprintf(stderr,"command not implemented\n");
#endif
}


/*
	Set the window x-range or y-range.
*/
setwindow(pic,axis,size,flag)
PICTURESPEC *pic;
INTERVAL *size;
int axis,flag;
{
	if(axis == 0){ /* x-axis */
		pic->flags.autox = (flag == 0);
		if(flag == 1 || flag == 3)
			pic->win.xl = size->lo;
		if(flag == 2 || flag == 3)
			pic->win.xr = size->hi;
	}else{ /* y-axis */
		pic->flags.autoy = (flag == 0);
		if(flag == 1 || flag == 3)
			pic->win.yb = size->lo;
		if(flag == 2 || flag == 3)
			pic->win.yt = size->hi;
	}
}


copy_nlist(tp,sp,ubnd)
short *tp,*sp;
int ubnd;
{
	while(*sp)
		if(*sp > ITEM_OFFSET){ /* have a solitary entry */
			*tp++ = min(ubnd + ITEM_OFFSET,*sp);
			++sp;
		}else{ /* have the left end of range of values */
			*tp++ = min(ubnd,*sp); /* copy left end */
			++sp;
			*tp++ = min(ubnd,*sp); /* copy right end */
			++sp;
			*tp++ = min(ubnd,*sp); /* copy stepsize */
			++sp;
		}
	*tp = (short)0;
}


bump_nlist(nlp,step)
short *nlp;
int step;
{
	extern int numoframes;

	while(*nlp)
		if(*nlp > ITEM_OFFSET)
			*nlp++ = min(numoframes + ITEM_OFFSET,max(1 + ITEM_OFFSET,*nlp + step));
		else{
			*nlp++ = min(numoframes,max(1,*nlp + step));
			*nlp++ = min(numoframes,max(1,*nlp + step));
			++nlp;
		}
}


closeplot()
{
	extern FILE *pfp;

	if(pfp != NULL)
#ifdef PIPEPLOT
		pclose(pfp);
#else
		fclose(pfp);
#endif
	pfp = NULL;
}


FILE *
openplot()
{
	char *plotprog = "gplot1",comm[200];
        int emktemp();
	FILE *epopen(),*efopen(),*pfp;
	extern char argfiles[];

#ifdef PIPEPLOT
	sprintf(comm,"%s %s",plotprog,argfiles);
	pfp = epopen(comm,"w");
#else
#ifdef FILEPLOT
	sprintf(comm,"%s","pl?XXXXXX");
	emktemp(comm);
	strcat(comm,".apf");
	pfp = efopen(comm,"w");
#else
	pfp = efopen("/dev/null","w");
#endif
#endif
	return pfp;
}


/*	Called when the user wishes to change the current input file(s). */
restart(files)
char *files;
{
	extern FILE *pfp;
	extern int numofiles,numoframes;
	int count;
	char *flist[MAXFILES];
	extern FRAMETYPE frame[];

	count = re_format(files,flist);
	if(check_access(count,flist)){
		closepl();
		fprintf(stderr,"file list unchanged\n");
		return 0;
	}else{
		closeplot();
		deallocmem(frame + 1,numoframes);
		openpl();
		erase();
		space();
		closepl();
		initialize(numofiles = count,flist,stdout);
		return 1;
	}
}


/*	Build an array of pointers in "flist" which point to the individual
	words in "files". Make the words terminate with the null character.
*/
re_format(files,flist)
char *files,*flist[];
{
	int count = 0;
	char *cp = files;

	while(*cp == ' ' || *cp == '\t') ++cp;
	while(*cp){
		flist[count++] = cp;
		while(*cp != ' ' && *cp != '\t' && *cp != '\0') ++cp;
		if(*cp != '\0')
			*cp++ = '\0';
		while(*cp == ' ' || *cp == '\t') ++cp;
	}
	flist[count] = NULL;
	return count;
}


