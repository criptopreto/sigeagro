FROM postgres:13

RUN localedef -i es_VE -c -f UTF-8 -A /usr/share/locale/locale.alias es_VE.UTF-8
ENV LANG es_VE.utf8
ENV POSTGRES_PASSWORD SiGeAgro2020*-
ENV POSTGRES_USER postgres
ENV POSTGRES_DB postgres

VOLUME [ "/postgresql/data" ]

EXPOSE 5432