      subroutine psetup(t,y)
************************************************************************
*
*   PSETUP -- Problem set-up for the semiconductor test problem.
*
************************************************************************
      include "parameters.h"
      
      integer nepn,mcol
      parameter(nepn=npde+2,mcol=40)

      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision bv
      integer nbnod,bnod,bc
      common /mfe030/ bv(nepn,mbnd),nbnod,bnod(2,mbnd),bc(nepn,10)

      double precision uscf,vscf
      common /data1/ uscf,vscf

      double precision t,y(4,mnod),pcx(mcol),pry(mcol)
      double precision pgate,vgate,vcoll,p,u0,r,width,r0
      integer mtype,ncol,nrow,npc,nsc(mcol),npr,nsr(mcol)
      integer grow,crow,gstop,cbegn,node,icol,irow,n,j,k,restart
      character*8 label
*     ==================================================================
*      Function definitions.
*     ==================================================================
*     Node numbering by row.
      node(icol,irow) = icol + ncol*(irow-1)

*     Initial profile for the transformed variable.
      u0(r) = 1. - (3. - 2.*(r/width))*(r/width)**2
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

      read(5,*,err=910,end=920) label, grow
      if(grow.le.1 .or. grow.ge.npr) call inperr('bad value for GROW')

      read(5,*,err=910,end=920) label, crow
      if(crow.le.grow.or.crow.ge.npr) call inperr('bad value for CROW')

      read(5,*,err=910,end=920) label, r0
      read(5,*,err=910,end=920) label, width
      read(5,*,err=910,end=920) label, pgate
      read(5,*,err=910,end=920) label, vgate
      read(5,*,err=910,end=920) label, vscf

      read(5,*,err=910,end=920) label, restart
      print *, "restart=",restart

*     Column number of the end of the gate.
      gstop = 1
      do 130 irow=1,grow-1
  130 gstop = gstop + nsr(irow) + 1

*     Column number of the beginning of the collector.
      cbegn = 1
      do 131 irow=1,crow-1
  131 cbegn = cbegn + nsr(irow) + 1

*     ==================================================================
*      Compute the initial value of the solution vector Y.
*     ==================================================================
      vcoll = 0.
      vgate = vgate/vscf

*     Define transformation constants.
      uscf = -log(pgate)

*     Compute the x-coord of the columns and y-coord of the rows.
      call filseg(npc-1,nsc,pcx)
      call filseg(npr-1,nsr,pry)

      do 30 irow=1,nrow
      do 30 icol=1,ncol

      n = node(icol,irow)
      y(3,n) = pcx(icol)
      y(4,n) = pry(irow)

      if(y(3,n) .le. r0) then
        y(1,n) = 1.
      elseif(y(3,n) .lt. r0+width) then
        y(1,n) = u0(y(3,n)-r0)
      else
        y(1,n) = 0.
        endif

      r = y(4,n) - pry(gstop)
      if(r .le. r0) then
        y(1,n) = -1.*y(1,n)
      elseif(r .lt. r0+width) then
        y(1,n) = -u0(r-r0)*y(1,n)
      else
        y(1,n) = 0.
        endif
   30 continue

      if(restart.ne.0) then
	print *,"Reading mfedat"
	open(4,file="mfedat",form="unformatted")
	read(4) t, ((y(k,j), k=1,nepn), j=1,ncol*nrow)
	close(4)
	endif

      t = 0.

*     ==================================================================
*      Generate the triangle vertex list; initializes MFE010-11.
*     ==================================================================
      nnod = ncol*nrow
      call trirg(ncol,nrow,mtype,  ntri,tvtx)

*     ==================================================================
*      Set-up the boundary conditions;  initializes MFE030.
*     ==================================================================
*     ------------------------------------------
*      Initialize the boundary condition array.
*     ------------------------------------------
*     Index 1: Dirichlet conditions on u and v; nodes fixed.
      bc(1,1) = 1
      bc(2,1) = 1
      bc(3,1) = 1
      bc(4,1) = 1

*     Index 2: Dirichlet conditions on u and v; node x-coord fixed.
      bc(1,2) = 1
      bc(2,2) = 1
      bc(3,2) = 1
      bc(4,2) = 0

*     Index 3: Dirichlet conditions on u and v; node y-coord fixed.
      bc(1,3) = 1
      bc(2,3) = 1
      bc(3,3) = 0
      bc(4,3) = 1

*     Index 4: Nodes fixed.
      bc(1,4) = 0
      bc(2,4) = 0
      bc(3,4) = 1
      bc(4,4) = 1

*     Index 5: Node x-coordinates fixed.
      bc(1,5) = 0
      bc(2,5) = 0
      bc(3,5) = 1
      bc(4,5) = 0

*     Index 6: Node y-coordinates fixed.
      bc(1,6) = 0
      bc(2,6) = 0
      bc(3,6) = 0
      bc(4,6) = 1
*     -----------------------------------------------------------
*      Generate the list of boundary nodes and pointers into BC.
*     -----------------------------------------------------------
*     Bottom boundary.
      nbnod = 0
      do 40 icol=2,ncol-1
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(icol,1)
       bnod(2,nbnod) = 6
   40 continue

*     Right boundary.
      do 41 irow=2,nrow-1
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(ncol,irow)
       bnod(2,nbnod) = 5
   41 continue

*     Bottom right and top right corner nodes.
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(ncol,1)
      bnod(2,nbnod) = 4
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(ncol,nrow)
      bnod(2,nbnod) = 4

*     Gate boundary.
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(1,1)
      bnod(2,nbnod) = 1
      bv(2,nbnod) = vgate
      do 42 irow=2,gstop-1
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(1,irow)
       bnod(2,nbnod) = 2
       bv(2,nbnod) = vgate
   42 continue
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(1,gstop)
      bnod(2,nbnod) = 1
      bv(2,nbnod) = vgate

*     Collector boundary.
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(1,cbegn)
      bnod(2,nbnod) = 1
      bv(2,nbnod) = vcoll
      do 43 irow=cbegn+1,nrow-1
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(1,irow)
       bnod(2,nbnod) = 2
       bv(2,nbnod) = vcoll
   43 continue
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(1,nrow)
      bnod(2,nbnod) = 1
      bv(2,nbnod) = vcoll

*     Remaining left boundary nodes.
      do 44 irow=gstop+1,cbegn-1
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(1,irow)
       bnod(2,nbnod) = 5
   44 continue

*     Top boundary nodes.
      do 45 icol=2,ncol-1
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(icol,nrow)
       bnod(2,nbnod) = 6
   45 continue

*     Initialize the boundary value array.
      do 46 j=1,nbnod
       bv(1,j) = y(1,bnod(1,j))
       bv(3,j) = y(3,bnod(1,j))
       bv(4,j) = y(4,bnod(1,j))
   46 continue

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
