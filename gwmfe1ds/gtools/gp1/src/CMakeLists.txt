include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(common OBJECT clip1.c draw1.c pass2.c util1.c sysdep.c init1.c)

add_executable(gplot1 gplot1.c pscript.c)
target_link_libraries(gplot1 common m)

add_executable(gp1 rules1.c comact1.c alfa1.c tek4010.c)
target_link_libraries(gp1 common m)

install(TARGETS gp1 gplot1)
