/* original parser id follows */
/* yysccsid[] = "@(#)yaccpar	1.9 (Berkeley) 02/21/93" */
/* (use YYMAJOR/YYMINOR for ifdefs dependent on parser version) */

#define YYBYACC 1
#define YYMAJOR 1
#define YYMINOR 9
#define YYPATCH 20200330

#define YYEMPTY        (-1)
#define yyclearin      (yychar = YYEMPTY)
#define yyerrok        (yyerrflag = 0)
#define YYRECOVERING() (yyerrflag != 0)
#define YYENOMEM       (-2)
#define YYEOF          0
#define YYPREFIX "yy"

#define YYPURE 0

#line 2 "rules1.y"
#include        <stdlib.h>
#include	"switches.h"
#ifdef HANDLE_INTERRUPTS
#include	<signal.h>
#include	<setjmp.h>
#endif

#include	"defs1.h"
#include	"init1.h"
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#line 14 "rules1.y"
typedef union{
	REALPAIR rpair;
	float val;
	short list[NLISTSIZE];
	RANGE_TYPE range;
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
#line 45 "y.tab.c"

/* compatibility with bison */
#ifdef YYPARSE_PARAM
/* compatibility with FreeBSD */
# ifdef YYPARSE_PARAM_TYPE
#  define YYPARSE_DECL() yyparse(YYPARSE_PARAM_TYPE YYPARSE_PARAM)
# else
#  define YYPARSE_DECL() yyparse(void *YYPARSE_PARAM)
# endif
#else
# define YYPARSE_DECL() yyparse(void)
#endif

/* Parameters sent to lex. */
#ifdef YYLEX_PARAM
# define YYLEX_DECL() yylex(void *YYLEX_PARAM)
# define YYLEX yylex(YYLEX_PARAM)
#else
# define YYLEX_DECL() yylex(void)
# define YYLEX yylex()
#endif

#if !(defined(yylex) || defined(YYSTATE))
int YYLEX_DECL();
#endif

/* Parameters sent to yyerror. */
#ifndef YYERROR_DECL
#define YYERROR_DECL() yyerror(const char *s)
#endif
#ifndef YYERROR_CALL
#define YYERROR_CALL(msg) yyerror(msg)
#endif

extern int YYPARSE_DECL();

#define NUMBER 257
#define DIAMOND 258
#define SQUARE 259
#define TRIANGLE 260
#define NO 261
#define DRAW 262
#define CLIPX 263
#define CLIPY 264
#define SUMMARY 265
#define LABELS 266
#define COMP 267
#define FRAME 268
#define NFILE 269
#define YES 270
#define ON 271
#define OFF 272
#define TO 273
#define NODES 274
#define SIZE 275
#define FORMAT 276
#define EXPERT 277
#define AUTO 278
#define SHIFT 279
#define PLOT 280
#define UFO 281
#define UMINUS 282
#define YYERRCODE 256
typedef short YYINT;
static const YYINT yylhs[] = {                           -1,
    0,    0,    0,    0,    0,    9,    9,    9,    9,    9,
    9,    9,    9,   10,   10,   10,   10,   10,   10,   11,
   11,   11,   11,   11,    7,    7,    7,    7,    6,    6,
    5,    5,    5,    4,    4,    4,    1,    1,    8,    8,
   12,   12,   12,   13,   14,   14,   14,   14,   14,   14,
    2,    2,   17,   17,   18,   18,   15,    3,    3,   19,
   19,   19,   19,   19,   19,   16,   16,   16,   16,
};
static const YYINT yylen[] = {                            2,
    2,    2,    3,    3,    1,    0,    1,    1,    1,    1,
    1,    1,    1,    2,    1,    1,    1,    3,    4,    2,
    3,    3,    4,    4,    1,    2,    1,    2,    3,    4,
    2,    2,    3,    1,    1,    1,    1,    2,    3,    4,
    1,    3,    3,    1,    2,    3,    3,    1,    2,    3,
    1,    1,    1,    1,    1,    1,    3,    1,    1,    1,
    2,    3,    2,    1,    1,    0,    1,    1,    1,
};
static const YYINT yydefred[] = {                         0,
    5,    0,   44,   58,   59,   13,    0,    0,    0,    0,
    0,    0,    0,    0,   41,   16,   17,    0,    0,   27,
    0,    0,    7,    8,    9,   10,   11,   12,    0,   67,
   68,   69,   45,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,   56,   54,   53,   55,   49,
   51,   52,    0,    0,    0,   28,    1,    2,    0,    0,
   18,   47,    0,    0,    0,    0,    0,   50,   46,   37,
    0,   43,   42,    3,    4,    0,   64,   65,    0,   57,
    0,    0,    0,   30,    0,   34,   35,   36,   23,   24,
   19,   38,   61,    0,   63,   32,   31,    0,    0,   39,
   62,   33,   40,
};
static const YYINT yydgoto[] = {                         18,
   72,   50,   19,   89,   84,   20,   21,   61,   22,   23,
   24,   25,   26,   27,   28,   34,   51,   52,   80,
};
static const YYINT yysindex[] = {                       -42,
    0,   50,    0,    0,    0,    0,  -21,  -50, -243,  -21,
  -21,  -21,  -21, -228,    0,    0,    0,   14,  -21,    0,
 -223,   -8,    0,    0,    0,    0,    0,    0, -222,    0,
    0,    0,    0, -234, -228,   60, -221, -221, -223,   60,
 -223, -235, -228,  -26,  -26,    0,    0,    0,    0,    0,
    0,    0,    2,  -18,   22,    0,    0,    0,   58,  -26,
    0,    0, -182,   22, -223, -223, -234,    0,    0,    0,
  -26,    0,    0,    0,    0,  -26,    0,    0,  -29,    0,
 -209, -207, -189,    0,  -27,    0,    0,    0,    0,    0,
    0,    0,    0,  -26,    0,    0,    0,   32,  -26,    0,
    0,    0,    0,
};
static const YYINT yyrindex[] = {                         3,
    0,   -6,    0,    0,    0,    0, -179,    0,    0, -181,
 -179,  -16,  -16,    5,    0,    0,    0,    3,  -17,    0,
   10,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  -10,    0,    0,   11,   -6,
   12,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   -5,    0,    0,    0,   -4,    0,
    0,    0,    0,   -3,   16,   20,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,   21,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,
};
static const YYINT yygindex[] = {                         0,
  -13,   17,    0,    0,    0,   44,    1,   36,   56,    0,
    0,    0,    0,    0,    0,   77,    0,    0,    0,
};
#define YYTABLESIZE 294
static const YYINT yytable[] = {                         25,
   16,   57,   17,   25,   26,   29,   25,   37,   39,   41,
   38,   74,    6,   40,   48,   71,   99,   71,   71,   15,
   20,   14,   32,   78,   66,   21,   71,   66,   66,   22,
   60,   73,   46,   55,   59,   64,   30,   65,   66,   31,
   79,   47,   48,   49,   60,   68,   85,   96,   25,   97,
   58,   62,   25,   26,   29,   25,   16,   92,   17,   69,
   75,    6,   93,   48,   56,   95,   29,   98,   15,   20,
   14,  100,  102,   53,   21,   86,   87,   88,   22,   60,
  101,   66,   56,   35,   56,  103,   42,   43,   44,   45,
   66,   66,   66,   32,   29,   54,   60,   83,   90,   66,
    0,   82,   91,   32,   29,    0,    0,   30,   56,   56,
   31,   33,   63,    0,    0,   81,   67,   30,    0,    0,
   31,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   36,    0,    0,    0,
    0,    0,    0,    1,    2,    0,    0,    0,    0,    3,
    4,    5,    6,    7,    8,    9,   10,   70,    0,   70,
   70,   11,   12,   13,   14,    0,    0,   15,   70,   66,
   66,    0,    0,   94,    0,    0,   25,   66,   66,   66,
   25,   26,   29,   25,   76,   66,    0,    0,    0,   77,
   66,    0,    0,    0,    0,    0,    0,    0,   66,    0,
    2,    0,   66,    0,    0,    3,    4,    5,    6,    7,
    8,    9,   10,    0,    0,    0,    0,   11,   12,   13,
   14,    0,    0,   15,
};
static const YYINT yycheck[] = {                         10,
   43,   10,   45,   10,   10,   10,   10,   58,    8,    9,
   61,   10,   10,  257,   10,   45,   44,   45,   45,   10,
   10,   10,   44,   42,   42,   10,   45,   45,   45,   10,
   10,   45,  261,  257,  257,  257,   58,   37,   38,   61,
   54,  270,  271,  272,  279,  281,   60,  257,   59,  257,
   59,   35,   59,   59,   59,   59,   43,   71,   45,   43,
   59,   59,   76,   59,   21,   79,   45,  257,   59,   59,
   59,   85,   41,   18,   59,  258,  259,  260,   59,   59,
   94,  261,   39,    7,   41,   99,   10,   11,   12,   13,
  270,  271,  272,   44,   45,   19,  279,   40,   63,  281,
   -1,   44,   67,   44,   45,   -1,   -1,   58,   65,   66,
   61,   62,   36,   -1,   -1,   58,   40,   58,   -1,   -1,
   61,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  257,   -1,   -1,   -1,
   -1,   -1,   -1,  256,  257,   -1,   -1,   -1,   -1,  262,
  263,  264,  265,  266,  267,  268,  269,  257,   -1,  257,
  257,  274,  275,  276,  277,   -1,   -1,  280,  257,  257,
  257,   -1,   -1,  273,   -1,   -1,  257,  258,  259,  260,
  257,  257,  257,  257,  273,  273,   -1,   -1,   -1,  278,
  278,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  279,   -1,
  257,   -1,  279,   -1,   -1,  262,  263,  264,  265,  266,
  267,  268,  269,   -1,   -1,   -1,   -1,  274,  275,  276,
  277,   -1,   -1,  280,
};
#define YYFINAL 18
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
#define YYMAXTOKEN 282
#define YYUNDFTOKEN 304
#define YYTRANSLATE(a) ((a) > YYMAXTOKEN ? YYUNDFTOKEN : (a))
#if YYDEBUG
static const char *const yyname[] = {

"end-of-file",0,0,0,0,0,0,0,0,0,"'\\n'",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,"'('","')'","'*'","'+'","','","'-'",0,0,0,0,0,0,0,0,0,0,0,0,
"':'","';'",0,"'='","'>'",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,"NUMBER","DIAMOND","SQUARE","TRIANGLE","NO","DRAW","CLIPX",
"CLIPY","SUMMARY","LABELS","COMP","FRAME","NFILE","YES","ON","OFF","TO","NODES",
"SIZE","FORMAT","EXPERT","AUTO","SHIFT","PLOT","UFO","UMINUS",0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,"illegal-symbol",
};
static const char *const yyrule[] = {
"$accept : comlist",
"comlist : command '\\n'",
"comlist : command ';'",
"comlist : comlist command '\\n'",
"comlist : comlist command ';'",
"comlist : error",
"command :",
"command : frmchng",
"command : compchng",
"command : plotcom",
"command : redraw",
"command : etcetera",
"command : clipcom",
"command : SUMMARY",
"frmchng : FRAME nlist",
"frmchng : nlist",
"frmchng : '+'",
"frmchng : '-'",
"frmchng : NUMBER nch shiftval",
"frmchng : FRAME NUMBER nch shiftval",
"compchng : COMP nlist",
"compchng : COMP ':' nlist",
"compchng : COMP '=' nlist",
"compchng : COMP NUMBER nch nodetype",
"compchng : COMP NUMBER nch shiftval",
"nlist : NUMBER",
"nlist : nlist NUMBER",
"nlist : interval",
"nlist : nlist interval",
"interval : NUMBER '-' NUMBER",
"interval : NUMBER '-' NUMBER step",
"step : ',' NUMBER",
"step : ':' NUMBER",
"step : '(' NUMBER ')'",
"nodetype : DIAMOND",
"nodetype : SQUARE",
"nodetype : TRIANGLE",
"number : NUMBER",
"number : '-' number",
"shiftval : SHIFT number number",
"shiftval : SHIFT number ',' number",
"plotcom : PLOT",
"plotcom : FORMAT nch number",
"plotcom : SIZE nch number",
"redraw : DRAW",
"etcetera : NUMBER '>'",
"etcetera : NODES nch lword",
"etcetera : LABELS nch lword",
"etcetera : EXPERT",
"etcetera : EXPERT lword",
"etcetera : NFILE nch UFO",
"lword : affirm",
"lword : notaffirm",
"affirm : ON",
"affirm : YES",
"notaffirm : OFF",
"notaffirm : NO",
"clipcom : axis nch sizespec",
"axis : CLIPX",
"axis : CLIPY",
"sizespec : number",
"sizespec : TO number",
"sizespec : number TO number",
"sizespec : number number",
"sizespec : AUTO",
"sizespec : '*'",
"nch :",
"nch : ':'",
"nch : '='",
"nch : ','",

};
#endif

#if YYDEBUG
int      yydebug;
#endif

int      yyerrflag;
int      yychar;
YYSTYPE  yyval;
YYSTYPE  yylval;
int      yynerrs;

/* define the initial stack-sizes */
#ifdef YYSTACKSIZE
#undef YYMAXDEPTH
#define YYMAXDEPTH  YYSTACKSIZE
#else
#ifdef YYMAXDEPTH
#define YYSTACKSIZE YYMAXDEPTH
#else
#define YYSTACKSIZE 10000
#define YYMAXDEPTH  10000
#endif
#endif

#define YYINITSTACKSIZE 200

typedef struct {
    unsigned stacksize;
    YYINT    *s_base;
    YYINT    *s_mark;
    YYINT    *s_last;
    YYSTYPE  *l_base;
    YYSTYPE  *l_mark;
} YYSTACKDATA;
/* variables for the parser stack */
static YYSTACKDATA yystack;
#line 140 "rules1.y"



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
#line 554 "y.tab.c"

#if YYDEBUG
#include <stdio.h>	/* needed for printf */
#endif

#include <stdlib.h>	/* needed for malloc, etc */
#include <string.h>	/* needed for memset */

/* allocate initial stack or double stack size, up to YYMAXDEPTH */
static int yygrowstack(YYSTACKDATA *data)
{
    int i;
    unsigned newsize;
    YYINT *newss;
    YYSTYPE *newvs;

    if ((newsize = data->stacksize) == 0)
        newsize = YYINITSTACKSIZE;
    else if (newsize >= YYMAXDEPTH)
        return YYENOMEM;
    else if ((newsize *= 2) > YYMAXDEPTH)
        newsize = YYMAXDEPTH;

    i = (int) (data->s_mark - data->s_base);
    newss = (YYINT *)realloc(data->s_base, newsize * sizeof(*newss));
    if (newss == 0)
        return YYENOMEM;

    data->s_base = newss;
    data->s_mark = newss + i;

    newvs = (YYSTYPE *)realloc(data->l_base, newsize * sizeof(*newvs));
    if (newvs == 0)
        return YYENOMEM;

    data->l_base = newvs;
    data->l_mark = newvs + i;

    data->stacksize = newsize;
    data->s_last = data->s_base + newsize - 1;
    return 0;
}

#if YYPURE || defined(YY_NO_LEAKS)
static void yyfreestack(YYSTACKDATA *data)
{
    free(data->s_base);
    free(data->l_base);
    memset(data, 0, sizeof(*data));
}
#else
#define yyfreestack(data) /* nothing */
#endif

#define YYABORT  goto yyabort
#define YYREJECT goto yyabort
#define YYACCEPT goto yyaccept
#define YYERROR  goto yyerrlab

int
YYPARSE_DECL()
{
    int yym, yyn, yystate;
#if YYDEBUG
    const char *yys;

    if ((yys = getenv("YYDEBUG")) != 0)
    {
        yyn = *yys;
        if (yyn >= '0' && yyn <= '9')
            yydebug = yyn - '0';
    }
#endif

    yym = 0;
    yyn = 0;
    yynerrs = 0;
    yyerrflag = 0;
    yychar = YYEMPTY;
    yystate = 0;

#if YYPURE
    memset(&yystack, 0, sizeof(yystack));
#endif

    if (yystack.s_base == NULL && yygrowstack(&yystack) == YYENOMEM) goto yyoverflow;
    yystack.s_mark = yystack.s_base;
    yystack.l_mark = yystack.l_base;
    yystate = 0;
    *yystack.s_mark = 0;

yyloop:
    if ((yyn = yydefred[yystate]) != 0) goto yyreduce;
    if (yychar < 0)
    {
        yychar = YYLEX;
        if (yychar < 0) yychar = YYEOF;
#if YYDEBUG
        if (yydebug)
        {
            if ((yys = yyname[YYTRANSLATE(yychar)]) == NULL) yys = yyname[YYUNDFTOKEN];
            printf("%sdebug: state %d, reading %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
    }
    if (((yyn = yysindex[yystate]) != 0) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == (YYINT) yychar)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: state %d, shifting to state %d\n",
                    YYPREFIX, yystate, yytable[yyn]);
#endif
        if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM) goto yyoverflow;
        yystate = yytable[yyn];
        *++yystack.s_mark = yytable[yyn];
        *++yystack.l_mark = yylval;
        yychar = YYEMPTY;
        if (yyerrflag > 0)  --yyerrflag;
        goto yyloop;
    }
    if (((yyn = yyrindex[yystate]) != 0) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == (YYINT) yychar)
    {
        yyn = yytable[yyn];
        goto yyreduce;
    }
    if (yyerrflag != 0) goto yyinrecovery;

    YYERROR_CALL("syntax error");

    goto yyerrlab; /* redundant goto avoids 'unused label' warning */
yyerrlab:
    ++yynerrs;

yyinrecovery:
    if (yyerrflag < 3)
    {
        yyerrflag = 3;
        for (;;)
        {
            if (((yyn = yysindex[*yystack.s_mark]) != 0) && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == (YYINT) YYERRCODE)
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: state %d, error recovery shifting\
 to state %d\n", YYPREFIX, *yystack.s_mark, yytable[yyn]);
#endif
                if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM) goto yyoverflow;
                yystate = yytable[yyn];
                *++yystack.s_mark = yytable[yyn];
                *++yystack.l_mark = yylval;
                goto yyloop;
            }
            else
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: error recovery discarding state %d\n",
                            YYPREFIX, *yystack.s_mark);
