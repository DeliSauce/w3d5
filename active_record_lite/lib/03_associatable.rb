require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
  end

  def table_name
    # ...
  end
end

class BelongsToOptions < AssocOptions
  attr_reader :foreign_key, :primary_key, :class_name
  def initialize(name, options = {})
    @name = name
    @primary_key = options[:primary_key] || :id
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || name.to_s.camelcase
  end

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name.downcase.pluralize
  end

end

class HasManyOptions < AssocOptions
  # attr_reader :foreign_key, :primary_key, :class_name
  #
  # def initialize(name, self_class_name, options = {})
  #   @primary_key = options[:primary_key] || :id
  #   @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
  #   @class_name = options[:class_name] || name.to_s.camelcase
  # end
  #
  # def model_class
  #   @class_name.constantize
  # end
  #
  # def table_name
  #   @class_name.downcase.pluralize
  # end

end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
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
