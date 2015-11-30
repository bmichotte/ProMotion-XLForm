class DynamicFormScreen < PM::XLFormScreen
  def form_data
    settings.map do |category|
      {
        title: category[:category].upcase,
        cells: category[:settings].map do |setting|
          {
            title: setting[:name],
            type: :text,
            name: setting[:key]
          }
        end
      }
    end + [{
      cells: [{
        type: :button,
        title: 'Submit',
        name: :submit,
        on_click: -> {
          mp values
        }
        }]
      }]
  end

  def settings
    [
      {
        category: 'Category 1',
        settings: [
          { name: 'Setting 1', key: :setting_1 },
          { name: 'Setting 2', key: :setting_2 },
          { name: 'Setting 3', key: :setting_3 },
        ]
      },
      {
        category: 'Category 2',
        settings: [
          { name: 'Setting 4', key: :setting_4 },
          { name: 'Setting 5', key: :setting_5 },
          { name: 'Setting 6', key: :setting_6 },
        ]
      }
    ]
  end
end
