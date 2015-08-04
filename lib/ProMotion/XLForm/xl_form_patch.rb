# Monkey patch
class XLFormAction

  attr_accessor :cells
  attr_accessor :required

  alias :old_copyWithZone :copyWithZone

  def copyWithZone(zone)
    action_copy = old_copyWithZone(zone)

    action_copy.cells    = self.cells.copy
    action_copy.required = self.required
    action_copy
  end
end

class XLFormRowDescriptor

  def options=(options)
    self.selectorOptions = parse_options(options)
  end

  def parse_options(options)
   return nil if options.nil? or options.empty?

   options.map do |key, text|
     val = key
     if val.is_a? Symbol
       val = val.to_s
     end
     XLFormOptionsObject.formOptionsObjectWithValue(val, displayText: text)
   end
 end

end
