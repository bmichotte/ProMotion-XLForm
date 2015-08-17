describe 'ProMotion::XLFormScreen' do

  tests TestFormScreen

  def form_screen
    @form_screen ||= TestFormScreen.new(nav_bar: true)
  end

  before { form_screen.update_form_data }
  after { @form_screen = nil }

  it "contains a 'Account information' title" do
    view("ACCOUNT INFORMATION").should.not.be.nil
  end

  it "contains a section footer" do
    view("Some help text").should.not.be.nil
  end

  it "contains 8 sections" do
    views(UITableView).first.numberOfSections.should == 8
  end

  it "contains 1 section with 7 fields" do
    tableview = views(UITableView).first
    @form_screen.tableView(tableview, numberOfRowsInSection: 0).should == 7
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

  it "should get a color" do
    color_cell = @form_screen.cell_with_tag(:color)
    color_cell.value.should == UIColor.blueColor

    color_cell.value = UIColor.redColor
    @form_screen.reload(color_cell)
    color_cell.value.should == UIColor.redColor
  end

  it "should be customizable" do
    cell = @form_screen.cell_with_tag(:options)
    cell.cellConfig["textLabel.font"].should == UIFont.fontWithName('Helvetica Neue', size: 15.0)
    cell.cellConfig["textLabel.textColor"].should == UIColor.greenColor
    cell.cellConfig["detailTextLabel.font"].should == UIFont.fontWithName('Helvetica Neue', size: 12.0)
    cell.cellConfig["detailTextLabel.textColor"].should == UIColor.blueColor
    cell.cellConfig["backgroundColor"].should == UIColor.grayColor

    label = view('Options')
    label.font.should == UIFont.fontWithName('Helvetica Neue', size: 15.0)
    label.textColor.should == UIColor.greenColor
    label.superview.superview.backgroundColor.should == UIColor.grayColor

    cell = @form_screen.cell_with_tag(:slider)
    cell.cellConfig["slider.tintColor"].should == UIColor.redColor
    views(UISlider).first.tintColor.should == UIColor.redColor
  end

end
