#!/bin/sh
set -e

git checkout -- lib/pact/support/version.rb
bundle exec bump ${1:-minor} --no-commit
bundle exec rake generate_changelog
git add CHANGELOG.md lib/pact/support/version.rb
git commit -m "chore(release): version $(ruby -r ./lib/pact/support/version.rb -e "puts Pact::Support::VERSION")"
bundle exec rake release
