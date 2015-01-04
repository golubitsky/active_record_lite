require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.class.assoc_options[source_name].table_name}
      JOIN
        #{self.class.assoc_options[through_name].table_name}
      ON
        #{self.class.assoc_options[through_name].foreign_key} =
          #{self.class.assoc_options[source_name].primary_key}
      WHERE
        #{self.class.assoc_options[source_name].primary_key} =
          #{send(self.class.assoc_options[through_name].foreign_key)}
      SQL

      objects = []
      results.each do |result|
        objects << options.model_class.new(result)
      end
      objects
    end

  end

end
