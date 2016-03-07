echo "Please exit out of all Microsoft Office products completely. Press any key to continue."
read ready
echo "Please enter your password."
sudo rm -R "/Applications/Microsoft Office 2011"
sudo rm -R "/Applications/Microsoft Messenger.app"
sudo rm ~/Library/Preferences/com.microsoft*
sudo rm -R ~/Library/Preferences/Microsoft/Office\ 2011
sudo rm /Library/LaunchDaemons/com.microsoft.office.licensing.helper.plist
sudo rm /Library/PrivilegedHelperTools/com.microsoft.office.licensing.helper
sudo rm /Library/Preferences/com.microsoft.office.licensing.plist
sudo rm -R /Library/Application\ Support/Microsoft/
sudo rm /Library/Receipts/Office2011_*
sudo rm /private/var/db/receipts/com.microsoft.office*
sudo rm -R /Library/Fonts/Microsoft
sudo mv ~/Documents/Microsoft\ User\ Data/ ~/Desktop/
echo "Please remove icons from launcher bar."
read ready