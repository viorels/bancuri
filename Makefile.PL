use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Bancuri',
  VERSION      => '1.0',
  AUTHOR       => 'Viorel Stirbu <viorels@gmail.com>',
  EXE_FILES    => ['bancuri.pl'],
  PREREQ_PM    => {
    'Catalyst' => '5.80005', # 5.80005
    'Catalyst::Log::Log4perl' => '1.03',
    'Catalyst::Plugin::ConfigLoader' => '0.23',
    'Catalyst::Plugin::Session' => '0.24',
    'Catalyst::Plugin::Session::State::Cookie' => '0.11',
    'Catalyst::Plugin::Session::Store::DBIC' => '0.09',
    'Catalyst::Plugin::Authentication' => '0.10013',
    'Catalyst::Plugin::Authorization::Roles' => '0.07',
    'Catalyst::Plugin::Unicode' => '0.91',
    'Catalyst::Plugin::DateTime' => '0.03',
    'Catalyst::Plugin::Scheduler' => '0.09',
    'Catalyst::Plugin::Static::Simple' => '0.21',
    'Catalyst::Plugin::StackTrace' => '0.10',
    'Catalyst::Authentication::Store::DBIx::Class' => '0.1082',
    'Catalyst::Model::Xapian' => '0.04',
    'Catalyst::Model::Adaptor' => '0.03',
    'Catalyst::View::TT' => '0.29',
    'Catalyst::View::JSON' => '0.25',
    'Data::Dump' => '1.14',
    'Data::SpreadPagination' => '0.1.2',
    'DateTime' => '0.50',
    'DateTime::Duration' => '',
    'Digest::SHA' => '5.47',
    'Email::Valid' => '0.181',
    'Encode' => '2.33',
    'HTML::Entities' => '3.60',
    'List::MoreUtils' => '0.22',
    'List::Util' => '1.21',
    'MIME::Lite::TT::HTML' => '0.04',
    'Math::Random' => '0.71',
    'NEXT' => '0.64',
    'Regexp::Assemble' => '0.34',
    'Scalar::Util' => '1.21',
    'Search::Sitemap' => '2.08',
    'Search::Tools' => '0.22',
    'Search::Tools::Transliterate' => '0.22',
    'Search::Tools::UTF8' => '0.22',
    'Search::Xapian' => '1.0.13.1',
    'Storable' => '2.20',
    'String::Diff' => '0.04',
    'Time::HiRes' => '1.9719',
    'URI' => '1.38',
    'XML::Feed' => '0.43',
  }, 
  test         => {TESTS => 't/*.t'}
);

