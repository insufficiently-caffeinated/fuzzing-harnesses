
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
    COMMAND llvm-link-13 
      "${CAFFEINE_BUILTINS}"
      "${CAFFEINE_LIBC}"
      "${CAFFEINE_LIBCXX}"
      "${BITCODE}"
      -o "${LINKED}"
    DEPENDS
      "${CAFFEINE_BUILTINS}"
      "${CAFFEINE_LIBC}"
      "${CAFFEINE_LIBCXX}"
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
