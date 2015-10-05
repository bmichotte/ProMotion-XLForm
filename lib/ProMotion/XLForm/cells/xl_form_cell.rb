module ProMotion
  class XLFormCell < XLFormBaseCell
    include ProMotion::TableViewCellModule

    def check_deprecated_styles
      # just ignore ProMotion messages
    end

    def value=(value)
      rowDescriptor.value = value
    end

    def value
      rowDescriptor ? rowDescriptor.value : nil
    end
  end
end
