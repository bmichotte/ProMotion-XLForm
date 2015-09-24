class UIAlertController
  # workaround for 
  # Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'UIAlertController:supportedInterfaceOrientations was invoked recursively!'

  def supportedInterfaceOrientations
    orientation = UIApplication.sharedApplication.statusBarOrientation

    orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskLandscape
  end

  def shouldAutorotate
    true
  end
end