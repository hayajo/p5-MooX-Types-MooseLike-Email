use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

{
  package MyClass;
  use Moo;
  use MooX::Types::MooseLike::Email qw/EmailMessage/;
  use Scalar::Util qw(blessed);
  has 'message'        => ( isa => EmailMessage, is => 'ro' );
  has 'coerce_message' => (
    isa    => EmailMessage,
    is     => 'ro',
    coerce => sub {
          return ( $_[0] and blessed( $_[0] ) and blessed( $_[0] ) ne 'Regexp' )
              ? $_[0]
              : Email::Simple->new( $_[0] );
      },
  );
}

my $text = <<'TEXT';
From: example@example.com
To: example@example.com
Subject: test
Date: Thu Jan 10 07:51:30 2013

Hello World
TEXT

my $msg = Email::Simple->new($text);

lives_ok { MyClass->new( message => $msg ) }
    'an ok email';
throws_ok { MyClass->new( message => $text) }
    qr/recognized by Email::Abstract/, 'Throws as not a valid email';
lives_ok { MyClass->new( coerce_message => $text ) }
    'an ok email';
