sudo echo "Starting..."
projectName="nonameyet"
while [ "$projectName" == "nonameyet" ]; do
    read -p "Enter project name: " projectName
    if [ -d "/home/jason/Projects/$projectName" ]; then
        echo "Project already exists at /home/jason/Projects. Please pick something else, here's an LS ya lazy"
        ls /home/jason/Projects/
        projectName="nonameyet"
    else
        read -p "Are you sure on $projectName? (y/n): " conf
        if [ "$conf" == "n" ]; then
            projectName="nonameyet"
        fi
    fi
done

echo "----------------------------------"

sudo mkdir "/home/jason/Projects/$projectName"
sudo chown $USER:$USER "/home/jason/Projects/$projectName" -R
cd "/home/jason/Projects/$projectName"
cloc --json > cloc_stat.json
sudo chmod 755 cloc_stat.json
git init
git add .
git commit -m "Project created"
echo "<h1>$projectName created (Dummy index.html)</h1>" >> index.html
cd /etc/apache2/sites-available
sudo touch "$projectName.conf"
sudo chmod 777 "$projectName.conf"
echo "<VirtualHost *:80>" > "$projectName.conf"
echo "    ServerName $projectName.prj" >> "$projectName.conf"
echo "    DocumentRoot '/home/jason/Projects/$projectName'" >> "$projectName.conf"
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
jq '. + {"'$projectName'": {"name":"'$projectName'", "fsLoc":"/home/jason/Projects/'$projectName'", "href":"'$projectName'.prj"}}' /var/www/html/projects.json | sudo tee /var/www/html/projects.json
sudo chmod 644 /var/www/html/projects.json

echo "All done"
