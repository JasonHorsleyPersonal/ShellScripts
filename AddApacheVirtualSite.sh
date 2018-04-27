#!/bin/bash
. ./includes/colors.sh
. ./includes/globals.sh
cd ~/Projects
## Colors are now coded COL_Red, COL_Blue, and COL_NC
## Use as echo -e "${COL_Red}...${COL_NC}" or printf "${COL_RED}...${COL_NC}"
echo -e "${COL_Green}---------- AddApacheVirtualHost ----------${COL_NC}"
echo ""
echo "This script will create a new virtual host with a name of your choosing"
echo "Further improvement: 
    Ask for a projectname (already), as well as the href and site name
    Replace all $USER with USER variable (and test, tired now)"
echo -e "Script requires ${COL_Red}ROOT${COL_NC} ACCESS and will modify 
    /etc/apache2/sites-available 
    /etc/hosts
    /var/www/html/projects.json
    /home/$USER/Projects/"
sudo echo ""
projectName="nonameyet"
while [ "$projectName" == "nonameyet" ]; do
    read -p "Enter project name: " projectName
    if [ -d "/home/$USER/Projects/$projectName" ]; then
        echo "Project already exists at /home/$USER/Projects. Please pick something else, here's an LS ya lazy"
        ls /home/$USER/Projects/
        projectName="nonameyet"
    else
        read -p "Are you sure on $projectName? (y/n): " conf
        if [ "$conf" == "n" ]; then
            projectName="nonameyet"
        fi
    fi
done

echo "----------------------------------"

sudo mkdir "/home/$USER/Projects/$projectName"
sudo chown $USER:$USER "/home/$USER/Projects/$projectName" -R
cd "/home/$USER/Projects/$projectName"
cloc --json > cloc_stat.json
sudo chmod 777 cloc_stat.json
git init
git add .
git commit -m "Project created"
echo "<h1>$projectName created (Dummy index.html)</h1>" >> index.html
cd /etc/apache2/sites-available
sudo touch "$projectName.conf"
sudo chmod 777 "$projectName.conf"
echo "<VirtualHost *:80>" > "$projectName.conf"
echo "    ServerName $projectName.prj" >> "$projectName.conf"
echo "    DocumentRoot '/home/$USER/Projects/$projectName'" >> "$projectName.conf"
echo "</VirtualHost>" >> "$projectName.conf"
sudo chmod 644 "$projectName.conf"
sudo a2ensite "$projectName"
sudo systemctl reload apache2
sudo service apache2 restart
sudo echo "127.0.1.1    $projectName.prj" | sudo tee -a /etc/hosts
#chromium-browser "http://$projectName.prj"
echo "Site created"
# TODO: Add to projects json in /var/www/

sudo chmod 777 /var/www/html/projects.json
jq '. + {"'$projectName'": {"name":"'$projectName'", "fsLoc":"/home/'$USER'/Projects/'$projectName'", "href":"'$projectName'.prj"}}' /var/www/html/projects.json | sudo tee /var/www/html/projects.json
sudo chmod 644 /var/www/html/projects.json

echo "All done"
