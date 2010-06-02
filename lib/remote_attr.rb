# Designed to be used as an extend; these methods will apply to the class, like
# Foo. When writing the class, simply call remote_attr and the magic will
# happen.
module RemoteAttr

  # Assumes that the class we are invoking this on as an instance variable
  # @client set.
  def remote_attr(*attributes)
    # The last element of attributes best be a hash containing some required
    # options.
    options = attributes.pop

    unless (prefix = options.delete(:prefix))
      raise ArgumentError, "Must specify a prefix for the method calls!"
    end

    unless (default_arguments = options.delete(:default_arguments))
      raise ArgumentError, "Must specify the default arguments for the method calls! Typically, this is the identity of an item."
    end

    default_arguments = [default_arguments] unless default_arguments.is_a? Array


    # If an attribute is of the form: 
    #   get_foo => foo
    # NOTE: Set methods not supported, as I haven't had any need for them yet.
    if option[:rubify] == true
      attributes.map! do |attribute|
        if match = /^get_(.*)$/.match(attribute)
          match[1]
        else
          # Catch-all in case we can't match it.
          attribute
        end
      end
    end

    # The metaprogrammatic magic
    # NOTE: this also ignores set_* methods.
    attributes.each do |m|
      attr_reader m
      ivar_name = "@#{m}".to_sym # a reference to the variable for our methods
      define_method(m, ->(force = false) do # An option to force the reloading of the ivar
        i = instance_variable_get ivar_name
        # Make sure we reload if the ivar isn't set.
        if i.nil? || force
          r = @client.call("#{prefix}.get_#{m}", *default_arguments)
          instance_variable_set ivar_name, r
        end
        instance_variable_get ivar_name
      end)
    end
  end
end

