[![Build Status](https://travis-ci.org//gregoirejh/final_project.svg?branch=master)](https://travis-ci.org/gregoirejh/final_project)

# Final Project

## 🚦 Routes

#### GET /login

> Renders the login page  

#### GET /signin

> Renders the signin page  

#### GET /addMetrics

> Renders the addMetrics page  

#### GET /logout

> Renders the logout page  

#### GET /Logging

> Renders the logs of the current session  

#### GET /metrics.json

> Fetches the metrics of the current user  

#### POST /login

> Authenticates an user 

```javascript
{
  username: String,
  password: String,
}
``` 

#### POST /signin

> Adds an user 

```javascript
{
  username: String,
  password: String,
}
``` 

#### POST /metrics.json

> Adds a new metric to the user's ones

```javascript
{
  username: String,
  password: String,
}
or
[
  {
    timestamp: String,
    value: Number,
  }
]
```

#### DELETE /metrics.json/:key

> Deletes the target metric

## 🛠 Testing

Only critical parts of the code have been tested (users-related and metrics-related actions). We have been using [ShouldJS](https://shouldjs.github.io/) for expectations and [SinonJS](http://sinonjs.org/) for mocking.

## 🚀 CI

Our CI relies on Travis that runs all the tests.
