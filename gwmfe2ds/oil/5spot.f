      subroutine psetup(t,y)
************************************************************************
*
*   PSETUP -- Set-up the 5-spot Buckley-Leverett problem.
*
************************************************************************
      include "parameters.h"

      integer mcol
      parameter(mcol=33)

      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision bv
      integer nbnod,bnod,bc
      common /mfe030/ bv(4,mbnd),nbnod,bnod(2,mbnd),bc(4,10)

      double precision pscf
      common /data1/ pscf

      double precision t,y(4,*)

      double precision prad1(mcol),prad2(mcol),pinj,width
      integer mtype,ncol,nrow,nrad1,nrad2,npr1,npr2
      integer nsr1(mcol),nsr2(mcol)

      integer n,node,icol,irow,j
      double precision s0,r,d1,d2
      character*8 label

*     ==================================================================
*      Function definitions.
*     ==================================================================
*     Node numbering by row.
      node(icol,irow) = icol + ncol*(irow-1)

*     Initial profile for the saturation of H2O.
      s0(r) = max(1.d0 - (r-prad2(1))/width, 0.d0)

*     ==================================================================
*      Read the problem-specific section of the input file.
*     ==================================================================
      read(5,*,err=910,end=920) label, mtype

      read(5,*,err=910,end=920) label, ncol
      if(ncol.lt.3) call inperr('NCOL must be .ge. 3')
      if(ncol.gt.mcol) call inperr('NCOL is too large')

      read(5,*,err=910,end=920) label, nrad1
      if(nrad1.lt.1) call inperr('NRAD1 must be .ge. 1')

      read(5,*,err=910,end=920) label, npr1
      if(npr1.lt.2)    call inperr('NPR1 must be .ge. 2')
      if(npr1.gt.mcol) call inperr('NPR1 is too large')

      read(5,*,err=910,end=920) label, (prad1(j), j=1,npr1)
      do 11 j=2,npr1
   11 if(prad1(j).le.prad1(j-1)) call inperr('bad PRAD1 values')
      if(prad1(1).le.0.) call inperr('PRAD1(1) must be .gt. 0')
      if(prad1(npr1).ge.sqrt(.5)) call inperr('PRAD1(NPR1) is too big')

      read(5,*,err=910,end=920) label, (nsr1(j), j=1,npr1-1)
      do 12 j=1,npr1-1
   12 if(nsr1(j).lt.0) call inperr('bad NSR1 values')
      n = npr1
      do 13 j=1,npr1-1
   13 n = n + nsr1(j)
      if(n.ne.nrad1) call inperr('NRAD1, NPR1, NSR1 are inconsistent')

      read(5,*,err=910,end=920) label, nrad2
      if(nrad2.lt.1) call inperr('NRAD2 must be .ge. 0')

      read(5,*,err=910,end=920) label, npr2
      if(npr2.lt.2)    call inperr('NPR2 must be .ge. 2')
      if(npr2.gt.mcol) call inperr('NPR2 is too large')

      read(5,*,err=910,end=920) label, (prad2(j), j=1,npr2)
      do 15 j=2,npr2
   15 if(prad2(j).le.prad2(j-1)) call inperr('bad PRAD2 values')
      if(prad2(1).le.0.) call inperr('PRAD2(1) must be .gt. 0')
      if(prad2(npr2).ge.sqrt(.5)) call inperr('PRAD2(NPR2) is too big')

      read(5,*,err=910,end=920) label, (nsr2(j), j=1,npr2-1)
      do 16 j=1,npr2-1
   16 if(nsr2(j).lt.0) call inperr('bad NSR2 values')
      n = npr2
      do 17 j=1,npr2-1
   17 n = n + nsr2(j)
      if(n.ne.nrad2) call inperr('NRAD2, NPR2, NSR2 are inconsistent')

      nrow = nrad1 + nrad2 + 1
      if(nrow.gt.mcol) call inperr('NRAD1+NRAD2 is too large')

      read(5,*,err=910,end=920) label, pinj
      read(5,*,err=910,end=920) label, pscf
      read(5,*,err=910,end=920) label, width

