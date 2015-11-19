# Monkey patch
class XLFormAction

  attr_accessor :cells
  attr_accessor :required

  alias :old_copyWithZone :copyWithZone

  def copyWithZone(zone)
    action_copy = old_copyWithZone(zone)

    action_copy.cells = self.cells.copy
    action_copy.required = self.required
    action_copy
  end
end

class XLFormRowDescriptor

  attr_accessor :cell_data

  alias :old_copyWithZone :copyWithZone

  def copyWithZone(zone)
    row_copy = old_copyWithZone(zone)
    row_copy.cell_data = cell_data
    row_copy
  end

  def enabled=(value)
    self.disabled = !value
  end

  def options=(options)
    self.selectorOptions = parse_options(options)
  end

  def parse_options(options)
    return nil if options.nil? || options.empty?

    options.map do |key, text|
      val = key
      if val.is_a? Symbol
        val = val.to_s
      end
      XLFormOptionsObject.formOptionsObjectWithValue(val, displayText: text)
    end
  end

  def cellForFormController(form_controller)
    unless self.cell
      cell_class = self.cellClass ? self.cellClass : XLFormViewController.cellClassesForRowDescriptorTypes[self.rowType]
      if cell_class.is_a?(String)
        bundle = NSBundle.bundleForClass(cell_class.to_s)
        if bundle.pathForResource(cell_class, ofType: "nib")
          self.cell = bundle.loadNibNamed(cell_class, owner: nil, options: nil).first
        end
      else
        self.cell = cell_class.alloc.initWithStyle(self.cellStyle, reuseIdentifier: nil)
      end

      if self.cell && self.cell.respond_to?(:setup)
        self.cell.setup(cell_data, form_controller)
      end
      self.configureCellAtCreationTime
    end

    self.cell
  end
end

class XLFormSectionDescriptor
  attr_accessor :section_data

  def self.section(section_data)
    title = section_data[:title]

    options = section_data.fetch(:options, :none)
    options = parse_section_options(options)
    insert_mode = section_insert_mode(section_data[:insert_mode])

    section = XLFormSectionDescriptor.formSectionWithTitle(title, sectionOptions: options, sectionInsertMode: insert_mode)
    section.section_data = section_data

    section
  end

  def options=(value)
    @section_options = self.class.parse_section_options(value)
  end

  # Since `sectionOptions` is a property on the Objective-C class and not a
  # Ruby method we can't use `super` to fallback when overriding the method.
  # To achieve the same thing we create an alias and use that instead.
  alias :originalSectionOptions :sectionOptions

  # This property/method is used in the Objective-C initializer and is called
  # before we ever have a chance to set @section_options so we need to be able
  # to fallback to the original.
  def sectionOptions
    @section_options || originalSectionOptions
  end
  alias_method :options, :sectionOptions

  def self.parse_section_options(options)
    return section_options(:none) if options.nil?

    opts = section_options(:none)
    unless options.is_a?(Array)
      options = [options]
    end
    options.each do |opt|
      opts |= section_options(opt)
    end

    opts
  end

  def self.section_insert_mode(symbol)
    {
      last_row: XLFormSectionInsertModeLastRow,
      button: XLFormSectionInsertModeButton
    }[symbol] || symbol || XLFormSectionInsertModeLastRow
  end

  def self.section_options(symbol)
    {
      none: XLFormSectionOptionNone,
      insert: XLFormSectionOptionCanInsert,
      delete: XLFormSectionOptionCanDelete,
      reorder: XLFormSectionOptionCanReorder
    }[symbol] || symbol || XLFormSectionOptionNone
  end
end
