use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Bancuri',
  VERSION      => '1.0',
  AUTHOR       => 'Viorel Stirbu <viorels@gmail.com>',
  EXE_FILES    => ['bancuri.pl'],
  PREREQ_PM    => {'Catalyst' => '5.60'},
  test         => {TESTS => 't/*.t'}
);

