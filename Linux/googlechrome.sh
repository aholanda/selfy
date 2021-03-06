if [ -f /usr/bin/google-chrome ]
then
	echo "WARNING: Google Chrome already installed."
	exit 0
fi
cat << EOF > /etc/apt/sources.list.d/google-chrome.list
deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
EOF
wget -O- https://dl.google.com/linux/linux_signing_key.pub |gpg --dearmor > /etc/apt/trusted.gpg.d/google.gpg
apt update
apt install -y google-chrome-stable

