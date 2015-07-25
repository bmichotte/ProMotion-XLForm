module ProMotion
  class Validator
    attr_accessor :message

    def isValid(row)
      is_valid = nil
      is_valid = valid?(row) if self.respond_to?(:valid?)

      return nil if is_valid.nil?
      XLFormValidationStatus.formValidationStatusWithMsg(@message, status: is_valid, rowDescriptor: row)
    end

    def valid?(row)
      mp "You have to override valid?", force_color: :red
    end

  end
end
