wmo-split
=========

Split file bundles in WMO’s FTP format


Usage
-----

```
wmo_split.pl file(s)
```


Why?
----

WMO GTS combines many small files into larger files when transferring them via FTP to reduce the per-file overhead.

When working with meteorological data you might encounter this format when grabbing input files from a GTS live data stream.

The format is defined in WMO No. 386 Vol I “Manual on the Global Telecommunication System”, Attachment II-15, Section 4. TCP/IP, Subsection “FTP Procedures”.


Format description
------------------

Single files are prefixed by their length in bytes and a format identifier and then concatenated into the collection file.

Bytes | Meaning
------|--------
8     | Message 1 length n₁
2     | Format identifier
n₁    | Message 1
8     | Message 2 length n₂
2     | Format identifier
n₂    | Message 2

The message itself consists of control characters, a sequence number, a heading and the content itself.

Bytes  | Meaning                            | Comment
-------|------------------------------------|---------
8      | Message 1 length n₁                |
2      | Format identifier: ASCII “00” = Starting Line and End of Message present |
       | *or* ASCII “01” = Starting Line and End of Message absent (deprecated)   |
4      | SOH CR CR LF (= ASCII 01 13 13 10) | ⎫
3 or 5 | sequence number as ASCII number    | ⎪
       | Heading                            | ⎬ Included in message length
       | Text                               | ⎪
4      | CR CR LF ETX (= ASCII 13 13 10 03) | ⎭
8      | Message 2 length n₂                |
…      | …                                  |
