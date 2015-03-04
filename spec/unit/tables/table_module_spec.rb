describe "PM::Table module" do

  def cell_factory(args={})
    { title: "Basic", action: :basic_cell_tapped, arguments: { id: 1 } }.merge!(args)
  end

  def custom_cell
    @image ||= UIImage.imageNamed("list")
    @pattern_image_color ||= UIColor.colorWithPatternImage(@image)
    cell_factory({
      title: "Crazy Full Featured Cell",
      subtitle: "This is way too huge..see note",
      arguments: { data: [ "lots", "of", "data" ] },
      action: :tapped_cell_1,
      long_press_action: :long_press_cell_1,
      height: 50, # manually changes the cell's height
      cell_style: UITableViewCellStyleSubtitle,
      cell_identifier: "Cell",
      cell_class: PM::TableViewCell,
      selection_style: :gray,
      accessory: {
        view: :switch, # currently only :switch is supported
        type: UITableViewCellAccessoryCheckmark,
        value: true # whether it's "checked" or not
      },
      image: { image: @image, radius: 15 },
      remote_image: {  # remote image, requires JMImageCache CocoaPod
        url: "http://placekitten.com/200/300",
        placeholder: "some-local-image",
        size: 50,
        radius: 15
      },
      properties: {
        content_view: {
          background_color: @pattern_image_color,
        },
        layer: {
          masks_to_bounds: true,
        },
      }
    })
  end

  def default_cell_height
    return UITableViewAutomaticDimension if TestHelper.ios8
    return 97.0 if TestHelper.ios7 # Normally 44, but 97 because of `row_height` designation
  end

  def default_header_height
    # Thanks, Apple.
    return -1.0 if TestHelper.ios8
    return 23.0 if TestHelper.ios7
    return 22.0 if TestHelper.ios6
  end

  before do
    @subject = TestTableScreen.new
    @subject.mock! :table_data do
      [{
        title: "Table cell group 1", cells: [ ]
      },{
        title: "Table cell group 2", cells: [ cell_factory ]
      },{
        title: "Table cell group 3", cells: [ cell_factory(title: "3-1"), cell_factory({title: "3-2", properties: { background_color: UIColor.blueColor } }) ]
      },{
        title: "Table cell group 4", cells: [ custom_cell, cell_factory(title: "4-2"), cell_factory(title: "4-3"), cell_factory(title: "4-4") ]
      },{
        title: "Custom section title 1", title_view: CustomTitleView, cells: [ ]
      },{
        title: "Custom section title 2", title_view: CustomTitleView.new, title_view_height: 50, cells: [ ]
      },{
        title: "Action WIth Index Path Group", cells: [ cell_factory(title: "IndexPath Group 1", action: :tests_index_path) ]
      }]
    end

    @subject.on_load

    @ip = NSIndexPath.indexPathForRow(1, inSection: 2) # Cell 3-2
    @custom_ip = NSIndexPath.indexPathForRow(0, inSection: 3) # Cell "Crazy Full Featured Cell"

    @subject.update_table_data
  end

  it "should have the right number of sections" do
    @subject.numberOfSectionsInTableView(@subject.table_view).should == 7
  end

  it "should set the section titles" do
    @subject.tableView(@subject.table_view, titleForHeaderInSection:0).should == "Table cell group 1"
    @subject.tableView(@subject.table_view, titleForHeaderInSection:1).should == "Table cell group 2"
    @subject.tableView(@subject.table_view, titleForHeaderInSection:2).should == "Table cell group 3"
    @subject.tableView(@subject.table_view, titleForHeaderInSection:3).should == "Table cell group 4"
    @subject.tableView(@subject.table_view, titleForHeaderInSection:4).should == "Custom section title 1"
    @subject.tableView(@subject.table_view, titleForHeaderInSection:5).should == "Custom section title 2"
  end

  it "should create the right number of cells" do
    @subject.tableView(@subject.table_view, numberOfRowsInSection:0).should == 0
    @subject.tableView(@subject.table_view, numberOfRowsInSection:1).should == 1
    @subject.tableView(@subject.table_view, numberOfRowsInSection:2).should == 2
    @subject.tableView(@subject.table_view, numberOfRowsInSection:3).should == 4
    @subject.tableView(@subject.table_view, numberOfRowsInSection:4).should == 0
    @subject.tableView(@subject.table_view, numberOfRowsInSection:5).should == 0
  end

  it "should create the jumplist" do
    @subject.mock! :table_data_index, do
      Array("A".."Z")
    end

    @subject.sectionIndexTitlesForTableView(@subject.table_view).should == Array("A".."Z")
  end

  it "should return the proper cell" do
    cell = @subject.tableView(@subject.table_view, cellForRowAtIndexPath: @ip)
    cell.should.be.kind_of(UITableViewCell)
    cell.textLabel.text.should == "3-2"
  end

  it "should return the table's cell height if none is given" do
    @subject.tableView(@subject.table_view, heightForRowAtIndexPath:@ip).should == default_cell_height
  end

  it "should allow setting a custom cell height" do
    @subject.tableView(@subject.table_view, heightForRowAtIndexPath:@custom_ip).should.be > 0.0
    @subject.tableView(@subject.table_view, heightForRowAtIndexPath:@custom_ip).should == custom_cell[:height].to_f
  end

  it "should trigger the right action on select and pass in the right arguments" do
    @subject.mock! :tapped_cell_1 do |args|
      args[:data].should == [ "lots", "of", "data" ]
    end

    @subject.tableView(@subject.table_view, didSelectRowAtIndexPath:@custom_ip)
  end

  it "should return an NSIndexPath when the action has two parameters" do
    ip = NSIndexPath.indexPathForRow(0, inSection: 6)

    @subject.tableView(@subject.table_view, didSelectRowAtIndexPath:ip)

    tapped_ip = @subject.got_index_path
    tapped_ip.section.should == 6
    tapped_ip.row.should == 0
  end

  # TODO - make this test work when MacBacon supports long press gestures
  # https://github.com/HipByte/RubyMotion/issues/160
  #
  # it "should trigger the right action on a long_press" do
  #   @subject.mock! :long_press_cell_1 do |args|
  #     args[:data].should == [ "lots", "of", "data" ]
  #   end
  #   tap(@subject.table_view, :at => location, :times => number_of_taps, :touches => number_of_fingers)
  # end

  it "should set a custom cell background image" do
    @image.should.not.be.nil
    ip = NSIndexPath.indexPathForRow(0, inSection: 3) # Cell 4-1
    cell = @subject.tableView(@subject.table_view, cellForRowAtIndexPath: ip)
    cell.should.be.kind_of(UITableViewCell)
    cell.layer.masksToBounds.should == true
    cell.contentView.backgroundColor.should.be.kind_of(UIColor)
    cell.contentView.backgroundColor.should == @pattern_image_color
  end

  it "should set a custom cell background color" do
    cell = @subject.tableView(@subject.table_view, cellForRowAtIndexPath: @ip)
    cell.should.be.kind_of(UITableViewCell)
    cell.backgroundColor.should.be.kind_of(UIColor)
    cell.backgroundColor.should == UIColor.blueColor
  end

  it "should have a header view" do
    @subject.tableView.tableHeaderView.class.should == UIImageView
  end

  it "should have a footer view" do
    @subject.tableView.tableFooterView.class.should == UIView
  end

  describe("section with custom title_view") do

    it "should use the correct class for section view" do
      cell = @subject.tableView(@subject.table_view, viewForHeaderInSection: 4)
      cell.should.be.kind_of(CustomTitleView)
    end

    it "should use the default section height if none is specified" do
      @subject.tableView(@subject.table_view, heightForHeaderInSection:4).should == default_header_height
    end

    it "should use the set title_view_height if one is specified" do
      @subject.tableView(@subject.table_view, heightForHeaderInSection:5).should == 50.0
    end

    it "should use the instantiated section view if one is specified" do
      cell = @subject.tableView(@subject.table_view, viewForHeaderInSection: 5)
      cell.should.be.kind_of(CustomTitleView)
    end
  end

  describe "header view modifications" do

    it "should call will_display_header" do
      header = @subject.tableView(@subject.table_view, viewForHeaderInSection: 4)
      @subject.tableView(@subject.table_view, willDisplayHeaderView:header, forSection:1)

      @subject.got_will_display_header.tap do |h|
        h.nil?.should == false
        h[:section].should == 1
        h[:view].should == header
      end
    end

  end

end
