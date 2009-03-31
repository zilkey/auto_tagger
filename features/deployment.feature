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
    When I run "cap staging deploy"
    Then the app should have the following tags:
      |name |
      |foo  |
      |foo  |
    And the "foo" tag should point to the same commit as the "bar" tag
  
  Scenario: Another user deploys
    Given an app
  