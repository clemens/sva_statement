module AttributeMethods
  def attributes; (@attributes ||= []).uniq; end

  def string_attributes(*attributes)
    attributes.each do |attribute|
      self.attributes << attribute

      attr_writer attribute unless method_defined?("#{attribute}=")
      attr_reader attribute unless method_defined?(attribute)
    end
  end

  def integer_attributes(*attributes)
    attributes.each do |attribute|
      self.attributes << attribute

      define_method("#{attribute}=") do |value|
        instance_variable_set(:"@#{attribute}", value.try(:to_i))
      end unless method_defined?("#{attribute}=")

      attr_reader attribute unless method_defined?(attribute)
    end
  end

  def date_attributes(*attributes)
    attributes.each do |attribute|
      self.attributes << attribute

      define_method("#{attribute}=") do |value|
        value = if value.present?
          value.respond_to?(:strftime) ? value : Date.parse(value)
        end

        instance_variable_set(:"@#{attribute}", value)
      end unless method_defined?("#{attribute}=")

      attr_reader attribute unless method_defined?(attribute)
    end
  end

  def number_attributes(*attributes)
    attributes.each do |attribute|
      self.attributes << attribute

      define_method("#{attribute}=") do |value|
        instance_variable_set(:"@#{attribute}", convert_number(value))
      end unless method_defined?("#{attribute}=")

      attr_reader attribute unless method_defined?(attribute)
    end
  end
end
