#!/usr/bin/bash
echo "**********************************************************************"
echo "*                   Log file is \"$LOG\""
echo "**********************************************************************"

RequireAPI xxdoo_db 3.3.0
RequireAPI xxdoo_utl 1.4.0
RequireAPI xxdoo_html 4.2.0
RequireAPI xxdoo_json 1.3.0
RequireAPI xxdoo_query 1.1.0
RequireAPI xxdoo_dsl 1.1.0
RequireAPI xxdoo_dao 1.0.0

GetConnectString APPS APPS_CON
GetConnectString XXDOO XXDOO_CON
GetConnectString XXDOO_EE XXDOO_EE_CON

SetNLSWindows
SqlExecute /nolog @sql/_install.sql $APPS_CON $XXDOO_CON $XXDOO_EE_CON | tee -a $LOG

echo "create directory $OA_HTML/cabo/jsLibs/custom/organizers" | tee -a $LOG
mkdir $OA_HTML/cabo/jsLibs/custom/organizers | tee -a $LOG
echo "copy resource files into $OA_HTML/cabo/jsLibs/custom/organizers" | tee -a $LOG
cp resource/oracle-client_3.js $OA_HTML/cabo/jsLibs/custom/organizers/oracle-client_3.js | tee -a $LOG
cp resource/noodoo-ui_7.css $OA_HTML/cabo/jsLibs/custom/organizers/noodoo-ui_7.css | tee -a $LOG
cp resource/master.css $OA_HTML/cabo/jsLibs/custom/organizers/master.css | tee -a $LOG
cp resource/images/background.gif $OA_HTML/cabo/jsLibs/custom/organizers/background.gif | tee -a $LOG
cp resource/images/eurochem.PNG $OA_HTML/cabo/jsLibs/custom/organizers/eurochem.PNG | tee -a $LOG
cp resource/images/ipad_icon.png $OA_HTML/cabo/jsLibs/custom/organizers/ipad_icon.png | tee -a $LOG
cp resource/images/search.png $OA_HTML/cabo/jsLibs/custom/organizers/search.png | tee -a $LOG
cp resource/fonts/OpenSans-Regular.ttf $OA_HTML/cabo/jsLibs/custom/organizers/OpenSans-Regular.ttf | tee -a $LOG
echo " Done..." | tee -a $LOG                                                            	
