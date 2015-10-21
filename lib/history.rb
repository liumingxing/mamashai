module MMS
  module History
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        alias_method_chain :before_update,:history
      end
    end
    module ClassMethods
      def save_history_before_update(name,opt={})
        @columns_with_history ||= {}
        opt[:history_column_name] = opt[:column] || "#{name}_history"
        history_column_name = opt[:history_column_name].to_sym
        column_with_history = name.to_sym
        @columns_with_history.merge!(column_with_history=>opt)
        serialize history_column_name,Array
        attr_protected history_column_name
          
          define_method(column_with_history){|*version|
            return read_attribute(column_with_history) if version[0].nil?
            return self.send(history_column_name)[version[0].to_i]
          }

          define_method(history_column_name){
            history=read_attribute(history_column_name) || []
            return history
          }
          
          define_method("#{history_column_name}=".to_sym){|content|
            (write_attribute(history_column_name,nil) ; return) if content.nil?
            history=read_attribute(history_column_name) || []
            if history.size > 11
              history.delete_at(0)
            end
            history << content
            write_attribute(history_column_name,history)
          }

      end
    end

    # Instance methods
    def before_update_with_history
      @columns_with_history = self.class.instance_variable_get("@columns_with_history")
      @columns_with_history.each_pair do |column_with_history,opt|
        if self.changed.include? column_with_history.to_s
          set_history_method="#{opt[:history_column_name]}="
          self.send(set_history_method,self.send(column_with_history))
        end
      end
      return before_update_without_history 
    end
  end
end
