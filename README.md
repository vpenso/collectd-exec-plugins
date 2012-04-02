Description
===========

Collection of [Collectd][1] Exec Plug-in.

Installation
============

Configuration files `*.conf` and `*.db` should be placed to:

    /etc/collectd/collectd.d/

The executable scripts needs to be deployed to:

    /usr/lib/collectd/exec

You may want to replace the suer name to execute the scripts!
Make sure this uses is allowed to execute all commands used
by the script (by configuring Sudo).

Copying
=======

Copyright 2011 Victor Penso  
License [GPLv3][3] (see LICENSE file)

[1]: http://collectd.org/
[2]: http://gridscheduler.sourceforge.net/
[3]: http://www.gnu.org/licenses/gpl-3.0.html
