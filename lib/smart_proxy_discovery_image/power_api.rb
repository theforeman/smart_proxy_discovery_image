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
      download_and_run_after_response data, 2, kexec, "--debug", "--force", "--append=#{data['append']}", "--initrd=/tmp/initrd.img", "/tmp/vmlinuz", *data['extra']
      { :result => true }.to_json
    end


    # Execute command in a separate thread after 5 seconds to give the server some
    # time to finish the request. Does *not* execute via a shell.
    def run_after_response(seconds, *command)
      Thread.start do
        begin
          logger.debug "Power API scheduling in #{seconds} seconds: #{command.inspect}"
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

    # Variant which also downloads kernel and initramdisk
    def download_and_run_after_response(data, seconds, *command)
      Thread.start do
        begin
          # download kernel and initramdisk
          downloaded = download_file(data, 'kernel', 'vmlinuz', '/tmp') &&
                         download_file(data, 'initram', 'initrd.img', '/tmp')
          # wait few seconds just in case the download was fast and perform kexec
          # only perform kexec when both locks were available to prevent subsequent request while downloading
          run_after_response(seconds, *command) if downloaded
        rescue Exception => e
          logger.error "Error during command execution: #{e}"
        end
      end
    end

    def download_file(data, kind, name, prefix)
      return unless data && (url = data[kind])

      logger.debug "Downloading: #{url}"
      download_thread = ::Proxy::HttpDownload.new(url, File.join(prefix, name)).start
      logger.error("#{name} is still downloading, ignored") unless download_thread
      download_success = download_thread.join.zero?
      logger.error("cannot download #{name} for kexec") unless download_success
      download_success
    end
  end
end
