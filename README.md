http_data_getter
=====

Simple http server which provides data obtaining from desired storage.
To perform data obtaining process you should specify data key as a part of query string:
```
   http://localhost:8080?key=sample1
```
http_data_getter returns the following HTTP codes:
- 200: value has been successfully obtained
- 400: wrong query params or key not found
- 500: internal server error (please contact support team)
- 503: limit for getting the value has been exceeded

http_data_getter provides two sample files(for the test purposes) for the file system adapter:
- priv/sample1
- priv/sample2

Howto run
-----
It's recommended to launch http_data_getter server in the docker container as:
```
 docker build -t http_data_getter .
 docker run -it -p 8080:8080 http_data_getter
```

Using
-----
You can use curl or another http client to communicate with http_data_getter server:
```
curl -i -H "Accept: text/plain" http://localhost:8080?key=sample2
HTTP/1.1 200 OK
content-length: 0
content-type: text/plain
date: Wed, 02 Jun 2021 15:01:50 GMT
server: Cowboy

curl -i -H "Accept: text/plain" http://localhost:8080?key=sample
HTTP/1.1 400 Bad Request
content-length: 0
content-type: text/plain
date: Wed, 02 Jun 2021 15:02:14 GMT
server: Cowboy
```

Load testing
-----
To perform load testing you should do the following:
```
    rebar3 compile
    ct_run -dir test -logdir logs
```
loggdir directory should exist
