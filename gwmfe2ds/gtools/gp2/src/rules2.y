/*	This file contains the yacc command language parser specification,
	the routine "main()", and other routines immediately related to the
	input parsing process.
*/
%{
#include	"switches.h"
#include	<stdio.h>
#include	<strings.h>
#include	<stdlib.h>

#ifdef HANDLE_INTERRUPTS
#include	<setjmp.h>
#include	<signal.h>
#endif

#include	<ctype.h>
#include	<math.h>
#include	"defs2.h"
%}

%start comlist
%union{
	float val;
	int ival;
}
%token <val> NUMBER
%token <str> UFO
%token  PLOT XSECT OPEN CLOSE NO DRAW GRID SHOW TIMES DOT NFILE VECT LEQ
	MOVE TILT HEQ WEQ MABS MREL UPDATE XSLICE YSLICE HWEQ
	CONT CSPACE OFFSET SHEAR SIZE FORMAT CAPX QXS
%type  <val> step number
%left	UMINUS


%%
comlist	: command '\n'		{prompt(snum,linecount++);}
	| command ';'		{/* null action */}
	| comlist command '\n'  {prompt(snum,linecount++);}
	| comlist command ';'	{/* null */}
	| error			{clear_error();yyerrok;yyclearin;prompt(snum,linecount++);}
	;


command : /* null */
	| fchngcom
	| plotcom
	| xsectcom
	| etcetera
	| windcom
	| contcom
	| vectcom
	;


fchngcom: number	{pic->framenumber= min(max((int)$1,1),numoframes);}
	| '+'		{if(pic->framenumber<numoframes) ++pic->framenumber;}
	| '-'		{if(pic->framenumber>1) --pic->framenumber;}
	;


number	: NUMBER	{$$= $1;}
	| '-' number	%prec UMINUS {$$= - $2;}
	;


plotcom : PLOT		{sprintf(fseq,"%d",pic->framenumber);
			 writepicspec(pic,fseq,&plspec,defer_draw,qxs);}
	| PLOT frameseq {writepicspec(pic,fseq,&plspec,defer_draw,qxs);}
	| FORMAT nch number	{plspec.format = min(max(1,(int)$3),5);setplotsize(0.0,&plspec);}
	| SIZE nch number	{setplotsize($3,&plspec);}
	;
frameseq: NUMBER	{incfseq((int)$1,(int)$1,1,fseq);}
	| interval
	| frameseq interval
	| frameseq NUMBER       {incfseq((int)$2,(int)$2,1,fseq);}
	;
interval: NUMBER':'NUMBER   	{incfseq((int)$1, (int)$3, 1,fseq);}
	| NUMBER':'NUMBER step     {incfseq((int)$1, (int)$3, (int)$4,fseq);}
	;
step	: '(' NUMBER ')'  {$$= $2;}
	;


etcetera: DRAW		{linecount = 0;pflag = 1;openpl();erase();drawscreen(pic,mfp,defer_draw,qxs);}
	| SHOW GRID	{pic->flags.grid= TRUE;pic->flags.dotgrid= FALSE;}
	| NO GRID	{pic->flags.grid= FALSE;pic->flags.dotgrid= FALSE;}
	| DOT GRID	{pic->flags.dotgrid= TRUE;pic->flags.grid= FALSE;}
	| SHOW TIMES	{linecount = 0;pflag = 0;showtable(mfp);}
	| number '>'	{snum= min(max((int)$1,0),PASIZE-1);pic= parray+snum;}
	| NFILE nch UFO	{if(restart(filename)){
				startpic(pic = parray);
				currframe = 0;
				pflag = 0;
				showtable(mfp);
				}}
	;


xsectcom: xinit			{initxsect(0,0,pic);}
	| xinit	NUMBER		{initxsect((int)$2,0,pic);} 
	| xinit	'*' NUMBER	{initxsect(0,(int)$3,pic);} 
	| xinit	NUMBER '*' NUMBER
				{initxsect((int)$2,(int)$4,pic);}
	| NO XSECT		{pic->flags.xsect= FALSE;pic->flags.openxs= FALSE;}
	| SHEAR number		{pic->xspec[pic->zindex].lshear= $2;}
	| SHEAR ',' number	{pic->xspec[pic->zindex].vshear= $3;}
	| SHEAR number ',' number	{pic->xspec[pic->zindex].lshear= $2;
					 pic->xspec[pic->zindex].vshear= $4;}
	| XSLICE	{pic->xspec[pic->zindex].yslice= FALSE;}
	| YSLICE	{pic->xspec[pic->zindex].yslice= TRUE;}
	;
xinit	: XSECT		{defer_draw = FALSE; qxs = FALSE;}
	| CAPX		{defer_draw = TRUE;}
	| QXS		{qxs = TRUE;}
	;


