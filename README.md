## mesh

**NOTE**: `mesh` is (very) pre-alpha. (**Let's be honest, it's literally just a hello world right now.**)

This is the primary project that I am working on at [Hacker School](http://hackerschool.com) during the Winter 2014 batch. Expect daily updates. Everything is subject to change.

**For design descriptions**, please see the [docs](doc/index.md).

### Building

The only requirements to build `mesh` on any supported platform are [git](http://git-scm.com/) and [GNU make](https://www.gnu.org/software/make/). Running `make` will download [nasm](http://www.nasm.us/) 2.11 for you (assuming you have [cURL](http://curl.haxx.se), [gzip](http://www.gzip.org), and [cpio](http://en.wikipedia.org/wiki/Cpio), all of which are present in stock OSX and ubiquitous among Linux distributions).

    $ git clone https://github.com/davidad/mesh
    $ cd mesh
    $ make

This will build a flat binary `mesh.bin`, which can be run with

    $ qemu mesh.bin

(tested using [qemu 1.7.0](http://wiki.qemu-project.org/download/qemu-1.7.0.tar.bz2))

Future Makefiles will enable the creation of bootable USB volumes, and ultimately installation onto a disk partition.

### Licensing

As network-oriented software, mesh is released under the [AGPLv3](https://www.gnu.org/licenses/agpl-3.0.html). The Makefile contains code derived from the [rpm5](http://rpm5.org) project, which is licensed under the [LGPLv3](http://www.gnu.org/licenses/lgpl.html).
