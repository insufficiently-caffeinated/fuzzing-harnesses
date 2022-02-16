#include "caffeine.h"

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <assert.h> 
#include <vector>

#define PNG_INTERNAL
#include "png.h"

void* limited_malloc(png_structp, png_alloc_size_t size) {
  if (size > 8000000)
    return nullptr;
  
  void* data = malloc(size);
  caffeine_make_symbolic(data, size, "data2");
  return data;
}

void default_free(png_structp, png_voidp ptr) {
  return free(ptr);
}

void error_fn(png_structp ptr, png_const_charp text) {
  exit(1);
}

void warn_fn(png_structp ptr, png_const_charp text) {
  // Nothing to do here.
}


static const int kPngHeaderSize = 8;
extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
  if (size < kPngHeaderSize) {
    return 0;
  }

  std::vector<unsigned char> v(data, data + size);
  if (png_sig_cmp(v.data(), 0, kPngHeaderSize)) {
    // not a PNG.
    return 0;
  }

  png_structp png_ptr = png_create_read_struct
    (PNG_LIBPNG_VER_STRING, nullptr, nullptr, nullptr);
  assert(png_ptr);

#ifdef MEMORY_SANITIZER
  png_set_user_limits(png_ptr, 65535, 65535);
#endif
  png_set_mem_fn(png_ptr, nullptr, limited_malloc, default_free);
  png_set_error_fn(png_ptr, nullptr, error_fn, warn_fn);

  png_set_crc_action(png_ptr, PNG_CRC_QUIET_USE, PNG_CRC_QUIET_USE);

  png_infop info_ptr = png_create_info_struct(png_ptr);
  assert(info_ptr);

  if (setjmp(png_jmpbuf(png_ptr))) {
    return 0;
  }

  png_set_progressive_read_fn(png_ptr, nullptr, nullptr, nullptr, nullptr);
  png_process_data(png_ptr, info_ptr, const_cast<uint8_t*>(data), size);
  png_destroy_read_struct(&png_ptr, &info_ptr, nullptr);

  return 0;
}