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
end

class XLFormSectionDescriptor
  attr_accessor :section_data, :options

  def self.section(section_data)
    title = section_data[:title]

    options = section_data.fetch(:options, :none)
    options = parse_section_options(options)
    insert_mode = section_insert_mode(section_data[:insert_mode])

    section = XLFormSectionDescriptor.formSectionWithTitle(title, sectionOptions: options, sectionInsertMode: insert_mode)
    section.section_data = section_data
    section.options = options
    section
  end

  def options=(value)
    @options = self.class.parse_section_options(value)
  end

  def options
    @options
  end

  def sectionOptions
    options
  end

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
