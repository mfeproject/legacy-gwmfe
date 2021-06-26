/*
	for testing and debugging purposes
*/
#include	<stdio.h>
#include	"defs2.h"
#include	"pgs2.h"

int	symsize = 30; /* size of symbols (nodes) in device coords */

PAGETYPE *pg = &tek4015page;

label(s)
char *s;
{
	printf("label(%s)\n",s);
}


space(x0,y0,x1,y1)
{
	printf("space(%d,%d,%d,%d)\n",x0,y0,x1,y1);
}

openpl()
{
	printf("openpl()\n");
}

closepl()
{
	printf("closepl()\n");
}


erase()
{
	printf("erase()\n");
}


linemod(s)
char *s;
{
	printf("linemod(%s)\n",s);
}


move(x,y)
int x,y;
{
	printf("move(%d,%d)\n",x,y);
}


line(x0,y0,x1,y1)
int x0,y0,x1,y1;
{
	printf("line(%d,%d,%d,%d)\n",x0,y0,x1,y1);
}


cont(x,y)
int x,y;
{
	printf("cont(%d,%d)\n",x,y);
}
