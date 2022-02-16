
add_definitions(-DZLIB_COMPAT)

add_executable(small example_small_fuzzer.c)
add_executable(large example_large_fuzzer.c)
add_executable(inflate inflate_fuzzer.c)

target_link_libraries(small   PRIVATE ZLIB::ZLIB main)
target_link_libraries(large   PRIVATE ZLIB::ZLIB main)
target_link_libraries(inflate PRIVATE ZLIB::ZLIB main)

extract_bitcode(small-bitcode small)
extract_bitcode(large-bitcode large)
extract_bitcode(inflate-bitcode inflate)
