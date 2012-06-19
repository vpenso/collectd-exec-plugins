#!/usr/bin/env ruby

#---------------------------------------------------------------
##
## Lustre plugin for Collectd
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
## Version: 0.0.1
##----------------------------------------------------------------

require 'fileutils'
require 'timeout'

hostname = ENV.has_key?('COLLECTD_HOSTNAME') ? ENV['COLLECTD_HOSTNAME'] : 'localhost'
interval = ENV.has_key?('COLLECTD_INTERVAL') ? ENV['COLLECTD_INTERVAL'].to_i : 60

# Executes a file listing `ls` against a directory
# in the distributed Lustre file-system.
_path = "/lustre/.collectd/#{hostname}"
FileUtils.mkdir_p(_path)
# In case of problems with Lustre the `ls` command
# will hang for a possibly very long time, therefore
# use timeout.
_timeout = 10
# Generate a set of files randomly checked by
# this script.
0.upto(10).each do |n|
  File.open("#{_path}/#{n}.txt",'w') do |f|
    f.write '0'
  end
end
# main loop running the check in the interval defined by Collectd
while true
  # time stamp
  time=`date +%s`.chop
  # in case the ls command runs into a time out 
  # 10000ms is returned 
  _run_time = 10000
  # drop the output of ls
  command = "/bin/ls #{_path}/#{rand(10)}.txt > /dev/null"
  begin
    timeout(_timeout) do
     _beginning = Time.now
     `#{command}` # run ls
     _ending = Time.now
     # calculate the elapsed time for the ls execution
     _run_time = ( _ending - _beginning ) * 1000
    end
  rescue Timeout::Error
  end
  # write output to stdout
  puts %Q[PUTVAL #{hostname}/lustre/ls_runtime interval=#{interval} #{time}:#{_run_time} ]
  $stdout.flush # make sure to always write the output buffer before sleep
  # wait
  sleep interval
end

exit 0
