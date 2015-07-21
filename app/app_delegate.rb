class AppDelegate < ProMotion::Delegate

  def on_load(app, options)
    open TestFormScreen.new(nav_bar: true)
  end
  
end
