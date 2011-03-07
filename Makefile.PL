
use strict;
use warnings;



use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'A framework for dataflow processing',
  'AUTHOR' => 'Alexei Znamensky <russoz@cpan.org>',
  'BUILD_REQUIRES' => {
    'English' => '0',
    'File::Find' => '0',
    'File::Temp' => '0',
    'Test::More' => '0.94',
    'Test::UseAllModules' => '0',
    'aliased' => '0',
    'common::sense' => '0',
    'perl' => '5.004'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'DataFlow',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'DataFlow',
  'PREREQ_PM' => {
    'Carp' => '0',
    'Data::Dumper' => '0',
    'DateTime' => '0',
    'Encode' => '0',
    'HTML::TreeBuilder::XPath' => '0',
    'LWP::Curl' => '0',
    'List::Util' => '0',
    'Moose' => '0',
    'Moose::Role' => '0',
    'Moose::Util::TypeConstraints' => '0',
    'MooseX::OneArgNew' => '0',
    'MooseX::Traits' => '0',
    'MooseX::Types::IO' => '0',
    'Queue::Base' => '0',
    'SQL::Abstract' => '0',
    'Scalar::Util' => '0',
    'Text::CSV' => '0',
    'WWW::Mechanize' => '0'
  },
  'VERSION' => '0.91.06',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



