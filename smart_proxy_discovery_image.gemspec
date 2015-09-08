# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smart_proxy_discovery_image/version'

Gem::Specification.new do |gem|
  gem.name          = "smart_proxy_discovery_image"
  gem.version       = Proxy::DiscoveryImage::VERSION
  gem.authors       = ['Lukas Zapletal']
  gem.email         = ['lzap+rpm@redhat.com']
  gem.homepage      = "https://github.com/theforeman/foreman-discovery-image"
  gem.summary       = %q{FDI API for Foreman Smart-Proxy}
  gem.description   = <<-EOS
    Smart Proxy plugin providing Foreman Discovery Image API.
  EOS

  gem.files         = Dir['{lib,bundler.d,settings.d}/**/*', 'Gemfile', 'LICENSE', 'README.md']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license = 'GPLv3'
end

