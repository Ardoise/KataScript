./configure --prefix=/usr       \
            --bindir=/bin       \
            --libdir=/lib       \
            --sysconfdir=/etc   \
            --disable-manpages  \
            --with-xz           \
            --with-zlib

The meaning of the configure options:

--with-*
--disable-manpages

Compile the package:

make
make check
make pkgconfigdir=/usr/lib/pkgconfig install
