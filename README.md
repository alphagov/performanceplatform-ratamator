#performanceplatform-ratamator

This repo holds a simple script application for use with the [Performance Platform](https://www.gov.uk/performance).

The application:
* extracts data from a dataset using the platform 'Read API'
* calculates the ratio of two metrics within the record
* uploads the new data records to dataset using the platform  ['Write API'](http://performance-platform.readthedocs.org/en/latest/api/write-api.html)

NOTE: This application is an interim solution until the platform can support this type of transform 

##Purpose
The Platform has an automated feed of consulate appointment available and used hours.  Each record contains information about:

* consulate
* service
* available hours
* used hours

e.g.
```
{
    _id: "MjAxNS0wNi0wNlQwMDowMDowMFpkYXlCcml0aXNoIEhpZ2ggQ29tbWlzc2lvbiBPdHRhd2FhcHBvaW50bWVudA==",
    _timestamp: "2015-06-06T00:00:00+00:00",
    available_hours: 8.0,
    consulate: "British High Commission Ottawa",
    period: "day",
    service: "appointment",
    used_hours: 5.5
}
```

The need is for a record to contain both the available and used hours and the ratio of the two

The  'utilisation rate' is calculated as:

'used hours'/'available hours'

The 'rate' is then appended to the record, un-required tags removed, and uploaded to the platform in an different dataset.

e.g.
```
{
    _id: "MjAxNS0wNS0yOFQwMDowMDowMCswMDowMC5kYXkuQnJpdGlzaCBIaWdoIENvbW1pc3Npb24gR2VvcmdldG93bi5hcHBvaW50bWVudA==",
    _timestamp: "2015-05-28T00:00:00+00:00",
    available_hours: 6.0,
    consulate: "British High Commission Georgetown",
    period: "day",
    service: "appointment",
    used_hours: 3.0,
    utilisation_rate: 0.5
},
```
 
##Running the application
To view the options for running the application:
```
$ ./bin/pp-ratamator -h
```

To see the application run options:
```
$ ./bin/pp-ratamator -h go
```

To run the application:
```
$ ./bin/pp-ratamator go --environment=<environment> --verbose=<verbose-flag> --recordperiod=<no. of days> --dryrun=<dryrun-flag> --upload=<upload>  --bearer=<bearer-token>
```

The main purpose of the application is to automate the extraction, transformation and upload of json data, but it can be configured to output a csv formatted file for manual upload to the platform.


