#!/usr/bin/bash
echo "**********************************************************************"
echo "*                   Log file is \"$LOG\""
echo "**********************************************************************"

RequireAPI xxdoo_utl 1.5.0
RequireAPI xxdoo_html 4.0.0
RequireAPI xxdoo_db 3.1.2

GetConnectString XXDOO XXDOO_CON

SetNLSWindows
SqlExecute /nolog @sql/_install.sql $XXDOO_CON | tee -a $LOG

echo " Done..." | tee -a $LOG                                                            	
