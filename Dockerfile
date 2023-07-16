# Use an official Ubuntu runtime as a parent image
FROM ubuntu:bionic

# Set the working directory in the container to /app
WORKDIR /app

# Set environment variables to disable prompt during package installation and set the timezone
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Warsaw
ENV MAKEFLAGS=-j

# Install any needed packages specified in requirements.txt
RUN apt update &&  apt install software-properties-common -y  && add-apt-repository ppa:bitcoin/bitcoin
RUN  apt-get update
RUN  apt-get install libdb4.8-dev libdb4.8++-dev -y 
RUN apt-get update && \
    apt-get install -y git build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 software-properties-common tzdata libboost-all-dev libssl-dev libevent-dev wget libzmq3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

# Build Berkeley DB
RUN wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz && \
    tar -xvf db-4.8.30.NC.tar.gz && \
    cd db-4.8.30.NC/build_unix/ && \
    ../dist/configure --enable-cxx && \
    make && \
    make install && \
    cd /app && \
    rm -rf db-4.8.30.NC db-4.8.30.NC.tar.gz

# Clone the Dogecoin Core repository
RUN git clone https://github.com/dogecoin/dogecoin.git

# Change the working directory to the cloned repository
WORKDIR /app/dogecoin

# Build the project according to the instructions
RUN ./autogen.sh
RUN ./configure BDB_LIBS="-L/usr/local/BerkeleyDB.4.8/lib -ldb_cxx-4.8" BDB_CFLAGS="-I/usr/local/BerkeleyDB.4.8/include"
RUN make
RUN make install

# Make port 80 available to the world outside this container
EXPOSE 80

# Run the application when the container launches
CMD ["dogecoind"]

