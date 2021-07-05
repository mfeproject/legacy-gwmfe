set(EXE "arsenic")
add_executable(${EXE} prob.f pde.f)
target_include_directories(${EXE} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
install(TARGETS ${EXE})

# A special version of mkgrf for this problem
add_executable(mkgrf-arsenic mkgrf.f)
install(TARGETS mkgrf-arsenic)

# standard code sources
target_sources(${EXE} PRIVATE
  source/amtx.f
  source/ares.f
  source/cmtx.f
  source/cpmtx.f
  source/dfdy.f
  source/enorm.f
  source/gthvec.f
  #source/init.f
  source/jac.f
  source/lapl.f
  source/laplvc.f
  source/linsol.f
  source/locpp.f
  source/main.f
  source/rdhead.f
  source/rdvars.f
  source/regmtx.f
  source/regres.f
  source/regrhs.f
  source/res.f
  source/scheck.f
  source/sctdgl.f
  source/sctmtx.f
  source/sctvec.f
  #source/wrhead.f
  #source/wrlog.f
  #source/wrsoln.f
  source/ydot.f
  source/bdf2.f
  source/bsolve.f
  source/meshlib.f
  source/sbsolve.f
)

# customized code versions for this problem
target_sources(${EXE} PRIVATE
  init.f wrhead.f wrlog.f wrsoln.f
)
