/+
MIT License
Copyright (c) 2020 Andrea Manzini
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
+/

module gauthenticator;

import std.digest.hmac : HMAC;
import std.digest.sha : SHA1,toHexString;
import std.bitmanip : nativeToBigEndian,bigEndianToNative;
import std.format : format;

// code adapted from https://github.com/tilaklodha/google-authenticator

/// HMAC-based One Time Password(HOTP)
public string getHOTPToken(const string secret, const ulong interval)
{
    //secret is a base32 encoded string. Converts to a byte array
    auto key = base32decode(secret);
    //Signing the value using HMAC-SHA1 Algorithm
    auto hm = HMAC!SHA1(key);
    hm.put(nativeToBigEndian(interval));
    ubyte[20] sha1sum = hm.finish();
	// We're going to use a subset of the generated hash.
	// Using the last nibble (half-byte) to choose the index to start from.
	// This number is always appropriate as it's maximum decimal 15, the hash will
	// have the maximum index 19 (20 bytes of SHA1) and we need 4 bytes.    
    const int offset = (sha1sum[19] & 15);
    ubyte[4] h = sha1sum[offset .. offset + 4];
	//Ignore most significant bits as per RFC 4226.
	//Takes division from one million to generate a remainder less than < 7 digits    
    const uint h12 = (bigEndianToNative!uint(h) & 0x7fffffff) % 1_000_000;
    return format("%06d",h12);
}

/// Time-based One Time Password(TOTP)
public string getTOTPToken(const string secret)
{
    //The TOTP token is just a HOTP token seeded with every 30 seconds.
    import std.datetime : Clock;
    immutable ulong interval = Clock.currTime().toUnixTime() / 30;
    return getHOTPToken(secret, interval);
}

//RFC 4648 base32 implementation
private ubyte[] base32decode(const string message)
{
    int buffer = 0;
    int bitsLeft = 0;
    ubyte[] result;
    for (int i = 0; i < message.length; i++)
    {
        int ch = message[i];
        if (ch == '=')
            break;
        if (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n' || ch == '-')
        {
            continue;
        }
        buffer = buffer << 5;

        // Deal with commonly mistyped characters
        if (ch == '0')
        {
            ch = 'O';
        }
        else if (ch == '1')
        {
            ch = 'L';
        }
        else if (ch == '8')
        {
            ch = 'B';
        }

        // Look up one base32 digit
        if ((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z'))
        {
            ch = (ch & 0x1F) - 1;
        }
        else if (ch >= '2' && ch <= '7')
        {
            ch -= ('2' - 26);
        }

        buffer |= ch;
        bitsLeft += 5;
        if (bitsLeft >= 8)
        {
            const c = (buffer >> (bitsLeft - 8));
            result ~= cast(byte)(c & 0xff);
            bitsLeft -= 8;
        }

    }
    return result;

}
//test for base32 decoder
unittest
{
    auto expected = cast(byte[])("FOOBAR");
    auto message = base32decode("IZHU6QSBKI");
    assert(message == expected);
    expected = cast(byte[])("12345test");
    message = base32decode("GEZDGNBVORSXG5A=");
    assert(message == expected);
}

// test for SHA1 func
unittest
{
    SHA1 hash;
    hash.start();
    auto data = cast(ubyte[])"abc";
    hash.put(data);
    ubyte[20] result = hash.finish();
    assert(toHexString(result) == "A9993E364706816ABA3E25717850C26C9CD0D89D");
}

//final test for OTP functionality (with a fixed time)
unittest
{
    auto secret = "dummySECRETdummy";
    auto interval = ulong(50_780_342);  // D allows underscore in numbers to improve readability
    const otp = "971294";
    assert(otp == getHOTPToken(secret, interval));
}
