FROM python:3.10-slim

RUN useradd --create-home user
USER user

WORKDIR /home/user

ADD /app .

RUN pip install --no-cache-dir --user -r requirements.txt

EXPOSE 5000

CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]