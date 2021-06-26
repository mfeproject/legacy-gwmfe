/*
	This file is a separate program from the 2-d graphics program. It
	contains the routines which implement the graphics pre-processor.
	The pre-processor converts an ascii mfe data file to binary format.
*/
#include	<stdlib.h>
#include	<stdio.h>
#include	<strings.h>
#include	<signal.h>
#include	<ctype.h>
#include	<float.h>
#include	"defs2.h"

char tempfile[10];
FILEALFA falfa;  /* data from mfe fixed header is in this structure */

char	today[12], mfefname[BOXLLENGTH];
int 	numofedges,numofcells,numofnodes,numoframes,numofzvals;
REALBOX domain;
REALPAIR *node0;
EDGETYPE *edge0;
CELLTYPE *cell0;
INTERVAL globalz[MAXZVALS];
float	**zpp;
int 	currframe;
FRAMETYPE frm;

/* internal function prototypes */
void onintr2(int);

int main(int argc, char **argv)
{
	int status=0,quiet=0;

	if(signal(SIGINT,SIG_IGN) != SIG_IGN)
		signal(SIGINT,onintr2);
	if(argc > 1 && argv[1][0] == '-' && argv[1][1] == 'q'){
		quiet = 1;
		++argv;
		--argc;
	}
	while(argc >1){
		status=0;
		if(atob(*++argv)){
			fprintf(stderr,"%s:failed to process\n",*argv);
			remove_file(tempfile);
			status=1;
		}
		--argc;
		if(!quiet && status == 0)
			writesummary(*argv);
	}
	return status;
}


void onintr2(int signum)
{
	remove_file(tempfile);
	exit(1);
}


/* open an input file with the given name, and open a temporary output file */
openfiles(ip,op,name)
FILE **ip,**op;
char *name;
{
	FILE *fopen();

	sprintf(tempfile,"gppXXXXXX");
	if((*ip = fopen(name,"r")) == NULL)
		return 1;
	mkstemp(tempfile);
	if((*op = fopen(tempfile,"w")) == NULL){
		fclose(*ip);
		return 1;
	}
	return 0;
}


/* change fname from ascii to binary format */
atob(fname)
char *fname;
{
	int c,i=0,exstat;
	FILE *inp,*outp,*fopen();
	long index[MAXFRAMES],ia,ra;
	INTERVAL xrange,yrange,zrange[MAXFRAMES][MAXZVALS];

	if(openfiles(&inp,&outp,fname))
		return 1;
	else if((c=getw(inp)) == MAGICNUM){
		fclose(inp);
		fclose(outp);
		remove_file(tempfile);
		return 0; /* already binary */
	}
	rewind(inp);
	zeroindex(index);
	writeword(outp,0,HEADERSIZE);
	setranges(&xrange,&yrange,zrange);
	if(movestring(inp,outp,4))
		return 1;
	if(fscanf(inp,"%d",&numofzvals) != 1)
		return 1;
	if(movestring(inp,outp,numofzvals))
		return 1;
	if(fscanf(inp,"%d %d %d",&numofnodes,&numofedges,&numofcells) != 3)
		return 1;
	allocmem();
	if(moveedgelist(inp,outp,numofedges))
		return 1;
	if(movecelllist(inp,outp,numofcells))
		return 1;
	while((c= getc(inp)) != EOF){
		ungetc(c,inp);
		index[i]= ftell(outp);
		if(moveframe(inp,outp,numofnodes,numofzvals,&xrange,&yrange,zrange[i]))
			return 1;
		i++;
		while((c= getc(inp)) == '\n') {/* skip extra newlines */}
		ungetc(c,inp);
	}
	numoframes= i;
	ia= ftell(outp);
	writeindex(outp,index);
	ra= ftell(outp);
	writeranges(outp,&xrange,&yrange,zrange,numoframes,numofzvals);
	writeheader(outp,numofnodes,numofedges,numofcells,numofzvals,numoframes,ia,ra);
	fclose(inp);
	fclose(outp);
	deallocmem();
	exstat=rename_file(tempfile,fname);
	return(exstat);
}


zeroindex(ip)
long *ip;
{
	int i;

	for(i=0;i<MAXFRAMES;i++)
		ip[i]= 0;
}


