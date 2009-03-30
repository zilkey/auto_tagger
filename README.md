# AutoTagger

AutoTagger is a gem that helps you automatically create a date-stamped tag for each stage of your deployment, and deploy from the last tag from the previous environment.

Let's say you have the following workflow:

 * Run all test on a Continuous Integration (CI) server
 * Deploy to a staging server
 * Deploy to a production server

You can use the `autotag` command to tag releases on your CI box, then use the capistrano tasks to auto-tag each release.

## Installation

    gem sources -a http://gems.github.com
    sudo gem install zilkey-auto_tagger

## Contribute

    [Tracker Project](http://www.pivotaltracker.com/projects/11988)
    [GitHub Repository](http://github.com/zilkey/auto_tagger/tree/master)

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

    require 'release_tagger'

    # The :stages variable is required
    set :stages, [:ci, :staging, :production]

    # The :working_directory variable is optional, and defaults to Dir.pwd
    # :working_directory can be an absolute or relative path
    set :working_directory, "../../"

    task :production do
      # In each of your environments that need auto-branch setting, you need to set :current_stage
      set :current_stage, :production
    end

    task :staging do
      # If you do not set current_stage, it will not auto-set your branch
      # set :current_stage, :staging
    end

    # You need to add the before/ater callbacks yourself
    before "deploy:update_code", "release_tagger:set_branch"
    after  "deploy", "release_tagger:create_tag"

Assume you have the following tags in your git repository:

  * ci/01
  * staging/01
  * production/01

The deployments would look like this:

    cap staging deploy    # => sets branch to ci/01
    cap production deploy # => sets branch to staging/01

You can override with with the -Shead and -Stag options

    cap staging deploy -Shead=true      # => sets branch to master
    cap staging deploy -Stag=staging/01 # => sets branch to staging/01

## Links

 * http://codeintensity.blogspot.com/2008/06/changelogs-and-deployment-notification.html
  
Copyright (c) 2009 [Jeff Dean], released under the MIT license
