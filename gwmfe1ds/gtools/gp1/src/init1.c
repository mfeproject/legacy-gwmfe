#include        <stdlib.h>
#include        <string.h>
#include	"defs1.h"
#include	"init1.h"

#define		TEMPFILENAME	"/tmp/gpXXXXXX"

char b0[256],b1[256],*bp[2] = {b0,b1},char_class[128];

initialize(namecount,namelist,ofp)
int namecount;
char *namelist[];
FILE *ofp;
{
	int framecount,j;
	extern FRAMETYPE frame[];
	extern int numofcols,numoframes;
	extern FILE_TABLE_ENTRY file_name[];
	char tempfile[25];
	FILE *dfp,*ifp,*efopen();

	numofcols = numoframes = 0;
	sprintf(tempfile,TEMPFILENAME);
	mkstemp(tempfile);
	dfp = efopen(tempfile,"w+");
	for(j=0;j<namecount;j++){
		ifp = efopen(*namelist,"r");
		framecount = pass1(ifp,dfp,frame + numoframes);
		make_table_entry(file_name + j,*namelist++,numoframes+1,numoframes + framecount);
		fclose(ifp);
		write_summary(file_name + j,frame,ofp);
		numoframes += framecount;
	}
	rewind(dfp);
	pass2(dfp,frame,numoframes);
	remove_file(tempfile);
	fclose(dfp);
	for(j=1;j<= numoframes;j++)
		if(frame[j].ncol > numofcols)
			numofcols = frame[j].ncol;
}


startpic(pic)
PICTURESPEC *pic;
{
	PICTURESPEC *ip;
	int i;
	extern REALPAIR fshift[],cshift[];
	extern int numoframes,numofcols;

	for(i=1;i<=numoframes;i++) fshift[i].x = fshift[i].y = 0.0;
	for(i=1;i<=numofcols;i++) cshift[i].x = cshift[i].y = 0.0;
	for(ip=pic;ip<PASIZE+pic;ip++){
		PICFLAGS *f = &ip->flags;
		f->nodes = f->autox = f->autoy = f->labels = TRUE;
		ip->fseq[0] = ip->cseq[0] = (short)(1 + ITEM_OFFSET);
		ip->fseq[1] = ip->cseq[1] = (short)0;
	}
}


/*	The array "char_class" is used by "mygetline()" to classify the
	successive lines of the input files as numeric or non-numeric.
*/
init_char_classes()
{
	int i;

	char_class['-'] = char_class['+'] = char_class['.'] = char_class['e'] = char_class['E'] = FLOATCHAR;
	for(i='0';i<= '9';i++)
		char_class[i] = FLOATCHAR;
	for(i=8;i<=13;i++)
		char_class[i] = WHITESPACE;
	char_class[' '] = WHITESPACE;
}


#define		start_new_frame(f,w,s)	(++f)->nrow = 1;f->ncol = w;\
					strncpy(f->title,s,(size_t)LINELENGTH);\
					f->title[LINELENGTH] = '\0'

/*	The first pass through the input file(s) counts frames, separates the
	frame title from other alpha lines, and writes the numeric information
	into a temporary file for later use by "pass2()".
*/
pass1(infile,outfile,startframe)
FILE *infile,*outfile;
FRAMETYPE *startframe;
{
	int curr_index = 0,isnumeric[2],wordcount,done = FALSE;
	FRAMETYPE *endframe = startframe;

	isnumeric[curr_index] = FALSE;
	while(!done){
		wordcount = mygetline(isnumeric + !curr_index,bp[!curr_index],&done,infile);
		if(isnumeric[curr_index]){
				fprintf(outfile,"%s\n",bp[curr_index]);
				if(isnumeric[!curr_index]){
					if(wordcount != endframe->ncol){
						start_new_frame(endframe,wordcount,"\0");
					}else
						++endframe->nrow;
				}
		}else if(isnumeric[!curr_index]){
			start_new_frame(endframe,wordcount,bp[curr_index]);
		}
		curr_index = !curr_index;
	}
	if(isnumeric[curr_index])
		fprintf(outfile,"%s\n",bp[curr_index]);
	return endframe - startframe;
}


/*	Get a single line from the input. Load its contents into the buffer
	pointed to by "bufp", determine if the line is numeric or not, and
	determine if end of file has been reached.
*/
mygetline(is_num,bufp,is_done,fp)
int *is_num,*is_done;
char *bufp;
FILE *fp;
{
	register int c,state = 0,wcnt = 0;

	*is_num = TRUE;
	while((c = getc(fp)) ==  ' ' || c == '\t'){ /* skip white space */ }
	while(c != '\n' && c != EOF){
		switch(char_class[c]){
		case WHITESPACE		:state = 0;break;
		case ALLOTHER		:*is_num = FALSE;
		case FLOATCHAR		:if(state == 0){
						state = 1;
						++wcnt;
					 }
					 break;
		}
		*bufp++ = c;
		c = getc(fp);
	}
	*bufp = '\0';
	*is_done = (c == EOF);
	if(wcnt == 0)
		*is_num = FALSE;
	return wcnt;
}


/*	Save a file name and the first and last frame numbers associated with
	that file in the file table.
*/
make_table_entry(fte,name,f,l)
FILE_TABLE_ENTRY *fte;
char *name;
int f,l;
{
	char *p,*reverse_index();

	if((p = reverse_index(name,'/')) != NULL)
		name = p + 1; /* strip any leading path components */
	if(f >= l)
		sprintf(fte->name,"%.13s(%d)",name,l);
	else
		sprintf(fte->name,"%.13s(%d-%d)",name,f,l);
	fte->first = f;
	fte->last = l;
}


/*	Write out a file name and the title lines of each of the frames
	associated with that file.
*/
write_summary(fte,fp,ofp)
FILE_TABLE_ENTRY *fte;
FRAMETYPE *fp;
FILE *ofp;
{
	int j;

	fprintf(ofp,"%s\n",fte->name);
	for(j = fte->first;j <= fte->last;j++)
		fprintf(ofp,"%d) %dX%d: %s\n",j,fp[j].nrow,fp[j].ncol-1,fp[j].title);
	fflush(ofp);
}
