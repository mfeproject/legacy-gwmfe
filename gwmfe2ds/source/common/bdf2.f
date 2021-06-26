      subroutine bdf2(n,rvar,ivar,tout,rfreq,  istate,q,p,t,u,time)
************************************************************************
*
*   BDF2 -- Second order backward difference ODE integrator.
*
************************************************************************
      logical upjac,oldjac
      double precision hlb,ntol,margin,vtol,h,hlast,hjac
      integer mtry,mitr,mvec,frzcnt,nstep,nje,nre,npf,njf,nnr,nnf,npef
      common /bdf010/ hlb,ntol,margin,vtol,mtry,mitr,mvec
      common /bdf011/ h,hlast,hjac,upjac,frzcnt
      common /bdf020/ nstep,nje,nre,npf,njf,nnr,nnf,npef
      save /bdf010/,/bdf011/,/bdf020/

      integer log,msgs
      character*48 fn,fj,fa,fh,fpf,fjf,fnr,fnf,fpef,fni,fnif
      common /bdf030/ log,msgs
      common /bdf031/ fn,fj,fa,fh,fpf,fjf,fnr,fnf,fpef,fni,fnif
      save /bdf030/,/bdf031/

      integer n,ivar(3),rfreq,istate
      double precision u(n,4),time(4),rvar(5),tout,q(n),p(n),t

      integer j,errc,try
      double precision perr,enorm,rmin,rmax,eta,etah
      parameter(rmin=.25d0,rmax=4.d0)

      if(istate .eq. 2) then
	do 10 j=1,n
   10   q(j) = u(j,1)
	go to 100
	endif

      if(istate .eq. 3) go to 200
       
*     ==================================================================
*      Initialization.
*     ==================================================================

      mtry = ivar(1)
      mitr = ivar(2)
      mvec = ivar(3)
      h    = rvar(1)
      hlb  = rvar(2)
      ntol = rvar(3)
      margin = rvar(4)
      vtol = rvar(5)

      nstep = 0
      nje = 0
      nre = 0
      npf = 0
      njf = 0
      nnr = 0
      nnf = 0
      npef = 0

      if(istate .eq. 0) then
*       Call starting procedure.
        call sbdf2(n,q,p,t,  u,time,  errc)
        if(errc .ne. 0) go to 930

      else
*       Restart.
        frzcnt = 0
        upjac = .true.
        hlast = time(1) - time(2)
        endif

      go to 200

*     ==================================================================
*      Test for a normal return before taking the next step.
*     ==================================================================

  100 if(tout .le. time(1)) then
*       Cubic interpolation to TOUT.
        t = tout
        do 110 j=1,n
         q(j) = u(j,1) + (tout-time(1))*(u(j,2)
     +        + (tout-time(2))*(u(j,3) + (tout-time(3))*u(j,4)))
  110   continue
        istate = 2
        return

      elseif(mod(nstep,rfreq) .eq. 0) then
*       Return current solution.
        istate = 3
        return
        endif

*     ==================================================================
*      Start of a BDF2 step.
*     ==================================================================

  200 nstep = nstep + 1
      try = 0

  210 try = try + 1
      if(try .gt. mtry) go to 910
      if(h .lt. hlb) go to 920

      t = time(1) + h
      eta = (hlast + h)/(hlast + 2.d0*h)
      etah = eta*h
      oldjac = .true.
      if(msgs .ge. 1) write(log,fn) nstep,try,time(1),h

  220 continue
*     ------------
*      Predictor.
*     ------------
      do 230 j=1,n
       q(j) = u(j,1) + h*(u(j,2) + (h+hlast)*u(j,3))
       p(j) = u(j,2) + ((h+hlast)/eta)*u(j,3)
  230 continue

*     Check whether the initial guess is admissible.
      call scheck(q,0,  errc)
      if(errc .ne. 0) then
        h = h/2.d0
        frzcnt = 1
        npf = npf + 1
        if(msgs .ge. 1) write(log,fpf) h
        go to 210
        endif
