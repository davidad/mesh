## mesh

### Building

Building mesh for any supported platform depends only on [NASM](http://www.nasm.us/) and [GNU Make](http://www.gnu.org/software/make/). In fact, `make` will download the most recent version of nasm for you, if you have [cURL](http://curl.haxx.se).

    $ git clone https://github.com/davidad/mesh
    $ cd mesh
    $ make

Currently, supported platforms are OSX (10.5+) and Linux (3.10+), running on Intel CPUs (Sandy Bridge or newer) in 64-bit mode. Support for Windows is planned, as is support for Intel processors as old as Nocona/Prescott. 32-bit support is not planned.
