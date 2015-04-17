require 'spec_helper'
require 'pact/consumer/request'
require 'pact/consumer_contract/request'
require 'pact/matchers/embedded_diff_formatter'


PACT_SPEC_DIR = "../pact-specification/testcases"
REQUEST_TEST_CASE_FOLDERS = Dir.glob("#{PACT_SPEC_DIR}/request/**")
REQUEST_TEST_CASE_FILES = Dir.glob("#{PACT_SPEC_DIR}/request/**/*.json")

TEST_DESCRIPTIONS = {true => "matches", false => "does not match"}
TESTCASES = "**/*.json"
# TESTCASES = "array with nested array that matches.json"
describe "Pact gem complicance with Pact Specification 1.0.0" do

  directories = Dir.glob("#{PACT_SPEC_DIR}/request") # make this a *

  directories.each do | dir_name |

    describe File.basename(dir_name) do

      sub_directories = Dir.glob("#{dir_name}/*")

      sub_directories.each do | sub_dir_name |

        context File.basename(sub_dir_name) do
          testcases = Dir.glob("#{sub_dir_name}/#{TESTCASES}")

          testcases.each do | file_name |

            context File.basename(file_name).chomp(".json") do

              file_content = nil
              begin
                file_content = File.read(file_name)
                test_content = JSON.parse(file_content)
                default = {'query' => '', 'headers' => {}}

                request_hash = Pact::MatchingRules.merge(test_content["expected"], test_content["expected"]['requestMatchingRules'])
                expected = Pact::Request::Expected.from_hash(default.merge(request_hash))

                # expected = Pact::Request::Expected.from_hash(default.merge(test_content["expected"]))
                actual = Pact::Consumer::Request::Actual.from_hash(default.merge(test_content["actual"]))
                expected_result = test_content.fetch("match")
                comment = test_content["comment"]

                it "#{TEST_DESCRIPTIONS[expected_result]} - #{comment}" do
                  matches = expected.matches?(actual)
                  if matches != expected_result
                    puts Pact::Matchers::EmbeddedDiffFormatter.call(expected.difference(actual))
                  end
                  expect(matches).to eq expected_result
                end
              rescue => e
                puts "Error parsing json from #{file_name}, #{e.message}: #{file_content}"
                raise e
              end

            end

          end
        end
      end
    end
  end
end
