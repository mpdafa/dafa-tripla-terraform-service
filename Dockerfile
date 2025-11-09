FROM python:3.14-slim

WORKDIR /app

# COPY requirements.txt .
# RUN pip3 install -r requirements.txt

RUN pip install flask gunicorn python-hcl2

COPY . .

RUN mkdir -p terraform

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "main:app"]