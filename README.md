# README

This project is a web application that allows you to synchronize a [noCRM](https://www.nocrm.io) account
with a Salesforce account. You can map your lead fields and your sales pipeline step
to Salesforce ones.

:warning: DISCLAIMER : This project is a proof of concept and not meant to be used in production at this stage

## What you need to test the app

- A noCRM account: if you don't have a noCRM account yet, you can [create a free trial account now](https://www.nocrm.io)
  - your **account subdomain**
  - and an **API key**
- A **[Salesforce Developer Edition](https://developer.salesforce.com/signup)** account with
  - an application with **API and OAuth settings enabled**
    - Set the callback URL to `https://APP_URL/auth/salesforce/oauth2callback` (`APP_URL` being the public URL of this app)
    - Add "Full Access (full)", "Manage user data via API (api)" scopes: this is what we did for our tests but you might want to reduce to concerned scopes
      in production
  - your **Consumer key**
  - and your **Consumer secret**

## Deployment instructions

Try it yourself !

[![Deploy on Scalingo](https://cdn.scalingo.com/deploy/button.svg)](https://my.scalingo.com/deploy?source=https://github.com/nocrm-io/salesforce-connector#main)

:warning: Small step to get the app running, go to your app environment and change `mysql://` to `mysql2://` in the  `SCALINGO_MYSQL_URL` variable and re-deploy

## Development instructions

### Configuration

Create the `master.key` file

```
echo "d502c5963932c2fca52d0399db6fc0c1" > config/master.key
```

### Database creation

```
rails db:setup
```

###  Asset compilation
```ruby
yarn build
yarn build:css
```

### Run the app

If you have the [foreman gem](https://github.com/ddollar/foreman) installed, simply run

```
foreman start
```

Otherwise, run

```
rails s
```

and these two commands to automatically recompile the assets

```
yarn build --watch
yarn build:css --watch
```
