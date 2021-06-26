      subroutine init(t,y,z)
************************************************************************
*
*   INIT -- MFE2 initialization.
*
************************************************************************
      include "parameters.h"

      integer nepn
      parameter(nepn=npde+2)

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

      integer j,k,errc
      double precision t,y(*),z(*)

      call rdhead
      call psetup(t,y)
      call rdvars
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
        open(9,file='bdfout')
        endif
*     ==================================================================
*      Initialize the linear equations solver.
*     ==================================================================
*     Find adjacency structure of the mesh, using S as a temporary.
      call fnadjt(ntri,tvtx,  nnod,xadj,adjncy,2*medg,  s,errc)

*     ---------------------------------
*      Initialization for band solver.
*     ---------------------------------
*     Compute the bandwidth of the MFE equations.
      bandw = 0
      do 20 k=0,2
      do 20 j=1,ntri
   20 bandw = max( bandw, abs(tvtx(mod(k+1,3),j)-tvtx(k,j)) )

*     Solve for the pressure initially.
      call pressure(y,bandw,  s)

*     Output the initial value of the solution vector.
      call wrhead
      call wrsoln(t,y)
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
