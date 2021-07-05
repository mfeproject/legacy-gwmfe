include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(gp2-common STATIC alfa2.c clip2.c draw2.c matrix.c sysdep.c util2.c xs.c)

add_executable(gplot2 gplot2.c pscript.c)
target_link_libraries(gplot2 gp2-common m)

add_executable(gp2 comact2.c init2.c rules2.c tek4010.c)
target_link_libraries(gp2 gp2-common m)

add_executable(gpp gpp.c util2.c sysdep.c)

add_executable(cats cats.c)

install(TARGETS gp2 gplot2 gpp cats)
