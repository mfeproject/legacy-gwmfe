      subroutine wrsoln(t,y)
************************************************************************
*
*   WRSOLN -- Write solution to the output file.
*
************************************************************************
      include "parameters.h"

      integer nepn
      parameter(nepn=npde+2)

      integer nnod,ntri
      common /mfe010/ nnod,ntri

      integer stats
      double precision hlast
      real cpusec
      common /mfe070/ hlast,cpusec,stats(8)

      double precision t,y(nepn,*)
      integer j,k

      write(7) t
      write(7) (y(npde+1,j), y(npde+2,j),
     +         (y(k,j), k=1,npde), j=1,nnod)
      write(7) hlast,cpusec,(stats(j), j=1,8)

      return
      end
