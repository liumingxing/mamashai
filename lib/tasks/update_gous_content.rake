require 'rubygems'
require 'nokogiri'
require 'open-uri'
namespace :mamashai do
  #　删除发票信息
  desc "update_gous_content"
  task :update_gous_content  => [:environment] do
    Gou.find_in_batches(:batch_size => 100) do |gous|
      gous.each_with_index do |gou, index|
        ActiveRecord::Base.transaction do
          gou_doc = Nokogiri::HTML::Document.new
          content = gou_doc.fragment(gou.content).children
          content.xpath("div/div").remove
          gou.update_attribute(:content, content.try(:to_html).try(:to_s))
          puts gou.inspect if index % 100 == 0
        end
      end
    end
  end
end