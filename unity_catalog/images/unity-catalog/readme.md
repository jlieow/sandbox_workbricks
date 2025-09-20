# Unity Catalog

From [source](https://docs.unitycatalog.io/docker_compose/)

To start Unity Catalog in Docker Compose in one command, install the latest version of Docker Desktop and run the following from the project's root directory:
```
docker compose up -d
```

This starts the Unity Catalog server and UI. You can access the UI at http://localhost:3000 and the server at http://localhost:8080. Clients like DuckDB or Spark running on the host machine will be able to interact on those ports with the containers running Unity Catalog.

To use the Unity Catalog CLI, attach to a shell in the Unity Catalog server container:
```
docker exec -it unitycatalog-server-1 /bin/bash
```

Use the Unity Catalog CLI from the attached shell to interact with the server:
```
bin/uc table list --catalog unity --schema default
```

To remove the containers and persistent volumes, exit the attached shell and run the following from the host machine:
```
docker compose down --volumes --remove-orphans
```
