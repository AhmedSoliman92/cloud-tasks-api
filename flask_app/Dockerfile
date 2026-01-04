FROM python:3.14-slim

WORKDIR /flask-app


COPY . .
RUN pip3 install --no-cache-dir -r requirements.txt

CMD ["gunicorn", "-c", "gunicorn.conf.py", "app:app"]