/* write n machine words onto stdout */
writeword(fp,w,n)
FILE *fp;
int w,n;
{
	while(n--)
		putw(w,fp);
}


/* set initial values for z-ranges */
setranges(x,y,z)
INTERVAL *x,*y,z[][MAXZVALS];
{
	int i,j;

	x->lo= y->lo= FLT_MAX;
	x->hi= y->hi= -FLT_MAX;
	for(i=0;i<MAXFRAMES;i++)
		for(j=0;j<MAXZVALS;j++){
			z[i][j].lo= FLT_MAX;
			z[i][j].hi= -FLT_MAX;
		}
}


/* move n newline terminated strings from input to output */
movestring(ip,op,n)
FILE *ip,*op;
int n;
{
	char c;

	while(n--){
		while((c= getc(ip)) == '\n') {/* skip extra newlines */}
		putc(c,op);
		while((c= getc(ip)) != '\n'){
			if(!isascii(c)) /* not portable to non-ascii systems */
				return 1;
			putc(c,op);
		}
		putc(c,op);
	}
	return(0);
}


/* move an edge list of length n from input to output */
moveedgelist(ip,op,n)
FILE *ip,*op;
int n;
{
	EDGETYPE *ep;

	for(ep= edge0;ep<edge0 + n;ep++)
		if(fscanf(ip,"%hd %hd",&ep->tail,&ep->head) != 2)
			return 1;
	fwrite(edge0,sizeof(EDGETYPE),n,op);
	return(0);
}


/* move a cell list of length n from input to output */
movecelllist(ip,op,n)
FILE *ip,*op;
int n;
{
	CELLTYPE *cp;
	
	for(cp= cell0;cp<cell0 +n;cp++)
		if(fscanf(ip,"%hd %hd %hd",&cp->v0,&cp->v1,&cp->v2) != 3)
			return 1;
	fwrite(cell0,sizeof(CELLTYPE),n,op);
	return(0);
}



moveframe(ip,op,n,j,x,y,z)
FILE *ip,*op;
int n,j;
INTERVAL *x,*y,z[];
{
	int i;
	float *flp,f;
	REALPAIR *np;

	if(fscanf(ip,"%f",&f) != 1)
		return 1;
	fwrite(&f,sizeof(float),1,op);
	if(movestring(ip,op,4))
		return 1;
	for(np= node0;np<node0 + n;np++){
		if(fscanf(ip,"%f %f",&np->x,&np->y) != 2)
			return 1;
		compare(np->x,x);
		compare(np->y,y);
		for(i=0;i<j;i++){
			if(fscanf(ip,"%f",flp= *(zpp+i)+(np-node0)) != 1)
				return 1;
			compare(*flp,&z[i]);
		}
	}
	fwrite(node0,sizeof(REALPAIR),n,op);
	for(i=0;i<j;i++)
		fwrite(zpp[i],sizeof(float),n,op);
	return(0);
}


compare(v,i)
double v;
INTERVAL *i;
{
	if(v < i->lo)
		i->lo= v;
	if(v > i->hi)
		i->hi= v;
}


writeindex(op,i)
FILE *op;
long *i;
{
	while(*i){
		fwrite(i,sizeof(long),1,op);
		i++;
	}
}


writeranges(op,x,y,z,n,nzs)
FILE *op;
INTERVAL *x,*y,z[][MAXZVALS];
int n,nzs;
{
	int i,j;

	fwrite(&x->lo,sizeof(float),1,op);
	fwrite(&x->hi,sizeof(float),1,op);
	fwrite(&y->lo,sizeof(float),1,op);
	fwrite(&y->hi,sizeof(float),1,op);
	for(i=0;i<n;i++)
		for(j=0;j<nzs;j++){
			fwrite(&z[i][j].lo,sizeof(float),1,op);
			fwrite(&z[i][j].hi,sizeof(float),1,op);
		}
}


writeheader(op,n,e,c,z,f,i,r)
FILE *op;
int n,e,c,z,f;
long i,r;
{
	rewind(op);
	putw(MAGICNUM,op);
	putw(n,op);
	putw(e,op);
	putw(c,op);
	putw(z,op);
	putw(f,op);
	fwrite(&i,sizeof(long),1,op);
	fwrite(&r,sizeof(long),1,op);
}


