require 'smart_proxy_discovery_image/power_api'

map "/power" do
  run Proxy::DiscoveryImage::PowerApi
end
