# Dockerfile for DMARC viewer app
# Use Alpine as stripped down OS
FROM python:3.6-slim

# Install build deps, then run `pip install`, then remove unneeded build deps
# all in a single step. Correct the path to your production requirements file,
# if needed.
RUN set -ex \
	&& apt update \
    && apt upgrade -fy \
    && apt install -fy build-essential \
            curl \
            git \
            jq \
            mariadb-client \
            unzip \
            tar \
            libc-dev \
            libcairomm-1.0-dev \
            libffi-dev \
            libmariadb-dev \
            libmariadb-dev-compat \
            libpcre++-dev \
            libpq5 \
            libpq-dev \
 && apt clean \
 && python3 -m pip install -U pip

# Copy in your requirements file
ADD requirements.txt /requirements.txt

RUN python3 -m pip install --no-cache-dir -r /requirements.txt \
    && python3 -m pip install --no-cache-dir uwsgi

RUN set -ex \
 && curl -sL $(curl -sL https://api.github.com/repos/maxmind/geoipupdate/releases/latest | jq -Mr '.assets[].browser_download_url' | grep -E 'geoipupdate_[0-9.]+_linux_amd64.tar.gz') | tar x -z -C /usr/local/bin --strip-components=1 --wildcards "g*/geoipupdate" \
    && find /usr/local \
        \( -type d -a -name test -o -name tests \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
        -exec rm -rf '{}' +
    # Commented code removes runtime dependencies `CairoSVG`
    # FIXME: Find out how to detect those dependencies with scanelf
    # && runDeps="$( \
    #         scanelf --needed --nobanner --recursive /usr/local \
    #                 | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    #                 | sort -u \
    #                 | xargs -r apk info --installed \
    #                 | sort -u \
    # )" \
    # && apk add --virtual .python-rundeps $runDeps \
    # && apk del .build-deps

# Copy your application code to the container (make sure you create a
# .dockerignore file if any large files or directories should be excluded)
RUN mkdir /code/ \
    mkdir /imapbox

WORKDIR /code/
ADD . /code/


# uWSGI will listen on this port
EXPOSE 8000

# NOTE: Other user-set app environment variables (app key, db pw, ...) are
# passed through from `docker-compose`. If you didn't create the container with
# `docker-compose` you have to pass the required environment variables to
# `docker run`, e.g. using the `-e` flag
ENV DJANGO_SETTINGS_MODULE="dmarc_viewer.settings"

# Configure uWSGI using environment variables
# NOTE: When passed as environment variables, options are capitalized and
# prefixed with UWSGI_, and dashes are substituted with underscores
# See http://uwsgi-docs.readthedocs.io/en/latest/Options.html
ENV UWSGI_WSGI_FILE=dmarc_viewer/wsgi.py \
    UWSGI_HTTP=:8000 \
    UWSGI_MASTER=1 \
    UWSGI_WORKERS=2 \
    UWSGI_THREADS=8 \
    UWSGI_UID=1000 \
    UWSGI_GID=2000 \
    UWSGI_LAZY_APPS=1 \
    UWSGI_WSGI_ENV_BEHAVIOR=holy \
    UWSGI_HTTP_AUTO_CHUNKED=1 \
    UWSGI_HTTP_KEEPALIVE=1 \
    UWSGI_STATIC_MAP=/static=/var/www/dmarc_viewer/static

ENTRYPOINT ["/code/docker-entrypoint.sh"]

# Start uWSGI
CMD ["uwsgi"]
