      subroutine jac(y,z,t,h,  errc)
************************************************************************
*
*   JAC -- Compute the Jacobian matrix R'(Y,T) = (-1/h)*C(Y) + DF/DY.
*
************************************************************************
      include "parameters.h"

      integer nepn,nepn2
      parameter(nepn=npde+2,nepn2=nepn**2)

      integer nnod,ntri
      common /mfe010/ nnod,ntri

      double precision bv
      integer nbnod,bnod,bc
      common /mfe030/ bv(nepn,mbnd),nbnod,bnod(2,mbnd),bc(nepn,10)

      double precision s
      integer bandw,xadj,adjncy
      common /mfe040/ s(smax),bandw,xadj(mnod+1),adjncy(2*medg)

      double precision y(*),z(*),t,h,trix,triy
      double precision jmtx(nepn,nepn,2*medg),jdgl(nepn,nepn,mnod)
      double precision cdgl(nepn,nepn,mnod)
      integer errc,j,k,itri,vl,jbw,jbn,jbc,i,l

      integer FULL
      parameter(FULL=0)
*     ==================================================================
*      Compute the Jacobian of the MFE residual.
*     ==================================================================
*     Zero the Jacobian initially.
      do 10 j=1,nepn2*(xadj(nnod+1)-1)
   10 jmtx(j,1,1) = 0.

      do 11 j=1,nnod*nepn2
   11 jdgl(j,1,1) = 0.

*     Zero the mass matrix diagonal initially (Preconditioning).
      do 20 j=1,nnod*nepn2
   20 cdgl(j,1,1) = 0.
*     ---------------------------------------------
*      Compute the Jacobian 64 elements at a time.
*     ---------------------------------------------
      do 30 itri=1,ntri,64
       vl = min(64, ntri-itri+1)

*      Gather the local unknown vectors.
       call gthvec(vl,itri,y,z)

*      Compute frequently used local quantities.
       call locpp(vl,  errc,trix,triy)

*      Compute the local mass matrix.
       call cmtx(vl,-1.d0/h,FULL)

*      Scatter the local mass matrix diagonal (Preconditioning).
       call sctdgl(vl,itri,  cdgl)

*      Compute the local DF/DY matrix.
       call dfdy(vl,  errc,trix,triy)
       if(errc .ne. 0) go to 920

*      Scatter the local Jacobian matrix.
       call sctmtx(vl,itri,xadj,adjncy,  jmtx,jdgl)
   30 continue

*     Unscale the diagonal blocks.
      do 50 j=1,nnod*nepn2
   50 cdgl(j,1,1) = -h*cdgl(j,1,1)
*     ==================================================================
*      Boundary condition contribution to the Jacobian.
*     ==================================================================
      do 40 j=1,nbnod
      jbn = bnod(1,j)
      jbc = bnod(2,j)
      do 40 k=1,nepn
       if(bc(k,jbc) .eq. 1) then
        do 41 l = xadj(jbn), xadj(jbn+1) - 1
         do 41 i = 1, nepn
          jmtx(k,i,l) = 0.0
   41   continue
   
        do 42 i=1,nepn
         jdgl(k,i,jbn) = 0.0
         cdgl(k,i,jbn) = 0.0
   42   continue
        jdgl(k,k,jbn) = 1.0
        cdgl(k,k,jbn) = 1.0
        endif
   40 continue
*     ==================================================================
*      Diagonal preconditioning and factorization.
*     ==================================================================
      call vfct(nnod,  cdgl,  nepn)
      call vmslv(nnod, cdgl,jdgl,  nepn,nepn)
      do 60 j=1,nnod
       jbw = xadj(j+1) - xadj(j)
       call mslv(cdgl(1,1,j),jmtx(1,1,xadj(j)),  nepn,nepn*jbw)
   60 continue

      if(.true.) then
*       --------------------------------------------
*        Factorization for the block banded solver.
*       --------------------------------------------
*       Copy the compactly stored jacobian to banded storage.
        call cpmtx(nnod,xadj,adjncy,jmtx,jdgl,  bandw,s)
 
*       Compute the LU factorization.
        call bbfct(nnod,nepn,bandw,  s)

      else
C*       ----------------------------------------------
C*        Factorization for the block envelope solver.
C*       ----------------------------------------------
C*       Input the preconditioned jacobian to BENVPAK.
C        call inmtx(nnod,xadj,adjncy,jmtx,jdgl,  s)
C
C*       Compute the LU factorization.
C        call solve(s)
        endif

      errc = 0
      return
*     ==================================================================
*      Error return.
*     ==================================================================
  920 write(8,921) errc+itri-1, trix, triy
  921 format(/'** DFDY: Bad triangle -- no. ',i5,
     +       ' (',e12.5,',',e12.5,')')
      errc = 2
      return
      end
