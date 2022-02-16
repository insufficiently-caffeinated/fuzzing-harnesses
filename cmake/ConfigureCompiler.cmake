
set(_configure_compiler_dir "${CMAKE_CURRENT_LIST_DIR}" CACHE INTERNAL "")

set(COMPILER gclang)
configure_file(
  "${_configure_compiler_dir}/cc.sh.in"
  "${CMAKE_BINARY_DIR}/cc.sh"
  @ONLY
)

set(COMPILER gclang++)
configure_file(
  "${_configure_compiler_dir}/cc.sh.in"
  "${CMAKE_BINARY_DIR}/cxx.sh"
  @ONLY
)

unset(COMPILER)

set(CMAKE_C_COMPILER   "${CMAKE_BINARY_DIR}/cc.sh")
set(CMAKE_CXX_COMPILER "${CMAKE_BINARY_DIR}/cxx.sh")
