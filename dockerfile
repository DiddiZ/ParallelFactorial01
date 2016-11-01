FROM ubuntu:16.04

# Update the operating system and install gdc:
RUN apt-get update && apt-get install -y gdc

# Add source files
COPY . /d

# Compile them
RUN gdc /d/main.d -o /d/main.o

# Provide entrypoint
ENTRYPOINT ["/d/main.o"]