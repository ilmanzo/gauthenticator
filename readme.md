## Google Authenticator
A small D library to generate the google authenticator code.

inspired from https://github.com/tilaklodha/google-authenticator

- Install D Language https://dlang.org/ 
- Install Dub package manager 
    - On OSX run `brew install dub`.
    - Follow instructions on https://code.dlang.org/ for other OSes.


The OTP auth code works on the secret token and the current time. 
The time on your local machine should be in sync according to NTP.
The secret token usually is given to the user on the first configuration as a base32-encoded string or acquired via QR code.

The library exposes two functions:

- getHOTPToken
   given a "secret" and a time interval, returns the 6-digit HOTP Token as a string
- getTOTPToken
   given a "secret", returns the 6-digit TOTP Token as a string using the current time





