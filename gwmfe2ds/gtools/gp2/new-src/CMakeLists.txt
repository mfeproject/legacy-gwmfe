include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(gp2new-common STATIC alfa2.c clip2.c draw2.c matrix.c sysdep.c util2.c xs.c)

add_executable(gplot2new gplot2.c pscript.c)
target_link_libraries(gplot2new gp2new-common m)

add_executable(gp2new comact2.c init2.c rules2.c tek4010.c)
target_link_libraries(gp2new gp2new-common m)

install(TARGETS gp2new gplot2new)
