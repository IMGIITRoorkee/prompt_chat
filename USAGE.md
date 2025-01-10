Here’s an improved, detailed, and structured version of your CLI documentation for the chat application, with code examples for better clarity:

```markdown
# Command Line Interface Documentation

Welcome to the chat application! This documentation will guide you through the various CLI commands available to interact with the platform. Commands are categorized for ease of use.

---

## Table of Contents
1. [User Management](#user-management)
   - Register
   - Login
   - Logout
   - Update Username
   - Update Password
   - Delete User
2. [User Interaction](#user-interaction)
   - Search Users
   - Send Direct Messages
   - View Direct Messages
3. [Server Management](#server-management)
   - Create Server
   - Join Server
   - Leave Server
   - Invite Members
   - Manage Categories and Channels
   - Role Management
4. [Messaging](#messaging)
   - Send Messages
   - Display Messages

---

## User Management

### Register
Create a new user with the `register` command.  
**Command:**  
```bash
register --username <username> --password <password>
```
**Example:**  
```bash
register --username alice123 --password secretpass
```

---

### Login
Log in with your username and password.  
**Command:**  
```bash
login --username <username> --password <password>
```
**Example:**  
```bash
login --username alice123 --password secretpass
```

---

### Logout
Log out of your current session.  
**Command:**  
```bash
logout
```
**Example:**  
```bash
logout
```

---

### Update Username
Change your username.  
**Command:**  
```bash
update-username <new_username> <current_password>
```
**Example:**  
```bash
update-username alice_updated secretpass
```

---

### Update Password
Change your password.  
**Command:**  
```bash
update-password <new_password> <current_password>
```
**Example:**  
```bash
update-password newsecretpass secretpass
```

---

### Delete User
Permanently delete your account and all associated data.  
**Command:**  
```bash
delete-user
```
**Example:**  
```bash
delete-user
```

---

## User Interaction

### Search Users
Find other users on the platform. Returns up to 5 results.  
**Command:**  
```bash
search-users <search_term>
```
**Example:**  
```bash
search-users alice
```

---

### Send Direct Messages
Send a private message to another user.  
**Command:**  
```bash
send-dm <user_name>
```
**Example:**  
```bash
send-dm bob123
```
You will be prompted to type your message after running the command.

---

### View Direct Messages
View received direct messages.  
**Command:**  
```bash
display-dms
```

---

### View Sent Direct Messages
View messages you have sent.  
**Command:**  
```bash
display-sent-dms
```

---

## Server Management

### Create a Server
Set up a new server.  
**Command:**  
```bash
create-server --name <server_name> --permission <join_permission>
```
**Example:**  
```bash
create-server --name myServer --permission closed
```
`join_permission` can be `open` (anyone can join) or `closed` (invite only). Default is `open`.

---

### Join a Server
Join an existing server.  
**Command:**  
```bash
join-server --server <server_name>
```
**Example:**  
```bash
join-server --server myServer
```

---

### Leave a Server
Leave a server you are part of.  
**Command:**  
```bash
leave-server --server <server_name>
```
**Example:**  
```bash
leave-server --server myServer
```
If you are the server owner, transfer ownership first.

---

### Add Members to a Server
Invite users to your server (owner only).  
**Command:**  
```bash
add-member --server <server_name> --member <user_name>
```
**Example:**  
```bash
add-member --server myServer --member charlie123
```

---

### Create Categories and Channels
- **Add a Category:**  
  ```bash
  add-category --server <server_name> --category <category_name>
  ```
  **Example:**  
  ```bash
  add-category --server myServer --category general
  ```

- **Add a Channel:**  
  ```bash
  add-channel --server <server_name> --channel <channel_name> --permissions <channel_perms> --type <channel_type> --category <parent_category>
  ```
  **Example:**  
  ```bash
  add-channel --server myServer --channel text-chat --permissions member --type text --category general
  ```

---

### Manage Roles
- **Create a Role:**  
  ```bash
  create-role --server <server_name> --role <role_name> --permission <role_permission>
  ```
  **Example:**  
  ```bash
  create-role --server myServer --role moderator --permission moderator
  ```

- **Assign a Role:**  
  ```bash
  assign-role --server <server_name> --role <role_name> --member <member_name>
  ```
  **Example:**  
  ```bash
  assign-role --server myServer --role moderator --member charlie123
  ```

---

## Messaging

### Send a Message
Send a message in a text channel.  
**Command:**  
```bash
send-msg --server <server_name> --channel <channel_name>
```
**Example:**  
```bash
send-msg --server myServer --channel text-chat
```
You will be prompted to type your message after running the command.

---

### Display Messages
View all messages in a channel.  
**Command:**  
```bash
display-messages --server <server_name> --channel <channel_name>
```
**Example:**  
```bash
display-messages --server myServer --channel text-chat
```

---

This documentation should now provide users with a more comprehensive understanding of the chat application's CLI commands.
```