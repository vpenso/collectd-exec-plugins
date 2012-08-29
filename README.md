Description
===========

Collection of scripts to be used with the [Collectd][1] 
[Exec Plugin][2].

Each scripts consists of an executable script collecting the
data, a configuration file for Collectd and a data-set 
specification.

* <tt>gridengine-jobs.rb</tt> queries a [GridEngine][5] queue
  master for the number of jobs running, queued and suspended.
* <tt>infiniband-traffic.rb</tt> collects the counters from
  a Infiniband network card using <tt>perfquery</tt>.
* <tt>lustre-ls-runtime.rb</tt> monitors the response time of a
  [Lustre][6] file-system for listing a random set of files. In case
  Lustre doesn't respond to a <tt>ls</tt> within a timeout a 
  spike in the data is produced.
* <tt>ipmi-temperature.rb</tt> collects the system temperature
  using <tt>ipmitool</tt>.


Installation
============

Configuration files `*.conf` and `*.db` should be placed to:

    /etc/collectd/collectd.d/

The executable scripts needs to be deployed to:

    /usr/lib/collectd/exec

You may want to replace the user name to execute the scripts!
Make sure this uses is allowed to execute all commands used
by the script (by configuring Sudo).

Copying
=======

Copyright 2012 Victor Penso  
License [GPLv3][3]

[1]: http://collectd.org/
[2]: http://collectd.org/wiki/index.php/Plugin:Exec
[3]: http://www.gnu.org/licenses/gpl-3.0.html
[4]: http://collectd.org/documentation/manpages/types.db.5.shtml
[5]: http://gridscheduler.sourceforge.net
[6]: http://www.lustre.org/
