1. [x] Create a flutter DrawingLog app with a login screen that has a text field for the user to enter their email and a text field for the user to enter their password. Add a button that the user needs to press to submit their login info in order to login.

2. [x] Create a hardcoded set of 4 user login info in the firebase project including usernames and passwords for them.

3. [x] create a seperate screen that after the user's login info is verified in the user database is where the user lands after successfully logging in named the home screen. Add a Scaffold, a ListView, two hardcoded drawing cards with details about the drawing like what was drawn/ color(s) used/ mediums used/ size/ effort amount put in/ ect. Each card should have a time stamp and have the amount of time the user spent on making the drawing.


4. [x] Add tests to verify that the login page authenticates the text entered and then goes to the homepage.

5. [x] Modify the login page so it authenticates the text entered and then goes to the home page once all of the information is successfully verified. 

6. [x] Instead of using mock data inside the current project use the data in the linked firebase project. Fix the already existing code so it all actually works based on requirment 1 in the requirements.md file and passes all the tests in requirment_1_test.dart file. Also eliminate any files that are duplicates/ are redundant in terms of their purpose and if there are redundant files keep the single file that follow the previuos prompts.


7. [x] Check that all tests are passed especially the ones using the data from drawinglog-oaks-sye-sp26 specifically via the user certification part of that project. 


8. [x] Check that all tests for all requirments in requirments.md are passed and if any tests are failed fix the code responsible. Also ensure only one function per files in the library and move any others to new files in the approriate folders. Make seperate git commits with changes made to code relating to a single requirment.


9. [x] The requirments have been updated/ added to please check that the code fufills all of the requirments and passes all of the tests. Also please make tests to make sure there is a functioning user interface/ buttons actually work properly for user. Also please make sure there are buttons when they are appropriate.

10. [x] Please check that drawing log entries can be saved between user logins or even between page switches and create tests to verify drawing log entries are successfully saved by default.


11. [x] Fix the code for saving drawing log entries if tests are not passed until all the tests are passed.


12. [x] Create tests that verify users can successfully create and save their goal from the settings button. Also ensure that the user after having successfully created a goal they are then sent to the home page and notified from a pop up that they were able to sucessfully create a goal that was saved.

13. [x] Do requirment 10 and create unit tests to make sure the button works.

14. [x] Ensure that drawing log entries persist and are saved for a user's account even when the app has stopped running. Add unit tests to verify this and if the tests are not passed fix the code until the tests are passed (and check that the generated tests are appropriate after a certain amount of times of having specific tests failed repeatedly)

15. [x] Generate neccissary code to fufill requirment 11 and integrate firebase with this app. Then create unit tests for the code that an experienced quality assurance tester would create to test the generated code and that firebase is properly integrated with the app to store all the user data. Also ensure that tests are generated to ensure compatability with the rest of the code for the app and with other features and if any tests are failed fix the code until the failed tests are passed.


16. [x] Do prompt 15 again but this time ensuring to connect the app to firsebase cloud firstore of the firebase project connected to this app. Update the stored re-CAPTCHA key for the web-app version of the app if need be.



17. [x] Ensure that the goal set by the user is saved between app restarts and add unit tests to verify this.

18. [x] Move the function _login inside the file login_page.dart to 'services/login_user.dart' and then properly call the _login function from the login_page.dart file in the lib folder. Generate unit tests as if you were a junior Quality Assurance tester to ensure that after the function has been moved that it is called properly and works. Fix the code until the tests can be passed

19. [x] Please make sure the firebase real time database is integrated with this project instead of firestore. Essentially swap out firestore for real time database through firebase and unintegrate firestore. Check that prompt 15 is also properly fufilled with this change in data storage location in firebase. Also keep the firebase authentication code if it works properly.

20. [ ] Please fix the 'firebase fatal error: cannot parse firebase url' or explain what I need to do in my firebase consol settings to fix this.

21. [ ] If any requirment does not have unit tests for the code related to it generate unit tests for that code with one requirments's tests per file. Remove redundant tests unless they are regression tests or include tests that cover code not covered by the other file. 





** Development Rules **

1. Always commit the current code before implimenting a new feature that has a commit
message that is a summary of the changes made since the last commit.