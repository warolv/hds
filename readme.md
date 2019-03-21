# Health Dashboard Service

## Implemented API
  * /api/v1/health                   Get health statuses of all services
  * /api/v1/availability             Get services availability (in percentage) span over the last hour, 1m interval 
  * /api/v1/scheduled_health_check   For internal usage by cronjob, make service sampling each minute
  * /api/v1//get_last_hour_samples   Samples monitoring for the last hour

## Status
### Done
    * Tried to keep it simple as possible
    * Created simple data store (HcDataStore) which saves maximum 60 samples of each type (up / down / unknown) for each service
    * Added api versioning for case we need improve our api and upgrade to new version
    * Added api described in 'Implemented API' section
    * Added unit test coverage of main functionality


### Things that has been left out and need improvement
    * Change HcDataStore simple storage to db - to not loose all data after each app restart
    * Add logs for crontab job, every minute access must be saved to log, will be very helpfull for debugging purposes
    * Cover more functionality with tests - unit / integration tests
    * '/scheduled_health_check' api method must be filtered from outside, only for internal usage
    * Api service separation (instead of 3 request in one api - 3 seoparate apis) for better scalability/performance 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

### Prerequisites

* Installed ruby envinronment
* Linux / macosx for running cronjob

### Installing
  *  cd hds
  *  bundle install
  * whenever --update-crontab
  * ruby app.rb

## Running the tests

Explain how to run the automated tests for this system

## In case of troubles with cron jobs
  1. Stop/Clear crontab using whenever -c or crontab -r
  2. whenever --update-crontab
  3. crontab -l, then check you can see this string '* * * * * /bin/bash -l -c curl -I http://0.0.0.0:4567/api/v1/scheduled_health_check'

## Built With

* Sinatra framework
* whenever gem - provides a clear syntax for writing and deploying cron jobs

## Authors

* **Igor Zhivilo** - [warolv.net](https://warolv.net)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


