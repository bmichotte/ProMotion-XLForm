class XLFormColorSelectorCell < XLFormBaseCell
  def configure
    super.tap do
      self.selectionStyle = UITableViewCellSelectionStyleNone
      @color_view = UIView.alloc.initWithFrame [[0, 0], [80, 30]]
      @color_view.contentMode = UIViewContentModeScaleAspectFit
      @color_view.layer.borderWidth = 1
      @color_view.layer.borderColor = UIColor.blackColor.CGColor
      @color_view.backgroundColor = UIColor.whiteColor
      tap = UITapGestureRecognizer.alloc.initWithTarget(self, action: 'on_color_tap:')
      self.addGestureRecognizer(tap)

      self.accessoryView = @color_view
    end
  end

  def on_color_tap(_)
    unless self.rowDescriptor.disabled
      self.formViewController.view.endEditing(true)

      size = if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
               [400, 440]
             else
               [320, 440]
             end
      color_chooser = PMXLColorChooser.alloc.initWithFrame [[0, 0], size]
      color_chooser.delegate = self
      color_chooser.color = self.rowDescriptor.value || UIColor.whiteColor

      if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
        controller = UIViewController.new
        controller.view = color_chooser
        @popover = UIPopoverController.alloc.initWithContentViewController controller
        @popover.popoverContentSize = color_chooser.frame.size
        f = self.contentView.convertRect(@color_view.frame, toView: self.formViewController.view)
        @popover.presentPopoverFromRect(f,
                                        inView: self.formViewController.view,
                                        permittedArrowDirections: UIPopoverArrowDirectionAny,
                                        animated: true)
      else
        controller = UIViewController.new
        controller.view = color_chooser

        navigation_controller = UINavigationController.alloc.initWithRootViewController(controller)
        navigation_controller.navigationBar.translucent = false
        right = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemDone,
                                                                  target: self,
                                                                  action: 'hide_picker:')
        controller.navigationItem.rightBarButtonItem = right
        if self.formViewController.presentedViewController
          self.formViewController.dismissViewControllerAnimated(true,
                                                                completion: -> {
                                                                  self.formViewController.presentViewController(navigation_controller,
                                                                                                                animated: true,
                                                                                                                completion: nil)
                                                                })
        else
          self.formViewController.presentViewController(navigation_controller,
                                                        animated: true,
                                                        completion: nil)
        end
      end
    end
  end

  def hide_picker(_)
    self.formViewController.dismissViewControllerAnimated(true, completion: nil)
  end

  def update
    super.tap do
      self.textLabel.text = (self.rowDescriptor.isRequired && self.rowDescriptor.title) ? "#{self.rowDescriptor.title}*" : self.rowDescriptor.title
      @color_view.frame = [[305.0, 7.0], [80.0, 30.0]]
      color = self.rowDescriptor.value
      unless color
        color = UIColor.whiteColor
      end
      @color_view.layer.borderColor = UIColor.blackColor.CGColor
      @color_view.backgroundColor = color
      self.textLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    end
  end

  def colorPickerDidChangeSelection(color_picker)
    color = color_picker.selectionColor
    @color_view.backgroundColor = color
    self.rowDescriptor.value = color
  end
end

class PMXLColorChooser < UIView

  attr_accessor :delegate

  def initWithFrame(frame)
    super.tap do
      self.backgroundColor = UIColor.whiteColor

      picker_frame = CGRectInset(frame, 10, 10)
      picker_frame.size.height = picker_frame.size.width
      @color_picker = RSColorPickerView.alloc.initWithFrame picker_frame
      self.addSubview(@color_picker)

      slider_frame = [[10, CGRectGetMaxX(picker_frame) + 5], [CGRectGetWidth(picker_frame), 30]]
      @slider = PMXLBrightnessSlider.alloc.initWithFrame slider_frame
      @slider.color_picker = @color_picker
      self.addSubview(@slider)
    end
  end

  def color=(value)
    @color_picker.setSelectionColor(value)
    @slider.value = @color_picker.brightness
  end

  def color
    @color_picker.selectionColor
  end

  def delegate=(value)
    @delegate = value
    @color_picker.delegate = value
  end

end

class PMXLBrightnessSlider < UISlider
  attr_accessor :color_picker

  def initWithFrame(frame)
    super.tap do
      init_routine
    end
  end

  def initWithCoder(decoder)
    super.tap do
      init_routine
    end
  end

  def init_routine
    self.minimumValue = 0.0
    self.maximumValue = 1.0
    self.continuous = true

    self.enabled = true
    self.userInteractionEnabled = true

    self.addTarget(self,
                   action: 'slider_value_changed:',
                   forControlEvents: UIControlEventValueChanged)
  end

  def slider_value_changed(_)
    color_picker.setBrightness(self.value)
  end

  def drawRect(rect)
    ctx = UIGraphicsGetCurrentContext()

    space = CGColorSpaceCreateDeviceGray()
    colors = [UIColor.blackColor, UIColor.whiteColor]

    gradient = CGGradientCreateWithColors(space, colors, nil)

    CGContextDrawLinearGradient(ctx, gradient, CGPointZero, [rect.size.width, 0], 0)
  end

  def color_picker=(value)
    @color_picker = value
    self.value = @color_picker.brightness unless @color_picker.nil?
  end

end
