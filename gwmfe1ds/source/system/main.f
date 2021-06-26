************************************************************************
* 
* GWMFE1DS -- An implementation of the gradient-weighted moving finite
*             element method for systems of PDEs in one dimension.
* 
* Version 4.2 (1991, with minor changes March 1998).
* 
* Neil Carlson <Neil.N.Carlson@gmail.com>
* 
* Copyright (c) 1991, 1998, 2008  Neil N. Carlson
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

      program gwmfe1ds

      include "parameters.h"
      
      integer meqn,smax
      parameter(meqn=mnod*nepn,smax=meqn*nepn)

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

      double precision a,b,c
      common /mfe040/ a(smax),b(smax),c(smax)

      double precision tout
      integer nout,ofreq,mstep,imsg
      common /mfe050/ tout(50),nout,ofreq,mstep,imsg

      integer mtry,mitr,mvec
      double precision ptol,rtol,dx,h,hlb,ntol,margin,vtol
      common /mfe060/ ptol(nepn),rtol /mfe061/ dx(mnod)
      common /mfe062/ h,hlb,ntol,margin,vtol,mtry,mitr,mvec
      equivalence(h,rvar),(mtry,ivar)

      integer stats,nstep
      double precision hlast
      real cpusec
      common /mfe070/ hlast,cpusec,stats(8)
      equivalence(nstep,stats)

      double precision usera
      common /mfe100/ usera(25)

      double precision y(meqn),z(meqn),work(meqn,16),time(4),rvar(5),t
      integer ivar(3),istate,j,neqn

*     Initialize the code.
      call init(y,z,t)
*     ==================================================================
*      Begin integration.
*     ==================================================================
      j = 2
      neqn = nepn*nnod
      istate = 0
      if(ofreq .le. 0) ofreq = mstep

      write(6,710) t
  710 format(//'** MAIN: Beginning integration at t =',e11.4)

  100 if(j .gt. nout) go to 810
  110 if(nstep .ge. mstep) go to 820

      call bdf2(neqn,rvar,ivar,tout(j),ofreq,istate,y,z,t,work,time)

*     Update the variables in MFE070.
      call gstat(stats,hlast)
      call second(cpusec)

      if(istate .eq. 2) then

*       Integrated to TOUT.
        call wrlog(t)
        call wrgrf(y,t)
        j = j + 1
        go to 100

      elseif(istate .eq. 3) then
*       Integrated OFREQ more steps.
       call wrlog(t)
       call wrgrf(y,t)

        go to 110

      else
        go to 900
        endif
*     ==================================================================
*      Normal terminations.
*     ==================================================================
  810 write(6,811)
  811 format(/'** MAIN: Completed integration to final TOUT.',
     +       /'** Halting execution.')
      stop

  820 write(6,821)
  821 format(/'** MAIN: Maximum number of steps completed.',
     +       /'** Halting execution.')
      stop
*     ==================================================================
*      Abnormal terminations.
*     ==================================================================
*     Output last good solution if it hasn't already.
  900 if(mod(nstep-1,ofreq) .ne. 0) then
        call wrlog(t)
        call wrgrf(y,t)
      else
        call wrlog(t)
        endif

      if(istate .eq. -1) write(6,910)
      if(istate .eq. -2) write(6,920)
      if(istate .eq. -3) write(6,930)

  910 format(/'** MAIN: Repeated failure at a step (ISTATE = -1).',
     +       /'** Aborting execution.')
  920 format(/'** MAIN: Next time step is too small (ISTATE = -2).',
     +       /'** Aborting execution.')
  930 format(/'** MAIN: Starting procedure failed (ISTATE = -3).',
     +       /'** Aborting execution.')

      stop
      end
