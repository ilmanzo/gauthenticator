module base32_test;

import std.stdio;


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

void main() {
   writeln("ciao");

    
    auto expected = cast(int[]) "FOOBAR";
    writeln(base32decode("IZHU6QSBKIFA===="));
    writeln(expected);
}