*     ----------------------
*      Jacobian evaluation.
*     ----------------------
*     if(abs(etah-hjac)/etah .gt. margin) upjac = .true.
      if(hjac/etah .gt. 1.d0 + margin) upjac = .true.
      if(etah/hjac .gt. 1.d0 + margin) upjac = .true.
      if(upjac) then
        nje = nje + 1
        if(msgs .ge. 1) write(log,fj)
        call jac(q,p,t,etah,  errc)
        if(errc .ne. 0) then
          h = h/2.d0
          upjac = .true.
          if(msgs .ge. 1) write(log,fjf) h
          njf = njf + 1
          go to 210
          endif
        upjac  = .false.
        oldjac = .false.
        hjac = etah
        endif
*     -------------------
*      Newton iteration.
*     -------------------
      call nwtn(n,t,etah,u(1,4),  q,p,  errc)
      if(errc .ne. 0) then
        if(oldjac) then
*         Newton failed with an old jacobian.
          upjac = .true.
          if(msgs .ge. 1) write(log,fnr)
          nnr = nnr + 1
          go to 220

        else
*         Newton failed with an fresh jacobian.
          h = h/2.d0
          frzcnt = 1
          if(msgs .ge. 1) write(log,fnf) h
          nnf = nnf + 1
          go to 210
          endif
        endif
*     ------------------
*      Predictor error.
*     ------------------
      do 240 j=1,n
  240 u(j,4) = q(j) - (u(j,1) + h*(u(j,2) + (h+hlast)*u(j,3)))
      perr = enorm(u(1,4),2)

      if(perr .gt. 4.d0) then
*       Reject the step on basis of predictor error.
        h = h/2.d0
        frzcnt = 1
        if(msgs .ge. 1) write(log,fpef) perr,h
        npef = npef + 1
        go to 210
        endif
      if(msgs .ge. 1) write(log,fa) perr
*     -----------------------------
*      Update divided differences.
*     -----------------------------
      time(4) = time(3)
      time(3) = time(2)
      time(2) = time(1)
      time(1) = t
      do 250 j=1,n
       u(j,4) = u(j,3)
       u(j,3) = u(j,2)
       u(j,2) = u(j,1)
       u(j,1) = q(j)

       u(j,2) = (u(j,1) - u(j,2))/(time(1) - time(2))
       u(j,3) = (u(j,2) - u(j,3))/(time(1) - time(3))
       u(j,4) = (u(j,3) - u(j,4))/(time(1) - time(4))
  250 continue
*     -----------------------
*      Choose new time step.
*     -----------------------
      hlast = h
      call choose(time,perr,  h)
      h = max( rmin*hlast, min( rmax*hlast, h ) )
      if(frzcnt .ne. 0) h = min( hlast, h )
      frzcnt = max( 0, frzcnt-1 )
      if(msgs .ge. 1) write(log,fh) hlast,h
      go to 100

*     ==================================================================
*      Error returns.
*     ==================================================================

*     Repeated failure at a single step.
  910 istate = -1
      t = time(1)
      do 911 j=1,n
  911 q(j) = u(j,1)
      return

*     Time step is too small.
  920 istate = -2
      t = time(1)
      do 921 j=1,n
  921 q(j) = u(j,1)
      return

*     Starting procedure failed.
  930 istate = -3
      t = time(1)
      do 931 j=1,n
  931 q(j) = u(j,1)
      return
      end
      subroutine nwtn(n,t,h,dq,  q,p,  errc)
