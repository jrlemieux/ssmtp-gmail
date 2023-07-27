# ssmtp-gmail

A script to make ssmtp work with Gmail SMTP, with a single pre-fixed destination correspondant.

This script will be useful to you if you need to configure ssmtp on your personal server with only one commmand, ensuring that all emails sent through sendmail are delivered to your own Gmail email address, which is also used to send the messages over the Gmail SMTP servers.

I wrote this because I have spent too much time fiddling with ssmtp over the years. I just needed something that works all the time using the least number of parameters.

The main script "install.sh" can be called with the parameters:

```
$ ./install.sh bob@myserver.com mickey.mouse@gmail.com jjdhsgggfaghhsjks 0
```

Where: 
* "bob<span>@</span>myserver.com" corresponds to the ssh username/host specification. The installation script will run on this host. So here, we are installing on the server at "myserver.com".
* "mickey.mouse<span>@</span>gmail.com" is the Gmail address to which ALL messages sent by sendmail will be sent. It is also the Gmail email address that will be used to send the outbound messages.
* "jjdhsgggfaghhsjks" is an Google application password associated with the Gmail account specified by the Gmail address.
* The last 0 is a flag (0 or 1) that indicates whether we want to turn logging on or not (see below).

The "install.sh" script simply copies the "remote-install.sh" script on the remote host and it launches it.

The "remote-install.sh" script performs these tasks:
* It first ensures that ssmtp is installed. It will install it if needed.
* It then figures out where is the ssmtp program and where does reside the sendmail symbolic link.
* It creates an empty revaliases file since it is no longer needed (all emails go to the same destination), so there is no need for rewriting etc.
* It creates a super minimalist ssmtp.conf file, which will hold only the information required to connect and authenticate to the Gmail SMTP servers.
* It creates a script that will trap all calls to sendmail (i.e. it will become the new sendmail). This script, in turn, will call the ssmtp program, but with hard-coding the email address that will receive the email. This script will also log -- if the debug flag has been defined as "1" -- (i) the command line parameters initially supplied to sendmail, (ii) and the actual email message body that will be piped into the ssmtp program. The log files are named /tmp/ssmtp-handler.sh-bob.log for messages sent by Bob, /tmp/ssmtp-handler.sh-alice.log for messages sent by Alice, etc.
* The script sets all the appropriate ownership and permissions on files and folders involved.

The installation script assumes that you have sudo access.

If you run this command:
```
echo "hello" | sendmail
```
You are supposed to receive a message with a body "hello".

If you enabled logging, you would find this file in /tmp/ssmtp-handler.sh-bob.log if your username is bob:

```
/etc/ssmtp/ssmtp-handler.sh called with: /usr/sbin/sendmail
hello
```

Tested under Ubuntu 22.04.

Hopefull, this will be useful to someone else. It fully details all the elements required to make ssmtp work well under this limited use case.

JL

