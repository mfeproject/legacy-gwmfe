      subroutine init(y,z,t)
************************************************************************
*
*  INIT -- Initialization routine.
*
************************************************************************
      include "parameters.h"

      integer nnod,nelt
      common /mfe010/ nnod,nelt

      double precision wpde
      common /mfe020/ wpde(npde)

      double precision bvl,bvr
      integer bcl,bcr
      common /mfe030/ bcl(nepn),bcr(nepn),bvl(nepn),bvr(nepn)

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

      double precision yseg
      integer nseg,niseg
      common /tmp020/ nseg,niseg(mnod),yseg(nepn,mnod)

      integer errc,j,k
      double precision y(nepn,*),z(nepn,*),t

*     Open the input and output files.
      open(5,file='mfein')
      open(6,file='mfelog')
      open(7,file='mfegrf')

*     Read the input file and echo to the log file.
      call rdvars

*     Compute the initial solution vector y and output it.
      t = tout(1)
      call ivals(y)
      call wrgrf(y,t)

*     No weighting for a scalar PDE.
      if(npde .eq. 1) wpde(1) = 1.

c*     Set flags to fix the boundary nodes.
c      bcl(nepn) = 1
c      bcr(nepn) = 1

*     Save the initial boundary values.
      do 10 k=1,nepn
       bvl(k) = y(k,1)
       bvr(k) = y(k,nnod)
   10 continue
*     ==================================================================
*      Initialize BDF2 parameters.
*     ==================================================================
      mtry = 9
      if(imsg .gt. 0) then
        open(9,file='bdfout')
        call mbdf2(imsg,9)
        endif

*     Initialize the status variables.
      hlast = 0.
      cpusec = 0.
      do 20 j=1,8
   20 stats(j) = 0
*     ==================================================================
*      Compute the initial value of dy/dt.
*     ==================================================================
      call ydot(y,t,  z,errc)
      if(errc .ne. 0) then
        write(6,911)
  911   format(/'** INIT: Initial solution vector is bad.',
     +         /'** Aborting execution.')
        stop
        endif

      return
      end
