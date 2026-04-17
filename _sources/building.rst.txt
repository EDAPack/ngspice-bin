Building from Source
====================

ngspice-bin is built inside a `manylinux_2_28
<https://github.com/pypa/manylinux>`_ (or ``manylinux_2_34``) Docker
container so the resulting binaries work on a wide range of Linux
distributions.

Prerequisites
-------------

* Docker (any recent version)
* ``git`` with the repository cloned
* Network access (the build downloads the NGSpice source tarball from
  SourceForge)

Local container build
---------------------

Use the provided helper script::

    ./scripts/run_docker.sh [ngspice_version] [image]

For example::

    # Build the latest release (46) in the default manylinux_2_28_x86_64 image
    ./scripts/run_docker.sh

    # Build a specific version
    ./scripts/run_docker.sh 46

    # Build in a different image
    ./scripts/run_docker.sh 46 manylinux_2_34_x86_64

Or invoke Docker directly::

    docker run --rm \
        --volume "$(pwd):/io" \
        --env ngspice_version=46 \
        --env image=manylinux_2_28_x86_64 \
        --workdir /io \
        quay.io/pypa/manylinux_2_28_x86_64 \
        /io/scripts/build.sh

The output tarball is written to ``release/``.

Build script steps
------------------

``scripts/build.sh`` performs the following steps:

1. **System dependencies** — installs build tools (``wget``, ``bison``,
   ``flex``, ``gcc``, ``gcc-c++``, ``readline-devel``, ``ncurses-devel``,
   ``patchelf``) via ``yum``.
2. **Download** — fetches ``ngspice-<version>.tar.gz`` from SourceForge.
3. **Configure** — runs ``./configure`` with ``--with-x=no``,
   ``--enable-xspice``, and ``--enable-cider``.
4. **Build & install** — ``make -j$(nproc) && make install`` into a local
   prefix.
5. **Bundle libs** — copies non-standard shared libraries (``libreadline``,
   ``libtinfo``, ``libgomp``, ``libstdc++``, ``libgcc_s``) into
   ``install/lib/``.
6. **Fix RPATH** — uses ``patchelf`` to set ``$ORIGIN``-relative RPATHs on
   the binary and all XSPICE plugins so the tarball is fully self-contained.
7. **Strip** — strips the binary and shared libraries to reduce tarball size.
8. **Verify** — runs a quick batch-mode smoke test (``echo '.end' | ngspice -b -``).
9. **Package** — moves the install prefix to ``ngspice/``, adds
   ``export.envrc``, and creates ``release/ngspice-<image>-<version>.tar.gz``.

Environment variables
---------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Variable
     - Description
   * - ``ngspice_version``
     - NGSpice version number to build (e.g. ``46``). **Required.**
   * - ``image``
     - manylinux image name; used as the platform string in the tarball name.
       Defaults to ``linux``.
   * - ``BUILD_NUM``
     - Appended to ``rls_version`` for traceability (set automatically by
       GitHub Actions to the workflow run ID).
   * - ``rls_version``
     - Override the full release version string (used by the manual Release
       workflow to produce clean ``46`` tags rather than ``46.<run_id>``).

CI / GitHub Actions
-------------------

Two workflows are provided:

``ci.yml``
    Triggered on every push, via ``workflow_dispatch``, and on a weekly
    schedule (Sunday 12:00 UTC).  Automatically detects the latest NGSpice
    version from SourceForge, builds on ``manylinux_2_28_x86_64`` and
    ``manylinux_2_34_x86_64``, and publishes a GitHub **pre-release** with
    the tarballs.

``release.yml``
    Manually triggered via ``workflow_dispatch`` with an explicit
    ``ngspice_version`` input.  Produces a proper (non-pre-release) GitHub
    Release.

Release layout
--------------

The unpacked release directory contains::

    bin/
      ngspice
    lib/
      libreadline.so.7
      libtinfo.so.6
      libgomp.so.1
      libstdc++.so.6
      libgcc_s.so.1
      ngspice/
        analog.cm
        digital.cm
        tlines.cm
        xtradev.cm
        xtraevt.cm
        spice2poly.cm
        table.cm
        ivlng.so
    share/
      ngspice/
        scripts/
    export.envrc
