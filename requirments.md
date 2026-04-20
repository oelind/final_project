<!-- required for this project-->
<!--https://blog.devops.dev/is-requirements-txt-essential-for-developers-using-python-4cdcf00a8fb2 this is a source 
I used because I was a lil confused on the purpose of this document-->

# Directions to Gemini
- Generate seperate tests for each requirement

# App Requirments Document

## features


<!--ed called markdown files being comments so will keep that in mind-->

<!--Will need to potentially use a user database to keep a library unique to each user -->

1. Create a log in screen that has the options for the user to log into the tracker or to create an account.


<!-- goal that is in terms of end of week total time or goal that is in terms of time per day-->
<!-- goal widget could still keep track of goal in both daily and end of week version-->
2. User is prompted to enter desired amount of time (total) to spend drawing for the week or the desired amount of time to spend drawing per day.


<!-- where ed said to start (also forgot to mention other ideas off the top of my head during meeting)-->



<!-- if reminders/ notifications are desired or not like an alarm that prompts you to get a doodle in-->
3. Store if the user would like to recieve notifications that are reminders to work towards fufilling their goal.


<!-- if reminders are desired then the amount that is okay from a range of like a single reminder at a specific time to say one reminder every 2 hours if a log is not made by a specific time/ if goal amount is not reached by a specific time (like noon)-->
4. For settings of reminders (if any are desired) selected like the amount of reminders that start being sent via email if a drawing log entry has not been made by the time the user has specified (with the default being noon). The maximum amount of reminders to be sent after the user specified time (or noon if they do not specify a time) is one reminder every hour until a user specified latest time for reminders to be sent (with the default for if a user does not specify a time being midnight).

5. After the user signs into their account they are sent to a home screen that displays all of their past drawing entires (if any). If there are no drawing log entries yet in the center of the middle of the screen a button that says record your first entry gives the user the opportunity to log how long they spent on said drawing, when they made the drawing (default being the current date), how much effort they put into it (with the default being medium), and after all that information is entered after they hit a button in the bottom right hand corner of the popup the user is currently in titled finished that then records all the user inputed data and assigns a timestamp of when the finished button was pressed.

6.  Also there are buttons in the bottom right hand corner of the home screen where the user can log drawings. Also a settings button where the user can access a drop down menu to select is they want to sign out, edit their weekly goal, or to edit their notification settings. Each button of the dropdown menu goes to different pages. Also there are buttons for the user to be able to interface with their data and change their settings.

7. The user responses/ data is stored in a user specific local library a via the account they have set up.


8.  If reminder/ notification clicked on: user could be asked if they need to log a drawing that they forgot to log earlier or to start to log a real time log entry for a drawing which has a timer that when stopped is the amount of time for the in progress entry. The user then fills out the rest of the entry details.


9. Widget that is updated after every log entry for the goal that is displayed at the top of the home page before all of the log entries are displayed. This widget will show how much of the user's goal has been completed in percentages of a progress bar. If the user has completed the goal then the progress bar will display the goal progress and a message congradulating the user on completing more than their goal.
-->

<!--If end of week for user is sunday or monday-->


<!--list of ideas for drawings screen-->

10. On the home screen below the logged drawing entries create a a random drawing prompt generator using the object_prompts.txt file randomly select one of the words to be outputed as the generated drawing prompt. Have a button that the user presses to output a the randomly selected drawing prompt with only a single drawing prompt displayed at any given time.

11. All data for the app including the login info for users will be stored in the firebase project associated with this app (ie the firebase project drawinglog-oaks-sye-sp26). Specifically through and in the firebase real time database associatted with this app.

<!--lists of various discriptors of actions for a prompt (like specific style to draw in/ media used/ in color or not/ landscape or portrait 
orientation/ )-->


<!--At end of week give user summary on number of drawings/ avg amount of time spent on each drawing/ if prompts from lift were used/
if prompt generator button was pressed-->




<!---->