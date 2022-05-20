# robocop: disable=wrong-case-in-keyword-name
*** Settings ***
Documentation  A simple test suite to demonstrate implicit context in BDD tests.
Resource  ImplicitContextLibrary/ImplicitContextKeywords.resource


*** Test Cases ***
The Implicit Context Library Can Refer to That Object
  [Documentation]  Tests that we can refer to a previous object as "that object"
  Given a new robotalk titled "Using Implicit Context"
  When that robotalk is complete
  Then there is a scattering of applause for that robotalk

The Implicit Context Library Can Refer to Objects By Position
  [Documentation]  Tests that we can refer to "the first robotalk" and "the last robotalk"
  Given a new robotalk titled "Using Implicit Context"
  And a new robotalk titled "Another Talk"
  When the first robotalk is complete
  Then there is a scattering of applause for the next-to-last robotalk
  And the last robotalk has not yet received applause

The Implicit Context Library Gives A Predictable Error Message When No That Object
  [Documentation]  Tests that we can determine error message for "that_object" for easy debugging
  Run Keyword And Expect Error  Variable '\${THAT_ROBOTALK}' not found.  That robotalk is complete

The Implicit Context Library Gives A Predictable Error Message When No Those Objects
  [Documentation]  Tests that we can determine error message for "those_objects" for easy debugging
  Run Keyword And Expect Error  Variable '\${THOSE_ROBOTALKS}' not found.  The first robotalk is complete

The Implicit Context Library Gives A Predictable Error Message When Not Enough Objects
  [Documentation]  Tests that we can determine error message for non existing indexed objects
  [Setup]  A new robotalk titled "Using Implicit Context"
  Run Keyword And Expect Error  IndexError: Given index 1 is out of the range 0-0.  The second robotalk is complete


*** Keywords ***
A new robotalk titled "${talk_title}"
  [Documentation]  Constructs a new robotalk object for later use
  [Tags]  out:that_robotalk
  ${a_robotalk}=  Create Robotalk  ${talk_title}
  Push Implicit Context  robotalk  ${a_robotalk}
  [Return]  ${a_robotalk}  # robocop: disable=deprecated-statement

That robotalk is complete
  [Documentation]  Sets the status of implicit that_robotalk to complete
  [Tags]  in:that_robotalk
  Set Robotalk Status  ${THAT_ROBOTALK}  COMPLETE

There is a scattering of applause for that robotalk
  [Documentation]  Fails if implicit that_robotalk object does not have applause
  [Tags]  in:that_robotalk
  Robotalk Should Have Applause  ${THAT_ROBOTALK}

The ${idx_name:first|second|third|fourth|fifth|last|next-to-last} robotalk is complete
  [Documentation]  Sets the status of implicit first/second/last/next-to-last robotalk to complete
  [Tags]  in:those_robotalks  out:that_robotalk
  ${a_robotalk}=  Get Implicit Context  robotalk  ${idx_name}
  Set Test Variable  $THAT_ROBOTALK  ${a_robotalk}
  Set Robotalk Status  ${a_robotalk}  COMPLETE

There is a scattering of applause for the ${idx_name:first|second|third|fourth|fifth|last|next-to-last} robotalk
  [Documentation]  Fails if implicit first/second/last/next-to-last robotalk does not have applause
  [Tags]  in:those_robotalks  out:that_robotalk
  ${a_robotalk}=  Get Implicit Context  robotalk  ${idx_name}
  Set Test Variable  $THAT_ROBOTALK  ${a_robotalk}
  Robotalk Should Have Applause  ${a_robotalk}

The ${idx_name:first|second|third|fourth|fifth|last|next-to-last} robotalk has not yet received applause
  [Documentation]  Fails if implicit first/second/last/next-to-last robotalk has received applause
  [Tags]  in:those_robotalks  out:that_robotalk
  ${a_robotalk}=  Get Implicit Context  robotalk  ${idx_name}
  Set Test Variable  $THAT_ROBOTALK  ${a_robotalk}
  Robotalk Should Not Have Applause  ${a_robotalk}

Robotalk Should Have Applause
  [Arguments]  ${a_robotalk}
  [Documentation]  Fails the test if the given robotalk does not have applause
  Dictionary Should Contain Key  ${a_robotalk}  applause
  Should Be True  ${a_robotalk['applause']}

Robotalk Should Not Have Applause
  [Arguments]  ${a_robotalk}
  [Documentation]  Fails the test if the given robotalk does have applause
  Dictionary Should Not Contain Key  ${a_robotalk}  applause

Create Robotalk
  [Arguments]  ${talk_title}
  [Documentation]  Creates a simple dictionary to represent a robocon talk
  ${a_robotalk}=  Create Dictionary  title=${talk_title}
  [Return]  ${a_robotalk}  # robocop: disable=deprecated-statement

Set Robotalk Status
  [Arguments]  ${a_robotalk}  ${new_status}
  [Documentation]  Sets the status of implicit that_robotalk; if complete, generates an applause property
  Set To Dictionary  ${a_robotalk}  status=${new_status}
  IF  "${new_status}"=="COMPLETE"
    Set To Dictionary  ${a_robotalk}  applause=${True}
  END
