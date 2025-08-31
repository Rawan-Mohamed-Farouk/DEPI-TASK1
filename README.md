# DEPI-TASK1
## 1. Install Nginx

bash
sudo apt update
sudo apt install nginx -y


Check status:

bash
systemctl status nginx


Visit http://localhost → you should see “Welcome to Nginx!”.

---

## 2. Install PHP and connect to Nginx

### Install PHP + PHP-FPM:

bash
sudo apt install php-fpm php-mysql -y


---

### Way 1: Connect Nginx to PHP *via TCP port*

Edit config:

bash
sudo nano /etc/nginx/sites-available/default


Replace location ~ \.php$ block with:

nginx
location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass 127.0.0.1:9000;
}


Restart:

bash
sudo systemctl restart nginx php7.4-fpm


---

### Way 2: Connect Nginx to PHP *via UNIX socket*

Change to:

nginx
fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;


Restart services:

bash
sudo systemctl restart nginx php7.4-fpm


Now PHP is working both via *port* and *socket*.

---

## 3. Run Spring PetClinic in WSL

We’ll clone the project and run with Maven.

bash
sudo apt install git maven openjdk-21-jdk -y
git clone https://github.com/spring-projects/spring-petclinic.git
cd spring-petclinic
./mvnw spring-boot:run


Visit: http://localhost:8080

---

## 4. Create Multi-stage Dockerfile

Create a file called Dockerfile:

dockerfile
# Build stage
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
RUN git clone https://github.com/spring-projects/spring-petclinic.git .
RUN mvn -q -DskipTests package

# Runtime stage
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar /app/petclinic.jar
EXPOSE 8080
CMD ["java", "-jar", "/app/petclinic.jar"]


Build and run:

bash
docker build -t petclinic .
docker run -p 8080:8080 petclinic


---

## 5. Docker Compose: App + MySQL + Postgres

Create docker-compose.yml:

yaml
version: '3.8'
services:
  app:
    build: .
    depends_on:
      - mysql
      - postgres
    ports:
      - "8080:8080"
  mysql:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: petclinic
      MYSQL_USER: petclinic
      MYSQL_PASSWORD: petclinic
    ports:
      - "3306:3306"
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: petclinic
      POSTGRES_PASSWORD: petclinic
      POSTGRES_DB: petclinic
    ports:
      - "5432:5432"


Run everything:

bash
docker compose up -d --build
