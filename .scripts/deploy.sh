#!/bin/bash
set -e

echo "Deployment started ..."

# Pull the latest version of the app
echo "Copying New changes...."
git pull origin main
echo "New changes copied to server !"


# copying  media files to media folder
echo "Copying css files...."
# cp -r /home/ubuntu/BookStoreEcommerce/public/media/* /var/www/bookstore/media

if [ -d "/home/ubuntu/BookStoreEcommerce/public/media" ] && [ "$(ls -A /home/ubuntu/BookStoreEcommerce/public/media)" ]; then
    echo "Copying media files..."
    cp -r /home/ubuntu/BookStoreEcommerce/public/media/* /var/www/bookstore/media
else
    echo "Media directory is empty or does not exist, skipping file copy."
fi


# Activate Virtual Env
#Syntax:- source virtual_env_name/bin/activate
source venv/bin/activate
echo "Virtual env 'venv' Activated !"

echo "Installing Dependencies..."
pip install -r requirements.txt --no-input

echo "Clearing Cache..."
python manage.py clean_pyc
python manage.py clear_cache

echo "Serving Static Files..."
python manage.py collectstatic --noinput

echo "Running Database migration..."
# python manage.py makemigrations
python manage.py migrate

# Deactivate Virtual Env
deactivate
echo "Virtual env 'venv' Deactivated !"


echo "reloading redis server"
sudo systemctl restart redis-server


echo "reloading celery and celery beat"
# sudo supervisorctl restart all
sudo systemctl restart celery.service
sudo systemctl restart celerybeat.service



echo "Reloading App..."
#kill -HUP `ps -C gunicorn fch -o pid | head -n 1`
ps aux |grep gunicorn |grep bookShop | awk '{ print $2 }' |xargs kill -HUP

echo "Deployment Finished !"