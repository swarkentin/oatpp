FROM forallsecure/debian-buster

COPY build/main-prefix/src/main-build /opt/mayhem
WORKDIR /opt/mayhem

EXPOSE 8000 8000

ENTRYPOINT ["/opt/mayhem/mayhem-harness-exe"]