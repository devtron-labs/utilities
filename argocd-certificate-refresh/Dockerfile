FROM ubuntu:20.04
RUN apt update && apt install curl git -y
WORKDIR /app
COPY argocd.sh .
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.1/bin/linux/amd64/kubectl
RUN chmod u+x kubectl && mv kubectl /bin/kubectl
CMD ["./argocd.sh"]