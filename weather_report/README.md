# Weather Report

A Python script to measure temp, humidity and atmosperic pressure from DHT22 and LPS331AP sensors connected to Raspberry Pi and send them to Google BigQuery via Fluentd.

## Set up RasPi 

On your host computer, use Ansible for setting up your RasPi with the playbook.

```
> ansible-playbook weather_report.yml
```

## Set up BigQuery 

### Create a table

On your host computer, create a table on BigQuery to store the metrics. Google Cloud SDK is required.

```
> bq mk -t <your-project-id>:<your_dataset>.weather_report wr_bqschema.json
```

### Create a service account

Next, you'll create an OAuth service account for accessing BigQuery from RasPi.

- Open console.developers.google.com
- Open your project
- Click APIs & auth > Credentials > Create new Client ID
- Select Service account and click Create Client ID. This will start downloading a new private key for the service account

### Setting up fluentd.conf

Next, you'll configure Fluentd to access BigQuery with the service account

- Copy the private key file on the RasPi's weather_report/ directory
- Edit fluentd.conf to add `email` and `private_key_path`

## Run

### Run Fluentd

On your RasPi, run Fluentd.

```
> cd ~/raspi/weather_report
> fluentd -c fluentd.conf
```

Open another console, run the python script.

```
> cd ~/raspi/weather_report
> sudo python weather_report.py

## Run query on BigQuery

Run the following query on BigQuery Web UI to check if the metrics are inserted.

```
SELECT * FROM [YOUR_PROJECT_ID:YOUR_DATASET.YOUR_TABLE] LIMIT 1000
```


