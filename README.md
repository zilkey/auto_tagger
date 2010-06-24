# IMPORTANT NOTE

This creates and pushes tags to your git repository, please use with caution.

# AutoTagger

AutoTagger is a gem that helps you automatically create a date-stamped tag for each stage of your deployment, and deploy from the last tag from the previous environment.

Let's say you have the following workflow:

 * Run all test on a Continuous Integration (CI) server
 * Deploy to a staging server
 * Deploy to a production server

You can use the `autotag` command to tag releases on your CI box, then use the capistrano tasks to auto-tag each release.

## Installation

    sudo gem install auto_tagger

## Contribute

  * [GitHub Repository](http://github.com/zilkey/auto_tagger/tree/master)

## The autotag executable

Installing the gem creates an executable file named autotag, which takes two arguments: the stage, and optionally the path to the git repo:

    $ autotag demo  # => creates a tag like demo/200804041234 in the current directory
    $ autotag demo . # => same as above
    $ autotag demo /Users/me/foo # => cd's to /Users/me/foo before creating the tag

Running autotag does the following:

    $ git fetch origin --tags
    $ git tag <stage>/<timestamp>
    $ git push origin --tags

## Capistrano Integration

AutoTagger comes with 2 capistrano tasks: 

  * `release_tagger:set_branch` tries to set the branch to the last tag from the previous environment.
  * `release_tagger:create_tag` runs autotag for the current stage

Example `config/deploy.rb` file:

    require 'auto_tagger/recipes'

    # The :autotagger_stages variable is required
    set :autotagger_stages, [:ci, :staging, :production]

    # The :working_directory variable is optional, and defaults to Dir.pwd
    # :working_directory can be an absolute or relative path
    set :working_directory, "../../"

    task :production do
      # In each of your environments that need auto-branch setting, you need to set :stage
      set :stage, :production
    end

    task :staging do
      # If you do not set stage, it will not auto-set your branch
      # set :stage, :staging
    end

    # You need to add the before/ater callbacks yourself
    before "deploy:update_code", "release_tagger:set_branch"
    after  "deploy", "release_tagger:create_tag"
    after  "deploy", "release_tagger:write_tag_to_shared"
    after  "deploy", "release_tagger:print_latest_tags"

### Cpistano-ext multistage support

If you use capistano-ext multistage, you can use auto_tagger.

    set :autotagger_stages, [:ci, :staging, :production]
    set :stages, [:staging, :production]
    set :default_stage, :staging
    require 'capistrano/ext/multistage'

When you deploy, autotagger will auto-detect your current stage.

### release_tagger:set_branch

This task sets the git branch to the latest tag from the previous stage.  Assume you have the following tags in your git repository:

  * ci/01
  * staging/01
  * production/01

And the following stages in your capistrano file:

    set :autotagger_stages, [:ci, :staging, :production]

The deployments would look like this:

    cap staging release_tagger:set_branch    # => sets branch to ci/01
    cap production release_tagger:set_branch # => sets branch to staging/01

You can override with with the -Shead and -Stag options

    cap staging release_tagger:set_branch -Shead=true      # => sets branch to master
    cap staging release_tagger:set_branch -Stag=staging/01 # => sets branch to staging/01

If you add `before "deploy:update_code", "release_tagger:set_branch"`, you can just deploy with:

    cap staging deploy
    
and the branch will be set for you automatically.

### release_tagger:create_tag

This cap task creates a new tag, based on the latest tag from the previous environment.  

If there is no tag from the previous stage, it creates a new tag from the latest commit in your _working directory_.

If you don't specify any `autotagger_stages`, autotagger will create a tag that starts with "production".

### release_tagger:print_latest_tags

This task reads the git version from the text file in shared:

    cap staging release_tagger:read_tag_from_shared

### release_tagger:print_latest_tags

This task takes the latest tag from each environment and prints it to the screen.  You can add it to your deploy.rb like so:

    after  "deploy", "release_tagger:print_latest_tags"

Or call it directly, like:

    cap production release_tagger:print_latest_tags
    
This will produce output like:

    ** AUTO TAGGER: release tag history is:
     ** ci         ci/20090331045345              8031807feb5f4f99dd83257cdc07081fa6080cba some commit message
     ** staging    staging/20090331050908         8031807feb5f4f99dd83257cdc07081fa6080cba some commit message
     ** production production/20090331050917      8031807feb5f4f99dd83257cdc07081fa6080cba some commit message

## Running tests:

You must be able to ssh into your box via localhost (remote login).  To make this easier, add your own key to your own account:

    cat ~/.ssh/id_rsa.pub >>~/.ssh/authorized_keys
    
To ensure that this has worked, try this:

    ssh localhost
    
If it asks you for a password, you've done something wrong.

To run the specs, execute:

    spec spec/
    
To run the cucumber features, execute:

    cucumber features/

## Acknowledgments

Special thanks to:

 * Brian Takita for the original recipes
 * Mike Dalessio for his git fu
 * Chad Wooley for his feature ideas
 * Tim Holahan for his QA
 * Pat Nakajima for making auto_tagger a better ruby citizen

## Links

 * http://codeintensity.blogspot.com/2008/06/changelogs-and-deployment-notification.html
  
Copyright (c) 2009 [Jeff Dean], released under the MIT license
