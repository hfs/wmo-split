#!/usr/bin/env perl

use strict;
use warnings;

use Fcntl qw(:seek);

unshift(@ARGV, '-') unless @ARGV;
INPUT_FILE: while (my $input_file = shift) {
    open(my $in, '<', $input_file)
        or die ("Can't open '$input_file' for reading: $!");
    binmode($in);
    my $buffer;
    while ( (read ($in, $buffer, 10)) != 0 ) {
        # Expect 10 bytes header:
        # 8 bytes length as ASCII number
        # 2 bytes type indicator ASCII 00 or 01
        if (length($buffer) != 10) {
            warn("Unexpected end of file in '$input_file'");
            close($in);
            next INPUT_FILE;
        }
        if ($buffer !~ m/(\d{8})(\d{2})/) {
            my $pos = tell($in) - 10;
            my $pos_info = "";
            if ($pos >= 0) {
                $pos_info = ", byte $pos_info";
            }
            warn("Broken length header in file '$input_file'$pos_info: Expected /\\d{10}/, but got '$buffer'");
            close($in);
            next INPUT_FILE;
        }
        my $length = $1;
        my $format = $2;
        if ($format ne "00") {
            warn("Unsupported format '$format' in '$input_file'");
            close($in);
            next INPUT_FILE;
        }
        next if $length <= 0;
        my $messageheader;
        if ((read($in, $messageheader, 10)) != 10) {
            warn("Unpexpected end of file in '$input_file'");
            close($in);
            next INPUT_FILE;
        }
        if ($messageheader !~ m/^\x01\x0D\x0D\x0A(\d{3,5})\x0D/) {
            my $pos = tell($in) - 10;
            my $pos_info = "";
            if ($pos >= 0) {
                $pos_info = ", byte $pos_info";
            }
            my $hex = join(' ', unpack('(H2)*', $messageheader));
            warn("Broken message header in file '$input_file'$pos_info: Expected x0D x0A x0A nnn(nn)? x0D, but got '$hex'");
            close($in);
            next INPUT_FILE;
        }
        my $counter = $1;

        my $output_file = "$input_file-$counter";
        open(my $out, ">", $output_file)
            or die("Can't open output file '$output_file' for writing: $!");
        print $out $messageheader;
        my $rest = $length - 10;
        while ((my $read = read($in, $buffer, $rest)) != 0) {
            print $out $buffer;
            $rest -= $read;
        }
        close($out);
    }
}
