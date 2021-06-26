      subroutine eltfy(t,  errc)
************************************************************************
*
*   ELTFY -- Element-wise contribution to df/dy.
*
************************************************************************
      include "parameters.h"

      integer nnod,nelt
      common /mfe010/ nnod,nelt

      double precision h,dxmin
      common /mfe022/ h,dxmin

      double precision u,r,a
      common /loc10/ u(mnod,nepn,0:1)
      common /loc12/ r(mnod,nepn,0:1)
      common /loc20/ a(mnod,nepn,nepn,0:1,0:1)

      integer errc,i,j,k,knod
      double precision t,rsave(mnod,nepn,0:1)
*     --------------------------------------------
*      Compute and save the unperturbed residual.
*     --------------------------------------------
      call pderhs(t)
      call regrhs
      call cres

      do 10 k=1,nepn
      do 10 j=1,nelt
       rsave(j,k, 0) = r(j,k, 0)
       rsave(j,k, 1) = r(j,k, 1)
   10 continue
*     --------------------------------------------------------
*      Partials with respect to the kth unknown at node knod.
*     --------------------------------------------------------
      do 20 knod=0,1
      do 20 k=1,nepn

      do 22 j=1,nelt
   22 u(j,k, knod) = u(j,k, knod) + h

      call eltpp(errc)
      if(errc .ne. 0) return
      call pderhs(t)
      call regrhs
      call cres

      do 21 j=1,nelt
   21 u(j,k, knod) = u(j,k, knod) - h

      do 20 i=1,nepn
      do 20 j=1,nelt
       a(j, i,k, 0,knod) = a(j, i,k, 0,knod) + (r(j,i,0)-rsave(j,i,0))/h
       a(j, i,k, 1,knod) = a(j, i,k, 1,knod) + (r(j,i,1)-rsave(j,i,1))/h
   20 continue

      return
      end
