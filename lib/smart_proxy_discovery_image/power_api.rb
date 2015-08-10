require 'sinatra'

module Proxy::DiscoveryImage
  class PowerApi < ::Sinatra::Base
    helpers ::Proxy::Helpers
    include Proxy::Log
    include Proxy::Util

    put "/reboot" do
      log_halt 500, "shutdown binary was not found" unless (shutdown = which('shutdown'))
      run_after_response 5, shutdown, "-r", "now", "Foreman BMC API reboot"
      content_type :json
      { :result => true }.to_json
    end

    put "/kexec" do
      log_halt 500, "kexec binary was not found" unless (kexec = which('kexec'))
      data = JSON.parse request.body.read

      # download kernel and image synchronously (can be improved: http://projects.theforeman.org/issues/11318)
      wget = "#{which("wget")} --timeout=10 --tries=3 --no-check-certificate -qc "
      status = system("#{wget} '#{escape_for_shell(data['kernel'])}' -O /tmp/vmlinuz")
      log_halt 500, "Cannot download kernel: #{$?.exitstatus}" unless status
      status = system("#{wget} '#{escape_for_shell(data['initram'])}' -O /tmp/initrd.img")
      log_halt 500, "Cannot download kernel: #{$?.exitstatus}" unless status

      run_after_response 2, kexec, "--force", "--append=#{data['append']}", "--initrd=/tmp/initrd.img", "/tmp/vmlinuz"
      { :result => true }.to_json
    end


    # Execute command in a separate thread after 5 seconds to give the server some
    # time to finish the request. Does *not* execute via a shell.
    def run_after_response(seconds, *command)
      logger.debug "BMC shell execution scheduled in #{seconds} seconds"
      Thread.start do
        begin
          sleep seconds
          logger.debug "BMC shell executing: #{command.inspect}"
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
