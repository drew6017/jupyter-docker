```shell
$ docker build -t drew6017/jupyter .
$ docker run --gpus all -v "C:\pathto\shared":/host -p 8888:8888 -d --name jupyter-lab-server -it drew6017/jupyter
```
Ez start/stop in Docker Desktop.
