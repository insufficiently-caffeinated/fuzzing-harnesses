
#include <stdint.h>
#include <stdlib.h>

#include "zlib.h"

#define BUFSIZE 1024

void* zalloc(void* _, unsigned items, unsigned size) {
  return malloc(items * size);
}
void zfree(void* _, void* addr) {
  free(addr);
}

int __attribute__((noinline))
LLVMFuzzerTestOneInput(const uint8_t *d, size_t size) {
  z_stream stream;

  uint8_t *buffer = malloc(BUFSIZE);

  stream.next_in = (Bytef *)d;
  stream.avail_in = size;
  stream.next_out = buffer;
  stream.avail_out = BUFSIZE;

  stream.zalloc = zalloc;
  stream.zfree = zfree;

  if (inflateInit(&stream) != Z_OK)
    return 0;

  // Note: We limit the number of iterations here to prevent running forever.
  for (size_t i = 0; i < 128; ++i) {
    int error = inflate(&stream, Z_SYNC_FLUSH);
    if (error == Z_STREAM_END)
      break;

    if (error != Z_OK)
      break;

    stream.next_out = buffer;
    stream.avail_out = BUFSIZE;
  }

  inflateEnd(&stream);
  return 0;
}
