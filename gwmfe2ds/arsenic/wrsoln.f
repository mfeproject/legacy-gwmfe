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

      double precision cscf,uscf,tscf,gamma,mu
      common /data1/ cscf,uscf,tscf,gamma,mu
      save /data1/

      double precision t,y(3,*),cofu
      integer j

      write(7) t*tscf
      write(7) (y(2,j),y(3,j),y(1,j),
     +          log10(cscf*cofu(y(1,j))),cofu(y(1,j)), j=1,nnod)
      write(7) hlast*tscf,cpusec,(stats(j), j=1,8)

      return
      end
