module ProMotion
  module XLFormCellBuilder

    def create_cell(cell_data)
      tag = cell_data[:name]
      mp("Cell with no :name option", force_color: :red) unless tag
      if tag.respond_to? :to_s
        tag = tag.to_s
      end
      title = cell_data[:title]
      type = cell_data[:type]
      if type.nil? && cell_data[:cells]
        type = :selector_push
      end

      cell = XLFormRowDescriptor.formRowDescriptorWithTag(tag, rowType: row_type(type), title: title)

      cell.required = cell_data[:required]

      properties = cell_data[:properties] || {}

      # placeholder
      if cell_data[:placeholder]
        if type == :textview
          cell.cellConfigAtConfigure.setObject(cell_data[:placeholder], forKey: "textView.placeholder")
        else
          cell.cellConfigAtConfigure.setObject(cell_data[:placeholder], forKey: "textField.placeholder")
        end
      end

      # step_counter
      if cell_data[:type] == :step_counter
        min = properties[:min]
        max = properties[:max]
        step = properties[:step]

        cell.cellConfigAtConfigure.setObject(true, forKey: "stepControl.wraps")
        cell.cellConfigAtConfigure.setObject(min, forKey: "stepControl.minimumValue") if min
        cell.cellConfigAtConfigure.setObject(max, forKey: "stepControl.maximumValue") if max
        cell.cellConfigAtConfigure.setObject(step, forKey: "stepControl.maximumValue") if step
      end

      # slider
      if cell_data[:type] == :slider
        min = properties[:min]
        max = properties[:max]
        step = properties[:step]
        cell.cellConfigAtConfigure.setObject(min, forKey: "slider.minimumValue") if min
        cell.cellConfigAtConfigure.setObject(max, forKey: "slider.maximumValue") if max
        cell.cellConfigAtConfigure.setObject(step, forKey: "steps") if step
      end

      # dates
      if [:date_inline, :datetime_inline, :time_inline, :date, :datetime, :time, :datepicker].include? cell_data[:type]
        min = properties[:min]
        max = properties[:max]
        cell.cellConfigAtConfigure.setObject(min, forKey: "minimumDate") if min
        cell.cellConfigAtConfigure.setObject(max, forKey: "maximumDate") if max
      end

      cell_class = cell_data[:cell_class]

      # image
      if cell_data[:type] == :image
        cell_class = XLFormImageSelectorCell if cell_class.nil?
        cell_data[:height] ||= 100
      elsif cell_data[:type] == :color
        cell_class = XLFormColorSelectorCell if cell_class.nil?
      end

      # image accessory
      if cell_data[:image]
        accessory_image = cell_data[:image].is_a?(UIImage) ? cell_data[:image] : UIImage.imageNamed(cell_data[:image])
        cell.cellConfigAtConfigure.setObject(accessory_image, forKey: "image")
      end

      cell.cellClass = cell_class if cell_class

      # subcells
      if cell_data[:cells]
        cell.action.viewControllerClass = ProMotion::XLSubFormScreen
        cell.action.cells = cell_data[:cells]
        cell.valueTransformer = ProMotion::ValueTransformer
      end

      # also accept default XLForm viewControllerClass
      cell.action.viewControllerClass = cell_data[:view_controller_class] if cell_data[:view_controller_class]
      cell.valueTransformer = cell_data[:value_transformer] if cell_data[:value_transformer]

      # callbacks
      add_proc tag, :on_change, cell_data[:on_change] if cell_data[:on_change]
      add_proc tag, :on_add, cell_data[:on_add] if cell_data[:on_add]
      add_proc tag, :on_remove, cell_data[:on_remove] if cell_data[:on_remove]

      # button clicks
      if cell_data[:type] == :button && cell_data[:on_click]
        cell.action.formBlock = -> (cell) {
          action = cell_data[:on_click]
          case action.arity
            when 0
              action.call
            when 1
              action.call(cell)
            else
              mp(":on_click take 0 or 1 argument", force_color: :red)
          end
        }
      end

      cell.selectorTitle = cell_data[:selector_title] if cell_data[:selector_title]
      cell.options = cell_data[:options]

      cell.disabled = !cell_data.fetch(:enabled, true)

      # row visible
      if cell_data.has_key?(:hidden)
        configure_hidden(cell, cell_data[:hidden])
      end

      # validators
      if cell_data[:validators]
        validators = cell_data[:validators]
        validators.each do |key, value|
          validator = case key
                        when :email
                          XLFormValidator.emailValidator
                        when :regex
                          regex = value[:regex]
                          if regex.is_a?(String)
                            XLFormRegexValidator.formRegexValidatorWithMsg(value[:message], regex: regex)
                          elsif regex.is_a?(Regexp)
                            ProMotion::RegexValidator.validator(value[:message], regex)
                          else
                            mp "Invalid regex : #{regex.inspect}. Please provides a Regexp or a String", force_color: :red
                            nil
                          end
                        when :url
                          ProMotion::UrlValidator.validator
                        else
                          if value.is_a?(ProMotion::Validator) || value.respond_to?(:isValid)
                            value
                          else
                            mp "Invalid validator : #{key}", force_color: :red
                            nil
                          end
                      end

          if validator
            cell.addValidator(validator)
          end
        end
      end

      # customization
      appearance = cell_data[:appearance]
      if appearance
        cell.cellConfig["textLabel.font"] = appearance[:font] if appearance[:font]
        cell.cellConfig["textLabel.textColor"] = appearance[:color] if appearance[:color]
        cell.cellConfig["detailTextLabel.font"] = appearance[:detail_font] if appearance[:detail_font]
        cell.cellConfig["detailTextLabel.textColor"] = appearance[:detail_color] if appearance[:detail_color]
        cell.cellConfig["backgroundColor"] = appearance[:background_color] if appearance[:background_color]

        appearance.delete_if { |k, v| k.is_a?(Symbol) }.each do |k, v|
          cell.cellConfig[k] = v
        end
      end

      value = cell_data[:value]
      if value && cell.selectorOptions
        cell.selectorOptions.each do |opt|
          if opt.formValue == value
            value = opt
            break
          end
        end
      end

      if value.is_a?(TrueClass) && (value === true || value === false)
        value = value ? 1 : 0
      end

      cell.value = value

      # move this at the end so we can "override" some cell_data
      cell.cell_data = cell_data

      cell
    end

  end
end
