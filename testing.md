# Testing

## Test Cases

| Test Case # | Test Title | Test Steps | Test Date | Expected Result | Actual Result | Pass/Fail Status | Notes |
|-------|-------|-------|-------|-------|-------|-------|-------|
| 1  | Registration Screen Appearance  | Start Application, Application open on profile page, Attempt to interact with profile page, Get directed to login page, Select the registration option, Get directed to registration page, Registration page (email, username, password fields)  | N/A  | Registration screen should have a clean and intuitive design and should be triggered when user attempts to interact with application features  | Intended result was achieved  | Pass  | -  |
| 2  | Valid Registration Data  | Enter valid registration data (email, username, password)  | Email: email@email.com, Username: username, Password: password  | User should be successfully registered  | Intended result was achieved  | Pass  | -  |
| 2.1  | Invalid Registration Data  | Enter invalid registration data  | Email: email, Username: username, Password: password  | User should not be registered  | Intended result was achieved  | Pass  | -  |
| 3  | Login Screen Appearance  | Start application, Applciation opens on profile page, Attempt to interact with profile page, Get directed to login page, Login screen (username, password fields)  | N/A  | Login Screen should have a clean and intuitive design  | Intended result was achieved  | Pass  | -  |
| 4  | Valid Login Credentials  | Enter valid registration data  | Valid username and password, Username: username, Password: password  | Users should be successfully logged in | Intended result was achieved  | Pass  | -  |
| 4.1  | Invalid Login Credentials  | Enter invalid registration data  | Invalid username and/or password, Username: newuser, Password: password  | Users should receive an error message and not be logged in  | Intended result was achieved  | Pass  | -  |
| 5  | User Profile Creation  | Enter valid profile data, Ensure the user's profile is successfully created  | Enter valid profile data, Ensure the user's profile is sucessfully created | Test data: valid name, selected instrument, and bio  | The user's profile should be successfully created  | Intended result was achieved  | Pass  | - |
| 6  | User Authentication  | Ensure valid login credentials, Ensure the user is securely authenticated  | Valid username and password, Username: username, Password: password  | Users shoudl be securely authenticated  | Intended result was achieved  | Pass  | -  |
| 7  | Media Upload  | Attempt to upload valid media files, Ensure the media files are successfully uploaded  | Valid media files  | Media files should be successfully uploaded  | Intended result was achieved  | Pass  | - |
| 8  | Messaging  | Send a message with valid content, Ensure the message is successfully sent and recieved  | Valid message content  | Messages should be successfully sent and received  | Intended result was achieved  | Pass  | - |
| 9 | User Management (Admin) | Attempt to manage user accounts with appropriate permissions, Ensure administrators can successfully manage user accounts | N/A | Administrators should be able to manage user accounts | Intended result was achieved | Pass | - |
| 10 | Notifications | Send a message with valid content
Ensure the message is successfully sent and received, Ensure receiver was notified of message content | N/A | Users should receive notifications for messages | Intended result was not achieved | Fail | Users are unable to recieve notifications; messages are successfully being sent and received |
