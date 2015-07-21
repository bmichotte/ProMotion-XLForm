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

  alias :old_copyWithZone :copyWithZone

  def copyWithZone(zone)
    row_descriptor_copy = old_copyWithZone(zone)

    row_descriptor_copy.valueTransformer = self.valueTransformer
    row_descriptor_copy
  end

end