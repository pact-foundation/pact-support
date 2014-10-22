Do this to generate your change history

  git log --pretty=format:'  * %h - %s (%an, %ad)'

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
