# Use the official PostgreSQL 14 image
FROM postgres:14.10

# Install AWS CLI to interact with S3
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    python3-pip \
    python3-dev \
    groff \
    less \
    vim \
    && rm -rf /var/lib/apt/lists/*
# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -f awscliv2.zip
RUN echo "consider configuring AWS CLI using environment variables or by mounting you .aws directory."
# Create a directory for the backups
RUN mkdir /backups

# Copy the backup script into the container
COPY backup-to-s3.sh .
RUN chmod +x backup-to-s3.sh

CMD [ "./backup-to-s3.sh" ]

#ENV AWS_DEFAULT_REGION="us-east-1"
ENV DB_USER='doadmin'
ENV DB_NAME='s6-user'
ENV DB_HOST='db-postgresql-nyc3-26515-do-user-12198957-0.c.db.ondigitalocean.com'

