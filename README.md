# Aircraft Landing

## Requirements

In order to run the programs you must have Python and Sicstus Prolog installed. For the OR Tools version you should also have the respective python library installed.

## Use and Test Instructions

For both the python and prolog programs, the file selection is done inside program by updating the see predicate and the open functions, respectively, with the path to the test file of your choice.

To run the Prolog implementation, initiate the Sisctus Prolog interpreter and then consult the aircraft_landing.pl file. Finally run the predicate:

```
aircraft_landing.
```

To run the OR Tools implementation, simply run:

```
python aircraft_landing.py
``` 