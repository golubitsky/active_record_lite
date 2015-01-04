require_relative '02_searchable'
require 'active_support/inflector'

# module TableizeFix
#   def pluralize
#     return "humans" if self.downcase == 'human'
#     super
#   end
# end
#
# class String
#   prepend TableizeFix
# end

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    self.class_name = options[:class_name] || name.to_s.camelize
    self.foreign_key = options[:foreign_key] || "#{name}_id".intern
    self.primary_key = options[:primary_key] || "id".intern
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.class_name = options[:class_name] || name.to_s.singularize.camelize
    self.foreign_key = options[:foreign_key] ||
      "#{self_class_name.underscore}_id".intern
    self.primary_key = options[:primary_key] || "id".intern
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    
    define_method(name) do
      return nil unless send(options.foreign_key)

      result = DBConnection.execute(<<-SQL)
        SELECT
          *
        FROM
          #{options.table_name}
        WHERE
          #{options.primary_key} = #{send(options.foreign_key)}
      SQL

      options.model_class.new(result.first)
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      results = DBConnection.execute(<<-SQL)
        SELECT
          *
        FROM
          #{options.table_name}
        WHERE
          #{options.foreign_key} = #{send(options.primary_key)}
      SQL

      objects = []
      results.each do |result|
        objects << options.model_class.new(result)
      end
      objects
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
