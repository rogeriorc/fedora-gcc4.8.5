# fedora-gcc4.8.5

Build a fedora with gcc 4.8.5 docker image
The gcc will be avaliale in
 
* /opt/gcc485/bin/gcc
* /usr/bin/gcc485
* /opt/gcc485/bin/g++
* /usr/bin/g++485


To make the image:
```
docker build --tag=fedora-gcc4.8.5 .
```

After build, to run:
```
docker run -it fedora-gcc4.8.5 bash
```

To map a host directory in the container
```
docker run -it --mount type=bind,source="C:\path\to\my\src",target="/tmp/source" fedora-gcc4.8.5 bash
```
