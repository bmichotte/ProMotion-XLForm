module ProMotion
  class ValueTransformer
    def self.transformedValueClass
      NSString
    end

    def self.allowsReverseTransformation
      false
    end

    def transformedValue(value)
      return nil if value.nil?

      # best effort
      value.inspect
    end
  end
end