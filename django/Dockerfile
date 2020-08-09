FROM python:3.8-alpine

RUN mkdir -p /code
WORKDIR /code
COPY requirements.txt /code

RUN python -m pip install --upgrade pip
RUN \
    apk add --no-cache postgresql-libs && \
    apk add --no-cache --virtual .build-deps gcc musl-dev postgresql-dev && \
    python3 -m pip install -r requirements.txt --no-cache-dir && \
    apk add bash && \
    apk --purge del .build-deps

COPY . /code

RUN mkdir -p sigeagro/static/admin