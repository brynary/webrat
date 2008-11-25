class Module #:nodoc:
  def webrat_deprecate(old_method_name, new_method_name)
    define_method old_method_name do |*args|
      warn "#{old_method_name} is deprecated. Use #{new_method_name} instead."
      __send__(new_method_name, *args)
    end
  end
end