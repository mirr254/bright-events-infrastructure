#!/bin/bash
source /app/venv/bin/activate
python manage.py db migrate
python manage.py db upgrade
exec gunicorn -b :5000 --access-logfile - --error-logfile - run:app
# equivalent to "from myproject import run as app"