      program mkgrf

      integer mpde,mnod
      parameter(mpde=4,mnod=500)

      double precision t,y((mpde+2)*mnod),size
      integer npde,nnod,n
      character*24 title(4)

  110 format(a,$)
  120 format(a,i3,a,g13.5)
  130 format(a)

      write(6,*) "Domain size: "
      read(5,*) size

      call rdhead(npde,nnod,  *910,*920)

      n = 0
   10 n = n + 1
      call rdsoln(nnod,npde,size,  t,y,title,  *20,*910)
      call wrsoln(nnod+1,npde,t,y,title)
      write(6,120) 'Frame', n, ') Time =', t
      go to 10

   20 write(6,130) 'GP2 data file written on "mfegrf".'
      stop

***** Bad file formats.
  910 write(6,130) '** Error -- Bad format for "mfeout".'
      stop

  920 write(6,130) '** Error -- Bad format for ".gp2lbl".'
      stop
      end
      subroutine rdhead(npde,nnod,  *,*)
************************************************************************
*
*   This routine reads the top portion (up to the first solution) of
*   the 'mfeout' file produced by MFE2, gathering the information
*   needed for GP2 and writes the header for the GP2 datafile.
*
*     npde,nnod,nedg,ntri -- the number of components, nodes, edges,
*               and triangles.
*     evtx -- the list of edge endpoints.
*     tvtx -- the list of triangle vertices.
*     title -- character array of four title strings displayed by GP2.
*               See the documentation of GP2 for their use.
*     label -- character array on descriptive labels, one for each
*               component (u, v, ...).  See the documentation on GP2
*               for their use.
*
*   The alternate return is taken if the EOF or an error is encountered
*   on any of the reads.  This indicates that either the file is not in
*   the correct 'mfeout' format, or that the file was not properly
*   positioned initially.
*
************************************************************************
      integer mpde,mnod,mtri,medg
      parameter(mpde=4,mnod=500,mtri=2*mnod,medg=3*mnod)

      integer npde,nnod,nedg,ntri,tvtx(0:2,mtri),evtx(0:1,medg),i,j,k
      integer edg0,edg1
      character*24 title(4),label(mpde)

*     Read data file header.
      open(4,file='mfeout',form='unformatted')
      read(4,end=910,err=910) npde,nnod,ntri
      read(4,end=910,err=910) ((tvtx(k,j),k=0,2), j=1,ntri)

*     Read the label file.
      open(3,file=".gp2lbl")
      read(3,*,end=920,err=920) title(1), (label(k), k=1,npde)
      close(3)

*     Set the remaining title strings.
      title(2) = '-'
      title(3) = '-'
      title(4) = '-'

*     Generate the list of edges.
      nedg = 0
      do 10 j=1,ntri
      do 10 k=0,2
       edg0 = tvtx(k,j)
       edg1 = tvtx(mod(k+1,3),j)
       do 11 i=1,nedg
   11  if(evtx(1,i) .eq. edg0 .and. evtx(0,i) .eq. edg1) go to 10
       nedg = nedg + 1
       evtx(0,nedg) = edg0
       evtx(1,nedg) = edg1
   10 continue

  100 format(a)
  110 format(1x,i5)
  120 format((2(1x,i5)))
  130 format((3(1x,i5)))

*     Write the header portion of the GP2 data file.
      open(7,file='mfegrf')
      write(7,100) (title(j), j=1,4)
      write(7,110) npde
      write(7,100) (label(k), k=1,npde)
      write(7,130) nnod+1,nedg,ntri
      write(7,120) ((evtx(k,j), k=0,1), j=1,nedg)
      write(7,130) ((tvtx(k,j), k=0,2), j=1,ntri)

      return

***** Bad file format.
  910 return 1

***** Bad .gp2lbl file.
  920 return 2
      end
      subroutine rdsoln(nnod,npde,size,  t,y,label,  *,*)
************************************************************************
*
*   This routine reads a solution from the 'mfeout' file produced by
*   MFE2.  It gathers the information neccessary for GP2 and discards
*   the rest.  The arguments are
*
*     nnod, npde -- the number of nodes and PDEs.
*     t -- the solution time.
*     y -- the solution vector (ordered x,y,u,v,... at each node).
*     label -- a character array of four descriptive labels for this
*              solution.  See the documentation on GP2 for details.
*
*   The first two arguments are input and the rest are returned.  The
*   alternate return is taken if the EOF or an error is encountered
*   on any of the reads.  This indicates that either the file is not
*   in the correct 'mfeout' format, or that the file was not properly
*   positioned initially.
*
************************************************************************
      integer nnod,npde,j,k,nstep,nje,nre
      double precision t,y(npde+2,nnod),h,cputime,size
      character*24 label(4)

*     Read the solution.
      read(4,end=110,err=120) t
      read(4,end=120,err=120) ((y(k,j), k=1,npde+2), j=1,nnod)
      read(4,end=120,err=120) h,cputime,nstep,nje,nre

*     Dummy data point.
      y(1,nnod+1) = size
      y(2,nnod+1) = size

*     Create the title strings.
      write(label(1),'(a,i4)')     'STEP  =', nstep
      write(label(2),'(a,f7.2,a)') 'CPU   =', cputime, '(SEC)'
      write(label(3),'(a,e10.3)')  'H     =', h
      write(label(4),'(a,i5,":",i3.3)')  'NRE:NJE =', nre, nje

      return

***** We've read all the solutions.
  110 return 1

***** Bad file format.
  120 return 2
      end
      subroutine wrsoln(nnod,npde,t,y,label)
************************************************************************
*
*   This routine writes a solution to the GP2 input file.  See
*   the documentation on GP2 for details on the format of this file.
*   The arguments are all input and are described in RDSOLN.
*
************************************************************************
      integer nnod,npde,j,k
      double precision t,y(1)
      character label(4)*24,fmt*48

  110 format(e17.9)
  120 format(a)
  130 format('((2e18.9e3,',i1,'e13.4e3))')

      write(7,110) t
      write(7,120) (label(k), k=1,4)
      write(fmt,130) npde
      write(7,fmt) (y(j), j=1,nnod*(npde+2))

      return
      end
