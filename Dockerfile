FROM          alpine:3.6

COPY          entrypoint.sh /entrypoint.sh

ENV           CONFIG_NAME 0

ENTRYPOINT    ["/entrypoint.sh"]

CMD           ["default_arg"]
