#define		ALLOTHER	0
#define		WHITESPACE	1
#define		FLOATCHAR	2

typedef struct{
	INTERVAL range;
	float *val;
}COLUMN_HEADER;
/*
	A "column" is just a list of numbers. Its minimum and maximum values are
	stored in the variable 'range'. The pointer 'val' points to the first
	value in the list.
*/

typedef struct{
	COLUMN_HEADER *head;
	short nrow,ncol;
	char title[LINELENGTH + 1];
}FRAMETYPE;
/*
	A "frame" is an array of numbers with 'nrow' rows and 'ncol' columns.
	Associated with each frame is a title, which is just the last non-
	numeric line before the frame proper begins. It may be empty. At the
	head of each column in the frame is a COLUMN_HEADER, for which see
	previous typedef.
*/

extern int write_summary();
/*
	"write_summary()" is available to re-write the summary of frame titles
	on to the given file(usually stdout).
*/

extern int initialize();
/*
	"initialize()" is used to start the interactive graphics program. It
	is called with the number of files given to main(), and the vector of
	file names. It reads the input files, writes a summary to stdout, starts
	the background hard-copy program, and returns information in the global
	variables frame, file_list, etc.
*/
