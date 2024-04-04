FROM registry.access.redhat.com/ubi8/python-311:latest

COPY requirements.txt /opt/app-root/src/requirements.txt
RUN pip install -r /opt/app-root/src/requirements.txt

COPY src /opt/app-root/src

ENV ENVIRONMENT=prod
EXPOSE 8080
ENTRYPOINT ["/opt/app-root/src/main.py"]
