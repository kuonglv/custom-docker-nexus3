# custom-docker-nexus3
A custom Dockerfile for Sonatype Nexus 3 with pre inited dependencies

## Introduce
By default, when we run a Nexus application form Docker image, it inits with empty repositories (without jars files in repo) util we build a project, Spring boot using Maven for example.

A requirement to have an image with pre-loaded dependencies then I create this Dockerfile with jar files copied from host into container. 
When the Nexus up and running, the user can be able to download dependencies right away

## Docker build
To build image, execute following command:

```sh
docker build -t name:ver .
```

To run:

```sh
docker run -p 8081:8081 name:ver
```
To access on web browser: 

```sh
http://localhost:8081/nexus
```

To login: admin/admin123
