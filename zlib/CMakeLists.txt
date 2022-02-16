cmake_minimum_required(VERSION 3.16)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../cmake")

# Persist these as environment variables for the build
set(ENV{VCPKG_OVERLAY_TRIPLETS} "${VCPKG_OVERLAY_TRIPLETS}")

# Note: must be included before the project call
include(ConfigureCompiler)

project(fuzz-zlib)

find_package(ZLIB     REQUIRED)
find_package(caffeine REQUIRED)

include(BitcodeUtils)

add_definitions(-DZLIB_COMPAT)
add_compile_options(-fcolor-diagnostics -O3)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED TRUE)

add_library(dummy SHARED caffeine_dummy.c)

add_executable(small example_small_fuzzer.c caffeine_main.c)
add_executable(large example_large_fuzzer.c caffeine_main.c)
add_executable(inflate inflate_fuzzer.c caffeine_main.c)

target_link_libraries(dummy PUBLIC caffeine::interface)
target_link_libraries(small PRIVATE ZLIB::ZLIB dummy)
target_link_libraries(large PRIVATE ZLIB::ZLIB dummy)
target_link_libraries(inflate PRIVATE ZLIB::ZLIB dummy)

extract_bitcode(small-bitcode small)
extract_bitcode(large-bitcode large)
extract_bitcode(inflate-bitcode inflate)
