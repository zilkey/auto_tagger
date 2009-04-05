# create keys between the users on this machine
Feature: Deployment
  In order to get auto-tagging goodness
  As a ruby and git ninja
  I want cap to do all the work for me

  Scenario: user deploys
    Given a three-stage app
    And a ci tag
    When I deploy
    Then a tag should be added to git