      subroutine second (cpusec)
      use f90_unix
      real cpusec, usr_time, sys_time
      integer(kind=clock_tick_kind) t1
      type(tms) t2
      t1 = times(t2)
      usr_time = real(t2 % utime) / real(clock_ticks_per_second())
      sys_time = real(t2 % stime) / real(clock_ticks_per_second())
      cpusec = usr_time + sys_time
      return
      end
