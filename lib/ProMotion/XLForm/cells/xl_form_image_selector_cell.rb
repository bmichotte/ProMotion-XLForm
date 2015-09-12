class XLFormImageSelectorCell < XLFormBaseCell

  attr_accessor :imageview, :text_label

  def configure
    super
    @image_height = 100.0
    @image_width = 100.0
    self.selectionStyle = UITableViewCellSelectionStyleNone
    self.backgroundColor = UIColor.whiteColor
    self.separatorInset = UIEdgeInsetsZero

    self.contentView.addSubview(imageview)
    self.contentView.addSubview(text_label)
    text_label.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew, context: 0)
  end

  def update
    text_label.text = self.rowDescriptor.title
    imageview.image = self.rowDescriptor.value

    text_label.setFont(UIFont.preferredFontForTextStyle(UIFontTextStyleBody))
    text_label.sizeToFit
    updateConstraints
  end

  def self.formDescriptorCellHeightForRowDescriptor(_)
    120.0
  end

  def formDescriptorCellDidSelectedWithFormController(controller)
    if Kernel.const_defined?("UIAlertController")
      alert = UIAlertController.alertControllerWithTitle(self.rowDescriptor.selectorTitle,
                                                         message: nil,
                                                         preferredStyle: UIAlertControllerStyleActionSheet)

      alert.addAction(UIAlertAction.actionWithTitle(NSLocalizedString("Choose From Library", nil),
                                                    style: UIAlertActionStyleDefault,
                                                    handler: lambda { |_|
                                                      open_from_alert(UIImagePickerControllerSourceTypePhotoLibrary)
                                                    }))

      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera)
        alert.addAction(UIAlertAction.actionWithTitle(NSLocalizedString("Take Photo", nil),
                                                      style: UIAlertActionStyleDefault,
                                                      handler: lambda { |_|
                                                        open_from_alert(UIImagePickerControllerSourceTypeCamera)
                                                      }))
      end

      if 
        alert.modalPresentationStyle = UIModalPresentationPopover
        alert.popoverPresentationController.sourceView = self.contentView
        alert.popoverPresentationController.sourceRect = self.contentView.bounds
      end

      present = -> {
        self.formViewController.presentViewController(alert, animated: true, completion: nil)
      }
      if self.formViewController.presentedViewController
        self.formViewController.dismissViewControllerAnimated(true, completion: present)
      else
        present.call
      end

    else
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera)
        action_sheet = UIActionSheet.alloc.initWithTitle(self.rowDescriptor.selectorTitle,
                                                         delegate: self,
                                                         cancelButtonTitle: NSLocalizedString("Cancel", nil),
                                                         destructiveButtonTitle: nil,
                                                         otherButtonTitles: NSLocalizedString("Choose From Library", nil), NSLocalizedString("Take Photo", nil), nil)
      else
        action_sheet = UIActionSheet.alloc.initWithTitle(self.rowDescriptor.selectorTitle,
                                                         delegate: self,
                                                         cancelButtonTitle: NSLocalizedString("Cancel", nil),
                                                         destructiveButtonTitle: nil,
                                                         otherButtonTitles: NSLocalizedString("Choose From Library", nil), nil)
      end
      action_sheet.tag = self.tag
      action_sheet.showInView(self.formViewController.view)
    end
  end

  def updateConstraints
    ui_components = { "image" => imageview, "text" => text_label }

    self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-16-[text]", options: 0, metrics: 0, views: ui_components))
    self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-6-[text]", options: 0, metrics: 0, views: ui_components))

    self.contentView.addConstraint(NSLayoutConstraint.constraintWithItem(imageview,
                                                                         attribute: NSLayoutAttributeTop,
                                                                         relatedBy: NSLayoutRelationEqual,
                                                                         toItem: self.contentView,
                                                                         attribute: NSLayoutAttributeTop,
                                                                         multiplier: 1.0,
                                                                         constant: 10.0))

    self.contentView.addConstraint(NSLayoutConstraint.constraintWithItem(imageview,
                                                                         attribute: NSLayoutAttributeBottom,
                                                                         relatedBy: NSLayoutRelationEqual,
                                                                         toItem: self.contentView,
                                                                         attribute: NSLayoutAttributeBottom,
                                                                         multiplier: 1.0,
                                                                         constant: -10.0))

    self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[image(width)]", options: 0, metrics: { "width" => @image_width }, views: ui_components))
    self.contentView.addConstraint(NSLayoutConstraint.constraintWithItem(imageview,
                                                                         attribute: NSLayoutAttributeCenterX,
                                                                         relatedBy: NSLayoutRelationEqual,
                                                                         toItem: self.contentView,
                                                                         attribute: NSLayoutAttributeCenterX,
                                                                         multiplier: 1.0,
                                                                         constant: 0.0))
    super
  end

  # trick to force the status bar to be hidden when presenting the UIImagePickerViewController
  def navigationController(_, willShowViewController: _, animated: _)
    UIApplication.sharedApplication.setStatusBarHidden true
  end

  def setImageValue(image)
    self.rowDescriptor.value = image
    imageview.image = image
  end

  def observeValueForKeyPath(key_path, ofObject: object, change: change, context: _)
    if object == text_label && key_path == "text"
      if change[NSKeyValueChangeKindKey] == NSKeyValueChangeSetting
        text_label.sizeToFit
        frame = text_label.frame
        frame.origin = [16, 4]
        text_label.frame = frame
        self.contentView.needsUpdateConstraints
      end
    end
  end

  def dealloc
    text_label.removeObserver(self, forKeyPath: "text")
  end

  # UIActionSheetDelegate
  def actionSheet(action_sheet, clickedButtonAtIndex: button_index)
    return if button_index == action_sheet.cancelButtonIndex

    title = action_sheet.buttonTitleAtIndex(button_index)

    case title
      when NSLocalizedString("Choose From Library", nil)
        open_from_alert(UIImagePickerControllerSourceTypePhotoLibrary)
      when NSLocalizedString("Take Photo", nil)
        open_from_alert(UIImagePickerControllerSourceTypeCamera)
      else
        return
    end
  end

  def open_from_alert(source)
    open = -> {
      open_picker(source)
    }

    if @popover_controller && @popover_controller.isPopoverVisible
      @popover_controller.dismissPopoverAnimated(true)
      open.call
    elsif self.formViewController.presentedViewController
      self.formViewController.dismissViewControllerAnimated(true, completion: open)
    else
      open.call
    end
  end

  def open_picker(source)
    @image_picker = UIImagePickerController.alloc.init
    @image_picker.delegate = self
    @image_picker.allowsEditing = true
    @image_picker.sourceType = source

    if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
      @popover_controller = UIPopoverController.alloc.initWithContentViewController(@image_picker)
      @popover_controller.presentPopoverFromRect(self.contentView.frame,
                                                 inView: self.formViewController.view,
                                                 permittedArrowDirections: UIPopoverArrowDirectionAny,
                                                 animated: true)
    else
      self.formViewController.presentViewController(@image_picker,
                                                    animated: true,
                                                    completion: nil)
    end
  end

  # UIImagePickerControllerDelegate
  def imagePickerController(_, didFinishPickingMediaWithInfo: info)
    editedImage = info[UIImagePickerControllerEditedImage]
    originalImage = info[UIImagePickerControllerOriginalImage]
    if editedImage
      imageToUse = editedImage
    else
      imageToUse = originalImage
    end
    setImageValue(imageToUse)

    if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
      if @popover_controller && @popover_controller.isPopoverVisible
        @popover_controller.dismissPopoverAnimated(true)
      end
    else
      self.formViewController.dismissViewControllerAnimated(true, completion: nil)
    end
  end

  # Properties
  def imageview
    return @imageview if @imageview

    @imageview = UIImageView.autolayoutView
    @imageview.layer.masksToBounds = true
    @imageview.contentMode = UIViewContentModeScaleAspectFit
    @imageview
  end

  def text_label
    return @text_label if @text_label
    @text_label = UILabel.autolayoutView
  end

end
