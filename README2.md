# Fuzz harness

To create a new fuzz target:
* Make sure that you have `vcpkg` installed
* Make sure that you have `caffeine` installed (`bazel run //:install -- --destdir=<abs path to some dir>`)
* Copy the `zlib` example directory
  * Be sure to link in main, which is defined as a shared library in the root of the repo. This actually
    calls `LLVMFuzzerTestOneInput`
* Run `./setup.sh`
