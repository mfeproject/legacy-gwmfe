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

      double precision pscf
      common /data1/ pscf

      double precision t,y(nepn,*)
      integer j,k

      write(7) t
      write(7) (y(3,j), y(4,j), y(1,j), pscf*y(2,j), j=1,nnod)
      write(7) hlast,cpusec,(stats(j), j=1,8)

      return
      end
