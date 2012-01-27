#!/usr/bin/env ruby

#---------------------------------------------------------------
##
## GridEngine plugin for Collectd
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

hostname = ENV.has_key?('COLLECTD_HOSTNAME') ? ENV['COLLECTD_HOSTNAME'] : 'localhost'
interval = ENV.has_key?('COLLECTD_INTERVAL') ? ENV['COLLECTD_INTERVAL'].to_i : 60

command = %q[qstat -ext -u '*']

while true

  time=`date +%s`.chop
  jobs = { :running => 0, :queued => 0, :suspended => 0  }

  `#{command}`.split("\n")[2..-1].each do |job|
    # get the job state
    job.split[7].each_char do |flag|
      case flag
      when 'r': jobs[:running] += 1
      when 'q': jobs[:queued] += 1
      when 's','S]': jobs[:suspended] += 1
      end
    end
  end

  puts %Q[PUTVAL #{hostname}/gridengine/gridengine_jobs interval=#{interval} #{time}:#{jobs[:running]}:#{jobs[:queued]}:#{jobs[:suspended]} ]
  $stdout.flush # make sure to always write the output buffer before sleep

  sleep interval

end

