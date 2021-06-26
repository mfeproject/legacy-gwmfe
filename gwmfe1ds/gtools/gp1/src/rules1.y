%{
#include        <stdlib.h>
#include	"switches.h"
#ifdef HANDLE_INTERRUPTS
#include	<signal.h>
#include	<setjmp.h>
#endif

#include	"defs1.h"
#include	"init1.h"
%}

%start comlist
%union{
	REALPAIR rpair;
	float val;
	short list[NLISTSIZE];
	RANGE_TYPE range;
}
%token <val> NUMBER DIAMOND SQUARE TRIANGLE
%token  NO DRAW CLIPX CLIPY SUMMARY LABELS COMP FRAME NFILE YES ON OFF TO
	NODES SIZE FORMAT EXPERT AUTO SHIFT PLOT UFO
%type  <val> number lword axis nodetype step
%type  <range> interval
%type  <list> nlist
%type  <rpair> shiftval
%left	UMINUS

%%
comlist	: command '\n'		{printf(" %d>",snum);}
	| command ';'		{/* null action */}
	| comlist command '\n'  {printf(" %d>",snum);}
	| comlist command ';'	{/* null */}
	| error			{clear_error();yyerrok;yyclearin;printf(" %d>",snum);}
	;


command : /* null */
	| frmchng
	| compchng
	| plotcom
	| redraw
	| etcetera
	| clipcom
	| SUMMARY 	{openpl();erase();closepl();
			 for(j=0;j<numofiles;j++)
				write_summary(file_name + j,frame,stdout);}
	;


frmchng	: FRAME nlist	{copy_nlist(pic->fseq,$2,numoframes);np = 0;}
	| nlist			{copy_nlist(pic->fseq,$1,numoframes);np = 0;}
	| '+'			{bump_nlist(pic->fseq,1);}
	| '-'			{bump_nlist(pic->fseq,-1);}
	| NUMBER nch shiftval	{fshift[min(max((int)$1,1),numoframes)] = $3;}
	| FRAME NUMBER nch shiftval	{fshift[min(max((int)$2,1),numoframes)] = $4;}
	;

compchng: COMP nlist	{copy_nlist(pic->cseq,$2,numofcols);np = 0;}
	| COMP ':' nlist	{copy_nlist(pic->cseq,$3,numofcols);np = 0;}
	| COMP '=' nlist	{copy_nlist(pic->cseq,$3,numofcols);np = 0;}
	| COMP NUMBER nch nodetype {set_attribute(pic->attr,(int)$2,(int)$4);}
	| COMP NUMBER nch shiftval	{cshift[min(max((int)$2,1),numofcols)] = $4;}
	;

nlist	: NUMBER	{$$[np++] = max(1,(int)$1) + ITEM_OFFSET;$$[np] = 0;}
	| nlist NUMBER	{$$[np++] = max(1,(int)$2) + ITEM_OFFSET;$$[np] = 0;}
	| interval	{$$[np++] = $1.left;$$[np++] = $1.right;$$[np++] = $1.stepsize;$$[np] = 0;}
	| nlist interval	{$$[np++] = $2.left;$$[np++] = $2.right;$$[np++] = $2.stepsize;$$[np] = 0;}
	;

interval: NUMBER '-' NUMBER	{$$.left = max(1,(int)$1);$$.right = max(1,(int)$3);$$.stepsize = 1;}
	| NUMBER '-' NUMBER step	{$$.left = max(1,(int)$1);$$.right = max(1,(int)$3);$$.stepsize = max(1,(int)$4);}
	;

step	: ',' NUMBER		{$$ = $2;}
	| ':' NUMBER		{$$ = $2;}
	| '(' NUMBER ')'	{$$ = $2;}
	;

nodetype: DIAMOND	{$$ = DVAL;}
	| SQUARE	{$$ = SVAL;}
	| TRIANGLE	{$$ = TVAL;}
	;

number	: NUMBER	{$$= $1;}
	| '-' number	%prec UMINUS {$$= - $2;}
	;

shiftval: SHIFT number number		{$$.x = $2;$$.y = $3;}
	| SHIFT number ',' number	{$$.x = $2;$$.y = $4;}
	;

