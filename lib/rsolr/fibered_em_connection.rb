require "eventmachine"
require "em-http"

class RSolr::FiberedEmConnection

  def execute(client, request_context)
    method      = request_context[:method]
    data        = request_context[:data]
    scheme      = request_context[:uri].scheme
    host        = request_context[:uri].host
    port        = request_context[:uri].port
    request_uri = request_context[:uri].request_uri
    headers     = request_context[:headers] || {}
    
    params = {}
    params[:body] = data if method == :post and data
    request = "#{scheme}://#{host}:#{port}#{request_uri}"

    http = EM::HttpRequest.new(request).send(method, params)

    fiber = Fiber.current
    http.callback{ fiber.resume }
    http.errback { fiber.resume }
    Fiber.yield

    { :status   => http.response_header.status,
      :headers  => http.response_header.to_hash,
      :body     => http.response }
  end

end
