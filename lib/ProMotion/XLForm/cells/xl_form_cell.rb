module ProMotion
  class XLFormCell < XLFormBaseCell

    def value=(value)
      rowDescriptor.value = value
    end

    def value
      rowDescriptor ? rowDescriptor.value : nil
    end
  end
end
