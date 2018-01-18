FROM          alpine:3.6

COPY          entrypoint.sh /entrypoint.sh

ENV           CONFIG_OPTIONAL _
ENV           CONFIG_DEFAULT default
ENV           CONFIG_REQUIRED !

ENTRYPOINT    ["/entrypoint.sh"]

CMD           ["default_arg"]
