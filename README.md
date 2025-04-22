# Virtual Browser Docker Container
## Purpose
Provides a browser (Firefox) running inside a relatively small Docker container exposed via VNC, but without any VNC client, showing nothing else but that browser. This allows for browsing the web from within a docker network. Use cases include:
- Accessing services inside a docker network that would otherwise have to be exposed
- Accessing a local network from a WAN/the internet
- Unrestricted browsing when http traffic would otherwise be restricted/monitored
## Why does this not include a VNC client (e.g., NoVNC)?
There are plenty of options that include other applications, or a VNC client. This purposefully does not include one. I use Guacamole to access several servers, this virtual browser container is just one of them - so I didn't want to have additional VNC clients when I use the Guacamole built-in one anyway.
## Do I really just need the Dockerfile?
Scripts and configuration files are created by the Dockerfile while building the image. This could have been done differently, but I create small images like this one in the Portainer UI and I want to keep it simple, and without dependencies on the continued existance of this repository.
## Build
Download the Dockerfile into some folder on a machine that runs docker and execute
```
docker build -t virtualbrowser:minimal .
```
or use the _Build image_ functionality in Portainer and paste the contents of Dockerfile into that.
## Use
Best way to do this is using compose. This compose file assumes you have created an isolated network called "internal". The beauty of that is that you can attach other containers to it, such as Guacamole, and a reverse proxy. This way, you only need to expose the reverse proxy's port, (e.g., 443,) reverse proxy to Guacamole, and have Guacamole access your internal VNC, RDP and SSH resources. 
The "vb" network only serves to provide access from the container to the surrounding network (as "internal" is isolated in my case.)
```yaml
services:
  virtualbrowser:
    image: virtualbrowser:minimal
    hostname: virtualbrowser
    # Not needed in my case as I'm routing traffic through the "internal" network
    # ports:
    #  - 5901:5901
    # If you're publishing the port, feel free to remove the networks in this stack
    networks:
      internal:
        aliases:
          - "virtualbrowser"
      vb:
    volumes:
      - openbox_config:/etc/openbox
    environment:
      VNC_PASSWORD: PutYourVncPasswordHere

volumes:
  openbox_config:
    # If you want the config volume to live & die with this stack, you can remove the "external" line. 
    # In case you keep the volume external, don't forget to create it before composing.
    external: true

networks:
  # pre-existing network called "internal". If you want to keep it, don't forget to create it before composing.
  internal:
    external: true
  vb:
    driver: bridge
```
