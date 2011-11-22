# RLetters #

[![Still Maintained][sm_img]][sm] [![Build Status][travis_img]][travis]

[sm]: http://stillmaintained.com/cpence/rletters
[sm_img]: http://stillmaintained.com/cpence/rletters.png
[travis]: http://travis-ci.org/cpence/rletters
[travis_img]: http://travis-ci.org/cpence/rletters.png

**Homepage:** [http://charlespence.net/rletters](http://charlespence.net/rletters})  
**Git:** [http://github.com/cpence/rletters](http://github.com/cpence/rletters)  
**Author:** Charles Pence  
**Contributors:** See Contributors section below  
**Copyright:** 2011  
**License:** MIT License  
**Latest Version:** (still in private beta)  
**Release Date:** (still in private beta)  


## Features ##

### Support for web and library standards ###

RLetters provides support for the following web and library standards:

-   [unAPI](http://unapi.info) for automatic bibliographic data retrieval from individual documents
-   [WorldCat OpenURL Registry](http://www.oclc.org/developer/services/worldcat-registry) for detection of the OpenURL resolver of the user's local library

And you can export bibliographic data in the following standard formats:

-   [MARC 21 transmission format](http://www.loc.gov/marc/)
-   [MARCXML](http://www.loc.gov/standards/marcxml/)
-   [MARC-JSON (draft)](http://www.oclc.org/developer/content/marc-json-draft-2010-03-11)
-   [MODS](http://www.loc.gov/standards/mods/)
-   [RDF/XML](http://www.w3.org/TR/rdf-syntax-grammar/) (using [Dublin Core Grammar](http://dublincore.org/documents/dc-citation-guidelines/))
-   [RDF/N3](http://www.w3.org/DesignIssues/Notation3.html) (using [Dublin Core Grammar](http://dublincore.org/documents/dc-citation-guidelines/))
-   [BibTeX](http://www.ctan.org/pkg/bibtex)
-   [EndNote (ENW format)](http://www.endnote.com/)
-   [Reference Manager (RIS format)](http://www.refman.com/support/risformat_intro.asp)

### Cutting-edge development and maintenance tools ###

RLetters doesn't leave your developers out in the cold, either.  We've got support for the following features that make development, deployment, maintenance, and monitoring easier:

-   Source well-documented using [Yard](http://yardoc.org)
-   Continuous integration support with [Travis](http://travis-ci.org/)
-   Baked-in support for error reporting using [Airbrake](http://airbrake.io/) (account registration required)


## Installation ##

### Install and configure Solr ###

You will need to install and set up Solr yourself before you begin.  RLetters provides snippets from both `schema.xml` and `solrconfig.xml` in the `contrib/solr` directory, which define the document schema and the request handlers that are used by RLetters.  Of course, you are welcome to add, edit, or change these as necessary.

### Install Rails and some gems ###

We'll assume for these instructions that you know how to [install Ruby on Rails](http://guides.rubyonrails.org/getting_started.html) and get a Rails application up and running on your local web server.  Install the various gems required for RLetters by executing `bundle install`.

### Get delayed_job running ###

You now need to ensure that the `delayed_job` daemon is started with your other server executables.  In the `contrib/delayed_job` directory you will find a sample init.d script (for Ubuntu-based systems) and a snippet from a Monit configuration file for running the delayed_job daemon.

### Set up some configuration files ###

Set up the required configuration files:

-   Copy `config/database.yml.dist` to `config/database.yml`, and edit it to point to your database.
-   Copy `config/app_config.yml.dist` to `config/app_config.yml`, and edit it to include your application's details.

User login for RLetters uses the external [Janrain Engage](http://www.janrain.com/products/engage) service, which allows users to log in through Google, Facebook, LinkedIn, and a number of other third-party services.  For user login to work properly, you will need to create a Janrain Engage account at their website (free for less than 2,500 users per year, which should be more than enough for an academic resource like RLetters).  Once you've created an account, click "Sign-In for Websites" on the right-hand side, and configure your login widget.  Under "Application Settings," make sure to add your deployment URL to the Domain Whitelist.  Add a link to your privacy policy ((YOUR URL)/info/privacy), and your favicon.  Now open `config/app_config.yml`.  The value for `janrain_appname` is the subdomain under Application Domain (e.g., for rletters.rpxnow.com, the `janrain_appname` is `rletters`).  Copy the value for "App ID" as `janrain_appid`, and the value for "API Key (Secret)" as `janrain_secret`.

If you would like your users to be able to search for document results on [Mendeley](http://www.mendeley.com), you will need to visit the [Mendeley Developers Portal](http://dev.mendeley.com) and register your application.  Take the value of your "Consumer Key" and paste it into `config/app_config.yml` as `mendeley_key`.

If you have an [Airbrake](http://airbrake.io/) account, take your Airbrake API key (available under "Edit this Project" in the Airbrake main window) and copy its value into `config/app_config.yml` as `airbrake_key`.

Obviously, make sure to secure your `config/app_config.yml` file.

### Customize some static content ###

Several files have some long-format text about your application that you'll want to customize.

-   `app/views/info/_privacy_short.markdown` and `app/views/info/_privacy_long.markdown`:  We've filled this in with a pretty good default privacy policy for the default settings of RLetters.  If you change the way that you interact with your users, you should update this privacy policy.
-   `app/views/datasets/_no_datasets.markdown`: This message is displayed to users when they log in for the first time (and don't have any datasets).  You'll want to customize it to tell users a little more about your application.

Now you've got some images to customize.

-   `app/assets/images/error-watermark.png`: This is an image shown in the bottom-left corner of the site's error pages (as well as the page shown to web-app users when they attempt to access RLetters without an internet connection).  Something like 500x300 pixels is a good size for this image.
-   Now, the iOS splash images and icons:
    -   `images/h/apple-touch-icon.png`: 114x114 pixel iOS application icon.  This is used on Retina Display-capable iPhones.
    -   `images/m/apple-touch-icon.png`: 72x72 pixel iOS application icon.  This is used on the iPad.
    -   `images/l/apple-touch-icon.png` and `l/apple-touch-icon-precomposed.png`: 57x57 pixel iOS application icon.  This is used on low-resolution iPhone and iPod Touch devices.
    -   `images/h/splash.png`: 768x1004 splash screen, displayed while loading the app on retina-display iPhone devices.
    -   `images/l/splash.png`: 320x460 splash screen, displayed while loading the app on low-resolution iPhone and iPod Touch devices.
-   Finally, `public/favicon.ico`, the standard favorite icon.

## Contributors ##

Special thanks to all contributors for submitting patches. A full list of
contributors including their patches can be found at: 

https://github.com/cpence/rletters/contributors

## Copyright ##

RLetters &copy; 2011 by [Charles Pence](mailto:charles@charlespence.net). RLetters is licensed under the MIT license. Please see the {file:LICENSE} document for more information.

