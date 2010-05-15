Feature: Deployment
  In order to get auto-tagging goodness on ci boxes
  As a ruby and git ninja
  I want to be able to easily create a tag from the command line with the same name format as the one created by the cap tasks

  Scenario: user runs autotag with no args
    Given a repo
    When I run autotag with no arguments
    Then the exit code should be "0"
    And I should see "USAGE:"
    And no tags should be created

  Scenario: user runs autotag with "--help"
    Given a repo
    When I run autotag with "--help"
    Then the exit code should be "0"
    And I should see "USAGE:"
    And no tags should be created

  Scenario: user runs autotag with "-h"
    Given a repo
    When I run autotag with "-h"
    Then the exit code should be "0"
    And I should see "USAGE:"
    And no tags should be created

  Scenario: user runs autotag with "-?"
    Given a repo
    When I run autotag with "-?"
    Then the exit code should be "0"
    And I should see "USAGE:"
    And no tags should be created

  Scenario: user runs autotag with "demo"
    Given a repo
    When I run autotag with "demo"
    Then the exit code should be "0"
    And a "demo" tag should be created

  Scenario: user runs autotag with "demo ."
    Given a repo
    When I run autotag with "demo"
    Then the exit code should be "0"
    And a "demo" tag should be created

  Scenario: user runs autotag with a non-existant
    Given a repo
    When I run autotag with "foobarbaz asdfasdf"
    Then the exit code should be "1"
    And no tags should be created
