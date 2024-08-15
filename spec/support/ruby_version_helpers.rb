module RubyVersionHelpers
  RUBY_2_4 = Gem::Version.new('2.4.0')
  CURRENT_RUBY = Gem::Version.new(RUBY_VERSION)

  def numeric_type
    if CURRENT_RUBY < RUBY_2_4
      Fixnum
    else
      Integer
    end
  end
  module_function :numeric_type

  def a_numeric
    type = numeric_type
    if type == Integer
      "an #{type}"
    else
      "a #{type}"
    end
  end
  module_function :a_numeric
  def a_float
    "a #{Float}"
  end
  module_function :a_float
end