*     ==================================================================
*      Compute the initial value of the solution vector Y.
*     ==================================================================
      d1 = 2.*atan(1.)/(ncol-1)
      d2 = 1./(ncol-1)
      t = 0.

      call filseg(npr1-1,nsr1,prad1)
      call filseg(npr2-1,nsr2,prad2)

      do 20 icol=1,ncol

       do 22 irow=1,nrad1
        n = node(icol,irow)
        y(1,n) = 0.
        y(3,n) = prad1(irow)*sin(d1*(icol-1))
        y(4,n) = prad1(irow)*cos(d1*(icol-1))
   22  continue

       n = node(icol,nrad1+1)
       y(1,n) = 0.
       y(3,n) = d2*(icol-1)
       y(4,n) = 1. - d2*(icol-1)

       do 21 irow=nrad1+2,nrow
        n = node(icol,irow)
        y(1,n) = s0(prad2(nrow-irow+1))
        y(3,n) = 1. - prad2(nrow-irow+1)*cos(d1*(icol-1))
        y(4,n) = 1. - prad2(nrow-irow+1)*sin(d1*(icol-1))
   21  continue

   20 continue

*     ==================================================================
*      Generate the triangle vertex list; initializes MFE010-11.
*     ==================================================================
      nnod = ncol*nrow
      call trirg(ncol,nrow,mtype,  ntri,tvtx)

*     ==================================================================
*      Set-up the boundary conditions; initializes MFE030.
*     ==================================================================
*     ------------------------------------------
*      Initialize the boundary condition array.
*     ------------------------------------------
*     Index 1: Dirichlet conditions on s and p; nodes fixed.
      bc(1,1) = 1
      bc(2,1) = 1
      bc(3,1) = 1
      bc(4,1) = 1

*     Index 2: Node x-coordinates fixed.
      bc(1,2) = 0
      bc(2,2) = 0
      bc(3,2) = 1
      bc(4,2) = 0

*     Index 3: Node y-coordinates fixed.
      bc(1,3) = 0
      bc(2,3) = 0
      bc(3,3) = 0
      bc(4,3) = 1

*     Index 4: Nodes fixed.
      bc(1,4) = 0
      bc(2,4) = 0
      bc(3,4) = 1
      bc(4,4) = 1
*     -----------------------------------------------------------
*      Generate the list of boundary nodes and pointers into BC.
*     -----------------------------------------------------------
      nbnod = 0

*     Production well.
      do 31 icol=1,ncol
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(icol,1)
       bnod(2,nbnod) = 1
       bv(2,nbnod) = 0.
   31 continue

*     Injection well.
      do 32 icol=1,ncol
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(icol,nrow)
       bnod(2,nbnod) = 1
       bv(2,nbnod) = pinj/pscf
   32 continue

*     West and south boundaries.
      do 33 irow=2,nrad1
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(1,irow)
       bnod(2,nbnod) = 2

       nbnod = nbnod + 1
       bnod(1,nbnod) = node(ncol,irow)
       bnod(2,nbnod) = 3
   33 continue

*     North and east boundaries.
      do 34 irow=nrad1+2,nrow-1
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(1,irow)
       bnod(2,nbnod) = 3

       nbnod = nbnod + 1
       bnod(1,nbnod) = node(ncol,irow)
       bnod(2,nbnod) = 2
   34 continue

*     Northwest corner node.
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(1,nrad1+1)
      bnod(2,nbnod) = 4

*     Southeast corner node.
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(ncol,nrad1+1)
      bnod(2,nbnod) = 4
*     --------------------------------------
*      Initialize the boundary value array.
*     --------------------------------------
      do 30 j=1,nbnod
       bv(1,j) = y(1,bnod(1,j))
       bv(3,j) = y(3,bnod(1,j))
       bv(4,j) = y(4,bnod(1,j))
   30 continue

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