************************************************************************
*
*   NWTN -- Newton iteration.
*
*   This routine uses a modified Newton method to solve the nonlinear
*   system of equations
*
*      R(q,p,t) = 0,   p := (q - qb)/h.
*
*   where the parameter t is "time" and p is a backward difference
*   with "time step" h.  The iteration proceeds as
*
*      R'*dq = R(q_k,p_k,t),
*      q_(k+1) = q_k - dq,
*      p_(k+1) = p_k - dq/h,
*
*   where the jacobian matrix R' has been evaluated at some (q,p,t)
*   and is used for every iteration.  The routine RES computes
*   R(q,p,t) and LINSOL solves the linear system.  The routine
*   ENORM computes the norm of the successive corrections dq.
*
*   Argument  I/O/M/T  Description
*   --------  -------  -----------
*    N           I     Size of the system.
*
*    T, H        I     The "time" and "time step".  They are simply
*                      passed on to RES.
*
*    DQ          T     Working array of length at least n*(1+2*mitr)
*                      The final 2*mitr*n locations are working storage
*                      for the newton accelerator.  This allows for a
*                      maximum of mitr iterations.
*
*    Q           M     On input, the initial guess for the solution.
*                      It is overwritten with the final iterate.
*
*    P           M     On input, the initial guess for the backward
*                      difference.  It is overwritten with the final
*                      backward difference.
*
*    ERRC        O     Error flag.  Set to 1 if the iterations failed
*                      to converge; set to 2 if SCHECK returned an
*                      error condition.  Set to 0 if successful.
*
*   Subroutines:  SCHECK, RES, LINSOL, ENORM.
*
************************************************************************
      double precision hlb,ntol,margin,vtol
      integer mtry,mitr,mvec,nstep,nje,nre,npf,njf,nnr,nnf,npef
      common /bdf010/ hlb,ntol,margin,vtol,mtry,mitr,mvec
      common /bdf020/ nstep,nje,nre,npf,njf,nnr,nnf,npef
      save /bdf010/,/bdf020/

      integer log,msgs
      character*48 fn,fj,fa,fh,fpf,fjf,fnr,fnf,fpef,fni,fnif
      common /bdf030/ log,msgs
      common /bdf031/ fn,fj,fa,fh,fpf,fjf,fnr,fnf,fpef,fni,fnif
      save/bdf030/,/bdf031/

      integer n,errc,j,itr
      double precision t,h,dq(n,*),q(n),p(n),e,enorm,elast,crate

      errc = 0
      itr = 0
      elast = 1.d0
  100 itr = itr + 1

*     Solve the linearized equations.
      nre = nre + 1
      call res(q,p,t,  dq)
      call linsol(dq)

*     Acceleration.
      if(mvec .ge. 1) call naccel(n,itr,mvec,vtol,dq(1,2),  dq)

*     Next iterate.
      do 110 j=1,n
       q(j) = q(j) - dq(j,1)
       p(j) = p(j) - dq(j,1)/h
  110 continue

*     Check whether the new iterate is admissible.
      call scheck(q,1,  errc)
      if(errc .ne. 0) then
        errc = 2
        if(msgs .ge. 2) write(log,fnif) itr
        return
        endif

*     Estimated error and stopping criteria.
      e = enorm(dq,1)
      crate = e/elast

*     We require 100 times greater accuracy on the first iteration.
      if((itr .eq. 1) .and. (e .le. .01d0*ntol)) then
        errc = 0
        if(msgs .ge. 2) write(log,fni) itr,e,crate
        return
        endif

*     Force at least 2 iterations.
*     if(e .le. ntol) then
      if((e .le. ntol) .and. (itr .ge. 2)) then
        errc = 0
        if(msgs .ge. 2) write(log,fni) itr,e,crate
        return
        endif
*     Disable testing of convergence rate.
*     if((itr .ge. mitr) .or. (itr .ge. 2 .and. crate .ge. 1.1d0)) then
      if(itr .ge. mitr) then
        errc = 1
        if(msgs .ge. 2) write(log,fni) itr,e,crate
        return
        endif
      elast = e
      go to 100

      end
      subroutine naccel(n,itr,mvec,tol,u,  f)
************************************************************************
*
*   NACCEL -- Newton iteration accelerator.
*
*   Argument  I/O/M/T  Description
*   --------  -------  -----------
*     N          I     Vector size.
*
*     ITR        I     Newton iteration count.  Initialization is done
*                      for ITR=1 and ITR is ignored thereafter.
*
*     MVEC       I     Maximum number of vectors to use in the
*                      acceleration algorithm.  May change from call
*                      to call but should be greater than 0 and no
*                      more than the internal parameter MAX (=10).
*
*     TOL        I     Tolerance for dropping vectors.  We drop the
*                      pair (z_k,w_k) if the sine of the angle between
*                      w_k and span{w_1, ..., w_(k-1)} is less than TOL.
*
*     U          T     Work space of length at least N*(2*MVEC+2).
*                      It should not be modified between calls.
*
*     F          M     Vector of length N.  On entry, it is the value
*                      of the function f at the current iterate.  It
*                      is overwritten with the accelerated correction.
*                      The unaccelerated correction would simply be f
*                      itself.
*
************************************************************************
      integer max
      parameter(max=10)

      integer n,itr,mvec
      double precision tol,u(n,2,mvec+1),f(n)

      double precision h(max+1,max+1)
      integer nvec,head,next,link(max+1)
      save nvec,head,next,link,h

      double precision c(max),t
      integer jptr,kptr,km1ptr,last,tmp,i,j,k
