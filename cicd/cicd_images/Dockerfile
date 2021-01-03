FROM docker:19.03

RUN apk add --no-cache curl jq wget unzip python3 py-pip
RUN pip3 install awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
# Run AWS install
RUN ./aws/install
RUN wget https://releases.hashicorp.com/terraform/0.14.2/terraform_0.14.2_linux_amd64.zip
RUN unzip terraform_0.14.2_linux_amd64.zip && rm terraform_0.14.2_linux_amd64.zip
RUN mv terraform /usr/bin/terraform