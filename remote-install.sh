#!/bin/bash

#************************************************************************************
#
# A shell script that installs a shell script that will trap the calls to sendmail target, and calling the
# ssmtp program specifying a fixed destination email address. This is to prevent the bugs with revaliases 
# file, which can then be empty.
#
# P1 - Gmail email address to which ALL emails will be sent.
# P2 - The Google application password associated with this Gmail email address.
# P3 - Debug flag, 0 or 1
#
# When the debug flag is 1, the script will create a log file such as /tmp/ssmtp-handler.sh-bob.log for user Bob
# or ssmtp-handler.sh-alice.log for user Alice. The log file will indicate the parameters with which the sendmail
# program was called with.
#
#************************************************************************************

# No traces.
set +x

# Grab parameters.
EMAIL="$1"
APP_PASSW="$2"
ENABLE_LOG="$3"

# Echo a line in green.
function green {
  echo ""	
  echo -e "\e[32m$1\e[m"
}

# Check if ssmtp is already installed.
green "Checking if ssmtp is installed."
LC_ALL=C apt list ssmtp 2>/dev/null | grep '\[installed\]' >/dev/null

# Install ssmtp it if not installed.
if [[ "$?" != "0" ]]; then
  echo " - Installing ssmtp."
  sudo apt install -y ssmtp
else
  echo " - ssmtp is already installed."    	
fi

# Figure out where and the ssmtp program and the sendmail link.
SSMTP_EXEC=`which ssmtp`
SENDMAIL_SYMLINK=`which sendmail`

green "Programs are located at:"
echo " - $SSMTP_EXEC"
echo " - $SENDMAIL_SYMLINK"

# Set permissions on a file that is owned by root.
function setPerm {
  FILE="$1"	
  PERM="$2"
  sudo chown root:root "$FILE"
  sudo chmod $PERM "$FILE"
  green "File $FILE ownership set to root and permissions set to $PERM."
  ls -ald "$FILE"
}

# The revaliases file is no longer needed, create an empty one.
sudo cp /dev/null /etc/ssmtp/revaliases
# The config is secret.
setPerm /etc/ssmtp/revaliases a=,g=rx,u=rx 

# Create the configuration file.
CONFIG=$(
cat <<END_HEREDOC
mailhub=smtp.gmail.com:587
UseSTARTTLS=yes
AuthUser=$EMAIL
AuthPass=$APP_PASSW
END_HEREDOC
)

sudo bash -c "echo \"$CONFIG\" >/etc/ssmtp/ssmtp.conf"
# This config is secret.
setPerm /etc/ssmtp/ssmtp.conf a=,g=rx,u=rx

SCRIPT_NAME="/etc/ssmtp/ssmtp-handler.sh"

# Build the script contents. 
s="#/bin/bash"
s+=$'\n'
if [[ "$ENABLE_LOG" == "1" ]]; then
  LOG_BASE_NAME=`basename $SCRIPT_NAME`
  s+="LOGFILE=/tmp/$LOG_BASE_NAME-"
  s+=$'$USER.log'
  s+=$'\n'
  s+=$'echo "'
  s+="$SCRIPT_NAME called with: "
  s+=$'$0" >$LOGFILE'
  s+=$'\n'
  s+=$'tee -a $LOGFILE | '
fi	
s+=$"$SSMTP_EXEC $EMAIL"
# Now the contents is in a bash variable 's'.
export s
# Now the contents is also in an environment symbol 's'.
# We use awk to dump this symbol into a file, because it contains $ characters that must not be expanded.
echo "" | awk '{ print ENVIRON["s"] }' | sudo tee $SCRIPT_NAME >/dev/null
# The script must be executable by all. Note that we cannot do a setuid on this file because this feature is ignored on .sh files. 
setPerm "$SCRIPT_NAME" a=rx,g=rx,u=rx

# The folder itself must be readable for all users so that the script above can be accessed. There is no harm in letting people
# access the folder as the configuration files are protected.
setPerm /etc/ssmtp a=rx,g=rx,u=rx

# Change the sendmail link so that it points to our script.
sudo ln -f -s /etc/ssmtp/ssmtp-handler.sh $SENDMAIL_SYMLINK

# The ssmtp program, which will be run by anyone, must have a setuid in order to access its protected configuration files.
setPerm "$SSMTP_EXEC" a=rx,g=rxs,u=rx

green "/etc/ssmtp/ssmtp.conf:"
sudo cat /etc/ssmtp/ssmtp.conf

green "/etc/ssmtp/revaliases:"
sudo cat /etc/ssmtp/revaliases

green "sendmail link:"
sudo ls -ald `which sendmail`

green "Script $SCRIPT_NAME: "
cat $SCRIPT_NAME

echo ""
