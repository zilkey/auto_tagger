Feature: Deployment
  In order to get auto-tagging goodness
  As a ruby and git ninja
  I want cap to do all the work for me

  Scenario: user deploys with single file deploy.rb
    Given a three-stage app using single deploy file
    And a ci tag
    When I deploy to staging
    Then a tag should be added to git
    
  Scenario: user deploys with cap-ext multistage
    Given a three-stage app using cap-multistage
    And a ci tag
    When I deploy to staging
    Then a tag should be added to git