windcom	: OPEN		{if(!pic->flags.xsect){
				pic->flags.xsect= pic->flags.openxs;
				pic->flags.openxs= FALSE;
				if(pic->currwin-pic->wspec < MAXWINDOWS-1)
					if(pic->flags.window){
						pic->flags.window= FALSE;
						pic->topwin= ++pic->currwin;
					}else{
						pic->flags.window= TRUE;
						initwindow(pic->currwin);
					}
			 }else{
				pic->flags.xsect= FALSE;
				pic->flags.openxs= TRUE;
			 }
			}
	| CLOSE		{if(!pic->flags.openxs){
				if(pic->flags.window)
					pic->flags.window= FALSE;
				else if(pic->currwin > pic->wspec){
						pic->flags.window= TRUE;
						pic->topwin= --pic->currwin;
				}
			 }else{
				pic->flags.xsect= TRUE;
				pic->flags.openxs= FALSE;
			 }
			}
	| CLOSE '!'	{pic->currwin= pic->wspec;pic->flags.window= FALSE;}
	| OPEN  '!'	{pic->currwin= pic->topwin;}
	| MABS number ',' number {if(pic->flags.window || pic->currwin > pic->wspec)
					mabox(lax= $2,lay= $4,pic->flags.window ? pic->currwin +1 : pic->currwin);}
	| MABS ',' number      	 {if(pic->flags.window || pic->currwin > pic->wspec)
					mabox(lax,lay= $3,pic->flags.window ? pic->currwin +1 : pic->currwin);}
	| MABS number 		 {if(pic->flags.window || pic->currwin > pic->wspec)
					mabox(lax= $2,lay,pic->flags.window ? pic->currwin +1 : pic->currwin);}
	| MABS			 {if(pic->flags.window || pic->currwin > pic->wspec)
					mabox(lax=50.0,lay=50.0,pic->flags.window ? pic->currwin +1 : pic->currwin);}
	| MREL number ',' number {if(pic->flags.window || pic->currwin > pic->wspec)
					mrbox(lrx= $2,lry= $4,pic->flags.window ? pic->currwin +1 : pic->currwin);}
	| MREL ',' number      	 {if(pic->flags.window || pic->currwin > pic->wspec)
					mrbox(lrx,lry= $3,pic->flags.window ? pic->currwin +1 : pic->currwin);}
	| MREL number 		 {if(pic->flags.window || pic->currwin > pic->wspec)
					mrbox(lrx= $2,lry,pic->flags.window ? pic->currwin +1 : pic->currwin);}
	| MREL			 {if(pic->flags.window || pic->currwin > pic->wspec)
					mrbox(lrx,lry,pic->flags.window ? pic->currwin +1 : pic->currwin);}
	| TILT nch number	{if(pic->flags.window || pic->currwin > pic->wspec)
				if(pic->flags.window)
					(pic->currwin+1)->tilt = $3 + pic->currwin->tilt;
				else
					pic->currwin->tilt = $3 + (pic->currwin-1)->tilt;}
	| HEQ nch number	{if(pic->flags.window || pic->currwin > pic->wspec)
				if(pic->flags.window)
					changeheight(pic->currwin+1, $3);
				else
					changeheight(pic->currwin, $3);}
	| WEQ nch number	{if(pic->flags.window || pic->currwin > pic->wspec)
				if(pic->flags.window)
					changewidth(pic->currwin+1, $3);
				else
					changewidth(pic->currwin, $3);}
	| HWEQ nch number	{if(pic->flags.window || pic->currwin > pic->wspec)
				if(pic->flags.window){
					changeheight(pic->currwin+1, $3);
					changewidth(pic->currwin+1, $3);
				}else{
					changeheight(pic->currwin, $3);
					changewidth(pic->currwin, $3);
				}
			}
	| UPDATE	{if(pic->flags.window && !pic->flags.openxs)
				if(pic->flags.xsect)
					drawxsect(&pic->xspec[pic->zindex],pic->currwin+1);
				else
					drawindow(pic->currwin+1);}
	;


contcom	: CONT		{initcont(0,pic,0);}
	| DOT CONT	{initcont(0,pic,1);}
	| CONT number	{initcont((int)$2,pic,0);}
	| DOT CONT number	{initcont((int)$3,pic,1);}
	| NO CONT	{pic->flags.contflag= FALSE;}
	| CSPACE nch number	{setcontint($3,pic);}
	| OFFSET nch number	{pic->contour[pic->zindex].offset=$3;}
	;


vectcom	: VECT		{initvect(0,0,0,pic);}
	| VECT number ',' number	{initvect((int)$2,(int)$4,0,pic);}
	| VECT '*' number	{initvect(0,0,(int)$3,pic);}
	| VECT number ',' number '*' number	{initvect((int)$2,(int)$4,(int)$6,pic);}
	| LEQ nch number	{setvectlength($3,pic);}
	| NO VECT	{pic->flags.vect= FALSE;}
	;

nch	: /* the possibly null character */
	| ':'
	| '='
	| ','
	;


%%



#define		YYDEBUG 0

extern FRAMETYPE frm;
extern float   getcontint();
extern PAGETYPE *pg;

