# AutoTagger

AutoTagger allows you to create a date-stamped tag for each stage of your deployment, and deploy from the last tag from the previous environment.

Let's say you have the following workflow:

 * Run all test on a Continuous Integration (CI) server
 * Deploy to a staging server
 * Deploy to a production server

You can use the `autotag` command to tag releases on your CI box, then use the capistrano tasks to auto-tag each release.

## Capistrano Integration

Example deploy file:

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

    cap staging deploy    # => ci/01
    cap production deploy # => staging/01

You can override with with the -Shead and -Stag options

    cap staging deploy -Shead=true      # => master
    cap staging deploy -Stag=staging/01 # => staging/01

## The autotag executable

    autotag -h
    autotag demo
    autotag demo .
    autotag demo /Users/me/foo

## Known Issues

  * DOES NOT work with capistrano ext multi-stage
  * It will accept invalid tag names (if you specify a tag name with a space, it will blow up when you try to create the tag)

## Things that might be useful

  * Make it possible to define a different remote other than "origin"
  * Make it possible to define a different default branch other than "master"
  * Make it work with either cap-ext multistage or single-file deploy.rb files
  * Make it possible to provide your own tag naming convention (like the PaperClip string interpolation), instead of relying on <prefix>/<timestamp>

## Links

 * http://codeintensity.blogspot.com/2008/06/changelogs-and-deployment-notification.html
  
Copyright (c) 2009 [Jeff Dean], released under the MIT license
