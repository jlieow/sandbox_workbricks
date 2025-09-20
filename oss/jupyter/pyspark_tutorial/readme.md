# Docker image with Jupyter notebook and PySpark
Note: Image repo - https://quay.io/organization/jupyter

docker pull quay.io/jupyter/pyspark-notebook
docker run -p 8888:8888 quay.io/jupyter/pyspark-notebook

This will make every file in your /home/YourUserName/jupyter folder accessible inside your container via /home/jovyan and vice versa! So things you save in /tmp while working inside your container will then be available on your host in that previously declared folder:

```
DIR=/Users/jeromelieow/jupyter
docker run -it -p 8888:8888 -v $DIR:/home/jovyan --rm --name jupyter quay.io/jupyter/pyspark-notebook
```

# Look for token during docker container startup logs

```
    To access the server, open this file in a browser:
        file:///home/jovyan/.local/share/jupyter/runtime/jpserver-7-open.html
    Or copy and paste one of these URLs:
        http://localhost:8888/lab?token=2fdc0cf8221a73fb238fc8b8b0cd0e9e111b130bcc55645b
        http://127.0.0.1:8888/lab?token=2fdc0cf8221a73fb238fc8b8b0cd0e9e111b130bcc55645b
```

# Tutorial

https://github.com/anshlambagit/PySpark-Full-Course/tree/main/DATA%20and%20NOTEBOOK
https://github.com/anshlambagit/PySpark-Full-Course/tree/main/DATA%20and%20NOTEBOOK