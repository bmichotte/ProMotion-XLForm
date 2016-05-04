module ProMotion
  class XLForm

    include ProMotion::XLFormHelper
    include ProMotion::XLFormCellBuilder
    include ProMotion::XLFormSectionBuilder

    attr_reader :form_data

    def initialize(form_data, opts={})
      @form_data = form_data
      @title = opts[:title] || ''
      @required = opts[:required]
      @auto_focus = opts[:auto_focus]
    end

    def build
      form = XLFormDescriptor.formDescriptorWithTitle(@title)
      form.addAsteriskToRequiredRowsTitle = (@required == :asterisks)


      # focus on this cell
      if @auto_focus
        form.assignFirstResponderOnShow = true
      end

      form_data.each do |section_data|
        section = create_section(section_data)
        form.addFormSection(section)
      end

      form
    end

    def get_callback(descriptor, event)
      tag = descriptor.respond_to?(:multivaluedTag) ? descriptor.multivaluedTag : descriptor.tag
      return if @blocks.nil? || @blocks[tag].nil? || @blocks[tag][event].nil?

      @blocks[tag][event]
    end

    private
    def add_proc(tag, event, block)
      @blocks ||= {}
      @blocks[tag] ||= {}
      @blocks[tag][event] = block.respond_to?('weak!') ? block.weak! : block
    end

    def row_type(symbol)
      {
        text: XLFormRowDescriptorTypeText,
        name: XLFormRowDescriptorTypeName,
        url: XLFormRowDescriptorTypeURL,
        email: XLFormRowDescriptorTypeEmail,
        password: XLFormRowDescriptorTypePassword,
        number: XLFormRowDescriptorTypeNumber,
        phone: XLFormRowDescriptorTypePhone,
        twitter: XLFormRowDescriptorTypeTwitter,
        account: XLFormRowDescriptorTypeAccount,
        integer: XLFormRowDescriptorTypeInteger,
        decimal: XLFormRowDescriptorTypeDecimal,
        textview: XLFormRowDescriptorTypeTextView,
        zip_code: XLFormRowDescriptorTypeZipCode,
        selector_push: XLFormRowDescriptorTypeSelectorPush,
        selector_popover: XLFormRowDescriptorTypeSelectorPopover,
        selector_action_sheet: XLFormRowDescriptorTypeSelectorActionSheet,
        selector_alert_view: XLFormRowDescriptorTypeSelectorAlertView,
        selector_picker_view: XLFormRowDescriptorTypeSelectorPickerView,
        selector_picker_view_inline: XLFormRowDescriptorTypeSelectorPickerViewInline,
        multiple_selector: XLFormRowDescriptorTypeMultipleSelector,
        multiple_selector_popover: XLFormRowDescriptorTypeMultipleSelectorPopover,
        selector_left_right: XLFormRowDescriptorTypeSelectorLeftRight,
        selector_segmented_control: XLFormRowDescriptorTypeSelectorSegmentedControl,
        date_inline: XLFormRowDescriptorTypeDateInline,
        datetime_inline: XLFormRowDescriptorTypeDateTimeInline,
        time_inline: XLFormRowDescriptorTypeTimeInline,
        countdown_timer_inline: XLFormRowDescriptorTypeCountDownTimerInline,
        date: XLFormRowDescriptorTypeDate,
        datetime: XLFormRowDescriptorTypeDateTime,
        time: XLFormRowDescriptorTypeTime,
        countdown_timer: XLFormRowDescriptorTypeCountDownTimer,
        datepicker: XLFormRowDescriptorTypeDatePicker,
        picker: XLFormRowDescriptorTypePicker,
        slider: XLFormRowDescriptorTypeSlider,
        check: XLFormRowDescriptorTypeBooleanCheck,
        switch: XLFormRowDescriptorTypeBooleanSwitch,
        button: XLFormRowDescriptorTypeButton,
        info: XLFormRowDescriptorTypeInfo,
        step_counter: XLFormRowDescriptorTypeStepCounter,
        image: XLFormRowDescriptorTypeImage,
        color: 'XLFormRowDescriptorTypeColor',
      }[symbol]
    end

  end

end
