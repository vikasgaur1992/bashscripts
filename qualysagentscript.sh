###########################################################################################################################
#                            Qualys agent Installation and status check.
#                            This script is used to check the status of Qualys agent and install it if not present.
#			
##################################################################################################################################

#!/bin/sh

#listing agent status before installation
echo "Agent status before Installing : "
/opt/Citizens/Core/bin/CFG_Agent_MGMT.bash -c list | grep Qualys

#checking qualys agent
status=$(/opt/Citizens/Core/bin/CFG_Agent_MGMT.bash -c list | grep "Agent :  Qualys          : Status Code : 0" | wc -l)

if [ $status -eq 1 ]
then
	echo "Qualys in running state "
else
	#if qualys agent not found
	#Installing the agent
	/opt/Citizens/Core/bin/CFG_Agent_MGMT.bash -c install -a qualys
	if [ $? -ne 0 ]
	then
		a=$(/opt/Citizens/Core/bin/CFG_Agent_MGMT.bash -c install -a qualys | tail -1 | awk '{print $14}')
		b="${a%?}"
		path=$(dirname $b)
		filename=$(basename -s .tar.gz $b)
		tarfile=$(basename $b)
		sigfile=$filename".sig"
		echo $path
		echo $tarfile
		echo $sigfile
		cd $path
		sha512sum $tarfile > $sigfile
		/opt/Citizens/Core/bin/CFG_Agent_MGMT.bash -c install -a qualys
		if [ $? -eq 0 ]
		then
			echo "Agent installed successfully"
		else
			echo "Agent not installed check manually"
		fi
	else
		echo "Agent installed successfully"
	fi
fi

#Check agent status after installation
echo "Status After Installation : "
/opt/Citizens/Core/bin/CFG_Agent_MGMT.bash -c list | grep Qualys
