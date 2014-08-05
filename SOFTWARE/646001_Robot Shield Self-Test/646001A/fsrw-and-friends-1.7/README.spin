{{
fsrw 1.7 - Third Party Update - By John Twomey AKA: QuattroRS4
            Added SDdec,SDhex,SDBin and SDstr to fsrw to Facilitate
            ease of writing Strings as well as Hex,Binary and Decimal
            Values. A Simple demo. App. - 'sdrw_vga_demo' is included
            to show operation of additions on a vga screen - This demo
            app. uses 'Vga_1025x768_tile_driver_with_cursor' object by
            Chip Gracey (Parallax). 


fsrw 1.6 Copyright 2008   Radical Eye Software


See end of file for terms of use.

This is secure digital and FAT16 read/write code.

For connectivity, see "sdspiqasm.spin".  You only need four
Propeller lines and six pullup resistors and some sort of SD or
microSD or miniSD socket.

We only support the root directory at the moment, and only one
file open at a time.  The file can be open for read, write, or
append.  We also support delete (open a file in mode "d"), as well
as a traversal of the root directory.

No long file name support.  No (real) date support yet.  No
formatting utility yet.

I've tested it on 10 different secure digital cards, and it works
on all of them.  There is some variance in the speed.  For reads,
I see speeds of between 271 to 428 KBytes/sec.  For writes, I see
speeds of between 114 to 304 KBytes/sec, depending on the card.
This is with full file system overhead, and the file system code
is completely SPIN.  If you use only the block I/O layer you can do
better than this; if you write small files or flush frequently you
will see worse than this.

I am supplying four different block level implementations.  You
should start with the "sdspi" code which is slow and completely in
spin.  If that works, move up to "sdspiasm" and, "sdspifasm", and
finally "sdspiqasm" which increases the frequencies the card is
driven at.  All cards should support the fastest mode, but you
have to make sure your wires are not terribly long and stuff like
that.  You change the block layer used in the object section of the
"fsrw.spin" source.

I've tested this code on cards in their virgin (out of the bubble
pack) state, and when formatted with XP, and when formatted with
Win2K, and when formatted with the Canon XTi camera, and when
formatted with the Canon SD400 camera.  No problems in any case.

This code will *only* read FAT16, not FAT12 and not FAT32.  This means
the number of clusters on your volume must be greater than 4096 and
less than 65530 (or thereabouts).  Clusters can range from 512 bytes to
32K (they must be a power of two in size), so this means we can support
cards from 4M up to 2G.

When you format your card, you can use XP to do it, but you have to pick
a cluster size that will make the card end up in FAT16 (which means the
cluster count must satisfy the constraints above).  For performance, the
larger the cluster size, the better (since fewer metadata writes and
reads are required).  This does introduce some additional space loss due
to fragmentation, but with the large cards available now, this should not
be a problem.

The following table shows the range of cluster sizes you can select in
XP when formatting in order to guarantee a FAT16 volume.  The number
of clusters will be the size of the card divided by the cluster size
(approximately).

          min   max
   4M     512   512
   8M     512    1K
   16M    512    2K
   32M    512    4K
   64M     1K    8K
   128M    2K   16K
   256M    4K   32K
   512M    8K   32K
   1G     16K   32K
   2G     32K   32K

If you do not select the right cluster size, your volume may be formatted
in FAT12 or FAT32, neither of which is supported by this code.

FAT16 does not support volumes greater than 4G.  If you must use a 4G
card, you will have to ensure the first volume is 2G or less, and this
code will only mount that first volume.  In reality this is not much of
an issue, because this code only supports the SD protocol, and cards
of 4G or larger require the new SDHC protocol.  (I have no way at this
time to know if an SDHC card will default to the SD protocol for the
first portion of the card.)

I have an even faster assembly language routine but it is significantly
longer (unrolled loops and stuff) so I will continue working on that
before releasing it.

When formatting, try to pick the largest cluster size; that will
reduce the reading and writing overhead.

I have not yet experimented with multiblock mode or pre-erase.  Either
or both of these may increase the speed significantly.

I have tried to keep the code as short as possible.  Right now fsrw
plus sdspifasm is under 4K total memory consumption.  You can reduce
it even further by commenting out routines you don't use.

For fastest write speeds with minimum jitter, you will want to
preallocate the file you write to, make sure it is contiguous,
and then just do sequential block writes.  I have not written any
code to do this particular thing, but it is not terribly difficult.
}}

OBJ
   fsrw: "fsrw" ' the main FAT16 reading and writing code
   sdspi: "sdspi" ' low-level SD block I/O in spin (slow)
   sdspiasm: "sdspiasm" ' low-level SD block I/O in simple asm
   sdspifasm: "sdspifasm" ' low-level SD block I/O in faster asm
   sdspiqasm: "sdspiqasm" ' low-level SD block I/O in fastest asm
   fsrw_speed: "fsrw_speed" ' a test of speed
   sdrw_test: "sdrw_test" ' a simple example of use
   sdrw_test: "sdrw_VGA_Demo" ' a simple Vga example of use including Changes
pub start ' dummy

{{
'  Permission is hereby granted, free of charge, to any person obtaining
'  a copy of this software and associated documentation files
'  (the "Software"), to deal in the Software without restriction,
'  including without limitation the rights to use, copy, modify, merge,
'  publish, distribute, sublicense, and/or sell copies of the Software,
'  and to permit persons to whom the Software is furnished to do so,
'  subject to the following conditions:
'
'  The above copyright notice and this permission notice shall be included
'  in all copies or substantial portions of the Software.
'
'  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
'  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
'  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
'  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
'  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
'  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
'  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}}