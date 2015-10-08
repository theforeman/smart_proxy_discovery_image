class Proxy::DiscoveryImage::InventoryApi < Sinatra::Base
  helpers ::Proxy::Helpers

  get "/facter" do
    begin
      content_type :json
      Facter.clear
      Facter.to_hash.to_json
    rescue => e
      log_halt 400, e
    end
  end
end
