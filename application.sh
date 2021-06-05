echo ${Application_Name} > /tmp/hi.txt
if [ ${Application_Name} = "jenkins" ]; then
        echo "hi"
        sudo apt install -y apache2
        sudo systemctl enable --now apache2
        echo "hi" > /tmp/test.txt
elif [ ${Application_Name} = "ansible" ]; then
        echo "bye"
        sudo apt install -y apache2
        sudo systemctl enable --now apache2
        echo "hi" > /tmp/test.txt
fi
