#!/bin/bash
cat /opt/CA/WA_Agent/status
if [ $? -eq 0 ]
then
echo "autosys present at /opt/CA/WA_Agent/"
cd /opt/CA/WA_Agent/
./cybAgent -s 
./cybAgent -a 
cat status
fi
cat /opt/CA/WorkloadAutomationAE/SystemAgent/WA_AGENT/status
if [ $? -eq 0 ]
then
echo "autosys present at /opt/CA/WorkloadAutomationAE/SystemAgent/WA_AGENT/"
cd /opt/CA/WorkloadAutomationAE/SystemAgent/WA_AGENT/
./cybAgent -s 
./cybAgent -a 
fi

