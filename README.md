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

These instructions cover Debian Squeeze, but should be easy
to adapt to other Linux distributions. 

Optional configurations for Collectd plug-ins are automatically 
read from <tt>/etc/collectd/collectd.d/</tt>, copy `*.conf` and 
`*.db` into this directory. The executable scripts need to be 
deployed to <tt>/usr/lib/collectd/exec</tt>. After deployment
restart the Collectd daemon. Check if the daemon has resumed 
normal operation by looking to the log-file. 

    » /etc/init.d/collectd restart
    » cat /var/log/collectd.log
    ...SNIP...
    [2012-08-29 16:34:37] Initialization complete, entering read-loop.
    » ls /var/lib/collectd/rrd/$(hostname -f)/ipmi
    ipmi_temperature.rrd

If everything works as expected you should find a new RRD file for 
the values collected by a script. The example above shows where 
to find a corresponding file for the IPMI temperature script. 

Depending on the script it may be necessary to configure Sudo to
allow the monitoring user to execute commands limited to root.
All configuration files inside this repository require a user 
called "mon" for this purpose.

You can add a file to the <tt>/etc/sudoers.d/</tt> directory to 
enable "mon" to execute a certain command. The following example 
illustrates this for the <tt>ipmitool</tt> command: 

    » echo "mon $(hostname -f) = NOPASSWD: /usr/bin/ipmitool" > /etc/sudoers.d/ipmitool
    » chmod 0440 /etc/sudoers.d/ipmitool

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
