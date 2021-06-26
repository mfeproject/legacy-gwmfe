      subroutine dfdy(n,  errc,trix,triy)
************************************************************************
*
*   DFDY -- Compute the matrix DF/DY locally.
*
************************************************************************
      include "parameters.h"

      integer nepn
      parameter(nepn=npde+2)

      double precision h,dxymin
      common /mfe022/ h,dxymin

      double precision y,r0,r1,r2,a
      common /loc010/ y(65,nepn,0:2)
      common /loc012/ r0(65,nepn),r1(65,nepn),r2(65,nepn)
      common /loc013/ a(65,nepn,nepn,0:2,0:2)

      integer n,errc,i,j,k,kvtx
      double precision trix,triy
      double precision r0save(65,nepn),r1save(65,nepn),r2save(65,nepn)
*     -------------------------------------------
*      Compute and save the triangular residual.
*     -------------------------------------------
      call pderhs(n)
      call regrhs(n)
      call   ares(n)
      call regres(n)

      do 10 k=1,nepn
      do 10 j=1,n
       r0save(j,k) = r0(j,k)
       r1save(j,k) = r1(j,k)
       r2save(j,k) = r2(j,k)
   10 continue

      do 20 kvtx=0,2
      do 20 k=1,nepn
*     -----------------------------------------------------------
*      Partials with respect to the kth variable at vertex kvtx.
*     -----------------------------------------------------------
      do 22 j=1,n
   22 y(j,k,kvtx) = y(j,k,kvtx) + h

      call locpp(n,  errc,trix,triy)
      if(errc .ne. 0) return
      call pderhs(n)
      call regrhs(n)
      call   ares(n)
      call regres(n)

      do 21 j=1,n
   21 y(j,k,kvtx) = y(j,k,kvtx) - h

      do 20 i=1,nepn
      do 20 j=1,n
       a(j, i,k, 0,kvtx) = a(j, i,k, 0,kvtx) + (r0(j,i)-r0save(j,i))/h
       a(j, i,k, 1,kvtx) = a(j, i,k, 1,kvtx) + (r1(j,i)-r1save(j,i))/h
       a(j, i,k, 2,kvtx) = a(j, i,k, 2,kvtx) + (r2(j,i)-r2save(j,i))/h
   20 continue

      return
      end
