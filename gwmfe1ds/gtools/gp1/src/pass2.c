/*
	This routine carries out the second pass over the 1-D input file. It
	reads from the temporary file, converting ascii format to binary, and
	allocating memory for each column of each frame.
*/
#include	"defs1.h"
#include	"init1.h"

pass2(datafile,fp,n)
FILE *datafile;
FRAMETYPE *fp;
int n;
{
	register COLUMN_HEADER *h;
	register int i;
	void *emalloc();

	for(fp++;n;n--,fp++){ /* note that the first (zero-th) frame pointer is unused */
		fp->head = (COLUMN_HEADER *)emalloc(sizeof(COLUMN_HEADER)*fp->ncol);
		fp->head->val = (float *)emalloc(sizeof(float)*fp->nrow*fp->ncol);
		for(h = fp->head;h < fp->head + fp->ncol;h++){ /* read the firstentry in each column */
			h->val = fp->head->val + fp->nrow*(h - fp->head);
			fscanf(datafile,"%f",h->val);
			h->range.lo = h->range.hi = *h->val;
		}
		for(i=1;i<fp->nrow;i++) /* read remaining entries */
			for(h = fp->head;h < fp->head + fp->ncol;h++){ /* column by column */
				fscanf(datafile,"%f",h->val + i);
				if(h->range.lo > (h->val)[i])
					h->range.lo = (h->val)[i];
				else if(h->range.hi < (h->val)[i])
					h->range.hi = (h->val)[i];
			}
	}
}
