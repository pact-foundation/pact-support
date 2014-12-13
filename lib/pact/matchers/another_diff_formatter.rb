require 'pact/shared/jruby_support'
require 'pact/shared/active_support_support'
require 'pact/matchers/differ'
require 'term/ansicolor'

module Pact
  module Matchers

    class AnotherDiffFormatter

      include JRubySupport
      include Pact::ActiveSupportSupport
      C = ::Term::ANSIColor

      def initialize diff, options = {}
        @diff = diff
        @colour = options.fetch(:colour, false)
        @differ = Pact::Matchers::Differ.new(@colour)
      end

      def self.call diff, options = {colour: Pact.configuration.color_enabled}
        new(diff, options).call
      end

      def call
        to_s
      end

      def to_s
        annotate fix_json_formatting(JSON.pretty_generate(handle(@diff)))
      end

      private

      def handle thing
        case thing
        when Hash then copy_hash(thing)
        when Array then copy_array(thing)
        when Difference then copy_diff(thing)
        when TypeDifference then copy_diff(thing)
        when RegexpDifference then copy_diff(thing)
        when NoDiffIndicator then copy_no_diff(thing)
        else copy_object(thing)
        end
      end

      def annotate json
        lines = json.split("\n")
        max = lines.collect(&:size).max
        next_message = nil
        lines.collect do | line |

          if next_message
            msg, next_message = next_message, nil
            line.ljust(max) + msg
          else

            if line =~ /"expected_key.*":/
              line.gsub(/expected_key_/, '').ljust(max) + C.color(:green, " <- Expected")
              # C.color(:green, line.gsub(/expected_/, '').ljust(max) + " <- Expected")
            elsif line =~ /"actual_key.*":/
              line.gsub(/actual_key_/, '').ljust(max) + C.color(:red, " <- Actual")
              # C.color(:red, line.gsub(/actual_/, '').ljust(max) + " <- Actual")
            elsif line =~ /"expected_at_index:(\d+)/
              next_message = C.color(:green, " <- Expected at [#{$1}]")
              nil
            elsif line =~ /"expected_to_match_/
              line.gsub(/expected_to_match_/, '').ljust(max) + C.color(:green, " <- Expected to match")
            elsif line =~ /"actual_at_index:(\d+)/
              next_message = C.color(:red, " <- Actual at [#{$1}]")
              nil
            else
              line
            end

          end

        end.compact.join("\n")
      end


      def generate_string diff
        comparable = handle(diff)
        begin
          # Can't think of an elegant way to check if we can pretty generate other than to try it and maybe fail
          fix_blank_lines_in_empty_hashes JSON.pretty_generate(comparable)
        rescue JSON::GeneratorError
          comparable.to_s
        end
      end

      def copy_hash hash
        hash.keys.each_with_object({}) do | key, new_hash |
          if hash[key].is_a?(Pact::Matchers::Difference)
            new_hash['expected_key_' + key.to_s] = hash[key].expected
            new_hash['actual_key_' + key.to_s] = hash[key].actual
          elsif hash[key].is_a?(Pact::Matchers::RegexpDifference)
            new_hash['expected_to_match_' + key.to_s] = RegexpDecorator.new(hash[key].expected)
            new_hash['actual_key_' + key.to_s] = hash[key].actual
          else
            value = handle hash[key]
            new_hash[key] = value unless (KeyNotFound === value || UnexpectedKey === value)
          end
        end
      end

      def copy_array array
        array.each_index.each_with_object([]) do | index, new_array |
          # Regexp difference!
          if array[index].is_a?(Difference)
            new_array << "expected_at_index:#{index}"
            new_array << array[index].expected
            new_array << "actual_at_index:#{index}"
            new_array << array[index].actual
          elsif array[index].is_a?(NoDiffIndicator)
            # do nothing
          else
            value = handle array[index]
            (new_array << value) unless (UnexpectedIndex === value || IndexNotFound === value)
          end

        end
      end

      def copy_no_diff(thing)
        thing
      end

      def copy_diff difference
        if target == :actual
          handle difference.actual
        else
          handle difference.expected
        end
      end

      def copy_object object
        if Regexp === object
          RegexpDecorator.new(object)
        else
          object
        end
      end

      attr_reader :diff

      class RegexpDecorator

        def initialize regexp
          @regexp = regexp
        end

        def to_json options={}
          @regexp.inspect
        end

        def as_json
          @regexp.inspect
        end
      end
    end

  end
end
