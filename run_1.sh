#!/bin/sh

sh setup/0_welcome.sh 

echo "What would be the username?"
read uname
echo "What would be the fullname of the user?"
read fname

sh setup/1_pacstrap.sh $uname $fname
