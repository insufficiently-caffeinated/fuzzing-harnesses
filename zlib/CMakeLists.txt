cmake_minimum_required(VERSION 3.16)

project(fuzz-zlib)

find_package(ZLIB     REQUIRED)
find_package(caffeine REQUIRED)

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

function(extract_bitcode)
  set(TARGET_NAME   "${ARGV0}")
  set(TARGET_INPUT  "${ARGV1}")
  set(TARGET_OUTPUT "${TARGET_INPUT}.bc")

  set(TEMPDIR "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET_NAME}.dir/bitcode")
  make_directory("${TEMPDIR}")

  set(BITCODE   "${TEMPDIR}/${TARGET_INPUT}.unlinked.bc")
  set(LINKED    "${TEMPDIR}/${TARGET_INPUT}.linked.bc")
  set(OPTIMIZED "${TEMPDIR}/${TARGET_INPUT}.opt.bc")
  set(OUTPUT    "${TARGET_INPUT}.ll")

  add_custom_command(
    OUTPUT  "${BITCODE}"
    COMMAND get-bc -S -b -o "${BITCODE}" "$<TARGET_FILE:${TARGET_INPUT}>"
    DEPENDS "${TARGET_INPUT}"
    VERBATIM
  )

  add_custom_command(
    OUTPUT  "${LINKED}"
    COMMAND llvm-link-13 "${CAFFEINE_BUILTINS}" "${CAFFEINE_LIBC}" "${BITCODE}" -o "${LINKED}"
    DEPENDS
      "${CAFFIENE_BUILTINS}"
      "${CAFFEINE_LIBC}"
      "${BITCODE}"
    VERBATIM
  )

  add_custom_command(
    OUTPUT  "${OPTIMIZED}"
    COMMAND "$<TARGET_FILE:caffeine::caffeine-opt>"
    ARGS
      --load "$<TARGET_FILE:caffeine::caffeine-opt-plugin>"
      --caffeine-gen-builtins
      --internalize
      --internalize-public-api-list main
      --globaldce 
      -O3
      "${LINKED}"
      -o "${OPTIMIZED}"
    DEPENDS "${LINKED}" "$<TARGET_FILE:caffeine::caffeine-opt-plugin>"
    VERBATIM
  )

  add_custom_command(
    OUTPUT  "${OUTPUT}"
    COMMAND llvm-dis-13 "${OPTIMIZED}" -o "${OUTPUT}"
    DEPENDS "${OPTIMIZED}"
    VERBATIM
  )

  add_custom_target("${TARGET_NAME}" ALL DEPENDS "${OUTPUT}")
endfunction(extract_bitcode)

extract_bitcode(small-bitcode small)
extract_bitcode(large-bitcode large)
extract_bitcode(inflate-bitcode inflate)