*     ==================================================================
*      First call: save f and the (unaccelerated) correction.
*     ==================================================================
      if(itr .eq. 1) then
        head = 1
        do 10 j=1,n
         u(j,1,head) = f(j)
         u(j,2,head) = f(j)
   10   continue
        link(1) = 0
        nvec = 1

*       Free storage linked list.
        next = 2
        do 20 k=2,max
   20   link(k) = k + 1
        link(max+1) = 0
        return
        endif
*     ==================================================================
*      Compute w_1.
*     ==================================================================
      do 100 j=1,n
  100 u(j,2,head) = u(j,2,head) - f(j)
      t = 0.0d0
      do 101 j=1,n
  101 t = t + u(j,2,head)**2
      t = 1.0d0/sqrt(t)

*     Normalize w_1 and apply same factor to z_1.
      do 110 j=1,n
       u(j,1,head) = t*u(j,1,head)
       u(j,2,head) = t*u(j,2,head)
  110 continue

*     Update H.
      kptr = link(head)
      do 120 k=2,nvec
       h(1,k) = 0.0d0
       do 121 j=1,n
  121  h(1,k) = h(1,k) + u(j,2,head)*u(j,2,kptr)
       kptr = link(kptr)
  120 continue
*     ==================================================================
*      Compute the Choleski factorization of H.
*     ==================================================================
      k = 2
      h(1,1) = 1.d0
  200 if(k .gt. min(nvec,mvec)) go to 250

      do 210 j=1,k-1
       h(k,j) = h(j,k)
       do 211 i=1,j-1
  211  h(k,j) = h(k,j) - h(k,i)*h(j,i)
       h(k,j) = h(k,j)/h(j,j)
  210 continue

      h(k,k) = 1.d0
      do 220 j=1,k-1
  220 h(k,k) = h(k,k) - h(k,j)**2

      if(h(k,k) .lt. tol**2) then
*       -----------------------------------------------
*        w_k is nearly in span{w_1, ..., w_(k-1)}
*       -----------------------------------------------
*       Remove w_k from linked list.
        km1ptr = head
        do 230 j=2,k-1
  230   km1ptr = link(km1ptr)      
        kptr = link(km1ptr)
        link(km1ptr) = link(kptr)
        nvec = nvec - 1

*       Update free storage list.
        link(kptr) = next
        next = kptr

*       Update H.
        do 240 j=k,nvec
         do 241 i=1,k-1
  241    h(i,j) = h(i,j+1)
         do 242 i=k,j-1
  242    h(i,j) = h(i+1,j+1)
  240   continue
        go to 200

      else
        h(k,k) = sqrt(h(k,k))
        k = k + 1
        go to 200
        endif
*     ------------------------------
*      Retain at most MVEC vectors.
*     ------------------------------
  250 if(nvec .gt. mvec) then
*       truncate the linked list.
        last = head
        do 260 j=2,mvec
  260   last = link(last)
        tmp = link(last)
        link(last) = 0
	last = tmp

*       Update free storage list.
        do 270 j=mvec+2,nvec
  270   last = link(last)
        link(last) = next
        next = tmp
        nvec = mvec
        endif
*     ==================================================================
*      Compute the projection of f onto {w_1, ... , w_nvec}.
*     ==================================================================
      jptr = head
      do 300 j=1,nvec
       c(j) = 0.0d0
       do 301 i=1,n
  301  c(j) = c(j) + f(i)*u(i,2,jptr)
       jptr = link(jptr)
       do 310 i=1,j-1
  310  c(j) = c(j) - h(j,i)*c(i)
       c(j) = c(j)/h(j,j)
  300 continue

      do 320 j=nvec,1,-1
       do 321 i=j+1,nvec
  321  c(j) = c(j) - h(i,j)*c(i)
       c(j) = c(j)/h(j,j)
  320 continue
