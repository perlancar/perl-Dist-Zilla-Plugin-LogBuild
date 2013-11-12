package Dist::Zilla::Plugin::LogBuild;

use 5.010;
use Moose;
with 'Dist::Zilla::Role::FileGatherer';

# VERSION

use namespace::autoclean;

has filename => (
    is  => 'ro',
    isa => 'Str',
    default => 'build.log',
);

sub gather_files {
    require Dist::Zilla::File::FromCode;

    my ($self, $arg) = @_;

    my $zilla = $self->zilla;
    my $file  = Dist::Zilla::File::FromCode->new({
        name => $self->filename,
        code_return_type => 'text',
        code => sub {
            my @ct;

            push @ct, "* This distribution is built with Dist::Zilla ".
                "$Dist::Zilla::VERSION on ${\(scalar localtime)}\n\n";

            push @ct, "* Loaded Dist::Zilla plugins\n";
            for (sort keys %INC) {
                next unless m!^\ADist/Zilla/Plugin!;
                no strict 'refs';
                my $pkg = $_; $pkg =~ s!/!::!g; $pkg =~ s/\.pm\z//;
                push @ct, "  - $pkg ".(${"$pkg\::VERSION"} // 0)."\n";
            }
            push @ct, "\n";

            push @ct, "* Loaded Pod::Weaver plugins\n";
            for (sort keys %INC) {
                next unless m!^\APod/Weaver(?:/Plugin|\.)!;
                no strict 'refs';
                my $pkg = $_; $pkg =~ s!/!::!g; $pkg =~ s/\.pm\z//;
                push @ct, "  - $pkg ".(${"$pkg\::VERSION"} // 0)."\n";
            }
            push @ct, "\n";

            return join "", @ct;
        },
    });
    $self->add_file($file);
    return;
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Add build information file (build.log)

=head1 SYNOPSIS

In your F<dist.ini>:

  [LogBuild]


=head1 DESCRIPTION

This plugin generates a C<build.log> file containing build information (like the
list of loaded plugins and their versions) to aid in debugging.


=head1 SEE ALSO

L<Dist::Zilla>
