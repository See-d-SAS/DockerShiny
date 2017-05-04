FROM debian:jessie

LABEL maintainer="theplatypus <nicolas.bloyet@see-d.fr>"

USER root
WORKDIR /srv

# install common utilities and compilation libraries
RUN \
    apt-get update && apt-get install -y \
    git wget nano pandoc \
	# compilers
    gcc g++ gfortran build-essential openjdk-7-jdk \
	# libs required ; with headers (.h)
    curl bzip2 libssl-dev libsasl2-dev liblzma-dev libblas-dev libbz2-dev libcurl4-openssl-dev \
    libreadline-dev xorg-dev libghc-regex-pcre-dev

RUN apt-get update && apt-get install -y \
sudo \
gdebi-core \
pandoc \
pandoc-citeproc \
libcurl4-gnutls-dev \
libcairo2-dev \
libxt-dev \
libssl-dev

# get R source code from CRAN mirror
RUN \
    wget https://cran.univ-paris1.fr/src/base/R-3/R-3.4.0.tar.gz

RUN \
    mkdir ./R && \
    tar -xzf R-3.4.0.tar.gz -C R

WORKDIR /srv/R/R-3.4.0

# compile R project
RUN \
    ./configure --with-readline=no --with-x=no && \
    make && \
	make install

# Download and install shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
VERSION=$(cat version.txt)  && \
wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
gdebi -n ss-latest.deb && \
rm -f version.txt ss-latest.deb

RUN R -e "install.packages(c('shiny', 'rmarkdown', 'tm', 'wordcloud', 'memoise'), repos='http://cran.rstudio.com/')"

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY /src /srv/shiny-server/

EXPOSE 80

COPY shiny-server.sh /usr/bin/shiny-server.sh

# Install packages required by my app
RUN R -e "install.packages(c('devtools','ggplot2','xtable','dplyr','ade4','shiny','DT','ggvis','shinydashboard','FactoMineR','plotly','randomForest','stringr','shinyBS','data.table','plyr'), repos='http://cran.rstudio.com/')"

# Install packages required by my app
#RUN R -e "devtools::install_github('hadley/ggplot2')"


# Remove Shiny example inherited from the base image
RUN rm -rf /srv/shiny-server/*


# Copy the source code of the app from my hard drive to the container (in this case we use the app "wordcloud" from http://shiny.rstudio.com/gallery/word-cloud.html)
COPY src/* /srv/shiny-server/

# give open bar
RUN chmod -R 777 /srv/shiny-server/
RUN chmod 777 /srv/shiny-server/*

# Start the server with the container
CMD ["/usr/bin/shiny-server.sh"]
