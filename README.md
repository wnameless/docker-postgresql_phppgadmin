docker-postgresql_phppgadmin
============================

postgresql + phpPgAdmin

```
docker pull wnameless/postgresql-phppgadmin
```

Run with 22, 80 and 5432 ports opened:
```
docker run -d -p 49160:22 -p 49161:80 -p 49162:5432 wnameless/postgresql-phppgadmin
```

Open http://localhost:49161/phppgadmin in your browser with following credential:
```
username: postgres
password: postgres
```

Login by SSH
```
ssh root@localhost -p 49160
password: admin
```
