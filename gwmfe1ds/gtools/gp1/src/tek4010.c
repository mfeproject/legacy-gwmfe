/*
	For Tek 4010 compatible terminals.
*/
#include	<stdio.h>
#include	"defs1.h"
#include	"pgs1.h"

#define		US	037
#define		ESC	033
#define		GS	035
#define		FF	014
/* #define SLOWDOWN */

static int oloy = -1, ohiy = -1, ohix = -1, oextra = -1,oldx = -1,oldy = -1;
int	symsize = 30; /* size of symbols (nodes) in device coords */

PAGETYPE *pg = &tek4015page;

label(s)
register char *s;
{
	putchar(US);
	while(*s)
		putchar(*s++);
}


space(x0,y0,x1,y1){}

openpl()
{
	putchar(GS);
}

closepl()
{
	putchar(US);
	fflush(stdout);
}


erase()
{
	putchar(ESC);
	putchar(FF);
	ohiy = ohix = oextra = oloy = oldx = oldy = -1;
#ifdef SLOWDOWN
	fflush(stdout);
	sleep(1);
#endif
}


linemod(s)
char *s;
{
	putchar(ESC);
	if(s[0] == 'l')
		putchar('d'); /* long-dashed */
	else if(s[1] == 'h')
		putchar('c'); /* short-dashed */
	else if(s[3] == 'd')
		putchar('b'); /* dot-dashed */
	else if(s[0] == 'd')
		putchar('a'); /* dotted */
	else
		putchar('e'); /* solid */
}


move(x,y)
int x,y;
{
	if(x != oldx || y != oldy){
		putchar(GS);
		cont(x,y);
	}
}


line(x0,y0,x1,y1)
int x0,y0,x1,y1;
{
	move(x0,y0);
	cont(x1,y1);
}


cont(x,y)
int x,y;
{
#ifdef SLOWDOWN
	int n; /* optional null count for slow terminals */
#endif
	int hix,hiy,lox,loy,extra;

	oldx = x;
	oldy = y;
	hix = (x >> 7) & 037;
	hiy = (y >> 7) & 037;
	lox = (x >> 2) & 037;
	loy = (y >> 2) & 037;
	extra = (x & 03) + ((y << 02) & 014);
#ifdef SLOWDOWN
	n = (abs(hix - ohix) + abs(hiy - ohiy) + 6)/12;
#endif
	if(hiy != ohiy){
		putchar(hiy|040);
		ohiy = hiy;
	}
	if(extra != oextra){
		putchar(extra|0140);
		oextra = extra;
		putchar(loy|0140);
		oloy = loy;
		if(hix != ohix){
			putchar(hix|040);
			ohix = hix;
		}
	}else if(loy != oloy){
		putchar(loy|0140);
		oloy = loy;
		if(hix != ohix){
			putchar(hix|040);
			ohix = hix;
		}
	}else if(hix != ohix){
		putchar(loy|0140);
		oloy = loy;
		putchar(hix|040);
		ohix = hix;
	}
	putchar(lox|0100);
#ifdef SLOWDOWN
	while(n--) putchar(0); /* for slow terminals */
#endif
}
