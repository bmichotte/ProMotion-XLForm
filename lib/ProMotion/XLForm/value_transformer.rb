module ProMotion
  class ValueTransformer
    def self.transformedValueClass
      NSString
    end

    def self.allowsReverseTransformation
      false
    end

    def transformedValue(value)
      return self.transformed_value(value) if self.respond_to?(:transformed_value)
      return nil if value.nil?

      # best effort
      value.inspect
    end
  end
end