cmake_minimum_required(VERSION 3.16)

project(fuzz-libpng)

find_package(caffeine REQUIRED)

# add_compile_options(-fcolor-diagnostics -O3)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED TRUE)

add_library(dummy SHARED caffeine_dummy.c)

add_subdirectory(third_party)

add_executable(read read_fuzzer.cpp caffeine_main.c)

target_link_libraries(dummy PUBLIC caffeine::interface)
target_link_libraries(read PUBLIC libpng dummy)

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
    COMMAND llvm-link-12 "${CAFFEINE_BUILTINS}" "${CAFFEINE_LIBC}" "${BITCODE}" -o "${LINKED}"
    DEPENDS
      "${CAFFIENE_BUILTINS}"
      "${CAFFEINE_LIBC}"
      "${BITCODE}"
    VERBATIM
  )

  add_custom_command(
    OUTPUT  "${OPTIMIZED}"
    COMMAND opt-12 
    ARGS
      "--load=$<TARGET_FILE:caffeine::caffeine-opt-plugin>"
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
    COMMAND llvm-dis-12 "${OPTIMIZED}" -o "${OUTPUT}"
    DEPENDS "${OPTIMIZED}"
    VERBATIM
  )

  add_custom_target("${TARGET_NAME}" ALL DEPENDS "${OUTPUT}")
endfunction(extract_bitcode)

extract_bitcode(read-bitcode read)
