      subroutine res(y,ydot,t,  r)
************************************************************************
*
*   RES -- Residual vector.
*
************************************************************************
      include "parameters.h"
      
      integer nnod,nelt
      common /mfe010/ nnod,nelt

      double precision bvl,bvr
      integer bcl,bcr
      common /mfe030/ bcl(nepn),bcr(nepn),bvl(nepn),bvr(nepn)

      double precision a00,a10,a01,a11
      common /loc20/ a00(mnod,nepn,nepn),a10(mnod,nepn,nepn),
     +               a01(mnod,nepn,nepn),a11(mnod,nepn,nepn)

      double precision r0,r1
      common /loc12/ r0(mnod,nepn),r1(mnod,nepn)

      integer errc,i,j,k
      double precision y(nepn,*),ydot(nepn,*),t,r(nepn,*)
      double precision diag(nepn,nepn,mnod)
      equivalence (diag,a10)
*     ==================================================================
*      Element-wise contribution to the residual.
*     ==================================================================
      call eltvec(y,ydot)
      call eltpp(errc)
      if(errc .ne. 0) go to 910
      call pderhs(t)
      call regrhs
      call cres

      do 110 k=1,nepn
      do 110 j=2,nelt
  110 r(k,j) = r0(j,k) + r1(j-1,k)

      do 111 k=1,nepn
       r(k,1) = r0(1,k)
       r(k,nnod) = r1(nelt,k)
  111 continue

      call cdgl

      do 120 k=1,nepn
      do 120 i=1,nepn
      do 120 j=2,nelt
  120 diag(i,k,j) = a00(j,i,k) + a11(j-1,i,k)

      do 121 k=1,nepn
      do 121 i=1,nepn
       diag(i,k,1) = a00(1,i,k)
       diag(i,k,nnod) = a11(nelt,i,k)
  121 continue
*     ==================================================================
*      Boundary condition modification of the residual.
*     ==================================================================
      do 130 k=1,nepn
        if(bcl(k) .eq. 1) then
          r(k,1) = y(k,1) - bvl(k)
          do 131 i=1,nepn
            diag(i,k,1) = 0.0d0
            diag(k,i,1) = 0.0d0
  131     continue
          diag(k,k,1) = 1.0d0
        endif
        if(bcr(k) .eq. 1) then
          r(k,nnod) = y(k,nnod) - bvr(k)
          do 132 i=1,nepn
            diag(i,k,nnod) = 0.0d0
            diag(k,i,nnod) = 0.0d0
  132     continue
          diag(k,k,nnod) = 1.0d0
        endif
  130 continue
*     ==================================================================
*      Diagonal preconditioning of the residual.
*     ==================================================================
      call vfct(nnod,  diag,  nepn)
      call vslv(nnod,  diag,r,  nepn)

      errc = 0
      return
*     ==================================================================
*      Error return.
*     ==================================================================
  910 write(6,911) errc
  911 format(/'** RES: Bad element -- no. ',i4)
      errc = 1
      return
      end
