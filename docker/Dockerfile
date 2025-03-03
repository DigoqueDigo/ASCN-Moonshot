# Use an official Python base image
FROM python:3.11.5-slim

# Copy moonshot application to docker
COPY ./moonshot /var/www/moonshot

# Copy script
COPY ./script.sh /var/www/moonshot

# Set the working directory
WORKDIR /var/www/moonshot

# Move the environment .env.example to .env
RUN mv .env.example .env

# Expose port 8000
EXPOSE 8000

# Copy start script
COPY ./script.sh .

# Add execution permission to start script
RUN chmod +x script.sh

# Install project requirements
RUN pip install -r requirements.txt

# Run migrations and start application
CMD ["./script.sh"]
