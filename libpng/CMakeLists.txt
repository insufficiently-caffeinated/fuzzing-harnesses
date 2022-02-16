# add_definitions(-DZLIB_COMPAT)

add_executable(read read_fuzzer.c)

target_link_libraries(read PUBLIC dummy main PRIVATE  png_static)
extract_bitcode(read-bitcode read)
