module ProMotion
  module XLFormModule

    def self.included(base)
      base.extend(XLFormClassMethods)
    end

  end
end
