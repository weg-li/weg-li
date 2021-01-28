![Build Status](https://github.com/weg-li/weg-li/workflows/build/badge.svg)
[![Financial Contributors on Open Collective](https://opencollective.com/weg-li/all/badge.svg?label=financial+contributors)](https://opencollective.com/weg-li)

# 📸 📝 ✊ weg-li: 1, 2, 3 - Macht die Bahn frei!

https://www.weg.li/

![weg-li: 1, 2, 3 - Macht die Bahn frei!](https://user-images.githubusercontent.com/48745/62852900-12304300-bceb-11e9-8ba4-3303c83c7dfc.png)

## Installation

You can either run the application locally or via Docker.

### Local setup

To run weg-li locally, you'll need:

- Ruby
- PostgreSQL
- NodeJS & Yarn
- Redis


#### Quick setup for Linux (Ubuntu)

See [this guide](https://gorails.com/setup/ubuntu/20.10) which guides you through installing Ruby, Rails and PostgreSQL.

Complete the setup by installing the Redis server at the end.

```bash
apt install redis
```

#### Quick setup for Mac OS

Please follow [this guide](https://guides.railsgirls.com/install) if you have not ever installed Ruby on your computer.

```bash
# global setup
brew install rbenv # ruby environemnt

brew install postgresql # database
createuser -s postgres # create general purpose postgres user

brew install imagemagick # image-processing

# project setup
bin/setup
```

```bash
# install ruby runtime
rbenv install

# run this to start the rails process
script/server
```

### Docker setup

```bash
docker-compose up
```

## Contributing

### Create admin user

After installing the dependencies and running the server, you should be able to log in via “email” by visiting [http://localhost:3000/sessions/email](http://localhost:3000/sessions/email) and following the prompts. No email will be sent - the generated email is opened in your browser.

Once you have successfully authenticated, make your user an admin: Start the rails console (run `rails c` in your project directory), then enter `User.last.update(access: 'admin')`, which should result in `=> true`. Now you should be able to access the admin interface at [/admin](http://localhost:3000/admin/).

### Importing base data

For proper functionality, you need to populate your database with *districts*.

To fabricate random districts, run `rake dev:data`. This will synthesize all the kinds of data you need to get dashboards, stats, etc. working right.

If you want to get as close as possible to a “production” system, the easiest way is to import data from the production instance. Download an export format from `https://www.weg.li/districts.csv` (or `.json`) and import it into your local database. Example using the rails console (`rails c`):

```ruby
> districts = JSON.parse(URI.open('https://www.weg.li/districts.json').read); districts.count
=> 3377
> District.insert_all!(districts.map{ |x| x.except('personal_email').merge({'flags': x['personal_email'] ? 1 : 0}) }); District.count
=> 3377
```

### Secrets and keys

You need to set the following environment variables to enable full functionality for weg-li:

```bash
GITHUB_CONSUMER_KEY=github-key
GITHUB_CONSUMER_SECRET=github-secret

TWITTER_CONSUMER_KEY=twitter-key
TWITTER_CONSUMER_SECRET=twitter-secret

GOOGLE_CONSUMER_KEY=google-key
GOOGLE_CONSUMER_SECRET=google-secret
```

These are used to let users authenticate with the different providers. Learn how to create your own keys: [GitHub](https://docs.github.com/en/free-pro-team@latest/developers/apps/creating-an-oauth-app), [Twitter](https://developer.twitter.com/en/docs/apps/overview), [Google](https://developers.google.com/identity/sign-in/web/sign-in).

In addition, weg-li uses Google Cloud Storage for storing uploaded data and Google Cloud Vision to read license plates and determine car makes and colors. You will need to [create a Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) and set up the required API access for *Google Cloud Storage* and *Google Cloud Vision*. Be aware that you might be billed for Google Cloud usage. Please refer to the Google Cloud documentation, and set the following environment variables accordingly:

```bash
GOOGLE_CLOUD_PROJECT=google-cloud-project-id
GOOGLE_CLOUD_KEYFILE=path/to/project/keyfile/gcloud.json
```

For local use, you can put these variables into a `.env` file in the project directory, and the `dotenv` gem will automatically make them available to your rails app. (See `.env-example`.)

## Contributors

### Code Contributors

Dieses Projekt existiert dank aller Menschen, die dazu beitragen.

<a href="https://github.com/weg-li/weg-li/graphs/contributors"><img src="https://opencollective.com/weg-li/contributors.svg?width=890&button=false" /></a>

### Financial Contributors

Werden Sie ein finanzieller Spender und helfen Sie uns, unsere Gemeinschaft zu erhalten. [[Beitragen](https://opencollective.com/weg-li/contribute)]

#### Individuals

<a href="https://opencollective.com/weg-li"><img src="https://opencollective.com/weg-li/individuals.svg?width=890"></a>

#### Organizations

Unterstützen Sie dieses Projekt mit Ihrer Organisation. Ihr Logo wird hier mit einem Link zu Ihrer Website angezeigt.[[Beitragen](https://opencollective.com/weg-li/contribute)]

<a href="https://opencollective.com/weg-li/organization/0/website"><img src="https://opencollective.com/weg-li/organization/0/avatar.svg"></a>



## License

"THE (extended) BEER-WARE LICENSE" (Revision 42.0815): [phoet](mailto:ps@nofail.de) contributed to this project.

As long as you retain this notice you can do whatever you want with this stuff.
If we meet some day, and you think this stuff is worth it, you can buy me some beers in return.
