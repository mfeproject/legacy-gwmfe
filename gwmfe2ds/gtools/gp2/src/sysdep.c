/*
	This file contains system calls and other routines which may be
	system dependent.
*/
#include	<stdio.h>
#include        <stdlib.h>
#include        <time.h>
#include	<sys/time.h>
#include	<setjmp.h>
#include	<strings.h>
#include	<sys/file.h>

/*
	Return current time
*/
char *
gettime()
{
	struct timeval tv;
	struct timezone tz;
	struct tm      *t;
	static char s[20];

	gettimeofday(&tv,&tz);
	t = localtime(&tv.tv_sec);
	sprintf(s,"%02d%02d%02d",
		t->tm_hour,
		t->tm_min,
		t->tm_sec);
	return s;
}


/*
	Return current date
*/
char *
getdate()
{
	struct timeval tv;
	struct timezone tz;
	struct tm *t;
	static char s[20];

	gettimeofday(&tv,&tz);
	t = localtime(&tv.tv_sec);
	sprintf(s, "%02d%02d%02d",
		t-> tm_year,
		++(t-> tm_mon),
		t-> tm_mday);
	return s;
}

remove_file(fname)
char *fname;
{
	return(unlink(fname));
}

rename_file(from,to)
char *from,*to;
{
	return(rename(from,to));
}

/*
	Return a pointer to the last instance of character 'c' in string 's',
	or 0 if 'c' does not occur in 's'.
*/
char *reverse_index(s,c)
char *s,c;
{
	return(rindex(s,c));
}


/*
	Execute the program named "p".
*/
call_program(p)
char *p;
{
	return(system(p));
}

/*
	Open a file with given name and mode, checking for errors.
*/
FILE *efopen(name,mode)
char *name,*mode;
{
	FILE *fp;

	if((fp = fopen(name,mode)) != NULL)
		return fp;
	fprintf(stderr, "%s: failed to open in mode %s\n",name,mode);
	exit(1);
}


/*
	Open a pipe to the given command with the given read/write mode.
*/
FILE *epopen(commandline,mode)
char *commandline,*mode;
{
	FILE *fp;

	if((fp = popen(commandline,mode)) != NULL)
		return fp;
	fprintf(stderr,"%s: could not execute\n",commandline);
	exit(1);
}


/*
	Check to see if the given path name is accessible under the given mode.
	Used to see if a given file can be opened for reading, writing, etc.
*/
can_access(path,mode)
char *path;
int mode;
{
	return(access(path,mode));
}
