FROM ubuntu:18.04
RUN apt-get update -y
RUN apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:openjdk-r/ppa

RUN apt-get update
RUN apt-get update -y && apt-get install -y python3 python3-pip python3-dev
RUN apt-get -y install openjdk-8-jdk wget tar

RUN pip3 install --upgrade "pip < 21.0"
RUN pip3 install psycopg2-binary
RUN pip3 install boto3
RUN pip3 install awscli
RUN pip3 install aiobotocore
RUN pip3 install s3fs
RUN pip3 install fsspec
RUN pip3 install pyspark==2.4.3 findspark
RUN pip3 install pytest
RUN pip3 install moto
RUN pip3 install mock
RUN pip3 install pytest-mock
RUN pip install pytest-cov

RUN wget https://archive.apache.org/dist/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz
RUN tar -xzf spark-2.4.3-bin-hadoop2.7.tgz
RUN mv spark-2.4.3-bin-hadoop2.7 /spark
RUN rm spark-2.4.3-bin-hadoop2.7.tgz

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV SPARK_HOME /spark
ENV HADOOP_HOME /hadoop

ENV PATH $JAVA_HOME/bin:$PATH
ENV PATH $SPARK_HOME/bin:$PATH
ENV PATH $HADOOP_HOME/bin:$PATH
ENV PATH /usr/bin/python3:$PATH
ENV PYSPARK_PYTHON=python3
ENV PYTHONPATH="$PYTHONPATH:../"
COPY spark-defaults.conf /spark/conf
COPY . /dataloader

RUN touch /dataloader/conftest.py
WORKDIR /dataloader

RUN mkdir /root/.aws
COPY config /root/.aws
COPY dataloader_config.json /app/config.json
ENV AWS_REGION=us-west-2

ARG env=local
ENV image=$env

ENTRYPOINT [ "python3", "-m", "pytest", "--cov=.", "--cov-report", "xml:cov.xml", "--cov-report", "term", "--cov-report", "html:/dataloader/dataloder_coverage", "--cov-fail-under=85" ]
