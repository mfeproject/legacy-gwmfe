/*
	This program removes selected frames from an ascii mfe1d datafile or
	a binary mfe2d datafile, or catenates together several files, or both.
*/
#include        <stdlib.h>
#include	<stdio.h>
#include	<signal.h>
#include	<strings.h>
#include	<ctype.h>
#include	<sys/file.h>
#include	<unistd.h>

#define		ALLOTHER	0
#define		WHITESPACE	1
#define		FLOATCHAR	2
#define		max(a,b)	(((a)>(b)) ? (a):(b))
#define		MAXFRAMES	500
#define		MAXFILES	50

char *tf1 = "cats1XXXXXX", *tf2 = "cats2XXXXXX", char_class[128];

/* internal function prototypes */
void onintr(int);

int main(int argc, char **argv)
{
  	int filetype;
	char *filelist[MAXFILES],*framelist[MAXFILES];

	init_char_classes();
	separate_args(argv,filelist,framelist);
	if(*filelist == NULL)
		error("usage: %s [framelist] file [file ...] > nufile\n",*argv);
	if((filetype = gettype(*filelist)) == 0)
		error("unrecognized file type\n",*filelist);
	if(signal(SIGINT,SIG_IGN) != SIG_IGN)
		signal(SIGINT,&onintr);
	mkstemp(tf1);
	build1(tf1,filelist,filetype);
	if(*framelist == NULL){
		emit_file(tf1);
		unlink(tf1);
		return 0;
	}
	mkstemp(tf2);
	build2(tf1,tf2,framelist,filetype);
	unlink(tf1);
	emit_file(tf2);
	unlink(tf2);
	return 0;
}


/*	The array "char_class" is used by "mygetline()" to classify the
	successive lines of the input files as numeric or non-numeric.
*/
init_char_classes()
{
	int i;

	char_class['-'] = char_class['+'] = char_class['.'] = char_class['e'] = char_class['E'] = FLOATCHAR;
	for(i='0';i<= '9';i++)
		char_class[i] = FLOATCHAR;
	for(i=8;i<=13;i++)
		char_class[i] = WHITESPACE;
	char_class[' '] = WHITESPACE;
}


/*
	Separate the argument list into a list of files and a list of frame
	numbers. Note that every argument is checked first to see if it is a
	readable filename. If not, then it is checked to see if it starts with
	a digit. Otherwise, there is a fatal error.
*/
separate_args(argv,filelist,frmlist)
char *argv[],*filelist[],*frmlist[];
{
	while(*++argv)
		if(access(*argv,R_OK) == 0)
			*filelist++ = *argv;
		else if(isdigit(**argv))
			*frmlist++ = *argv;
		else
			error("%s: bad argument\n",*argv);
	*filelist = *frmlist = NULL;
}


/*
	Determine whether the given file name is an mfe2d binary file, an
	mfe1d ascii file, or something else. Note that any ascii file will be
	found to be mfe1d.
*/
gettype(fname)
char *fname;
{
	FILE *fp,*efopen();
	int size,i;
	char buff[1024],*cp = buff;

	fp = efopen(fname,"r");
	size = fread(buff,1,1024,fp);
	if(*(int *)cp == 0250)
		return 2;
	for(i=0;i<size;i++)
		if(!isascii(*cp++))
			return 0;
	return 1;
}


