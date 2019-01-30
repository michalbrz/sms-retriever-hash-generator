# SmsRetriever hash generator

### What is [SmsRetriever](https://developers.google.com/identity/sms-retriever/overview)

It is relatively new mechanism from Google that lets you handle SMS verification in your app without accessing SMSes directly. Just read here(https://developers.google.com/identity/sms-retriever/overview) for more info.

### Why SmsRetriever hash generator?

To use SmsRetriever you need hash that needs to be included in SMS sent from server. This hash is harder to generate than I thought:
- script provided in docs doesn't work for me (they get stuck and I don't want to fight with bash scripts)
- if you use Google Play signing, generating hash is not that obvious.

So I decided to wrap bash magic into Ruby script - for easier modification and easier usage.

### Usage?

To run script from console: `ruby google_play_sign.rb` with parameters:
```
--package NAME               Your app package, e.g com.test.app
--google-play-key KEY_PATH   Google Play public key (in DER format) used to sign release app
--keystore KEYSTORE_PATH     Path to keystore (.jks file)
--keystore-password PASSWORD Password to the keystore - required only when option "--keystore" is specified
--key-alias KEY_ALIAS        Alias of key in the keystore - required only when option "--keystore" is specified
-h, --help                   Prints this help
```

So basically for generating hash **from Google Play signing public key**:

`ruby google_play_sign.rb --package com.your.app --google-play-key deployment_key.der `

and for generating hash **from local keystore**:

`ruby google_play_sign.rb --package com.your.app --keystore keystore.jks --keystore-password mypassword --key-alias myalias`


### Credits

This Ruby script is based on bash script from https://github.com/googlesamples/android-credentials/blob/master/sms-verification/bin/sms_retriever_hash_v9.sh made by @ithinkihaveacat.
