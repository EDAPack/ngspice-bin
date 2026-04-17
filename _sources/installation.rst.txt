Installation
============

From a GitHub Release tarball
------------------------------

Download the latest tarball for your platform from the
`GitHub Releases page <https://github.com/EDAPack/ngspice-bin/releases>`_
and unpack it::

    tar xf ngspice-manylinux_2_28_x86_64-<version>.tar.gz
    export PATH=$(pwd)/ngspice/bin:$PATH

Verify the installation::

    echo '.end' | ngspice -b -

With IVPM
---------

`IVPM <https://github.com/fvutils/ivpm>`_ users can declare a dependency
directly in their project's ``ivpm.yaml``::

    package:
      dep-sets:
        - name: default-dev
          deps:
            - name: ngspice-bin
              src: gh-rls
              url: https://github.com/EDAPack/ngspice-bin

Then run::

    ivpm update

IVPM will prepend the bundled ``bin/`` directory to ``PATH`` automatically
via the ``export.envrc`` included in the tarball.

With direnv
-----------

If you unpack the tarball manually alongside a project, add the following
to your ``.envrc``::

    source_env /path/to/ngspice/export.envrc

or simply::

    PATH_add /path/to/ngspice/bin

System requirements
-------------------

* Linux x86-64 with **glibc ≥ 2.17** (manylinux_2_28 build).
* No additional runtime libraries required — all non-standard dependencies
  are bundled inside the tarball.
