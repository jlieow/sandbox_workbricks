# Docker image with Jupyter notebook and PySpark
docker pull quay.io/jupyter/pyspark-notebook
docker run -p 8888:8888 quay.io/jupyter/pyspark-notebook

This will make every file in your /home/YourUserName/jupyter folder accessible inside your container via /home/jovyan and vice versa! So things you save in /tmp while working inside your container will then be available on your host in that previously declared folder:

```
DIR=/Users/jerome.lieow/Documents/Jupyter
docker run -it -p 8888:8888 -p 4040:4040 -v $DIR:/home/jovyan --rm --name jupyter quay.io/jupyter/pyspark-notebook
```

From [issue](https://github.com/jupyter/docker-stacks/issues/1003), to resolve permission error `PermissionError: [Errno 13] Permission denied: '/home/jovyan/.local'` use:
```
DIR=/Users/jerome.lieow/Documents/Jupyter
docker run --user root -v $DIR:/home/jovyan \
  -e CHOWN_HOME=yes -e CHOWN_HOME_OPTS='-R' \
  -it -d -p 8888:8888 -p 40401:4040 --name jupyter quay.io/jupyter/pyspark-notebook
```

To run in detached mode, you need to retrieve the token from the container logs:
```
DIR=/Users/jerome.lieow/Documents/Jupyter
docker run --user root -v $DIR:/home/jovyan \
  -e CHOWN_HOME=yes -e CHOWN_HOME_OPTS='-R' \
  -it -d -p 8888:8888 -p 4040:4040 --name jupyter quay.io/jupyter/pyspark-notebook
docker logs jupyter
```

# Look for token during docker container startup logs

```
    To access the server, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/jpserver-7-open.html
    Or copy and paste one of these URLs:
        http://localhost:8888/lab?token=2fdc0cf8221a73fb238fc8b8b0cd0e9e111b130bcc55645b
        http://127.0.0.1:8888/lab?token=2fdc0cf8221a73fb238fc8b8b0cd0e9e111b130bcc55645b
```

# Install Netcat

Exec into container, update packages, install netcat

```
docker exec -it jupyter /bin/bash
sudo apt-get update
sudo apt-get install ncat -y

ncat -l 9999
```