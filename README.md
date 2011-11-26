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

-   All deployment (and even much of the configuration) handled automatically by [Capistrano](https://github.com/capistrano/capistrano/)
-   Track page views with [Google Analytics](http://google.com/analytics)
-   Source well-documented using [Yard](http://yardoc.org)
-   Continuous integration support with [Travis](http://travis-ci.org/)
-   Baked-in support for error reporting using [Airbrake](http://airbrake.io/) (account registration required)


## Installation ##

### Install and configure Solr ###

You will need to install and set up Solr yourself before you begin.  RLetters provides snippets from both `schema.xml` and `solrconfig.xml` in the `contrib/solr` directory, which define the document schema and the request handlers that are used by RLetters.  Of course, you are welcome to add, edit, or change these as necessary.

### Install infrastructure ###

We'll assume for these instructions that you know how to [install Ruby on Rails](http://guides.rubyonrails.org/getting_started.html) and get a Rails application up and running on your local web server.  You'll need, at the very least, to have installations of (i) some web server or other, (ii) Ruby, and (iii) MySQL.  Since deployments are best handled through Capistrano (and this README will assume you're using it), you should also have git on this server.

Copy the file `config/deploy/deploy_config.rb.dist` to `config/deploy/deploy_config.rb` and edit the variables found within it to match your server configuration.

Begin the deployment and configuration process by executing `cap deploy:setup`.  The deployment setup will ask you a host of questions about your setup, including your database passwords, the name of your application, and your IDs and keys for various third-party services.  Read on to see what all those are about.  If you need to edit the files created by the `deploy:setup` task, they may be found on your server at `DEPLOY_PATH/shared/config/app_config.yml` and `DEPLOY_PATH/shared/config/database.yml`.

Alternatively (and especially if you wish to set up multiple servers) you can skip these two steps by executing either `cap deploy:setup -S "skip_config_setup=true"` or `cap deploy:setup -S "skip_db_setup=true"`.  You can then set up the files in `DEPLOY_PATH/shared/config` manually.

### The configuration prompts ###

-   MySQL database root password: The root password to your MySQL database.  (FIXME: Eventually we will have support for users other than root.)
-   Friendly application name: The user-friendly name of your application.
-   Developer e-mail: The e-mail address to which bug reports and such should be sent.
-   Application domain: The domain name at which your application is published.
-   Janrain settings: User login for RLetters uses the external [Janrain Engage](http://www.janrain.com/products/engage) service, which allows users to log in through Google, Facebook, LinkedIn, and a number of other third-party services.  For user login to work properly, you will need to create a Janrain Engage account at their website (free for less than 2,500 users per year, which should be more than enough for an academic resource like RLetters).  Once you've created an account, click "Sign-In for Websites" on the right-hand side, and configure your login widget.  Under "Application Settings," make sure to add your deployment URL to the Domain Whitelist.  Add a link to your privacy policy ((YOUR URL)/info/privacy), and your favicon.
    -   Janrain application name: The subdomain under "Application Domain" in your Engage settings (e.g., for rletters.rpxnow.com, the application name is `rletters`).
    -   Janrain application ID: The "App ID" in your Engage settings.
    -   Janrain secret: The "API Key (Secret)" in your Engage settings.
-   Mendeley key: If you would like your users to be able to search for document results on [Mendeley](http://www.mendeley.com), you will need to visit the [Mendeley Developers Portal](http://dev.mendeley.com) and register your application.  This setting is the value of your "Consumer Key".
-   Airbrake key: If you have an [Airbrake](http://airbrake.io/) account, this is your Airbrake API key (available under "Edit this Project" in the Airbrake main window).
-   Solr server path: The http path to the Solr server (from the deployment server, e.g. `http://localhost:8080/solr`).

### Finish deployment ###

All right, you now have the configuration set up for your new RLetters server.  Check things over by executing `cap deploy:check`.  If all goes well, push the code to the server with `cap deploy:update`.  If you have not yet created a production database, SSH over to the server, change into the `DEPLOY_PATH/current` directory and execute `rake RAILS_ENV=production db:schema:load`.  **DO NOT DO THIS** if you already have a database, as it **WILL WIPE YOUR PRODUCTION DATA.**  (In particular, you don't need to do this if you're upgrading.)

Finally, execute `cap deploy:start` and fire up your new RLetters installation in a browser.  If all is good, you're ready to move on to the final customization steps.

### Customize some static content ###

The only thing remaining is to customize some static content -- images and text -- that is shipped with RLetters.  First, several files have some long-format text about your application that you'll want to customize.

-   `app/views/info/_privacy_short.markdown` and `app/views/info/_privacy_long.markdown`:  We've filled this in with a pretty good default privacy policy for the default settings of RLetters.  If you change the way that you interact with your users, you should update this privacy policy.
-   `app/views/datasets/_no_datasets.markdown`: This message is displayed to users when they log in for the first time (and don't have any datasets).  You'll want to customize it to tell users a little more about your application.

Now you've got some images to customize.  You can start by copying the `shared_assets` directory from the RLetters `contrib` directory over to your server.  This directory should be located at `DEPLOY_PATH/shared/static_assets`, and it contains the following images:

-   `static_assets/error-watermark.png`: This is an image shown in the bottom-left corner of the site's error pages.  Something like 500x300 pixels is a good size for this image.
-   Now, the iOS splash images and icons:
    -   `static_assets/h/apple-touch-icon.png`: 114x114 pixel iOS application icon.  This is used on Retina Display-capable iPhones.
    -   `static_assets/m/apple-touch-icon.png`: 72x72 pixel iOS application icon.  This is used on the iPad.
    -   `static_assets/l/apple-touch-icon.png` and `l/apple-touch-icon-precomposed.png`: 57x57 pixel iOS application icon.  This is used on low-resolution iPhone and iPod Touch devices.
    -   `static_assets/h/splash.png`: 768x1004 splash screen, displayed while loading the app on retina-display iPhone devices.
    -   `static_assets/l/splash.png`: 320x460 splash screen, displayed while loading the app on low-resolution iPhone and iPod Touch devices.
-   Finally, `static_assets/favicon.ico`, the standard favorite icon.

These static assets will be automatically connected when you deploy.  To make sure they are active, you should perform another `cap deploy` now.

That's it!  You've successfully configured a new RLetters installation, and even personalized it a bit to make it your own.


## Contributors ##

Special thanks to all contributors for submitting patches. A full list of
contributors including their patches can be found at: 

https://github.com/cpence/rletters/contributors


## Copyright ##

RLetters &copy; 2011 by [Charles Pence](mailto:charles@charlespence.net). RLetters is licensed under the MIT license. Please see the {file:COPYING} document for more information.

