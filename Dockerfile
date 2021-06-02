FROM erlang:alpine

RUN mkdir /http_getter_app
WORKDIR /http_getter_app
COPY . /http_getter_app

EXPOSE 8080

ENTRYPOINT rebar3 shell --config server.config --apps http_data_getter
