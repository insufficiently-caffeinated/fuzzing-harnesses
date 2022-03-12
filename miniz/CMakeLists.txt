cmake_minimum_required(VERSION 3.16)

add_compile_options(-g)

add_executable(miniz uncompress2_fuzzer.c miniz.c miniz.h)

target_link_libraries(miniz PRIVATE main)

extract_bitcode(miniz-bitcode miniz)
