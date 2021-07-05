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

#line 6 "rules2.y"
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
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#line 22 "rules2.y"
typedef union{
	float val;
	int ival;
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
#line 47 "y.tab.c"

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
#define UFO 258
#define PLOT 259
#define XSECT 260
#define OPEN 261
#define CLOSE 262
#define NO 263
#define DRAW 264
#define GRID 265
#define SHOW 266
#define TIMES 267
#define DOT 268
#define NFILE 269
#define VECT 270
#define LEQ 271
#define MOVE 272
#define TILT 273
#define HEQ 274
#define WEQ 275
#define MABS 276
#define MREL 277
#define UPDATE 278
#define XSLICE 279
#define YSLICE 280
#define HWEQ 281
#define CONT 282
#define CSPACE 283
#define OFFSET 284
#define SHEAR 285
#define SIZE 286
#define FORMAT 287
#define CAPX 288
#define QXS 289
#define UMINUS 290
#define YYERRCODE 256
typedef short YYINT;
static const YYINT yylhs[] = {                           -1,
    0,    0,    0,    0,    0,    3,    3,    3,    3,    3,
    3,    3,    3,    4,    4,    4,    2,    2,    5,    5,
    5,    5,   11,   11,   11,   11,   13,   13,    1,    7,
    7,    7,    7,    7,    7,    7,    6,    6,    6,    6,
    6,    6,    6,    6,    6,    6,   14,   14,   14,    8,
    8,    8,    8,    8,    8,    8,    8,    8,    8,    8,
    8,    8,    8,    8,    8,    8,    9,    9,    9,    9,
    9,    9,    9,   10,   10,   10,   10,   10,   10,   12,
   12,   12,   12,
};
static const YYINT yylen[] = {                            2,
    2,    2,    3,    3,    1,    0,    1,    1,    1,    1,
    1,    1,    1,    1,    1,    1,    1,    2,    1,    2,
    3,    3,    1,    1,    2,    2,    3,    4,    3,    1,
    2,    2,    2,    2,    2,    3,    1,    2,    3,    4,
    2,    2,    3,    4,    1,    1,    1,    1,    1,    1,
    1,    2,    2,    4,    3,    2,    1,    4,    3,    2,
    1,    3,    3,    3,    3,    1,    1,    2,    2,    3,
    2,    3,    3,    1,    4,    3,    6,    3,    2,    0,
    1,    1,    1,
};
static const YYINT yydefred[] = {                         0,
    5,   17,    0,   47,    0,    0,    0,   30,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,   66,   45,
   46,    0,    0,    0,    0,    0,    0,    0,   48,   49,
   15,    0,    0,    0,    0,    7,    8,    9,   10,   11,
   12,   13,    0,    0,    0,   24,   53,   52,   41,   32,
   79,   71,   31,   34,   33,    0,   81,   83,   82,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,   69,    0,    0,    0,    0,    0,    0,   18,
    0,   35,    1,    2,    0,    0,    0,    0,   25,   70,
   36,   76,    0,   78,   62,   63,   64,   55,    0,   59,
    0,   65,   72,   73,   43,    0,   22,   21,    3,    4,
    0,   39,    0,    0,   54,   58,   44,   40,    0,   28,
    0,    0,   77,   29,
};
static const YYINT yydgoto[] = {                         33,
  120,   34,   35,   36,   37,   38,   39,   40,   41,   42,
   45,   60,   46,   43,
};
static const YYINT yysindex[] = {                        -6,
    0,    0, -235,    0,   -5,   28, -153,    0, -246, -224,
   -2,  -39,   -2,   -2,   -2,   -2,  -37,  -35,    0,    0,
    0,   -2,  -40,   -2,   -2,  -33,   -2,   -2,    0,    0,
    0,  -40,   27,  -31,    4,    0,    0,    0,    0,    0,
    0,    0,  -38,  -25, -234,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,  -40,    0,    0,    0, -233,
  -40,  -40,  -17,  -40,  -40,  -40,  -40,  -40,   13,  -40,
   18,  -40,    0,  -40,  -40,  -40,   49,  -40,  -40,    0,
    5,    0,    0,    0,   29, -197, -159,  -25,    0,    0,
    0,    0,  -40,    0,    0,    0,    0,    0,  -40,    0,
  -40,    0,    0,    0,    0,  -40,    0,    0,    0,    0,
 -158,    0,   60,   64,    0,    0,    0,    0, -149,    0,
  -40,   68,    0,    0,
};
static const YYINT yyrindex[] = {                         6,
    0,    0,    7,    0,    8,   10,    0,    0,    0,    0,
 -148,   16,  -32,  -32,  -32,  -32,   22,   24,    0,    0,
    0,  -32,   26,  -32,  -32,    0,  -32,  -32,    0,    0,
    0,   30,    6,   33,    0,    0,    0,    0,    0,    0,
    0,    0,   35,  -10,   36,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,   37,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,   38,    0,
   42,    0,    0,    0,    0,    0,   43,    0,    0,    0,
    0,    0,    0,    0,   44,    0,    0,   -9,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,   -8,   45,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,
};
static const YYINT yygindex[] = {                         0,
    0,   12,   81,    0,    0,    0,    0,    0,    0,    0,
    0,  110,   70,    0,
};
#define YYTABLESIZE 316
static const YYINT yytable[] = {                         23,
   26,   27,   62,   86,   61,   61,   68,   61,   70,   61,
   76,   61,   80,   83,  109,    6,   19,   50,   53,   51,
   54,   44,   88,   63,   91,   74,   93,   47,   69,   71,
   82,   57,   87,   61,   73,   67,   31,   77,   32,   16,
   55,   58,   14,   80,   37,   20,   68,   56,   23,   26,
   27,   60,   42,   38,   75,   57,   99,   56,   59,  112,
   48,  101,   84,  110,    6,   19,   50,   90,   51,   31,
  111,   32,   80,   92,   74,   94,   95,   96,   97,   98,
   57,  100,   61,  102,   67,  103,  104,  105,   16,  107,
  108,   14,  106,   37,   20,   68,   56,  113,  118,  119,
   60,   42,   38,   75,  114,  121,   49,  122,  124,   80,
  115,   50,  116,   81,   89,    0,   51,  117,    0,    0,
    0,    0,   64,   65,   66,   67,    0,    0,   52,    0,
    0,   72,  123,   74,   75,    0,   78,   79,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    2,    2,   85,    2,
    0,    2,    0,    2,   80,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   23,   26,   27,    1,
    2,    0,    3,    4,    5,    6,    7,    8,    0,    9,
    0,   10,   11,   12,   13,    0,   14,   15,   16,   17,
   18,   19,   20,   21,   22,   23,   24,   25,   26,   27,
   28,   29,   30,    2,    0,    3,    4,    5,    6,    7,
    8,    0,    9,    0,   10,   11,   12,   13,    0,   14,
   15,   16,   17,   18,   19,   20,   21,   22,   23,   24,
   25,   26,   27,   28,   29,   30,
};
static const YYINT yycheck[] = {                         10,
   10,   10,   42,   42,   45,   45,   44,   45,   44,   45,
   44,   45,   45,   10,   10,   10,   10,   10,  265,   10,
  267,  257,  257,   12,  258,   10,   44,   33,   17,   18,
   62,   10,   58,   10,   23,   10,   43,   26,   45,   10,
  265,   44,   10,   32,   10,   10,   10,   10,   59,   59,
   59,   10,   10,   10,   10,   58,   44,  282,   61,  257,
   33,   44,   59,   59,   59,   59,   59,   56,   59,   43,
   42,   45,   61,   62,   59,   64,   65,   66,   67,   68,
   59,   70,   59,   72,   59,   74,   75,   76,   59,   78,
   79,   59,   44,   59,   59,   59,   59,  257,  257,   40,
   59,   59,   59,   59,   93,   42,  260,  257,   41,  258,
   99,  265,  101,   33,   45,   -1,  270,  106,   -1,   -1,
   -1,   -1,   13,   14,   15,   16,   -1,   -1,  282,   -1,
   -1,   22,  121,   24,   25,   -1,   27,   28,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  257,  257,  257,  257,
   -1,  257,   -1,  257,  257,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  257,  257,  257,  256,
  257,   -1,  259,  260,  261,  262,  263,  264,   -1,  266,
   -1,  268,  269,  270,  271,   -1,  273,  274,  275,  276,
  277,  278,  279,  280,  281,  282,  283,  284,  285,  286,
  287,  288,  289,  257,   -1,  259,  260,  261,  262,  263,
  264,   -1,  266,   -1,  268,  269,  270,  271,   -1,  273,
  274,  275,  276,  277,  278,  279,  280,  281,  282,  283,
  284,  285,  286,  287,  288,  289,
};
#define YYFINAL 33
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
#define YYMAXTOKEN 290
#define YYUNDFTOKEN 307
#define YYTRANSLATE(a) ((a) > YYMAXTOKEN ? YYUNDFTOKEN : (a))
#if YYDEBUG
static const char *const yyname[] = {

"end-of-file",0,0,0,0,0,0,0,0,0,"'\\n'",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,"'!'",0,0,0,0,0,0,"'('","')'","'*'","'+'","','","'-'",0,0,0,0,0,0,0,0,0,0,0,
0,"':'","';'",0,"'='","'>'",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,"NUMBER","UFO","PLOT","XSECT","OPEN","CLOSE","NO","DRAW","GRID",
"SHOW","TIMES","DOT","NFILE","VECT","LEQ","MOVE","TILT","HEQ","WEQ","MABS",
"MREL","UPDATE","XSLICE","YSLICE","HWEQ","CONT","CSPACE","OFFSET","SHEAR",
"SIZE","FORMAT","CAPX","QXS","UMINUS",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
"illegal-symbol",
};
static const char *const yyrule[] = {
"$accept : comlist",
"comlist : command '\\n'",
"comlist : command ';'",
"comlist : comlist command '\\n'",
"comlist : comlist command ';'",
"comlist : error",
"command :",
"command : fchngcom",
"command : plotcom",
"command : xsectcom",
"command : etcetera",
"command : windcom",
"command : contcom",
"command : vectcom",
"fchngcom : number",
"fchngcom : '+'",
"fchngcom : '-'",
"number : NUMBER",
"number : '-' number",
"plotcom : PLOT",
"plotcom : PLOT frameseq",
"plotcom : FORMAT nch number",
"plotcom : SIZE nch number",
"frameseq : NUMBER",
"frameseq : interval",
"frameseq : frameseq interval",
"frameseq : frameseq NUMBER",
"interval : NUMBER ':' NUMBER",
"interval : NUMBER ':' NUMBER step",
"step : '(' NUMBER ')'",
"etcetera : DRAW",
"etcetera : SHOW GRID",
"etcetera : NO GRID",
"etcetera : DOT GRID",
"etcetera : SHOW TIMES",
"etcetera : number '>'",
"etcetera : NFILE nch UFO",
"xsectcom : xinit",
"xsectcom : xinit NUMBER",
"xsectcom : xinit '*' NUMBER",
"xsectcom : xinit NUMBER '*' NUMBER",
"xsectcom : NO XSECT",
"xsectcom : SHEAR number",
"xsectcom : SHEAR ',' number",
"xsectcom : SHEAR number ',' number",
"xsectcom : XSLICE",
"xsectcom : YSLICE",
"xinit : XSECT",
"xinit : CAPX",
"xinit : QXS",
"windcom : OPEN",
"windcom : CLOSE",
"windcom : CLOSE '!'",
"windcom : OPEN '!'",
"windcom : MABS number ',' number",
"windcom : MABS ',' number",
"windcom : MABS number",
"windcom : MABS",
"windcom : MREL number ',' number",
"windcom : MREL ',' number",
"windcom : MREL number",
"windcom : MREL",
"windcom : TILT nch number",
"windcom : HEQ nch number",
"windcom : WEQ nch number",
"windcom : HWEQ nch number",
"windcom : UPDATE",
"contcom : CONT",
"contcom : DOT CONT",
"contcom : CONT number",
"contcom : DOT CONT number",
"contcom : NO CONT",
"contcom : CSPACE nch number",
"contcom : OFFSET nch number",
"vectcom : VECT",
"vectcom : VECT number ',' number",
"vectcom : VECT '*' number",
"vectcom : VECT number ',' number '*' number",
"vectcom : LEQ nch number",
"vectcom : NO VECT",
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
#line 222 "rules2.y"



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
#line 618 "y.tab.c"

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
#line 36 "rules2.y"
	{prompt(snum,linecount++);}
break;
case 2:
#line 37 "rules2.y"
	{/* null action */}
break;
case 3:
#line 38 "rules2.y"
	{prompt(snum,linecount++);}
break;
case 4:
#line 39 "rules2.y"
	{/* null */}
break;
case 5:
#line 40 "rules2.y"
	{clear_error();yyerrok;yyclearin;prompt(snum,linecount++);}
break;
case 14:
#line 55 "rules2.y"
	{pic->framenumber= min(max((int)yystack.l_mark[0].val,1),numoframes);}
break;
case 15:
#line 56 "rules2.y"
	{if(pic->framenumber<numoframes) ++pic->framenumber;}
break;
case 16:
#line 57 "rules2.y"
	{if(pic->framenumber>1) --pic->framenumber;}
break;
case 17:
#line 61 "rules2.y"
	{yyval.val= yystack.l_mark[0].val;}
break;
case 18:
#line 62 "rules2.y"
	{yyval.val= - yystack.l_mark[0].val;}
break;
case 19:
#line 66 "rules2.y"
	{sprintf(fseq,"%d",pic->framenumber);
			 writepicspec(pic,fseq,&plspec,defer_draw,qxs);}
break;
case 20:
#line 68 "rules2.y"
	{writepicspec(pic,fseq,&plspec,defer_draw,qxs);}
break;
case 21:
#line 69 "rules2.y"
	{plspec.format = min(max(1,(int)yystack.l_mark[0].val),5);setplotsize(0.0,&plspec);}
break;
case 22:
#line 70 "rules2.y"
	{setplotsize(yystack.l_mark[0].val,&plspec);}
break;
case 23:
#line 72 "rules2.y"
	{incfseq((int)yystack.l_mark[0].val,(int)yystack.l_mark[0].val,1,fseq);}
break;
case 26:
#line 75 "rules2.y"
	{incfseq((int)yystack.l_mark[0].val,(int)yystack.l_mark[0].val,1,fseq);}
break;
case 27:
#line 77 "rules2.y"
	{incfseq((int)yystack.l_mark[-2].val, (int)yystack.l_mark[0].val, 1,fseq);}
break;
case 28:
#line 78 "rules2.y"
	{incfseq((int)yystack.l_mark[-3].val, (int)yystack.l_mark[-1].val, (int)yystack.l_mark[0].val,fseq);}
break;
case 29:
#line 80 "rules2.y"
	{yyval.val= yystack.l_mark[-1].val;}
break;
case 30:
#line 84 "rules2.y"
	{linecount = 0;pflag = 1;openpl();erase();drawscreen(pic,mfp,defer_draw,qxs);}
break;
case 31:
#line 85 "rules2.y"
	{pic->flags.grid= TRUE;pic->flags.dotgrid= FALSE;}
break;
case 32:
#line 86 "rules2.y"
	{pic->flags.grid= FALSE;pic->flags.dotgrid= FALSE;}
break;
case 33:
#line 87 "rules2.y"
	{pic->flags.dotgrid= TRUE;pic->flags.grid= FALSE;}
break;
case 34:
#line 88 "rules2.y"
	{linecount = 0;pflag = 0;showtable(mfp);}
break;
case 35:
#line 89 "rules2.y"
	{snum= min(max((int)yystack.l_mark[-1].val,0),PASIZE-1);pic= parray+snum;}
break;
case 36:
#line 90 "rules2.y"
	{if(restart(filename)){
				startpic(pic = parray);
				currframe = 0;
				pflag = 0;
				showtable(mfp);
				}}
break;
case 37:
#line 99 "rules2.y"
	{initxsect(0,0,pic);}
break;
case 38:
#line 100 "rules2.y"
	{initxsect((int)yystack.l_mark[0].val,0,pic);}
break;
case 39:
#line 101 "rules2.y"
	{initxsect(0,(int)yystack.l_mark[0].val,pic);}
break;
case 40:
#line 103 "rules2.y"
	{initxsect((int)yystack.l_mark[-2].val,(int)yystack.l_mark[0].val,pic);}
break;
case 41:
#line 104 "rules2.y"
	{pic->flags.xsect= FALSE;pic->flags.openxs= FALSE;}
break;
case 42:
#line 105 "rules2.y"
	{pic->xspec[pic->zindex].lshear= yystack.l_mark[0].val;}
break;
case 43:
#line 106 "rules2.y"
	{pic->xspec[pic->zindex].vshear= yystack.l_mark[0].val;}
break;
case 44:
#line 107 "rules2.y"
	{pic->xspec[pic->zindex].lshear= yystack.l_mark[-2].val;
					 pic->xspec[pic->zindex].vshear= yystack.l_mark[0].val;}
break;
case 45:
#line 109 "rules2.y"
	{pic->xspec[pic->zindex].yslice= FALSE;}
break;
case 46:
#line 110 "rules2.y"
	{pic->xspec[pic->zindex].yslice= TRUE;}
break;
case 47:
#line 112 "rules2.y"
	{defer_draw = FALSE; qxs = FALSE;}
break;
case 48:
#line 113 "rules2.y"
	{defer_draw = TRUE;}
break;
case 49:
#line 114 "rules2.y"
	{qxs = TRUE;}
break;
case 50:
#line 118 "rules2.y"
	{if(!pic->flags.xsect){
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
break;
case 51:
#line 134 "rules2.y"
	{if(!pic->flags.openxs){
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
break;
case 52:
#line 146 "rules2.y"
	{pic->currwin= pic->wspec;pic->flags.window= FALSE;}
break;
case 53:
#line 147 "rules2.y"
	{pic->currwin= pic->topwin;}
break;
case 54:
#line 148 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
					mabox(lax= yystack.l_mark[-2].val,lay= yystack.l_mark[0].val,pic->flags.window ? pic->currwin +1 : pic->currwin);}
break;
case 55:
#line 150 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
					mabox(lax,lay= yystack.l_mark[0].val,pic->flags.window ? pic->currwin +1 : pic->currwin);}
break;
case 56:
#line 152 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
					mabox(lax= yystack.l_mark[0].val,lay,pic->flags.window ? pic->currwin +1 : pic->currwin);}
break;
case 57:
#line 154 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
					mabox(lax=50.0,lay=50.0,pic->flags.window ? pic->currwin +1 : pic->currwin);}
break;
case 58:
#line 156 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
					mrbox(lrx= yystack.l_mark[-2].val,lry= yystack.l_mark[0].val,pic->flags.window ? pic->currwin +1 : pic->currwin);}
break;
case 59:
#line 158 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
					mrbox(lrx,lry= yystack.l_mark[0].val,pic->flags.window ? pic->currwin +1 : pic->currwin);}
