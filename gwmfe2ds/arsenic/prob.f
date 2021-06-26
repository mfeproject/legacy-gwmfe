      subroutine psetup(t,y)
************************************************************************
*
*   PSETUP -- Set-up the arsenic diffusion problem of Kent Smith.
*
************************************************************************
      include 'parameters.h'
      
      integer mcol
      parameter(mcol=17)

      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision bv
      integer nbnod,bnod,bc
      common /mfe030/ bv(3,mbnd),nbnod,bnod(2,mbnd),bc(3,10)

      double precision cscf,uscf,tscf,gamma,mu,d0,d1
      common /data1/ cscf,uscf,tscf,gamma,mu
      common /data2/ d0,d1
      save /data1/,/data2/

      double precision t,y(3,*),width,maskl,rowy(mcol)
      double precision cmin,cmax,ni
      double precision hpi,dx,dtheta,c,uofc,u0,r
      integer nxcel,nycel1,nycel2,icol,irow,n,node,j,k
      character*8 label

      parameter(hpi=1.57079632679490)
*     ==================================================================
*      Function definitions.
*     ==================================================================
*     Node numbering by row.
      node(icol,irow) = icol + (nxcel+1)*(irow-1)
     +                - max( 0 , abs(irow-nycel1)*(irow-nycel1-1)/2 )

*     Transformation of the scaled concentration.
      uofc(c) = (c/mu + log(c/mu) - gamma)/uscf

*     Initial profile for transformed variable.
      u0(r) = 1. - (r/width)

*     ==================================================================
*      Read the problem-specific section of the input file.
*     ==================================================================
      read(5,*,err=910,end=920) label, nxcel
      if(nxcel.le.0) call inperr('NXCEL must be .gt. 0')

      read(5,*,err=910,end=920) label, nycel1
      if(nycel1.le.0) call inperr('NYCEL1 must be .gt. 0')

      read(5,*,err=910,end=920) label, nycel2
      if(nycel2.le.0) call inperr('NYCEL2 must be .gt. 0')
      if(nycel2.gt.nxcel) call inperr('NYCEL2 must be .le. NXCEL')

      read(5,*,err=910,end=920) label, width

      read(5,*,err=910,end=920) label, (rowy(j), j=1,nycel1+1)
      rowy(1) = 0.
      do 110 j=1,nycel1
  110 if(rowy(j+1).le.rowy(j)) call inperr('Bad ROWY values')
      maskl = rowy(nycel1+1)

      read(5,*,err=910,end=920) label, mu

*     ==================================================================
*      Initialize data.
*     ==================================================================
      d0 = 7.3e-8
      d1 = 1.17e-7
      ni = 7.12e18

*     Minimum and maximum scaled concentrations.
      cscf = 2.*ni
      cmin = 1.e14/cscf
      cmax = 2.e21/cscf

*     Define transformation constants.
      gamma = 0.
      uscf  = 1.
      gamma = uofc(cmin)
      uscf  = uofc(cmax)

*     Define time scale factor.
      tscf = 1./(mu*uscf*4.*d1)

*     ==================================================================
*      Compute the initial value of the solution vector Y.
*     ==================================================================
      t = 0.

      dx = width/nxcel

      do 10 irow=1,nycel1+1
      do 10 icol=1,nxcel+1
      n = node(icol,irow)
      y(1,n) = u0((icol-1)*dx)
      y(2,n) = (icol-1)*dx
      y(3,n) = rowy(irow)
   10 continue

      do 20 icol=2,nxcel+1
      dtheta = hpi/min(icol-1,nycel2)
      do 20 irow=2,min(icol,nycel2+1)
      n = node(icol,nycel1+irow)
      y(1,n) = u0((icol-1)*dx)
      y(2,n) = (icol-1)*dx*cos((irow-1)*dtheta)
      y(3,n) = maskl + (icol-1)*dx*sin((irow-1)*dtheta)
   20 continue

*     ==================================================================
*      Generate the triangle and edge vertex lists and setup the
*      boundary conditions; initializes MFE010-12 and MFE030.
*     ==================================================================
      nnod = node(nxcel+1,nycel1+nycel2+1)

      call struct(nxcel,nycel1,nycel2)

*     Initialize the boundary value array.
      do 30 k=1,3
      do 30 j=1,nbnod
   30 bv(k,j) = y(k,bnod(1,j))

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

      close(5)
      return
      end
      subroutine struct(nxcel,nycel1,nycel2)
************************************************************************
*
*   STRUCT -- Generate the structure arrays and boundary condition
*             arrays for the following mesh.

