Noodling with a web app to act as a facade to a Socrata store

```
bundle install
rackup
```

Then add a `.env` file containing a line like the following:

```
SOCRATA_CATALOG=data.bathhacked.org
SOCRATA_CATALOG_NAME=BathHacked
```

Then go to a dataset page using the dataset id from your Socrata instance:

```
http://localhost:9292/datasets/p3ch-yw3f
```
