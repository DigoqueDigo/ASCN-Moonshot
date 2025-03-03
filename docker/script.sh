#!/bin/bash

echo ">>> Running migration"
python manage.py migrate

if [ "$seed_database" == "true" ]; then
    echo ">>> Running seed"
    python seed.py
fi

echo ">>> Starting app..."
python manage.py runserver 0.0.0.0:8000