[![build status](https://travis-ci.org/envygeeks/feralchimp.png?branch=master)](https://travis-ci.org/envygeeks/feralchimp/) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/envygeeks/feralchimp)

Feralchimp is a Ruby based API wrapper for the MailChimp API, it is modeled after [Gibbon](https://github.com/amro/gibbon) and it is not meant to be a replacement for the excellent [Gibbon](https://github.com/amro/gibbon)... that is unless you are seeking better control over your HTTP. On that note, it is certainly not meant to be better than the already excellent [Gibbon](https://github.com/amro/gibbon) wrapper. The idea did not spawn from hatred...well not of Gibbon, just of the fact that I had HTTParty and Faraday in the same Rails app when I could have had only Faraday.

## Installation:
```sh
gem install feralchimp
```

## Differences:
* Some Feralchimp options are named differently.
* Feralchimp supports an export chain method.
* Feralchimp will parse the export API output for you.

## Similarities:
* Both adapt as the API changes by just adjusting versions.
* Both support the export API at their basic level.
* Allowing you to choose whether or not to raise or return `{}`.

## Options:
* Feralchimp.mailchimp_key = Mailchimp key w/ region part.
* Feralchimp.raise = True or False
* Feralchimp.timeout = *Defaults:* 5
* *You can also optionally set ENV["MAILCHIMP_API_KEY"] too*

There is one setter called `exportar` (Spanish for export) that is a public but private API method so that the class can communicate with the instance when a user chains using `export`.  This variable is always reset back to false each time `#call` is called. While it won't hurt anything if you play with it (such as setting it to true,) just be warned it's internal and it's state is always reset even if it's already false and setting it to any value but false or nil will just result in you hitting the Export API.

## Normal API Usage:

    Feralchimp.new.lists #=> {}
    Feralchimp.lists #=> {}
    Feralchimp.new(api_key).lists # => {}

Using the class creates a new instance each run but you also have the option to create your own persistant instance so you can control key state.  When creating a new instance you can send an optional api key which will be set for that instance only, for example: `Feralchimp.new(api_key)`.

## Export API Usage:

    Feralchimp.new.export.list(id: list_id) #=> [{}]
    Feralchimp.export.list(id: list_id) #=> [{}]
    Feralchimp.new(api_key).export.list(id: list_id) #=> [{}]

According to the Mailchimp spec it will send a plain text list of JSON arrays delimited by `\n`, with the first JSON array being the header (AKA the hash keys) keeping in line with this we actually parse this list for you, in that we take the first JSON array and zip it into an array, like so:

    # What Mailchimp gives us:
    # ["header1", "header2"]
    # ["array1_v1", "array1_v2"]
    # ["array2_v1", "array2_v2"]

    # What we give you:
    [
      {"header1" => "array1_v1", "header2" => "array1_v2" }
      {"header1" => "array2_v1", "header2" => "array2_v2" }
    ]

This means that to work with the Export API you need do nothing more special than you already do because we handle all the hard work, if you can call it hard work considering it required very little extra code.

## API Payloads

    Feralchimp.new.list_members(id: list_id)
    Feralchimp.list_members(id: list_id)
    Feralchimp.new(api_key).list_members(id: list_id)

Feralchimp accepts a hash based payload.  This payload is not tracked by us and all we do is transform it and post it so if you would like to know more about what payloads you might need to send to Mailchimp please visit the [Mailchimp API docs](http://apidocs.mailchimp.com/api/1.3/).

## Testing and Contributing

All I ask is that you license your code the same as mine, that you sign your commit before requesting a pull request (you should also do -S if you are on Git 1.7.9+) and that you eye your coverage along with listen to simplecov and maintain 100% coverage making sure you test critical features and new features and make sure you don't break old features.

```
rake [spec|test]
BENCHMARK=true rake [spec|test]
```

## A Special Thanks

I want to send a special thanks out to [East Boulder County United](http://eastbocounited.org) who sponsored this.

## License

Copyright 2012 Jordon Bedwell & East Boulder County United.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
