# DockerShiny

A docker image for a fast and reliable shiny server running on **debian:jessie**.

## Synopsis

As it is convenient to use a shiny server to visualize some results through a webpage, we stated that it could be useful to have a fast way to deploy it in a server.

For this kind of task, we really appreciate Docker, which offers a reproductible and reliable way to deploy a solution.

However, the existing docker images available on DockerHub are based on debian:testing, because the R version available through apt-get is quite old.

The point is :
- we like debian, but the unstable release is... too unstable
- we like R, but we need the latest release
- we like Docker, but *r-base:latest* is based on *debian:unstable*

So, we propose the following Dockerfile : 
- FROM debian 8 (jessie)
- compile the latest R from sources
- deploy and expose a shiny-server

> And as we searched for it, we release it.

## Getting Started

### Prerequisites

One of Docker's main advantages is that you don't need a lot of stuff. 

You only need the following : 

- [Docker engine](https://store.docker.com/search?type=edition&offering=community)
- internet connection
- time

### Get a copy

First, clone this repo (should be fast)

```bash
# clone it
git clone https://github.com/See-d-SAS/DockerShiny.git
cd ./DockerShiny

# copy your shiny app into this folder
mkdir src
```

### Building

Then, build the Docker image : 

```bash
docker build -t MyImageName .
```

(this is where you can leave, and get some hot beverage)

### Running

Finally, run the obtained image into a container : 

```bash
docker run -d -p 80:80 MyShinyAppName
```

And you're good !
> You should be able to access your shiny app on **http://127.0.0.1/**

### Troubleshooting

If you can't access the interface, make sure you address to the right localhost.

By default, docker run on a custom network interface, *brideg0*, and thus *127.0.0.1* does not refer to this interface.

Typically, this *bridge0* interface is binded to *172.17.0.0/16*, with a gateway on *172.17.0.1*.
To make sure, you can type the following commands to get the right address : 

```bash
# list network interfaces accessibles to docker
docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
a67bb264f66a        bridge              bridge              local
a267e382133c        host                host                local
2d0a7ab19937        none                null                local

# outputs the details of bridge
docker network inspect bridge
...
"Name": "bridge",
        
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        }
```

Or, you can pass the **--network=host** to bind your container on the real *127.0.0.1*... but it is less funny (and more seriously, not really in the docker aim).


## Built with

- [Docker](https://www.docker.com/)
- [Debian](https://www.debian.org/)
- [R](https://cran.r-project.org/)
- [Shiny](https://github.com/rstudio/shiny)

## Authors

- lefranc <valentin.lefrancATsee-d.fr>
