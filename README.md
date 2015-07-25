# ProMotion-XLForm

ProMotion-XLForm provides a PM::XLFormScreen for [ProMotion](https://github.com/clearsightstudio/ProMotion) powered by the CocoaPod [XLForm](https://github.com/xmartlabs/XLForm).

## Warning
This gem is currently in very early-stage. Use it at your own risk :)

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

`PM::XLFormScreen` include `PM::ScreenModule` so you'll have all ProMotion methods available.

To create a form, create a new `PM::XLFormScreen` and implement `form_data`.

```ruby
class TestFormScreen < PM::XLFormScreen
  def form_data
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
          title: 'Sex',
          name: :sex,
          type: :selector_push,
          options: {
            male: 'Male',
            female: 'Female',
            other: 'Other'
          }
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
* :image

### Class options

```ruby
class TestFormScreen < PM::XLFormScreen

  form_options required:  :asterisks, # add an asterisk to required fields
               on_save:   :'save_form:', # will be called when you touch save
               on_cancel: :cancel_form # will be called when you touch cancel

   def save_form(values)
     mp values
   end

   def cancel_form
   end
end
```

### Getting values

You can get the values of your form with `values`. You can also get validation errors with `validation_errors` and check if the form is valid with `valid?`

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
  on_change: lambda do |old_value, new_value|
    puts "Changed from #{old_value} to #{new_value}"
  end
}
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



## Todo
- Validations
- Tests
- A lot of other things :)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Make some specs pass
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## License

Released under the [MIT license](LICENSE).
