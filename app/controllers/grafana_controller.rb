class GrafanaController < ApplicationController
  require 'net/http'

  def proxy
    grafana_url = "http://grafana:3000/#{params[:path]}"
    uri = URI(grafana_url)

    # Send request to the Grafana service
    response = Net::HTTP.get_response(uri)

    # Render the Grafana response
    render plain: response.body, status: response.code.to_i
  end
end
