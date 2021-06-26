/*	This file contains definitions and typedefs which apply to the entire
	program.
*/
#define		MAXZVALS	5
#define		FALSE		0
#define		TRUE		!FALSE
#define		min(a,b)	(((a)<(b)) ? (a):(b))
#define		max(a,b)	(((a)>(b)) ? (a):(b))
#define		min3(a,b,c)	(((a)<(b)) ? min(a,c) : min(b,c))
#define		max3(a,b,c)	(((a)>(b)) ? max(a,c) : max(b,c))
#define		PI		3.14159265358979324
#define		BOXLLENGTH	22
#define		nextup(z,i,o)   ((o)+(i)*ceil(((z)-(o))/(i)))
#define		nint(x)		((x)<0) ? (int)((x)-.5):(int)((x)+.5)
#define 	remainder(y,x)	((y)-(x)*floor((y)/(x)))
#define		frac(x)		((x) - (int)(x))
#define		CONTDENSITY	10
#define		abs(a)		((a) >= 0 ? (a) : -(a))
#define		PASIZE		4
#define		NAMESIZE	20
#define		MAXWINDOWS	10
#define		MAXGRIDSIZE	10000
#define		MAGICNUM	0250
#define		YYMAXDEPTH	10
#define		MAXFRAMES	100
#define		HEADERSIZE	10

typedef struct{
	float x,y;
}REALPAIR;

typedef struct{
	REALPAIR ll,ur;
}REALBOX;

typedef struct{
	float x,y,z;
}REALTRIPLE;

typedef struct{
	int x,y;
}INTPAIR;

typedef struct{
	unsigned short tail,head;
}EDGETYPE; /* an edge is defined by the node numbers at its tail and head*/

typedef struct{
	unsigned short v0,v1,v2;
}CELLTYPE; /* A cell has 3 vertices; v0, v1, and v2 */


typedef struct{
	short ch_size,lf_size;
	INTPAIR home,ll,ur;
}DEVICEBOX;


typedef struct{
	DEVICEBOX screen,
		viewport,
		title,
		acct,
		profile,
		params,
		command;
}PAGETYPE; /* a page is made up of several boxes */
	

typedef struct{
	float lo,hi;
}INTERVAL;

typedef struct{
	float t;
	char lastep[BOXLLENGTH+1],maxstep[BOXLLENGTH+1],
		cputime[BOXLLENGTH+1],isteps[BOXLLENGTH+1];
	INTERVAL z[MAXZVALS];
}FRAMETYPE;


typedef struct{
	char title[BOXLLENGTH+1], date[BOXLLENGTH+1],
	vercpu[BOXLLENGTH+1],op[BOXLLENGTH+1],
	z[MAXZVALS][BOXLLENGTH+1];
}FILEALFA;


typedef struct{
	short numofxs,yslice;
	float lshear,vshear;
}XSECTIONSPEC;


typedef struct{
	REALPAIR center;
	float tilt,width,height;
}WINDOWSPEC;


typedef struct{
	float interval,offset;
	int dotted;
}CONTOURSPEC;


typedef struct{
	short comp1,comp2,gridsize,manscale;
	float vlength;
}VECTORSPEC;


typedef struct{
	float x,y,u,v;
}VECTPOINT;


typedef struct{
	int format;
	float size;
}PLOTSPEC;


typedef struct{
	unsigned vect	    :1;
	unsigned grid	    :1;
	unsigned dotgrid       :1;
	unsigned contflag      :1;
	unsigned window	    :1;
	unsigned xsect	    :1;
	unsigned openxs	    :1;
}PICFLAGS;


typedef struct{
	short framenumber;
	short zindex;
	PICFLAGS flags;
	WINDOWSPEC wspec[MAXWINDOWS];
	WINDOWSPEC *currwin,*topwin;
	XSECTIONSPEC xspec[MAXZVALS];
	CONTOURSPEC contour[MAXZVALS];
	VECTORSPEC vspec;
}PICTURESPEC;




/*
*	Global variables
*/

extern	FILEALFA falfa;  /* data from mfe fixed header is in this structure */

extern	char	today[12], mfefname[BOXLLENGTH];
extern  int 	numofedges,numofcells,numofnodes,numoframes,numofzvals,symsize;
extern  REALBOX domain;
extern  REALPAIR *node0;
extern  EDGETYPE *edge0;
extern  CELLTYPE *cell0;
extern  float	**zpp;
