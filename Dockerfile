FROM alpine:latest
EXPOSE 5901
RUN apk add --no-cache tigervnc firefox font-liberation openbox xrandr python3 dbus-x11 py-xdg
RUN mkdir -p $HOME/.vnc
RUN echo $'#!/bin/ash\n\
 if [ \'$VNC_PASSWORD\' = \'\' ]\n\
 then\n\
  Xvnc :1 -SecurityTypes=None\n\
 else\n\
  echo $VNC_PASSWORD | vncpasswd -f > $HOME/.vnc/passwd\n\
  chmod o-rw,g-rw,u+rw $HOME/.vnc/passwd\n\
  Xvnc :1 -SecurityTypes=VncAuth -PasswordFile=$HOME/.vnc/passwd&\n\
 fi\n\
 sleep 5\n\
 DISPLAY=:1 /usr/bin/openbox-session\n\
' > /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN mkdir -p $HOME/.config/openbox
RUN ln -s $HOME/.config/openbox /etc/openbox
RUN echo $'$!/bin/ash\n\
firefox &\n' > /etc/openbox/autostart
RUN chmod +x /etc/openbox/autostart
RUN sed -e 's/sans/Liberation Sans/g' /etc/xdg/openbox/rc.xml > /etc/openbox/rc.xml
RUN sed -i -e 's/Clearlooks/Mikachu/g' /etc/openbox/rc.xml
RUN sed -i -e 's/NLIMC/M/g' /etc/openbox/rc.xml
RUN echo $'\
<openbox_menu xmlns="http://openbox.org/3.4/menu">\n\
<menu id="resolutions-menu" label="Screen resolutions">\n\
 <item label="1024 x 768">\n\
  <action name="Execute">\n\
   <command>xrandr -s 1024x768</command>\n\
  </action>\n\
 </item>\n\
 <item label="1280 x 720">\n\
  <action name="Execute">\n\
   <command>xrandr -s 1280x720</command>\n\
  </action>\n\
 </item>\n\
 <item label="1280 x 800">\n\
  <action name="Execute">\n\
   <command>xrandr -s 1280x800</command>\n\
  </action>\n\
 </item>\n\
 <item label="1280 x 960">\n\
  <action name="Execute">\n\
   <command>xrandr -s 1280x960</command>\n\
  </action>\n\
 </item>\n\
 <item label="1280 x 1024">\n\
  <action name="Execute">\n\
   <command>xrandr -s 1280x1024</command>\n\
  </action>\n\
 </item>\n\
 <item label="1360 x 768">\n\
  <action name="Execute">\n\
   <command>xrandr -s 1360x768</command>\n\
  </action>\n\
 </item>\n\
 <item label="1400 x 1050">\n\
  <action name="Execute">\n\
   <command>xrandr -s 1400x1050</command>\n\
  </action>\n\
 </item>\n\
 <item label="1680 x 1050">\n\
  <action name="Execute">\n\
   <command>xrandr -s 1680x1050</command>\n\
  </action>\n\
 </item>\n\
</menu>\n\
<menu id="root-menu" label="Root">\n\
  <item label="Virtual Browser">\n\
    <action name="Execute">\n\
      <command>firefox</command>\n\
      <startupnotify>\n\
        <enabled>yes</enabled>\n\
      </startupnotify>\n\
    </action>\n\
  </item>\n\
  <separator />\n\
  <menu id="resolutions-menu" />\n\  
</menu>\n\
</openbox_menu>\n\
' > /etc/openbox/menu.xml
VOLUME /etc/openbox
ENTRYPOINT ["/entrypoint.sh"]
