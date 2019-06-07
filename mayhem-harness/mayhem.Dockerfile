FROM forallsecure/debian-buster

COPY build/mayhem-harness-exe /opt/mayhem
WORKDIR /opt/mayhem

EXPOSE 8000 8000

ENTRYPOINT ["/opt/mayhem/mayhem-harness-exe"]