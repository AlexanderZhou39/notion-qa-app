FROM node:18

WORKDIR /app

ARG OPENAI_API_KEY
ENV OPENAI_API_KEY=$OPENAI_API_KEY

RUN mkdir frontend && mkdir backend

# backend setup
COPY backend/requirements.txt ./backend/
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get install -y python3.8
RUN ln -s /usr/bin/python3.8 /usr/bin/python
RUN apt-get install -y python3-pip
RUN cd backend && pip3 install -r requirements.txt

# frontend setup
COPY frontend/package.json ./frontend/
COPY frontend/yarn.lock ./frontend/
RUN cd frontend && yarn install
COPY ./frontend/ ./frontend/
RUN cd frontend && yarn build

# combine app
RUN mv ./frontend/dist ./backend/

EXPOSE 8000
WORKDIR /app/backend
CMD [ "gunicorn", "-k", "uvicorn.workers.UvicornWorker", "--daemon" ]
