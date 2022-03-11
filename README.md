# Fuzzing Harnesses for Caffeine
This repo contains a set of fuzzing harnesses for use with caffeine. It also
has cmake configuration that makes compiling such a fuzzing harness easy.

## Usage
First, setup caffeine and vcpkg and install caffeine to a directory somewhere.
`setup.sh` assumes that caffeine is installed to `~/install` and vcpkg is at
`~/vcpkg` respectively. If these are at a different location then modify
`setup.sh` to suit.

Once that is done, running `setup.sh` will create a `build` folder with a cmake
setup that will compile test harnesses to bitcode along with any dependencies
used by vcpkg.
