      subroutine wrsoln(t,y)
************************************************************************
*
*   WRSOLN -- Write solution to the output file.
*
************************************************************************
      integer nnod,ntri
      common /mfe010/ nnod,ntri

      integer stats
      double precision hlast
      real cpusec
      common /mfe070/ hlast,cpusec,stats(8)

      double precision t,y(3,*)
      integer j

      write(7) t
      write(7) (y(2,j),y(3,j),y(1,j), j=1,nnod)
      write(7) hlast,cpusec,(stats(j), j=1,8)

      return
      end
