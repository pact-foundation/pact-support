# Releasing

1. Increment the version in `lib/pact/support/version.rb`
2. Update the `CHANGELOG.md` using:

      $ git log --pretty=format:'  * %h - %s (%an, %ad)' vX.Y.Z..HEAD

3. Add files to git

      $ git add CHANGELOG.md lib/pact/support/version.rb
      $ git commit -m "chore(release): version $(ruby -r ./lib/pact/support/version.rb -e "puts Pact::Support::VERSION")"

3. Release:

      $ bundle exec rake release
