cmake_minimum_required(VERSION 3.16)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

# Persist these as environment variables for the build
set(ENV{VCPKG_OVERLAY_TRIPLETS} "${VCPKG_OVERLAY_TRIPLETS}")

# Note: must be included before the project call
include(ConfigureCompiler)

project(fuzzing-harnesses)

# Add all packages here
find_package(caffeine REQUIRED)
find_package(ZLIB     REQUIRED)
find_package(LIBPNG   REQUIRED)

include(BitcodeUtils)

add_compile_options(-fcolor-diagnostics -O3)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED TRUE)

# Note: dummy here is a library that offers symbols for caffeine builtins
#       but is not linked in directly so the bitcode for them doesn't get
#       included.
add_library(dummy SHARED caffeine_dummy.c)
add_library(main  STATIC caffeine_main.c)

target_link_libraries(main  PUBLIC dummy)
target_link_libraries(dummy PUBLIC caffeine::interface)

add_subdirectory(zlib)
