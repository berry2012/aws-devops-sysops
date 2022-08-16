# Running Ubuntu Desktop on an AWS EC2 instance

sudo apt update
sudo apt install ubuntu-desktop -y
sudo apt install tightvncserver -y
sudo apt install gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal -y

# launching the desktop
vncserver :1


# creating script for launching the desktop. Paste the code below
vim ~/.vnc/xstartup

...
#!/bin/sh

export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
x-terminal-emulator -geometry 1920x1080 -randr 1920x1080,1600x1200,1440x900,1024x768 -ls -title "UBUNTUVNCDESKTOP Desktop" & 
x-window-manager &

vncconfig -iconic &
gnome-panel &
gnome-settings-daemon &
metacity &
nautilus &
gnome-terminal &
...

# To kill the vnc server and start it again, type the following command:

vncserver -kill :1
vncserver :1


# specifying screen sizes
vncserver -geometry 1920x1080 -randr 1920x1080,1600x1200,1440x900,1024x768

# Then resize with:

xrandr -s 1600x1200
xrandr -s 1440x900  
xrandr -s 1024x768 



# --- script to launch the desktop via forwarding 

#!/bin/sh
echo "connect to EC2 Ubuntu Desktop"
ssh -i ~/.ssh/key.pem ubuntu@46.137.2.222 -L 5901:127.0.0.1:5901




# more - https://ubuntu.com/tutorials/ubuntu-desktop-aws#2-setting-up-tightvnc-on-aws
