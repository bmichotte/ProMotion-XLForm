describe 'ProMotion::XLFormScreen' do

  tests TestFormScreen

  def form_screen
    @form_screen ||= TestFormScreen.new(nav_bar: true)
  end

  before { form_screen.update_form_data }
  after { @form_screen = nil }

  # it "contains a 'Account information' title" do
  #   view("ACCOUNT INFORMATION").should.not.be.nil
  # end

  it "contains a section footer" do
    view("Some help text").should.not.be.nil
  end

  it "contains 9 sections" do
    views(UITableView).first.numberOfSections.should == 9
  end

  it "contains 1 section with 9 fields" do
    tableview = views(UITableView).first
    @form_screen.tableView(tableview, numberOfRowsInSection: 0).should == 10
  end

  it "should not be valid" do
    @form_screen.valid?.should == false
  end

  it "should be valid" do
    cell = @form_screen.cell_with_tag(:email)
    cell.value = 'email@domain.com'
    @form_screen.reload(cell)

    cell = @form_screen.cell_with_tag(:url)
    cell.value = 'http://www.domain.com'
    @form_screen.reload(cell)

    @form_screen.valid?.should == true
  end

  it "only letters should be invalid" do
    cell = @form_screen.cell_with_tag(:email)
    cell.value = 'email@domain.com'
    @form_screen.reload(cell)

    cell = @form_screen.cell_with_tag(:url)
    cell.value = 'http://www.domain.com'
    @form_screen.reload(cell)

    cell = @form_screen.cell_with_tag(:letters)
    cell.value = '23fd4 342'
    @form_screen.reload(cell)

    @form_screen.valid?.should == false
  end

  it "only letters should be valid" do
    cell = @form_screen.cell_with_tag(:email)
    cell.value = 'email@domain.com'
    @form_screen.reload(cell)

    cell = @form_screen.cell_with_tag(:url)
    cell.value = 'http://www.domain.com'
    @form_screen.reload(cell)

    cell = @form_screen.cell_with_tag(:letters)
    cell.value = 'AzErtY'
    @form_screen.reload(cell)

    @form_screen.valid?.should == true
  end

  it "only one should be invalid" do
    cell = @form_screen.cell_with_tag(:email)
    cell.value = 'email@domain.com'
    @form_screen.reload(cell)

    cell = @form_screen.cell_with_tag(:url)
    cell.value = 'http://www.domain.com'
    @form_screen.reload(cell)

    cell = @form_screen.cell_with_tag(:only_one)
    cell.value = '23'
    @form_screen.reload(cell)

    @form_screen.valid?.should == false
  end

  it "only one should be valid" do
    cell = @form_screen.cell_with_tag(:email)
    cell.value = 'email@domain.com'
    @form_screen.reload(cell)

    cell = @form_screen.cell_with_tag(:url)
    cell.value = 'http://www.domain.com'
    @form_screen.reload(cell)

    cell = @form_screen.cell_with_tag(:only_one)
    cell.value = '1'
    @form_screen.reload(cell)

    @form_screen.valid?.should == true
  end

  it "should play hide and seek" do
    predicate = "$hide_and_seek == 1".formPredicate
    show_me = @form_screen.cell_with_tag(:show_me)
    show_me.hidden.should == predicate
    show_me.isHidden.should == true

    predicate = 'not($show_me contains[c] "hello")'.formPredicate
    hide_me = @form_screen.cell_with_tag(:hide_me)
    hide_me.hidden.should == predicate
    hide_me.isHidden.should == true

    switch = @form_screen.cell_with_tag(:hide_and_seek)
    switch.value = false
    @form_screen.reload(switch)

    show_me.value = 'hello'
    @form_screen.reload(show_me)

    show_me.isHidden.should == false
    hide_me.isHidden.should == false
  end

  it "should play hide and seek with a selector" do
    predicate = "$options.value.valueData == 'value_1'".formPredicate
    show_me_selector = @form_screen.cell_with_tag(:show_me_selector)
    show_me_selector.hidden.should == predicate
    show_me_selector.isHidden.should == true

    selector = @form_screen.cell_with_tag('options')
    selector.value = 'value_2'
    @form_screen.reload(selector)

    @form_screen.reload(show_me_selector)

    show_me_selector.isHidden.should == false
  end

  it "should get a color" do
    color_cell = @form_screen.cell_with_tag(:color)
    color_cell.value.should == UIColor.blueColor

    color_cell.value = UIColor.redColor
    @form_screen.reload(color_cell)
    color_cell.value.should == UIColor.redColor
  end

  it "should be customizable" do
    cell = @form_screen.cell_with_tag(:options)
    cell.cellConfig["textLabel.textColor"].should == UIColor.greenColor

    font = cell.cellConfig["textLabel.font"]
    font.fontDescriptor.fontAttributes['NSFontNameAttribute'].should == 'HelveticaNeue'
    font.fontDescriptor.fontAttributes['NSFontSizeAttribute'].should == 15

    font = cell.cellConfig["detailTextLabel.font"]
    font.fontDescriptor.fontAttributes['NSFontNameAttribute'].should == 'HelveticaNeue'
    font.fontDescriptor.fontAttributes['NSFontSizeAttribute'].should == 12

    cell.cellConfig["detailTextLabel.textColor"].should == UIColor.blueColor
    cell.cellConfig["backgroundColor"].should == UIColor.grayColor

    cell = @form_screen.cell_with_tag(:slider)
    cell.cellConfig["slider.tintColor"].should == UIColor.redColor
    views(UISlider).first.tintColor.should == UIColor.redColor

    cell = @form_screen.cell_with_tag(:align)
    cell.cellConfig["textField.textAlignment"].should == NSTextAlignmentRight
  end

  it "should allow a custom cell" do
    cell = @form_screen.cell_with_tag(:custom_cell)
    cell.cellForFormController(@form_screen).should.be.kind_of(MyCustomCell)
  end

  it "should have Hello as value" do
    value = @form_screen.value_for_cell(:custom_cell)
    value.should == 'Hello'
  end

  it "should allow custom images to be set on the cell" do
    tableview = views(UITableView).first
    cell = @form_screen.tableView(tableview, cellForRowAtIndexPath: NSIndexPath.indexPathForRow(6, inSection:0))
    cell.imageView.should.not.be.nil
  end

  it "should not allow a :selector_popover on iPhone" do
    cell = @form_screen.cell_with_tag(:ipad_options)
    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
      cell.rowType.should == "selectorPopover"
    else
      cell.rowType.should == "selectorPush"
    end
  end

end
