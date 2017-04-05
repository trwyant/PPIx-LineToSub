use strict;
use warnings;

use ExtUtils::MakeMaker;

( my $mmv = ExtUtils::MakeMaker->VERSION ) =~ s/_//g;

my %args = (
    NAME		=> 'PPIx::LineToSub',
    ABSTRACT     => 'Find package and subroutine by line of PPI document',
    VERSION_FROM => 'lib/PPIx/LineToSub.pm',
    PREREQ_PM => {
	'Carp'			=> '0',
        'PPI::Document'		=> '0',
	'PPIx::Utilities::Node'	=> '0',
        'Test::More'		=> '0',
        'strict'		=> '0',
        'warnings'		=> '0',
    },
    PL_FILES => {},	# Prevent old MakeMaker from running Build.PL
    AUTHOR       => [
	'Leon Brocard <acme@astray.com>',
	'Thomas R. Wyant, III <wyant at cpan dot org>',
    ],
    realclean	=> {
	FILES	=> 'cover_db',
    },
);

$mmv >= 6.31
    and $args{LICENSE} = 'perl';

$mmv >= 6.4501
    and $args{META_MERGE} = {
	'meta-spec'	=> {
	    version	=> 2,
	},
	no_index	=> {
	    directory	=> [ qw{ inc t xt } ],
	},
	resources	=> {
#	    bugtracker	=> {
#                web	=> 'https://rt.cpan.org/Public/Dist/Display.html?Name=PPIx-LineToSub',
#                mailto  => 'wyant@cpan.org',
#            },
	    license	=> 'http://dev.perl.org/licenses/',
	    repository	=> {
		type	=> 'git',
		url	=> 'git://github.com/trwyant/perl-PPIx-LineToSub.git',
		web	=> 'https://github.com/trwyant/perl-PPIx-LineToSub',
	    },
	},
	provides(),
};

$mmv >= 6.4701
    and $args{MIN_PERL_VERSION} = 5.008004;

$mmv >= 6.5702
    or $args{AUTHOR} = join ', ', @{ $args{AUTHOR} };

my $build_requires = {
#   'Test::More'	=> 0.88,	# Because of done_testing().
};

$mmv >= 6.5501
    and $args{BUILD_REQUIRES} = $build_requires
    or $mmv >= 6.4501
    and $args{META_MERGE}{build_requires} = $build_requires;

WriteMakefile( %args );

sub MY::postamble {
    my ( $self, @args ) = @_;

    my $authortest = $self->test_via_harness(
	'$(FULLPERLRUN)', '$(AUTHORTEST_FILES)' );
    $authortest =~ s/ \s+ \z //smx;
    $authortest =~ s/ \A \s+ //smx;
    chomp $authortest;

    return <<"EOD";

AUTHORTEST_FILES = t/*.t xt/author/*.t

authortest :: pure_all
	AUTHOR_TESTING=1 $authortest

testcover :: pure_all
	cover -test
EOD
}

sub provides {
    -d 'lib'
	or return;
    local $@ = undef;
    my $provides = eval {
	require Module::Metadata;
	Module::Metadata->provides( version => 2, dir => 'lib' );
    } or return;
    return ( provides => $provides );
}

# ex: set textwidth=72 :
