class Client
  def initialize(attrs = {})
    @attrs = attrs
  end

  def [](key)
    @attrs[key.to_s] || @attrs[key.to_sym]
  end

  def keys
    @attrs.keys
  end

  def to_s
    display = @attrs.map do |k, v|
      "#{k}: #{v}"
    end.join(', ')
    "#{display}"
  end
end
