module ProMotion
  module XLFormHelper

    def configure_hidden(cell_or_section, predicate)
      tag = operand = value = nil
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
        if match && match.length == 4
          # todo better than ignore ?
          tag = match[1]
          operand = match[2]
          value = match[3]
          if value =~ /"(.*)"/
            value = value[1, value.length - 2]
          end
        end
      end

      if tag && operand
        if tag.is_a?(Symbol)
          tag = tag.to_s
        elsif tag.start_with?(':')
          tag[0] = ''
        end
        tag += ".value.valueData" if predicate.is_a?(Hash) && predicate[:options]

        value = case value
                  when nil
                    'nil'
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
          cell_or_section.hidden = "$#{tag} contains[c] #{value}"
        elsif operand == 'not contains'
          cell_or_section.hidden = "not($#{tag} contains[c] #{value})"
        else
          cell_or_section.hidden = "$#{tag} #{operand} #{value}"
        end
      else
        mp predicate: predicate.inspect, message: "predicate can not be parsed", force_color: :red
      end
    end
  end
end
