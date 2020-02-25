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

import std.stdio;

class GAuthenticator
{

    // HMAC-based One Time Password(HOTP)
    public string getHOTPToken(const string secret, const ulong interval)
    {
        /*
        auto key=base32decode(secret);
        hash = HMAC-SHA1(key)
        offset = last nibble of hash
        truncatedHash := hash[offset..offset+3]  //4 bytes starting at the offset
        Set the first bit of truncatedHash to zero  //remove the most significant bit
        code := truncatedHash mod 1000000
        pad code with 0 from the left until length of code is 6
        return code */

        return "000000";
    }

    //Time-based One Time Password(TOTP)
    public string getTOTPToken(const string secret)
    {
        //The TOTP token is just a HOTP token seeded with every 30 seconds.
        import std.datetime : Clock;

        immutable ulong interval = Clock.currTime().toUnixTime() / 30;
        return getHOTPToken(secret, interval);
    }

    //RFC 4648
    public int[] base32decode(const string message)
    {
        int buffer = 0;
        int bitsLeft = 0;
        int[] result;
        for (int i = 0; i < message.length; i++)
        {
            int ch = message[i];
            writeln(ch);
            if (ch == ' ' || ch == '\t' || ch == '\r' || ch == '\n' || ch == '-')
            {
                continue;
            }
            buffer <<= 5;

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
                ch -= '2' - 26;
            }

            buffer |= ch;
            bitsLeft += 5;
            if (bitsLeft >= 8)
            {
                result ~= (buffer >> (bitsLeft - 8));
                bitsLeft -= 8;
            }

        }
        return result;

    }

    unittest
    {
        const base32 = "gr6d 5br7 25s6 vnck v4vl hlao re======";

    }

    /*
    unittest
    {
        auto ga = new GAuthenticator;
        auto secret = "dummySECRETdummy";
        auto interval = ulong(50780342);
        auto otp = "971294";
        assert(otp == ga.getHOTPToken(secret, interval));
    }
*/

}

unittest
{
    writeln("ciao");

    auto ga = new GAuthenticator();
    auto expected = cast(int[]) "FOOBAR";
    writeln(ga.base32decode("IZHU6QSBKIFA===="));
    writeln(expected);
}
