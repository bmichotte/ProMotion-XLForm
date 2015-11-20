module ProMotion
  class XLFormImageSelectorCell < XLFormCell

    def self.formDescriptorCellHeightForRowDescriptor(_)
      100
    end

    def setup(data_cell, screen)
      super

      size = (data_cell[:height] || 100) - 20

      @imageview = UIImageView.alloc.initWithFrame([[0, 0], [size, size]])
      self.accessoryView = @imageview

      self.selectionStyle = UITableViewCellSelectionStyleNone
      self.backgroundColor = UIColor.whiteColor
      self.separatorInset = UIEdgeInsetsZero
      self.editingAccessoryView = self.accessoryView
    end

    def update
      @imageview.image = value
    end

    def formDescriptorCellDidSelectedWithFormController(controller)
      if Kernel.const_defined?("UIAlertController") && UIAlertController.respond_to?(:'alertControllerWithTitle:message:preferredStyle:')
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

        if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
          alert.modalPresentationStyle = UIModalPresentationPopover
          alert.popoverPresentationController.sourceView = self.contentView
          alert.popoverPresentationController.sourceRect = self.contentView.bounds
        end

        present = -> {
          Dispatch::Queue.main.async do
            self.formViewController.presentViewController(alert, animated: true, completion: nil)
          end
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

    # trick to force the status bar to be hidden when presenting the UIImagePickerViewController
    def navigationController(_, willShowViewController: _, animated: _)
      UIApplication.sharedApplication.setStatusBarHidden true
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
        Dispatch::Queue.main.async do
          @popover_controller.presentPopoverFromRect(self.contentView.frame,
                                                     inView: self.formViewController.view,
                                                     permittedArrowDirections: UIPopoverArrowDirectionAny,
                                                     animated: true)
        end
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

      self.value = imageToUse
      @imageview.image = imageToUse

      if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad
        if @popover_controller && @popover_controller.isPopoverVisible
          @popover_controller.dismissPopoverAnimated(true)
        end
      else
        self.formViewController.dismissViewControllerAnimated(true, completion: nil)
      end
    end

  end
end
