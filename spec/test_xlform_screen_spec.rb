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

  it "contains 1 section with 4 fields" do
    tableview = views(UITableView).first
    @form_screen.tableView(tableview, numberOfRowsInSection: 0).should == 4
  end

  it "should not be valid" do
    @form_screen.valid?.should == false
  end

  it "should be valid" do
    cell = @form_screen.cell_with_tag(:email)
    cell.value = 'email@domain.com'
    @form_screen.reload(cell)
    @form_screen.valid?.should == true
  end

end