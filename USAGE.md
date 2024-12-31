# Command Line Interface Documentation

## Registering and logging in

### Register a user
Use the command `register --username <username> --password <password>` to register a new user on the platform. Note that you will need to login separately after registering.

### Login
Use `login --username <username> --password <password>` to login as an existing user. Note that only one user can be logged in during a session. 

### Logout
Use `logout` to logout of the session.

## Servers

### Create a server
Use `create-server --name <server_name> --permission <join_permission>` to create a new server. You will automatically be marked as the owner of that server and gain the ability to add other users, add categories, channels and manage permissions. The `--permission` flag can be either set as `open` or `closed`. Open servers can be joined by any users, while closed servers require owner to add new members. It is set to `open` by default.

### Joining a server 
Use `join-server --server <server_name>` to join a server, granted the server is open.

### Add users to a server
Use `add-member --server <server_name> --member <user_name>` to add existing users to a server. You must be logged in to do so. The added user will automatically be given member privileges.

### Add categories to a server
Use `add-category --server <server_name> --category <category_name>` to add a category to a server (requires owner privileges). The newly added category will not have any channels in it by default.

### Add channels to a server
Use `add-channel --server <server_name> --channel <channel_name> --permissions <channel_perms> --type <channel_type> --category <parent_category>` to add a channel, with the `--category` flag being optional. (requires owner privileges). By default, the channel will not belong to any category.

Channels can have three levels of permission - `member`, `moderator`, and `owner`, allowing varying levels of access. Channels currently support three types - `text`, `voice` and `video`.

### Send message in a server
Use `send-msg --server <server_name> --channel <channel_name>` to send a message in a text channel. (Can be done only while logged in). You will then be prompted to enter your message. 

### Displaying messages
Use `display-messages --server <server_name>` to display messages in a server.
Other display commands include:
- `display-users` - Show all users
- `display-channels` - Show all channels

### Creating a new role for a server
Use `create-role --server <server_name> --role <role_name> --permission <role_permission>` to create a new role for a server (owner privileges required). Note that role names must be unique for a server. Permissions can be - `owner`, `moderator` or `member` (by default).

### Assign an existing role in a server to a member
Use `assign-role --server <server_name> --role <role_name> --member <member_name>` to assign a role in a server to a member (owner privileges required).

### Adding channels to categories for a server (Owner only)
Use `channel-to-cat --server <server_name> --channel <channel_name> --category <category_name>` to assign an existing channel in that server to an existing category. 

### Changing permissions for a channel (Owner only)
Use `change-perm --server <server_name> --channel <channel_name> --permission <new_perm>` to change the permissions for an existing channel. Permissions can be - `member`, `moderator` or `owner`.

### Relinquish ownership of a server
Use `change-ownership --server <server_name> --owner <new_owner>` to give your owner rights to another user.

### Leave a server
Use `leave-server --server <server_name>` to leave a server. Note that you must relinquish your ownership rights using `change-ownership` first before leaving a server if you are its owner.

### Kickout users from server
Use `kickout-member --server <server_name> --member <user_name>` to kickout a member from a server. Note that you must be an owner or moderator for this.