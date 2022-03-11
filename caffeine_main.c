
#include "caffeine.h"
#include <stdint.h>
#include <stdlib.h>

int LLVMFuzzerTestOneInput(const uint8_t *d, size_t size);

int main(int argc, char** argv) {
  size_t size = 256;
  uint8_t* data = malloc(size);
  caffeine_make_symbolic(data, size, "data");

  return LLVMFuzzerTestOneInput(data, size);
}
