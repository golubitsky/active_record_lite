class AttrAccessorObject

  def self.my_attr_accessor(*names)
    #setters
    names.each do |name|
      define_method("#{name}=".intern) do |value|
        self.instance_variable_set("@#{name}", value)
      end
    end

    #getters
    names.each do |name|
      define_method(name) do
        self.instance_variable_get("@#{name}")
      end
    end

  end

end
