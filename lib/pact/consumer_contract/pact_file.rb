module Pact

  module PactFile

    extend self

    def read uri, options = {}
      open_options = options[:username] ? {} : {http_basic_authentication:[options[:username],options[:password]]}
      pact = open(uri.to_s, open_options) { | file | file.read }
      if options[:save_pactfile_to_tmp]
        save_pactfile_to_tmp pact, ::File.basename(uri.to_s)
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
  end
end