class ActiveRecord::Base
  # Returns a string with all the column names, useful for :group support in postgresql.
  def self.columns_with_table_name
    column_names.collect {|c| "#{quoted_table_name}.#{c}"}.join(",")
  end
end