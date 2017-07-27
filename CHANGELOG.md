Do this to generate your change history

  git log --pretty=format:'  * %h - %s (%an, %ad)'

### 1.1.3 (28 July 2017)
* cd0fc09 - fix(pact serialisation): Use square bracket notation for JSON path keys containing dots when serialising the pact Fixes https://github.com/pact-foundation/pact-support/issues/39 (Beth Skurrie, Fri Jul 28 09:39:15 2017 +1000)

### 1.1.2 (20 June 2017)
* 8c3e53d - Fixing recursive require problems for https://github.com/pact-foundation/pact-support/issues/36 (Beth Skurrie, Tue Jun 20 18:59:24 2017 +1000)

### 1.1.1 (20 June 2017)
* 14789df - Adding missing requires for #36 (Beth Skurrie, Tue Jun 20 16:27:43 2017 +1000)

### 1.1.0 (19 June 2017)
* 1659c54 - Add list of messages to diff output (Beth Skurrie, Mon Jun 19 09:39:08 2017 +1000)
* e18debc - Reify actual and expected when a type difference is encountered while doing exact matching (Beth Skurrie, Tue May 30 09:24:18 2017 +1000)
* 2ba49b6 - Updating matching rules extraction to use inheritance as per #34 (Beth Skurrie, Mon May 29 16:17:57 2017 +1000)

### 1.0.1 (11 May 2017)
* e34374b - Extract rules for QueryHash and QueryString so we can include request matching rules in the pact. (Beth Skurrie, Thu May 11 09:11:19 2017 +1000)

### 1.0.0 (12 Apr 2017)
* 0ad2ef5 - Stop removing trailing slash from path, as per https://github.com/pact-foundation/pact-specification/blob/version-2/testcases/request/path/missing%20trailing%20slash%20in%20path.json (Beth Skurrie, Wed Apr 12 14:59:04 2017 +1000)
* 7f93c00 - add a helper to match a non iso861 datetime string (Courtney Braafhart, Thu Apr 6 12:18:53 2017 -0500)

### 0.6.1 (10 Mar 2017)
* 4627b56 - Explicit require of CGI class. (Tan Le, Thu Mar 9 17:01:37 2017 +1100)
* 26b6678 - Added colon support to matching rules path. (soundstep, Wed Mar 8 09:18:35 2017 +0000)

### 0.6.0 (14 Nov 2016)
* 64a9a37 - Enable interactions to validate themselves (Taiki Ono, Wed Nov 9 19:08:49 2016 +0900)

### 0.5.9 (27 Jun 2016)
* dea4645 - Clarify that pact-support will only work with ruby >= 2.0 (Sergei Matheson, Mon Jun 27 10:18:32 2016 +1000)
* 50ea21f - Update json_differ.rb (Beth Skurrie, Thu Jun 9 16:01:34 2016 +1000)
* d303870 - Comment. (Beth Skurrie, Thu Jun 9 15:57:34 2016 +1000)

### 0.5.8 (26 May 2016)
* 768b382 - Add pactfile_write_order configuration (Alex Malkov, Mon May 23 11:02:27 2016 +0100)

### 0.5.7 (3 May 2016)
* 289d4e5 - Handle loading local pact files as well as remote (Sergei Matheson, Tue May 3 12:56:51 2016 +1000)
* 6d4e559 - Update to ruby 2.3.1 in travis (Sergei Matheson, Tue May 3 10:46:46 2016 +1000)

### 0.5.6 (29 April 2016)
* d8bc8fa - Remove pull request merge logs from changelog (Sergei Matheson, Fri Apr 29 10:06:51 2016 +1000)
* 24ba197 - Corrected v0.5.5 release date in CHANGELOG (Sergei Matheson, Fri Apr 29 10:05:11 2016 +1000)
* 9dcef8d - Retry reading pact file (Taiki Ono, Thu Apr 28 17:15:54 2016 +0900)
* 61ceda1 - Re-write test with WebMock (Taiki Ono, Thu Apr 28 15:50:29 2016 +0900)
* 62dcf66 - Use WebMock2 (Taiki Ono, Thu Apr 28 13:51:53 2016 +0900)

