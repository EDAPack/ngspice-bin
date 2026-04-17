#!/bin/bash -ex

root=$(pwd)

#********************************************************************
#* Install required packages
#********************************************************************
if test $(uname -s) = "Linux"; then
    yum update -y
    yum install -y wget bison flex make gcc gcc-c++ \
        readline-devel ncurses-devel patchelf

    if test -z $image; then
        image=linux
    fi

    rls_plat=${image}
fi

#********************************************************************
#* Validate environment variables
#********************************************************************
if test -z "$ngspice_version"; then
    echo "ngspice_version not set"
    env
    exit 1
fi

#********************************************************************
#* Calculate version information
#********************************************************************
rls_version=${ngspice_version}

if test "x${BUILD_NUM}" != "x"; then
    rls_version="${rls_version}.${BUILD_NUM}"
fi

#********************************************************************
#* Setup directories
#********************************************************************
PREFIX=${root}/install

rm -rf build install ngspice release
mkdir -p build install

#********************************************************************
#* Download ngspice source
#********************************************************************
cd ${root}/build

echo "Downloading ngspice ${ngspice_version}..."
wget -q --tries=3 \
    "https://sourceforge.net/projects/ngspice/files/ng-spice-rework/${ngspice_version}/ngspice-${ngspice_version}.tar.gz/download" \
    -O ngspice-${ngspice_version}.tar.gz

tar xf ngspice-${ngspice_version}.tar.gz
rm ngspice-${ngspice_version}.tar.gz

#********************************************************************
#* Configure NGSpice
#********************************************************************
echo "Configuring ngspice ${ngspice_version}..."
cd ${root}/build/ngspice-${ngspice_version}
mkdir -p build-ngspice
cd build-ngspice

../configure \
    --prefix=${PREFIX} \
    --with-x=no \
    --enable-xspice \
    --enable-cider \
    CFLAGS="-O2"

#********************************************************************
#* Build NGSpice
#********************************************************************
echo "Building ngspice..."
make -j$(nproc)
make install

#********************************************************************
#* Bundle non-standard shared libraries for portability
#* (libs not in the manylinux whitelist must be included)
#********************************************************************
echo "Bundling shared libraries..."

# Collect libs needed by the ngspice binary that aren't in the system whitelist
WHITELIST="libc.so libdl.so libm.so libpthread.so librt.so libutil.so libgomp.so libgcc_s.so libstdc\+\+.so"

bundle_dep_libs() {
    local bin="$1"
    ldd "$bin" 2>/dev/null | awk '{print $3}' | grep -v '^$' | grep '\.so' | while read lib; do
        test -f "$lib" || continue
        libname=$(basename "$lib")
        # Skip whitelist libs (basic system libs present everywhere)
        echo "$libname" | grep -qE "^(libc|libdl|libm|libpthread|librt|libutil)\.so" && continue
        dest="${PREFIX}/lib/${libname}"
        if test ! -f "$dest"; then
            echo "  Bundling: $lib -> ${PREFIX}/lib/"
            cp "$lib" "${PREFIX}/lib/"
            # Also grab versioned symlink target
            real=$(readlink -f "$lib")
            if test "$real" != "$lib"; then
                realname=$(basename "$real")
                test -f "${PREFIX}/lib/${realname}" || cp "$real" "${PREFIX}/lib/"
            fi
        fi
    done
}

# Bundle deps for the main binary
bundle_dep_libs "${PREFIX}/bin/ngspice"

# Bundle deps for any .cm / .so plugins
find "${PREFIX}/lib/ngspice" -name "*.so" -o -name "*.cm" | while read plugin; do
    bundle_dep_libs "$plugin"
done

#********************************************************************
#* Fix RPATH so binaries find bundled shared libs
#********************************************************************
echo "Fixing RPATH..."
find ${PREFIX}/bin -type f -executable | while read f; do
    file "$f" | grep -q ELF || continue
    patchelf --set-rpath '$ORIGIN/../lib' "$f" 2>/dev/null || true
done
# Plugins in lib/ngspice look in ../  (i.e., install/lib)
find ${PREFIX}/lib/ngspice -type f \( -name "*.so" -o -name "*.cm" \) | while read f; do
    file "$f" | grep -q ELF || continue
    patchelf --set-rpath '$ORIGIN/..' "$f" 2>/dev/null || true
done

#********************************************************************
#* Strip binaries to reduce size
#********************************************************************
echo "Stripping binaries..."
find ${PREFIX}/bin -type f -executable | xargs strip 2>/dev/null || true
find ${PREFIX}/lib -name "*.so*" -type f | xargs strip --strip-unneeded 2>/dev/null || true

#********************************************************************
#* Verify installation
#********************************************************************
echo "Verifying installation..."
echo '.end' | ${PREFIX}/bin/ngspice -b - 2>&1 | head -5
echo "ngspice verification OK"

#********************************************************************
#* Create release tarball
#********************************************************************
cd ${root}
mkdir -p release

mv install ngspice
tar czf release/ngspice-${rls_plat}-${rls_version}.tar.gz ngspice

echo "Build complete: release/ngspice-${rls_plat}-${rls_version}.tar.gz"
