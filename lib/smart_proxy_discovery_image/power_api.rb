require 'sinatra'

module Proxy::DiscoveryImage
  class PowerApi < ::Sinatra::Base
    helpers ::Proxy::Helpers
    include Proxy::Log
    include Proxy::Util

    put "/reboot" do
      log_halt(500, "shutdown binary was not found") unless (shutdown = which('shutdown'))
      run_after_response 5, shutdown, "-r", "now", "Foreman Power API reboot"
      content_type :json
      { :result => true }.to_json
    end

    put "/kexec" do
      body_data = request.body.read
      # change virtual terminal out of newt screen
      system("chvt", "2")
      logger.debug "Initiated kexec provisioning with #{body_data}"
      log_halt(500, "kexec binary was not found") unless (kexec = which('kexec'))
      begin
        data = JSON.parse body_data
      rescue JSON::ParserError
        log_halt 500, "Unable to parse kexec JSON input: #{body_data}"
      end
      logger.debug "Downloading: #{data['kernel']}"
      if ::Proxy::HttpDownload.new(data['kernel'], '/tmp/vmlinuz').start.join != 0
        log_halt 500, "cannot download kernel for kexec!"
      end
      logger.debug "Downloading: #{data['initram']}"
      if ::Proxy::HttpDownload.new(data['initram'], '/tmp/initrd.img').start.join != 0
        log_halt 500, "cannot download initram for kexec!"
      end
      run_after_response 2, kexec, "--debug", "--force", "--append=#{data['append']}", "--initrd=/tmp/initrd.img", "/tmp/vmlinuz", *data['extra']
      { :result => true }.to_json
    end


    # Execute command in a separate thread after 5 seconds to give the server some
    # time to finish the request. Does *not* execute via a shell.
    def run_after_response(seconds, *command)
      logger.debug "Power API scheduling in #{seconds} seconds: #{command.inspect}"
      Thread.start do
        begin
          sleep seconds
          logger.debug "Power API executing: #{command.inspect}"
          if (sudo = which('sudo'))
            status = system(sudo, *command)
          else
            logger.warn "sudo binary was not found"
          end
          # only report errors
          logger.warn "The attempted command failed with code #{$?.exitstatus}" unless status
        rescue Exception => e
          logger.error "Error during command execution: #{e}"
        end
      end
    end
  end
end
