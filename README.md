DMARC viewer
------
DMARC viewer is a Django based web-app that lets you visually analyze DMARC aggregate reports. The tool differs between incoming and outgoing reports. Incoming reports you receive from foreign domains (reporter) based on e-mail messages, the reporter received, purportedly from you. Outgoing reports on the other hand you send to foreign domains based on e-mail messages that you received, purportedly by them. To analyze reports you need to use the provided parser management command and parse your reports into your database.

To receive DMARC reports for you mailing domain(s) just add a simple DNS entry, e.g.:
```shell
v=DMARC
````

Learn more about DMARC at [dmarc.org](https://dmarc.org/)

## Installation
### System Dependencies
- Python2.7
- [Cairo](https://www.cairographics.org/download/)
- [Postgres](https://docs.djangoproject.com/en/1.8/ref/databases/#postgresql-note)

### Create Postgres Database and user
```shell
# Assuming `postgres` is th default user
$ psql -U postgres
postgres=# CREATE DATABASE dmarc_viewer_db;
postgres=# CREATE USER dmarc_viewer_db WITH PASSWORD '**** YOU BETTER CHANGE THIS *********';
postgres=# GRANT ALL PRIVILEGES ON DATABASE dmarc_viewer_db TO dmarc_viewer_db;
```

### Clone and install Django app
```
# FIXME update url
git clone dmarc-viewer

pip install -r requirements.txt

python manage.py makemigrations website
python manage.py migrate

python manage.py runserver
```

### Download Maxmind GeoLite2 City

The dmarc viewer report parser uses [Maxmind's GeoLite2 City](http://geolite.maxmind.com/download/geoip/database) database to
retrieve geo information for IP addresses.
Download [`GeoLite2-City.mmdb.gz`](http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz) to the project root (and keep it up to date), to retrieve geo information when parsing your DMARC reports:

```shell
# In the project root
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz
gunzip GeoLite2-City.mmdb.gz
```
You can also point the `settings.GEO_LITE2_CITY_DB` to an existing GeoLite2-City db on your system.


### Parse reports
Once you have your incoming and outgoing reports, you can feed them into DMARC viewer's database with the following commands:
```shell
python manage.py parse [--type (in|out)] (<dmarc-aggregate-report>.xml | dir/to/reports) ...
```

### Import Analysis Views

Use this command to create some basic 'analysis views' that you can use to
analyze your data. The loaded views can easily be modified and extended via the
web interface on the 'view management' page.

```
python manage.py loadviews
```


## Install Apache and mod_wsgi
https://docs.djangoproject.com/en/1.10/topics/install/#install-apache-and-mod-wsgi


## Contribute

### Frontend
Per default all JS and CSS code is served from
[`website/static/dist`](website/static/dist) (fonts from
[`website/static/fonts`](website/static/fonts)).

If you want to make changes to frontend code, take a look at
[`package.json`](package.json), where 3rd party dependencies are defined
and at [`Gulpfile.js`](Gulpfile.js), which provides task runners to compile
and build frontend code.

Also set [`settings.TEMPLATE_SETTINGS.use_dist`](dmarc_viewer/settings.py) to
`False` in order to serve the original local JavaScript files.

Below are the most important commands to handle frontend code, all executed
from the root of the project:

#### Download dependencies
Download and install dependencies defined in `package.json` to `node_modules`.
```shell
npm install
```
#### Auto-compile SCSS
All custom styles should be written in `website/static/sass`. The command below
watches the file for changes and automatically creates a new CSS file in
`website/static/css`.
```shell
gulp watch-styles
```

#### Create new dist files
Create new dist files after having modified SCSS code (make sure it is
compiled), local JS code (in [`website/static/js`](website/static/js)) or
3rd party frontend code (don't modify 3rd party code directly, rather
add/remove/update via `package.json`).

```shell
gulp create-dist
```
