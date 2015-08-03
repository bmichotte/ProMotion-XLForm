class TestFormScreen < PM::XLFormScreen

  title "PM::XLFormScreen"

  form_options required:  :asterisks,
               on_save:   :'save_form:',
               on_cancel: :cancel_form

  def form_data
    [
      {
        title:  'Account information',
        footer: 'Some help text',
        cells:  [
          {
            title:       'Email',
            name:        :email,
            type:        :email,
            placeholder: 'Enter your email',
            required:    true,
            validators: {
              email: true
            }
          },
          {
            title:       'Url',
            name:        :url,
            type:        :url,
            placeholder: 'Enter an url',
            required:    true,
            validators: {
              url: true
            }
          },
          {
            title: 'Only letters',
            name:  :letters,
            type:  :text,
            validators: {
              regex: { regex: /^[a-zA-Z]+$/, message: 'Invalid name' }
            }
          },
          {
            title: 'One',
            name:  :only_one,
            type:  :text,
            validators: {
              custom: NumberValidator.new
            }
          },
          {
            title: 'Yes ?',
            name:  'check',
            type:  :switch
          },
          {
            title:   'Options',
            name:    'options',
            type:    :selector_push,
            options: {
              "value_1" => "Value 1",
              "value_2" => "Value 2",
              "value_3" => "Value 3",
              "value_4" => "Value 4",
            },
            value:   "value_1"
          }
        ]
      },
      {
        cells: [
          {
            title:      'A slider',
            name:       :slider,
            type:       :slider,
            properties: {
              max:  100,
              min:  2,
              step: 4
            }
          },
          {
            title: 'A date',
            name:  :date,
            type:  :date_inline
          },
          {
            title:      'Another date',
            name:       :other_date,
            type:       :date_inline,
            properties: {
              min: NSDate.new
            }
          }
        ]
      },
      {
        name:    'images',
        cells:   [
          {
            title: 'An image',
            name:  :picture,
            type:  :image
          }
        ]
      },
      {
        title:   'Multi-value',
        name:    'multi',
        options: [:insert, :delete, :reorder],
        cells:   [
          {
            title: 'Some text',
            name:  :some_text,
            type:  :text
          }
        ]
      },
      {
        title: 'Subcells',
        name:  :sub_cells,
        options: [:insert, :delete, :reorder],
        cells: [
          {
            title: 'Subcell',
            name: :sub_cell,
            cells: [
              {
                title: 'Some text',
                name:  :some_text,
                type:  :text
              },
              {
                title: 'Other text',
                name:  :some_other_text,
                type:  :text
              }
            ]
          }
        ]
      },
      {
        title: 'Subcells with custom transformer',
        name:  :sub_cells,
        cells: [
          {
            title: 'Subcell',
            name: :sub_cell,
            value_transformer: TestValueTransformer,
            cells: [
              {
                title: 'First text',
                name:  :first_text,
                type:  :text
              },
              {
                title: 'Second text',
                name:  :second_text,
                type:  :text
              }
            ]
          }
        ]
      },
      {
        title: 'Hide and seek',
        cells: [
          {
            title: 'Switch me',
            type: :switch,
            name: :hide_and_seek,
            value: true
          },
          {
            title: 'Switch is off',
            name: :show_me,
            type: :text,
            visible: { name: :hide_and_seek, is: :equal, value: false },
            value: 'hi !'
          },
          {
            title: 'hello ?',
            name: :hide_me,
            type: :info,
            visible: ':show_me not contains "hello"'
          }
        ]
      }
    ]
  end

  def save_form(values)
    mp on_save: values
  end

  def cancel_form
    mp 'cancel_form has been called'
  end

end

class TestValueTransformer < ProMotion::ValueTransformer

  def transformedValue(value)
    return nil if value.nil?

    str = []
    str << value['first_text'] if value['first_text']
    str << value['second_text'] if value['second_text']

    str.join(',')
  end
end

class NumberValidator < ProMotion::Validator
  def initialize
    @message = "Only 1 !!!"
  end

  def valid?(row)
    return nil if row.nil? or row.value.nil?
    row.value == "1"
  end
end