/*
	Build the first temporary file, consisting of the concatenation of all
	the file arguments.
*/
build1(outfile,flist,type)
char *outfile,*flist[];
int type;
{
	register int c;
	int h[6],h1[6],i,fsize,rts;
	FILE *ip,*op,*efopen();
	long a[2],index[MAXFRAMES],hl = 6*sizeof(int) + 2*sizeof(long),
		newindex[MAXFRAMES],*nip = newindex;
	char *buffer,*emalloc();
	float rangetable[MAXFRAMES],*rtp = rangetable;

	op = efopen(outfile,"w");
	if(type == 1) /* mfe1d ascii files */
		while(*flist){
			if(gettype(*flist) != 1)
				error("%s: expected 1D file\n",*flist);
			ip = efopen(*flist,"r");
			while((c = getc(ip)) != EOF)
				putc(c,op);
			fclose(ip);
			++flist;
		}
	else{ /* mfe2d binary files */
		ip = efopen(*flist,"r");
		fread(h1,sizeof(int),6,ip); /* read the first header */
		fwrite(h1,sizeof(int),6,op); /* write same */
		fread(a,sizeof(long),2,ip); /* read index addresses */
		fwrite(a,sizeof(long),2,op); /* write same */
		fseek(ip,a[0],0); /* seek to the index table */
		fread(index,sizeof(long),h1[5],ip); /* read index table */
		fread(rtp,sizeof(float),4,ip); /* read domain values */
		rtp += 4;
		fseek(ip,hl,0); /* seek to start of string list */
		buffer = emalloc((unsigned)max(index[0],100+index[1]-index[0]));
		fread(buffer,1,index[0] - hl,ip); /* read strings, edge list and cell list */
		fwrite(buffer,1,index[0] - hl,op); /* write same */
		fclose(ip); /* close first file */
		h1[5] = 0; /* set total frames to zero */
		while(*flist){ /* read each file, including the first */
			if(gettype(*flist) != 2)
				error("%s: expected 2D file\n",*flist);
			ip = efopen(*flist,"r");
			fread(h,sizeof(int),6,ip); /* read header */
			rts = 2*h[5]*h[4]; /* compute range table size */
			fread(a,sizeof(long),2,ip); /* read index addresses */
			h1[5] += h[5]; /* increment total frames read */
			if(h1[1] != h[1] || h1[2] != h[2] || h1[3] != h[3] || h1[4] != h[4])
				error("%s: topological mis-match\n",*flist);
			fseek(ip,a[0],0); /* seek to the index table */
			fread(index,sizeof(long),h[5],ip); /* read index */
			fseek(ip,(long)(4*sizeof(float)),1); /* seek past the domain values */
			fread(rtp,sizeof(float),rts,ip); /* read range table */
			rtp += rts; /* move up the range table pointer */
			fseek(ip,index[0],0); /* seek to frame 1 */
			for(i=0;i< h[5];i++){ /* for each frame in file */
				fsize = (i == h[5] - 1) ? a[0] - index[i] : index[i+1] - index[i];
				fread(buffer,1,fsize,ip); /* read frame */
				*nip++ = ftell(op); /* record the address of the frame in output file */
				fwrite(buffer,1,fsize,op); /* write frame */
			}
			fclose(ip);
			++flist;
		}
		a[0] = ftell(op); /* record address of index table */
		fwrite(newindex,sizeof(long),h1[5],op); /* write index table */
		a[1] = ftell(op); /* record address of range table */
		fwrite(rangetable,sizeof(float),rtp-rangetable,op); /* write */
		rewind(op); /* seek to beginning of output file */
		fwrite(h1,sizeof(int),6,op); /* write new header */
		fwrite(a,sizeof(long),2,op); /* write new index addresses */
		free(buffer);
	}
	fclose(op);
}


/*	Open the given file and put it onto stdout */
emit_file(fname)
char *fname;
{
	FILE *fp,*efopen();
	register int c;

	fp = efopen(fname,"r");
	while((c = getc(fp)) != EOF)
		putc(c,stdout);
}


/*
	Scan an mfe1d file, recording the address of each frame, and counting
	frames. The boolean variable "pin" means "previous line is numeric";
	and "cin" means "current line is numeric".
*/
pass_one(fp,ftable)
FILE *fp;
long *ftable;
{
	long *p = ftable;
	int oldwordcount = -1, done = 0,pin = 1,cin,wordcount;

	while(!done){
		*p = ftell(fp);
		wordcount = mygetline(&cin,&done,fp);
		if(pin)
			if(cin){
				if(wordcount != oldwordcount) ++p;
			}else if(!done || wordcount != 0) ++p;
		pin = cin;
		oldwordcount = wordcount;
	}
	*p = ftell(fp);
	return p - ftable;
}


/*	Get a single line from the input. Determine if the line is numeric
	or not, and determine if end of file has been reached.
*/
mygetline(is_num,is_done,fp)
int *is_num,*is_done;
FILE *fp;
{
	register int c,state = 0,wcnt = 0;

	*is_num = 1;
	while((c = getc(fp)) ==  ' ' || c == '\t'){ /* skip white space */ }
	while(c != '\n' && c != EOF){
		switch(char_class[c]){
		case WHITESPACE		:state = 0;break;
		case ALLOTHER		:*is_num = 0;
		case FLOATCHAR		:if(state == 0){
						state = 1;
						++wcnt;
					 }
					 break;
		}
		c = getc(fp);
	}
	*is_done = (c == EOF);
	if(wcnt == 0)
		*is_num = 0;
	return wcnt;
}


/*
	Verify that the list of frames is sensible. Count the number of frames
	to be deleted.
*/
check_list(lp,frp,hibnd)
int *frp,hibnd;
char *lp[];
{
	int n,l,r,count = 0;

	for(;*lp;++lp){
		if(sscanf(*lp,"%d-%d",&l,&r) != 2)
			if(sscanf(*lp,"%d",&n) != 1)
				error("%s: garbled argument\n",*lp);
			else
				count += mark_frame(n,frp,hibnd);
		else if(l>r)
				error("%s: garbled argument\n",*lp);
		else
			for(n=l;n<=r;n++)
				count += mark_frame(n,frp,hibnd);
	}
	return(hibnd - count);
}


