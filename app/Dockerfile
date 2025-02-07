FROM python:3.12-slim

# Set the working directory
WORKDIR /api_app

COPY . /api_app

# Install dependencies
RUN pip install --upgrade pip -r requirements.txt

# Reminder to expose the port for Flask app
EXPOSE 5000

# Run app
CMD ["python", "connectionAPI.py"]