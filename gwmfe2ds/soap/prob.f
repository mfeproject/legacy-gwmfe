      subroutine psetup(t,y)
************************************************************************
*
*   PSETUP -- Set-up for the "Gouda cheese" problem of motion by
*             mean curvature.
*
************************************************************************
      include "parameters.h"
      
      integer mcol,npde,nepn
      parameter(mcol=33,npde=1,nepn=npde+2)

      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision bv
      integer nbnod,bnod,bc
      common /mfe030/ bv(nepn,mbnd),nbnod,bnod(2,mbnd),bc(nepn,10)

      double precision t,y(nepn,mnod),pcx(mcol),pry(mcol)
      integer mtype,ncol,nrow,npc,nsc(mcol),npr,nsr(mcol)
      integer node,n,j,k,icol,irow
      character*8 label

*     ==================================================================
*      Function definitions.
*     ==================================================================
*     Node numbering by row.
      node(icol,irow) = icol + ncol*(irow-1)

*     ==================================================================
*      Read the problem-specific section of the input file.
*     ==================================================================

      read(5,*,err=910,end=920) label, mtype

      read(5,*,err=910,end=920) label, npc
      if(npc.lt.2)    call inperr('NPC must be .ge. 2')
      if(npc.gt.mcol) call inperr('NPC is too large')

      read(5,*,err=910,end=920) label, (pcx(j), j=1,npc)
      do 11 j=2,npc
   11 if(pcx(j).le.pcx(j-1)) call inperr('bad PCX values')

      read(5,*,err=910,end=920) label, (nsc(j), j=1,npc-1)
      do 12 j=1,npc-1
   12 if(nsc(j).lt.0) call inperr('bad NSC values')
      ncol = npc
      do 13 j=1,npc-1
   13 ncol = ncol + nsc(j)
      if(ncol.lt.3)    call inperr('NCOL must be .ge. 3')
      if(ncol.gt.mcol) call inperr('NCOL is too large')

      read(5,*,err=910,end=920) label, npr
      if(npr.lt.2)    call inperr('NPR must be .ge. 2')
      if(npr.gt.mcol) call inperr('NPR is too large')

      read(5,*,err=910,end=920) label, (pry(j), j=1,npr)
      do 21 j=2,npr
   21 if(pry(j).le.pry(j-1)) call inperr('bad PRY values')

      read(5,*,err=910,end=920) label, (nsr(j), j=1,npr-1)
      do 22 j=1,npr-1
   22 if(nsr(j).lt.0) call inperr('bad NSR values')
      nrow = npr
      do 23 j=1,npr-1
   23 nrow = nrow + nsr(j)
      if(nrow.lt.3)    call inperr('NROW must be .ge. 3')
      if(nrow.gt.mcol) call inperr('NROW is too large')

*     ==================================================================
*      Compute the initial value of the unknown vector Y.
*     ==================================================================

      t = 0.

*     Compute the x-coord of the columns and y-coord of the rows.
      call filseg(npc-1,nsc,pcx)
      call filseg(npr-1,nsr,pry)

      do 30 irow=1,nrow
      do 30 icol=1,ncol
       n = node(icol,irow)
       y(2,n) = pcx(icol)
       y(3,n) = pry(irow)
       y(1,n) = 0.
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
*     Type 1: Fix x.
      bc(1,1) = 0
      bc(2,1) = 1
      bc(3,1) = 0

*     Type 2: Fix y.
      bc(1,2) = 0
      bc(2,2) = 0
      bc(3,2) = 1

*     Type 3: Fix z.
      bc(1,3) = 1
      bc(2,3) = 0
      bc(3,3) = 0

*     Type 4: Fix x and y.
      bc(1,4) = 0
      bc(2,4) = 1
      bc(3,4) = 1

*     Type 5: Fix x and z.
      bc(1,5) = 1
      bc(2,5) = 1
      bc(3,5) = 0

*     Type 6: Fix y and z.
      bc(1,6) = 1
      bc(2,6) = 0
      bc(3,6) = 1

*     Type 7: Fix x, y, and z.
      bc(1,7) = 1
      bc(2,7) = 1
      bc(3,7) = 1
*     -----------------------------------------------------------
*      Generate the list of boundary nodes and pointers into BC.
*     -----------------------------------------------------------
*     Corner nodes.
      bnod(1,1) = node(1,1)
      bnod(2,1) = 7
      bnod(1,2) = node(ncol,1)
      bnod(2,2) = 7
      bnod(1,3) = node(1,nrow)
      bnod(2,3) = 7
      bnod(1,4) = node(ncol,nrow)
      bnod(2,4) = 4

*     Remaining nodes.
      nbnod = 4
      do 40 icol=2,ncol-1
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(icol,1)
       bnod(2,nbnod) = 6

       nbnod = nbnod + 1
       bnod(1,nbnod) = node(icol,nrow)
       bnod(2,nbnod) = 2
   40 continue

      do 41 irow=2,nrow-1
       nbnod = nbnod + 1
       bnod(1,nbnod) = node(1,irow)
       bnod(2,nbnod) = 5

       nbnod = nbnod + 1
       bnod(1,nbnod) = node(ncol,irow)
       bnod(2,nbnod) = 1
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
