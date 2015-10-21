# -*- coding: utf-8 -*-
require "rexml/document"

namespace :mamashai do
  desc "add latitude and longitude to city"
  task :add_lat_and_lng_to_city  => [:environment] do
    doc = REXML::Document.new File.new("tmp/points.xml")
    ActiveRecord::Base.transaction do 
      doc.elements.each("*/point") do |point|
        province=point.attributes["province"].strip
        city = point.attributes["city"].strip
        city_aliase = city.end_with?("市") ? city.gsub(/市$/,'') : "#{city}市"
        lng = point.attributes["lng"].to_f
        lat = point.attributes["lat"].to_f
        province = point.attributes["province"]
        c=City.find_by_name(city) || City.find_by_name(city_aliase)
        unless c.present? 
          unless city.match /北京|重庆|上海|天津/
            province_aliase = province.end_with?("省") ? province.gsub(/省$/,'') : "#{province}省"
            pro=Province.find_by_name(province) || Province.find_by_name(province_aliase)
            unless pro.present?
              puts "city is #{city} province is #{province}"
            else
              City.create :name=>city, :province_id=>pro.id, :longitude=>lng, :latitude=>lat
            end
          end
        else
          c.longitude=lng
          c.latitude=lat
          c.save
        end
      end
      city_map={
        "北京"=>{:latitude=>39.55,:longitude=>116.24},
        "上海"=>{:latitude=>31.14,:longitude=>121.29},
        "天津"=>{:latitude=>39.02,:longitude=>117.12},
        "重庆"=>{:latitude=>29.35,:longitude=>106.33},
        "台湾"=>{:latitude=>25.03,:longitude=>121.30},
        "香港"=>{:latitude=>21.23,:longitude=>115.12},
        "澳门"=>{:latitude=>21.33,:longitude=>115.07},
      }
      provinces=Province.all :conditions=>["name in (?)",["北京","上海","天津","重庆","台湾","香港","澳门"]]
      provinces.each do |pro|
        if pro.cities.present?
          pro.cities.each do |c|
            if c.longitude.blank? or c.latitude.blank?
              c.longitude = city_map[pro.name][:longitude]
              c.latitude = city_map[pro.name][:latitude]
              c.save
            end
          end
        end
      end
      City.all(:conditions=>"longitude is null or latitude is null").each do |c|
        c.longitude = city_map["北京"][:longitude]
        c.latitude = city_map["北京"][:latitude]
        c.save
      end
    end
  end
end
