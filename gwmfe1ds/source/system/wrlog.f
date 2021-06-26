      subroutine wrlog(t)
************************************************************************
*
*   WRLOG -- Write integration message to the log file.
*
************************************************************************
      double precision hlast
      real cpusec
      integer nstep,nje,nre,npf,njf,nnr,nnf,npef
      common /mfe070/ hlast,cpusec,
     +                nstep,nje,nre,npf,njf,nnr,nnf,npef

      double precision t

      write(6,100) nstep,t,hlast,cpusec,
     +             nre,nje,npf,njf,nnr,nnf,npef

  100 format(/i5,':  T =',e11.4,',  H =',e10.3,
     +           ',  CPU =',f8.2,'(SEC)',
     +       /8x,'NRE:NJE=',i4.3,':',i3.3,
     +           ',  NPF:NJF:NNR:NNF:NPEF=',i4.3,4(':',i3.3))

      return
      end 
