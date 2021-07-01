cmake_minimum_required(VERSION 3.16)
project(GWMFE1DS LANGUAGES Fortran C)

set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR})

# Extra compiler flags needed to cope with the old crusty F77 code
set(COMPILING_WITH_GFORTRAN -w -std=legacy -fno-align-commons)
set(COMPILING_WITH_NAG -w -dusty)

add_compile_options("$<$<COMPILE_LANG_AND_ID:Fortran,GNU>:${COMPILING_WITH_GFORTRAN}>")
add_compile_options("$<$<COMPILE_LANG_AND_ID:Fortran,NAG>:${COMPILING_WITH_NAG}>")

add_subdirectory(burgers)
add_subdirectory(conv-diff)
add_subdirectory(drift-diff)
add_subdirectory(navier-stokes)

add_subdirectory(gtools/gp1/src)
