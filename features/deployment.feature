# create keys between the users on this machine
Feature: Deployment
  In order to get auto-tagging goodness
  As a ruby and git ninja
  I want cap to do all the work for me

  Scenario: user deploys
    Given an app
    And the app has the following tags:
      |name |
      |foo  |
      |foo  |
    And the app has the following stages:
      |stage      |
      |ci         |
      |staging    |
      |production |
    And the app has the following environments:
      |environments |
      |staging      |
      |production   |
    And the following callbacks
      |callback |arg1               |arg2                               |
      |before   |deploy:update_code |release_tagger:set_branch          |
      |after    |deploy             |release_tagger:create_tag          |
      |after    |deploy             |release_tagger:write_tag_to_shared |
      |after    |deploy             |release_tagger:print_latest_tags   |
    When I run "cap staging deploy"
    Then the app should have the following tags:
      |name |
      |foo  |
      |foo  |
    And the "foo" tag should point to the same commit as the "bar" tag
  
  # Scenario: Another user deploys
  #   Given an app
  