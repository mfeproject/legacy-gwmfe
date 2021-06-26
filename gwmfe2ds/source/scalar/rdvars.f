      subroutine rdvars
************************************************************************
*
*   RDVARS -- Read the variables from the input file.
*
************************************************************************
      double precision eltvsc,tensn,press,rad0,fdinc,dxymin
      common /mfe021/ eltvsc,tensn,press,rad0
      common /mfe022/ fdinc,dxymin

      double precision tout
      integer nout,ofreq,mstep,imsg
      common /mfe050/ tout(50),nout,ofreq,mstep,imsg

      double precision ptol,rtol
      common /mfe060/ ptol(3),rtol

      integer mtry,mitr,mvec
      double precision h,hlb,ntol,margin,vtol
      common /mfe062/ h,hlb,ntol,margin,vtol,mtry,mitr,mvec

      double precision usera
      common /mfe100/ usera(25)

      integer j,k
      character*8 label

      read(5,'(a)',end=910,err=910) label
      if(label .ne. '$') go to 910
*     ==================================================================
*      Read the input parameters.
*     ==================================================================
      read(5,*,end=920,err=930) label, eltvsc
      read(5,*,end=920,err=930) label, tensn
      read(5,*,end=920,err=930) label, press
      read(5,*,end=920,err=930) label, rad0
      read(5,*,end=920,err=930) label, fdinc
      read(5,*,end=920,err=930) label, dxymin

      read(5,*,end=920,err=930) label, imsg
      read(5,*,end=920,err=930) label, ofreq
      read(5,*,end=920,err=930) label, mstep
      read(5,*,end=920,err=930) label, nout
      read(5,*,end=920,err=930) label, (tout(j), j=1,nout)

      read(5,*,end=920,err=930) label, rtol
      read(5,*,end=920,err=930) label, (ptol(k), k=1,3)

      read(5,*,end=920,err=930) label, h
      read(5,*,end=920,err=930) label, hlb
      read(5,*,end=920,err=930) label, margin
      read(5,*,end=920,err=930) label, ntol
      read(5,*,end=920,err=930) label, mitr
      read(5,*,end=920,err=930) label, vtol
      read(5,*,end=920,err=930) label, mvec
*     ==================================================================
*      Echo the input parameters.
*     ==================================================================
  100 format(//a/)
  110 format(t3,a,t42,'=',i6)
  120 format(t3,a,t42,'=',g11.4)
  130 format(t3,a,t42,'=',(t43,g11.4,2g12.4))
  140 format(t3,'(',a8,') =',g11.4)
  150 format()

      write(8,100) 'M F E   P A R A M E T E R S'
      write(8,130) 'Element viscosities (ELTVSC)', eltvsc
      write(8,130) 'Element tensions (TENSN)', tensn
      write(8,130) 'Element pressures (PRESS)', press
      write(8,120) 'Element pressure radius (RAD0)', rad0
      write(8,120) 'Jacobian increment (FDINC)', fdinc
      write(8,120) 'Minimum element area (DXYMIN)', dxymin
      write(8,150)
      write(8,110) 'BDF2 message flag (IMSG)', imsg
      write(8,110) 'Output frequency (OFREQ)', ofreq
      write(8,110) 'Maximum number of steps (MSTEP)', mstep
      write(8,130) 'Solution output times (TOUT)', (tout(j), j=1,nout)
      write(8,150)
      write(8,120) 'Relative tolerance on areas (RTOL)', rtol
      write(8,130) 'Predictor error tolerance (PTOL)',(ptol(k),k=1,3)
      write(8,150)
      write(8,120) 'Initial time step (H)', h
      write(8,120) 'Time step lower bound (HLB)', hlb
      write(8,120) 'Jacobian time step margin (MARGIN)', margin
      write(8,120) 'Newton iteration tolerance (NTOL)', ntol
      write(8,110) 'Maximum number of iterations (MITR)', mitr
      write(8,120) 'Vector tolerance in GMRES (VTOL)', vtol
      write(8,110) 'Max no of vectors in GMRES (MVEC)', mvec

      read(5,'(a)',end=910,err=910) label
      if(label .ne. '$') go to 910
*     ==================================================================
*      Read and echo the user parameters.
*     ==================================================================
      do 30 j=1,25
       read(5,*,end=31,err=930) label, usera(j)
       if(j .eq. 1) then
        write(8,100) 'U S E R   D E F I N E D   V A R I A B L E S'
        endif
       write(8,140) label, usera(j)
   30 continue
   31 continue

      close(5)

      return
*     ==================================================================
*      Input errors.
*     ==================================================================
  910 write(8,911)
  911 format(/'** RDVARS: Bad file format -- expecting a ''$''.',
     +       /'** Aborting execution.')
      stop

  920 write(8,921)
  921 format(/'** RDVARS: Bad file format -- at EOF.',
     +       /'** Aborting execution.')
      stop

  930 write(8,931) label
  931 format(/'** RDVARS: Bad file format -- part of line:',a,
     +       /'** Aborting execution.')
      stop
      end
