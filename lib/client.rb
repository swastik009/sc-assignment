##
# Client represents a single client record with dynamic attribute access.
#
# Allows access to attributes via [] and method_missing, supporting both string and symbol keys.
#
# @example Initialize and access attributes
#   client = Client.new({ 'email' => 'a@b.com', name: 'Alice' })
#   client[:email] #=> 'a@b.com'
#   client.name    #=> 'Alice'
class Client
  ##
  # Initializes a new Client with the given attributes.
  #
  # @param attrs [Hash] The attributes for the client (string or symbol keys).
  def initialize(attrs = {})
    @attrs = attrs
  end

  ##
  # Accesses an attribute by key (string or symbol).
  #
  # @param key [String, Symbol] The attribute key.
  # @return [Object, nil] The value for the key, or nil if not found.
  def [](key)
    @attrs[key.to_s] || @attrs[key.to_sym]
  end

  ##
  # Handles dynamic method access for attributes.
  #
  # @param method [Symbol] The method name (attribute key).
  # @return [Object, nil] The value for the key, or nil if not found.
  def method_missing(method, *_args)
    if @attrs.key?(method)
      @attrs[method]
    elsif @attrs.key?(method.to_s)
      @attrs[method.to_s]
    elsif @attrs.key?(method.to_sym)
      @attrs[method.to_sym]
    end
  end

  ##
  # Checks if the client responds to a dynamic attribute method.
  #
  # @param method [Symbol] The method name (attribute key).
  # @param include_private [Boolean] Whether to include private methods.
  # @return [Boolean] True if the attribute exists, false otherwise.
  def respond_to_missing?(method, include_private = false)
    @attrs.key?(method) || @attrs.key?(method.to_s) || @attrs.key?(method.to_sym) || super
  end

  ##
  # Returns all attribute keys for the client.
  #
  # @return [Array<String, Symbol>] The keys for all attributes.
  def keys
    @attrs.keys
  end

  ##
  # Returns a string representation of the client attributes.
  #
  # @return [String] The formatted attributes as a string.
  def to_s
    display = @attrs.map do |k, v|
      "#{k}: #{v}"
    end.join(', ')
    "#{display}"
  end
end
