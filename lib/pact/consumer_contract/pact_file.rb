require 'net/http'

module Pact
  module PactFile
    extend self

    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 5
    RETRY_LIMIT = 3

    class HttpError < StandardError
      attr_reader :uri, :response

      def initialize(uri, response)
        @uri, @response = uri, response
        super("HTTP request failed: status=#{response.code}")
      end
    end

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

    def render_pact(uri_string, options)
      uri_obj = URI(windows_safe(uri_string))
      if uri_obj.userinfo
        options[:username] = uri_obj.user unless options[:username]
        options[:password] = uri_obj.password unless options[:password]
      end
      get(uri_obj, options)
    end

    private

    def get(uri, options)
      local?(uri) ?  get_local(uri, options) : get_remote_with_retry(uri, options)
    end

    def local? uri
      !uri.host
    end

    def get_local(uri, _)
      File.read uri.to_s
    end

    def get_remote(uri, options)
      request = Net::HTTP::Get.new(uri)
      request.basic_auth(options[:username], options[:password]) if options[:username]
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.open_timeout = options[:open_timeout] || OPEN_TIMEOUT
        http.read_timeout = options[:read_timeout] || READ_TIMEOUT
        http.request(request)
      end
    end

    def get_remote_with_retry(uri, options)
      ((options[:retry_limit] || RETRY_LIMIT) + 1).times do |i|
        begin
          response = get_remote(uri, options)
          case
          when success?(response)
            return response.body
          when retryable?(response)
            raise HttpError.new(uri, response) if abort_retry?(i, options)
            delay_retry(i + 1)
            next
          else
            raise HttpError.new(uri, response)
          end
        rescue Timeout::Error => e
          raise e if abort_retry?(i, options)
          delay_retry(i + 1)
        end
      end
    end

    def success?(response)
      response.code.to_i == 200
    end

    def retryable?(response)
      (500...600).cover?(response.code.to_i)
    end

    def abort_retry?(count, options)
      count >= (options[:retry_limit] || RETRY_LIMIT)
    end

    def delay_retry(count)
      Kernel.sleep(2 ** count * 0.3)
    end

    def windows_safe(uri)
      uri.start_with?("http") ? uri : uri.gsub("\\", File::SEPARATOR)
    end
  end
end
