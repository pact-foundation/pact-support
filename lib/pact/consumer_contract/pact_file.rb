module Pact

  module PactFile

    extend self

    def read uri, options = {}
      uri_string = uri.to_s
      pact = render_pact(uri_string, options)
      if options[:save_pactfile_to_tmp]
        save_pactfile_to_tmp pact, ::File.basename(uri_string)
      end
      pact
    rescue StandardError => e
      $stderr.puts "Error reading file from #{uri}"
      $stderr.puts "#{e.to_s} #{e.backtrace.join("\n")}"
      raise e
    end

    def save_pactfile_to_tmp pact, name
      ::FileUtils.mkdir_p Pact.configuration.tmp_dir
      ::File.open(Pact.configuration.tmp_dir + "/#{name}", "w") { |file|  file << pact}
    end

    def render_pact uri_string, options
      if File.file?(uri_string)
        open(uri_string) { | file | file.read }
      else
        uri_obj = URI(uri_string)
        uri_user_info = uri_obj.userinfo
        if(uri_user_info)
          options[:username] = uri_obj.user unless options[:username]
          options[:password] = uri_obj.password unless options[:password]
          uri_string = uri_string.sub("#{uri_user_info}@", '')
        end
        open_options = options[:username] ? {http_basic_authentication:[options[:username],options[:password]]} : {}
        open(uri_string, open_options) { | file | file.read }
      end
    end
  end
end
