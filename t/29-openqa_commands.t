#!/usr/bin/env perl -w
# Copyright (C) 2017 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;
use FindBin;
use lib ("$FindBin::Bin/lib", "../lib", "lib");
use Test::More tests => 3;
use OpenQA;
use Test::Output 'combined_like';

subtest _run => sub {
    combined_like sub {
        OpenQA::_run(
            "fake",
            sub {
                Devel::Cover::report() if Devel::Cover->can('report');
                exit 0;
            });
    }, qr/fake started with pid/;
};

subtest _stopAll => sub {
    combined_like sub {
        OpenQA::_run("fake", sub { 42 });
        OpenQA::_stopAll();
    }, qr/stopping fake with pid /;
};

subtest run => sub {
    $ARGV[0] = "";
    my $touched;
    use Mojo::Util 'monkey_patch';
    monkey_patch "OpenQA::WebAPI", run => sub { $touched++; };
    OpenQA::run();
    is $touched, 1 or diag $touched;
};

1;
