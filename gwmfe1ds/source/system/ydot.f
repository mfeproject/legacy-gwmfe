      subroutine ydot(y,t,  z,errc)
************************************************************************
*
*   YDOT -- Solve C(y)*dy/dt = g(y,t) for dy/dt.
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

      double precision g0,g1
      common /loc12/ g0(mnod,nepn),g1(mnod,nepn)

      double precision a00,a10,a01,a11
      common /loc20/ a00(mnod,nepn,nepn),a10(mnod,nepn,nepn),
     +               a01(mnod,nepn,nepn),a11(mnod,nepn,nepn)

      integer errc,i,j,k
      double precision y(nepn,*),t,z(nepn,*)
*     ==================================================================
*      Element-wise contribution to the MFE equations.
*     ==================================================================
      call eltvec(y,z)
      call eltpp(errc)
      if(errc .ne. 0) go to 910
*     -------------------------------
*      Compute the mass matrix C(y).
*     -------------------------------
      call cmtx(1.d0)

      do 110 k=1,nepn
      do 110 i=1,nepn
      do 110 j=2,nelt
       a(i,k,j) = a00(j,i,k) + a11(j-1,i,k)
       b(i,k,j) = a01(j,i,k)
       c(i,k,j) = a10(j-1,i,k)
  110 continue

      do 111 k=1,nepn
      do 111 i=1,nepn
       a(i,k,1) = a00(1,i,k)
       b(i,k,1) = a01(1,i,k)
       c(i,k,nnod) = a10(nelt,i,k)
       a(i,k,nnod) = a11(nelt,i,k)
  111 continue
*     --------------------------------
*      Compute the RHS vector g(y,t).
*     --------------------------------
      call pderhs(t)
      call regrhs

      do 120 k=1,nepn
      do 120 j=2,nelt
  120 z(k,j) = g0(j,k) + g1(j-1,k)

      do 121 k=1,nepn
       z(k,1) = g0(1,k)
       z(k,nnod) = g1(nelt,k)
  121 continue
*     ==================================================================
*      Boundary condition contribution to the MFE equations.
*     ==================================================================
      do 130 k=1,nepn
        if(bcl(k) .eq. 1) then
          do 131 i=1,nepn
            a(k,i,1) = 0.0d0
            a(i,k,1) = 0.0d0
            b(k,i,1) = 0.0d0
  131     continue
          a(k,k,1) = 1.0d0
          z(k,1) = 0.0d0
        endif
        if(bcr(k) .eq. 1) then
          do 132 i=1,nepn
            a(k,i,nnod) = 0.0d0
            a(i,k,nnod) = 0.0d0
            c(k,i,nnod) = 0.0d0
  132     continue
          a(k,k,nnod) = 1.0d0
          z(k,nnod) = 0.0d0
        endif
  130 continue
*     ==================================================================
*      Solve for dy/dt.
*     ==================================================================
      call btfct(nnod,nepn,  a,b,c)
      call btslv(nnod,nepn,  a,b,c,  z)

      errc = 0
      return
*     ==================================================================
*      Error return.
*     ==================================================================
  910 write(6,911) errc
  911 format(/'** YDOT: Bad element -- no. ',i4)
      errc = 1
      return
      end
