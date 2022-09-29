#docker build -t drew6017/jupyter .
#docker run --gpus all -v "C:\pathto\shared":/host -p 8888:8888 -d --name jupyter-lab-server -it drew6017/jupyter
#ez start/stop in Docker Desktop
FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04
MAINTAINER drew6017

ENV PYTHON_VER=3.10
SHELL ["/bin/bash", "-c"]

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt install -yqq --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# install miniconda
ENV MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    MINICONDA_DIR=/opt/miniconda
ADD $MINICONDA_URL /tmp/miniconda-install.sh
WORKDIR /tmp
RUN chmod +x miniconda-install.sh && \
    ./miniconda-install.sh -bfp $MINICONDA_DIR && \
    rm -rf /tmp/* /var/lib/apt/lists/*

# setup conda env
RUN source $MINICONDA_DIR/bin/activate && \
    conda create -y --name main python=$PYTHON_VER && \
    conda activate main && \
    echo "source $MINICONDA_DIR/bin/activate && conda activate main" >> ~/.bashrc
	
RUN apt update && \
    apt install -yqq --no-install-recommends nodejs npm	
	
RUN source $MINICONDA_DIR/bin/activate && \
    conda activate main && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    conda install jupyterlab xeus-python
	
RUN source $MINICONDA_DIR/bin/activate && \
    conda activate main && \
	jupyter labextension install @telamonian/theme-darcula

# optional packages
RUN source $MINICONDA_DIR/bin/activate && \
    conda activate main && \
    pip install numpy matplotlib

ENV PORT=8888	
RUN echo -e "#!/bin/bash\n \
source $MINICONDA_DIR/bin/activate\n \
conda activate main\n \
export SHELL=/bin/bash\n \
export JUPYTERLAB_SETTINGS_DIR=/host/settings\n \
export JUPYTERLAB_WORKSPACES_DIR=/host/workspaces\n \
cd /host\n \
jupyter-lab --allow-root --ip 0.0.0.0 --port $PORT" > /start.sh && chmod +x /start.sh

CMD ["/start.sh"]
