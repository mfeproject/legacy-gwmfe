************************************************************************
* 
* GWMFE2DS -- An implementation of the gradient-weighted moving finite
*             element method for systems of PDEs in two dimensions.
* 
* Version 1.1 (1991, with minor changes October 1997).
* 
* Neil Carlson <Neil.N.Carlson@gmail.com>
* 
* Copyright 1997, 2008  Neil N. Carlson.
*
* Permission is hereby granted, free of charge, to any person obtaining a
* copy of this software and associated documentation files (the "Software"),
* to deal in the Software without restriction, including without limitation
* the rights to use, copy, modify, merge, publish, distribute, sublicense,
* and/or sell copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
* DEALINGS IN THE SOFTWARE.
*
************************************************************************

      program gwmfe2ds

      include "parameters.h"

      integer nepn,meqn
      parameter(nepn=npde+2,meqn=mnod*nepn)

      integer nnod,ntri,tvtx
      common /mfe010/ nnod,ntri /mfe011/ tvtx(0:2,mtri)

      double precision wpde,eltvsc,tensn,press,rad0,fdinc,dxymin
      common /mfe020/ wpde(npde)
      common /mfe021/ eltvsc(npde),tensn(npde),press(npde),rad0
      common /mfe022/ fdinc,dxymin

      double precision bv
      integer nbnod,bnod,bc
      common /mfe030/ bv(nepn,mbnd),nbnod,bnod(2,mbnd),bc(nepn,10)

      double precision s
      integer bandw,xadj,adjncy
      common /mfe040/ s(smax),bandw,xadj(mnod+1),adjncy(2*medg)

      double precision tout
      integer nout,ofreq,mstep,imsg
      common /mfe050/ tout(50),nout,ofreq,mstep,imsg

      double precision ptol,rtol,dxy0,dxy1,dxy
      common /mfe060/ ptol(nepn),rtol
      common /mfe061/ dxy0(mtri),dxy1(mtri),dxy(mtri)

      integer mtry,mitr,mvec
      double precision h,hlb,ntol,margin,vtol
      common /mfe062/ h,hlb,ntol,margin,vtol,mtry,mitr,mvec
      equivalence(h,rvar),(mtry,ivar)

      integer stats,nstep
      double precision hlast
      real cpusec
      common /mfe070/ hlast,cpusec,stats(8)
      equivalence(nstep,stats)

      double precision usera
      common /mfe100/ usera(25)

      double precision t,y(meqn),z(meqn),work(meqn,16),time(4),rvar(5)
      integer ivar(3),istate,j,neqn

      call init(t,y,z)
*     ==================================================================
*      Begin integration.
*     ==================================================================
      j = 1
      neqn = nnod*nepn
      istate = 0
      if(ofreq .le. 0) ofreq = mstep

      write(8,710) t
  710 format(//'** MAIN: Beginning integration at t =',e11.4)

  100 if(j .gt. nout) go to 810
  110 if(nstep .ge. mstep) go to 820

      call bdf2(neqn,rvar,ivar,tout(j),ofreq,istate,y,z,t,work,time)

*     Update the variables in MFE070.
      call gstat(stats,hlast)
      call cpu_time(cpusec)

      if(istate .eq. 2) then
*       Integrated to TOUT.
        call wrlog(t,2,8)
        call wrlog(t,2,6)
        call wrsoln(t,y)
        j = j + 1
        go to 100

      elseif(istate .eq. 3) then
*       Integrated OFREQ more steps.
        call wrlog(t,1,8)
        call wrlog(t,1,6)
        call wrsoln(t,y)
        go to 110

      else
        go to 900
        endif
*     ==================================================================
*      Normal terminations.
*     ==================================================================
  810 write(8,811)
  811 format(/'** MAIN: Completed integration to final TOUT.',
     +       /'** Halting execution.')
      stop

  820 write(8,821)
  821 format(/'** MAIN: Maximum number of steps completed.',
     +       /'** Halting execution.')
      stop
*     ==================================================================
*      Abnormal terminations.
*     ==================================================================
*     Output last good solution if it hasn't already.
  900 if(mod(nstep-1,ofreq) .ne. 0) then
        call wrlog(t,1,8)
        call wrlog(t,1,6)
        call wrsoln(t,y)
      else
        call wrlog(t,1,8)
        call wrlog(t,1,6)
        endif

      if(istate .eq. -1) write(8,910)
      if(istate .eq. -2) write(8,920)
      if(istate .eq. -3) write(8,930)

  910 format(/'** MAIN: Repeated failure at a step.  ISTATE = -1',
     +       /'** Aborting execution.')
  920 format(/'** MAIN: Next time step is too small.  ISTATE = -2',
     +       /'** Aborting execution.')
  930 format(/'** MAIN: Starting procedure failed.  ISTATE = -3',
     +       /'** Aborting execution.')

      stop
      end
