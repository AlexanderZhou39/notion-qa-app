FROM python:3.8

WORKDIR /app

ARG OPENAI_API_KEY
ENV OPENAI_API_KEY=$OPENAI_API_KEY

RUN mkdir frontend && mkdir backend

# backend setup
COPY backend/requirements.txt ./backend/
RUN cd backend && pip3 install -r requirements.txt
COPY ./backend/ ./backend/

RUN apt-get update && apt-get install -y \
    software-properties-common \
    npm
RUN npm install npm@latest -g && \
    npm install n -g && \
    n latest
RUN npm install -g yarn
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
CMD [ "gunicorn", "server:app", "-k", "uvicorn.workers.UvicornWorker" ]
