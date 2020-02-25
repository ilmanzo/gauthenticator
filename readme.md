## Google Authenticator
A small D program to generate the google authenticator code.

inspired from https://github.com/tilaklodha/google-authenticator

- Install D Language https://dlang.org/ 
- Install Dub package manager 
    - On OSX run `brew install dub`.
    - Follow instructions on https://code.dlang.org/ for other OSes.

- Provide your 16-digit secret token in secrets.pem file

The auth code works on the secret token and the current time. The time on your local machine should be in sync according to NTP.

- Run `sudo ntpdate time.nist.gov` to sync time
- Run `rdmd example\runme.d`.