break;
case 60:
#line 160 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
					mrbox(lrx= yystack.l_mark[0].val,lry,pic->flags.window ? pic->currwin +1 : pic->currwin);}
break;
case 61:
#line 162 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
					mrbox(lrx,lry,pic->flags.window ? pic->currwin +1 : pic->currwin);}
break;
case 62:
#line 164 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
				if(pic->flags.window)
					(pic->currwin+1)->tilt = yystack.l_mark[0].val + pic->currwin->tilt;
				else
					pic->currwin->tilt = yystack.l_mark[0].val + (pic->currwin-1)->tilt;}
break;
case 63:
#line 169 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
				if(pic->flags.window)
					changeheight(pic->currwin+1, yystack.l_mark[0].val);
				else
					changeheight(pic->currwin, yystack.l_mark[0].val);}
break;
case 64:
#line 174 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
				if(pic->flags.window)
					changewidth(pic->currwin+1, yystack.l_mark[0].val);
				else
					changewidth(pic->currwin, yystack.l_mark[0].val);}
break;
case 65:
#line 179 "rules2.y"
	{if(pic->flags.window || pic->currwin > pic->wspec)
				if(pic->flags.window){
					changeheight(pic->currwin+1, yystack.l_mark[0].val);
					changewidth(pic->currwin+1, yystack.l_mark[0].val);
				}else{
					changeheight(pic->currwin, yystack.l_mark[0].val);
					changewidth(pic->currwin, yystack.l_mark[0].val);
				}
			}
