require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    cols.map!(&:to_sym)
    @columns = cols
  end

  def self.finalize!
    self.columns.each do |column_name|

      #getter method
      define_method(column_name) do
        self.attributes[column_name]
      end

      #setter method
      define_method("#{column_name}=") do |value|
        self.attributes[column_name] = value
      end

    end
  end

  def self.table_name=(name)
    @table_name = name
  end

  def self.table_name
    # if @table_name
    #   @table_name
    # else
    #   @table_name = self.name.underscore.downcase.pluralize
    # end
    @table_name ||= self.name.underscore.pluralize
  end

  def self.all
    complete_table = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
    SQL
    parse_all(complete_table)
  end

  def self.parse_all(results)
    results.map{|params_hash| self.send(:new, params_hash)}
  end

  def self.find(id)
    single_entry = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        "#{self.table_name}"
      WHERE
        id = ? --solution had table_name.id
    SQL
    parse_all(single_entry).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      raise Exception.new("unknown attribute '#{attr_name}'") unless self.class.columns.include?(attr_name)
      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    #may want to redo this so that default values of nil are set for each column
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    col_names = self.class.columns.drop(1).join(", ")
    question_marks = Array.new(self.class.columns.count - 1){"?"}.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_set = self.class.columns.drop(1).map{|col| "#{col} = ?"}.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1), self.id)
      UPDATE
        #{self.class.table_name}
      SET
         #{col_set}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end
end
