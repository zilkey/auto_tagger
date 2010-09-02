Feature: Deployment
  In order to get auto-tagging goodness
  As a ruby and git ninja
  I want cap to do all the work for me

  @0.1.5
  Scenario: user deploys with single file deploy.rb with 3 stages
    Given a three-stage app using single deploy file
    And a ci tag
    When I deploy to staging
    Then a tag should be added to git

  @0.1.5
  Scenario: user deploys with single file deploy.rb with no stages
    Given a one-stage app using single deploy file with the following environments:
      |production  |
    When I deploy
    Then a "production" tag should be added to git

  @0.1.5
  Scenario: user deploys with single file deploy.rb stages with dashes in the name
    Given a one-stage app using single deploy file with the following environments:
      |staging            |
      |secret-production  |
    When I deploy to secret-production
    Then a "secret-production" tag should be added to git

  @0.1.5
  Scenario: user deploys with cap-ext multistage
    Given a three-stage app using cap-multistage
    And a ci tag
    When I deploy to staging
    Then a tag should be added to git