#endif
                if (yystack.s_mark <= yystack.s_base) goto yyabort;
                --yystack.s_mark;
                --yystack.l_mark;
            }
        }
    }
    else
    {
        if (yychar == YYEOF) goto yyabort;
#if YYDEBUG
        if (yydebug)
        {
            if ((yys = yyname[YYTRANSLATE(yychar)]) == NULL) yys = yyname[YYUNDFTOKEN];
            printf("%sdebug: state %d, error recovery discards token %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
        yychar = YYEMPTY;
        goto yyloop;
    }

yyreduce:
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: state %d, reducing by rule %d (%s)\n",
                YYPREFIX, yystate, yyn, yyrule[yyn]);
#endif
    yym = yylen[yyn];
    if (yym > 0)
        yyval = yystack.l_mark[1-yym];
    else
        memset(&yyval, 0, sizeof yyval);

    switch (yyn)
    {
case 1:
#line 30 "rules1.y"
	{printf(" %d>",snum);}
break;
case 2:
#line 31 "rules1.y"
	{/* null action */}
break;
case 3:
#line 32 "rules1.y"
	{printf(" %d>",snum);}
break;
case 4:
#line 33 "rules1.y"
	{/* null */}
break;
case 5:
#line 34 "rules1.y"
	{clear_error();yyerrok;yyclearin;printf(" %d>",snum);}
break;
case 13:
#line 45 "rules1.y"
	{openpl();erase();closepl();
			 for(j=0;j<numofiles;j++)
				write_summary(file_name + j,frame,stdout);}
break;
case 14:
#line 51 "rules1.y"
	{copy_nlist(pic->fseq,yystack.l_mark[0].list,numoframes);np = 0;}
break;
case 15:
#line 52 "rules1.y"
	{copy_nlist(pic->fseq,yystack.l_mark[0].list,numoframes);np = 0;}
break;
case 16:
#line 53 "rules1.y"
	{bump_nlist(pic->fseq,1);}
break;
case 17:
#line 54 "rules1.y"
	{bump_nlist(pic->fseq,-1);}
break;
case 18:
#line 55 "rules1.y"
	{fshift[min(max((int)yystack.l_mark[-2].val,1),numoframes)] = yystack.l_mark[0].rpair;}
break;
case 19:
#line 56 "rules1.y"
	{fshift[min(max((int)yystack.l_mark[-2].val,1),numoframes)] = yystack.l_mark[0].rpair;}
break;
case 20:
#line 59 "rules1.y"
	{copy_nlist(pic->cseq,yystack.l_mark[0].list,numofcols);np = 0;}
break;
case 21:
#line 60 "rules1.y"
	{copy_nlist(pic->cseq,yystack.l_mark[0].list,numofcols);np = 0;}
break;
case 22:
#line 61 "rules1.y"
	{copy_nlist(pic->cseq,yystack.l_mark[0].list,numofcols);np = 0;}
break;
case 23:
#line 62 "rules1.y"
	{set_attribute(pic->attr,(int)yystack.l_mark[-2].val,(int)yystack.l_mark[0].val);}
break;
case 24:
#line 63 "rules1.y"
	{cshift[min(max((int)yystack.l_mark[-2].val,1),numofcols)] = yystack.l_mark[0].rpair;}
break;
case 25:
#line 66 "rules1.y"
	{yyval.list[np++] = max(1,(int)yystack.l_mark[0].val) + ITEM_OFFSET;yyval.list[np] = 0;}
break;
case 26:
#line 67 "rules1.y"
	{yyval.list[np++] = max(1,(int)yystack.l_mark[0].val) + ITEM_OFFSET;yyval.list[np] = 0;}
break;
case 27:
#line 68 "rules1.y"
	{yyval.list[np++] = yystack.l_mark[0].range.left;yyval.list[np++] = yystack.l_mark[0].range.right;yyval.list[np++] = yystack.l_mark[0].range.stepsize;yyval.list[np] = 0;}
break;
case 28:
#line 69 "rules1.y"
	{yyval.list[np++] = yystack.l_mark[0].range.left;yyval.list[np++] = yystack.l_mark[0].range.right;yyval.list[np++] = yystack.l_mark[0].range.stepsize;yyval.list[np] = 0;}
break;
case 29:
#line 72 "rules1.y"
	{yyval.range.left = max(1,(int)yystack.l_mark[-2].val);yyval.range.right = max(1,(int)yystack.l_mark[0].val);yyval.range.stepsize = 1;}
break;
case 30:
#line 73 "rules1.y"
	{yyval.range.left = max(1,(int)yystack.l_mark[-3].val);yyval.range.right = max(1,(int)yystack.l_mark[-1].val);yyval.range.stepsize = max(1,(int)yystack.l_mark[0].val);}
break;
case 31:
#line 76 "rules1.y"
	{yyval.val = yystack.l_mark[0].val;}
break;
case 32:
#line 77 "rules1.y"
	{yyval.val = yystack.l_mark[0].val;}
break;
case 33:
#line 78 "rules1.y"
	{yyval.val = yystack.l_mark[-1].val;}
break;
case 34:
#line 81 "rules1.y"
	{yyval.val = DVAL;}
break;
case 35:
#line 82 "rules1.y"
	{yyval.val = SVAL;}
break;
case 36:
#line 83 "rules1.y"
	{yyval.val = TVAL;}
break;
case 37:
#line 86 "rules1.y"
	{yyval.val= yystack.l_mark[0].val;}
break;
case 38:
#line 87 "rules1.y"
	{yyval.val= - yystack.l_mark[0].val;}
break;
case 39:
#line 90 "rules1.y"
	{yyval.rpair.x = yystack.l_mark[-1].val;yyval.rpair.y = yystack.l_mark[0].val;}
break;
case 40:
#line 91 "rules1.y"
	{yyval.rpair.x = yystack.l_mark[-2].val;yyval.rpair.y = yystack.l_mark[0].val;}
break;
case 41:
#line 94 "rules1.y"
	{writepicspec(pic,&plspec);}
break;
case 42:
#line 95 "rules1.y"
	{plspec.format = min(max(1,(int)yystack.l_mark[0].val),5);setplotsize(0.0,&plspec);}
break;
case 43:
#line 96 "rules1.y"
	{setplotsize(yystack.l_mark[0].val,&plspec);}
break;
case 44:
#line 99 "rules1.y"
	{openpl();erase();drawscreen(pic,expert_mode);
			  if(expert_mode) closepl();}
break;
case 45:
#line 103 "rules1.y"
	{snum= min(max((int)yystack.l_mark[-1].val,0),PASIZE-1);pic= parray+snum;}
break;
case 46:
#line 104 "rules1.y"
	{pic->flags.nodes= (int)yystack.l_mark[0].val;}
break;
case 47:
#line 105 "rules1.y"
	{pic->flags.labels= (int)yystack.l_mark[0].val;}
break;
case 48:
#line 106 "rules1.y"
	{expert_mode = TRUE;}
break;
case 49:
#line 107 "rules1.y"
	{expert_mode = (int)yystack.l_mark[0].val;}
break;
case 50:
#line 108 "rules1.y"
	{if(restart(argfiles))startpic(pic = parray);}
break;
case 51:
#line 111 "rules1.y"
	{yyval.val = TRUE;}
break;
case 52:
#line 112 "rules1.y"
	{yyval.val = FALSE;}
break;
case 57:
#line 121 "rules1.y"
	{setwindow(pic,(int)yystack.l_mark[-2].val,&lastsize,setflag);}
break;
case 58:
#line 123 "rules1.y"
	{yyval.val = 0;}
break;
case 59:
#line 124 "rules1.y"
	{yyval.val = 1;}
break;
case 60:
#line 126 "rules1.y"
	{lastsize.lo = yystack.l_mark[0].val;setflag = 1;}
break;
case 61:
#line 127 "rules1.y"
	{lastsize.hi = yystack.l_mark[0].val;setflag = 2;}
break;
case 62:
#line 128 "rules1.y"
	{lastsize.lo = yystack.l_mark[-2].val;lastsize.hi = yystack.l_mark[0].val;setflag = 3;}
break;
case 63:
#line 129 "rules1.y"
	{lastsize.lo = yystack.l_mark[-1].val;lastsize.hi = yystack.l_mark[0].val;setflag = 3;}
break;
case 64:
#line 130 "rules1.y"
	{setflag = 0;}
break;
case 65:
#line 131 "rules1.y"
	{setflag = 0;}
break;
#line 972 "y.tab.c"
    }
    yystack.s_mark -= yym;
    yystate = *yystack.s_mark;
    yystack.l_mark -= yym;
    yym = yylhs[yyn];
    if (yystate == 0 && yym == 0)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: after reduction, shifting from state 0 to\
 state %d\n", YYPREFIX, YYFINAL);
#endif
        yystate = YYFINAL;
        *++yystack.s_mark = YYFINAL;
        *++yystack.l_mark = yyval;
        if (yychar < 0)
        {
            yychar = YYLEX;
            if (yychar < 0) yychar = YYEOF;
#if YYDEBUG
            if (yydebug)
            {
                if ((yys = yyname[YYTRANSLATE(yychar)]) == NULL) yys = yyname[YYUNDFTOKEN];
                printf("%sdebug: state %d, reading %d (%s)\n",
                        YYPREFIX, YYFINAL, yychar, yys);
            }
#endif
        }
        if (yychar == YYEOF) goto yyaccept;
        goto yyloop;
    }
    if (((yyn = yygindex[yym]) != 0) && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == (YYINT) yystate)
        yystate = yytable[yyn];
    else
        yystate = yydgoto[yym];
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: after reduction, shifting from state %d \
to state %d\n", YYPREFIX, *yystack.s_mark, yystate);
#endif
    if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM) goto yyoverflow;
    *++yystack.s_mark = (YYINT) yystate;
    *++yystack.l_mark = yyval;
    goto yyloop;

yyoverflow:
    YYERROR_CALL("yacc stack overflow");

yyabort:
    yyfreestack(&yystack);
    return (1);

yyaccept:
    yyfreestack(&yystack);
    return (0);
}
