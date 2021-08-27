# Linux Container with OpenCAPI, Fletcher, and Xilinx Vivado/Vivado HLS
This dockerfile currently downloads and installs Vivado from a publically accessible CERN server.

## Build Instructions
Building: into the dir and run 'docker build . -t ocxl' (where ocxl is the tag, use any name you like)

## Run Using X11
Running: first run ‘xhost +’, then 
```bash
docker run -ti --net host -e XAUTHORITY=$HOME/.Xauthority -e DISPLAY=$DISPLAY -v $HOME/.Xauthority:$HOME/.Xauthority -v /tmp/.X11-unix/:/tmp/.X11-unix -h $HOSTNAME ocxl
```
(The complicated run command is to enable X11 forwarding support, so that the simulated oc-accel terminal will pop up)

### Alternate Entrypoint
By default, docker will execute the entrypoint command which will start an OpenCAPI simulation window.
To override the entrypoint, you need to use the ```--entrypoint``` option. You may want to do this, for instance, if you want to open a bash terminal instead.
```bash
docker run --rm -it -e DISPLAY=$IP:0 -v /tmp/.X11-unix:/tmp/.X11-unix --entrypoint /bin/bash <container name>:<container tag>
```

## Command Line Access to a Currently Running Container
If you need to access the command line for a container which is currently running you can use the following command to open up a bash prompt:
```bash
docker exec -it <container name> bash
```

You may need to run ```docker ps -a``` to find the name of the container if you didn't set one yourself. Docker will set it's own name if you didn't specify one.
