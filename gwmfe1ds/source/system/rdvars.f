      subroutine rdvars
************************************************************************
*
*   RDVARS -- Read the input file.
*
************************************************************************
      include "parameters.h"

      integer nnod,nelt
      common /mfe010/ nnod,nelt

      integer kreg
      double precision wpde,segvsc,segspr,fdinc,dxmin
      common /mfe020/ wpde(npde)
      common /mfe021/ segvsc(npde),segspr(npde),kreg
      common /mfe022/ fdinc,dxmin

      double precision bvl,bvr
      integer bcl,bcr
      common /mfe030/ bcl(nepn),bcr(nepn),bvl(nepn),bvr(nepn)

      double precision tout
      integer nout,ofreq,mstep,imsg
      common /mfe050/ tout(50),nout,ofreq,mstep,imsg

      integer mtry,mitr,mvec
      double precision ptol,rtol,h,hlb,ntol,margin,vtol
      common /mfe060/ ptol(nepn),rtol
      common /mfe062/ h,hlb,ntol,margin,vtol,mtry,mitr,mvec

      double precision usera
      common /mfe100/ usera(25)

      double precision yseg
      integer nseg, niseg
      common /tmp020/ nseg,niseg(mnod),yseg(nepn,mnod)

      integer j,k
      character title*64,label*8
*     ==================================================================
*      Read the title strings and write the logfile header.
*     ==================================================================
  110 format(79a)
  130 format(a)
  140 format('*  ',a,t79,'*')

      write(6,110) ('*', j=1,79)
   10 read(5,130,end=910,err=920) title
      if(title .eq. '$') go to 11
      write(6,140) title
      go to 10
   11 write(6,110) ('*', j=1,79)
*     ==================================================================
*      Read the input parameters.
*     ==================================================================
      read(5,*,end=910,err=920) label, nelt
      nnod = nelt + 1
      read(5,*,end=910,err=920) label, nseg
      read(5,*,end=910,err=920) label, (niseg(j), j=1,nseg)
      read(5,*,end=910,err=920) label, ((yseg(k,j),k=1,nepn),j=1,nseg+1)
      read(5,*,end=910,err=920) label, (bcl(k), k=1,nepn)
      read(5,*,end=910,err=920) label, (bcr(k), k=1,nepn)

      read(5,*,end=910,err=920) label, (wpde(k), k=1,npde)
      read(5,*,end=910,err=920) label, kreg
      read(5,*,end=910,err=920) label, (segvsc(k), k=1,npde)
      read(5,*,end=910,err=920) label, (segspr(k), k=1,npde)
      read(5,*,end=910,err=920) label, dxmin
      read(5,*,end=910,err=920) label, fdinc

      read(5,*,end=910,err=920) label, imsg
      read(5,*,end=910,err=920) label, ofreq
      read(5,*,end=910,err=920) label, mstep
      read(5,*,end=910,err=920) label, nout
      read(5,*,end=910,err=920) label, (tout(j), j=1,nout)

      read(5,*,end=910,err=920) label, rtol
      read(5,*,end=910,err=920) label, (ptol(k), k=1,nepn)

      read(5,*,end=910,err=920) label, h
      read(5,*,end=910,err=920) label, hlb
      read(5,*,end=910,err=920) label, margin
      read(5,*,end=910,err=920) label, ntol
      read(5,*,end=910,err=920) label, mitr
      read(5,*,end=910,err=920) label, vtol
      read(5,*,end=910,err=920) label, mvec
*     ==================================================================
*      Echo the input parameters.
*     ==================================================================
  200 format(//1x,a/)
  210 format(t3,a)
  220 format(t3,a,t42,'=',i6)
  222 format(t3,a,t42,'=',(t43,9i4))
  224 format(/t12,'  x',t24,'  u(k)'/t12,' ---',t24,' ------')
  225 format('((t10,',i2,'g12.4))')
  226 format(t3,a,t42,'=',9i2)
  230 format(t3,a,t42,'=',g11.4)
  240 format(t3,a,t42,'=',(t43,g11.4,2g12.4))
  250 format(t3,'(',a8,') =',g11.4)
  260 format()

      write(6,200) 'I N I T I A L   C O N D I T I O N S'
      write(6,220) 'Number of elements (NELT)', nelt
      write(6,220) 'Number of grid segments (NSEG)', nseg
      write(6,222) 'Number of cells per segment (NISEG)',
     +             (niseg(j), j=1,nseg)
      write(6,210) 'Initial conditions (YSEG):'
      write(6,224)
      write(title,225) nepn
      write(6,title) (yseg(nepn,j), (yseg(k,j), k=1,npde), j=1,nseg+1)
      write(6,*)
      write(6,226) 'Left boundary conditions (BCL)', (bcl(k), k=1,nepn)
      write(6,226) 'Right boundary conditions (BCR)', (bcr(k), k=1,nepn)

      write(6,200) 'M F E   P A R A M E T E R S'
      if(npde .ne. 1) write(6,240) 'Equation weights (WPDE)',
     +                             (wpde(k), k=1,npde)
      write(6,220) 'Kind of segment viscosities (KREG)', kreg
      write(6,240) 'Segment viscosities (SEGVSC)', (segvsc(k), k=1,npde)
      write(6,240) 'Segment springs (SEGSPR)', (segspr(k), k=1,npde)
      write(6,230) 'Lower bound on cell width (DXMIN)', dxmin
      write(6,230) 'Finite difference increment (FDINC)', fdinc
      write(6,260)
      write(6,220) 'BDF2 message flag (IMSG)', imsg
      write(6,220) 'Output frequency (OFREQ)', ofreq
      write(6,220) 'Maximum number of steps (MSTEP)', mstep
      write(6,240) 'Solution output times (TOUT)',(tout(j),j=2,nout)
      write(6,260)
      write(6,230) 'Relative tolerance on dx (RTOL)', rtol
      write(6,240) 'Predictor error tolerance (PTOL)',(ptol(k),k=1,nepn)
      write(6,260)
      write(6,230) 'Initial time step (H)', h
      write(6,230) 'Time step lower bound (HLB)', hlb
      write(6,230) 'Jacobian time step margin (MARGIN)', margin
      write(6,230) 'Newton iteration tolerance (NTOL)', ntol
      write(6,220) 'Max number of iterations (MITR)', mitr
      write(6,230) 'Vector tolerance in GMRES (VTOL)', vtol
      write(6,220) 'Max no. of vectors in GMRES (MVEC)', mvec
*     ==================================================================
*      Read and echo the user parameters.
*     ==================================================================
      do 100 j=1,25
       read(5,*,end=101,err=920) label, usera(j)
       if(j.eq.1) then
        write(6,200) 'U S E R   D E F I N E D   V A R I A B L E S'
        endif
       write(6,250) label, usera(j)
  100 continue
  101 continue
      return
*     ==================================================================
*      Error exits.
*     ==================================================================
  910 write(6,911)
  911 format(/'** RDVARS: Reached the EOF prematurely.',
     +       /'** Aborting execution.')
      stop

  920 write(6,921) label
  921 format(/'** RDVARS: Error in input file.  Part of last line: ',a,
     +       /'** Aborting execution.')
      stop
      end
