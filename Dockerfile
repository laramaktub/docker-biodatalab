FROM ubuntu:16.04
MAINTAINER bhaas@broadinstitute.org

RUN apt-get update && apt-get install -y gcc g++ perl python automake make \
                                       wget git curl libdb-dev \
                                       zlib1g-dev bzip2 libncurses5-dev \
				       texlive-latex-base \
                                       default-jre \
				       python-pip python-dev \
                                       gfortran \
				       build-essential libghc-zlib-dev libncurses-dev libbz2-dev liblzma-dev libpcre3-dev libxml2-dev \
				       libblas-dev gfortran git unzip ftp libzmq3-dev nano ftp fort77 libreadline-dev \
				       libcurl4-openssl-dev libx11-dev libxt-dev \
				       x11-common libcairo2-dev libpng12-dev libreadline6-dev libjpeg8-dev pkg-config \
				       software-properties-common python-setuptools python-dev python-numpy \ 
                   && apt-get clean



## set up tool config and deployment area:

ENV SRC /usr/local/src
ENV BIN /usr/local/bin




# blast
WORKDIR $SRC
RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.5.0/ncbi-blast-2.5.0+-x64-linux.tar.gz && \
    tar xvf ncbi-blast-2.5.0+-x64-linux.tar.gz && \
    cp ncbi-blast-2.5.0+/bin/* $BIN


  
##########
## Trinity



# Version Trinity 2.4.0
ENV TRINITY_VERSION="2.4.0"


RUN TRINITY_URL="https://github.com/trinityrnaseq/trinityrnaseq/archive/Trinity-v${TRINITY_VERSION}.tar.gz" && \
    wget $TRINITY_URL

RUN tar -xvf Trinity-v${TRINITY_VERSION}.tar.gz

RUN cd trinityrnaseq-Trinity-v${TRINITY_VERSION} && make

ENV TRINITY_HOME $SRC/trinityrnaseq-Trinity-v${TRINITY_VERSION}

RUN cp $TRINITY_HOME/trinity-plugins/BIN/samtools $BIN

ENV PATH=${TRINITY_HOME}:${PATH}

COPY Dockerfile $SRC/Dockerfile.$TRINITY_VERSION


RUN apt-get install -y libtbb-dev && apt-get clean

RUN cd /usr/local/src &&\ 
    rm -rf *tar.gz




## Install prinseq

#Download and install prinseq
RUN set -e \
      && cd /usr/local/src \
      && wget 'https://sourceforge.net/projects/prinseq/files/latest/download?source=files' -O prinseq.tar.gz \
      && tar xzvf prinseq.tar.gz \
      && cd prinseq-* \
      && chmod +x *.pl \
      && cp *.pl /usr/local/bin




#install  MAFFT

RUN wget https://mafft.cbrc.jp/alignment/software/mafft-7.394-gcc_fc6.x86_64.rpm
RUN apt-get install -y rpm
RUN rpm -Uvh mafft-7.394-gcc_fc6.x86_64.rpm 


#install iqtree

RUN wget https://github.com/Cibiv/IQ-TREE/releases/download/v1.6.2/iqtree-1.6.2-Linux.tar.gz
RUN tar -zxvf iqtree-1.6.2-Linux.tar.gz 
ENV PATH="/usr/local/src/iqtree-1.6.2-Linux/bin:${PATH}"



#mrbayer

RUN apt install -y vim mpich wget autoconf gcc make

RUN wget 'http://downloads.sourceforge.net/project/mrbayes/mrbayes/3.2.6/mrbayes-3.2.6.tar.gz'
RUN tar -xvzf mrbayes-3.2.6.tar.gz

WORKDIR /usr/local/src/mrbayes-3.2.6/src

RUN autoconf
RUN ./configure --enable-mpi=yes --with-beagle=no
RUN make

RUN cp mb /usr/local/bin

#Install picard

WORKDIR $BIN
RUN wget https://github.com/broadinstitute/picard/releases/download/2.18.4/picard.jar
ENV PICARD="$BIN/picard.jar"

#GATK
RUN wget https://github.com/broadinstitute/gatk/releases/download/4.0.4.0/gatk-4.0.4.0.zip
RUN  unzip gatk-4.0.4.0.zip 
ENV PATH="/usr/local/bin/gatk-4.0.4.0/:${PATH}"


#VARSCAN
ENV OPT /opt
WORKDIR $OPT

RUN apt-get install -y cmake
RUN wget http://downloads.sourceforge.net/project/varscan/VarScan.v2.3.9.jar && mv VarScan.v2.3.9.jar VarScan.jar
RUN wget https://github.com/genome/bam-readcount/archive/v0.7.4.tar.gz && tar xvzf v0.7.4.tar.gz && rm v0.7.4.tar.gz
RUN  cd /opt/bam-readcount-0.7.4 && mkdir build && cd build && cmake ../ && make deps && make -j && make install
ENV VarScan="$OPT/VarScan.jar"

#Install BWA

RUN wget https://downloads.sourceforge.net/project/bio-bwa/bwa-0.7.17.tar.bz2
RUN  tar xvjf bwa-0.7.17.tar.bz2
RUN cd bwa-0.7.17 && make
ENV PATH="$OPT/bwa-0.7.17/:${PATH}"
    
	

CMD /bin/bash -l

