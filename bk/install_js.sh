#!/usr/bin/bash
echo "**********************************************************************"
echo "*                   Log file is \"$LOG\""
echo "**********************************************************************"


SetNLSWindows

echo "create directory $OA_HTML/cabo/jsLibs/custom/organizers" | tee -a $LOG
mkdir $OA_HTML/cabo/jsLibs/custom/organizers | tee -a $LOG
mkdir $OA_HTML/cabo/jsLibs/custom/organizers/images | tee -a $LOG
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
