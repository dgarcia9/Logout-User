# Logout-User
This power shell script leverages the supervisor rest API to force logout a user.

Script can be run as is and it will ask for the supervisor/admin username, followed by the password, followed by the username that they want to force logout.

It can also be passed parameters for either of those three items. If any item is missing they will be prompted for it.

Parameters are:
-five9Username
-five9UserPass
-logoutUsername