### 0.5.5 (29 April 2016)
* eb9aa26 - Supporting nested Pact::SomethingLike reification (Takatoshi Maeda, Thu Apr 28 02:04:58 2016 +0900)
* 9e924c8 - Object supporting DSL can be built without block (Taiki Ono, Wed Mar 23 16:38:27 2016 +0900)
* 2b0e7b4 - Escape query string components (Taiki Ono, Mon Mar 14 15:22:29 2016 +0900)
* a383368 - Fix indent (Taiki Ono, Mon Mar 14 15:18:26 2016 +0900)
* dc54092 - Support latest jruby and drop supporting jruby 1.7 (Taiki Ono, Sun Mar 13 20:27:17 2016 +0900)
* 85fbb09 - Drop supporting ruby1.9 (Taiki Ono, Thu Mar 10 23:01:54 2016 +0900)
* 966fa3a - `raise_error` should be with specific error (Taiki Ono, Thu Mar 10 22:50:13 2016 +0900)
* 2861742 - Cosmetic change (Taiki Ono, Thu Mar 10 22:11:51 2016 +0900)
* c491682 - `QueryHash` accepts nested hash query (Taiki Ono, Thu Mar 10 21:24:41 2016 +0900)

### 0.5.4 (4 November 2015)

* 2791b72 - [+AM] Add like_datetime_with_milisecods helper method (David Sevcik, Wed Nov 4 17:40:53 2015 +0100)

### 0.5.3 (8 September 2015)

* c7b1454 - Apply reification to ArrayLike flexible matcher. (Matt Fellows, Tue Sep 8 11:35:32 2015 +1000)

### 0.5.2 (13 August 2015)

* cb88842 - Add shortcuts like_uuid, like_datetime, like_date (Alex Malkov, Thu Aug 13 09:34:23 2015 +0100)

### 0.5.1 (19 July 2015)

* bd24aff - Remove rspec require from pact/support.rb to stop rspec's let method overriding minitest's let method (Beth Skurrie, Sun Jul 19 07:49:15 2015 +1000)
* bbe9553 - Support bracket notation in matching rule jsonpaths. (Beth Skurrie, Fri Jul 10 15:16:55 2015 +1000)

### 0.5.0 (10 July 2015)

* 9451bf4 - Created helper methods for Pact::Term, SomethingLike and ArrayLike (Beth Skurrie, Fri Jul 10 11:44:45 2015 +1000)

### 0.4.4 (9 July 2015)

* 6d9be6e - Create no rules for exact matching (Beth Skurrie, Thu Jul 9 14:28:56 2015 +1000)

### 0.4.3 (7 July 2015)

* cf99e97 - Handle nils when symbolizing keys in a hash (Beth Skurrie, Tue Jul 7 11:52:50 2015 +1000)
* b100ccd - Log warning when no content type is found that text diff will be performed on body (Beth Skurrie, Sun May 10 21:57:07 2015 +1000)

### 0.4.2 (9 May 2015)

* 75f98d7 - Added missing requires (Beth Skurrie, Sat May 9 16:20:07 2015 +1000)

### 0.4.1 (23 April 2015)

* 7da52f3 - Switch from require_relative to require to avoid double-loading when symlinks are involved (John Meredith, Thu Apr 23 14:46:03 2015 +1000)

### 0.4.0 (20 March 2015)

* 409bde5 - support url including basic authentication info, e.g.: http://username:password@packtbroker.com (lifei zhou, Wed Mar 18 21:49:29 2015 +1100)
* d0d42bb - added http basic authentication options when open uri (lifei zhou, Thu Feb 26 22:03:21 2015 +1100)

### 0.3.1 (24 Februrary 2015)

* e3d6d6d - Fixed bug when Content-Type is a Pact::Term. (Beth Skurrie, Tue Feb 24 17:25:10 2015 +1100)

### 0.3.0 (13 Februrary 2015)

