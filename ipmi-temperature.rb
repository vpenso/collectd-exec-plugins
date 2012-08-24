#!/usr/bin/env ruby

#---------------------------------------------------------------
##
## IPMI Collectd Exec Plugin
##
## This is free software: you can redistribute it
## and/or modify it under the terms of the GNU General Public
## License as published by the Free Software Foundation,
## either version 3 of the License, or (at your option) any
## later version.
##
## This program is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
## PURPOSE. See the GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public
## License along with this program. If not, see
##
## <http://www.gnu.org/licenses/>.
##
##----------------------------------------------------------------
## Author: Victor Penso
## Copyright 2012
## Version: 0.1
##----------------------------------------------------------------


hostname = ENV.has_key?('COLLECTD_HOSTNAME') ? ENV['COLLECTD_HOSTNAME'] : 'localhost'
interval = ENV.has_key?('COLLECTD_INTERVAL') ? ENV['COLLECTD_INTERVAL'].to_i : 60


def temperature
  `ipmitool sensor | grep "System Temp" | cut -d'|' -f2`.strip
end

# run until we get killed by a mother program 
while true
  ports.each_pair do |port,lid|
    # post data to the caller program
    $stdout.puts %Q[PUTVAL #{hostname}/ipmi_temperature interval=#{interval} #{time}:#{temperature}]
    # clear output buffer before sleeping
    $stdout.flush
  end
  sleep interval
end

exit 0
