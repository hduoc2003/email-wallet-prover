# Sử dụng một hình ảnh Ubuntu 22.04 làm cơ sở
FROM ubuntu:22.04

# Cài đặt các gói cần thiết
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    nodejs \
    npm \
    git

WORKDIR /code
RUN git clone https://github.com/zkemail/email-wallet

WORKDIR /code/email-wallet/packages/prover
RUN apt-get install -y curl
RUN npm install -g snarkjs@latest
RUN pip install -r requirements.txt
RUN mkdir /root/params
RUN mkdir -p build
RUN curl https://email-wallet-trusted-setup-ceremony-pse-p0tion-production.s3.eu-central-1.amazonaws.com/circuits/emailwallet-account-creation/contributions/emailwallet-account-creation_00019.zkey --output /root/params/account_creation.zkey
RUN curl https://email-wallet-trusted-setup-ceremony-pse-p0tion-production.s3.eu-central-1.amazonaws.com/circuits/emailwallet-account-init/contributions/emailwallet-account-init_00007.zkey --output /root/params/account_init.zkey
RUN curl https://email-wallet-trusted-setup-ceremony-pse-p0tion-production.s3.eu-central-1.amazonaws.com/circuits/emailwallet-account-transport/contributions/emailwallet-account-transport_00005.zkey --output /root/params/account_transport.zkey
RUN curl https://email-wallet-trusted-setup-ceremony-pse-p0tion-production.s3.eu-central-1.amazonaws.com/circuits/emailwallet-claim/contributions/emailwallet-claim_00006.zkey --output /root/params/claim.zkey
RUN curl https://email-wallet-trusted-setup-ceremony-pse-p0tion-production.s3.eu-central-1.amazonaws.com/circuits/emailwallet-email-sender/contributions/emailwallet-email-sender_00006.zkey --output /root/params/email_sender.zkey
RUN chmod +x circom_proofgen.sh

CMD [ "python3", "local.py" ]
