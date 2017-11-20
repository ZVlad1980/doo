#!/usr/bin/bash
echo "**********************************************************************"
echo "*                   Log file is \"$LOG\""
echo "**********************************************************************"

RequireAPI xxdoo_utl 0.0.2

GetConnectString APPS APPS_CON
GetConnectString XXDOO XXDOO_CON

SetNLSWindows
SqlExecute /nolog @sql/_install.sql $APPS_CON $XXDOO_CON | tee -a $LOG

echo " Done..." | tee -a $LOG                                                            	
