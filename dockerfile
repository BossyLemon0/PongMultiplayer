# Use a base image with Love2D installed
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    love \
    libgl1-mesa-glx \
    libopenal1 \
    libvorbisfile3 \
    libphysfs1 \
    libmodplug1 \
    libmpg123-0 \
    libtheora0 \
    libogg0 \
    liblua5.1-0 \
    libluajit-5.1-2

# Set the working directory
WORKDIR /src/app

# Copy the game files to the container
COPY . .

# Command to run the game
CMD ["love", "."]