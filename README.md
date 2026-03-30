## 1. Prerequisites
Before running the commands, ensure you have a basic Flask app structure:
* `app.py`: Your Flask code.
* `requirements.txt`: Contains `Flask`.
* `Dockerfile`: The instructions for Docker.

---

## 2. The Setup Commands
If you are doing this manually for the first time, here is the workflow:

### Install Docker
* **Linux (Ubuntu):** `sudo apt update && sudo apt install docker.io -y`
* **Mac/Windows:** Download [Docker Desktop](https://www.docker.com/products/docker-desktop/).

### Build and Run
1.  **Build the image:** `docker build -t flask-app:v1 .`
2.  **Run the container:** `docker run -p 5000:5000 flask-app:v1`

---

## 3. Project Files

### Dockerfile Explained
```dockerfile
# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app


# Install any needed packages specified in requirements.txt
COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Run app.py when the container launches
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
```



---

## 4. README.md (v1.0)
You can copy the content below directly into your project's `README.md` file.

```markdown
# Flask Dockerized App - v1.0.0

This project contains a simple Flask web application running inside a Docker container.

## Version Info
- App Version: v1.0
- Status: Stable
- Features: Basic Flask routing, Dockerized environment.

## Installation & Setup

### 1. Install Docker
- Ubuntu: `sudo apt update && sudo apt install docker.io -y`
- Windows/Mac: Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).

### 2. Build the Docker Image
Navigate to the project root directory and run:

bash
docker build -t flask-app:v1 .
```

### 3. Run the Flask App
Launch the container and map port 5000 of your machine to port 5000 of the container:
```bash
docker run -d -p 5000:5000 --name flask-v1 flask-app:v1
```
If error occurs replace 5000:5000 port mapping to 5001:5000, 5002...:5000. If and only when 5000 port is occupied by other application. 

### 4. Access the App
### Open your browser and go to: `http://localhost:5000`
\
**If Port Changed**: In place of 5000 place your port that you replaced with. 
\
eg. `http://localhost:5001` for `5001`. 

### 5. App Structure
```
.
├── app.py
├── requirements.txt
├── Dockerfile
└── templates/
    └── index.html
```


## Container Management
- **Stop the app:** `docker stop flask-v1`
- **Remove container:** `docker rm flask-v1`
- **View logs:** `docker logs flask-v1`


---
\
**Quick Tip:** Make sure your `app.py` is configured to listen on all network interfaces by using `app.run(host='0.0.0.0')`, otherwise you might not be able to reach it from your browser even if the container is running!
