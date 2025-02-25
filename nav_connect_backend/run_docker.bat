docker stop nav-container
docker rm nav-container
docker build -t nav-connect .
docker run -d -p 8000:8000 --name nav-container nav-connect