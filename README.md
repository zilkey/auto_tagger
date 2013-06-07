# IMPORTANT NOTE

This creates and pushes tags to your git repository, please use with caution.

# AutoTagger

[![Build Status](https://secure.travis-ci.org/zilkey/auto_tagger.png)](http://travis-ci.org/zilkey/auto_tagger)

(build is currently failing because of SSH issues on the Travis machine - but `rake` should pass for you locally).

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

Installing the gem creates an executable file named autotag, which takes the stage, optionally the path to the git repo, and options:

    $ autotag create demo  # => creates a tag like demo/200804041234 in the current directory
    $ autotag create demo . # => same as above
    $ autotag create demo /Users/me/foo # => cd's to /Users/me/foo before creating the tag

By default, running autotag does the following:

    $ git fetch origin refs/tags/*:refs/tags/*
    $ git update-ref refs/tags/demo/20100910051459 1242b283208d06661b2a916097c41c046510af68
    $ git push origin refs/tags/*:refs/tags/*

The autotag executable has the following commands:

    help
    version
    create STAGE
    list STAGE
    cleanup STAGE
    delete_locally STAGE
    delete_on_remote STAGE

The autotag executable accepts the following options:

    --date-separator - the character used to separate parts of the timestamp
    --fetch-refs - whether to fetch refs before creating or listing them
    --push-refs - whether to push refs after creating them
    --remote - specify a custom remote (defaults to "origin")
    --ref-path - use a different ref directory, other than "tags"
    --stages - specify all of the stages
    --offline - don't push or fetch refs (is ignored with delete_on_remote command)
    --dry-run - don't execute anything, but print the commands
    --verbose - prints all commands as they run
    --refs-to-keep - when using any clean commans, specify how many refs to keep
    --executable - specify the full path to the git executable
    --opts-file - the location of a custom options file

## Capistrano Integration

AutoTagger comes with 2 capistrano tasks: 

  * `auto_tagger:set_branch` tries to set the branch to the last tag from the previous environment.
  * `auto_tagger:create_ref` runs autotag for the current stage

Example `config/deploy.rb` file:

    require 'auto_tagger/recipes'

    # The :auto_tagger_stages variable is required
    set :auto_tagger_stages, [:ci, :staging, :production]

    # The :working_directory variable is optional, and defaults to Dir.pwd
    # :working_directory can be an absolute or relative path
    set :auto_tagger_working_directory, "../../"

    task :production do
      # In each of your environments that need auto-branch setting, you need to set :auto_tagger_stage
      set :auto_tagger_stage, :production
    end

    task :staging do
      # If you do not set stage, it will not auto-set your branch
      # set :auto_tagger_stage, :staging
    end

    # You need to add the before/ater callbacks yourself
    before "deploy:update_code", "auto_tagger:set_branch"
    after  "deploy", "auto_tagger:create_ref"
    after  "deploy", "auto_tagger:print_latest_refs"

### Capistano-ext multistage support

If you use capistano-ext multistage, you can use auto_tagger.

    set :auto_tagger_stages, [:ci, :staging, :production]
    set :stages, [:staging, :production]
    set :default_stage, :staging
    require 'capistrano/ext/multistage'

When you deploy, auto_tagger will auto-detect your current stage.

You can specify the following capistrano variables that correspond to the autotag options:

    :auto_tagger_date_separator
    :auto_tagger_push_refs
    :auto_tagger_fetch_refs
    :auto_tagger_remote
    :auto_tagger_ref_path
    :auto_tagger_offline
    :auto_tagger_dry_run
    :auto_tagger_verbose
    :auto_tagger_refs_to_keep
    :auto_tagger_executable
    :auto_tagger_opts_file
    :auto_tagger_working_directory

### auto_tagger:set_branch

This task sets the git branch to the latest tag from the previous stage.  Assume you have the following tags in your git repository:

  * ci/01
  * staging/01
  * production/01

And the following stages in your capistrano file:

    set :auto_tagger_stages, [:ci, :staging, :production]

The deployments would look like this:

    cap staging auto_tagger:set_branch    # => sets branch to ci/01
    cap production auto_tagger:set_branch # => sets branch to staging/01

You can override with with the -Shead and -Stag options

    cap staging auto_tagger:set_branch -Shead=true      # => sets branch to master
    cap staging auto_tagger:set_branch -Stag=staging/01 # => sets branch to staging/01

If you add `before "deploy:update_code", "auto_tagger:set_branch"`, you can just deploy with:

    cap staging deploy
    
and the branch will be set for you automatically.

### auto_tagger:create_ref

This cap task creates a new tag, based on the latest tag from the previous environment.  

If there is no tag from the previous stage, it creates a new tag from the latest commit in your _working directory_.

If you don't specify any `auto_tagger_stages`, auto_tagger will create a tag that starts with "production".

### auto_tagger:print_latest_refs

This task takes the latest tag from each environment and prints it to the screen.  You can add it to your deploy.rb like so:

    after  "deploy", "auto_tagger:print_latest_refs"

Or call it directly, like:

    cap production auto_tagger:print_latest_refs
    
This will produce output like:

    ** AUTO TAGGER: release tag history is:
     ** ci         ci/20090331045345              8031807feb5f4f99dd83257cdc07081fa6080cba some commit message
     ** staging    staging/20090331050908         8031807feb5f4f99dd83257cdc07081fa6080cba some commit message
     ** production production/20090331050917      8031807feb5f4f99dd83257cdc07081fa6080cba some commit message

## Configuration

You can store options in an options file, which is .auto_tagger by default.  You can set options in this file like so:

    --date-separator=-
    --ref-path=autotags
    --refs-to-keep=5

## Testing

### Setup

1. Authorize your local SSH keys to access your local machine:

   ```sh
   ./script/configure-ssh-localhost.sh
   ```

   To verify, you should be able to connect to localhost without supplying a password:

   ```sh
   ssh localhost
   ```

2. Install bundler:

   ```sh
   gem install bundler
   ```

3. Install the project's bundle:

   ```sh
   bundle install
   ```

### Running

To run the entire suite:

    rake

To run individual test suites:

    rake spec
    rake features

## Releasing

  * run `rake` and make sure that things are green
  * update the changelog to say what you've done
  * update the version
  * commit your changes
  * run `rake build`
  * run `rake install` and then open the gem and make sure everything looks ok
  * run `rake release`

## Acknowledgments

Special thanks to:

 * Brian Takita for the original recipes
 * Mike Dalessio for his git fu
 * Chad Wooley for his feature ideas
 * Tim Holahan for his QA
 * Pat Nakajima for making auto_tagger a better ruby citizen
 * Josh Susser for recommending the date format changes

## Links

 * http://codeintensity.blogspot.com/2008/06/changelogs-and-deployment-notification.html
  
Copyright (c) 2009 [Jeff Dean], released under the MIT license
