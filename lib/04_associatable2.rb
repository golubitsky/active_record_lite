require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      results = DBConnection.execute(<<-SQL)
      SELECT
        #{source_options.table_name}.*
      FROM
        #{through_options.table_name}
      JOIN
        #{source_options.table_name}
      ON
        #{through_options.table_name}.#{source_options.primary_key} =
        #{source_options.table_name}.#{source_options.primary_key}
      WHERE
        #{source_options.table_name}.#{source_options.primary_key} =
        #{send(through_options.foreign_key)}
      SQL

      objects = [] #will be useful for has_many implementation
      results.each do |result|
        objects << source_options.model_class.new(result)
      end
      objects.first
    end

  end

end
