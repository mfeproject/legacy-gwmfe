#include	<stdio.h>
#include	<strings.h>
#include	<math.h>
#include	<ctype.h>

#define		FALSE		0
#define		TRUE		!FALSE
#define		min(a,b)	(((a)<(b)) ? (a):(b))
#define		max(a,b)	(((a)>(b)) ? (a):(b))
/* #define		PI		3.14159265358979324 */
#define		BOXSIZE		22
#define		nint(x)		((x)<0) ? (int)((x)-.5):(int)((x)+.5)
#define		abs(a)		((a) >= 0 ? (a) : -(a))
#define		PASIZE		4
#define		MAXFRAMES	250
#define		MAXCOMP		100
#define		MAXFILES	20
#define		MAXROWS		1000
#define		LINELENGTH	80
#define		NLISTSIZE	25
#define		YYMAXDEPTH	10
#define		MAXATTR		6
#define		ITEM_OFFSET	010000
#define		DVAL		0
#define		SVAL		1
#define		TVAL		2

typedef struct{
	int x,y;
}INTPAIR;

typedef struct{
	float x,y;
}REALPAIR;

typedef struct{
	short index,nodetype;
}ATTRIBUTE;

typedef struct{
	int left,right,stepsize;
}RANGE_TYPE;

typedef struct{
	short ch_size,lf_size;
	INTPAIR home,ll, ur;
}DEVICEBOX; /* character size, linefeed size and the coordinates of home, lower
		left and upper right corners */

typedef struct{
	DEVICEBOX screen,
		viewport,
		title,
		params,
		command;
}PAGETYPE; /* a page is made up of several boxes */

typedef struct{
	float lo,hi;
}INTERVAL;

typedef struct{
	int format;
	float size;
}PLOTSPEC;

typedef struct{
	short nodes;
	short autox;
	short autoy;
	short labels;
}PICFLAGS;

typedef struct{
	float xl,xr,yb,yt;
}WINDOWSPEC;

typedef struct{
	short fseq[NLISTSIZE],cseq[NLISTSIZE];
	ATTRIBUTE attr[MAXATTR];
	PICFLAGS flags;
	WINDOWSPEC win;
}PICTURESPEC;

typedef struct{
	char name[20];
	int first,last;
}FILE_TABLE_ENTRY;
