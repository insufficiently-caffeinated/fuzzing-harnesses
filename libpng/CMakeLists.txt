# add_definitions(-DZLIB_COMPAT)

add_executable(read read_fuzzer.cpp caffeine_main.c)

target_link_libraries(read PUBLIC dummy PRIVATE  png_static)
extract_bitcode(read-bitcode read)
