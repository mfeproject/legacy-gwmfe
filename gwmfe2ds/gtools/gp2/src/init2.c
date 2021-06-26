/*
	This file contains routines which initialize the graphics program and
	handle restarts when the user changes files from within the graphics
	program.
*/
#include	"switches.h"
#include	<stdio.h>
#include        <stdlib.h>
#include	<string.h>
#include	<sys/file.h>
#include	<unistd.h>
#include	"defs2.h"

extern char mfefname[];

initialize(fname)
char *fname;
{
	char s[30],*getenv(),user[NAMESIZE],*getdate();
	FILE *efopen(),*openplot();
	extern FILE *mfp,*pfp;

	strcpy(mfefname,fname);
	strcpy(user,getenv("USER"));
	mfp = efopen(fname,"r");
	if(getw(mfp) != MAGICNUM){
		fclose(mfp);
		sprintf(s,"gpp -q %s",fname);
		if(call_program(s)){
			fprintf(stderr,"%s: preprocessing failed\n",fname);
			exit(1);
		}
		mfp = efopen(fname,"r");
	}
	sprintf(today, "%s",getdate());
	readgdata(mfp);
}


startpic(pic)
PICTURESPEC *pic;
{
	int j;
	PICTURESPEC *ip;

	openpl();
	space();
	for(ip=pic;ip<PASIZE+pic;ip++){
		WINDOWSPEC *w = ip->wspec;
		ip->currwin = ip->topwin = ip->wspec;
		ip->flags.grid = TRUE;
		ip->flags.vect = ip->flags.dotgrid = ip->flags.contflag = ip->flags.window = ip->flags.xsect = ip->flags.openxs = FALSE;
		ip->vspec.gridsize = 20;
		for(j=0;j<numofzvals;j++){
			XSECTIONSPEC *x = &ip->xspec[j];
			x->numofxs = x->lshear = x->vshear = 50;
		}
		ip->framenumber = 1;
		ip->zindex = 0;
		ip->vspec.comp1 = 0;
		ip->vspec.comp2= (numofzvals > 1) ? 1 : 0;
		w->center.x=(domain.ll.x+domain.ur.x)/2.0;
		w->center.y=(domain.ll.y+domain.ur.y)/2.0;
		w->width=w->height= max(domain.ur.x- domain.ll.x,domain.ur.y-domain.ll.y);
	}
}


/*	Called when the user wishes to change the current input file(s). */
restart(file)
char *file;
{
	extern FILE *pfp,*mfp;

	if(can_access(file,R_OK)){
		closepl();
		fprintf(stderr,"can't open %s for reading\n",file);
		openpl();
		space();
		return 0;
	}else{
		closeplot();
		fclose(mfp);
		deallocmem();
		initialize(file);
		return 1;
	}
}


closeplot()
{
	extern FILE *pfp;

	if(pfp != NULL)
#ifdef PIPEPLOT
		pclose(pfp);
#else
		fclose(pfp);
#endif
	pfp = NULL;
}


FILE *
openplot()
{
	char *plotprog = "gplot2", plotfile[15], comm[50],*emktemp();
	FILE *epopen(),*efopen();

#ifdef PIPEPLOT
	sprintf(comm,"%s %s",plotprog,mfefname);
	return epopen(comm,"w");
#else
#ifdef FILEPLOT
	sprintf(plotfile,"%s","pl?XXXXXX");
	emktemp(plotfile);
	strcat(plotfile,".apf");
	return efopen(plotfile,"w");
#else
	return efopen("/dev/null","w");
#endif
#endif
}
