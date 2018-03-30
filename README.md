# ProMotion-XLForm

ProMotion-XLForm provides a PM::XLFormScreen for [ProMotion](https://github.com/clearsightstudio/ProMotion) powered by the CocoaPod [XLForm](https://github.com/xmartlabs/XLForm).

[![Build Status](https://travis-ci.org/bmichotte/ProMotion-XLForm.svg?branch=master)](https://travis-ci.org/bmichotte/ProMotion-XLForm) [![Gem Version](https://badge.fury.io/rb/ProMotion-XLForm.svg)](http://badge.fury.io/rb/ProMotion-XLForm)

## Installation

```ruby
gem 'ProMotion-XLForm'
```

Then:

```sh-session
$ bundle
$ rake pod:install
```

## Usage

`PM::XLFormScreen` includes `PM::ScreenModule` so you'll have all the same ProMotion screen methods available.

To create a form screen, subclass `PM::XLFormScreen` and define a `form_data` method.

```ruby
class TestFormScreen < PM::XLFormScreen
  def form_data
    genders = [
      { id: :male, name: 'Male' },
      { id: :female, name: 'Female' },
      { id: :other,  name: 'Other' },
    ]

    [
      {
        title:  'Account information',
        cells: [
          {
            title:       'Email',
            name:        :email,
            type:        :email,
            placeholder: 'Enter your email',
            required:    true
          },
          {
            title: 'Name',
            name:  :name,
            type:  :text,
            value: 'Default value'
          },
          {
            title: 'Gender',
            name: :gender,
            type: :selector_push,
            options: Hash[genders.map do |gender|
              [gender[:id], gender[:name]]
            end]
          }
        ]
      }
    ]
  end
end
```

## Available types
* :text
* :name
* :url
* :email
* :password
* :number
* :phone
* :twitter
* :account
* :integer
* :decimal
* :textview
* :zip_code
* :selector_push
* :selector_popover
* :selector_action_sheet
* :selector_alert_view
* :selector_picker_view
* :selector_picker_view_inline
* :multiple_selector
* :multiple_selector_popover
* :selector_left_right
* :selector_segmented_control
* :date_inline
* :datetime_inline
* :time_inline
* :countdown_timer_inline
* :date
* :datetime
* :time
* :countdown_timer
* :datepicker
* :picker
* :slider
* :check
* :switch
* :button
* :info
* :step_counter
* :image (ProMotion-XLForm specific)
* :color (ProMotion-XLForm specific using [RSColorPicker](https://github.com/RSully/RSColorPicker))

### Form Options

The `form_options` class method allows you to customize the default behavior of the form.

```ruby
class TestFormScreen < PM::XLFormScreen

  form_options on_save:   :save_form,   # adds a "Save" button in the nav bar and calls this method
               on_cancel: :cancel_form, # adds a "Cancel" button in the nav bar and calls this method
               required:  :asterisks,   # display an asterisk next to required fields
               auto_focus: true         # the form will focus on the first focusable field

  def save_form(values)
    dismiss_keyboard
    mp values
  end

  def cancel_form
  end
end
```

#### Save & Cancel Buttons

By default, no buttons are displayed in the nav bar unless you configure the `on_save` or `on_cancel` options.

You can either pass the name of the method that you want to call when that button is tapped, or you can pass a hash of options, allowing you to configure the title of the button.

**Hash Options:**
- `title` or `system_item` - The button text or system item that will be displayed.
- `action` - The method that will be called when the button is tapped.

```ruby
form_options on_cancel: { system_item: :trash, action: :cancel_form },
             on_save: { title: 'Continue', action: :continue }
```

`system_item` can be any `UIBarButtonSystemItem` constant or one of the following symbols:
```ruby
:done, :cancel, :edit, :save, :add, :flexible_space, :fixed_space, :compose,
:reply, :action, :organize, :bookmarks, :search, :refresh, :stop, :camera,
:trash, :play, :pause, :rewind, :fast_forward, :undo, :redo
```

If you would like to display a button as part of your form, you could do something like this:

```ruby
form_options on_save: :my_save_method

def form_data
  [
    {
      title: 'Save',
      name: :save,
      type: :button,
      on_click: -> (cell) {
        on_save(nil)
      }
    }
  ]
end

def my_save_method(values)
  mp values
end

```

### Getting values

You can get the values of your form with `values`. You can call `dismiss_keyboard` before before calling `values` to ensure you capture the input from the currently focused form element.
You can also get validation errors with `validation_errors` and check if the form is valid with `valid?`.
You can also get a specific value with `value_for_cell(:my_cell)`.

### Events

`on_change`, `on_add` and `on_remove` are available for cells, `on_add` and `on_remove` are available for sections.

```ruby
{
  title: 'Sex',
  name: :sex,
  type: :selector_push,
  options: {
    male: 'Male',
    female: 'Female',
    other: 'Other'
  },
  # An optional row paramater may be passed |old_value, new_value|
  on_change: lambda do |old_value, new_value|
    puts "Changed from #{old_value} to #{new_value}"
  end
}
# An optional row paramater may be passed to on_change:
#  on_change: lambda do |old_value, new_value, row|
#    puts "Changed from #{old_value} to #{new_value}"
#    row.setTitle(new_value)
#    self.reloadFormRow(row) if old_value != new_value
#  end
```

### Multivalued Sections (Insert, Delete, Reorder rows)

```ruby
{
  title:  'Multiple value',
  name:   :multi_values,
  options: [:insert, :delete, :reorder],
  cells: [
    {
      title: 'Add a new tag',
      name:  :tag,
      type:  :text
    }
  ]
}
```

### Custom Selectors

You can create a custom _subform_ with a few options

```ruby
{
  title:  'Custom section',
  cells: [
    {
      title: 'Custom',
      name:  :custom,
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
}
```

By default, the cell will print a `Hash.inspect` of your _subcells_. You can change this by creating a valueTransformer and set `value_transformer:`.

```ruby
{
  title: 'Custom',
  name:  :custom,
  value_transformer: MyValueTransformer
  cells: []
}

class MyValueTransformer < PM::ValueTransformer
  def transformedValue(value)
    return nil if value.nil?

    str = []
    str << value['some_text'] if value['some_text']
    str << value['some_other_text'] if value['some_other_text']

    str.join(',')
  end
end
```

For a more advanced custom selector, you can set `view_controller_class:`. See [XLForm documentation](https://github.com/xmartlabs/XLForm/#custom-selectors---selector-row-with-a-custom-selector-view-controller) for more informations.

### Cell

You can use your own cell by providing `cell_class`

```ruby
{
  title: 'MyCustomCell',
  name: :custom_cell,
  cell_class: MyCustomCell
}

class MyCustomCell < PM::XLFormCell
  def initWithStyle(style, reuseIdentifier: reuse_identifier)
    super.tap do
      @label = UILabel.new
      self.contentView.addSubview(@label)
    end
  end

  def update
    super

    @label.text = value
    @label.sizeToFit
  end
end
```

In your cell, you can set the value with `self.value=` and get the value with `self.value`

### Validators

You can add validators to cells.

```ruby
{
  title:       'Email',
  name:        :email,
  type:        :email,
  required:    true,
  validators: {
    email: true
  }
}
```

`:email` and `:url` are available out of the box, as well as `:regex`. You will have to provide a valid regex and a message.

```ruby
{
  title:       'Only letters',
  name:        :letters,
  type:        :text,
  required:    true,
  validators: {
    regex: { regex: /^[a-zA-Z]+$/, message: "Only letters please !" }
  }
}
```

Finally, you can provide a PM::Validator with a `valid?(cell)` method.

### Make a row or section invisible depending on other rows values
[You can show/hide cells](https://github.com/xmartlabs/XLForm#make-a-row-or-section-invisible-depending-on-other-rows-values) depending on a cell value with a predicate

```ruby
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
      title: 'Appear when switch is on',
      name: :show_me,
      type: :info,
      hidden: {
        # the cell name wich will "trigger" the visibility
        name: :hide_and_seek,

        # the operand. Valid operands are :equal, :not_equal, :contains, :not_contains
        is: :equal,

        # the value which trigger the visibility
        value: true }
    },
    {
      title: 'Appear when switch is off',
      name: :hide_me,
      type: :info,

      # you can also write it this way
      hidden: ':hide_and_seek == false'
      # also valid ':some_text contains "a text"'
      #            ':some_text not contains "a text"'
    }
  ]
}
```

### Buttons and click
You can add `:on_click` on `:button` which accepts 0 or 1 argument (the cell).
```ruby
{
  title: 'Click me',
  name: :click_me,
  type: :button,
  on_click: -> (cell) {
    mp "You clicked me"
  }
}
```


### Appearance
You can change the appearance of the cell using the `appearance` hash

```ruby
{
  title:   'Options',
  name:    'options',
  type:    :selector_push,
  appearance: {
    font: UIFont.fontWithName('Helvetica Neue', size: 15.0),
    detail_font: UIFont.fontWithName('Helvetica Neue', size: 12.0),
    color: UIColor.greenColor,
    detail_color: UIColor.blueColor,
    background_color: UIColor.grayColor
  },
  options: {
    "value_1" => "Value 1",
    "value_2" => "Value 2",
    "value_3" => "Value 3",
    "value_4" => "Value 4",
  }
},
{
  title: 'Alignment',
  name: :align,
  type: :text,
  appearance: {
    alignment: :right # or NSTextAlignmentRight
  }
}
```

You can also pass any key-value to configure your cell. Take a look at [this](https://github.com/xmartlabs/XLForm#additional-configuration-of-rows) for more information

```ruby
{
  appearance: {
    "slider.tintColor" => UIColor.grayColor
  }
}
```

### Keyboard
For the text based cells (like `:text`, `:password`, `:number`, `:integer`, `:decimal`), you can specify a `keyboard_type`. The following keyboard types are available :
- :default
- :ascii
- :numbers_punctuation
- :url
- :number_pad
- :phone_pad
- :name_phone_pad
- :email
- :decimal_pad
- :twitter
- :web_search
- :alphabet

### RMQ / RedPotion
If you use [RMQ](https://github.com/infinitered/rmq) or [RedPotion](https://github.com/infinitered/redpotion), you can style the screen with
```ruby
def form_view(st)

end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Make some specs pass
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## License

Released under the [MIT license](LICENSE).
