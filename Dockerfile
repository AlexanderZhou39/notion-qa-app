FROM node:18

WORKDIR /app

ARG OPENAI_API_KEY
ENV OPENAI_API_KEY=$OPENAI_API_KEY

RUN mkdir frontend && mkdir backend

# backend setup
COPY backend/requirements.txt ./backend/
RUN : \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        software-properties-common \
    && add-apt-repository -y ppa:deadsnakes \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3.8-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && :

RUN python3.8 -m venv /venv
ENV PATH=/venv/bin:$PATH
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