*     ==================================================================
*      Compute the accelerated correction.
*     ==================================================================
*     Save f for the next call.
      do 410 j=1,n
  410 u(j,2,next) = f(j)

      kptr = head
      do 420 k=1,nvec
       do 421 j=1,n
  421  f(j) = f(j) - c(k)*u(j,2,kptr) + c(k)*u(j,1,kptr)
       kptr = link(kptr)
  420 continue

*     Save the correction for the next call.
      do 430 j=1,n
  430 u(j,1,next) = f(j)
*     ==================================================================
*      Shift the vectors to the right.
*     ==================================================================
      tmp = next
      next = link(tmp)
      link(tmp) = head
      head = tmp

*     Update H.
      do 500 j=nvec,1,-1
      do 500 i=1,j-1
  500 h(i+1,j+1) = h(i,j)

      nvec = nvec + 1

      return
      end
      subroutine choose(t,perr,  newh)
************************************************************************
*
*   CHOOSE -- Choose a new time step.
*
************************************************************************
      double precision t(4),perr,newh,tol,phi,dphi,h,h1,h1ph2,a,dh
      parameter(tol=1.d-3)

      phi(h) = h*(h+h1)*(h+h1ph2) - a
      dphi(h) = (2.d0*h+h1)*(h+h1ph2) + h*(h+h1)

      h1 = t(1) - t(2)
      h1ph2 = t(1) - t(3)
      a = .5d0*h1*h1ph2*(t(1)-t(4))/perr

   10 dh = phi(newh)/dphi(newh)
      newh = newh - dh
      if(abs(dh)/newh .gt. tol) go to 10

      return
      end
      subroutine sbdf2(n,q,p,t,  u,time,  errc)
************************************************************************
*
*   SBDF2 -- Starting procedure for BDF2.
*
************************************************************************
      logical upjac
      double precision hlb,ntol,margin,vtol,h,hlast,hjac
      integer mtry,mitr,mvec,frzcnt,nstep,nje,nre,npf,njf,nnr,nnf,npef
      common /bdf010/ hlb,ntol,margin,vtol,mtry,mitr,mvec
      common /bdf011/ h,hlast,hjac,upjac,frzcnt
      common /bdf020/ nstep,nje,nre,npf,njf,nnr,nnf,npef
      save /bdf010/,/bdf011/,/bdf020/

      integer log,msgs
      character*48 fn,fj,fa,fh,fpf,fjf,fnr,fnf,fpef,fni,fnif
      common /bdf030/ log,msgs
      common /bdf031/ fn,fj,fa,fh,fpf,fjf,fnr,fnf,fpef,fni,fnif
      save /bdf030/,/bdf031/

      integer n,errc,j
      double precision q(n),p(n),t,u(n,4),time(3),etah

*     ==================================================================
*      Step 1:  Trapazoidal rule with FCE as predictor.
*     ==================================================================

      nstep = nstep + 1
      time(1) = t
      t = t + h
      etah = .5d0*h
      if(msgs .ge. 1) write(log,fn) nstep,1,time(1),h

*     Initial guess for Newton.
      do 10 j=1,n
       u(j,1) = q(j)
       q(j) = u(j,1) + h*p(j)
   10 continue

*     Check whether the initial guess is admissible.
      call scheck(q,0,  errc)
      if(errc .ne. 0) go to 910

*     Evaluate jacobian at initial guess.
      nje = nje + 1
      call jac(q,p,t,etah,  errc)
      if(errc .ne. 0) go to 910

*     Newton iteration.
      call nwtn(n,t,etah,u(1,4),  q,p,  errc)
      if(errc .ne. 0) go to 910

      time(2) = time(1)
      time(1) = t

      do 20 j=1,n
       u(j,2) = u(j,1)
       u(j,1) = q(j)
   20 continue

*     ==================================================================
*      Step 2:  BDF2 with midpoint method as predictor.
*     ==================================================================

      nstep = nstep + 1
      t = time(1) + h
      etah = 2.d0*h/3.d0
      if(msgs .ge. 1) write(log,fn) nstep,1,time(1),h

