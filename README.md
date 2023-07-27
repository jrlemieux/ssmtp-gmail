# ssmtp-gmail

A script to make ssmtp work with Gmail SMTP, with a single pre-fixed destination correspondant.

Over the years, I've been struggling to make ssmtp work with Google SMTP servers. It seems that the "rewriting"
of destination email addresses do not always work, maybe it is inconsistent from operating system to an other.

The main script "install.sh" can be called with the parameters:

$ ./install.sh bob@myserver.com bob.r.smith@gmail.com jjdhsgggfaghhsjks 0

Where: 
* bob@myserver.com corresponds to the ssh username/host specification. The installation script will run on this host.
* r.smith@gmail.com is the Gmail address to which ALL messages sent by sendmail will be sent. It is also the email address that will be used to send messages.
* jjdhsgggfaghhsjks is an Google application password associated with the Gmail account specified by the Gmail address.
* The last 0 is a flag (0 or 1) that indicates whether we want to turn logging on or not (see below).

The "install.sh" script simple copies the "remote-install.sh" script on the remote host and launches it.

The "remote-install.sh" script performs these tasks:
* It first ensures that ssmtp is installed. It will install it if needed.
* It then figures out where is this ssmtp program and where is the sendmail symbolic link.
* It creates an empty revaliases file since it is no longer needed (all emails go to the same destination), so there is no need for rewriting etc.
* It creates a super minimalist ssmtp.conf file, which will hold only the information required to connect and authenticate to the Gmail SMTP servers.
* It creates a script that will trap all calls to sendmail. This script, in turn, will call the ssmtp program, but with hard-coding which email address shoud receive the email. This script will also log, if the debug flag has been defined as "1", (i) the parameters initially supplied to sendmail, (ii) and the actual email message that was piped into sendmail. The log files are created in files named /tmp/ssmtp-handler.sh-bob.log for messages sent by Bob, /tmp/ssmtp-handler.sh-alice.log for messages sent by Alice, etc.
* The script sets all the appropriate permissions on files and folders involved.

So this script will be useful to you if you need to configure ssmtp on your personal server with only one commmand, ensuring that all emails sent through sendmail come at your own Gmail email address, the same address from which the messages will be sent.

JL

