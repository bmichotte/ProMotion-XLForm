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

  it "contains 6 sections" do
    views(UITableView).first.numberOfSections.should == 6
  end

  it "contains 1 section with 6 fields" do
    tableview = views(UITableView).first
    @form_screen.tableView(tableview, numberOfRowsInSection: 0).should == 6
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

end
