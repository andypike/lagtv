LAGTV Website
=============

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/andypike/lagtv)

Calling all fans of [LAGTV](http://www.youtube.com/user/LifesAGlitchTV). We, the bouses and bousettes of LAGTV are building an awesome website for the community. Let's keep it open source and freely available so the guys always have access to it.

For those that don't know, LAGTV is the partnership of Adam (NovaWar) and Jeff (MaximusBlack). They have two YouTube channels and show various series about computer games. Their most famous series is "When Cheese Fails" which has the pair casting StarCraft II replays of lower league players failing while attempting to cheese their opponent - it's very funny.

Between the two channels there are well over 100,000 subscribers which make up the LAGTV community. This project is here to build a website for this community.

Useful Links
============

* [Launch Video](http://youtu.be/oDqLysmsONw)
* [Live Site](http://www.lag.tv)
* [Test Site](http://lagtv.andypike.com)
* [Discussion Group](http://groups.google.com/group/lagtv-website?hl=en)
* [Issue Tracker](https://github.com/andypike/lagtv/issues)

How you can help
================

Developers
----------

If you know Ruby on Rails then you can help. Just fork this repro then create a feature branch for your changes. Please do not add changes to the master branch. When you are done, send a pull request and the core team will review the changes and then merge into master.

Make sure your changes are covered by test. Pull requests without tests will be rejected.

We haven't tried setting up the development environment on Windows, but OSX and Linux will be fine. Here's how to get setup (Docker instructions below):

1. Install Ruby (we use RVM)
2. Install Postgresql (we use Homebrew)
3. Create a database called lagtv_development with a user called lagtv
4. Setup your config by copying the following and changing as required:
  1. ```$ cp config/database.example.yml config/database.yml```
  2. ```$ cp config/application.example.yml config/application.yml```
  3. ```$ cp config/newrelic.example.yml config/newrelic.yml```
5. Run ```$ bundle```
6. Run ```$ rake db:setup```
7. Start the webserver with ```$ rails s```
8. See the site running at http://localhost:3000
9. Run tests with ```$ rake```
10. Start guard for fast test running while developing with ```$ bundle exec guard```
11. Install redis via homebrew
12. Start redis with ```$ redis-server /usr/local/etc/redis.conf```
13. Start resque worker for emails with ```$ QUEUE=group_email rake environment resque:work```

Docker
------

1. Install Docker & Docker Compose
2. Run ```$ docker-compose up```
3. See the site running at http://localhost:3000

Once you are all setup, pick an issue from the current release (see below) and code away :smile:. If you are unsure of what to work on or need help setting up, post a message in the [discussion group](http://groups.google.com/group/lagtv-website?hl=en) and one of us will help you get started.

Testers
-------

Get on the [test site](http://lagtv.andypike.com) and try it out. If you find a problem, create issues [here in the github issue tracker](https://github.com/andypike/lagtv/issues). Don't worry about breaking anything, just do whatever you fancy. We'll reset the database from time to time on this server. Keep an eye of the [discussion group](http://groups.google.com/group/lagtv-website?hl=en) where we announce upgrades to the testing server with details of what has changed.

Designers
---------

Take a look at the website and if you feel the user interface could be improved in certain areas then create a mock up and post it in the [discussion group](http://groups.google.com/group/lagtv-website?hl=en). Once we have discussed and accepted it, you might be asked for some assets (probably just PSDs) while we add your design.

Everyone
--------

We are always on the look out for new ideas for improving the site. If you've spotted a problem, large or small, or you have a feature request you can [discuss it with the group](http://groups.google.com/group/lagtv-website?hl=en) first and then create an issue in the [issue tracker](https://github.com/andypike/lagtv/issues) for us to pick up.

Before creating a new issue, please check the existing issues list to make sure that it hasn't been reported already.

Releases
========

Release Planning
----------------

* We will gather feedback from the community and if its a new, valid issue we will add it to the issue tracker.
* After discussion between the dev team and Adam we will do one of the following:
   * Add the issue to the [backlog](https://github.com/andypike/lagtv/issues?milestone=5&page=1&state=open) if it's a possible candidate for the next release.
   * Add the issue to the [icebox](https://github.com/andypike/lagtv/issues?milestone=10&page=1&state=open) if we think it is worth doing but a longer term item.
   * Close the issue if we do not feel the issue is in scope.
* At the beginning of a release cycle, we will review the backlog and select a number of issues that should make up the next release.
* We will try to keep releases small but often.

Next Release
------------

The next release is [1.6.0](https://github.com/andypike/lagtv/issues?milestone=16&state=open)

Process
-------

Here's how releases will work in general.

* Developers can pick issues from the next release milestone to work on.
* At various points during the release we will upgrade the test site and announce it in the discussion group.
* Testers can review the changes and report issues.
* The developers will fix the issues until the milestone is complete and the testers are happy.
* We will ask Adam and Jeff to review the test site and give us approval to upgrade live.
* We will publish the changes in the discussion group and in the forum.

Change Log
----------

**1.5.3**

* Adds support for Hitbox stream notifications.

**[1.5.2](https://github.com/andypike/lagtv/issues?q=milestone%3A1.5.2+is%3Aclosed)**

* Changes NovaWar stream links to hitbox.tv

**[1.5.1](https://github.com/andypike/lagtv/issues?milestone=17&state=closed)**

* Fixes a bug with registration where the user passes the "human" test but some other fields failed validation.

**[1.5.0](https://github.com/andypike/lagtv/issues?milestone=15&state=closed)**

* During replay upload, open the file and read the patch version and game length for added info for Analysts
* Now automatically cleans old (uploaded more than 28 days ago) replay files everyday to free up disk space
* New replay status of "Downloaded" which is set if an Admin (Adam or Jeff) download a replay
* Moderators (and above) can now order the forum categories on the main forum page
* Analysts can now only comment once per replay
* Changed Machinima footer link to Polaris (TGS)
* Upgraded rails and other gems for security patches
* Some other minor bug fixes and improvements

**[1.4.0](https://github.com/andypike/lagtv/issues?milestone=13&state=closed)**

* Members can setup their own profile pages
* Logged in members can view other peoples profile pages
* Admins can manage profile player connect services
* Members can customise the url of their profile page
* Forums now have RSS feeds
* Members can report profile pages for inappropriate content
* Community Managers can change a members role to any level expect Admin

**[1.3.0](https://github.com/andypike/lagtv/issues?milestone=14&state=closed)**

* Added the new LAGTV stream notification and design
* Admins can send emails to a selected group of members by role
* Announcements are now fixed at the top of the page after scrolling
* Users that are deactivated are logged out of the site on their next request

**1.2.1**

* Upgraded rails to 3.2.11 due to critical security patch

**[1.2.0](https://github.com/andypike/lagtv/issues?milestone=12&state=closed)**

* Stream Notifications (update every 5 minutes - even if the browser is not refreshed)
* Replay comments can be edited by the author (CMs and Admins can also edit them)
* Replay list can be filtered to show replays without a rating
* Added HotS and WoL options when uploading a replay
* Improved email notifications from forum posts

**[1.1.0](https://github.com/andypike/lagtv/issues?milestone=11&state=closed)**

* Upgraded the forum to the latest version of the Forem engine.
* Multiple forum enhancements
* Added adverts to the site so it can start to pay for itself.
* Added site wide announcements
* Members can see what rating their replay has been given.
* Improved the replays list with more information for Analysts.
* Added Analysts stats to the list of users so.
* Changes SSL to only be enforced on the login, register and edit profile pages to reduce browser warnings.
* Multiple bug fixes.

**[1.0.2](https://github.com/andypike/lagtv/issues?milestone=9&page=1&state=closed)**

* Imposed a maximum height of 150px for signatures.
* Users can opt to hide all signatures in the forums if they prefer not to see them.
* Fixed some signature layout issues.
* Changed the site font to improve readability and workaround a Chrome rendering bug on Windows 7.

**[1.0.1](https://github.com/andypike/lagtv/issues?milestone=8&page=1&state=closed)**

* Site wide SSL for increased security (redirects to https if on http). Note: forum pages containing external images (not on https) may display a browser warning.
* The "My Profile" link has been replaced with the logged in username and avatar.
* Forum signatures now part of the users profile and added to all posts by that user. Admins and CMs can hide a users signature if required.
* Homepage "Latest Forum Activity" list now excludes support category posts and displays the relative date of the post.
* Registration captcha now accepts answers in digits and words.
* Added new "Dev Team" role for those people actively developing and supporting the website.
* Images in the forums now have a max width and height so they do not go outside the bounds.
* BUG FIX: Users can now updated their own profile without receiving a permissions error.

**1.0.0**

* Initial release

Thank you
=========

A big thank you to everyone that has helped with the site so far. It's been a great community effort and I know that Adam and Jeff are very happy with what we have done so far.

Bouse!