writesummary(name)
char *name;
{
	float times[MAXFRAMES];
	INTERVAL x,y,z[MAXFRAMES][MAXZVALS],gz[MAXZVALS];
	FILE *fp;
	long index[MAXFRAMES];

	fp= fopen(name,"r");
	getstats(fp,&x,&y,z,index);
	getfrmtimes(fp,times,numoframes,index);
	getgranges(z,gz,numoframes,numofzvals);
	writeintro(fp,name);
	writetimes(times,numoframes);
	writegranges(fp,x,y,gz,numofzvals);
	writefranges(z,numoframes,numofzvals);
}


getstats(fp,x,y,z,i)
FILE *fp;
INTERVAL *x,*y,z[][MAXZVALS];
long *i;
{
	int j;

	fseek(fp,(long)sizeof(int),0);
	numofnodes= getw(fp);
	numofedges= getw(fp);
	numofcells= getw(fp);
	numofzvals= getw(fp);
	numoframes= getw(fp);
	fseek(fp,(long)getw(fp),0);
	fread(i,sizeof(long),numoframes,fp);
	fread(x,sizeof(INTERVAL),1,fp);
	fread(y,sizeof(INTERVAL),1,fp);
	for(j=0;j<numoframes;j++)
		fread(z[j],sizeof(INTERVAL),numofzvals,fp);
}


getfrmtimes(fp,t,n,i)
FILE *fp;
float *t;
int n;
long i[];
{
	int j;

	for(j=0;j<n;j++){
		fseek(fp,(long)i[j],0);
		fread(t+j,sizeof(float),1,fp);
	}
}


getgranges(z,gz,f,nz)
INTERVAL z[][MAXZVALS],gz[];
int f,nz;
{
	int i,j;

	for(j=0;j<nz;j++)
		gz[j]= z[0][j];
	for(i=1;i<f;i++)
		for(j=0;j<nz;j++){
			if(z[i][j].lo < gz[j].lo)
				gz[j].lo = z[i][j].lo;
			if(z[i][j].hi > gz[j].hi)
				gz[j].hi = z[i][j].hi;
		}
}


writeintro(fp,name)
FILE *fp;
char *name;
{
	printf("%s\n",name);
	fseek(fp,(long)sizeof(int)*HEADERSIZE,0);
	movestring(fp,stdout,4);
	printf("\n");
}


writetimes(t,n)
float *t;
int n;
{
	int i,nl= (n+2)/3;

	printf("\t\tTime information frame by frame\n");
	printf("frame    time        frame    time        frame    time\n");
	for(i=1;i<=nl;i++){
		printf(" %2d   %10.3e      ",i,t[i-1]);
		if(i+nl <= n)
			printf("%2d   %10.3e      ",i+nl,t[i+nl-1]);
		if(i+2*nl <= n)
			printf("%2d   %10.3e\n",i+2*nl,t[i+2*nl-1]);
		else
			printf("\n");
	}
	printf("\n");
}


writegranges(fp,x,y,gz,nz)
FILE *fp;
INTERVAL x,y,gz[];
int nz;
{
	char zdesc[MAXZVALS][20],*cp;
	int i;

	for(i=0;i<nz;i++){
		cp= zdesc[i];
		while((*cp= getc(fp)) != '\n')
			++cp;
		*cp= '\0';
	}
	printf("*\t*\t*\t*\t*\t*\t*\n");
	printf("\tRange information for the entire file\n");
	printf("xrange:\t\t\t%10.3e to %10.3e\n",x.lo,x.hi);
	printf("yrange:\t\t\t%10.3e to %10.3e\n",y.lo,y.hi);
	for(i=1;i<=nz;i++)
		printf("z%d:(%.14s)\t%10.3e to %10.3e\n",i,zdesc[i-1],gz[i-1].lo,gz[i-1].hi);
	printf("\n");
}


writefranges(z,n,nz)
INTERVAL z[][MAXZVALS];
int n,nz;
{
	int i,j;

	printf("\tRange information frame by frame\nFrame\n");
	for(i=1;i<=n;i++){
		printf("  %d",i);
		for(j=1;j<=nz;j++){
			printf("\tz%d:%10.3e to %10.3e",j,z[i-1][j-1].lo,z[i-1][j-1].hi);
			printf(j%2 ? "\b" : "\n");
		}
		printf(nz%2 ? "\n\n" : "\n");
	}
}
