ssh-utils
=========

Abstract
--------

The **ssh-utils package** provides tools and extensions for
the application of SSH.

Current contained tools:

* ssh-agent-manage.sh

  The management of the parallel SSH access
  by multiple agents, sessions, and keys.

  Allows Sysadmins and DevOps to open additional terminals
  and easily attach them to a an arbitrary shared local
  ssh-agent.

* ssh-pk-type.sh

* ssh-pk-asn1.sh

Install
-------

  The current version is just a bunch of tiny tools,
  designed for the expert user. Therefore currently
  there is some lack of comfort.

  So unpack the archive and copy these into a
  directory within your search path.

Platforms
---------

  Requires bash and OpenSSH.

  Tested for now on Linux only, may work for
  any Linux and Unix platform, including
  Apple-MacOS.

  Should work on Windows platforms by Cygwin.

Examples
--------

  - "ssh-agent-manage.sh --de"

    show ssh call environment

  - "ssh-agent-manage.sh -A"

    create an agent, calls 'ssh-agent'

  - ". ssh-agent-manage.sh -S"

    select and set a local running agent

    **REMINDER**:
      For setting of the environment of the current
      shell the 'source-call' variant is required.

  - "ssh-agent-manage.sh --de"

    show ssh call environment, after setting the
    current agent by '-S'

  - "ssh-agent-manage.sh -a"

    adds a key to current agent

  - "ssh-agent-manage.sh -p"

    list keys of current agent

  - "ssh-agent-manage.sh -e"

    enumerate all stored keys

  - "ssh-agent-manage.sh -P"

    list all local running agents

  - "ssh-agent-manage.sh -K"

    kill a selected running agent

  - ". ssh-agent-manage.sh -C"

    clears current shell environment

  - "ssh-agent-manage.sh -h"

    short help

  - "ssh-agent-manage.sh -help"

    detailed help

Documentation
-------------

For current documentation refer to the help:

  '-h':     short help

  '-help':  detailed help

Project Data
------------

* PROJECT:   ssh-utils

* MISSION:   Simplify the application of ssh.

* VERSION:   00.01

* RELEASE:   00.01

* NICKNAME:  Scotty

* MISSION:   Beam you up to, where ever you want.

* STATUS:    alpha

* AUTHOR:    Arno-Can Uestuensoez

* COPYRIGHT: Copyright (C) 2011,2012,2013,2017 Arno-Can Uestuensoez @Ingenieurbuero Arno-Can Uestuensoez

* LICENSE:   Artistic-License-2.0 + Forced-Fairplay-Constraints
  Refer to enclose documents:

  *  ArtisticLicense20.html - for base license: Artistic-License-2.0

  *  licenses-amendments.txt - for amendments: Forced-Fairplay-Constraints

Versions and Releases
---------------------

**Planned Releases:**

* RELEASE: 00.00.00x - Pre-Alpha: Extraction of the features from hard-coded application into a reusable package.

* RELEASE: 00.01.00x - Alpha: Completion of basic features.

* RELEASE: 00.02.00x - Alpha: Completion of features, stable interface.

* RELEASE: 00.03.00x - Beta: Accomplish test cases for medium to high complexity.

* RELEASE: 00.04.00x - Production: First production release. Estimated number of UnitTests := 1000.

* RELEASE: 00.05.00x - Production: Various performance enhancements.

* RELEASE: 00.06.00x - Production: Security review.

* RELEASE: >         - Production: Stable and compatible continued development.

**Current Release: 00.01.007 - Alpha:**

* Added the distinction for private and public keys of RSA, DSA, and ECDSA.

Current test status:

* UnitTests: >0(CLI)/0(Eclipse)

* Use-Cases as UnitTests: >0

**Total**: >0

