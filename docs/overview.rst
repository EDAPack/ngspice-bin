Overview
========

**ngspice-bin** packages `NGSpice <https://ngspice.sourceforge.io/>`_ — the
mixed-level / mixed-signal circuit simulator — into a portable, manylinux-
compatible binary release for Linux.

Why ngspice-bin?
----------------

Upstream NGSpice ships as source code.  Building it requires a C toolchain,
readline, ncurses, and several other libraries that may not be present (or may
be at the wrong version) on every target machine.  ngspice-bin provides:

* A pre-built ``ngspice`` binary that runs on any Linux system with
  glibc ≥ 2.17 (manylinux_2_28 build) without any system-level installation.
* All non-standard shared libraries (``libreadline``, ``libtinfo``,
  ``libgomp``, ``libstdc++``, ``libgcc_s``) bundled inside the tarball with
  ``$ORIGIN``-relative RPATHs — nothing extra needs to be on ``LD_LIBRARY_PATH``.
* XSPICE code-level simulation extensions enabled (analog and digital
  mixed-signal models).
* CIDER numerical device simulation enabled.
* An ``export.envrc`` that prepends ``bin/`` to ``PATH`` via
  `direnv <https://direnv.net/>`_ / `IVPM <https://github.com/fvutils/ivpm>`_.

Release naming
--------------

Each release tarball is named::

    ngspice-<image>-<ngspice_version>.<run_id>.tar.gz

For example::

    ngspice-manylinux_2_28_x86_64-46.12345678.tar.gz

The ``<image>`` field identifies the manylinux base used for the build, giving
a clear indication of the minimum glibc requirement.
