module Lightyear.Combinators

import Lightyear.Core

%access public

many : Monad m => ParserT m str a -> ParserT m str (List a)
many p = [| p :: lazy (many p) |] <|> pure []

some : Monad m => ParserT m str a -> ParserT m str (List a)
some p = [| p :: many p |]

sepBy1 : Monad m => ParserT m str a -> ParserT m str b -> ParserT m str (List a)
sepBy1 p s = [| p :: many (s $> p) |]

sepBy : Monad m => ParserT m str a -> ParserT m str b -> ParserT m str (List a)
sepBy p s = (p `sepBy1` s) <|> pure []

alternating : Monad m => ParserT m str a -> ParserT m str a -> ParserT m str (List a)
alternating p s = [| p :: lazy (alternating s p) |] <|> pure []

skip : Monad m => ParserT m str a -> ParserT m str ()
skip = map (const ())

-- the following names are inspired by the cut operator from Prolog

-- Monad-like operators

infixr 5 >!=
(>!=) : Monad m => ParserT m str a -> (a -> ParserT m str b) -> ParserT m str b
x >!= f = x >>= commitTo . f

infixr 5 >!
(>!) : Monad m => ParserT m str a -> ParserT m str b -> ParserT m str b
x >! y = x >>= \_ => commitTo y

-- Applicative-like operators

infixr 2 <$!>
(<$!>) : Monad m => ParserT m str (a -> b) -> ParserT m str a -> ParserT m str b
f <$!> x = f <$> commitTo x

infixr 2 <$!
(<$!) : Monad m => ParserT m str a -> ParserT m str b -> ParserT m str a
x <$! y = x <$ commitTo y

infixr 2 $!>
($!>) : Monad m => ParserT m str a -> ParserT m str b -> ParserT m str b
x $!> y = x $> commitTo y