*
*        Logical grid              Physical domain
*
*            c        d              d
*             *-+-+-*                  *
*            /|/|/|/|                  |\
*           +-+-+-+-+                  | \
*          /|/|/|/|/| NYCEL2         c *  \
*         +-+-+-+-+-+                  |\  \
*        /|/|/|/|/|/|       ===>       | \  \ 
*     b *-+-+-*-+-+-* e              b *--*--* e
*       |/|/|/|/|/|/|                  |  |  |
*       +-+-+-+-+-+-+ NYCEL1           |  |  |
*       |/|/|/|/|/|/|                  |  |  |
*       *-+-+-*-+-+-*                  *--*--*
*      a    NXCEL    f                a       f
*
*
*   Boundary Conditions
*   -------------------
*
*       3             1 -- Node fixed; c=cmax.
*        *            2 -- Nodes fixed; c=cmax.
*        |\           3 -- Node slides on y-axis; c=cmin.
*        | \          4 -- Node slides on x-axis; c=cmin.
*      7 |  \ 5       5 -- Nodes free; c=cmin.
*        |   \        6 -- Nodes slide on x-axis; no flow of c.
*        |    \       7 -- Nodes slide on y-axis; no flow of c.
*      1 *     *
*        |     | 5
*      2 |     |
*        |     |
*        *-----*
*       1   6   4
*
************************************************************************
      include 'parameters.h'
      
      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision bv
      integer nbnod,bnod,bc
      common /mfe030/ bv(3,mbnd),nbnod,bnod(2,mbnd),bc(3,10)

      integer nxcel,nycel1,nycel2,icol,irow,node

*     Node numbering by row.
      node(icol,irow) = icol + (nxcel+1)*(irow-1)
     +                - max( 0 , abs(irow-nycel1)*(irow-nycel1-1)/2 )

*     ==================================================================
*      Generate the triangle vertex list.
*     ==================================================================
      ntri=0
      do 110 irow=1,nycel1
      do 110 icol=1,nxcel
      ntri = ntri + 1
      tvtx(0,ntri) = node(icol,   irow)
      tvtx(1,ntri) = node(icol+1, irow)
      tvtx(2,ntri) = node(icol+1, irow+1)

      ntri = ntri + 1
      tvtx(0,ntri) = node(icol+1, irow+1)
      tvtx(1,ntri) = node(icol,   irow+1)
      tvtx(2,ntri) = node(icol,   irow)
  110 continue

      do 120 irow=1,nycel2
      ntri = ntri + 1
      tvtx(0,ntri) = node(irow,   nycel1+irow)
      tvtx(1,ntri) = node(irow+1, nycel1+irow)
      tvtx(2,ntri) = node(irow+1, nycel1+irow+1)
      do 120 icol=irow+1,nxcel
      ntri = ntri + 1
      tvtx(0,ntri) = node(icol,   nycel1+irow)
      tvtx(1,ntri) = node(icol+1, nycel1+irow)
      tvtx(2,ntri) = node(icol+1, nycel1+irow+1)

      ntri = ntri + 1
      tvtx(0,ntri) = node(icol+1, nycel1+irow+1)
      tvtx(1,ntri) = node(icol,   nycel1+irow+1)
      tvtx(2,ntri) = node(icol,   nycel1+irow)
  120 continue
*     ==================================================================
*      Initialize the boundary condition array BC.
*     ==================================================================
*     Index 1 -- c is given, nodes are fixed.
      bc(1,1) = 1
      bc(2,1) = 1
      bc(3,1) = 1

*     Index 2 -- c is given, nodes slide on y-axis.
      bc(1,2) = 1
      bc(2,2) = 1
      bc(3,2) = 0

*     Index 3 -- c is given, node slides on y-axis.
      bc(1,3) = 1
      bc(2,3) = 1
      bc(3,3) = 0

*     Index 4 -- c is given, node slides on x-axis.
      bc(1,4) = 1
      bc(2,4) = 0
      bc(3,4) = 1

*     Index 5 -- c is given, nodes are free (free boundary).
      bc(1,5) = 1
      bc(2,5) = 0
      bc(3,5) = 0

*     Index 6 -- no flow of c, nodes slide on x-axis.
      bc(1,6) = 0
      bc(2,6) = 0
      bc(3,6) = 1

*     Index 7 -- no flow of c, nodes slide on y-axis.
      bc(1,7) = 0
      bc(2,7) = 1
      bc(3,7) = 0
*     ==================================================================
*      Generate the list of boundary nodes and pointers into BC.
*     ==================================================================
      bnod(1,1) = node(1,1)
      bnod(2,1) = 1
      bnod(1,2) = node(1,nycel1+1)
      bnod(2,2) = 1
      nbnod = 2

      do 410 irow=2,nycel1
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(1,irow)
      bnod(2,nbnod) = 2
  410 continue

      nbnod = nbnod + 1
      bnod(1,nbnod) = node(nxcel+1,nycel1+nycel2+1)
      bnod(2,nbnod) = 3

      nbnod = nbnod + 1
      bnod(1,nbnod) = node(nxcel+1,1)
      bnod(2,nbnod) = 4

      do 420 irow=2,nycel1+nycel2
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(nxcel+1,irow)
      bnod(2,nbnod) = 5
  420 continue

      do 430 icol=2,nxcel
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(icol,1)
      bnod(2,nbnod) = 6
  430 continue

      do 440 irow=2,nycel2
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(irow,nycel1+irow)
      bnod(2,nbnod) = 7
  440 continue

      do 450 icol=nycel2+1,nxcel
      nbnod = nbnod + 1
      bnod(1,nbnod) = node(icol,nycel1+nycel2+1)
      bnod(2,nbnod) = 7
  450 continue

      return
      end
