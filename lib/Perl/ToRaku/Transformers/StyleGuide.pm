package Perl::ToRaku::Transformers::StyleGuide;

use strict;
use warnings;

# Don't use generic 'token' terms, though it's tempting.

# If PPI doesn't *quite* handle things as you'd like:
# Please do as much work with PPI in YourModule,pm, and then
# create YourModule_Workarounds.pm that does what PPI can't.
#
# You'll see $self->content is ready for you to grep through to fill in bits
# that PPI doesn't catch, such as the 'v1.2.3' of a package declaration. It's
# not usually PPI's fault, just a bit of new syntax that came out since the
# module was finalized.
#
# Writing a regression test, once that's all straightened out, might also be
# a nice thing. That way future maintainers can remove the Workaround modules
# one at a time, and if no tests blow chunks, the Workaround is no longer needed.

# This will get subsumed into something like a --dry-run flag, but for now it's going
# to be just a simple BEFORE and AFTER comment below:
# |
# V
# 'What the Perl version of your code looks like'
# =>
# 'What the Raku version of your code should look like afterwards.'
#
sub transformer {
  my $self = shift; # Chosen over @_ purely at random.
  my $ppi  = shift;

  return; # Prevent the module from actually doing anything, as it shouldn't.

  # I'm not sure what else would work quasi-generically.
  # Names will get confused easily otherwise, and you'd have...
  #
  # %operator = ( '&' => '+&' ); $operator{ $operator->name } = 1;
  #
  my %map = ( );

  # Use this style for early returns. Yes, even when checking something.
  # It keeps indents closer to the left. Imagine this instead:
  #
  # my $token = $ppi->find_first( 'PPI::Comment' );
  # if ( $token ) {
  #   # Unneeded level of indent here, probably throughout the code.
  # }
  #
  my $token;
  return unless $self->{ppi};
  return unless $token = $ppi->find_first( 'PPI::Comment' );

  # As much as I hate to say it, save tokens you've found in a temporary variable.
  # Yes, it's redundant, but when someone comes along to debug your code it'll save
  # them from duplicating your code or rewriting it to debug the list of tokens
  # you're actually getting.
  #
  my $tokens = $ppi->find( 'PPI::Comment' );

  # Also, use the brace form here for dereferencing, I guess. No strong feelings here,
  # but I'm going to write the code this way.
  #
  if ( $tokens ) {
    for my $token ( @{ $tokens } ) {
    }
  }
  
  # Save newly-created tokens into a temporary variable.
  # You don't really need it after testing, but remember that
  # someone after you will want to see what this thing looks like.
  # Especially tokens with nested content.
  #
  # Also, name the variable after the type, just to help clarify things.
  #
  my $new_comment = PPI::Comment->new( 'hello world' );
  
}

1;
