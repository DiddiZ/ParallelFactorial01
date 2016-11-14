FROM ubuntu:16.04

# Update the operating system and install gdc:
RUN apt-get update && apt-get install -y gdc

# Add source files
COPY . /d

# Compile them
RUN gdc /d/src/*.d -o /d/main

# Provide entrypoint
ENTRYPOINT ["/d/main"]