/*
	Mark the appropriate frame number in the boolean array "frp". A '0'
	means that the frame will be killed; a '1' means that the frame will
	be saved.
*/
mark_frame(fnum,frp,maxfnum)
int fnum,*frp,maxfnum;
{
	if(fnum < 1 || fnum > maxfnum){
		fprintf(stderr,"%d: argument out of bounds, ignored\n",fnum);
		return 0;
	}else if(frp[fnum - 1]){
		fprintf(stderr,"%d: duplicate argument\n",fnum);
		return 0;
	}else{
		frp[fnum-1] = 1;
		return 1;
	}
}


/* Report error condition and exit */
error(s1,s2)
char *s1,*s2;
{
	unlink(tf1);
	unlink(tf2);
	fprintf(stderr,s1,s2);
	exit(1);
}


void onintr(int signum)
{
	unlink(tf1);
	unlink(tf2);
	exit(1);
}


FILE *
efopen(name,mode)
char *name,*mode;
{
	FILE *fp;

	if((fp = fopen(name,mode)) == NULL)
		error("%s: cannot open this file\n",name);
	return fp;
}


char *
emalloc(n)
unsigned n;
{
	char *p;

	if((p = malloc(n)) == NULL)
		error("%s: cannot allocate enough memory\n",(char *)0);
	return p;
}


/*	Find an appropriate buffer size for mfe1d files. */
findsize(p,n)
int n;
long *p;
{
	int i,size = 0;

	for(i=0;i<n;i++)
		size = max(size,p[i+1] - p[i]);
	return size;
}


/*
	Build the second temporary file, by using the first temporary file as
	input, and passing through only those frames in the frame list to the
	output.
*/
build2(infile,outfile,frmlist,type)
char *infile,*outfile,*frmlist[];
int type;
{
	int h[6],i,n,fsize,bufsize,nf;
	static int save[MAXFRAMES];
	FILE *ip,*op,*efopen();
	long a[2],index[MAXFRAMES],hl = 6*sizeof(int) + 2*sizeof(long),newindex[MAXFRAMES],*nip = newindex;
	char *buffer,*emalloc();

	op = efopen(outfile,"w");
	ip = efopen(infile,"r");
	if(type == 1){ /* mfe1d file */
		nf = pass_one(ip,index); /* count frames and record addresses */
		rewind(ip);
		n = check_list(frmlist,save,nf);
		bufsize = findsize(index,nf);
		buffer = emalloc((unsigned)max(bufsize,1024));
		for(i=0;i<nf;i++){
			fsize = index[i+1] - index[i]; /* compute frame size */
			fread(buffer,1,fsize,ip);
			if(save[i])
				fwrite(buffer,1,fsize,op);
		}
	}else{ /* mfe2d file */
		fread(h,sizeof(int),6,ip); /* read header information */
		fread(a,sizeof(long),2,ip); /* read addresses of index and range tables */
		fseek(ip,a[0],0); /* seek to the index table */
		fread(index,sizeof(long),h[5],ip); /* read addresses of frames */
		fseek(ip,hl,0); /* seek to start of string list */
		n = check_list(frmlist,save,h[5]);
		h[5] -= n; /* "n" is the number of frames to be deleted */
		fwrite(h,sizeof(int),6,op); /* write new header information */
		fwrite(a,sizeof(long),2,op); /* write addresses as placeholders - they will be changed later */
		buffer = emalloc((unsigned)max(index[0],1000+index[1]-index[0]));
		fread(buffer,1,index[0] - hl,ip); /* read string list, edge and cell lists */
		fwrite(buffer,1,index[0] - hl,op); /* write same */
		for(i=0;i< h[5]+n;i++){ /* for every frame in the input file */
			fsize = (i == h[5]+n-1) ? a[0]-index[i] : index[i+1]-index[i];
			fread(buffer,1,fsize,ip); /* read frame */
			if(save[i]){
				*nip++ = ftell(op); /* store the address of the start of the frame */
				fwrite(buffer,1,fsize,op); /* write the frame */
			}
		}
		fseek(ip,a[1],0); /* find the range table in input file */
		a[0] = ftell(op); /* store the address of the index table in the output file */
		fwrite(newindex,sizeof(long),h[5],op); /* write the new index table */
		a[1] = ftell(op); /* store the address of the new range table */
		fread(buffer,sizeof(float),4,ip); /* read the domain size */
		fwrite(buffer,sizeof(float),4,op); /* write the domain size */
		for(i=0;i<h[5]+n;i++){ /* for every entry in the old range table */
			fread(buffer,sizeof(float),2*h[4],ip); /* read entry */
			if(save[i])
				fwrite(buffer,sizeof(float),2*h[4],op); /* write entry */
		}
		fseek(op,(long)(6*sizeof(int)),0); /* seek back to the header */
		fwrite(a,sizeof(long),2,op); /* write addresses of the new index and range tables */
	}
	fclose(ip);
	fclose(op);
	free(buffer);
}