PLOTSPEC	plspec = {4,7.0}; /* the default format and size */
FILE		*pfp = NULL, *mfp;
PICTURESPEC 	parray[PASIZE],*pic = parray;
#ifdef HANDLE_INTERRUPTS
jmp_buf		sjbuf;
#endif
char		fseq[80],filename[80];
int		snum; /* the current screen or pic spec being used */
int		defer_draw; /* for control of cross-section drawing method */
int		qxs; /* "quick" cross sections */
int		linecount,pflag;
float		lax,lay,lrx,lry;
/* global declarations for all files */
FILEALFA	falfa;
char		today[12], mfefname[BOXLLENGTH];
int		numoframes,numofnodes,numofedges,numofcells,numofzvals;
REALBOX		domain;
REALPAIR	*node0= NULL;
EDGETYPE	*edge0;
CELLTYPE	*cell0;
float		**zpp; /* ptr to array of ptrs to z-values */
/* end global decls */

extern float getcontint();
int currframe;
FRAMETYPE frm;

int main(int argc, char **argv)
{
	int onintr();

	if(argc!=2){
	    printf("usage: gp 'mfe file'\n");
	    return 1;
	}
	initialize(*++argv);
	startpic(pic);
	showtable(mfp);
#ifdef HANDLE_INTERRUPTS
	signal(SIGINT, onintr);
	setjmp(sjbuf);
#endif
	prompt(snum,linecount++);
	yyparse();
	closeplot();
	openpl();
	erase();
	closepl();
	return 0;
}


/*	Lexical analysis routine: breaks up the command line into words,
	numbers, and perhaps characters, returns the appropriate token value.
*/
yylex()
{
	int c,sval;
	char str[50],*cp;
	static int newfile;

	if(newfile){ /* last token seen was "NFILE"; take remainder of the line as a single string */
		newfile = FALSE;
		cp = filename;
		while((*cp = getc(stdin)) == ':' || *cp == '=' || *cp == ' '){}
		while((*++cp = getc(stdin)) != '\n' && *cp != ';'){}
		ungetc(*cp,stdin);
		*cp = '\0';
		return UFO;
	}
	while((c=getc(stdin))==' ' || c== '\t') {/* skip blanks & tabs */}
	if(isdigit(c) || c == '.'){
	    ungetc(c,stdin);
	    fscanf(stdin,"%f",&yylval.val);
	    return(NUMBER);
	}
	if(isalpha(c)){
	    cp = str;
	    *cp = c;
	    while(isalpha(*++cp=getc(stdin)))
		;
	    ungetc(*cp,stdin);
	    *cp = '\0';
	    sval = search(str);
	    newfile = (sval == NFILE); /* was the token the newfile token? */
	    return(sval);
	}
	return(c);/*default return is the character itself*/
}

/*	Determine if the given name matches a prefix of any of the table
	entries. If so, return the associated token value. Otherwise return
	the token "UFO", meaning an unknown identifier in this context. The
	search is linear, and the first match is returned if "name" is 
	ambiguous.
*/
search(name)
char *name;
{
	static struct kword{
		char *word;
		int val;
	}kwt[] = {
	"draw",DRAW,
	"close",CLOSE,
	"mabs",MABS,
	"mrel",MREL, 
	"dot",DOT,
	"grid",GRID,
	"update",UPDATE,
	"height",HEQ,
	"length",LEQ,
	"hw",HWEQ,
	"no",NO,
	"contour",CONT,
	"file",NFILE,
	"open",OPEN,
	"plot",PLOT,
	"show",SHOW,
	"angle",TILT,
	"times",TIMES,
	"width",WEQ,
	"xsect",XSECT,
	"Xsect",CAPX,
	"XSect",CAPX,
	"qxsect",QXS,
	"interval",CSPACE,
	"offset",OFFSET,
	"shear",SHEAR,
	"format",FORMAT,
	"xslice",XSLICE,
	"vector",VECT,
	"yslice",YSLICE,
	"size",SIZE
	};

	int i, last= sizeof(kwt)/sizeof(struct kword) -1;
	char *s,*t;

	for(i=0;i<=last;i++){
		    s= kwt[i].word;
		    t= name;
		    for(;*t == *s;t++,s++){
			if(*t == '\0')
				return(kwt[i].val);
		    }
		    if(*t == '\0')
			    return(kwt[i].val);
	}
	return(UFO);
}


yyerror(s)
char *s;
{
	fprintf(stderr,"%s\n",s);
	++linecount;
}


#ifdef HANDLE_INTERRUPTS
onintr()
{
	signal(SIGINT, onintr); /* reset the interrupt handler */
	openpl();
	move(pg->command.home.x,pg->command.home.y);
	closepl();
	fflush(stdout);
	longjmp(sjbuf,0);
}
#endif


/*	Flush input up to the next newline */
clear_error()
{
	int c;

	while((c = getchar()) != '\n' && c != EOF)
		;
}


prompt(n,i)
int n,i;
{
	INTPAIR p;

	if(pflag){
		p = pg->command.home;
		boxdraw(&pg->command);
		move(p.x,p.y - i*pg->command.lf_size);
	}
	closepl();
	printf(" %d>",n);
}
