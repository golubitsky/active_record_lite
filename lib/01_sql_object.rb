require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    columns = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{table_name}
      LIMIT 0
    SQL
    columns.flatten.map { |column| column.intern }
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}=".intern) do |value|
        # self.instance_variable_set("@#{column}", value) #we are using attributes hash instead
        attributes[column] = value
      end

      define_method(column) do
        # self.instance_variable_get("@#{column}") #we are using attributes hash instead
        attributes[column]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = "#{table_name}"
  end

  def self.table_name
    @table_name ||= self.to_s.downcase.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    objects = []
    results.each do |result|
      objects << new(result)
    end
    objects
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{table_name}
      WHERE id = ?
    SQL

    result.empty? ? nil : new(result.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name.intern)
      send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name} #{col_names}
      VALUES
        #{question_marks}
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    DBConnection.execute(<<-SQL, attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_col_names}
      WHERE
        id = ?
    SQL
  end

  def save
    id ? update : insert
  end

  private

  def question_marks
    "(#{(["?"]*(attributes.size)).join(', ')})"
  end

  def col_names
    "(#{attributes.keys.join(', ')})"
  end

  def set_col_names
    attributes.keys.map{ |attr| "#{attr} = ?" }.join(', ')
  end
end
