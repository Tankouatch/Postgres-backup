# Use the official PostgreSQL 14 image
FROM postgres:14.10

# Install AWS CLI and other dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    python3-pip \
    python3-dev \
    groff \
    less \
    vim \
    jq \ 
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -f awscliv2.zip

# Install yq
# Note: Replace the version number with the latest version from https://github.com/mikefarah/yq/releases
RUN curl -Lo /usr/bin/yq "https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_linux_amd64" \
    && chmod +x /usr/bin/yq

# Create a directory for the backups
RUN mkdir /backups

# Copy the backup script into the container

COPY backup-to-s3.sh .
RUN chmod +x backup-to-s3.sh

CMD [ "./backup-to-s3.sh" ]

