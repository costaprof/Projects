FROM ubuntu:latest
RUN apt-get update && apt-get install -y build-essential
WORKDIR /app
COPY container.cpp .
RUN g++ -o container container.cpp -std=c++11 -pthread
CMD ["./container"]




#********************************************
#FROM ubuntu:latest AS build

#RUN apt-get update && apt-get install -y build-essential

#WORKDIR /app

#COPY container.cpp .

#RUN g++ -o container container.cpp -std=c++11 -pthread

#**********************************************
#FROM ubuntu:latest

# Copy the compiled binary from the build stage
#COPY --from=build /app/container /app/container

#WORKDIR /app

#CMD ["./container"]

