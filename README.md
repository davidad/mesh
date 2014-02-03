## mesh

**NOTE**: `mesh` is (very) **pre-alpha**. Everything is subject to change.

**For design descriptions**, please see the [docs](doc/index.md).

### Building

The only requirements to build `mesh` on any supported platform are [git](http://git-scm.com/) and [GNU make](https://www.gnu.org/software/make/). Running `make` will download [nasm](http://www.nasm.us/) 2.11 for you (assuming you have [cURL](http://curl.haxx.se), [gzip](http://www.gzip.org), and [cpio](http://en.wikipedia.org/wiki/Cpio), all of which are present in stock OSX and ubiquitous among Linux distributions).

    $ git clone https://github.com/davidad/mesh
    $ cd mesh
    $ make

Currently, supported platforms are OSX (10.5+) and Linux (3.10+), running on Intel CPUs (Sandy Bridge or newer) in 64-bit mode. Support for Windows is planned, as is support for Intel processors as old as Nocona/Prescott. 32-bit support is not planned.

### Licensing

As network software, mesh is released under the [AGPLv3](https://www.gnu.org/licenses/agpl-3.0.html). The Makefile contains code derived from the [rpm5](http://rpm5.org) project, which is licensed under the [LGPLv3](http://www.gnu.org/licenses/lgpl.html).
