FROM ging/ptp

RUN rm -rf ./cep
RUN mkdir ./cep
COPY runPTP.py ./
COPY cepCode.py ./
COPY ./cep ./cep
COPY requirements.txt ./
COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/
RUN pip install --no-cache-dir -r requirements.txt
RUN cd ./cep && mvn clean compile package

CMD ["python","-u","./runPTP.py"]
