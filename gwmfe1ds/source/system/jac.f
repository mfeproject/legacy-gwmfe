      subroutine jac(y,ydot,t,h,  errc)
************************************************************************
*
*   JAC -- Jacobian matrix.
*
************************************************************************
      include "parameters.h"
      
      integer nnod,nelt
      common /mfe010/ nnod,nelt

      double precision bvl,bvr
      integer bcl,bcr
      common /mfe030/ bcl(nepn),bcr(nepn),bvl(nepn),bvr(nepn)

      double precision a,b,c
      common /mfe040/ a(nepn,nepn,mnod),b(nepn,nepn,mnod),
     +                c(nepn,nepn,mnod)

      double precision a00,a10,a01,a11
      common /loc20/ a00(mnod,nepn,nepn),a10(mnod,nepn,nepn),
     +               a01(mnod,nepn,nepn),a11(mnod,nepn,nepn)

      integer errc,i,j,k
      double precision y(*),ydot(*),t,h,diag(nepn,nepn,mnod)
*     ==================================================================
*      Element-wise contribution to the jacobian.
*     ==================================================================
      call eltvec(y,ydot)
      call eltpp(errc)
      if(errc .ne. 0) go to 910
      call cmtx(-1.d0/h)

*     Save the unscaled mass matrix block diagonal.
      do 110 k=1,nepn
      do 110 i=1,nepn
      do 110 j=2,nelt
  110 diag(i,k,j) = -h*(a00(j,i,k) + a11(j-1,i,k))

      do 111 k=1,nepn
      do 111 i=1,nepn
       diag(i,k,1) = -h*a00(1,i,k)
       diag(i,k,nnod) = -h*a11(nelt,i,k)
  111 continue

      call eltfy(t,  errc)
      if(errc .ne. 0) go to 920

      do 120 k=1,nepn
      do 120 i=1,nepn
      do 120 j=2,nelt
       a(i,k,j) = a00(j,i,k) + a11(j-1,i,k)
       b(i,k,j) = a01(j,i,k)
       c(i,k,j) = a10(j-1,i,k)
  120 continue

      do 121 k=1,nepn
      do 121 i=1,nepn
       a(i,k,1) = a00(1,i,k)
       b(i,k,1) = a01(1,i,k)
       c(i,k,nnod) = a10(nelt,i,k)
       a(i,k,nnod) = a11(nelt,i,k)
  121 continue
*     ==================================================================
*      Boundary condition modification of the jacobian.
*     ==================================================================
      do 130 k=1,nepn
        if(bcl(k) .eq. 1) then
          do 131 i=1,nepn
            a(k,i,1) = 0.0d0
            b(k,i,1) = 0.0d0
            diag(k,i,1) = 0.0d0
            diag(i,k,1) = 0.0d0
  131     continue
          a(k,k,1) = 1.0d0
          diag(k,k,1) = 1.0d0
        endif
        if(bcr(k) .eq. 1) then
          do 132 i=1,nepn
            a(k,i,nnod) = 0.0d0
            c(k,i,nnod) = 0.0d0
            diag(k,i,nnod) = 0.0d0
            diag(i,k,nnod) = 0.0d0
  132     continue
          a(k,k,nnod) = 1.0d0
          diag(k,k,nnod) = 1.0d0
        endif
  130 continue
*     ==================================================================
*      Diagonal preconditioning and factorization.
*     ==================================================================
      call vfct(nnod,  diag,  nepn)
      call vmslv(nnod,  diag,a,  nepn,nepn)
      call vmslv(nnod,  diag,b,  nepn,nepn)
      call vmslv(nnod,  diag,c,  nepn,nepn)

      call btfct(nnod,nepn,  a,b,c)

      errc = 0
      return
*     ==================================================================
*      Error returns.
*     ==================================================================
  910 write(6,911) errc
  911 format(/'** JAC: Bad element -- no. ',i4)
      errc = 1
      return

  920 write(6,921) errc
  921 format(/'** ELTFY: Bad element -- no. ',i4)
      errc = 2
      return
      end 
