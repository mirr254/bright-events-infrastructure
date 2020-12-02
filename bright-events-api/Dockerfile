FROM python:3.8-slim

RUN adduser brightevents 

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
     git \
     gcc \
     libpq-dev \
     libc-dev \
     && rm -rf /var/lib/apt/lists/*

ARG BRIGHT_EVENTS_BRANCH='development'

RUN git clone --branch ${BRIGHT_EVENTS_BRANCH} https://github.com/mirr254/Bright-Events.git /tmp/

RUN cp /tmp/requirements.txt requirements.txt 
RUN python -m venv venv \
    && venv/bin/python -m pip install --upgrade pip

RUN venv/bin/pip install -r requirements.txt \
    && venv/bin/pip install gunicorn

RUN cp -r /tmp/app app \
    && cp -r /tmp/migrations migrations \
    && cp -r /tmp/instance instance \
    && cp /tmp/manage.py /tmp/run.py ./ 

#cleanup
RUN rm -rf /tmp/tests /tmp/Designs 

COPY /scripts/boot.sh ./
RUN chmod +x boot.sh 


# env vars
ENV DATABASE_URL='postgresql://postgres:postgres@localhost:5432/bright_events' \
    SECRET_KEY='change-this' \
    SECURITY_PASSWORD_SALT='change-this' \
    SECURITY_PASSWORD_RESET_SALT='change-salt'

#gmail authentication
ENV APP_MAIL_USERNAME='mail-username' \
    APP_MAIL_PASSWORD='mail-passwrd' \
    MAIL_DEFAULT_SENDER='sammysteppa90@gmail.com'

#mail server env
ENV MAIL_SERVER='smtp.gmail.com' \
    MAIL_PORT=465 \
    MAIL_USE_TLS=False \
    MAIL_USE_SSL=True


ENV FLASK_APP=run.py \
    APP_SETTINGS=development

RUN chown -R brightevents:brightevents ./
USER brightevents

EXPOSE 5000
ENTRYPOINT [ "./boot.sh" ]


