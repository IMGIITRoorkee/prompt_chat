const String helpText = '''
========================================
             \u001b[1;34mCommand Help Menu\u001b[0m
========================================

\u001b[1;33m## User Management\u001b[0m

\u001b[1;32m- Register a user\u001b[0m
  \u001b[1;37mregister username password\u001b[0m
  Registers a new user. Login separately after registering.

\u001b[1;32m- Login\u001b[0m
  \u001b[1;37mlogin username password\u001b[0m
  Logs in as an existing user. Only one user can be logged in at a time.

\u001b[1;32m- Logout\u001b[0m
  \u001b[1;37mlogout\u001b[0m
  Logs out the current session.

----------------------------------------
\u001b[1;33m## Server Management\u001b[0m

\u001b[1;32m- Create a server\u001b[0m
  \u001b[1;37mcreate-server server_name join_permission\u001b[0m
  Creates a server. You become the owner. Set join_permission as 'open' (default) or 'closed'.

\u001b[1;32m- Join a server\u001b[0m
  \u001b[1;37mjoin-server server_name\u001b[0m
  Joins an open server.

\u001b[1;32m- Add members\u001b[0m
  \u001b[1;37madd-member server_name user_name\u001b[0m
  Adds users to the server (owner privileges required).

\u001b[1;32m- Add categories\u001b[0m
  \u001b[1;37madd-category server_name category_name\u001b[0m
  Adds a category to the server (owner privileges required).

\u001b[1;32m- Add channels\u001b[0m
  \u001b[1;37madd-channel server_name channel_name channel_perms channel_type [parent_category]\u001b[0m
  Adds channels to the server with optional parent category (owner privileges required).

----------------------------------------
\u001b[1;33m## Messaging and Roles\u001b[0m

\u001b[1;32m- Send a message\u001b[0m
  \u001b[1;37msend-msg server_name channel_name\u001b[0m
  Sends a message to a text channel.

\u001b[1;32m- Display messages\u001b[0m
  \u001b[1;37mdisplay-item server_name\u001b[0m
  Displays messages in a specific server.

\u001b[1;32m- Create a role\u001b[0m
  \u001b[1;37mcreate-role server_name role_name role_permission\u001b[0m
  Creates a new role with specific permissions.

\u001b[1;32m- Assign a role\u001b[0m
  \u001b[1;37massign-role server_name role_name member_name\u001b[0m
  Assigns a role to a member (owner privileges required).

----------------------------------------
\u001b[1;33m## Server and Channel Management\u001b[0m

\u001b[1;32m- Add channels to categories\u001b[0m
  \u001b[1;37mchannel-to-cat server_name channel_name category_name\u001b[0m
  Assigns a channel to a category (owner privileges required).

\u001b[1;32m- Change channel permissions\u001b[0m
  \u001b[1;37mchange-perm server_name channel_name new_perm\u001b[0m
  Updates permissions for a channel.

\u001b[1;32m- Transfer ownership\u001b[0m
  \u001b[1;37mchange-ownership server_name new_owner\u001b[0m
  Transfers server ownership to another user.

\u001b[1;32m- Leave a server\u001b[0m
  \u001b[1;37mleave-server server_name\u001b[0m
  Leaves a server. Owners must transfer ownership first.

\u001b[1;32m- Kick out members\u001b[0m
  \u001b[1;37mkickout-member server_name user_name\u001b[0m
  Removes a user from the server (owner/moderator privileges required).

========================================
  \u001b[1;34mUse these commands to manage users, servers, and roles efficiently!\u001b[0m
========================================
''';
