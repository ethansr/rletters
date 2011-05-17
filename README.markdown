
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

RLetters is licensed under the [MIT License](http://www.opensource.org/licenses/mit-license.php):

> RLetters, Copyright (c) 2011 Charles Pence and University of Notre Dame
> 
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
> 
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
