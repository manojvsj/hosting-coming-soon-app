# Build the Docker image
docker build -t coming-soon-app .

# Run the container
docker run -p 8080:8080 coming-soon-app