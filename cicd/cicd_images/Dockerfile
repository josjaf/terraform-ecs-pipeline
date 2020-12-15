FROM docker:19.03

RUN apk add --no-cache curl jq python3 py-pip wget
RUN pip3 install awscli
RUN wget https://releases.hashicorp.com/terraform/0.14.2/terraform_0.14.2_linux_amd64.zip
RUN unzip terraform_0.14.2_linux_amd64.zip && rm terraform_0.14.2_linux_amd64.zip
RUN mv terraform /usr/bin/terraform