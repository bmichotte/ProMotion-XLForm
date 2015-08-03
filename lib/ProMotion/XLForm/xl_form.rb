module ProMotion
  class XLForm

    attr_reader :form_data

    def initialize(form_data, opts={})
      @form_data = form_data
      @title     = opts[:title] || ''
      @required  = opts[:required]
    end

    def build
      form                                = XLFormDescriptor.formDescriptorWithTitle(@title)
      form.addAsteriskToRequiredRowsTitle = (@required == :asterisks)

      form_data.each do |section_data|
        title = section_data[:title]

        options     = parse_section_options(section_data[:options])
        insert_mode = section_insert_mode(section_data[:insert_mode])

        section = XLFormSectionDescriptor.formSectionWithTitle(title, sectionOptions: options, sectionInsertMode: insert_mode)
        if options.nonzero?
          tag = section_data[:name]
          mp("MutliValued section with no :name option", force_color: :red) unless tag
          if tag.respond_to? :to_s
            tag = tag.to_s
          end
          section.multivaluedTag = tag
        end
        section.footerTitle = section_data[:footer] if section_data[:footer]

        add_proc section, :on_add, section_data[:on_add] if section_data[:on_add]
        add_proc section, :on_remove, section_data[:on_remove] if section_data[:on_remove]

        form.addFormSection(section)

        section_data[:cells].each do |cell_data|
          tag = cell_data[:name]
          mp("Cell with no :name option", force_color: :red) unless tag
          if tag.respond_to? :to_s
            tag = tag.to_s
          end
          title = cell_data[:title]
          type  = cell_data[:type]
          if type.nil? and cell_data[:cells]
            type = :selector_push
          end

          cell = XLFormRowDescriptor.formRowDescriptorWithTag(tag, rowType: row_type(type), title: title)

          cell.required = cell_data[:required]

          properties = cell_data[:properties] || {}

          # placeholder
          cell.cellConfigAtConfigure.setObject(cell_data[:placeholder], forKey: "textField.placeholder") if cell_data[:placeholder]

          # step_counter
          if cell_data[:type] == :step_counter
            min  = properties[:min]
            max  = properties[:max]
            step = properties[:step]

            cell.cellConfigAtConfigure.setObject(true, forKey: "stepControl.wraps")
            cell.cellConfigAtConfigure.setObject(min, forKey: "stepControl.minimumValue") if min
            cell.cellConfigAtConfigure.setObject(max, forKey: "stepControl.maximumValue") if max
            cell.cellConfigAtConfigure.setObject(step, forKey: "stepControl.maximumValue") if step
          end

          # slider
          if cell_data[:type] == :slider
            min  = properties[:min]
            max  = properties[:max]
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
          elsif cell_data[:type] == :color
            cell_class = XLFormColorSelectorCell if cell_class.nil?
          end

          cell.cellClass = cell_class if cell_class

          # subcells
          if cell_data[:cells]
            cell.action.viewControllerClass = ProMotion::XLSubFormScreen
            cell.action.cells               = cell_data[:cells]
            cell.valueTransformer           = ProMotion::ValueTransformer
          end

          # also accept default XLForm viewControllerClass
          cell.action.viewControllerClass = cell_data[:view_controller_class] if cell_data[:view_controller_class]
          cell.valueTransformer           = cell_data[:value_transformer] if cell_data[:value_transformer]

          # callbacks
          add_proc cell, :on_change, cell_data[:on_change] if cell_data[:on_change]
          add_proc cell, :on_add, cell_data[:on_add] if cell_data[:on_add]
          add_proc cell, :on_remove, cell_data[:on_remove] if cell_data[:on_remove]

          cell.selectorTitle   = cell_data[:selector_title] if cell_data[:selector_title]
          cell.options = cell_data[:options]

          value = cell_data[:value]
          if value and cell.selectorOptions
            cell.selectorOptions.each do |opt|
              if opt.formValue == value
                value = opt
                break
              end
            end
          end

          cell.value    = value if value

          cell.disabled = !cell_data[:enabled] if cell_data[:enabled]

          # row visible
          if cell_data[:visible]
            predicate = cell_data[:visible]
            if predicate.is_a?(Hash)
              tag = predicate[:name]
              operand = case predicate[:is]
                when :equal
                  '=='
                when :not_equal
                  '!='
                when :contains
                  'contains'
                when :not_contains
                  'not contains'
                else
                  predicate[:is]
                end
              value = predicate[:value]
            else
              match = /(:?[a-zA-Z_]+)\s+(==|!=|contains|not contains)\s+(.*)/.match(predicate)
              if match and match.length == 4
                # todo better than ignore ?
                tag = match[1]
                operand = match[2]
                value = match[3]
                if value =~ /"(.*)"/
                  value = value[1, value.length - 2]
                end
              end
            end

            if tag and operand
              if tag.is_a?(Symbol)
                tag = tag.to_s
              elsif tag.start_with?(':')
                tag[0] = ''
              end
              value = case value
                when 'true', :true, true
                  0
                when 'false', :false, false
                  1
                when String
                  "\"#{value}\""
                else
                  value
                end

              if operand == 'contains'
                cell.hidden = "$#{tag} contains[c] #{value}"
              elsif operand == 'not contains'
                cell.hidden = "not($#{tag} contains[c] #{value})"
              else
                cell.hidden = "$#{tag} #{operand} #{value}"
              end
            else
              mp "#{cell_data[:visible]} can not be parsed", force_color: :red
            end
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
                if value.is_a?(ProMotion::Validator) or value.respond_to?(:isValid)
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

          section.addFormRow(cell)

          # multi sections
          if section.multivaluedTag
            cell.action.required           = @required
            section.multivaluedRowTemplate = cell.copy
          end
        end
      end

      form
    end

    def get_callback(row, event)
      return if @blocks.nil? or @blocks[row].nil? or @blocks[row][event].nil?

      @blocks[row][event]
    end

    private

    def add_proc(tag, event, block)
      @blocks             ||= {}
      @blocks[tag]        ||= {}
      @blocks[tag][event] = block.respond_to?('weak!') ? block.weak! : block
    end

    def parse_section_options(options)
      return section_options(:none) if options.nil?

      opts = section_options(:none)
      options.each do |opt|
        opts |= section_options(opt)
      end

      opts
    end

    def section_insert_mode(symbol)
      {
          last_row: XLFormSectionInsertModeLastRow,
          button:   XLFormSectionInsertModeButton
      }[symbol] || symbol || XLFormSectionInsertModeLastRow
    end

    def section_options(symbol)
      {
          none:    XLFormSectionOptionNone,
          insert:  XLFormSectionOptionCanInsert,
          delete:  XLFormSectionOptionCanDelete,
          reorder: XLFormSectionOptionCanReorder
      }[symbol] || symbol || XLFormSectionOptionNone
    end

    def row_type(symbol)
      {
          text:                        XLFormRowDescriptorTypeText,
          name:                        XLFormRowDescriptorTypeName,
          url:                         XLFormRowDescriptorTypeURL,
          email:                       XLFormRowDescriptorTypeEmail,
          password:                    XLFormRowDescriptorTypePassword,
          number:                      XLFormRowDescriptorTypeNumber,
          phone:                       XLFormRowDescriptorTypePhone,
          twitter:                     XLFormRowDescriptorTypeTwitter,
          account:                     XLFormRowDescriptorTypeAccount,
          integer:                     XLFormRowDescriptorTypeInteger,
          decimal:                     XLFormRowDescriptorTypeDecimal,
          textview:                    XLFormRowDescriptorTypeTextView,
          selector_push:               XLFormRowDescriptorTypeSelectorPush,
          selector_popover:            XLFormRowDescriptorTypeSelectorPopover,
          selector_action_sheet:       XLFormRowDescriptorTypeSelectorActionSheet,
          selector_alert_view:         XLFormRowDescriptorTypeSelectorAlertView,
          selector_picker_view:        XLFormRowDescriptorTypeSelectorPickerView,
          selector_picker_view_inline: XLFormRowDescriptorTypeSelectorPickerViewInline,
          multiple_selector:           XLFormRowDescriptorTypeMultipleSelector,
          multiple_selector_popover:   XLFormRowDescriptorTypeMultipleSelectorPopover,
          selector_left_right:         XLFormRowDescriptorTypeSelectorLeftRight,
          selector_segmented_control:  XLFormRowDescriptorTypeSelectorSegmentedControl,
          date_inline:                 XLFormRowDescriptorTypeDateInline,
          datetime_inline:             XLFormRowDescriptorTypeDateTimeInline,
          time_inline:                 XLFormRowDescriptorTypeTimeInline,
          countdown_timer_inline:      XLFormRowDescriptorTypeCountDownTimerInline,
          date:                        XLFormRowDescriptorTypeDate,
          datetime:                    XLFormRowDescriptorTypeDateTime,
          time:                        XLFormRowDescriptorTypeTime,
          countdown_timer:             XLFormRowDescriptorTypeCountDownTimer,
          datepicker:                  XLFormRowDescriptorTypeDatePicker,
          picker:                      XLFormRowDescriptorTypePicker,
          slider:                      XLFormRowDescriptorTypeSlider,
          check:                       XLFormRowDescriptorTypeBooleanCheck,
          switch:                      XLFormRowDescriptorTypeBooleanSwitch,
          button:                      XLFormRowDescriptorTypeButton,
          info:                        XLFormRowDescriptorTypeInfo,
          step_counter:                XLFormRowDescriptorTypeStepCounter,
          image:                       'XLFormRowDescriptorTypeImage',
          color:                       'XLFormRowDescriptorTypeColor',
      }[symbol] || symbol
    end

  end

end
