module ProMotion
  class XLSubFormScreen < XLFormScreen
    attr_accessor :rowDescriptor

    def form_data
      [
        {
          title: rowDescriptor.title,
          cells: rowDescriptor.action.cells.map do |cell|
            tag = cell[:name]
            if tag.respond_to? :to_s
              tag = tag.to_s
            end
            if rowDescriptor && rowDescriptor.value && rowDescriptor.value[tag]
              cell.merge({ value: rowDescriptor.value[tag] })
            else
              cell
            end
          end
        }
      ]
    end

    def update_form_data
      title = rowDescriptor.title
      required = rowDescriptor.action.required

      @form_builder = PM::XLForm.new(self.form_data,
                                     {
                                       title: title,
                                       required: required
                                     })
      @form_object = @form_builder.build
      self.form = @form_object
    end

    ## XLFormDescriptorDelegate
    def formRowDescriptorValueHasChanged(row, oldValue: old_value, newValue: new_value)
      super
      rowDescriptor.value = values
    end
  end
end
