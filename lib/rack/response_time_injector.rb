module Rack
  class ResponseTimeInjector
    def initialize(app, options = {})
      @app = app
      @format = options[:format] || "%f"
    end

    def returning(value)
      yield value
      value
    end
    
    def call(env)
      t0 = Time.now
      returning @app.call(env) do |status, headers, response|
        if response.kind_of?(ActionDispatch::Response)
          response.body = response.body.gsub /\$responsetime(?:\((.+)\))?/ do
            diff = Time.now - t0
            if @format.respond_to? :call
              @format.call(diff)
            else
              ($1 || @format) % diff
            end
          end
        end
      end
    end
  end
end
