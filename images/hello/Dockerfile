FROM ubuntu:latest
COPY ./script.sh /
RUN chmod +x /script.sh
RUN echo "$(date)" > /build_time.txt
# Set the entrypoint to the script with CMD arguments
ENTRYPOINT ["/script.sh"]
CMD [ "hulk", "batman", "superman"]