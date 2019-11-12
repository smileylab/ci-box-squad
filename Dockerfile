# There is no official container for squad
FROM debian:buster

RUN apt-get update && \
    apt-get install -qy auto-apt-proxy && \
    apt-get install -qy \
        python3 \
        python3-celery \
        python3-coreapi  \
        python3-django \
        python3-django-cors-headers \
        python3-django-crispy-forms \
        python3-django-simple-history \
        python3-django-filters \
        python3-djangorestframework \
        python3-djangorestframework-filters \
        python3-gunicorn \
        python3-jinja2 \
        python3-markdown \
        python3-msgpack \
        python3-psycopg2 \
        python3-dateutil \
        python3-yaml \
        python3-zmq \
        python3-requests \
        python3-sqlparse \
        python3-svgwrite \
        python3-whitenoise \
        rabbitmq-server \
        wget \
        unzip

ARG extra_packages=""
RUN apt -q update && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install ${extra_packages}

ARG version="master"
WORKDIR /app
#ADD https://github.com/Linaro/squad/archive/${version}.zip .
ADD https://github.com/loicpoulain/squad/archive/${version}.zip .


RUN unzip ${version}.zip
RUN mv squad-${version}/* .

RUN ln -sfT squad/container_settings.py /app/squad/local_settings.py

RUN python3 -m squad.frontend
RUN ./manage.py collectstatic --noinput --verbosity 0
RUN cd /app && python3 setup.py develop

COPY ./scripts/populate.sh /root/populate.sh
COPY ./scripts/create_project.py /root/create_project.py
COPY ./scripts/create_backend_lava.py /root/create_backend_lava.py
COPY ./scripts/entrypoint.sh /root/entrypoint.sh

#USER squad
ENV SQUAD_STATIC_DIR /app/static
ENV ENV production

ARG ampq_server="localhost"
ENV SQUAD_CELERY_BROKER_URL=amqp://${ampq_server}

ARG port_http=80
ENV SQUAD_PORT=${port_http}

ARG lava_server=""
ENV LAVA_SERVER=${lava_server}
ARG lava_username=""
ENV LAVA_USERNAME=${lava_username}
ARG lava_token=""
ENV LAVA_TOKEN=${lava_token}

ARG group=""
ENV SQUAD_GROUP=${group}
ARG projects=""
ENV SQUAD_PROJECTS=${projects}

ARG admin_username=root
ARG admin_password=password
ARG admin_email=$admin_username@localhost.com
ARG admin_token="2d703e793ea345efdbab52d95fe33ec715bcc2d4"
RUN /root/populate.sh ${admin_username} ${admin_password} ${admin_email} ${admin_token}

RUN useradd --create-home squad
RUN mkdir -m 0755 /app/tmp && chown squad:squad /app/tmp

ENTRYPOINT ["/root/entrypoint.sh"]
