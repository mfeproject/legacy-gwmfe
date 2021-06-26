#include	<stdio.h>

static char *header = "%%!PS-Adobe-1.0\n\
%%%%DocumentFonts: Times-Roman\n\
%%%%Title: GP plotfile\n\
%%%%Creator: %s\n\
%%%%CreationDate: %s\n\
%%%%Pages: (atend)\n\
%%%%EndComments\n\
save\n";

static char *macros = "/gs /gsave load def\n\
/gr /grestore load def\n\
/m /moveto load def\n\
/r /rlineto load def\n\
/s /stroke load def\n\
/sh /show load def\n";

static char *trailer = "%%%%Trailer\n\
restore\n\
%%%%Pages: %d\n";

extern char pltfil_[];
extern double xaxis_, yaxis_;
extern int chrsiz_;

FILE *pfp;
static int segcnt, oldx, oldy, pagecount;

openpl()
{
	FILE *efopen();
	char *getenv(),*getdate(),*gettime(),date[30];

	pfp = efopen(pltfil_, "w");
	sprintf(date,"%s  %s",getdate(),gettime());
	fprintf(pfp, header, getenv("USER"), date);
	fprintf(pfp, macros);
	fprintf(pfp, "%%%%EndProlog\n");
	oldx = oldy = -1;
	segcnt = 0;
	pagecount = 0;
}

#define XUR 612.0
#define YUR 792.0

space(x0, y0, x1, y1, landscape)
int x0, y0, x1, y1, landscape;
{
	double sx,sy,tx,ty;

	++pagecount;
	fprintf(pfp,"%%%%Page: %d %d\n",pagecount,pagecount);
	fprintf(pfp,"gs\nnewpath\n");
	if(landscape){
		fprintf(pfp,"%.8g 0 translate\n",XUR);
		fprintf(pfp,"90 rotate\n");
		sx = YUR/(x1 - x0);
		sy = XUR/(y1 - y0);
	}else{
		sx = XUR/(x1 - x0);
		sy = YUR/(y1 - y0);
	}
	tx = -x0*sx;
	ty = -y0*sy;
	fprintf(pfp,"%.8g %.8g translate\n",tx,ty);
	fprintf(pfp,"%.8g %.8g scale\n",sx,sy);
	linemod("solid");
	fprintf(pfp,"/Times-Roman findfont\n%d scalefont\n\
setfont\n7 setlinewidth\n",chrsiz_);

}


line(x0, y0, x1, y1)
int x0, y0, x1, y1;
{
	move(x0,y0);
	cont(x1,y1);
}


closepl()
{
	fprintf(pfp, trailer, pagecount);
	fclose(pfp);
}


erase()
{
	if(segcnt > 0){
		fprintf(pfp,"s\n");
		segcnt = 0;
	}
	fprintf(pfp,"gr\nshowpage\n");
	oldx = oldy = -1;
}


linemod(s)
char *s;
{
	
	if(segcnt > 0){
		segcnt = 0;
	        fprintf(pfp,"s\n%d %d m\n", oldx, oldy);
	}
	if(s[0] == 'l')		/* long-dashed */
		fprintf(pfp,"[200 40] 0 setdash\n");
	else if(s[1] == 'h')	/* short-dashed */
		fprintf(pfp,"[100 20] 0 setdash\n");
	else if(s[3] == 'd')	/* dot-dashed */
		fprintf(pfp,"[10 20 150 20] 0 setdash\n");
	else if(s[0] == 'd')	/* dotted */
		fprintf(pfp,"[10 20] 0 setdash\n");
	else			/* solid */
		fprintf(pfp,"[] 0 setdash\n");
}


label(s)
char *s;
{
	
	fprintf(pfp,"(%s) sh\n",s);
}


move(x,y)
int x,y;
{
	if(x != oldx || y != oldy){
		oldx = x;
		oldy = y;
		fprintf(pfp,"%d %d m\n", x, y);
	}
}


cont(x,y)
int x,y;
{
	if(x != oldx || y != oldy){
		fprintf(pfp,"%d %d r\n", x - oldx, y - oldy);
		oldx = x;
		oldy = y;
		if(segcnt++ > 100){
			segcnt = 0;
			fprintf(pfp,"s\n%d %d m\n",x,y);
		}
	}
}
