      subroutine init(t,y,z)
************************************************************************
*
*   INIT -- MFE2 initialization.
*
************************************************************************
      include "parameters.h"
      
      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision s
      integer bandw,xadj,adjncy
      common /mfe040/ s(smax),bandw,xadj(mnod+1),adjncy(2*medg)

      double precision tout
      integer nout,ofreq,mstep,imsg
      common /mfe050/ tout(50),nout,ofreq,mstep,imsg

      integer mtry,mitr,mvec
      double precision h,hlb,ntol,margin,vtol
      common /mfe062/ h,hlb,ntol,margin,vtol,mtry,mitr,mvec

      integer stats
      double precision hlast
      real cpusec
      common /mfe070/ hlast,cpusec,stats(8)

      integer salloc,error
      common /pfl0/ salloc,error
      save /pfl0/

      double precision cscf,uscf,tscf,gamma,mu
      common /data1/ cscf,uscf,tscf,gamma,mu
      save /data1/

      integer j,k,errc,sreq
      double precision t,y(*),z(*)

      call rdhead
      call psetup(t,y)
      call rdvars

*     Scale time variables.
      t = t/tscf
      h = h/tscf
      hlb = hlb/tscf
      do 5 j=1,nout
    5 tout(j) = tout(j)/tscf

*     Output the initial value of the solution vector.
      call wrhead
      call wrsoln(t,y)
*     ==================================================================
*      Initialize BDF2 parameters.
*     ==================================================================
      mtry = 9

      hlast = 0.
      cpusec = 0.
      do 10 j=1,8
   10 stats(j) = 0

      if(imsg .gt. 0) then
        call mbdf2(imsg,9)
        open(9,file="bdfout")
        endif
*     ==================================================================
*      Initialize the linear equations solver.
*     ==================================================================
*     Find adjacency structure of the mesh, using S as a temporary.
      call fnadjt(ntri,tvtx,  nnod,xadj,adjncy,2*medg,  s,errc)

      if(.true.) then
*       ---------------------------------
*        Initialization for band solver.
*       ---------------------------------
*       Compute the bandwidth of the MFE equations.
        bandw = 0
        do 20 k=0,2
        do 20 j=1,ntri
   20   bandw = max( bandw, abs(tvtx(mod(k+1,3),j)-tvtx(k,j)) )

      sreq = 9*nnod*(2*bandw+1)
      if(smax .lt. sreq) then
        write(8,fmt='(a,i9)') "** SMAX too small; must be at least ",
     +                           sreq
        stop
      endif
       
      else
C*       -------------------------------------
C*        Initialization for envelope solver.
C*       -------------------------------------
C*       Communicate the size of the array S to BENVPAK.
C        salloc = smax
C
C*       Input the nonzero structure of the MFE matrix.
C        call ijbegn
C        do 30 k=0,2
C        do 30 j=1,ntri
C   30   call inij(tvtx(mod(k+1,3),j),tvtx(k,j),  s)
C        call ijend(s)
C
C*       Find a good ordering of the nodes.
C        call order(3,s)
C        call bpstat(8)
C        if(error .ne. 0) then
C          write(8,912) error
C  912     format(/'** INIT: BENVPAK returns error code ',i2,
C     +           /'** Aborting execution.')
C          stop
C          endif
C        if(imsg .gt. 0) then
C          open(10,file="mtx.tex")
C          call prnonz(10,xadj,adjncy,s)
C          close(10)
C          endif
        endif
*     ==================================================================
*      Compute the initial value of dy/dt.
*     ==================================================================
      call ydot(y,t,  z,errc)
      if(errc .ne. 0) then
        write(8,911)
  911   format(/'** INIT: Initial solution vector is inadmissible.',
     +         /'** Aborting execution.')
        stop
        endif

      return
      end
