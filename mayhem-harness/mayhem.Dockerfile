FROM forallsecure/debian-buster

WORKDIR /opt/mayhem
COPY build/mayhem-harness-exe /opt/mayhem

EXPOSE 8000 8000

ENTRYPOINT ["/opt/mayhem/mayhem-harness-exe"]