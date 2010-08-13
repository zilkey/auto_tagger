Feature: Deployment
  In order to get auto-tagging goodness on ci boxes
  As a ruby and git ninja
  I want to be able to easily create a tag from the command line with the same name format as the one created by the cap tasks

  Scenario: user runs autotag with no args
    Given a repo
    When I run autotag with no arguments
    And I should see "USAGE:"
    And no tags should be created
    And exit code should be 0

  Scenario: user runs autotag with "--help"
    Given a repo
    When I run autotag with "--help"
    And I should see "USAGE:"
    And no tags should be created
    And exit code should be 0

  Scenario: user runs autotag with "-h"
    Given a repo
    When I run autotag with "-h"
    And I should see "USAGE:"
    And no tags should be created
    And exit code should be 0

  Scenario: user runs autotag with "-?"
    Given a repo
    When I run autotag with "-?"
    And I should see "USAGE:"
    And no tags should be created
    And exit code should be 0

  @deprecated
  Scenario: user runs autotag with "demo"
    Given a repo
    When I run autotag with "demo"
    Then a "demo" tag should be created
    And exit code should be 0

  @deprecated
  Scenario: user runs autotag with "demo ."
    Given a repo
    When I run autotag with "demo"
    Then a "demo" tag should be created
    And exit code should be 0

  @deprecated
  Scenario: autotag cannot successfully complete
    Given a repo
    When I run autotag with "demo /no/such/path"
    Then I should see "Error occured:"
    And exit code should be 1
    And no tags should be created

  @deprecated
  Scenario: path is incorrect
    Given a repo
    When I run autotag with "create demo /no/such/path"
    Then I should see "Error occured:"
    And exit code should be 1
    And no tags should be created

  @1.0.0
  Scenario: user runs autotag with "help"
    Given a repo
    When I run autotag with "help"
    And I should see "USAGE:"
    And no tags should be created
    And the exit code should be 0

  @1.0.0
  Scenario: user runs autotag with "version"
    Given a repo
    When I run autotag with "version"
    And I should see "AutoTagger version"
    And no tags should be created
    And the exit code should be 0

  @1.0.0
  Scenario: user runs autotag with "create demo . --date-separator -"
    Given a repo
    When I run autotag with "create demo --date-separator -"
    Then a hyphen-delimited "demo" tag should be created
    And the exit code should be 0
