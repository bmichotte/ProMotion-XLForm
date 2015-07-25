module ProMotion
  class UrlValidator
    def self.validator
      ProMotion::RegexValidator.validator(NSLocalizedString("Invalid url", nil), /^https?:\/\/.*/)
    end
  end
end
