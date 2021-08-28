# Linux Container with OpenCAPI, Fletcher, and Xilinx Vivado/Vivado HLS
This dockerfile currently downloads and installs Vivado from a publically accessible CERN server.

## Build Instructions
```bash
docker build . -t ocxl
```
(where ocxl is the tag, use any name you like)

## Run Using X11
```bash
xhost + #to enable the docker container to open a forwarded X window op your host
docker run -ti --net host -e XAUTHORITY=$HOME/.Xauthority -e DISPLAY=$DISPLAY -v $HOME/.Xauthority:$HOME/.Xauthority -v /tmp/.X11-unix/:/tmp/.X11-unix -h $HOSTNAME ocxl
```
(The complicated run command is to enable X11 forwarding support, so that the simulated oc-accel terminal will pop up)

An xterm window will pop up. in that terminal, execute
```bash
/work/OpenCAPI/fletcher-oc-accel/examples/stringwrite/sw/snap_stringwrite
```
To run the application. After it finishes, close the xterm window and press ctrl-c in the original bash terminal to stop the oc-accel HW/SW cosimulation.
After this, you can view the simulation's waveforms by running `./display_traces`

### Alternate Run command
By default, docker will start an OpenCAPI simulation window of the design configured in `files/snap_env.sh`.
If you just want to open a bash terminal instead, 
```bash
docker run -ti --net host -e XAUTHORITY=$HOME/.Xauthority -e DISPLAY=$DISPLAY -v $HOME/.Xauthority:$HOME/.Xauthority -v /tmp/.X11-unix/:/tmp/.X11-unix -h $HOSTNAME ocxl bash
```
If you don't want to forward any GUI windows, you could even just run 
```bash
docker run -ti ocxl bash
Keep in mind that normally, any changes you make will be lost when you close the bash session.
If you want to make changes permanently, you need to attach a volume or mount a directory on your host and perform your work there.

## Command Line Access to a Currently Running Container
If you need to access the command line for a container which is currently running you can use the following command to open up a bash prompt:
```bash
docker exec -it <container name> bash
```

You may need to run ```docker ps -a``` to find the name of the container if you didn't set one yourself. Docker will set it's own name if you didn't specify one.