plotcom : PLOT		{writepicspec(pic,&plspec);}
	| FORMAT nch number	{plspec.format = min(max(1,(int)$3),5);setplotsize(0.0,&plspec);}
	| SIZE nch number	{setplotsize($3,&plspec);}
	;

redraw	: DRAW		{openpl();erase();drawscreen(pic,expert_mode);
			  if(expert_mode) closepl();}
	;

etcetera: NUMBER '>'	{snum= min(max((int)$1,0),PASIZE-1);pic= parray+snum;}
	| NODES nch lword	{pic->flags.nodes= (int)$3;}
	| LABELS nch lword	{pic->flags.labels= (int)$3;}
	| EXPERT	{expert_mode = TRUE;}
	| EXPERT lword	{expert_mode = (int)$2;}
	| NFILE nch UFO	{if(restart(argfiles))startpic(pic = parray);}
	;

lword	: affirm	{$$ = TRUE;}
	| notaffirm	{$$ = FALSE;}
	;
affirm	: ON
	| YES
	;
notaffirm: OFF
	| NO
	;

clipcom	: axis nch sizespec	{setwindow(pic,(int)$1,&lastsize,setflag);}
	;
axis	: CLIPX 		{$$ = 0;}
	| CLIPY 		{$$ = 1;}
	;
sizespec: number	{lastsize.lo = $1;setflag = 1;}
	| TO number	{lastsize.hi = $2;setflag = 2;}
	| number TO number	{lastsize.lo = $1;lastsize.hi = $3;setflag = 3;}
	| number number	{lastsize.lo = $1;lastsize.hi = $2;setflag = 3;}
	| AUTO		{setflag = 0;}
	| '*'		{setflag = 0;}
	;

nch	: /* null character */
	| ':'
	| '='
	| ','
	;
%%



#define		YYDEBUG 0

extern int	initialize(),writepicspec(),erase();
extern PAGETYPE *pg;

PLOTSPEC	plspec = {4,7.0}; /* the default format and size */
FILE		*pfp = NULL;
PICTURESPEC 	parray[PASIZE],*pic= parray;
#ifdef HANDLE_INTERRUPTS
jmp_buf		sjbuf;
#endif
char		argfiles[200];
int		snum; /* the current screen or pic spec being used */
int		setflag,expert_mode,comp_chng;
int		numoframes,numofcols,numofiles;
int		j,np;
static INTERVAL lastsize;
FRAMETYPE frame[MAXFRAMES];
FILE_TABLE_ENTRY file_name[MAXFILES];
REALPAIR	fshift[MAXFRAMES], cshift[MAXCOMP];

/* local function prototypes */
void onintr(int);

main(argc, argv)
int argc;
char *argv[];
{
	void onintr();

	if(check_access(--argc,++argv))
		exit(1);
	init_char_classes();
	openpl();
	erase();
	space();
	closepl();
	save_argv(argv,argfiles);
	initialize(numofiles = argc,argv,stdout);
	startpic(pic);
#ifdef HANDLE_INTERRUPTS
	signal(SIGINT, onintr);
	setjmp(sjbuf);
#endif
	printf(" %d>",snum);
	yyparse();
	openpl();
	erase();
	closepl();
	exit(0);
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
		cp = argfiles;
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
	    comp_chng = (sval == COMP);
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
	}kwt[] ={
	"no",NO,
	"frame",FRAME,
	"draw",DRAW,
	"file",NFILE,
	"nodes",NODES,
	"labels",LABELS,
	"component",COMP,
	"off",OFF,
	"format",FORMAT,
	"plot",PLOT,
	"on",ON,
	"x",CLIPX,
	"y",CLIPY,
	"to",TO,
	"yes",YES,
	"auto",AUTO,
	"summary",SUMMARY,
	"xp",EXPERT,
	"size",SIZE,
	"shift",SHIFT,
	"diamonds",DIAMOND,
	"squares",SQUARE,
	"triangles",TRIANGLE
	};

	int i, last = sizeof(kwt)/sizeof(struct kword) -1;
	register char *s,*t;

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


/*	parser errors call this routine */
yyerror(s)
char *s;
{
	fprintf(stderr,"%s\n",s);
}


/*	Interrupt handler: jumps back to main and restarts the parser */
#ifdef HANDLE_INTERRUPTS
void onintr(int signum)
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
