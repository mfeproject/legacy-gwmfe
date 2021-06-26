      subroutine ydot(y,t,  z,  errc)
************************************************************************
*
*   YDOT -- Solve C(y)*dy/dt = g(y,t) for dy/dt.
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

      double precision t,y(*),z(nepn,*)
      double precision trix,triy
      double precision c(nepn,nepn,2*medg),cdgl(nepn,nepn,mnod)
      integer errc,j,k,itri,vl,jbn,jbc,i,l,ll,nbr

      integer salloc,error
      common /pfl0/ salloc,error
      save /pfl0/

      double precision ONE
      integer FULL
      parameter(ONE=1.0d0, FULL=0)
*     ==================================================================
*      Compute the MFE equations.
*     ==================================================================
*     Zero the mass matrix initially.
      do 10 j=1,nepn2*(xadj(nnod+1)-1)
   10 c(j,1,1) = 0.

      do 11 j=1,nnod*nepn2
   11 cdgl(j,1,1) = 0.

*     Zero the RHS vector initially.
      do 20 j=1,nnod*nepn
   20 z(j,1) = 0.
*     --------------------------------------------------
*      Compute the MFE equations 64 elements at a time.
*     --------------------------------------------------
      do 30 itri=1,ntri,64
       vl = min(64, ntri-itri+1)

*      Gather the local unknown vectors.
       call gthvec(vl,itri,y,z)

*      Compute frequently used local quantities.
       call locpp(vl,  errc,trix,triy)
       if(errc .ne. 0) go to 910

*      Compute the local mass matrix and scatter.
       call cmtx(vl,ONE,FULL)
       call sctmtx(vl,itri,xadj,adjncy,  c,cdgl)

*      Compute the local RHS vector and scatter.
       call pderhs(vl)
       call regrhs(vl)
       call sctvec(vl,itri,  z)
   30 continue
*     ==================================================================
*      Boundary condition contribution to the MFE equations.
*     ==================================================================
      do 40 j=1,nbnod
       jbn = bnod(1,j)
       jbc = bnod(2,j)
       do 41 k=1,nepn
        if(bc(k,jbc) .eq. 1) then
         do 42 l=xadj(jbn),xadj(jbn+1)-1
          do 43 i=1,nepn
           c(k,i,l) = 0.0d0
   43     continue
          nbr = adjncy(l)
          do 44 ll=xadj(nbr),xadj(nbr+1)-1
           if (adjncy(ll) .eq. jbn) then
            do 45 i=1,nepn
             c(i,k,ll) = 0.0d0
   45       continue
            go to 42
           endif
   44     continue
          print *, 'ydot: PANIC!'
   42    continue
         do 46 i=1,nepn
          cdgl(i,k,jbn) = 0.0d0
          cdgl(k,i,jbn) = 0.0d0
   46    continue
         cdgl(k,k,jbn) = 1.0d0
         z(k,jbn) = 0.0d0
        endif
   41  continue
   40 continue
*     ==================================================================
*      Solve for dy/dt.
*     ==================================================================
      if(.true.) then
*       ----------------------
*        Block banded solver.
*       ----------------------
*       Copy the mass matrix to banded storage and solve.
        call cpmtx(nnod,xadj,adjncy,c,cdgl,  bandw,s)
        call bbfct(nnod,nepn,bandw,  s)
        call bbslv(nnod,nepn,bandw,s,  z)

      else
C*       ------------------------
C*        Block envelope solver.
C*       ------------------------
C*       Input the mass matrix to BENVPAK.
C        call inmtx(nnod,xadj,adjncy,c,cdgl,  s)
C        if(error .ne. 0) go to 920
C
C*       Input RHS vector to BENVPAK and solve.
C        call inrhs(z,  s)
C        if(error .ne. 0) go to 920
C        call solve(s)
C
C*       Copy solution from S.
C        do 50 j=1,nnod*nepn
C   50   z(j) = s(j)
        endif

      errc = 0
      return
*     ==================================================================
*      Error returns.
*     ==================================================================
  910 write(8,911) errc+itri-1, trix, triy
  911 format(/'** YDOT: Bad triangle -- no. ',i5,
     +       ' (',e12.5,',',e12.5,')')
      errc = 1
      return

  920 write(8,921) error
  921 format(/'** YDOT: BENVPAK returns error code ',i2)
      errc = 2
      return
      end
