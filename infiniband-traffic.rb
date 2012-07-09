#!/usr/bin/env ruby

#---------------------------------------------------------------
##
## Infiniband Collectd Exec Plugin
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
## Version: 0.5.0
##----------------------------------------------------------------


def value(line)
  line.delete('.').split(':')[1].to_i
end

# returns a hash containing the Infiniband interface performance
# metrics, for a given LID on port
def read_values(lid,port=1)
  data = { :rbytes => 0, :tbytes => 0, :rpkts => 0, :tpkts => 0 }
  # read the perfquery manual for more information
  command = %Q[sudo /usr/sbin/perfquery -r #{lid} #{port} 0xf000]
  # clean all read counters, except of error counts
  `#{command}`.split("\n").each do |line|
    case line
    when /^RcvPkts/ # received packets
      data[:rpkts] = value(line) 
    when /^XmtPkts/ # transmitted packets
      data[:tpkts] = value(line)
    when /^RcvData/ # received bytes
      data[:rbytes] = value(line) * 4 # result in octets
    when /^XmtData/ # transmitted bytes
      data[:tbytes] = value(line) * 4 # result in octets
    when /^SymbolErrors/
      data[:symerr] = value(line)
    when /^LinkRecovers/
      data[:linkrec] = value(line)
    when /^LinkDowned/
      data[:linkdown] = value(line)
    when /^RcvErrors/
      data[:rerrors] = value(line)
    when /^RcvRemotePhysErrors/
      data[:rphyserrors] = value(line)
    when /^RcvSwRelayErrors/
      data[:rrelerrors] = value(line)
    when /^XmtDiscards/
      data[:xmtd] = value(line)
    when /^XmtConstraintErrors/
      data[:xmtcerrors] = value(line)
    when /^RcvConstraintErrors/
      data[:rcerrors] = value(line)
    when /^LinkIntegrityErrors/
      data[:linkerrors] = value(line)
    when /^ExcBufOverrunErrors/
      data[:buferrors] = value(line)
    when /^VL15Dropped/
      data[:vdropped] =value(line)
    end
  end
  return data
end

# determines list of Infiniband ports and their corresponding LIDs
def ports
  list = Hash.new
  ibstat = `/usr/sbin/ibstat`.split("\n")
  ibstat.each_index do |i|
    line = ibstat[i].lstrip.chop
    if line =~ /^Port [0-9]*$/
      number = line.delete(':').gsub(/Port /,'')
      lid = ibstat[i+4].lstrip.split(':')[1].lstrip
      list[number] = lid 
    end
  end
  return list
end

hostname = ENV.has_key?('COLLECTD_HOSTNAME') ? ENV['COLLECTD_HOSTNAME'] : 'localhost'
interval = ENV.has_key?('COLLECTD_INTERVAL') ? ENV['COLLECTD_INTERVAL'].to_i : 60

error_counters = true

# run until we get killed by a mother program 
while true
  ports.each_pair do |port,lid|
    # clean the counters
    trash = read_values(lid,port)
    sleep(1) # accumulate counters for one second
    # read the metrics 
    data = read_values(lid,port)
    time=`date +%s`.chop
    # post data to the caller program
    $stdout.puts %Q[PUTVAL #{hostname}/infiniband/ib_octets-port#{port} interval=#{interval} #{time}:#{data[:rbytes]}:#{data[:tbytes]}]
    $stdout.puts %Q[PUTVAL #{hostname}/infiniband/ib_packets-port#{port} interval=#{interval} #{time}:#{data[:rpkts]}:#{data[:tpkts]}]
    # optionally monitor error counters
    if error_counters
      # SymbolErrors, LinkRecovers, LinkDowned, LinkIntegrityErrors
      link = [data[:symerr],data[:linkrec],data[:linkdown],data[:linkerrors]].join(':')
      $stdout.puts %Q[PUTVAL #{hostname}/infiniband/ib_linkerror-port#{port} interval=#{interval} #{time}:#{link}]
      # RcvErrors, RcvRemotePhysErrors, ExcBufOverrunErrors
      rcv = [data[:rerrors],data[:rphyserrors],data[:buferrors]].join(':')
      $stdout.puts %Q[PUTVAL #{hostname}/infiniband/ib_rcverror-port#{port} interval=#{interval} #{time}:#{rcv}]
      # VL15Dropped, XmtDiscards
      pkg = [data[:vdropped],data[:xmtd]].join(':')
      $stdout.puts %Q[PUTVAL #{hostname}/infiniband/ib_pkgerror-port#{port} interval=#{interval} #{time}:#{pkg}]
    end
    # clear output buffer before sleeping
    $stdout.flush
  end
  sleep interval
end

exit 0
