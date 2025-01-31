#!/bin/bash
set -ex

scripts_path=$(dirname "$(readlink -f "$0")")

if [ -v LT_PTHREADS ]; then
  echo "#define BOOST_SP_USE_PTHREADS" >>"${CROSS_ROOT}/include/boost/config/user.hpp"
fi
if [ ! -f "${LIBTORRENT_VERSION}.tar.gz" ]; then
  wget -q "https://github.com/arvidn/libtorrent/archive/${LIBTORRENT_VERSION//\\./_}.tar.gz"
fi
tar -xzf "${LIBTORRENT_VERSION}.tar.gz"
rm "${LIBTORRENT_VERSION}.tar.gz"
cd "libtorrent-${LIBTORRENT_VERSION//\\./_}"
./autotool.sh
# shellcheck disable=SC2016
sed -i 's/$PKG_CONFIG openssl --libs-only-/$PKG_CONFIG openssl --static --libs-only-/' ./configure
if [ -v LT_OSXCROSS ]; then
  export OSXCROSS_PKG_CONFIG_PATH=${CROSS_ROOT}/lib/pkgconfig/
fi
# shellcheck disable=SC2097,SC2098,SC2086
CC=${LT_CC} CXX=${LT_CXX} \
  CFLAGS="${CFLAGS} -O2 ${LT_FLAGS}" \
  CXXFLAGS="${CXXFLAGS} ${LT_CXXFLAGS} ${CFLAGS}" \
  LIBS=${LT_LIBS} \
  ./configure \
  --with-cxx-standard=11 \
  --enable-static \
  --disable-shared \
  --disable-deprecated-functions \
  --host="${CROSS_TRIPLE}" \
  --prefix="${CROSS_ROOT}" \
  --with-boost="${CROSS_ROOT}" --with-boost-libdir="${CROSS_ROOT}/lib" ${LT_OPTS}
make -j"$(nproc)" && make install
# Update includes so swig does not fail
LIBTORRENT_INCLUDE="${CROSS_ROOT}/include/libtorrent" "${scripts_path}/update-includes.sh"
rm -rf "$(pwd)"
