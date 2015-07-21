module XLFormClassMethods

  def form_options(opts={})
    @form_options = opts
  end

  def get_form_options
    @form_options || {}
  end

end