break;
case 66:
#line 188 "rules2.y"
	{if(pic->flags.window && !pic->flags.openxs)
				if(pic->flags.xsect)
					drawxsect(&pic->xspec[pic->zindex],pic->currwin+1);
				else
					drawindow(pic->currwin+1);}
break;
case 67:
#line 196 "rules2.y"
	{initcont(0,pic,0);}
break;
case 68:
#line 197 "rules2.y"
	{initcont(0,pic,1);}
break;
case 69:
#line 198 "rules2.y"
	{initcont((int)yystack.l_mark[0].val,pic,0);}
break;
case 70:
#line 199 "rules2.y"
	{initcont((int)yystack.l_mark[0].val,pic,1);}
break;
case 71:
#line 200 "rules2.y"
	{pic->flags.contflag= FALSE;}
break;
case 72:
#line 201 "rules2.y"
	{setcontint(yystack.l_mark[0].val,pic);}
break;
case 73:
#line 202 "rules2.y"
	{pic->contour[pic->zindex].offset=yystack.l_mark[0].val;}
break;
case 74:
#line 206 "rules2.y"
	{initvect(0,0,0,pic);}
break;
case 75:
#line 207 "rules2.y"
	{initvect((int)yystack.l_mark[-2].val,(int)yystack.l_mark[0].val,0,pic);}
break;
case 76:
#line 208 "rules2.y"
	{initvect(0,0,(int)yystack.l_mark[0].val,pic);}
break;
case 77:
#line 209 "rules2.y"
	{initvect((int)yystack.l_mark[-4].val,(int)yystack.l_mark[-2].val,(int)yystack.l_mark[0].val,pic);}
break;
case 78:
#line 210 "rules2.y"
	{setvectlength(yystack.l_mark[0].val,pic);}
break;
case 79:
#line 211 "rules2.y"
	{pic->flags.vect= FALSE;}
break;
#line 1158 "y.tab.c"
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
