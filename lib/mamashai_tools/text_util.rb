require 'fileutils'

module MamashaiTools
  class TextUtil
    def initialize
    end
  
    def self.sign(params, secret)
      result = ""
      result << secret
      params.keys.sort.each{ |key|
        result << key << params[key]
      }
      result << secret
      Digest::MD5.hexdigest(result).upcase
    end
    
    def self.params_to_str(params)
      result = []
      params.each{|key, value|
        result << "#{key}=#{value}"
      }
      URI.escape(result.join("&"))
    end
    
    def self.gsub_dirty_words(content)
      return unless content
      if !$dirty_words
        $dirty_words = []
        File.open("./lib/mamashai_tools/dirty_words.txt") do |file|
          file.readlines.each{|line| $dirty_words << line.strip}
        end
      end
      
      for dirty in $dirty_words
        next if dirty.to_s.size < 2
        if dirty.index("|")
          content.gsub(/#{dirty}/i,'')
        elsif dirty.split(" ").size > 0
          has = true
          for d in dirty.split(" ")
            has = false if !content.index(d)
          end
          content = "" if has
        else
          content = '' if content.index(dirty)
        end
      end
      
      content
    end 
    
    def self.scan_atme_names(content) 
      #content.scan(/@(.+?)[\W|$]/)
      content_1 = content.gsub(/^回复/, '@')
      result = content_1.scan(/@(\p{Word}+)/)

      index1 = content.index("回复@")
      index2 = content.index("：") || content.index(":")
      if index1==0 && index2
        name = content[3..index2-1]
        result << [name]
      end
      result.uniq
    end
    
    def self.scan_post_tags(content)
      content.scan(/\[(.+?)\]/)
    end
    
    def self.gsub_not_tag_words(content)
      dirty_words = ''
      File.open("./lib/mamashai_tools/not_tag_words.txt") do |file|
        dirty_words = file.readlines.to_s
      end
      content.gsub(/#{dirty_words}/i,'')
    end 
    
    def self.gsub_site_words(content)
      dirty_words = ''
      File.open("./lib/mamashai_tools/site_words.txt") do |file|
        dirty_words = file.readlines.to_s
      end
      content.gsub(/#{dirty_words}/i,'')
    end
    
    def self.gsub_pdf_words(content)
      return unless content
      pdf_words = ''
      File.open("./lib/mamashai_tools/pdf_words.txt") do |file|
        pdf_words = file.readlines.to_s
      end
      content.gsub(/#{pdf_words}/i,'')
    end 
    
    def self.truncate(content,len)
      help.truncate(content,{:length=>len})
    end
    
    def self.truncate_long_content(long_content,len)
      MamashaiTools::TextUtil.truncate(ActionController::Base.helpers.strip_tags(long_content).gsub(/\r\n/i,'').gsub(/&nbsp;/i,'').gsub(/&radic;/i,''),len)  
    end
    
    def self.md5(str)
      Digest::MD5.hexdigest(str)
    end
    
    def self.uuid
      #UUID.random_create.to_s
      rand(1000000000000000000000)
    end
    
    def self.email_site(email)
      "http://www.#{email.split('@')[1]}"
    end
    
    def self.date_cn(time) 
      time.strftime("%Y#{APP_CONFIG['time_label_y']}%m#{APP_CONFIG['time_label_m']}%d#{APP_CONFIG['time_label_d']}") if time 
    end
    
    def self.rand_8_str
      chars = ("a".."z").to_a + (1..9).to_a
      chars = chars.sort_by { rand }
      str = chars[0..7].to_s
      return str
    end
    
    def self.rand_8_num_str
      chars = (1..9).to_a
      chars = chars.sort_by { rand }
      str = chars[0..7].to_s
      return str
    end
    
    def self.rand_4_num_str
      chars = (1..9).to_a
      chars = chars.sort_by { rand }
      str = chars[0..3].to_s
      return str
    end
    
    def self.encrypt_user_id_key
       1234567
    end
    
    def self.encrypt_user_id_chars
      [["3", "2", "1", "4", "5", "8", "9", "6", "7", "0"], ["4", "2", "0", "9", "1", "5", "7", "6", "8", "3"],
       ["6", "2", "3", "4", "0", "1", "5", "8", "7", "9"], ["1", "5", "3", "4", "2", "0", "6", "8", "7", "9"],
       ["3", "1", "4", "2", "5", "0", "8", "7", "6", "9"], ["8", "1", "4", "0", "3", "5", "7", "6", "2", "9"],
       ["8", "2", "3", "4", "0", "6", "5", "7", "9", "1"], ["2", "1", "0", "5", "4", "3", "6", "9", "8", "7"],
       ["7", "0", "6", "3", "4", "5", "1", "2", "8", "9"]]
    end
    
    def self.encrypt_user_id(id)
      id = id + self.encrypt_user_id_key
      id_chars = id.to_s.split('')
      mod1 = id % 9
      mod2 = id % 7
      chars = self.encrypt_user_id_chars[mod1]
      str = id_chars.collect{|s| "#{chars[s.to_i]}"}.join('')
      return mod2.to_s+str+mod1.to_s
    end
    
    def self.decrypt_user_id(str)
      str = str.to_s
      return nil if str.blank? or str.length < 9
      mod = str[str.length-1..str.length-1].to_i
      chars = self.encrypt_user_id_chars[mod]
      id_chars_str = str[1..str.length-2]
      id_chars_str.split('').collect{|char| chars.index(char) }.join('').to_i - self.encrypt_user_id_key
    end
    
    ############## private #################
    
    def help
      Helper.instance
    end
    
    class Helper
      include Singleton
      include ActionView::Helpers::TextHelper
      include ApplicationHelper
    end
    
  end
end
