add_executable(mkgrf mkgrf.f)
install(TARGETS mkgrf)

add_subdirectory(gp2/src)
add_subdirectory(gp2/new-src)
