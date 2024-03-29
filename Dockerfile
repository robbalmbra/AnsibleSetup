FROM ubuntu:18.04
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y openssh-server pwgen netcat net-tools curl wget && \
    apt-get clean all

RUN apt-get update && apt-get install -y \ 
 python3 \
 build-essential \ 
 python3-dev \ 
 libxml2-dev \ 
 libxslt-dev \ 
 libssl-dev \ 
 zlib1g-dev \ 
 libyaml-dev \ 
 libffi-dev \ 
 python3-pip

RUN pip3 install --upgrade pip \ 
 virtualenv \ 
 requests

RUN ln -s /usr/bin/python3 /usr/bin/python
RUN ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
RUN mkdir /var/run/sshd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN mkdir /root/.ssh

COPY id_rsa.pub /root/.ssh/authorized_keys
RUN chmod 400 /root/.ssh/authorized_keys

EXPOSE 22 
CMD ["/usr/sbin/sshd", "-D"]
