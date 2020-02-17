Hitch-Hiker's Guide to Writing Transformers
===========================================

# Who needs to know?

# What is it?

# Where does it go?

# When does it run?

# Why does it matter?

# How does it work?

# Transformers

## long_description()

Returns a string (usually a here-doc) that encapsulates what the transformer
actually does. At the bottom is a section (that may be broken out later) that
gives actual examples, with Perl and Raku code samples separated by '==>'.

This isn't checked right now in tests, but probably will be.

## short_description()

Returns a line (must be under 80 characters with newline - tested) that
is the nutshell version of what the transformer does.

## depends_upon()

Returns a list of transformer package names that need to be run *before* this
transformer. Right now the names are just the package names after Transformer::,
the rest isn't allowed.

Doesn't need to return anything, but it does need to exist. This may change
in the future.

## is_core()

Returns whether a transformer is declared "core" or not, by means of 1 or 0.
Transformers are declared as "core" if they are required for a Perl program to
come out the other end looking like newly-written Raku.

# The Heavy Lifting

The so-called "heavy lifting" can be done in one of two ways. The simplest
(so far) for you is probably to declare to the app what kind of node you
want to transform, and how to transform it. You can do this by defining just
two more methods:

## sub transforms { 'PPI::Token::Pod' }

This method returns a single string telling the app what kind of PPI node
it wants back. You can of course ask for any valid PPI node type, and it'll
pass every node of (in the example above POD) type one at a time to:

## sub transform { my ( $self, $node ) = @_; }

The application collects a list of nodes beforehand, so in principle you can
do anything you like inside the 'transform()' method and not affect the
iteration. Below are some somewhat-extreme examples that should make this point.

````
sub transform {
  my ($self, $POD) = @_;

  $POD->insert_after( PPI::Token:Pod->new( '=some new pod construct' ) );

  $POD->snext_sibling->find_first( 'PPI::Token::Pod' )->delete;
}
````

First, we add a new POD node *after* the current node. You're probably
expecting that this node will *NOT* be iterated over later, even though it
appears after the current node.

And you would be correct. We pick a list of nodes at the start and iterate over
those nodes. Theoretically not even the next line, which deletes a POD node
that we're about to iterate over, should affect the existing list of nodes.

Please do not take this as a challenge to abuse the system. If you truly need
to do something like this, you can use the full 'transformer()' method that
we discuss below to accomplish your goals. This gets the full PPI object tree
and lets you manipulate things as you want.

The combination of 'transforms()' and 'transform()' is only meant as a helper
to let you do simple tasks quickly.

## transformer()

This should be used any time you need to look above the scope of the node
you want to iterate over. This happens, for instance, when transforming
'sub new' to 'multi method new'. There are several reasons why we should
use the 'transformer()' method for this, but the main one is that this should
only ever run if we're transforming a package.

Learning that we're inside a package means going "above" the scope of the
PPI::Statement::Sub method, to search for the 'PPI::Statement::Package'
declaration. If we were using the other form, this test would be repeatedly
run for each PPI::Statement::Sub, which is wasteful.

So instead we use the 'transformer()' version which has the full PPI document
available, and can do one quick lookdown to see if the package declaration
is there.

Style Guide
===========

There's already a Transformers/StyleGuide.pm there, but this should be the
most up-to-date version of how to write a transformer.
