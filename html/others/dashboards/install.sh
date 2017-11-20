#!/usr/bin/bash
echo "**********************************************************************"
echo "*                   Log file is \"$LOG\""
echo "**********************************************************************"

GetConnectString XXAPPS   XXAPPS_CON
GetConnectString XXSL   XXSL_CON

SetNLSWindows
SqlExecute /nolog @sql/_install.sql $XXAPPS_CON $XXSL_CON | tee -a $LOG

echo " Done..." | tee -a $LOG                                                            	
