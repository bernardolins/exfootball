# Exfootball

This is an example application to show [FakeServer](https://github.com/bernardolins/fake_server) in action.

## Application structure

This application uses [Tesla](https://github.com/teamon/tesla) to fetch data from [football-data API](https://www.football-data.org). The HTTP client used to fetch the data can be found at [lib/external](https://github.com/bernardolins/exfootball/tree/master/lib/external) folder. FakeServer was used to test this client. The tests are can be found at [test/external](https://github.com/bernardolins/exfootball/tree/master/test/external) folder.
