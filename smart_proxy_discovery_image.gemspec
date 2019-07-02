# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smart_proxy_discovery_image/version'

Gem::Specification.new do |gem|
  gem.name          = "smart_proxy_discovery_image"
  gem.version       = Proxy::DiscoveryImage::VERSION
  gem.authors       = ['Lukas Zapletal']
  gem.email         = ['lzap+rpm@redhat.com']
  gem.homepage      = "https://github.com/theforeman/smart_proxy_discovery_image"
  gem.summary       = %q{FDI API for Foreman Smart-Proxy}
  gem.description   = <<-EOS
    Smart Proxy plugin providing Image API on discovered nodes. This plugin is only
    useful on discovered nodes, do not install on regular Smart Proxy deployments.
  EOS

  gem.files         = Dir['{lib,bundler.d,settings.d}/**/*', 'Gemfile', 'LICENSE', 'README.md']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license = 'GPL-3.0'
end

