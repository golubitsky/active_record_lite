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
    self.foreign_key = options[:foreign_key] || "#{name}_id".intern
    self.primary_key = options[:primary_key] || "id".intern
    self.class_name = options[:class_name] || name.camelize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.foreign_key = options[:foreign_key] ||
      "#{self_class_name.underscore}_id".intern
    self.primary_key = options[:primary_key] || "id".intern
    self.class_name = options[:class_name] || name.singularize.camelize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions(name, options)
    define_method(name) do
      #stopped here for now
      # options.model_class.send(:foreign_key)

    end
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
