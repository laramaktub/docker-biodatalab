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


WORKDIR $SRC

RUN apt-get update && apt-get install -y cmake

RUN apt-get install -y rsync

ENV TRINITY_VERSION="2.8.5"
ENV TRINITY_CO="d35f3c1149bab077ca7c83f209627784469c41c6"

WORKDIR $SRC

RUN git clone https://github.com/trinityrnaseq/trinityrnaseq.git && \
    cd trinityrnaseq && \
    git checkout $TRINITY_CO && \
    make && make plugins && \
    make install && \
    cd ../ && rm -r trinityrnaseq

ENV TRINITY_HOME /usr/local/bin/trinityrnaseq

ENV PATH=${TRINITY_HOME}:${PATH}


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

RUN  apt-get install -y mrbayes


#Install picard

WORKDIR $BIN
RUN wget https://github.com/broadinstitute/picard/releases/download/2.18.4/picard.jar
ENV PICARD="$BIN/picard.jar"

#GATK
RUN wget https://cephrgw01.ifca.es:8080/swift/v1/datalabbio/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef.tar.bz2 
RUN tar -xjvf GenomeAnalysisTK-3.8-1-0-gf15c1c3ef.tar.bz2
RUN mv /usr/local/bin/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar /usr/local/bin/gatk.jar
RUN chmod a+x /usr/local/bin/gatk.jar

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
    
#Install bowtie2

ENV ZIP=bowtie2-2.2.9-linux-x86_64.zip
ENV URL=https://github.com/BenLangmead/bowtie2/releases/download/v2.2.9/
ENV FOLDER=bowtie2-2.2.9


RUN wget $URL/$ZIP -O $BIN/$ZIP && \
    unzip $BIN/$ZIP -d $BIN && \
    rm $BIN/$ZIP && \
    mv $BIN/$FOLDER/* $BIN && \
rmdir $BIN/$FOLDER	

## Samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.7/samtools-1.7.tar.bz2 && \
    tar xvf samtools-1.7.tar.bz2 && \
    cd samtools-1.7/ && \
    ./configure && make && make install


