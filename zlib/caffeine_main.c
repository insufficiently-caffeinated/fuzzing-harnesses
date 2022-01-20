
#include "caffeine.h"
#include <stdint.h>
#include <stdlib.h>

int LLVMFuzzerTestOneInput(const uint8_t *d, size_t size);

int __attribute__((optnone)) main(int argc, char** argv) {
  size_t size = 256;
  uint8_t* data = malloc(size);
  caffeine_make_symbolic(data, size, "data");

  return LLVMFuzzerTestOneInput(data, size);

  // size_t size;
  // caffeine_make_symbolic(&size, sizeof(size), "size");

  // for (size_t i = 255; i < 256; ++i) {
  //   if (size != i)
  //     continue;

  //   uint8_t* data = malloc(i);
  //   caffeine_make_symbolic(data, i, "data");

  //   return LLVMFuzzerTestOneInput(data, i);
  // }
}