* 4e29277 - Create a public API for extracting matching rules for pact-mock_service to use. (Beth Skurrie, Fri Feb 13 15:35:14 2015 +1100)
* 17ffb7e - Improve Pact::Term error message when value does not match regexp. (Beth Skurrie, Thu Feb 12 15:35:28 2015 +1100)
* ad0b37b - Added logic to convert Term and SomethingLike to v2 matching rules (Beth Skurrie, Thu Feb 12 14:55:34 2015 +1100)
* cc15c4d - Renamed <index not found> to <item not found>, and <index not to exist> to <item not to exist> (Beth Skurrie, Thu Feb 12 11:47:53 2015 +1100)
* 1b65c46 - Change "no difference here" to ... in unix diff output (Beth Skurrie, Thu Feb 12 11:43:58 2015 +1100)
* 3cb5b30 - Fix duplicate "no difference here!" in diff when actual array has more items than the expected (Beth Skurrie, Thu Feb 12 11:30:58 2015 +1100)
* a9da567 - Changed display of NoDiffAtIndex (Beth Skurrie, Tue Dec 23 15:16:49 2014 +1100)
* f9619e6 - Log warning message when unsupported rules are detected (Beth Skurrie, Tue Dec 23 14:42:22 2014 +1100)
* 9875bef - Added support for v2 regular expression matching in provider (Beth Skurrie, Tue Dec 23 14:15:00 2014 +1100)

### 0.2.1 (21 January 2015)

* 4e26c75 - Ignore HTTP method case when determining if routes match. https://github.com/bethesque/pact-support/issues/3 (Beth, Tue Jan 20 20:15:20 2015 +1100)
* af96eba - Allow request path to be a Pact::Term (Beth, Tue Jan 20 19:37:23 2015 +1100)

### 0.1.4 (20 January 2015)

A naughty release because bumping the minor version to 0.2.0 means I have to upgrade all the gems.

### 0.2.0 (20 January 2015)

* bb5d893 - Added option to UnixDiffFormatter to not show the explanation (Beth, Tue Jan 20 08:39:42 2015 +1100)

### 0.1.3 (12 December 2014)

* 27f3625 - Fixed bug rendering no diff indicator as JSON (Beth, Fri Dec 12 10:42:50 2014 +1100)

### 0.1.2 (22 October 2014)

* 00280ac - Added logic to match form data when specified as a Hash (bethesque, Wed Oct 22 15:21:39 2014 +1100)

### 0.1.1 (22 October 2014)

* ff6a01d - Disallowing unexpected params in the query (bethesque, Wed Oct 22 14:42:41 2014 +1100)

### 0.1.0 (22 October 2014)

* fa7e03f - Removed JSON serialisation code from models. It has been moved to decorators in pact_mock-service. (bethesque, Wed Oct 22 12:53:21 2014 +1100)

### 0.0.4 (20 October 2014)

* ebe5e32 - Added differ for application/x-www-form-urlencoded bodies. (bethesque, Mon Oct 20 20:26:13 2014 +1100)

### 0.0.3 (17 October 2014)

* bab0b34 - Added possibility to provide queries as Hash. Then order of parameters in the query is not longer relevant. (André Allavena, Tue Oct 14 00:24:38 2014 +1000)

### 0.0.2 (12 October 2014)

* e7080fe - Added a QueryString class in preparation for a QueryHash class (Beth, Sun Oct 12 14:32:15 2014 +1100)
* 8839151 - Added Travis config (Beth, Sun Oct 12 12:31:44 2014 +1100)
* 81ade54 - Removed CLI (Beth, Sun Oct 12 12:29:22 2014 +1100)
* 3bdde98 - Removing unused files (Beth, Sun Oct 12 12:11:48 2014 +1100)
* ef95717 - Made it build (Beth, Sat Oct 11 13:24:35 2014 +1100)
* 1e78b62 - Removed pact-test.rake (Beth, Sat Oct 11 13:20:49 2014 +1100)
* 3389b5e - Initial commit (Beth, Sat Oct 11 13:13:23 2014 +1100)
