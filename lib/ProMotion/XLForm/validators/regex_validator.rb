module ProMotion
  class RegexValidator < ProMotion::Validator
    attr_accessor :regex

    def initialize(message, regex)
      @message = message
      @regex = regex
    end

    def valid?(row)
      return nil if row.nil? or row.value.nil? or !row.value.is_a?(String)

      !@regex.match(row.value).nil?
    end

    def self.validator(message, regex)
      ProMotion::RegexValidator.new(message, regex)
    end
  end
end
