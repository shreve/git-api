require 'json'

class Server
  DEFAULT_HEADERS = {
    'Content-Type' => 'application/json'
  }.freeze

  def initialize(&block)
    @routes = Routes.new(&block)
  end

  def call(env)
    request = Rack::Request.new(env)

    @routes.each do |route|
      next if (content = route.run(request)) == false
      return not_found if content.nil?
      return [200, DEFAULT_HEADERS, [content.to_json]]
    end

    not_found
  end

  private

  def not_found
    [404, {}, ['']]
  end

  # Collection of Route objects (intended for instance_eval DSL)
  class Routes
    def initialize(&block)
      @routes = []
      instance_eval(&block)
    end

    def get(route_spec, &block)
      # Replace all param placeholders with named regex matches
      pattern = route_spec.gsub(/:\w+/) { |w| "(?<#{w[1..-1]}>.*)" }
      pattern = %r{\A#{pattern}\z}

      @routes << Route.new(pattern, block)
    end

    def each(&block)
      @routes.each(&block)
    end
  end

  Route = Struct.new(:pattern, :block) do
    def run(request)
      match = pattern.match(request.path)
      return false unless match

      params = request.params.merge(match.named_captures)

      ActionEnvironment.new(request, params).instance_eval(&block)
    end
  end

  class ActionEnvironment
    attr_reader :request, :params

    def initialize(request, params)
      @request = request
      @params = params

      params.each_pair do |name, value|
        define_singleton_method(name) { value }
      end
    end
  end
end
