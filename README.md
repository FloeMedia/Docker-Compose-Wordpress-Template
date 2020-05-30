Docker Compose Wordpress Template
---

The Easiest Way To Create a Development or Production Wordpress Environment With Docker / Docker Compose

## Getting Started

**Clone or [download & extract](https://github.com/FloeMedia/Docker-Compose-Wordpress-Template/archive/master.zip) the repo.**

```bash
git clone https://github.com/FloeMedia/Docker-Compose-Wordpress-Template.git
```

## For Development

If you are developing a custom theme or plugin, uncomment (remove the `#`) any of the example lines in `docker-compose.yml` and adjust as needed.

```yaml
       #- ./my-theme:/var/www/html/wp-content/themes/my-theme
       #- ./my-plugin:/var/www/html/wp-content/plugins/my-plugin
```

Then, when you're all set...

```bash
docker-compose up -d
```

## For Production

So, the the biggest consideration for production use is changing the credentials that are set in the `.env` file. You can directly edit that `.env` file, but then you shouldn't push that file to any sort of git repo - you'd have to gitignore it.

A better solution is to override the environmental variables set in that file by...setting environmental variables. `docker-compose up` like this.

```bash
env DB_NAME=wordpress \
    DB_USER=wordpress \
    DB_PASSWORD=wordpress \
    DB_ROOT_PASSWORD=worpdress \
    docker-compose up -d
```

Adjust all above values to be secure. Use a password generator.
