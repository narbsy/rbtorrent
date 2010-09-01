# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

User.create( :email => 'narbsy@gmail.com', :password => 'oranges' )

ConfigOption.create( [{:name => "torrent-dir", :value => "/home/rtorrent/torrents"}, {:name => "download-dir", :value => "/home/rtorrent/downloads"}] )
