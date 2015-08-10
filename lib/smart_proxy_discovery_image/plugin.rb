module Proxy::DiscoveryImage
  class Plugin < ::Proxy::Plugin
    plugin 'discovery_image', Proxy::DiscoveryImage::VERSION

    http_rackup_path File.expand_path('http_config.ru', File.expand_path('../', __FILE__))
    https_rackup_path File.expand_path('http_config.ru', File.expand_path('../', __FILE__))
  end
end
