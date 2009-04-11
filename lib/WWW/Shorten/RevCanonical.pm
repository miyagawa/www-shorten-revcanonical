package WWW::Shorten::RevCanonical;

use strict;
use 5.008_001;
our $VERSION = '0.01';

use base qw( WWW::Shorten::generic Exporter );
our @EXPORT = qw( makeashorterlink makealongerlink );

use Carp;
use LWP::UserAgent;
use XML::LibXML;

sub _ua {
    my $ua = LWP::UserAgent->new;
    $ua->env_proxy;
    $ua->parse_head(0);
    $ua;
}

sub makeashorterlink {
    my $url = shift or croak "URL is required";

    my $content = _ua->get($url)->content;

    my $parser = XML::LibXML->new();
    $parser->recover(1);
    $parser->recover_silently(1);
    $parser->keep_blanks(0);
    $parser->expand_entities(1);
    $parser->no_network(1);

    my $doc = $parser->parse_html_string($content);
    my @links = $doc->findnodes("//link[contains(concat(' ', \@rev, ' '), ' canonical ')]");
    if (@links) {
        return $links[0]->getAttribute('href');
    }

    return;
}

sub makealongerlink {
    my $tiny_url = shift or croak "URL is required";

    my $res = _ua->get($tiny_url);
    return unless $res->redirects;

    return $res->request->uri;
}

1;
__END__

=encoding utf-8

=for stopwords TinyURL

=for test_synopsis
my $long_url;

=head1 NAME

WWW::Shorten::RevCanonical - Shorten URL using rev="canonical"

=head1 SYNOPSIS

  use WWW::Shorten 'RevCanonical';

  my $short_url = makeashorterlink($long_url); # Note that this could fail and return undef

=head1 DESCRIPTION

WWW::Shorten::RevCanonical is a WWW::Shorten plugin to extract
rev="canonical" link from HTML web pages. Unlike other URL shortening
services, the ability to make a short URL from rev="canonical" depends
on whether the target site implements the tag, so the call to
C<makeashorterlink> could fail, and in that case you'll get L<undef>
result. You might want to fallback to other shorten services like
I<TinyURL>.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<WWW::Shorten>, L<http://revcanonical.wordpress.com/>

=cut
