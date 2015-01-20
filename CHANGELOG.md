Do this to generate your change history

  git log --pretty=format:'  * %h - %s (%an, %ad)'

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
