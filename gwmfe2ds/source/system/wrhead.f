      subroutine wrhead
************************************************************************
*
*   WRHEAD -- Write top portion of the output file.
*
************************************************************************
      include "parameters.h"

      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      integer j,k

      open(7,file='mfeout',form='unformatted')
      rewind(7)

      write(7) npde,nnod,ntri
      write(7) ((tvtx(k,j), k=0,2), j=1,ntri)

      return
      end
