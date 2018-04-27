#!/bin/bash
. ./includes/colors.sh
. ./includes/globals.sh
cd ~/Projects
## Colors are now coded COL_Red, COL_Blue, and COL_NC
## Use as echo -e "${COL_Red}...${COL_NC}" or printf "${COL_RED}...${COL_NC}"
echo -e "${COL_Green}---------- RemoveApacheVirtualHost ----------${COL_NC}"
echo ""
echo -e "This script will ${COL_RED}DELETE${COL_NC} an existing virtual host"
echo -e "Script requires ${COL_Red}ROOT${COL_NC} ACCESS and will modify 
    /etc/apache2/sites-available 
    /etc/hosts
    /var/www/html/projects.json
    /home/$USER/Projects/"
sudo echo ""
echo -e "List of available projects for ${COL_Red}DELETION${COL_NC}"
ls ~/Projects
projectName="nonameyet"
while [ "$projectName" == "nonameyet" ]; do
    read -p "Enter project name: " projectName
    if [ -d "/home/$USER/Projects/$projectName" ]; then
        echo -ne "Are you sure you want to ${COL_RED}DELETE${COL_NC} $projectName? Type full name again to continue: "
        read -p "" conf
        if [ "$projectName" == "$conf" ]; then
            echo "Deleting project $projectName"
        else
            projectName="nonameyet"
        fi
    else
        echo "Project does not exists in /home/$USER/Projects. Please enter an existing project from that folder"
        ls "/home/$USER/Projects/"
        projectName="nonameyet"
    fi
done

echo "----------------------------------"

sudo chown $USER:$USER "/home/$USER/Projects/$projectName" -R
sudo mv "/home/$USER/Projects/$projectName" "/home/$USER/Projects/.trash/$projectName"
cd /etc/apache2/sites-available
sudo mv "$projectName.conf" ".trash/$projectName.conf"
sudo a2dissite "$projectName"
sudo systemctl reload apache2
sudo service apache2 restart
cd /etc
sudo cp hosts hosts.old
sudo sed -i "/127.0.1.1    $projectName.prj/d" ./hosts

cd /var/www/html
sudo chmod 777 projects.json
sudo cp projects.json .trash/projects.json
jq 'del(.'$projectName')' projects.json | sudo tee projects.json
sudo chmod 644 projects.json

echo "Site removed"
echo -e "If you tots messed up..."
echo -e "${COL_Green}Project files${COL_NC} are in ~/Projects/.trash/$projectName"
echo -e "${COL_Green}$projectName.conf${COL_NC} is at /etc/apache2/sites-available/.trash/$projectName"
echo -e "${COL_Green}Old host records${COL_NC} are at /etc/hosts.old"
