#!/usr/bin/awk -f
BEGIN {
    FS  = "\t";
    OFS = "";
}
TOLOWER {
    $3 = tolower($3);
}
{
    gsub(/, /, ORS, $3);
    print $3 | "sort --parallel=$(nproc) -S1G -us";
}