*     Initial guess for Newton.
      do 30 j=1,n
       q(j) = u(j,2) + 2.d0*h*p(j)
       p(j) = (q(j) - (4.d0*u(j,1) - u(j,2))/3.d0)/etah
   30 continue

*     Check whether the initial guess is admissible.
      call scheck(q,0,  errc)
      if(errc .ne. 0) go to 920

*     Evaluate jacobian at initial guess.
      nje = nje + 1
      call jac(q,p,t,etah,  errc)
      if(errc .ne. 0) go to 920

*     Newton iteration.
      call nwtn(n,t,etah,u(1,4),  q,p,  errc)
      if(errc .ne. 0) go to 920

      time(3) = time(2)
      time(2) = time(1)
      time(1) = t

*     ==================================================================
*      Final initialization before beginning a normal BDF2 step.
*     ==================================================================

      hlast = h
      hjac = 2.d0*h/3.d0
      upjac = .false.
      frzcnt = 0

*     Divided differences.
      do 40 j=1,n
       u(j,3) = u(j,2)
       u(j,2) = u(j,1)
       u(j,1) = q(j)

       u(j,3) = (u(j,2) - u(j,3))/h
       u(j,2) = (u(j,1) - u(j,2))/h
       u(j,3) = (u(j,2) - u(j,3))/(2.d0*h)
   40 continue

      errc = 0
      return

*     ==================================================================
*      Error returns.
*     ==================================================================

*     Failure on the first step.
  910 errc = 1
      return

*     Failure on the second step.
  920 errc = 2
      return
      end
      subroutine gstat(istats,rstats)
************************************************************************
*
*   GSTAT -- Get integration statistics.
*
************************************************************************
      logical upjac
      double precision h,hlast,hjac
      integer frzcnt,nstep,nje,nre,npf,njf,nnr,nnf,npef
      common /bdf011/ h,hlast,hjac,upjac,frzcnt
      common /bdf020/ nstep,nje,nre,npf,njf,nnr,nnf,npef
      save /bdf011/,/bdf020/

      double precision rstats
      integer istats(8)

      istats(1) = nstep
      istats(2) = nje
      istats(3) = nre
      istats(4) = npf
      istats(5) = njf
      istats(6) = nnr
      istats(7) = nnf
      istats(8) = npef
      rstats = hlast
      
      return
      end
      subroutine vbdf2(vers,date)
************************************************************************
*
*   VBDF2 -- Version number of this code.
*
************************************************************************
      character*8 vers,date

      vers = 'BDF2 1.0'
      date = '08/06/90'

      return
      end
      subroutine mbdf2(level,unit)
************************************************************************
*
*   MBDF2 -- Set message level and output unit for BDF2.
*
************************************************************************
      integer log,msgs
      common /bdf030/ log,msgs
      save /bdf030/

      integer level, unit

      if(level .ge. 0) msgs = level
      if(unit  .ge. 0) log  = unit

      return
      end
      block data bdfdat
************************************************************************
*
*   BDFDAT -- Formats for diagnostic output.
*
************************************************************************
      integer log,msgs
      character*48 fn,fj,fa,fh,fpf,fjf,fnr,fnf,fpef,fni,fnif
      common /bdf030/ log,msgs
      common /bdf031/ fn,fj,fa,fh,fpf,fjf,fnr,fnf,fpef,fni,fnif
      save /bdf030/,/bdf031/

      data log/6/,msgs/0/
      data fn/'("N:",i4.4,":",i1,":",e12.6,":",e12.6,":")'/,
     +     fj/'("J:")'/,
     +     fa/'("A:",e12.6,":")'/,
     +     fh/'("H:",e12.6,":",e12.6,":")'/,
     +    fpf/'("PF:",e12.6,":")'/,
     +    fjf/'("JF:",e12.6,":")'/,
     +    fnr/'("NR:")'/,
     +    fnf/'("NF:",e12.6,":")'/,
     +   fpef/'("PEF:",e12.6,":",e12.6,":")'/,
     +    fni/'("NI:",i1,":",e12.6,":",e12.6,":")'/,
     +   fnif/'("NIF:",i1,":",e12.6,":")'/

      end
