
Installation and Setup
======================

Install Rails and the RLetters bundle
-------------------------------------

Configure Rails [in the usual manner,](http://guides.rubyonrails.org/getting_started.html) and check out a copy of RLetters.  Install the required gems for RLetters using `bundle install`.

Set up a Solr server
--------------------

Install Solr, using the schema provided at `solr/schema.xml`.  You may then populate the Solr database in the usual manner, sending documents formatted like the sample document provided at `solr/sample-document.xml`.  (In the sample document, the `fulltext` attribute is merely the abstract of the given article; you will want to replace this with the proper full-text of the document.)

Customize application configuration
-----------------------------------

Copy the default configuration file from `config/config.yml.dist` to `config/config.yml` and edit it.  Modify the various variables to point to the URL of your Solr server, the various application name variables, and (optionally) a Google Analytics account and a [Mendeley Consumer API Key.](http://dev.mendeley.com/)

Customize the static content
----------------------------

For each of the following files, copy them from `<filename>.dist` to `<filename>`, replacing their content with content appropriate for your application.  You may also localize these static content files by making copies of, for example, `index.html.markdown` to `index.es.html.markdown`, `index.de.html.markdown`, and so on.

-   `views/about/index.html.markdown.dist`: The "about us" page, linked from a button at the top of the homepage.

Ready to go!
------------

Now you’re ready to roll!


License
=======

RLetters is licensed under the [GNU General Public License](http://www.gnu.org/licenses/gpl.html):

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
