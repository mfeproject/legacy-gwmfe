      subroutine res(y,z,t,  r)
************************************************************************
*
*   RES -- Compute the residual vector R(Y,Z,T) = G(Y,T) - C(Y)*Z.
*
************************************************************************
      include "parameters.h"

      integer nepn
      parameter(nepn=npde+2)

      integer nnod,ntri
      common /mfe010/ nnod,ntri

      double precision bv
      integer nbnod,bnod,bc
      common /mfe030/ bv(nepn,mbnd),nbnod,bnod(2,mbnd),bc(nepn,10)

      integer errc,itri,vl,j,jbc,jbn,k,i
      double precision y(nepn,*),z(*),t,r(nepn,*),a(nepn,nepn,mnod)
      double precision trix,triy

      double precision ONE
      integer DIAG
      parameter(ONE=1.0d0, DIAG=1)
*     ==================================================================
*      Compute the MFE residual.
*     ==================================================================
*     Zero the residual initially.
      do 10 j=1,nnod*nepn
   10 r(j,1) = 0.

*     Zero the mass matrix diagonal initially (Preconditioning).
      do 20 j=1,nnod*nepn**2
   20 a(j,1,1) = 0.
*     ---------------------------------------------
*      Compute the residual 64 elements at a time.
*     ---------------------------------------------
      do 30 itri=1,ntri,64
       vl = min(64, ntri-itri+1)

*      Gather the local unknown vectors.
       call gthvec(vl,itri,y,z)

*      Compute frequently used local quantities.
       call locpp(vl,  errc,trix,triy)

*      Compute the local residual.
       call pderhs(vl)
       call regrhs(vl)
       call   ares(vl)
       call regres(vl)

*      Scatter the local residual.
       call sctvec(vl,itri,  r)

*      Compute the local mass matrix diagonal (Preconditioning).
       call cmtx(vl,ONE,DIAG)
       call sctdgl(vl,itri,  a)
   30 continue
*     ==================================================================
*      Boundary condition modification of the residual.
*     ==================================================================
      do 40 j=1,nbnod
      jbn = bnod(1,j)
      jbc = bnod(2,j)
      do 40 k=1,nepn
       if(bc(k,jbc) .eq. 1) then
        r(k,jbn) = y(k,jbn) - bv(k,j)
        do 41 i=1,nepn
         a(i,k,jbn) = 0.0
         a(k,i,jbn) = 0.0
   41   continue
        a(k,k,jbn) = 1.0
        endif
   40 continue
*     ==================================================================
*      Diagonal preconditioning of the residual.
*     ==================================================================
      call vfct(nnod,  a,    nepn)
      call vslv(nnod,  a,r,  nepn)

      return
      end
