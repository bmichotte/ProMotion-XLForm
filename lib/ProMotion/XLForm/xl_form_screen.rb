module ProMotion
  class XLFormScreen < XlFormViewController
    include ProMotion::ScreenModule
    include ProMotion::XLFormModule

    attr_reader :form_object

    def viewDidLoad
      super
      update_form_data

      form_options = self.class.get_form_options

      if form_options[:on_cancel]
        on_cancel = form_options[:on_cancel]
        title = NSLocalizedString('Cancel', nil)
        item = :cancel
        if on_cancel.is_a? Hash
          title = on_cancel[:title] if on_cancel[:title]
          item = on_cancel[:item] if on_cancel[:item]
        end

        set_nav_bar_button :left, {
                                  system_item: item,
                                  title: title,
                                  action: 'on_cancel:'
                                }
      end

      if form_options[:on_save]
        on_cancel = form_options[:on_save]
        title = NSLocalizedString('Save', nil)
        item = :save
        if on_cancel.is_a? Hash
          title = on_cancel[:title] if on_cancel[:title]
          item = on_cancel[:item] if on_cancel[:item]
        end

        set_nav_bar_button :right, {
                                   system_item: item,
                                   title: title,
                                   action: 'on_save:'
                                 }
      end

      self.form_added if self.respond_to?(:form_added)
    end

    def form_data
      PM.logger.info "You need to implement a `form_data` method in #{self.class.to_s}."
      []
    end

    def update_form_data
      form_options = self.class.get_form_options
      title = self.class.title
      required = form_options[:required]

      @form_builder = PM::XLForm.new(self.form_data,
                                     {
                                       title: title,
                                       required: required
                                     })
      @form_object = @form_builder.build
      self.form = @form_object
    end

    def values
      values = {}
      formValues.each do |key, value|
        values[key] = clean_value(value)
      end

      values
    end

    def value_for_cell(tag)
      if tag.respond_to?(:to_s)
        tag = tag.to_s
      end
      values.has_key?(tag) ? values[tag] : nil
    end

    def valid?
      validation_errors.empty?
    end

    alias :validation_errors :formValidationErrors

    def display_errors
      return if valid?

      errors = validation_errors.map do |error|
        error.localizedDescription
      end

      if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1
        alert = UIAlertController.alertControllerWithTitle(NSLocalizedString('Error', nil),
                                                           message: errors.join(', '),
                                                           preferredStyle: UIAlertControllerStyleAlert)
        action = UIAlertAction.actionWithTitle(NSLocalizedString('OK', nil),
                                               style: UIAlertActionStyleDefault,
                                               handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
      else
        alert = UIAlertView.new
        alert.title = NSLocalizedString('Error', nil)
        alert.message = errors.join(', ')
        alert.addButtonWithTitle(NSLocalizedString('OK', nil))
        alert.show
      end
    end

    def section_with_tag(tag)
      if tag.respond_to? :to_s
        tag = tag.to_s
      end
      self.form.formSections.select { |section| section.multivaluedTag && section.multivaluedTag == tag }
        .first
    end

    def cell_with_tag(tag)
      if tag.respond_to? :to_s
        tag = tag.to_s
      end
      self.form.formRowWithTag(tag)
    end

    def cell_at_path(path)
      self.form.formRowAtIndex(path)
    end

    def reload(cell)
      reloadFormRow(cell)
    end

    def add_cell(cell, opts={})
      if opts[:before]
        row = opts[:before]
        if row.is_a?(Symbol)
          row = cell_with_tag(row)
        end
        self.form.addFormRow(cell, beforeRow: row)
      elsif opts[:after]
        row = opts[:after]
        if row.is_a?(Symbol)
          row = cell_with_tag(row)
        end
        self.form.addFormRow(cell, afterRow: row)
      else
        mp "Don't know where to add cell, please provides either :before or :after", force_color: :red
      end
    end

    def add_section(section, opts={})
      if opts[:index]
        self.form.addFormSection(section, atIndex: opts[:index])
      elsif opts[:after]
        self.form.addFormSection(section, afterSection: opts[:after])
      else
        self.form.addFormSection(section)
      end
    end

    def remove_section!(section_or_index)
      if section_or_index.is_a?(XLFormSectionDescriptor)
        self.form.removeFormSection(section_or_index)
      else
        self.form.removeFormSectionAtIndex(section_or_index)
      end
    end

    def remove_cell!(cell)
      if cell.is_a?(Symbol)
        self.form.removeFormRowWithTag(cell.to_s)
      elsif cell.is_a?(String)
        self.form.removeFormRowWithTag(cell)
      else
        self.form.removeFormRow(cell)
      end
    end

    def enabled=(value)
      self.form.disabled = !value
    end

    def enabled?
      !self.form.isDisabled
    end

    # dismiss keyboard
    def dismiss_keyboard
      self.view.endEditing true
    end

    protected
    def on_cancel(_)
      form_options = self.class.get_form_options
      if form_options[:on_cancel]
        on_cancel = form_options[:on_cancel]
        if on_cancel.is_a? Hash
          on_cancel = on_cancel[:action]
        end
        try on_cancel
      end
    end

    def on_save(_)
      unless valid?
        display_errors
        return
      end

      form_options = self.class.get_form_options
      if form_options[:on_save]
        on_save = form_options[:on_save]
        if on_save.is_a? Hash
          on_save = on_save[:action]
        end
        try on_save, values
      end
    end

    ## XLFormDescriptorDelegate
    def formSectionHasBeenAdded(section, atIndex: index)
      super
      action = @form_builder.get_callback(section, :on_add)
      return if action.nil?
      trigger_action(action, row, index_path)
    end

    def formSectionHasBeenRemoved(section, atIndex: index)
      super
      action = @form_builder.get_callback(section, :on_remove)
      return if action.nil?
      trigger_action(action, section, index)
    end

    def formRowHasBeenAdded(row, atIndexPath: index_path)
      super
      action = @form_builder.get_callback(row, :on_add)
      return if action.nil?
      trigger_action(action, row, index_path)
    end

    def formRowHasBeenRemoved(row, atIndexPath: index_path)
      super
      action = @form_builder.get_callback(row, :on_remove)
      return if action.nil?
      trigger_action(action, row, index_path)
    end

    def formRowDescriptorValueHasChanged(row, oldValue: old_value, newValue: new_value)
      super

      callback = @form_builder.get_callback(row, :on_change)
      if callback
        if old_value.is_a? XLFormOptionsObject
          old_value = old_value.formValue
        end
        if new_value.is_a? XLFormOptionsObject
          new_value = new_value.formValue
        end
        callback.call(old_value, new_value)
      end
    end

    def formRowFormMultivaluedFormSection(section)
      if section.multivaluedRowTemplate
        cell_data = section.multivaluedRowTemplate.cell_data
      else
        cell_data = section.section_data[:cells].first
      end

      @form_builder.create_cell(cell_data)
    end

    # override XLFormViewController
    def tableView(table_view, heightForRowAtIndexPath: index_path)
      row = cell_at_path(index_path)
      cell = row.cellForFormController(self)
      cell_class = cell.class
      if cell_class.respond_to?(:formDescriptorCellHeightForRowDescriptor)
        return cell_class.formDescriptorCellHeightForRowDescriptor(row)
      elsif row.respond_to?(:cell_data) && row.cell_data && row.cell_data[:height]
        return row.cell_data[:height]
      end
      self.tableView.rowHeight
    end

    private
    def trigger_action(action, section_or_row, index_path)
      case arity = action.arity
        when 0 then
          action.call # Just call the proc or the method
        when 2 then
          action.call(section_or_row, index_path) # Send arguments and index path
        else
          mp("Action should not have optional parameters: #{action.to_s}", force_color: :yellow) if arity < 0
          action.call(section_or_row)
      end
    end

    def clean_value(value)
      if value.is_a? XLFormOptionsObject
        value = value.formValue
      elsif value.is_a? Array
        value = value.map { |v| clean_value(v) }
      end

      value
    end
  end
end
