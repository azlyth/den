den
===

A really simple static-site generator.

## Getting started

### Requirements
Ruby and some Debian-based system (for now).

### Installation

Install the gem from RubyGems,

    gem install den

and then start a new instance of Den.

    den new site myblog

This will create a new directory called 'myblog' that will hold the contents of your Den instance.

### Configuration

Edit config.yml inside your new Den instance, and make sure that the site's root folder reflects the directory that your web server will serve your site from.

    cd myblog
    vim config.yml

## Usage
Note that all commands must be run from the root directory of their Den instance ('myblog/' in the above case). Additionally, all posts and pages use Den's template notation.

### Posts
To create a new post using your system's default editor:

    den new post

Save and quit when done writing up the post, and it will be added to the site.

You can also use a file as the new post:

    den new post <filename>
    
To delete a post by ID:

    den delete post <id>

### Pages
To create a new page using your system's default editor:

    den new page <page_name>
    
The page name is how the page will be accessed on your site (e.g. example.com/<page_name>).

You can also use a file as the new page:

    den new page <page_name> <filename>

To delete a page by ID:

    den delete page <id>

### Display content
To print out all the content currently in a Den instance:

    den list

This will display each page and post, along with it's ID and other relevant metadata.