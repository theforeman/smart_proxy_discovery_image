require 'smart_proxy_discovery_image/power_api'
require 'smart_proxy_discovery_image/inventory_api'

map "/power" do
  run Proxy::DiscoveryImage::PowerApi
end

map "/inventory" do
  run Proxy::DiscoveryImage::InventoryApi
end
