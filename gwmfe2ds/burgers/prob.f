      subroutine psetup(t,y)
************************************************************************
*
*   PSETUP -- Problem set-up for the Skew Burgers' problem.
*
************************************************************************
      include "parameters.h"

      integer mcol,nepn
      parameter(mcol=17,nepn=npde+2)

      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision bv
      integer nbnod,bnod,bc
      common /mfe030/ bv(nepn,mbnd),nbnod,bnod(2,mbnd),bc(nepn,10)

      double precision t,y(4,mnod),pcx(mcol),pry(mcol),tau1,tau2,pi,a,b
      integer mtype,ncol,nrow,npc,nsc(mcol),npr,nsr(mcol),ramp0,ramp1
      integer n,i,j,ij,k
      character*8 label
      parameter(pi = 3.141592653589793)

*     ==================================================================
*      Read the problem-specific section of the input file.
*     ==================================================================

      read(5,*,err=910,end=920) label, mtype

      read(5,*,err=910,end=920) label, ncol
      if(ncol.lt.3)    call inperr('NCOL must be .ge. 3')
      if(ncol.gt.mcol) call inperr('NCOL is too large')

      read(5,*,err=910,end=920) label, nrow
      if(nrow.lt.3)    call inperr('NROW must be .ge. 3')
      if(nrow.gt.mcol) call inperr('NROW is too large')

      read(5,*,err=910,end=920) label, npc
      if(npc.lt.2)    call inperr('NPC must be .ge. 2')
      if(npc.gt.mcol) call inperr('NPC is too large')

      read(5,*,err=910,end=920) label, (pcx(j), j=1,npc)
      do 11 j=2,npc
   11 if(pcx(j).le.pcx(j-1)) call inperr('bad PCX values')

      read(5,*,err=910,end=920) label, (nsc(j), j=1,npc-1)
      do 12 j=1,npc-1
   12 if(nsc(j).lt.0) call inperr('bad NSC values')
      n = npc
      do 13 j=1,npc-1
   13 n = n + nsc(j)
      if(n.ne.ncol) call inperr('NCOL, NPC, and NSC are inconsistent')

      read(5,*,err=910,end=920) label, npr
      if(npr.lt.2)    call inperr('NPR must be .ge. 2')
      if(npr.gt.mcol) call inperr('NPR is too large')

      read(5,*,err=910,end=920) label, (pry(j), j=1,npr)
      do 21 j=2,npr
   21 if(pry(j).le.pry(j-1)) call inperr('bad PRY values')

      read(5,*,err=910,end=920) label, (nsr(j), j=1,npr-1)
      do 22 j=1,npr-1
   22 if(nsr(j).lt.0) call inperr('bad NSR values')
      n = npr
      do 23 j=1,npr-1
   23 n = n + nsr(j)
      if(n.ne.nrow) call inperr('NROW, NPR, and NSR are inconsistent')

      read(5,*,err=910,end=920) label, tau1
      read(5,*,err=910,end=920) label, tau2

      read(5,*,err=910,end=920) label, ramp0
      read(5,*,err=910,end=920) label, ramp1
      if(ramp0.lt.1.or.ramp0.ge.npr) call inperr('bad value for RAMP0')
      if(ramp1.le.1.or.ramp1.gt.npr) call inperr('bad value for RAMP1')
      if(ramp1.le.ramp0) call inperr('RAMP0 must be .lt. RAMP1')

*     ==================================================================
*      Compute the initial value of the unknown vector Y.
*     ==================================================================

      t = 0.
      a = pry(ramp0)
      b = pry(ramp1)

*     Compute the x-coord of the columns and y-coord of the rows.
      call filseg(npc-1,nsc,pcx)
      call filseg(npr-1,nsr,pry)

      do 30 j=1,nrow
      if(pry(j) .le. a) then
        do 31 i=1,ncol
         ij = i + ncol*(j-1)
         y(1,ij) = tau1*sin(pi*pcx(i))
         y(2,ij) = tau2*cos(pi*pcx(i)) + 1.
         y(3,ij) = pcx(i)
         y(4,ij) = pry(j)
   31   continue

      elseif(pry(j) .ge. b) then
        do 32 i=1,ncol
         ij = i + ncol*(j-1)
         y(1,ij) = -tau1*sin(pi*pcx(i))
         y(2,ij) =  tau2*cos(pi*pcx(i)) - 1.
         y(3,ij) = pcx(i)
         y(4,ij) = pry(j)
   32   continue

      else
        do 33 i=1,ncol
         ij = i + ncol*(j-1)
         y(1,ij) = tau1*sin(pi*pcx(i))*(1.-2.*(pry(j)-a)/(b-a))
         y(2,ij) = tau2*cos(pi*pcx(i))+(1.-2.*(pry(j)-a)/(b-a))
         y(3,ij) = pcx(i)
         y(4,ij) = pry(j)
   33   continue
        endif
   30 continue

*     ==================================================================
*     Generate the mesh structure (initializes MFE010-11).
*     ==================================================================

      nnod = ncol*nrow
      call trirg(ncol,nrow,mtype,  ntri,tvtx)

*     ==================================================================
*      Set-up the boundary conditions (initializes MFE030).
*     ==================================================================

*     ------------------------------------------
*      Initialize the boundary condition array.
*     ------------------------------------------
*     Type 1: Fixed nodes; Dirichlet conditions on u and v.
      bc(1,1) = 1
      bc(2,1) = 1
      bc(3,1) = 1
      bc(4,1) = 1

*     Type 2: Nodes sliding vertically; Dirichlet condition on u.
      bc(1,2) = 1
      bc(2,2) = 0
      bc(3,2) = 1
      bc(4,2) = 0
*     -----------------------------------------------------------
*      Generate the list of boundary nodes and pointers into BC.
*     -----------------------------------------------------------
*     Top and bottom boundaries.
      nbnod = 0
      do 40 i=1,ncol
       nbnod = nbnod + 1
       bnod(1,nbnod) = i
       bnod(2,nbnod) = 1

       nbnod = nbnod + 1
       bnod(1,nbnod) = i + ncol*(nrow-1)
       bnod(2,nbnod) = 1
   40 continue

*     Left and right boundaries.
      do 41 j=2,nrow-1
       nbnod = nbnod + 1
       bnod(1,nbnod) = ncol*j
       bnod(2,nbnod) = 2

       nbnod = nbnod + 1
       bnod(1,nbnod) = 1 + ncol*(j-1)
       bnod(2,nbnod) = 2
   41 continue

*     Initialize the boundary value array.
      do 42 k=1,nepn
      do 42 j=1,nbnod
   42 bv(k,j) = y(k,bnod(1,j))

      return
*     ==================================================================
*      File format errors.
*     ==================================================================
  910 write(8,911) label
  911 format(/'** PSETUP: Bad file format -- part of line:',a,
     +       /'** Aborting execution.')
      stop

  920 write(8,921)
  921 format(/'** PSETUP: Bad file format -- at EOF.',
     +       /'** Aborting execution.')
      stop
      end
      subroutine inperr(message)
************************************************************************
*
*  Write input error messages and exit.
*
************************************************************************
      character*(*) message

      write(8,100)  message(1:len(message))
  100 format(/'** PSETUP: Input error -- ',a,
     +       /'** Aborting execution.')

      stop
      end
