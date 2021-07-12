FROM docker:19.03

RUN apk add --no-cache curl jq wget unzip python3 py-pip
RUN pip3 install awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
# Run AWS install
RUN ./aws/install
RUN wget https://releases.hashicorp.com/terraform/1.0.2/terraform_1.0.2_linux_arm64.zip
RUN unzip terraform_1.0.2_linux_arm64.zip
RUN mv terraform /usr/bin/terraform