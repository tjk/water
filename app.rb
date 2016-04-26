#!/usr/bin/env ruby

require "net/http"

# step 1: get expanded site data
# uri = URI("http://waterservices.usgs.gov/nwis/site/?format=rdb&stateCd=ca&siteOutput=expanded")
# Net::HTTP.start(uri.host, uri.port) do |http|
#   request = Net::HTTP::Get.new(uri)
#   http.request(request) do |response|
#     open("site.expanded.rdb", "w") do |io|
#       response.read_body do |chunk|
#         io.write(chunk)
#       end
#     end
#   end
# end

# step 2: build up js file to include
columns = nil
sites = []
File.readlines("site.expanded.rdb").each do |line|
  next if line[0] == "#"

  tokens = line.split("\t").map(&:strip)

  if columns.nil?
    columns = tokens
    next
  end

  sites << tokens
end

sites.shift # ignore "column-definition" row

LATITUDE_IDX = 6
LONGITUDE_IDX = 7
ALTITUDE_IDX = 19

open("site.expanded.sampled.js", "w") do |io|
  io.write("window.data = [\n")
  io.write("  ['Latitude', 'Longitutde', 'Altitude'],\n")
  sites.each_with_index do |v, i|
    alt_va = Integer(sites[i][ALTITUDE_IDX]) rescue nil
    if alt_va && rand(100) < 1 # sample otherwise too many points
      io.write("  [#{sites[i][LATITUDE_IDX]}, #{sites[i][LONGITUDE_IDX]}, #{alt_va}],\n")
    end
  end
  io.write("];")
end
